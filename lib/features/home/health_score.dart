part of '../../main.dart';

// Financial Health Score (approved point system):
//   Score = Action points (85) + Engagement points (15) - Deductions
//   kept between 0 and 100. Rolling last 30 days throughout.
// Action points = 85 x sum(weight x completion) / sum(active weights), over
// the active actions that have something due. Weights: Easy 10, Medium 15,
// Hard 20. Engagement = 10 x days opened / 30 + 5 x share labelled.
// Deductions D1-D7 are capped individually and at -30 in total.

const _healthWindow = Duration(days: 30);
const _healthIncomeGrace = Duration(days: 3);

/// Difficulty weights, by internal action ID.
const _healthActionWeights = <String, int>{
  'A1': 15, 'A3': 15, 'A20': 20, 'A19': 10, // G1
  'A9': 15, 'A8': 15, 'A22': 20, 'A10': 20, // G2
  'A12': 15, 'A23': 20, 'A30': 10, // G3
  'A26': 10, 'A27': 10, 'A28': 15, 'A29': 10, // G4
};

/// One active action's contribution.
class HealthActionLine {
  const HealthActionLine({
    required this.actionId,
    required this.weight,
    required this.completion,
    required this.points,
    required this.detail,
    this.text = '',
  });

  final String actionId;
  final int weight;

  /// 0-1, or null when nothing is due yet (left out of the score).
  final double? completion;
  final double points;
  final String detail;

  String get number => _actionNumber(actionId);

  /// The action with the user's own values filled in ("to ₱120,000").
  final String text;
  bool get counted => completion != null;
}

/// An engagement source or a deduction, with where it came from.
class HealthScoreItem {
  const HealthScoreItem({
    required this.code,
    required this.title,
    required this.detail,
    required this.points,
    required this.icon,
  });

  final String code;
  final String title;
  final String detail;

  /// Positive for engagement, negative for deductions.
  final double points;
  final IconData icon;
}

class HealthScoreBreakdown {
  const HealthScoreBreakdown({
    required this.score,
    required this.actionPoints,
    required this.engagementPoints,
    required this.deductionTotal,
    required this.actions,
    required this.engagement,
    required this.deductions,
  });

  /// Null until at least one active action has something due.
  final double? score;
  final double actionPoints;
  final double engagementPoints;

  /// Sum of deductions after the -30 cap (negative or zero).
  final double deductionTotal;
  final List<HealthActionLine> actions;
  final List<HealthScoreItem> engagement;
  final List<HealthScoreItem> deductions;

  bool get hasActions => actions.isNotEmpty;

  String get band {
    final value = score;
    if (value == null) return hasActions ? 'Starting soon' : 'No actions yet';
    if (value >= 80) return 'Thriving';
    if (value >= 60) return 'Healthy';
    if (value >= 40) return 'Building';
    return 'Needs attention';
  }
}

HealthScoreBreakdown computeHealthScore(AppState state) {
  final now = AppClock.now();
  // Nothing before tracking began counts: the first day Shellby was opened,
  // which "Reset account" moves to the reset day.
  final trackingStart = state.healthTrackingStart;
  final windowStart = now.subtract(_healthWindow);
  final since = trackingStart != null && trackingStart.isAfter(windowStart)
      ? trackingStart.subtract(const Duration(microseconds: 1))
      : windowStart;
  bool inWindow(DateTime? date) =>
      date != null && date.isAfter(since) && !date.isAfter(now);

  double ledgerSince(Set<String> types, DateTime from, [DateTime? to]) =>
      state.d1Ledger.where((entry) {
        if (!types.contains(entry['type'])) return false;
        final date = DateTime.tryParse(entry['date']?.toString() ?? '');
        return date != null && date.isAfter(from) && !date.isAfter(to ?? now);
      }).fold(
          0.0,
          (total, entry) =>
              total + ((entry['amount'] as num?)?.toDouble() ?? 0));

  double configuredPct(String actionId) {
    final raw = state.actionFieldValues[actionId]?['pct'] ?? '';
    final value = double.tryParse(raw.replaceAll(',', '').trim());
    return value != null && value > 0 ? value : 10;
  }

  final incomes = (state.fakeMayaLink?.summary.transactions ??
          const <FakeMayaTransaction>[])
      .where((tx) => _isIncomeTransaction(tx) && inWindow(tx.createdAt))
      .toList();

  final actionIds = <String>{
    for (final ids in _goalActionIds.values)
      for (final id in ids)
        if (state.selectedActionIds.contains(id) &&
            _healthActionWeights.containsKey(id))
          id,
  }.toList();

  final deductions = <HealthScoreItem>[];
  var missedIncomes = 0;
  final missedDetail = <String>[];

  // ---- per-income actions: A1, A8, A12, A27 ----
  ({double? completion, String detail}) perIncome(
    String actionId,
    String ledgerType,
    String fundName,
  ) {
    final pct = configuredPct(actionId);
    var total = 0.0;
    var counted = 0;
    var fullyDone = 0;
    var missed = 0;
    for (final income in incomes) {
      final allocated = state.d1Ledger
          .where((entry) =>
              entry['type'] == ledgerType &&
              entry['sourceTransactionId'] == income.transactionId)
          .fold(
              0.0,
              (acc, entry) =>
                  acc + ((entry['amount'] as num?)?.toDouble() ?? 0));
      final expected = income.amount * pct / 100;
      final pending = allocated <= 0 &&
          now.difference(income.createdAt!) <= _healthIncomeGrace;
      if (pending || expected <= 0) continue;
      final ratio = (allocated / expected).clamp(0.0, 1.0);
      total += ratio;
      counted++;
      if (ratio >= .999) fullyDone++;
      if (allocated <= 0) missed++;
    }
    if (missed > 0) {
      missedIncomes += missed;
      missedDetail.add('${_actionNumber(actionId)} ($missed)');
    }
    if (counted == 0) {
      return (completion: null, detail: 'No income to allocate yet');
    }
    return (
      completion: total / counted,
      detail: 'Set aside ${pct.toStringAsFixed(0)}% to the $fundName from '
          '$fullyDone of $counted incomes'
    );
  }

  ({double? completion, String detail}) evaluate(String id) {
    switch (id) {
      case 'A1':
        return perIncome(id, 'essential_deposit', 'Essential Expenses Fund');
      case 'A8':
        return perIncome(id, 'emergency_deposit', 'Emergency Fund');
      case 'A12':
        return perIncome(id, 'investment_deposit', 'Investment Fund');
      case 'A27':
        return perIncome(id, 'lifestyle_payday', 'Lifestyle Fund');

      case 'A3': // category budgets, with D1 per category
        final budgets = <String, double>{};
        if (state.categorySpendingBudgets.isNotEmpty) {
          budgets.addAll(state.categorySpendingBudgets);
        } else {
          final values = state.actionFieldValues['A3'] ?? const {};
          final cap = double.tryParse(
                  (values['amt'] ?? '').replaceAll(',', '').trim()) ??
              0;
          for (final category in (values['categories'] ?? '').split(',')) {
            if (category.trim().isNotEmpty && cap > 0) {
              budgets[canonicalExpenseCategory(category.trim())] = cap;
            }
          }
        }
        if (budgets.isEmpty) {
          return (completion: null, detail: 'No category budgets set yet');
        }
        final spent = <String, double>{};
        for (final tx in state.allTransactions) {
          if (tx.amount >= 0 ||
              !tx.isLabeled ||
              tx.excludedFromInsights ||
              !inWindow(tx.createdAt)) {
            continue;
          }
          final category = canonicalExpenseCategory(tx.category ?? '');
          if (!budgets.containsKey(category)) continue;
          spent[category] = (spent[category] ?? 0) + tx.amount.abs();
        }
        var categoryDeduction = 0.0;
        for (final entry in budgets.entries) {
          final used = spent[entry.key] ?? 0;
          if (entry.value <= 0 || used <= entry.value) continue;
          final overPct = (used - entry.value) / entry.value * 100;
          final points = math.min(5.0, overPct * .1);
          categoryDeduction += points;
          deductions.add(HealthScoreItem(
            code: 'D1',
            title: '${entry.key} over budget',
            detail: '${money(used)} spent vs ${money(entry.value)} budget '
                '(${overPct.toStringAsFixed(0)}% over)',
            points: -points,
            icon: Icons.pie_chart_rounded,
          ));
        }
        // D1 total cap: trim the last items if the categories pass -10.
        if (categoryDeduction > 10) {
          _capItems(deductions, 'D1', 10);
        }
        final totalBudget = budgets.values.fold(0.0, (a, b) => a + b);
        final totalSpent = spent.values.fold(0.0, (a, b) => a + b);
        return (
          completion: totalSpent <= totalBudget
              ? 1.0
              : (totalBudget / totalSpent).clamp(0.0, 1.0),
          detail: '${money(totalSpent)} spent of ${money(totalBudget)} in '
              'budgeted categories'
        );

      case 'A20':
        final target = _configuredActionAmount(
            state, 'A20', _recommendedMonthlyEarnings(state));
        final cashIn = incomes.fold(0.0, (acc, tx) => acc + tx.amount);
        if (target <= 0) {
          return (completion: null, detail: 'No cash-in target set');
        }
        return (
          completion: (cashIn / target).clamp(0.0, 1.0),
          detail: '${money(cashIn)} brought in of ${money(target)}'
        );

      case 'A19':
        final floor = _configuredActionAmount(
            state, 'A19', _recommendedEssentialFundFloor(state));
        final balance = state.essentialExpensesBalance;
        if (floor <= 0) return (completion: null, detail: 'No floor set');
        if (balance < floor) {
          final points = math.min(5.0, 5 * (floor - balance) / floor);
          deductions.add(HealthScoreItem(
            code: 'D5',
            title: 'Essential Expenses Fund below its floor',
            detail: '${money(floor - balance)} short of the ${money(floor)} '
                'floor (${_actionNumber('A19')})',
            points: -points,
            icon: Icons.home_work_rounded,
          ));
        }
        return (
          completion: (balance / floor).clamp(0.0, 1.0),
          detail: '${money(balance)} in the fund vs a ${money(floor)} floor'
        );

      case 'A9':
        final target = _configuredActionAmount(
            state, 'A9', _emergencyMonthlyDepositBase(state));
        final deposited =
            ledgerSince({'emergency_deposit', 'ef_replenish'}, since);
        if (target <= 0) return (completion: null, detail: 'No target set');
        return (
          completion: (deposited / target).clamp(0.0, 1.0),
          detail: '${money(deposited)} deposited of ${money(target)}'
        );

      case 'A22':
        final essentials = state.monthlyEssentialExpenseTotal;
        if (essentials <= 0) {
          return (completion: null, detail: 'Add monthly essentials first');
        }
        final targetMonths =
            double.tryParse(state.actionFieldValues['A22']?['months'] ?? '') ??
                3;
        final covered = state.displayedEmergencyFundBalance / essentials;
        return (
          completion: targetMonths <= 0
              ? 1.0
              : (covered / targetMonths).clamp(0.0, 1.0),
          detail: 'Covers ${covered.toStringAsFixed(1)} of '
              '${targetMonths.toStringAsFixed(0)} months of essentials'
        );

      case 'A10': // replenish withdrawals on time, with D4
        final days =
            double.tryParse(state.actionFieldValues['A10']?['days'] ?? '')
                    ?.round() ??
                14;
        var due = 0;
        var onTime = 0;
        final withdrawals = state.d1Ledger.where((entry) {
          if (entry['type'] != 'use_emergency') return false;
          final date = DateTime.tryParse(entry['date']?.toString() ?? '');
          return date != null &&
              date.isAfter(since.subtract(Duration(days: days)));
        }).toList();
        var overdue = 0;
        for (final withdrawal in withdrawals) {
          final date = DateTime.parse(withdrawal['date'].toString());
          final deadline = date.add(Duration(days: days));
          final amount = (withdrawal['amount'] as num?)?.toDouble() ?? 0;
          final refilled = ledgerSince({'ef_replenish'}, date, deadline);
          if (refilled + .5 >= amount) {
            due++;
            onTime++;
          } else if (deadline.isBefore(now)) {
            due++;
            overdue++;
          }
        }
        if (overdue > 0) {
          deductions.add(HealthScoreItem(
            code: 'D4',
            title: 'Emergency Fund not replenished on time',
            detail: '$overdue withdrawal${overdue == 1 ? '' : 's'} not '
                'refilled within $days days (${_actionNumber('A10')})',
            points: -math.min(10.0, overdue * 5.0),
            icon: Icons.shield_rounded,
          ));
        }
        return (
          completion: due == 0 ? 1.0 : onTime / due,
          detail: due == 0
              ? 'No withdrawals to replenish'
              : '$onTime of $due withdrawals refilled within $days days'
        );

      case 'A23':
        final target = state.configuredInvestmentPortfolioTarget;
        final progress = target <= 0
            ? 1.0
            : (state.investmentPortfolioValue / target).clamp(0.0, 1.0);
        const types = {
          'investment_deposit',
          'investment_monthly',
          'investment_windfall',
          'investment_sweep',
        };
        final recent = ledgerSince(types, since) > 0;
        final earlier =
            ledgerSince(types, now.subtract(const Duration(days: 60)), since) >
                0;
        final contributed = recent && earlier;
        return (
          completion: .5 * progress + (contributed ? .5 : 0),
          detail: '${(progress * 100).round()}% of the '
              '${money(target)} target · '
              '${contributed ? 'contributed in each of the last 2 months' : 'missed a month of contributions'}'
        );

      case 'A30':
        final target = state.investmentTargetAnnualReturnPercent;
        if (state.investmentReturnBaselineDate == null ||
            !state.hasInvestmentReturnWeek) {
          return (
            completion: .5,
            detail: 'Counts as 50% until the first full week is valued'
          );
        }
        final actual = state.investmentAnnualizedReturnPercent;
        return (
          completion: target <= 0 ? 1.0 : (actual / target).clamp(0.0, 1.0),
          detail: '${actual >= 0 ? '+' : ''}${actual.toStringAsFixed(1)}% '
              'annualized vs a ${target.toStringAsFixed(0)}% target'
        );

      case 'A26':
        final target = _configuredActionAmount(
            state, 'A26', _monthlySubscriptionBase(state));
        final reserved = ledgerSince({'lifestyle_subscription_reserve'}, since);
        if (target <= 0) return (completion: null, detail: 'No target set');
        return (
          completion: (reserved / target).clamp(0.0, 1.0),
          detail: '${money(reserved)} reserved of ${money(target)}'
        );

      case 'A28': // weekly non-essential limit, with D2
        final limit = _configuredActionAmount(state, 'A28', 1500);
        final today = DateTime(now.year, now.month, now.day + 1);
        var within = 0;
        var weeks = 0;
        var weekDeduction = 0.0;
        for (var week = 1; week <= 4; week++) {
          final end = today.subtract(Duration(days: 7 * (week - 1)));
          final start = end.subtract(const Duration(days: 7));
          final spent = _lifestyleSpendInRange(state, start, end);
          final withinLimit = limit <= 0 || spent <= limit;
          // A week that started before tracking only counts once it's over.
          if (withinLimit && start.isBefore(since)) continue;
          weeks++;
          if (withinLimit) {
            within++;
            continue;
          }
          final overPct = (spent - limit) / limit * 100;
          final points = math.min(3.0, 1 + overPct * .05);
          weekDeduction += points;
          deductions.add(HealthScoreItem(
            code: 'D2',
            title: 'Week over the non-essential limit',
            detail: '${money(spent)} spent vs ${money(limit)} '
                '(${overPct.toStringAsFixed(0)}% over), week ending '
                '${_shortDate(end.subtract(const Duration(days: 1)))}',
            points: -points,
            icon: Icons.local_mall_rounded,
          ));
        }
        if (weekDeduction > 8) _capItems(deductions, 'D2', 8);
        if (weeks == 0) {
          return (
            completion: null,
            detail: 'First full week still in progress'
          );
        }
        return (
          completion: within / weeks,
          detail: 'Within ${money(limit)} in $within of the last $weeks '
              'week${weeks == 1 ? '' : 's'}'
        );

      case 'A29':
        if (state.lifestyleHobbies.isEmpty) {
          return (completion: null, detail: 'No activities added yet');
        }
        var sum = 0.0;
        for (final hobby in state.lifestyleHobbies) {
          final target = (hobby['target'] as num?)?.toDouble() ?? 0;
          final created =
              DateTime.tryParse(hobby['createdAt']?.toString() ?? '') ?? now;
          final deadline = state.lifestyleHobbyDeadline(hobby);
          final span = deadline.difference(created).inDays;
          final elapsed = now.difference(created).inDays.clamp(0, span);
          final expected =
              span <= 0 ? target : target * math.max(1, elapsed) / span;
          final saved = state.lifestyleHobbyBalance(hobby['id'].toString());
          sum += expected <= 0 ? 1 : (saved / expected).clamp(0.0, 1.0);
        }
        final count = state.lifestyleHobbies.length;
        return (
          completion: sum / count,
          detail: '$count activit${count == 1 ? 'y' : 'ies'} · '
              '${(sum / count * 100).round()}% of the even pace'
        );
    }
    return (completion: null, detail: 'Not scored');
  }

  final lines = <HealthActionLine>[];
  for (final id in actionIds) {
    final result = evaluate(id);
    lines.add(HealthActionLine(
      actionId: id,
      weight: _healthActionWeights[id]!,
      completion: result.completion,
      points: 0,
      detail: result.detail,
    ));
  }
  lines.sort((a, b) => int.parse(a.number.substring(1))
      .compareTo(int.parse(b.number.substring(1))));

  // D3: missed per-income allocations.
  if (missedIncomes > 0) {
    deductions.add(HealthScoreItem(
      code: 'D3',
      title: 'Income not allocated within 3 days',
      detail: '$missedIncomes missed: ${missedDetail.join(', ')}',
      points: -math.min(5.0, missedIncomes * 1.0),
      icon: Icons.payments_rounded,
    ));
  }

  // D6: log-in streak breaks.
  var streakDeduction = 0.0;
  for (final entry in state.loginStreakBreaks) {
    final date = DateTime.tryParse(entry['date']?.toString() ?? '');
    if (!inWindow(date)) continue;
    final lost = (entry['lostStreak'] as num?)?.toDouble() ?? 0;
    streakDeduction += 1 + lost / 7;
  }
  if (streakDeduction > 0) {
    deductions.add(HealthScoreItem(
      code: 'D6',
      title: 'Log-in streak broken',
      detail: 'A streak ended in the last 30 days',
      points: -math.min(6.0, streakDeduction),
      icon: Icons.local_fire_department_rounded,
    ));
  }

  // D7: transactions left unlabelled for more than 7 days.
  final reviewable = state.allTransactions
      .where((tx) => inWindow(tx.createdAt) && !tx.isInternalFakeMayaTransfer);
  final staleUnlabelled = reviewable
      .where((tx) =>
          !tx.isLabeled &&
          now.difference(tx.createdAt!) > const Duration(days: 7))
      .length;
  if (staleUnlabelled > 0) {
    deductions.add(HealthScoreItem(
      code: 'D7',
      title: 'Unlabelled transactions',
      detail: '$staleUnlabelled transaction${staleUnlabelled == 1 ? '' : 's'} '
          'waiting more than 7 days for a label',
      points: -math.min(3.0, staleUnlabelled * .5),
      icon: Icons.label_off_rounded,
    ));
  }

  // Action points.
  final countedLines = lines.where((line) => line.counted).toList();
  final weightSum = countedLines.fold(0, (acc, line) => acc + line.weight);
  final scored = [
    for (final line in lines)
      HealthActionLine(
        actionId: line.actionId,
        weight: line.weight,
        completion: line.completion,
        points: line.counted && weightSum > 0
            ? 85 * line.weight * line.completion! / weightSum
            : 0,
        detail: line.detail,
        text: _healthActionText(state, line.actionId),
      ),
  ];
  final actionPoints = scored.fold(0.0, (acc, line) => acc + line.points);

  // Engagement points.
  final openedDays = state.appOpenDaysWithin(_healthWindow);
  final trackedDays = state.appOpenTrackedDays(_healthWindow);
  final openPoints =
      trackedDays <= 0 ? 0.0 : 10 * (openedDays / trackedDays).clamp(0.0, 1.0);
  final reviewList = reviewable.toList();
  final labelled = reviewList.where((tx) => tx.isLabeled).length;
  final labelShare = reviewList.isEmpty ? 1.0 : labelled / reviewList.length;
  final labelPoints = 5 * labelShare;
  final engagement = [
    HealthScoreItem(
      code: 'E1',
      title: 'Opened Shellby',
      detail: '$openedDays of the last $trackedDays days',
      points: openPoints,
      icon: Icons.phone_iphone_rounded,
    ),
    HealthScoreItem(
      code: 'E2',
      title: 'Labelled transactions',
      detail: reviewList.isEmpty
          ? 'No transactions to label in the last 30 days'
          : '$labelled of ${reviewList.length} transactions labelled',
      points: labelPoints,
      icon: Icons.sell_rounded,
    ),
  ];
  final engagementPoints = openPoints + labelPoints;

  deductions.sort((a, b) => a.points.compareTo(b.points));
  final rawDeductions = deductions.fold(0.0, (acc, item) => acc + item.points);
  final deductionTotal = math.max(-30.0, rawDeductions);

  // No money has moved since tracking began (a new or just-reset account):
  // there's nothing to grade yet, so the score starts from zero.
  final hasActivity =
      state.allTransactions.any((tx) => inWindow(tx.createdAt)) ||
          state.d1Ledger.any((entry) =>
              inWindow(DateTime.tryParse(entry['date']?.toString() ?? '')));

  final score = countedLines.isEmpty || !hasActivity
      ? null
      : (actionPoints + engagementPoints + deductionTotal)
          .clamp(0.0, 100.0)
          .toDouble();

  return HealthScoreBreakdown(
    score: score,
    actionPoints: actionPoints,
    engagementPoints: engagementPoints,
    deductionTotal: deductionTotal,
    actions: scored,
    engagement: engagement,
    deductions: deductions,
  );
}

String _healthActionText(AppState state, String actionId) {
  final action = _d2Actions[actionId];
  if (action == null) return actionId;
  final values = state.actionFieldValues[actionId] ?? const {};
  var text = action.text;
  for (final field in action.fields) {
    final raw = (values[field.key] ?? '').replaceAll(',', '').trim();
    final number = double.tryParse(raw);
    if (raw.isEmpty) continue;
    final shown = number == null || field.isPercent
        ? raw
        : _groupThousands(number.round());
    text = text.replaceFirst('X', shown);
  }
  return text;
}

String _groupThousands(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Keeps the total of [code] items at [cap] by trimming the smallest ones.
void _capItems(List<HealthScoreItem> items, String code, double cap) {
  final matching = items.where((item) => item.code == code).toList()
    ..sort((a, b) => a.points.compareTo(b.points)); // most negative first
  var remaining = cap;
  for (final item in matching) {
    final index = items.indexOf(item);
    final allowed = math.min(-item.points, remaining);
    remaining -= allowed;
    items[index] = HealthScoreItem(
      code: item.code,
      title: item.title,
      detail: item.detail,
      points: -allowed,
      icon: item.icon,
    );
  }
  items.removeWhere((item) => item.code == code && item.points == 0);
}

String _formatPoints(double points) {
  if (points.abs() < .05) return '0';
  final sign = points >= 0 ? '+' : '−';
  final value = points.abs();
  return '$sign${value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1)}';
}

// ---------------------------------------------------------------- page --

class FinancialHealthScoreScreen extends StatelessWidget {
  const FinancialHealthScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final breakdown = computeHealthScore(state);
    final counted = breakdown.actions.where((line) => line.counted).toList();
    final waiting = breakdown.actions.where((line) => !line.counted).toList();
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _title),
        title: const Text(
          'Your score',
          style: TextStyle(color: _title, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            _HealthScoreHeader(breakdown: breakdown),
            const SizedBox(height: 16),
            _HealthScoreSummary(breakdown: breakdown),
            const SizedBox(height: 22),
            _HealthSectionTitle(
              title: 'Actions',
              trailing: '${_formatPoints(breakdown.actionPoints)} / 85',
            ),
            const SizedBox(height: 10),
            if (breakdown.actions.isEmpty)
              const _HealthEmptyCard(
                text: 'Pick an action on the Goals page to start your score.',
              )
            else ...[
              for (final line in counted) ...[
                _HealthActionRow(line: line),
                const SizedBox(height: 8),
              ],
              if (waiting.isNotEmpty) ...[
                const SizedBox(height: 4),
                const Text(
                  'NOT COUNTED YET',
                  style: TextStyle(
                    color: _body,
                    fontSize: 10.5,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                for (final line in waiting) ...[
                  _HealthActionRow(line: line),
                  const SizedBox(height: 8),
                ],
              ],
            ],
            const SizedBox(height: 18),
            _HealthSectionTitle(
              title: 'Engagement',
              trailing: '${_formatPoints(breakdown.engagementPoints)} / 15',
            ),
            const SizedBox(height: 10),
            for (final item in breakdown.engagement) ...[
              _HealthItemRow(item: item),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 18),
            _HealthSectionTitle(
              title: 'Deductions',
              trailing: _formatPoints(breakdown.deductionTotal),
              negative: breakdown.deductionTotal < 0,
            ),
            const SizedBox(height: 10),
            if (breakdown.deductions.isEmpty)
              const _HealthEmptyCard(
                text: 'No deductions in the last 30 days. Nice work.',
                positive: true,
              )
            else ...[
              for (final item in breakdown.deductions) ...[
                _HealthItemRow(item: item),
                const SizedBox(height: 8),
              ],
              if (breakdown.deductionTotal >
                  breakdown.deductions.fold(0.0, (s, i) => s + i.points))
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    'Deductions are capped at −30 in total.',
                    style: TextStyle(
                        color: _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
            ],
            const SizedBox(height: 20),
            const Text(
              'How it works: actions earn up to 85 points, weighted by how hard '
              'they are and how consistently you did them over the last 30 '
              'days. Opening Shellby and labelling transactions earn up to 15. '
              'Deductions point at habits worth fixing this week.',
              style: TextStyle(
                color: _body,
                fontSize: 11.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthScoreHeader extends StatelessWidget {
  const _HealthScoreHeader({required this.breakdown});
  final HealthScoreBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final score = breakdown.score;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_purple, Color.lerp(_purple, Colors.black, .28)!],
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: .18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Health Score',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
                if (score != null) ...[
                  const SizedBox(height: 8),
                  ShareItChip(
                    achievement: healthScoreShareable(score, breakdown.band),
                    compact: true,
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    breakdown.band,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  score == null
                      ? breakdown.hasActions
                          ? 'Your score starts once your first action comes due.'
                          : 'Pick an action to start your score.'
                      : 'Based on your last 30 days of activity.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .82),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          _HealthScoreRing(score: score),
        ],
      ),
    );
  }
}

class _HealthScoreRing extends StatelessWidget {
  const _HealthScoreRing({required this.score});
  final double? score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: (score ?? 0) / 100,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: .22),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score == null ? '—' : '${score!.round()}',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'of 100',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthScoreSummary extends StatelessWidget {
  const _HealthScoreSummary({required this.breakdown});
  final HealthScoreBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    Widget tile(String label, String value, Color color) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
    return Row(
      children: [
        tile('Actions', _formatPoints(breakdown.actionPoints), _purple),
        const SizedBox(width: 8),
        tile('Engagement', _formatPoints(breakdown.engagementPoints), _brand),
        const SizedBox(width: 8),
        tile(
          'Deductions',
          _formatPoints(breakdown.deductionTotal),
          breakdown.deductionTotal < 0 ? _red : _body,
        ),
      ],
    );
  }
}

class _HealthSectionTitle extends StatelessWidget {
  const _HealthSectionTitle({
    required this.title,
    required this.trailing,
    this.negative = false,
  });
  final String title;
  final String trailing;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.fredoka(
              color: _title,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          trailing,
          style: TextStyle(
            color: negative ? _red : _body,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _HealthActionRow extends StatelessWidget {
  const _HealthActionRow({required this.line});
  final HealthActionLine line;

  @override
  Widget build(BuildContext context) {
    final completion = line.completion;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: line.counted ? .12 : .06),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Text(
              line.number,
              style: TextStyle(
                color: line.counted ? _purple : _body,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.text,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 12.5,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  line.detail,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 11,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (completion != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: completion,
                      minHeight: 5,
                      color: completion >= .8
                          ? _sage
                          : completion >= .5
                              ? _amber
                              : _red,
                      backgroundColor: _border,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                line.counted ? _formatPoints(line.points) : '—',
                style: TextStyle(
                  color: line.counted ? _sage : _body,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                completion == null
                    ? 'weight ${line.weight}'
                    : '${(completion * 100).round()}% · w${line.weight}',
                style: const TextStyle(
                  color: _body,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthItemRow extends StatelessWidget {
  const _HealthItemRow({required this.item});
  final HealthScoreItem item;

  @override
  Widget build(BuildContext context) {
    final negative = item.points < 0;
    final color = negative ? _red : _sage;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.detail,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 11,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatPoints(item.points),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthEmptyCard extends StatelessWidget {
  const _HealthEmptyCard({required this.text, this.positive = false});
  final String text;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: positive ? _sage.withValues(alpha: .08) : _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: positive ? _sage.withValues(alpha: .25) : _border),
      ),
      child: Row(
        children: [
          Icon(
            positive ? Icons.verified_rounded : Icons.info_outline_rounded,
            color: positive ? _sage : _body,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: positive ? _sage : _body,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
