part of '../../main.dart';

class PreparationOrientScreen extends StatefulWidget {
  const PreparationOrientScreen({super.key});

  @override
  State<PreparationOrientScreen> createState() =>
      _PreparationOrientScreenState();
}

class _PreparationOrientScreenState extends State<PreparationOrientScreen> {
  final controller = PageController();
  int index = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void next() {
    if (index == _slides.length - 1) {
      _push(context, const FinancialConcernScreen());
      return;
    }
    controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  static const _slides = [
    OrientationSlideData(
      icon: Icons.flag_rounded,
      illustrationAsset: 'assets/images/healthy_shelby.png',
      title: 'Shelby helps you develop healthier financial habits.',
      body:
          'He helps make goals more attainable and money decisions easier to act on.',
      accent: _brand,
    ),
    OrientationSlideData(
      icon: Icons.insights_rounded,
      illustrationAsset: 'assets/images/patterns_shelby.png',
      title: 'It looks for useful patterns.',
      body:
          'Shelby can help notice spending rhythms, savings gaps, debt pressure, and moments that affect your choices.',
      accent: _purple,
    ),
    OrientationSlideData(
      icon: Icons.lightbulb_rounded,
      illustrationAsset: 'assets/images/share_shelby.png',
      title: 'It shares gentle ideas.',
      body:
          'You may get simple prompts, goal ideas, and check-in suggestions that support the focus you choose.',
      accent: _amber,
    ),
    OrientationSlideData(
      icon: Icons.lock_rounded,
      illustrationAsset: 'assets/images/control_shelby.png',
      title: 'You stay in control.',
      body:
          'Shelby is not a bank, broker, or financial adviser. It will not move money, change device settings, read files, or collect data you do not approve.',
      accent: _red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLast = index == _slides.length - 1;
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    color: _brand,
                    icon: const Icon(Icons.chevron_left_rounded, size: 32),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        _push(context, const FinancialConcernScreen()),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: _body,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  itemCount: _slides.length,
                  onPageChanged: (value) => setState(() => index = value),
                  itemBuilder: (context, slideIndex) =>
                      OrientationSlide(data: _slides[slideIndex]),
                ),
              ),
              OrientationDots(count: _slides.length, index: index),
              const SizedBox(height: 24),
              PrimaryButton(
                label: isLast ? 'Choose Focus' : 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: next,
              ),
              const SizedBox(height: 12),
              const Text(
                'Educational guidance only. Not a substitute for licensed financial advice.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _body,
                  fontSize: 11,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrientationSlideData {
  const OrientationSlideData({
    required this.icon,
    required this.illustrationAsset,
    required this.title,
    required this.body,
    required this.accent,
  });

  final IconData icon;
  final String illustrationAsset;
  final String title;
  final String body;
  final Color accent;
}

class OrientationSlide extends StatelessWidget {
  const OrientationSlide({super.key, required this.data});

  final OrientationSlideData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 560;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OrientationIllustration(data: data, compact: compact),
            SizedBox(height: compact ? 20 : 34),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: compact ? 28 : 34,
                  ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 330),
              child: Text(
                data.body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _body,
                  fontSize: 16,
                  height: 1.38,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class OrientationIllustration extends StatelessWidget {
  const OrientationIllustration({
    super.key,
    required this.data,
    required this.compact,
  });

  final OrientationSlideData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 220.0 : 270.0;
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        data.illustrationAsset,
        fit: BoxFit.contain,
        semanticLabel: data.title,
      ),
    );
  }
}

class MiniBadge extends StatelessWidget {
  const MiniBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class OrientationDots extends StatelessWidget {
  const OrientationDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (dotIndex) {
        final active = dotIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? _brand : _border,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class GoalBranch {
  const GoalBranch({
    required this.layer,
    required this.layerDescription,
    required this.firstQuestion,
    required this.icon,
    required this.defaultGoalTitle,
    required this.defaultGoalDescription,
    required this.concerns,
  });

  final String layer;
  final String layerDescription;
  final String firstQuestion;
  final IconData icon;
  final String defaultGoalTitle;
  final String defaultGoalDescription;
  final List<GoalConcern> concerns;

  GoalConcern closestConcern(String answer) {
    final normalized = answer.toLowerCase();
    GoalConcern best = concerns.first;
    var bestScore = -1;
    for (final concern in concerns) {
      final score = concern.keywords
          .where((keyword) => normalized.contains(keyword))
          .length;
      if (score > bestScore) {
        best = concern;
        bestScore = score;
      }
    }
    return best;
  }
}

class GoalConcern {
  const GoalConcern({
    required this.feltNeed,
    required this.followUp,
    required this.goalTitle,
    required this.goalDescription,
    required this.keywords,
    required this.actionIds,
    required this.backgroundEffect,
    this.enableEmotionalLogs = false,
    this.enableStressIndicators = false,
  });

  final String feltNeed;
  final String followUp;
  final String goalTitle;
  final String goalDescription;
  final List<String> keywords;
  final List<String> actionIds;
  final String backgroundEffect;
  final bool enableEmotionalLogs;
  final bool enableStressIndicators;
}

class GuidedPathway {
  const GuidedPathway({
    required this.layer,
    required this.steps,
  });

  final String layer;
  final List<GuidedStep> steps;
}

class GuidedStep {
  const GuidedStep({
    required this.title,
    required this.question,
    required this.options,
    this.multiSelect = false,
  });

  final String title;
  final String question;
  final List<GuidedOption> options;
  final bool multiSelect;
}

class GuidedOption {
  const GuidedOption({
    required this.label,
    required this.text,
    this.detail,
    this.goalTitle,
    this.keywords = const [],
  });

  final String label;
  final String text;
  final String? detail;
  final String? goalTitle;
  final List<String> keywords;

  String get displayText => detail == null ? text : '$text $detail';
}

// D1 goals (from D1.csv)
class D1Goal {
  const D1Goal(
      {required this.id, required this.title, required this.description});
  final String id;
  final String title;
  final String description;
}

// D2 action configurable fields
class ActionField {
  const ActionField(
      {required this.key,
      required this.label,
      required this.hint,
      this.isPercent = false});
  final String key;
  final String label;
  final String hint;
  final bool isPercent;
}

double _baselineMoney(AppState state, String key) {
  return double.tryParse(
        (state.onboardingBaselines[key] ?? '').replaceAll(',', '').trim(),
      ) ??
      0;
}

double _mapMoney(Map<String, dynamic> value, String key) {
  final raw = value[key];
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw?.toString().replaceAll(',', '').trim() ?? '') ?? 0;
}

double _roundMoney(num value, {double step = 500, double minimum = 100}) {
  final safe = math.max(minimum, value.toDouble());
  return (safe / step).ceil() * step;
}

int _roundPercent(num value, {int minimum = 1, int maximum = 100}) {
  return value.round().clamp(minimum, maximum);
}

List<String> _moneyOptions(num recommended, {double step = 500}) {
  final best = _roundMoney(recommended, step: step).round();
  return [
    best,
    _roundMoney(best * 0.85, step: step).round(),
    _roundMoney(best * 1.15, step: step).round(),
  ].map((value) => value.toString()).toSet().toList();
}

List<String> _percentOptions(num recommended,
    {int spread = 5, int minimum = 1, int maximum = 100}) {
  final best = _roundPercent(recommended, minimum: minimum, maximum: maximum);
  return [
    best,
    (best - spread).clamp(minimum, maximum),
    (best + spread).clamp(minimum, maximum),
  ].map((value) => value.toString()).toSet().toList();
}

List<String> _dayOptions(num recommended) {
  final best = recommended.round().clamp(1, 30);
  return [
    best,
    (best + 2).clamp(1, 30),
    (best + 4).clamp(1, 30),
  ].map((value) => value.toString()).toSet().toList();
}

List<double> _moneyListFromBaseline(AppState state, String key) {
  final raw = state.onboardingBaselines[key] ?? '';
  final values = <double>[];
  for (final line in raw.split(RegExp(r'[\n,;]+'))) {
    final match = RegExp(r'(\d[\d,]*(?:\.\d+)?)').allMatches(line).lastOrNull;
    final value = double.tryParse(match?.group(1)?.replaceAll(',', '') ?? '');
    if (value != null && value > 0) values.add(value);
  }
  return values;
}

double _monthlyIncomeBase(AppState state) {
  if (state.income > 0) return state.income;
  final ledgerTotal = state.onboardingIncomeLedger.fold<double>(
    0,
    (total, income) => total + _mapMoney(income, 'amount'),
  );
  if (ledgerTotal > 0) return ledgerTotal;
  if (state.monthlySalary > 0) return state.monthlySalary;
  return _baselineMoney(state, 'income_baseline');
}

int _paydaysPerMonth(AppState state) {
  final rhythm = state.incomeRhythm.toLowerCase();
  if (rhythm.contains('week') && rhythm.contains('2')) return 2;
  if (rhythm.contains('bi') || rhythm.contains('fortnight')) return 2;
  if (rhythm.contains('week')) return 4;
  if (rhythm.contains('twice') || rhythm.contains('semi')) return 2;
  return 1;
}

String _recommendedFrequency(AppState state) {
  final rhythm = state.incomeRhythm.toLowerCase();
  if (rhythm.contains('week') && rhythm.contains('2')) return 'Every 2 weeks';
  if (rhythm.contains('bi') || rhythm.contains('fortnight')) {
    return 'Every 2 weeks';
  }
  if (rhythm.contains('week')) return 'Weekly';
  return 'Monthly';
}

double _monthlyExpenseBase(AppState state) {
  if (state.cashFlowPyramidBaseline > 0) return state.cashFlowPyramidBaseline;
  final baseline = _baselineMoney(state, 'monthly_expenses');
  if (baseline > 0) return baseline;
  final combined = state.expenses + state.variableExpenses + state.debtPayments;
  if (combined > 0) return combined;
  final essential = state.monthlyEssentialExpenseTotal > 0
      ? state.monthlyEssentialExpenseTotal
      : _baselineMoney(state, 'essential_expenses');
  if (essential > 0) return essential * 1.25;
  return 10000;
}

double _monthlyEssentialBase(AppState state) {
  if (state.monthlyEssentialExpenseTotal > 0) {
    return state.monthlyEssentialExpenseTotal;
  }
  final baseline = _baselineMoney(state, 'essential_expenses');
  if (baseline > 0) return baseline;
  return _monthlyExpenseBase(state) * 0.70;
}

double _monthlyDiscretionaryBase(AppState state) {
  if (state.monthlyNonEssentialExpenseTotal > 0) {
    return state.monthlyNonEssentialExpenseTotal;
  }
  final baseline = _baselineMoney(state, 'discretionary_spend');
  if (baseline > 0) return baseline;
  if (state.variableExpenses > 0) return state.variableExpenses;
  return math.max(1000, _monthlyExpenseBase(state) * 0.20);
}

double _monthlyBillBase(AppState state) {
  final bills = _moneyListFromBaseline(state, 'bills');
  if (bills.isNotEmpty) {
    return bills.fold<double>(0, (total, value) => total + value);
  }
  return _monthlyEssentialBase(state) * 0.40;
}

double _categoryLimitBase(AppState state) {
  final categoryAverages = _moneyListFromBaseline(state, 'category_averages');
  if (categoryAverages.isNotEmpty) {
    final average =
        categoryAverages.fold<double>(0, (total, value) => total + value) /
            categoryAverages.length;
    return average * 0.90;
  }
  final categories = (state.onboardingBaselines['categories'] ?? '')
      .split(',')
      .where((item) => item.trim().isNotEmpty)
      .length;
  if (categories > 0) return _monthlyDiscretionaryBase(state) / categories;
  return _monthlyDiscretionaryBase(state) / 2;
}

double _emergencyBalanceBase(AppState state) {
  final baseline = _baselineMoney(state, 'emergency_balance');
  if (baseline > 0) return baseline;
  return math.max(state.emergencyFundBalance, state.accountBalance('Savings'));
}

double _emergencyTargetBase(AppState state) {
  final baseline = _baselineMoney(state, 'emergency_target');
  if (baseline > 0) return baseline;
  if (state.emergencyFundTarget > 0) return state.emergencyFundTarget;
  return _monthlyEssentialBase(state) * 3;
}

double _investmentMonthlyContributionBase(AppState state) {
  final income = math.max(1.0, _monthlyIncomeBase(state));
  final surplus = math.max(0.0, _monthlySurplusBase(state));
  if (surplus > 0) return math.min(surplus * 0.30, income * 0.15);
  return math.max(500.0, income * 0.05);
}

double _minimumDebtPaymentBase(AppState state) {
  final baseline = _baselineMoney(state, 'minimum_debt_payment');
  if (baseline > 0) return baseline;
  if (state.debtPayments > 0) return state.debtPayments;
  return _monthlyIncomeBase(state) * 0.05;
}

double _debtBalanceBase(AppState state) {
  final baseline = _baselineMoney(state, 'debt_balance');
  if (baseline > 0) return baseline;
  return state.liabilities.fold<double>(0, (total, item) => total + item.value);
}

double _monthlySurplusBase(AppState state) {
  final income = _monthlyIncomeBase(state);
  return income - _monthlyExpenseBase(state) - _minimumDebtPaymentBase(state);
}

double _goalMonthlyNeedBase(AppState state) {
  final goals = state.onboardingBaselines['goals'] ?? '';
  var monthlyNeed = 0.0;
  final now = DateTime.now();
  for (final line in goals.split('\n')) {
    final parts = line.split('|').map((part) => part.trim()).toList();
    if (parts.length < 3) continue;
    final balance = double.tryParse(parts[1].replaceAll(',', '')) ?? 0;
    final target = double.tryParse(parts[2].replaceAll(',', '')) ?? 0;
    final dueDate = parts.length >= 4 ? DateTime.tryParse(parts[3]) : null;
    final priority = parts.length >= 5
        ? (double.tryParse(parts[4].replaceAll(',', '')) ?? 1)
        : 1;
    final months = dueDate == null
        ? 12
        : math.max(1, ((dueDate.difference(now).inDays) / 30).ceil());
    monthlyNeed +=
        math.max(0, target - balance) / months / math.max(1, priority);
  }
  if (monthlyNeed > 0) return monthlyNeed;
  if (state.selectedGoalMonthlyTarget > 0) {
    return state.selectedGoalMonthlyTarget;
  }
  return math.max(1000, _monthlyIncomeBase(state) * 0.10);
}

double _availableEverydayCash(AppState state) {
  final baselineCash = _baselineMoney(state, 'cash_balance');
  final linkedCash = state.accountBalance('Wallet') + state.cashOnHandBalance;
  return math.max(baselineCash, linkedCash);
}

int _recommendedEverydayFundMonths(AppState state) {
  final expenses = _monthlyExpenseBase(state);
  final income = _monthlyIncomeBase(state);
  final irregularIncome = state.irregularIncomeFloor > 0 ||
      state.incomeType.toLowerCase().contains('irregular') ||
      !state.incomeRhythm.toLowerCase().contains('monthly');
  final tightCash = income > 0 && income < expenses * 1.15;
  final lowStartingCash = _availableEverydayCash(state) < expenses * 0.5;
  if (irregularIncome || tightCash || lowStartingCash) return 2;
  return 1;
}

double _recommendedMonthlyEarnings(AppState state) {
  final expenses = _monthlyExpenseBase(state);
  final currentIncome = _monthlyIncomeBase(state);
  final months = _recommendedEverydayFundMonths(state);
  final everydayTarget = expenses * months;
  final reserveGap =
      math.max(0.0, everydayTarget - _availableEverydayCash(state));
  final monthlyReserveBuild = reserveGap / 6;
  final desiredBreathingRoom = math.max(expenses * 0.10, monthlyReserveBuild);
  final target = math.max(currentIncome, expenses + desiredBreathingRoom);
  return math.max(1000, (target / 500).ceil() * 500);
}

double _emergencyMonthlyDepositBase(AppState state) {
  final gap =
      math.max(0.0, _emergencyTargetBase(state) - _emergencyBalanceBase(state));
  if (gap > 0) return math.max(_monthlyIncomeBase(state) * 0.05, gap / 12);
  return math.max(500, _monthlyIncomeBase(state) * 0.05);
}

List<String> _recommendationsForActionField(
  AppState state,
  D2Action action,
  ActionField field,
) {
  final income = math.max(1.0, _monthlyIncomeBase(state));
  final surplus = _monthlySurplusBase(state);
  final lowEverydayCash =
      _availableEverydayCash(state) < _monthlyExpenseBase(state);
  if (field.key == 'freq') {
    final best = _recommendedFrequency(state);
    return [
      best,
      if (best != 'Monthly') 'Monthly',
      if (best != 'Weekly') 'Weekly',
      if (best != 'Every 2 weeks') 'Every 2 weeks',
    ].take(3).toList();
  }
  if (field.key == 'days') {
    final predictable = state.billsRhythm.toLowerCase().contains('predict');
    final highAnxiety = state.anxiety >= 7;
    final irregularIncome = state.irregularIncomeFloor > 0 ||
        state.incomeType.toLowerCase().contains('irregular');
    final recommended = switch (action.id) {
      'A5' => highAnxiety
          ? 7
          : irregularIncome
              ? 5
              : predictable
                  ? 3
                  : 5,
      'A10' => irregularIncome ? 14 : 7,
      _ => 3,
    };
    return _dayOptions(recommended);
  }
  if (action.id == 'A1' && field.key == 'pct') {
    return _percentOptions(_monthlyEssentialBase(state) / income * 100,
        spread: 10, minimum: 30, maximum: 80);
  }
  if (action.id == 'A2' && field.key == 'amt') {
    return _moneyOptions(_monthlyDiscretionaryBase(state) * 0.90);
  }
  if (action.id == 'A3' && field.key == 'amt') {
    return _moneyOptions(_categoryLimitBase(state));
  }
  if (action.id == 'A4' && field.key == 'amt') {
    return _moneyOptions(_monthlyBillBase(state) / _paydaysPerMonth(state));
  }
  if (action.id == 'A6' && field.key == 'pct') {
    final protectedMoney = _monthlyEssentialBase(state) +
        _emergencyMonthlyDepositBase(state) +
        _goalMonthlyNeedBase(state);
    return _percentOptions(protectedMoney / income * 100,
        spread: 10, minimum: 50, maximum: 90);
  }
  if (action.id == 'A7' && field.key == 'pct') {
    final recommended = lowEverydayCash
        ? 50
        : state.irregularIncomeFloor > 0
            ? 35
            : 25;
    return _percentOptions(recommended, spread: 10, minimum: 10, maximum: 80);
  }
  if (action.id == 'A8' && field.key == 'pct') {
    return _percentOptions(_emergencyMonthlyDepositBase(state) / income * 100,
        spread: 5, minimum: 5, maximum: 25);
  }
  if (action.id == 'A9' && field.key == 'amt') {
    return _moneyOptions(_emergencyMonthlyDepositBase(state));
  }
  if (action.id == 'A22' && field.key == 'months') {
    final target = _emergencyTargetBase(state);
    final essentials = math.max(1.0, _monthlyEssentialBase(state));
    final recommended = math.max(3, (target / essentials).ceil());
    return [
      recommended,
      math.max(recommended + 1, 6),
      math.max(recommended + 3, 9),
    ].map((value) => value.clamp(1, 12).toString()).toSet().toList();
  }
  if (action.id == 'A11' && field.key == 'pct') {
    final minimumPayment = math.max(1.0, _minimumDebtPaymentBase(state));
    final recommended =
        surplus <= 0 ? 5 : (surplus * 0.25 / minimumPayment) * 100;
    return _percentOptions(recommended, spread: 5, minimum: 5, maximum: 30);
  }
  if (action.id == 'A12' && field.key == 'pct') {
    final monthlyInvestment = _investmentMonthlyContributionBase(state);
    return _percentOptions(monthlyInvestment / income * 100,
        spread: 5, minimum: 5, maximum: 20);
  }
  if (action.id == 'A23' && field.key == 'amt') {
    return _moneyOptions(math.max(
      state.investmentPortfolioTarget,
      _baselineMoney(state, 'investment_balance') * 1.25,
    ));
  }
  if (action.id == 'A24' && field.key == 'amt') {
    final balance = math.max(
      state.investmentBalance,
      _baselineMoney(state, 'investment_balance'),
    );
    return _moneyOptions(math.max(500, balance * 0.01));
  }
  if (action.id == 'A25' && field.key == 'amt') {
    final balance = math.max(
      state.investmentBalance,
      _baselineMoney(state, 'investment_balance'),
    );
    return _moneyOptions(math.max(500, balance * 0.03));
  }
  if (action.id == 'A13' && field.key == 'pct') {
    final debtHeavy =
        _debtBalanceBase(state) > _baselineMoney(state, 'investment_balance');
    final recommended = lowEverydayCash
        ? 20
        : debtHeavy
            ? 50
            : 35;
    return _percentOptions(recommended, spread: 10, minimum: 10, maximum: 80);
  }
  if (action.id == 'A14' && field.key == 'pct') {
    final recommended = surplus <= 0
        ? 25
        : surplus > income * 0.20
            ? 60
            : 50;
    return _percentOptions(recommended, spread: 10, minimum: 20, maximum: 80);
  }
  if (action.id == 'A15' && field.key == 'amt') {
    final recommended = surplus > 0 ? surplus * 0.15 : income * 0.03;
    return _moneyOptions(recommended);
  }
  if (action.id == 'A16' && field.key == 'amt') {
    return _moneyOptions(_goalMonthlyNeedBase(state) / _paydaysPerMonth(state));
  }
  if (action.id == 'A16' && field.key == 'pct') {
    return _percentOptions(_goalMonthlyNeedBase(state) / income * 100,
        spread: 5, minimum: 5, maximum: 25);
  }
  if (action.id == 'A17' && field.key == 'pct') {
    final recommended = surplus <= 0 ? 10 : 20;
    return _percentOptions(recommended, spread: 5, minimum: 5, maximum: 35);
  }
  if (action.id == 'A18' && field.key == 'pct') {
    final recommended = _debtBalanceBase(state) > income * 3 ? 30 : 20;
    return _percentOptions(recommended, spread: 10, minimum: 10, maximum: 50);
  }
  if (action.id == 'A19' && field.key == 'amt') {
    final expenses = _monthlyExpenseBase(state);
    final recommended = expenses * _recommendedEverydayFundMonths(state);
    return [
      recommended,
      recommended + expenses,
      recommended + (expenses * 2),
    ]
        .map((value) => ((value / 500).ceil() * 500).toStringAsFixed(0))
        .toSet()
        .toList();
  }
  if (action.id == 'A21' && field.key == 'days') {
    final essentials = _monthlyEssentialBase(state);
    final wallet = _availableEverydayCash(state);
    final currentDays =
        essentials <= 0 ? 7.0 : wallet / math.max(1, essentials / 30);
    final recommended = currentDays < 7 ? 7 : math.min(21, currentDays + 3);
    return _dayOptions(recommended);
  }
  if (action.id == 'A20' && field.key == 'amt') {
    final recommended = _recommendedMonthlyEarnings(state).round();
    return [recommended, recommended * 1.1, recommended * 1.25]
        .map((value) => ((value / 500).ceil() * 500).toStringAsFixed(0))
        .toSet()
        .toList();
  }
  return _recommendationsForField(field);
}

String _recommendedValueText(
  AppState state,
  D2Action action,
  ActionField field,
) {
  final recommended =
      _recommendationsForActionField(state, action, field).first;
  return _fieldValueLabel(field, recommended);
}

String _recommendationFormulaForActionField(
  AppState state,
  D2Action action,
  ActionField field,
) {
  final income = math.max(1.0, _monthlyIncomeBase(state));
  final essentials = _monthlyEssentialBase(state);
  final surplus = _monthlySurplusBase(state);
  final value = _recommendedValueText(state, action, field);
  if (field.key == 'freq') {
    return '$value: matched to your income rhythm (${state.incomeRhythm}).';
  }
  if (field.key == 'days') {
    return switch (action.id) {
      'A5' =>
        '$value: based on bill predictability, income stability, and anxiety level.',
      'A10' =>
        '$value: 7 days for regular income, 14 days when income is irregular.',
      _ => '$value: default reminder window for this action.',
    };
  }
  return switch (action.id) {
    'A1' =>
      '$value: essential expenses (${money(essentials)}) divided by monthly income (${money(income)}).',
    'A2' =>
      '$value: 90% of your monthly discretionary spending (${money(_monthlyDiscretionaryBase(state))}).',
    'A3' =>
      '$value: average selected-category spend, reduced by 10% for a realistic cap.',
    'A4' =>
      '$value: monthly bills (${money(_monthlyBillBase(state))}) divided by ${_paydaysPerMonth(state)} payday(s).',
    'A6' =>
      '$value: essentials, emergency deposits, and goal needs divided by monthly income.',
    'A7' =>
      '$value: higher when Everyday Fund cash is low or income is irregular.',
    'A8' =>
      '$value: monthly emergency-fund catch-up need divided by monthly income.',
    'A9' =>
      '$value: monthly emergency-fund catch-up need based on your target gap.',
    'A22' =>
      '$value: Emergency Fund target divided by monthly essential expenses.',
    'A11' =>
      '$value: 25% of monthly surplus (${money(math.max(0.0, surplus))}) divided by minimum debt payment.',
    'A12' =>
      '$value: based on a sustainable share of monthly income and available surplus.',
    'A23' =>
      '$value: a meaningful next portfolio milestone above your current investment balance.',
    'A24' =>
      '$value: about 1% of your current portfolio balance as a monthly earnings target.',
    'A25' =>
      '$value: about 3% of your current portfolio balance as a monthly loss limit.',
    'A13' =>
      '$value: lower if cash is tight, higher when debt is heavier than investments.',
    'A14' =>
      '$value: based on monthly surplus strength after expenses and debt payments.',
    'A15' =>
      '$value: 15% of monthly surplus, or 3% of income when surplus is not available.',
    'A16' when field.key == 'amt' =>
      '$value: monthly goal funding need divided by ${_paydaysPerMonth(state)} payday(s).',
    'A16' => '$value: monthly goal funding need divided by monthly income.',
    'A17' => '$value: 20% when surplus exists, 10% when cash flow is tighter.',
    'A18' =>
      '$value: 30% when debt is above 3 months of income, otherwise 20%.',
    'A19' =>
      '$value: monthly expenses multiplied by the recommended Everyday Fund buffer.',
    'A20' =>
      '$value: max(current income, expenses + max(10% expense cushion, Everyday Fund gap divided by 6)).',
    _ =>
      '$value: calculated from the onboarding baseline that matches this action.',
  };
}

List<String> _recommendationsForField(ActionField field) {
  if (field.key == 'freq') return const ['Weekly', 'Every 2 weeks', 'Monthly'];
  final match = RegExp(r'\d+').firstMatch(field.hint);
  final example = int.tryParse(match?.group(0) ?? '') ?? 1;
  if (field.isPercent) {
    return [example, (example + 5).clamp(1, 100), (example + 10).clamp(1, 100)]
        .map((value) => value.toString())
        .toSet()
        .toList();
  }
  if (field.key == 'days') {
    return [example, (example + 2).clamp(1, 30), (example + 4).clamp(1, 30)]
        .map((value) => value.toString())
        .toSet()
        .toList();
  }
  return [example, example * 2, example * 3]
      .map((value) => value.toString())
      .toList();
}

String? _actionFieldError(ActionField field, String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'Choose or enter a value.';
  if (field.key == 'freq') {
    if (RegExp(r'^(weekly|monthly)$', caseSensitive: false).hasMatch(trimmed)) {
      return null;
    }
    final match = RegExp(r'^every\s+(\d+)\s+(days?|weeks?|months?)$',
            caseSensitive: false)
        .firstMatch(trimmed);
    if (match == null) {
      return 'Use Weekly, Monthly, or “Every N days/weeks/months.”';
    }
    final count = int.parse(match.group(1)!);
    final unit = match.group(2)!.toLowerCase();
    final maximum = unit.startsWith('day') ? 30 : 12;
    return count >= 1 && count <= maximum
        ? null
        : 'Use 1–30 days, 1–12 weeks, or 1–12 months.';
  }
  final number = double.tryParse(trimmed.replaceAll(',', ''));
  if (number == null) return 'Enter a number.';
  if (field.isPercent && (number < 1 || number > 100)) {
    return 'Use a percentage from 1 to 100.';
  }
  if (field.key == 'days' &&
      (number < 1 || number > 30 || number != number.roundToDouble())) {
    return 'Use a whole number from 1 to 30 days.';
  }
  if (field.key == 'months' &&
      (number < 1 || number > 12 || number != number.roundToDouble())) {
    return 'Use a whole number from 1 to 12 months.';
  }
  if (!field.isPercent &&
      field.key != 'days' &&
      field.key != 'months' &&
      (number < 100 || number > 1000000)) {
    return 'Use an amount from ₱100 to ₱1,000,000.';
  }
  return null;
}

String _fieldValueLabel(ActionField field, String value) {
  if (field.isPercent) return '$value%';
  if (field.key == 'days') return '$value days';
  if (field.key == 'months') return '$value months';
  if (field.key == 'freq') return value;
  return '₱$value';
}

// D2 action (from D2.csv)
class D2Action {
  const D2Action(
      {required this.id, required this.text, this.fields = const []});
  final String id;
  final String text;
  final List<ActionField> fields;
  bool get hasFields => fields.isNotEmpty;
}

const _goalBranches = [
  GoalBranch(
    layer: 'Cash Flow & Basic Needs',
    layerDescription:
        'Feel confident that there is enough money available to cover day-to-day expenses and essential needs.',
    firstQuestion: 'What is your biggest struggle with day-to-day spending?',
    icon: Icons.account_balance_wallet_rounded,
    defaultGoalTitle: 'Cash Flow Stability Plan',
    defaultGoalDescription:
        'Map income, fixed costs, and spending patterns so your monthly budget has a clear baseline.',
    concerns: [
      GoalConcern(
        feltNeed: 'I just forget to track my expenses.',
        followUp:
            'How often would tracking feel realistic for you: daily, weekly, or every payday?',
        goalTitle: 'Expense Tracking Routine',
        goalDescription:
            'Set up a simple expense tracking routine with reminders matched to your check-in rhythm.',
        keywords: ['forget', 'track', 'expense', 'logging', 'reminder'],
        actionIds: ['ACT3'],
        backgroundEffect:
            'Activates ACT3 tracking and sets up reminders based on the user check-in rhythm.',
      ),
      GoalConcern(
        feltNeed:
            'I notice extra purchases around weekends, payday, or certain stores.',
        followUp:
            'What usually comes right before the extra purchase: payday, weekends, social plans, ads, a specific store, or a quick reward?',
        goalTitle: 'Spending Trigger Tracker',
        goalDescription:
            'Tag expense context like day, category, merchant, and payday timing so Shelby can spot repeat spending triggers.',
        keywords: ['impulse', 'payday', 'weekend', 'store', 'trigger'],
        actionIds: ['ACT3', 'ACT5'],
        backgroundEffect:
            'Activates ACT3 tracking and ACT5 rule-based insights for repeat spending triggers.',
        enableEmotionalLogs: true,
      ),
      GoalConcern(
        feltNeed: 'My income changes every month, making it hard to plan.',
        followUp:
            'In a low-income month, what amount can you usually rely on, and which bills must be protected first?',
        goalTitle: 'Irregular Income Buffer',
        goalDescription:
            'Create a hill-and-valley budget that plans from lower-income months instead of a fixed average.',
        keywords: ['income', 'changes', 'irregular', 'variable', 'freelance'],
        actionIds: ['ACT6'],
        backgroundEffect:
            'Activates ACT6 plan adjustments and switches the budget formula for irregular income.',
      ),
    ],
  ),
  GoalBranch(
    layer: 'Financial Safety',
    layerDescription:
        'Avoid financial emergencies from disrupting daily life and long-term plans.',
    firstQuestion: 'What stops you from keeping an emergency fund?',
    icon: Icons.shield_rounded,
    defaultGoalTitle: 'Emergency Cushion',
    defaultGoalDescription:
        'Build a practical safety buffer sized around your real bills and essential living costs.',
    concerns: [
      GoalConcern(
        feltNeed: 'I always end up spending my savings on regular things.',
        followUp:
            'When you dip into savings, is it usually for bills, groceries, social plans, emergencies, or impulse purchases?',
        goalTitle: 'Safety Shield Boundary',
        goalDescription:
            'Ring-fence emergency savings and add alerts when regular spending starts pulling from it.',
        keywords: ['spending', 'savings', 'regular', 'dip', 'withdraw'],
        actionIds: ['ACT2'],
        backgroundEffect:
            'Activates ACT2 goal boundaries and warning prompts for emergency fund withdrawals.',
      ),
      GoalConcern(
        feltNeed: 'Unexpected bills or due dates keep disrupting my plan.',
        followUp:
            'Which bills disrupt your plan most, and are they hard because of timing, amount, or surprise charges?',
        goalTitle: 'Bill Due-Date Buffer',
        goalDescription:
            'Build a due-date buffer that reserves money before scheduled bills and flags shortfalls early.',
        keywords: ['bill', 'due', 'timing', 'surprise', 'unexpected'],
        actionIds: ['ACT5'],
        backgroundEffect:
            'Activates ACT5 insights and the upcoming bill-buffer status tracker.',
        enableStressIndicators: true,
      ),
      GoalConcern(
        feltNeed: 'I want to save, but I struggle to do it consistently.',
        followUp:
            'Would an automatic savings rule work better as a percentage of payday income or a fixed peso amount?',
        goalTitle: 'Payday Safety Sweep',
        goalDescription:
            'Set up a payday savings rule that builds the emergency cushion before the money blends into spending.',
        keywords: ['save', 'consistent', 'struggle', 'automatic', 'payday'],
        actionIds: ['ACT2'],
        backgroundEffect:
            'Activates ACT2 goal targets and suggests an automatic savings percentage every payday.',
      ),
    ],
  ),
  GoalBranch(
    layer: 'Accumulating Wealth',
    layerDescription:
        'Build wealth steadily and make progress toward long-term financial growth.',
    firstQuestion: 'Where should the app focus to help grow your wealth?',
    icon: Icons.trending_up_rounded,
    defaultGoalTitle: 'Net Worth Growth Plan',
    defaultGoalDescription:
        'Balance debt reduction, regular saving, and starter investing into one trackable plan.',
    concerns: [
      GoalConcern(
        feltNeed: 'I need a clear plan to aggressively pay off my debts.',
        followUp:
            'Which debt should Shelby look at first, and do you care more about lowering interest, monthly pressure, or total payoff time?',
        goalTitle: 'Debt Payoff Map',
        goalDescription:
            'Map a debt snowball or avalanche path so balances start moving in a visible direction.',
        keywords: ['debt', 'pay', 'payoff', 'aggressive', 'loan'],
        actionIds: ['ACT2'],
        backgroundEffect:
            'Activates ACT2 goal targets and the debt repayment target calculator.',
      ),
      GoalConcern(
        feltNeed: 'I want to start investing, but I have not completed setup.',
        followUp:
            'Which starter step should come first: learning the basics, choosing a monthly amount, opening an account, or making the first contribution?',
        goalTitle: 'Starter Investing Habit',
        goalDescription:
            'Complete a starter investing checklist and track a small recurring contribution habit.',
        keywords: ['invest', 'setup', 'monthly', 'first', 'contribution'],
        actionIds: ['ACT5'],
        backgroundEffect:
            'Activates ACT5 insights and the starter investing checklist path.',
      ),
      GoalConcern(
        feltNeed: 'I tend to spend more money whenever I get a raise.',
        followUp:
            'When your income rises, what grows first: rent, subscriptions, shopping, eating out, travel, or family support?',
        goalTitle: 'Lifestyle Creep Monitor',
        goalDescription:
            'Monitor fixed expenses and spending creep when income changes so wealth gains do not disappear.',
        keywords: ['raise', 'spend more', 'income', 'lifestyle', 'creep'],
        actionIds: ['ACT6'],
        backgroundEffect:
            'Activates ACT6 adjustments and monitors fixed expenses to prevent lifestyle inflation.',
      ),
    ],
  ),
  GoalBranch(
    layer: 'Financial Freedom',
    layerDescription:
        'Have freedom to afford desired lifestyles, experiences, and future aspirations.',
    firstQuestion: 'How do you want to save for your big life milestones?',
    icon: Icons.flag_rounded,
    defaultGoalTitle: 'Future Lifestyle Fund',
    defaultGoalDescription:
        'Create milestone buckets for meaningful plans while protecting essential money and safety buffers.',
    concerns: [
      GoalConcern(
        feltNeed:
            'I am trying to save for multiple big things at the same time.',
        followUp:
            'Which milestone should come first: home, wedding, school, family support, travel, business, or something else?',
        goalTitle: 'Milestone Bucket Plan',
        goalDescription:
            'Separate big goals into trackable buckets with target amounts, dates, and monthly contributions.',
        keywords: ['multiple', 'big', 'home', 'wedding', 'school'],
        actionIds: ['ACT2'],
        backgroundEffect:
            'Activates ACT2 goal targets and creates independent savings buckets with separate target dates.',
      ),
      GoalConcern(
        feltNeed: 'I am saving for these milestones together with a partner.',
        followUp:
            'What do you need to align on first: target amount, timeline, contribution split, privacy, or spending priorities?',
        goalTitle: 'Shared Future Alignment',
        goalDescription:
            'Prepare a collaborative goal with clear visibility, permissions, and shared progress tracking.',
        keywords: ['partner', 'together', 'shared', 'align', 'collaborate'],
        actionIds: ['ACT4'],
        backgroundEffect:
            'Activates ACT4 collaboration and opens account sharing options with privacy controls.',
      ),
      GoalConcern(
        feltNeed: 'I spend on travel or hobbies without a clear funded bucket.',
        followUp:
            'What kind of experience should have its own bucket, and how often would you want to fund it?',
        goalTitle: 'Planned Experience Fund',
        goalDescription:
            'Set aside a clear experience fund so hobby and travel spending is planned, visible, and separate from essentials.',
        keywords: ['travel', 'hobby', 'bucket', 'plan', 'spend'],
        actionIds: ['ACT5'],
        backgroundEffect:
            'Activates ACT5 insights and calculates how much planned experience money is available.',
      ),
    ],
  ),
];

// D1: goals G1-G8
const _d1Goals = <D1Goal>[
  D1Goal(
      id: 'G1',
      title: 'Maintain Available Cash',
      description:
          'Have and maintain enough available cash to cover expenses without financial stress.'),
  D1Goal(
      id: 'G2',
      title: 'Stable Cash Flow',
      description:
          'Maintain a stable cash flow even during months with irregular or changing income.'),
  D1Goal(
      id: 'G3',
      title: 'Build Emergency Fund',
      description:
          'Build an emergency fund that can cover unexpected expenses.'),
  D1Goal(
      id: 'G4',
      title: 'Pay Bills on Time',
      description:
          'Keep all bills, payments, and financial obligations paid on time to avoid penalties and disruptions.'),
  D1Goal(
      id: 'G5',
      title: 'Grow Investments',
      description:
          'Have a growing investment portfolio that steadily builds wealth over time.'),
  D1Goal(
      id: 'G6',
      title: 'Reduce Debt',
      description: 'Have total debt that steadily decreases over time.'),
  D1Goal(
      id: 'G7',
      title: 'Milestone Savings',
      description:
          'Have dedicated savings for specific milestones and experiences, each with a clear target amount and timeline.'),
  D1Goal(
      id: 'G8',
      title: 'Lifestyle Fund',
      description:
          'Consistently have money set aside for personal lifestyle activities, hobbies, and everyday enjoyment.'),
];

// D1: motivation → goal IDs matrix
const _motivationGoalIds = <String, List<String>>{
  'Cash Flow & Basic Needs': ['G1', 'G2', 'G4'],
  'Financial Safety': ['G1', 'G3', 'G4'],
  'Accumulating Wealth': ['G1', 'G5', 'G6'],
  'Financial Freedom': ['G1', 'G7', 'G8'],
};

D1Goal _d1GoalById(String id) =>
    _d1Goals.firstWhere((g) => g.id == id, orElse: () => _d1Goals.first);

// D2: actions A1-A18
const _d2Actions = <String, D2Action>{
  'A1': D2Action(
      id: 'A1',
      text:
          'Set aside X% of each income received into an Essential Expenses Fund.',
      fields: [
        ActionField(
            key: 'pct',
            label: 'Percentage of income',
            hint: 'e.g. 50',
            isPercent: true)
      ]),
  'A2': D2Action(
      id: 'A2',
      text: 'Spend no more than ₱X on discretionary purchases each month.',
      fields: [
        ActionField(key: 'amt', label: 'Monthly limit (₱)', hint: 'e.g. 5000')
      ]),
  'A3': D2Action(
      id: 'A3',
      text:
          'Limit spending in selected categories to a maximum of ₱X per month.',
      fields: [
        ActionField(
            key: 'amt',
            label: 'Monthly limit per category (₱)',
            hint: 'e.g. 3000')
      ]),
  'A4': D2Action(
      id: 'A4',
      text:
          'Set aside ₱X from each income received for upcoming bill and payment obligations.',
      fields: [
        ActionField(
            key: 'amt', label: 'Amount per income (₱)', hint: 'e.g. 2000')
      ]),
  'A5': D2Action(
      id: 'A5',
      text:
          'Pay each scheduled bill or financial obligation at least X days before its due date.',
      fields: [
        ActionField(key: 'days', label: 'Days before due date', hint: 'e.g. 3')
      ]),
  'A6': D2Action(
      id: 'A6',
      text:
          'Distribute X% of incoming income across separate spending and savings accounts immediately upon receipt.',
      fields: [
        ActionField(
            key: 'pct',
            label: 'Percentage of income',
            hint: 'e.g. 50',
            isPercent: true)
      ]),
  'A7': D2Action(
      id: 'A7',
      text:
          'Allocate X% of unexpected income (bonuses, gifts, side income) toward essential expense reserves.',
      fields: [
        ActionField(
            key: 'pct', label: 'Percentage', hint: 'e.g. 20', isPercent: true)
      ]),
  'A8': D2Action(
      id: 'A8',
      text: 'Set aside X% of each income for the Emergency Fund.',
      fields: [
        ActionField(
            key: 'pct', label: 'Percentage', hint: 'e.g. 10', isPercent: true)
      ]),
  'A9': D2Action(
      id: 'A9',
      text: 'Deposit at least ₱X into the Emergency Fund each month.',
      fields: [
        ActionField(
            key: 'amt', label: 'Minimum deposit (₱)', hint: 'e.g. 1000'),
      ]),
  'A10': D2Action(
      id: 'A10',
      text:
          'Replenish withdrawn Emergency Fund amounts within X days after receiving income.',
      fields: [
        ActionField(key: 'days', label: 'Days to replenish', hint: 'e.g. 7')
      ]),
  'A11': D2Action(
      id: 'A11',
      text:
          'Pay an additional X% above the minimum required debt payment each payment cycle.',
      fields: [
        ActionField(
            key: 'pct',
            label: 'Extra payment percentage',
            hint: 'e.g. 10',
            isPercent: true)
      ]),
  'A12': D2Action(
      id: 'A12',
      text: 'Allocate X% of each income to the Investment Portfolio.',
      fields: [
        ActionField(
            key: 'pct', label: 'Percentage', hint: 'e.g. 10', isPercent: true)
      ]),
  'A13': D2Action(
      id: 'A13',
      text:
          'Apply X% of unexpected income (bonuses, tax refunds, windfalls) toward outstanding debt or investment accounts.',
      fields: [
        ActionField(
            key: 'pct', label: 'Percentage', hint: 'e.g. 30', isPercent: true)
      ]),
  'A14': D2Action(
      id: 'A14',
      text:
          'Transfer X% of unspent monthly funds toward debt repayment or investments at the end of each month.',
      fields: [
        ActionField(
            key: 'pct', label: 'Percentage', hint: 'e.g. 50', isPercent: true)
      ]),
  'A15': D2Action(
      id: 'A15',
      text:
          'Increase investment contributions by ₱X upon receiving an income raise or additional income source.',
      fields: [
        ActionField(
            key: 'amt', label: 'Contribution increase (₱)', hint: 'e.g. 500')
      ]),
  'A23': D2Action(
      id: 'A23',
      text: 'Build the Investment Portfolio to ₱X.',
      fields: [
        ActionField(
            key: 'amt', label: 'Portfolio value target (₱)', hint: 'e.g. 50000')
      ]),
  'A24': D2Action(
      id: 'A24',
      text: 'Earn at least ₱X from investments this month.',
      fields: [
        ActionField(
            key: 'amt', label: 'Monthly earnings target (₱)', hint: 'e.g. 1000')
      ]),
  'A25': D2Action(
      id: 'A25',
      text: 'Keep investment losses below ₱X this month.',
      fields: [
        ActionField(
            key: 'amt', label: 'Monthly loss limit (₱)', hint: 'e.g. 1000')
      ]),
  'A16': D2Action(
      id: 'A16',
      text:
          'Contribute ₱X or X% of income to each goal-based savings fund every payday.',
      fields: [
        ActionField(key: 'amt', label: 'Fixed amount (₱)', hint: 'e.g. 2000'),
        ActionField(
            key: 'pct',
            label: 'Or percentage (%)',
            hint: 'e.g. 10',
            isPercent: true)
      ]),
  'A17': D2Action(
      id: 'A17',
      text:
          'Redirect X% of savings contributions toward the personal lifestyle fund from a lower-priority savings goal.',
      fields: [
        ActionField(
            key: 'pct',
            label: 'Percentage to redirect',
            hint: 'e.g. 20',
            isPercent: true)
      ]),
  'A18': D2Action(
      id: 'A18',
      text:
          'Temporarily redirect X% of goal savings contributions toward accelerated debt repayment.',
      fields: [
        ActionField(
            key: 'pct',
            label: 'Percentage to redirect',
            hint: 'e.g. 25',
            isPercent: true)
      ]),
  'A19': D2Action(
      id: 'A19',
      text:
          'Keep at least ₱X available in your Everyday Fund so essentials stay covered even before the next income arrives.',
      fields: [
        ActionField(
            key: 'amt', label: 'Everyday Fund minimum (₱)', hint: 'e.g. 30000')
      ]),
  'A20': D2Action(
      id: 'A20',
      text:
          'Bring in at least ₱X this month from income, side gigs, or other cash-in so your available cash target stays on pace.',
      fields: [
        ActionField(
            key: 'amt', label: 'Monthly cash-in target (₱)', hint: 'e.g. 25000')
      ]),
  'A21': D2Action(
      id: 'A21',
      text:
          "Keep at least X days' worth of expenses available in your Everyday Fund at all times.",
      fields: [
        ActionField(key: 'days', label: 'Days of expenses', hint: 'e.g. 14')
      ]),
  'A22': D2Action(
      id: 'A22',
      text:
          'Build your Emergency Fund to cover X months of essential expenses.',
      fields: [
        ActionField(key: 'months', label: 'Months of expenses', hint: 'e.g. 3')
      ]),
};

const _availableCashGoalActionIds = ['A1', 'A3', 'A20', 'A19'];
const _emergencyFundGoalActionIds = ['A9', 'A8', 'A22', 'A10'];
const _investmentGoalActionIds = ['A12', 'A23', 'A24', 'A25'];

// D2: goal → action IDs matrix
const _goalActionIds = <String, List<String>>{
  'G1': _availableCashGoalActionIds,
  'G2': ['A1', 'A3', 'A5', 'A6', 'A7'],
  'G3': _emergencyFundGoalActionIds,
  'G4': ['A1', 'A2', 'A4', 'A5', 'A10'],
  'G5': _investmentGoalActionIds,
  'G6': ['A11', 'A13', 'A14', 'A18'],
  'G7': ['A12', 'A15', 'A16', 'A17', 'A18'],
  'G8': ['A2', 'A3', 'A16', 'A17'],
};

class PlanDataPoint {
  const PlanDataPoint(this.id, this.kind, this.label);
  final String id;
  final String kind;
  final String label;
}

const _planDataPoints = <String, PlanDataPoint>{
  'D1': PlanDataPoint('D1', 'Time', 'Financial activity date'),
  'D2': PlanDataPoint('D2', 'Time', 'Scheduled bill due date'),
  'D3': PlanDataPoint('D3', 'Time', 'Goal target completion date'),
  'D4': PlanDataPoint('D4', 'Source', 'Income transaction amount'),
  'D5': PlanDataPoint('D5', 'Source', 'Expense transaction amount'),
  'D6': PlanDataPoint('D6', 'Source', 'Expense category'),
  'D7': PlanDataPoint('D7', 'Source', 'Transfer amount'),
  'D8': PlanDataPoint('D8', 'Source', 'Source bucket'),
  'D9': PlanDataPoint('D9', 'Source', 'Destination bucket'),
  'D10': PlanDataPoint('D10', 'Source', 'Current available cash balance'),
  'D11': PlanDataPoint('D11', 'Source', 'Emergency fund balance'),
  'D12': PlanDataPoint('D12', 'Source', 'Goal fund balance'),
  'D13': PlanDataPoint('D13', 'Source', 'Debt payment amount'),
  'D14': PlanDataPoint('D14', 'Source', 'Investment contribution amount'),
  'D15': PlanDataPoint('D15', 'Source', 'Outstanding debt balance'),
  'D16': PlanDataPoint('D16', 'Source', 'Investment account balance'),
  'D17': PlanDataPoint('D17', 'Source', 'Unexpected income amount'),
  'D18': PlanDataPoint('D18', 'Indicator', 'Savings-to-spending ratio'),
  'D19': PlanDataPoint('D19', 'Indicator', 'Emergency fund coverage in months'),
  'D20': PlanDataPoint('D20', 'Indicator', 'Net worth value'),
  'D21': PlanDataPoint('D21', 'Indicator', 'Goal progress percentage'),
  'D22': PlanDataPoint('D22', 'Indicator', 'Contribution compliance rate'),
  'D23': PlanDataPoint('D23', 'Indicator', 'Budget adherence rate'),
  'D24': PlanDataPoint('D24', 'Indicator', 'Monthly cash flow balance'),
  'D25': PlanDataPoint('D25', 'Source', 'Investment earnings amount'),
  'D26': PlanDataPoint('D26', 'Source', 'Investment loss amount'),
};

const _actionDataMatrix = <String, List<String>>{
  'A1': ['D1', 'D4', 'D7', 'D8', 'D9', 'D10', 'D18', 'D24'],
  'A2': ['D1', 'D4', 'D5', 'D6', 'D10', 'D23', 'D24'],
  'A3': ['D1', 'D4', 'D5', 'D6', 'D10', 'D23', 'D24'],
  'A4': ['D1', 'D2', 'D4', 'D7', 'D8', 'D9', 'D10', 'D23', 'D24'],
  'A5': ['D1', 'D2', 'D4', 'D5', 'D6', 'D10', 'D23'],
  'A6': ['D1', 'D4', 'D7', 'D8', 'D9', 'D10', 'D11', 'D12', 'D18', 'D24'],
  'A7': ['D1', 'D4', 'D7', 'D8', 'D9', 'D10', 'D17', 'D19', 'D24'],
  'A8': ['D1', 'D4', 'D7', 'D8', 'D9', 'D10', 'D11', 'D19', 'D22'],
  'A9': ['D1', 'D4', 'D7', 'D8', 'D9', 'D10', 'D11', 'D19', 'D22'],
  'A10': ['D1', 'D4', 'D7', 'D8', 'D9', 'D10', 'D11', 'D19'],
  'A11': ['D1', 'D4', 'D7', 'D8', 'D9', 'D10', 'D13', 'D15', 'D22'],
  'A12': ['D1', 'D4', 'D7', 'D8', 'D9', 'D10', 'D14', 'D16', 'D20', 'D22'],
  'A13': [
    'D1',
    'D4',
    'D7',
    'D8',
    'D9',
    'D10',
    'D13',
    'D14',
    'D15',
    'D16',
    'D17',
    'D20',
    'D24'
  ],
  'A14': [
    'D1',
    'D4',
    'D5',
    'D7',
    'D8',
    'D9',
    'D10',
    'D13',
    'D14',
    'D15',
    'D16',
    'D20',
    'D24'
  ],
  'A15': ['D1', 'D4', 'D7', 'D8', 'D9', 'D10', 'D14', 'D16', 'D20', 'D22'],
  'A23': ['D1', 'D7', 'D8', 'D9', 'D10', 'D14', 'D16', 'D20'],
  'A24': ['D1', 'D16', 'D20', 'D25'],
  'A25': ['D1', 'D16', 'D20', 'D26'],
  'A16': [
    'D1',
    'D3',
    'D4',
    'D7',
    'D8',
    'D9',
    'D10',
    'D12',
    'D21',
    'D23',
    'D24'
  ],
  'A17': ['D1', 'D3', 'D4', 'D7', 'D8', 'D9', 'D10', 'D12', 'D21'],
  'A18': [
    'D1',
    'D3',
    'D4',
    'D7',
    'D8',
    'D9',
    'D10',
    'D12',
    'D13',
    'D15',
    'D21',
    'D22'
  ],
  'A19': ['D1', 'D5', 'D10', 'D18', 'D24'],
  'A20': ['D1', 'D4', 'D10', 'D24'],
  'A22': ['D1', 'D5', 'D10', 'D11', 'D19'],
};

class BaselineField {
  const BaselineField(this.key, this.label, this.help, {this.format = 'money'});
  final String key;
  final String label;
  final String help;
  final String format;
}

const _baselineFields = <String, BaselineField>{
  'cash_balance': BaselineField(
      'cash_balance',
      'Initial available cash balance',
      'Cash currently available across your wallet and spending accounts.'),
  'monthly_expenses': BaselineField(
      'monthly_expenses',
      'Average monthly expenses',
      'Your best current estimate; Shellby will refine it from later transactions.'),
  'essential_expenses': BaselineField(
      'essential_expenses',
      'Average monthly essential expenses',
      'Housing, food, utilities, transport, and other necessary costs.'),
  'essential_balance': BaselineField(
      'essential_balance',
      'Essential Expenses Fund starting balance',
      'What is already reserved for essentials.'),
  'savings_balance': BaselineField(
      'savings_balance',
      'General savings starting balance',
      'Savings outside your emergency and goal funds.'),
  'discretionary_spend': BaselineField(
      'discretionary_spend',
      'Average monthly discretionary spending',
      'Your usual monthly spending on wants and non-essential purchases.'),
  'income_baseline': BaselineField(
      'income_baseline',
      'Typical income per payday',
      'The normal amount that defines a regular payday versus unexpected income.'),
  'categories': BaselineField('categories', 'Capped categories',
      'Enter categories separated by commas, such as Dining, Shopping, Transport.',
      format: 'categories'),
  'category_averages': BaselineField(
      'category_averages',
      'Average monthly spend per category',
      'One per line using Category: amount, for example Dining: 3000.',
      format: 'category_amounts'),
  'bills': BaselineField('bills', 'Bills and obligations',
      'One per line using Bill | amount | YYYY-MM-DD.',
      format: 'bills'),
  'emergency_balance': BaselineField(
      'emergency_balance',
      'Emergency Fund starting balance',
      'The amount currently available for emergencies.'),
  'emergency_target': BaselineField('emergency_target', 'Emergency Fund target',
      'The full amount you want the fund to reach or return to.'),
  'debt_balance': BaselineField(
      'debt_balance',
      'Total outstanding debt balance',
      'The current unpaid balance across debts used by the selected actions.'),
  'minimum_debt_payment': BaselineField('minimum_debt_payment',
      'Minimum debt payment', 'The required payment each cycle.'),
  'debt_cycle': BaselineField('debt_cycle', 'Debt payment cycle',
      'Enter Weekly, Every 2 weeks, or Monthly.',
      format: 'cycle'),
  'investment_balance': BaselineField(
      'investment_balance',
      'Investment starting balance',
      'The current value of the investment accounts in this plan.'),
  'goals': BaselineField('goals', 'Goal fund inventory',
      'One per line: Goal | starting balance | target | YYYY-MM-DD | priority number.',
      format: 'goals'),
};

// Retained as documentation of the action-to-standing-variable model.
// ignore: unused_element
const _actionBaselineMatrix = <String, List<String>>{
  'A1': ['cash_balance', 'monthly_expenses', 'essential_balance'],
  'A2': ['discretionary_spend', 'cash_balance'],
  'A3': ['categories', 'category_averages'],
  'A4': ['bills', 'cash_balance'],
  'A5': ['bills'],
  'A6': [
    'cash_balance',
    'essential_balance',
    'savings_balance',
    'income_baseline'
  ],
  'A7': ['income_baseline', 'essential_expenses'],
  'A8': ['emergency_balance', 'emergency_target', 'essential_expenses'],
  'A9': ['emergency_balance', 'emergency_target'],
  'A10': ['emergency_balance'],
  'A22': ['emergency_balance', 'emergency_target', 'essential_expenses'],
  'A11': ['debt_balance', 'minimum_debt_payment', 'debt_cycle'],
  'A12': ['investment_balance', 'income_baseline'],
  'A13': ['debt_balance', 'investment_balance', 'income_baseline'],
  'A14': [
    'monthly_expenses',
    'cash_balance',
    'debt_balance',
    'investment_balance'
  ],
  'A15': ['income_baseline', 'investment_balance'],
  'A23': ['investment_balance'],
  'A24': ['investment_balance'],
  'A25': ['investment_balance'],
  'A16': ['goals', 'income_baseline'],
  'A17': ['goals'],
  'A18': ['goals', 'debt_balance'],
};

// Each pathway has 3 steps: Surface (0), Situations/Reminders (1), Challenges (2).
// Goal Focus and Action Selection are handled dynamically using D1/D2 data.
const _guidedPathways = [
  GuidedPathway(
    layer: 'Cash Flow & Basic Needs',
    steps: [
      GuidedStep(
        title: 'Surface',
        question:
            'Surface: Before we turn this into a goal, what feels most true lately?',
        options: [
          GuidedOption(
            label: 'A',
            text:
                'I keep meaning to check my spending, but the habit slips when life gets busy.',
            keywords: ['busy', 'habit', 'spending', 'slips'],
          ),
          GuidedOption(
            label: 'B',
            text:
                'I notice extra purchases around weekends, payday, or certain stores.',
            keywords: ['weekend', 'payday', 'store', 'spend'],
          ),
          GuidedOption(
            label: 'C',
            text:
                'I feel thrown off when bills, income, or timing do not line up.',
            keywords: ['bills', 'income', 'timing', 'thrown off'],
          ),
        ],
      ),
      GuidedStep(
        title: 'Situations',
        question: 'When should the app remind you to stay on track?',
        multiSelect: true,
        options: [
          GuidedOption(
            label: 'Payday',
            text: 'Payday',
            detail: 'Nudge me the moment an income transaction is added.',
            keywords: ['payday', 'income'],
          ),
          GuidedOption(
            label: 'Weekends',
            text: 'Weekends',
            detail: 'Remind me every Saturday morning.',
            keywords: ['weekend', 'saturday'],
          ),
          GuidedOption(
            label: 'Bill Days',
            text: 'Bill Days',
            detail: 'Remind me 2 days before a scheduled bill is due.',
            keywords: ['bill', 'due'],
          ),
        ],
      ),
      GuidedStep(
        title: 'Challenges',
        question: 'What real hurdles should the app watch out for?',
        multiSelect: true,
        options: [
          GuidedOption(
            label: 'Impulse Buying',
            text: 'Impulse Buying',
            detail: 'Tag category, store, day, and payday context.',
            keywords: ['impulse', 'category', 'store', 'payday', 'expense'],
          ),
          GuidedOption(
            label: 'Budget Leaks',
            text: 'Budget Leaks',
            detail: 'Warn me if I spend more than my daily average.',
            keywords: ['leak', 'daily', 'average'],
          ),
        ],
      ),
    ],
  ),
  GuidedPathway(
    layer: 'Financial Safety',
    steps: [
      GuidedStep(
        title: 'Surface',
        question:
            'Surface: What has been making financial safety feel difficult lately?',
        options: [
          GuidedOption(
            label: 'A',
            text:
                'I save a little, but regular expenses keep pulling that money back out.',
            keywords: ['save', 'regular', 'expenses', 'pulling'],
          ),
          GuidedOption(
            label: 'B',
            text: 'Surprise expenses or due dates disrupt my monthly plan.',
            keywords: ['surprise', 'expense', 'due', 'bill'],
          ),
          GuidedOption(
            label: 'C',
            text:
                'I want a cushion, but I need help making saving feel automatic.',
            keywords: ['cushion', 'automatic', 'saving'],
          ),
        ],
      ),
      GuidedStep(
        title: 'Situations',
        question: 'When is it easiest for you to lock money into savings?',
        multiSelect: true,
        options: [
          GuidedOption(
            label: 'Payday Deposits',
            text: 'Payday Deposits',
            detail: 'Right when my regular paycheck lands.',
            keywords: ['payday', 'paycheck'],
          ),
          GuidedOption(
            label: 'Extra Cash Drops',
            text: 'Extra Cash Drops',
            detail: 'Whenever I log a bonus or side-income.',
            keywords: ['bonus', 'extra', 'side'],
          ),
        ],
      ),
      GuidedStep(
        title: 'Challenges',
        question: 'What hurdles should the app monitor for your savings?',
        multiSelect: true,
        options: [
          GuidedOption(
            label: 'Savings Dipping',
            text: 'Savings Dipping',
            detail: 'Warn me if my emergency fund balance drops.',
            keywords: ['dip', 'withdraw', 'balance'],
          ),
          GuidedOption(
            label: 'Missed Contributions',
            text: 'Missed Contributions',
            detail:
                'Alert me if a paycheck arrives but zero money moves to savings.',
            keywords: ['missed', 'contribution', 'paycheck'],
          ),
        ],
      ),
    ],
  ),
  GuidedPathway(
    layer: 'Accumulating Wealth',
    steps: [
      GuidedStep(
        title: 'Surface',
        question:
            'Surface: What has been on your mind when you think about growing your money?',
        options: [
          GuidedOption(
            label: 'A',
            text: 'Debt payments keep taking up budget space every month.',
            keywords: ['debt', 'payment', 'budget', 'space'],
          ),
          GuidedOption(
            label: 'B',
            text:
                'I want to start investing, but I have not completed the setup steps.',
            keywords: ['invest', 'setup', 'steps', 'start'],
          ),
          GuidedOption(
            label: 'C',
            text:
                'When more money comes in, it seems to disappear into more spending.',
            keywords: ['money', 'disappear', 'spending', 'income'],
          ),
        ],
      ),
      GuidedStep(
        title: 'Situations',
        question: 'What update triggers would keep you motivated?',
        multiSelect: true,
        options: [
          GuidedOption(
            label: 'Net Worth Sync',
            text: 'Net Worth Sync',
            detail:
                'Show me a monthly recap of debt shrinking vs. investments growing.',
            keywords: ['net worth', 'monthly', 'recap'],
          ),
          GuidedOption(
            label: 'Income Milestones',
            text: 'Income Milestones',
            detail:
                'Prompt me to increase savings whenever my net income baseline changes.',
            keywords: ['income', 'milestone', 'raise'],
          ),
        ],
      ),
      GuidedStep(
        title: 'Challenges',
        question: 'What obstacles should the app flag on your wealth path?',
        multiSelect: true,
        options: [
          GuidedOption(
            label: 'Expense Creep',
            text: 'Expense Creep',
            detail: 'Flag if my fixed expenses increase after an income raise.',
            keywords: ['expense', 'creep', 'raise'],
          ),
          GuidedOption(
            label: 'Stagnant Cash',
            text: 'Stagnant Cash',
            detail: 'Warn me if cash sits in checking without being allocated.',
            keywords: ['cash', 'checking', 'allocated'],
          ),
        ],
      ),
    ],
  ),
  GuidedPathway(
    layer: 'Financial Freedom',
    steps: [
      GuidedStep(
        title: 'Surface',
        question:
            'Surface: What makes spending for life, hobbies, or milestones feel complicated right now?',
        options: [
          GuidedOption(
            label: 'A',
            text:
                'I have several things I care about, and it is hard to know what to fund first.',
            keywords: ['several', 'care', 'fund', 'first'],
          ),
          GuidedOption(
            label: 'B',
            text:
                'I want to save for something meaningful without messing up my bills.',
            keywords: ['meaningful', 'bills', 'save'],
          ),
          GuidedOption(
            label: 'C',
            text: 'I spend on hobbies or travel without a clear funded bucket.',
            keywords: ['hobby', 'travel', 'bucket', 'spend'],
          ),
        ],
      ),
      GuidedStep(
        title: 'Situations',
        question: 'What condition should mark this spending as ready?',
        multiSelect: true,
        options: [
          GuidedOption(
            label: 'Green Light Status',
            text: 'Green Light Status',
            detail:
                'When essential bills and emergency savings are fully funded for the month.',
            keywords: ['green', 'bill', 'emergency'],
          ),
          GuidedOption(
            label: 'Target Proximity',
            text: 'Target Proximity',
            detail:
                "When my milestone bucket reaches 90%, remind me it's safe to plan the spend.",
            keywords: ['target', '90', 'bucket'],
          ),
        ],
      ),
      GuidedStep(
        title: 'Challenges',
        question: 'What hurdles should the app guard against?',
        multiSelect: true,
        options: [
          GuidedOption(
            label: 'Goal Congestion',
            text: 'Goal Congestion',
            detail:
                'Warn me if I track more than 3 active milestone buckets at once.',
            keywords: ['congestion', '3', 'bucket'],
          ),
          GuidedOption(
            label: 'Premature Spending',
            text: 'Premature Spending',
            detail:
                "Warn me before withdrawing if the bucket hasn't reached 100% of its target.",
            keywords: ['premature', 'withdraw', '100'],
          ),
        ],
      ),
    ],
  ),
];

GoalBranch _branchForLayer(String layer) {
  return _goalBranches.firstWhere(
    (branch) => branch.layer == layer,
    orElse: () => _goalBranches.first,
  );
}

GuidedPathway _pathwayForLayer(String layer) {
  return _guidedPathways.firstWhere(
    (pathway) => pathway.layer == layer,
    orElse: () => _guidedPathways.first,
  );
}

double _monthlyTargetForConcern(AppState state, GoalConcern concern) {
  return switch (concern.goalTitle) {
    'Expense Tracking Routine' => 0,
    'Irregular Income Buffer' => math.max(500, state.expenses * .15),
    'Spending Trigger Tracker' => 0,
    'Buffer Duration Goal' => math.max(500, state.expenses / 6),
    'Bill Due-Date Buffer' => math.max(300, state.expenses * .1),
    'Safety Shield Boundary' => math.max(500, state.expenses / 6),
    'Payday Safety Sweep' => math.max(500, state.expenses / 6),
    'Debt Payoff Map' => math.max(400, state.debtPayments * .8),
    'Starter Investing Habit' => math.max(500, state.income * .08),
    'Lifestyle Creep Monitor' => 0,
    'Milestone Bucket Plan' => math.max(500, state.income * .1),
    'Planned Experience Fund' => math.max(300, state.income * .05),
    'Shared Future Alignment' => math.max(500, state.income * .08),
    _ => 0,
  };
}

void _pushFinancialConcernWithFullHistory(BuildContext context) {
  final navigator = Navigator.of(context);
  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    (_) => false,
  );
  for (final page in const [
    PreparationContextScreen(),
    PreparationCredentialsScreen(),
    LifeContextScreen(),
    LifeRhythmScreen(),
    MonthlyIncomeScreen(),
    InitialBaselineScreen(),
    PreparationOrientScreen(),
    FinancialConcernScreen(),
  ]) {
    navigator.push(MaterialPageRoute(builder: (_) => page));
  }
}

class PreparationContextScreen extends StatefulWidget {
  const PreparationContextScreen({super.key});

  @override
  State<PreparationContextScreen> createState() =>
      _PreparationContextScreenState();
}

class _PreparationContextScreenState extends State<PreparationContextScreen> {
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final canContinue = state.name.isNotEmpty;
    return OnboardingScaffold(
      phase: 1,
      title: 'Let Shelby know you.',
      subtitle: "Let's start with your name!",
      bottom: PrimaryButton(
        label: 'Continue',
        icon: Icons.arrow_forward_rounded,
        enabled: canContinue,
        onPressed: () => _push(context, const PreparationCredentialsScreen()),
      ),
      child: Column(
        children: [
          LabeledField(
            label: 'Name',
            icon: Icons.person_rounded,
            child: TextField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: inputDecoration('What should Shelby call you?'),
              onChanged: (value) => setState(() => state.name = value.trim()),
            ),
          ),
        ],
      ),
    );
  }
}

class PreparationCredentialsScreen extends StatefulWidget {
  const PreparationCredentialsScreen({super.key});

  @override
  State<PreparationCredentialsScreen> createState() =>
      _PreparationCredentialsScreenState();
}

class _PreparationCredentialsScreenState
    extends State<PreparationCredentialsScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _runAuth(Future<void> Function(AppState state) action) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final state = AppScope.of(context);
      await action(state);
      if (!mounted) return;
      _push(context, const LifeContextScreen());
    } catch (error) {
      if (!mounted) return;
      _showAuthError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      phase: 1,
      title: 'Create your account.',
      subtitle:
          'Use email and password or continue with Google so Shelby can save your profile.',
      bottom: const SizedBox.shrink(),
      child: Column(
        children: [
          LabeledField(
            label: 'Email',
            icon: Icons.mail_rounded,
            child: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: inputDecoration('you@example.com'),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Password',
            icon: Icons.lock_rounded,
            child: TextField(
              controller: passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: inputDecoration('At least 6 characters'),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Create account',
            icon: Icons.person_add_alt_1_rounded,
            enabled: !busy,
            onPressed: () => _runAuth(
              (state) => state.createAccountWithEmail(
                email: emailController.text,
                password: passwordController.text,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _LoginDivider(),
          const SizedBox(height: 18),
          GoogleSignInButton(
            busy: busy,
            onPressed: () => _runAuth(
              (state) => state.signInWithGoogle(
                saveAfterSignIn: false,
                forceFreshGoogleSession: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LifeContextScreen extends StatefulWidget {
  const LifeContextScreen({super.key});

  @override
  State<LifeContextScreen> createState() => _LifeContextScreenState();
}

class _LifeContextScreenState extends State<LifeContextScreen> {
  final occupationController = TextEditingController();

  @override
  void dispose() {
    occupationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final canContinue = state.age.isNotEmpty && state.occupation.isNotEmpty;
    return OnboardingScaffold(
      phase: 2,
      title: 'What are you doing now?',
      subtitle:
          'Your work and life stage shape what feels doable. Shelby uses this to keep suggestions grounded in your real world.',
      bottom: PrimaryButton(
        label: 'Map Money Rhythm',
        icon: Icons.arrow_forward_rounded,
        enabled: canContinue,
        onPressed: () => _push(context, const LifeRhythmScreen()),
      ),
      child: Column(
        children: [
          LabeledField(
            label: 'Age & life stage',
            icon: Icons.calendar_today_rounded,
            child: DropdownButtonFormField<String>(
              value: state.age.isEmpty ? null : state.age,
              decoration: inputDecoration('Select your stage'),
              items: const [
                DropdownMenuItem(
                  value: 'Fresh Graduate',
                  child: Text('Fresh Graduate (20-25)'),
                ),
                DropdownMenuItem(
                  value: 'Early Career',
                  child: Text('Early Career (26-35)'),
                ),
                DropdownMenuItem(
                  value: 'Mid-Career',
                  child: Text('Mid-Career (36-50)'),
                ),
              ],
              onChanged: (value) => setState(() => state.age = value ?? ''),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Occupation',
            icon: Icons.work_rounded,
            child: TextField(
              controller: occupationController,
              decoration: inputDecoration('e.g. Software Engineer'),
              onChanged: (value) => setState(() => state.occupation = value),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Industry',
            icon: Icons.business_center_rounded,
            child: DropdownButtonFormField<String>(
              value: state.industry,
              decoration: inputDecoration('Select your industry'),
              items: const [
                'Technology',
                'Finance',
                'Healthcare',
                'Education',
                'Business Services',
                'Retail & E-commerce',
                'Creative & Media',
                'Government',
                'Manufacturing',
                'Hospitality',
                'Freelance / Self-employed',
                'Other',
              ].map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (value) =>
                  setState(() => state.industry = value ?? state.industry),
            ),
          ),
        ],
      ),
    );
  }
}

class LifeRhythmScreen extends StatefulWidget {
  const LifeRhythmScreen({super.key});

  @override
  State<LifeRhythmScreen> createState() => _LifeRhythmScreenState();
}

class _LifeRhythmScreenState extends State<LifeRhythmScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 3,
      title: 'How does money move for you?',
      subtitle:
          'Paydays, bills, shared responsibilities, and check-in habits all shape what Shelby should pay attention to.',
      bottom: PrimaryButton(
        label: 'Add Monthly Income',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const MonthlyIncomeScreen()),
      ),
      child: Column(
        children: [
          LabeledField(
            label: 'Employment status',
            icon: Icons.badge_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['Full-time', 'Freelance', 'Contract', 'Mixed']
                  .map(
                    (value) => CompactChoice(
                      label: value,
                      selected: state.employmentStatus == value,
                      onTap: () => setState(
                        () => state.employmentStatus = value,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Income type',
            icon: Icons.payments_rounded,
            child: Row(
              children: [
                Expanded(
                  child: ChoiceTile(
                    label: 'Fixed',
                    selected: state.incomeType == 'Fixed',
                    onTap: () => setState(() => state.incomeType = 'Fixed'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceTile(
                    label: 'Variable',
                    selected: state.incomeType == 'Variable',
                    onTap: () => setState(() => state.incomeType = 'Variable'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Income rhythm',
            icon: Icons.event_repeat_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['Weekly', 'Twice a month', 'Monthly', 'Irregular']
                  .map(
                    (value) => CompactChoice(
                      label: value,
                      selected: state.incomeRhythm == value,
                      onTap: () => setState(() => state.incomeRhythm = value),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Bills rhythm',
            icon: Icons.receipt_long_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                'Predictable dates',
                'Scattered dates',
                'Mostly automatic',
                'Often surprise me',
              ]
                  .map(
                    (value) => CompactChoice(
                      label: value,
                      selected: state.billsRhythm == value,
                      onTap: () => setState(() => state.billsRhythm = value),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Financial responsibility',
            icon: Icons.family_restroom_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['Mostly myself', 'Family support', 'Shared household']
                  .map(
                    (value) => CompactChoice(
                      label: value,
                      selected: state.responsibility == value,
                      onTap: () => setState(() => state.responsibility = value),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Money check-in rhythm',
            icon: Icons.fact_check_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['Daily', 'Weekly', 'Monthly', 'Only when needed']
                  .map(
                    (value) => CompactChoice(
                      label: value,
                      selected: state.checkInRhythm == value,
                      onTap: () => setState(() => state.checkInRhythm = value),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialConcernScreen extends StatefulWidget {
  const FinancialConcernScreen({super.key});

  @override
  State<FinancialConcernScreen> createState() => _FinancialConcernScreenState();
}

class _FinancialConcernScreenState extends State<FinancialConcernScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 6,
      title: 'What invited you here today?',
      subtitle:
          'Choose the layer that best matches what you want Shelby to help with first.',
      onBack: () {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }
        _pushFinancialConcernWithFullHistory(context);
      },
      bottom: PrimaryButton(
        label: 'Tell Shelby Why',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const MotivationSurfaceScreen()),
      ),
      child: Column(
        children: [
          ..._goalBranches.map(
            (branch) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SelectableOption(
                icon: branch.icon,
                title: branch.layer,
                body: branch.layerDescription,
                selected: state.primaryConcern == branch.layer,
                onTap: () => setState(() {
                  state.primaryConcern = branch.layer;
                  state.choosePresetGoal(
                    branch.defaultGoalTitle,
                    branch.defaultGoalDescription,
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Don't worry — you can add more later once your account is set up!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _body,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class MotivationSurfaceScreen extends StatefulWidget {
  const MotivationSurfaceScreen({super.key});

  @override
  State<MotivationSurfaceScreen> createState() =>
      _MotivationSurfaceScreenState();
}

// Steps: 0=Surface, 1=Goal Focus (D1), 2=Action Select (D2), 3=Configurables, 4=Situations, 5=Challenges
class _MotivationSurfaceScreenState extends State<MotivationSurfaceScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  final List<ChatMessage> messages = [];
  bool seeded = false;
  bool flowComplete = false;
  String error = '';
  late GuidedPathway pathway;
  int stepIndex = 0;
  final Map<int, List<GuidedOption>> answers = {};
  String? _selectedGoalId;
  Map<String, Map<String, String>> _actionConfigValues = {};
  List<GuidedOption>? _cachedGoalOptions;
  List<GuidedOption>? _cachedActionOptions;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (seeded) return;
    pathway = _pathwayForLayer(AppScope.of(context).primaryConcern);
    messages.add(ChatMessage(false, pathway.steps[0].question));
    seeded = true;
  }

  // Map step indices 0,4,5 to pathway steps 0,1,2
  GuidedStep get _pathwayStep {
    if (stepIndex == 4) return pathway.steps[1];
    if (stepIndex == 5) return pathway.steps[2];
    return pathway.steps[0];
  }

  bool get _isMultiSelectStep =>
      stepIndex == 2 || stepIndex == 4 || stepIndex == 5;

  // Returns step with correct multiSelect flag for GuidedChatControls
  GuidedStep get _stepForControls {
    if (stepIndex == 2) {
      return const GuidedStep(
          title: 'Actions', question: '', options: [], multiSelect: true);
    }
    return _pathwayStep;
  }

  List<GuidedOption> get currentOptions {
    if (stepIndex == 1) return _goalFocusOptions();
    if (stepIndex == 2) return _actionSelectOptions();
    return _pathwayStep.options;
  }

  bool get isComplete => flowComplete;

  bool get canContinueMulti =>
      _isMultiSelectStep && (answers[stepIndex]?.isNotEmpty ?? false);

  List<GuidedOption> _goalFocusOptions() {
    if (_cachedGoalOptions != null) return _cachedGoalOptions!;
    final ids = _motivationGoalIds[pathway.layer] ?? ['G1'];
    _cachedGoalOptions = [
      for (var i = 0; i < ids.length; i++)
        GuidedOption(
          label: String.fromCharCode(65 + i),
          text: _d1GoalById(ids[i]).description,
          goalTitle: ids[i],
          keywords: [ids[i].toLowerCase()],
        ),
    ];
    return _cachedGoalOptions!;
  }

  List<GuidedOption> _actionSelectOptions() {
    if (_cachedActionOptions != null) return _cachedActionOptions!;
    _cachedActionOptions = [
      for (final id in _goalActionIds[_selectedGoalId] ?? <String>[])
        GuidedOption(
            label: id, text: _d2Actions[id]?.text ?? id, goalTitle: id),
    ];
    return _cachedActionOptions!;
  }

  List<D2Action> get _selectedD2Actions {
    return (answers[2] ?? <GuidedOption>[])
        .map((o) => _d2Actions[o.goalTitle])
        .whereType<D2Action>()
        .toList();
  }

  void chooseOption(GuidedOption option) {
    if (isComplete) return;
    setState(() {
      error = '';
      controller.clear();
      if (stepIndex == 1) {
        _selectedGoalId = option.goalTitle;
        _cachedActionOptions = null;
        answers[1] = [option];
        _commitCurrentStep();
      } else if (_isMultiSelectStep) {
        final selected = [...answers[stepIndex] ?? <GuidedOption>[]];
        final idx = selected.indexWhere(
          (o) => o.goalTitle == option.goalTitle && o.label == option.label,
        );
        if (idx >= 0) {
          selected.removeAt(idx);
        } else {
          selected.add(option);
        }
        answers[stepIndex] = selected;
      } else {
        answers[stepIndex] = [option];
        _commitCurrentStep();
      }
    });
    _scrollToBottom();
  }

  void submitTypedAnswer() {
    if (stepIndex == 2 || stepIndex == 3 || isComplete) return;
    final typed = controller.text.trim();
    if (typed.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final opts = currentOptions;
    if (opts.isEmpty) return;
    final option = _closestOption(typed, opts);
    setState(() {
      error = '';
      controller.clear();
      messages.add(ChatMessage(true, typed));
      messages
          .add(ChatMessage(false, 'Closest fit: ${_trimPeriod(option.text)}'));
      if (stepIndex == 1) {
        _selectedGoalId = option.goalTitle;
        _cachedActionOptions = null;
        answers[1] = [option];
        _advanceFromStep();
      } else if (_isMultiSelectStep) {
        answers[stepIndex] = [
          ...answers[stepIndex] ?? <GuidedOption>[],
          option
        ];
      } else {
        answers[stepIndex] = [option];
        _advanceFromStep();
      }
    });
    _scrollToBottom();
  }

  void continueMultiSelect() {
    if (!canContinueMulti || isComplete) return;
    setState(() {
      final selected = answers[stepIndex] ?? <GuidedOption>[];
      messages.add(ChatMessage(
          true, selected.map((o) => _trimPeriod(o.text)).join(', ')));
      if (stepIndex == 2) {
        stepIndex = 3;
        messages.add(
            ChatMessage(false, "Let's set the specifics for each action."));
      } else {
        _advanceFromStep();
      }
    });
    _scrollToBottom();
  }

  void _commitCurrentStep() {
    final selected = answers[stepIndex] ?? <GuidedOption>[];
    if (selected.isEmpty) return;
    messages.add(
        ChatMessage(true, selected.map((o) => _trimPeriod(o.text)).join(', ')));
    _advanceFromStep();
  }

  void _advanceFromStep() {
    switch (stepIndex) {
      case 0:
        stepIndex = 1;
        messages.add(ChatMessage(false,
            "Specify: Which goal would you like to focus on first? Don't worry — you can add more later once your account is set up!"));
      case 1:
        stepIndex = 2;
        answers[2] = _actionSelectOptions();
        messages.add(ChatMessage(false,
            'Here are the recommended actions for your goal. Unselect any you want to skip, then confirm.'));
      case 4:
        stepIndex = 5;
        messages.add(ChatMessage(false, pathway.steps[2].question));
      case 5:
        _finishGuidedFlow();
    }
  }

  void _onActionsConfigured(Map<String, Map<String, String>> values) {
    setState(() {
      _actionConfigValues = values;
      messages.add(ChatMessage(true, 'Actions configured.'));
      stepIndex = 4;
      messages.add(ChatMessage(false, pathway.steps[1].question));
    });
    _scrollToBottom();
  }

  void _finishGuidedFlow() {
    flowComplete = true;
    final state = AppScope.of(context);
    final goalId = _selectedGoalId ?? 'G1';
    final goal = _d1GoalById(goalId);
    final selectedActionIds = (answers[2] ?? <GuidedOption>[])
        .map((o) => o.goalTitle ?? o.label)
        .toList();
    state.selectedGoalId = goalId;
    state.setRecommendedGoal(
      title: goal.title,
      description: goal.description,
      monthlyTarget: 0,
    );
    state.configureGoalActions(
      actionIds: selectedActionIds,
      enableEmotionalLogs: false,
      enableStressIndicators: false,
    );
    state.actionFieldValues
      ..clear()
      ..addAll(_actionConfigValues);
    for (final actionId in selectedActionIds) {
      final action = _d2Actions[actionId];
      if (action == null || !action.hasFields) continue;
      state.actionFieldValues.putIfAbsent(
        actionId,
        () => _initialActionFieldValues(state, action),
      );
    }
    state.setMotivation('${goal.title}. ${goal.description}');
    state.setGuidedChatSummary(
      surface: _summarySentence(_firstAnswer(0), _surfacePhrase),
      goalFocus: goal.title,
      timeframe: '',
      difficulty: '',
      situations: _summaryList(answers[4] ?? <GuidedOption>[]),
      challenges: _summaryList(answers[5] ?? <GuidedOption>[]),
    );
    messages.add(ChatMessage(false,
        "Great, I have enough to shape this with you. Let's turn it into a clear first plan that fits your rhythm."));
    unawaited(state.saveProfile());
  }

  void resetGuidedChat() {
    final state = AppScope.of(context);
    setState(() {
      error = '';
      flowComplete = false;
      stepIndex = 0;
      _selectedGoalId = null;
      _actionConfigValues = {};
      _cachedGoalOptions = null;
      _cachedActionOptions = null;
      pathway = _pathwayForLayer(state.primaryConcern);
      controller.clear();
      answers.clear();
      messages
        ..clear()
        ..add(ChatMessage(false, pathway.steps[0].question));
      state.resetGuidedPathDetails();
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final hasReflection = state.reflectedMotivation.isNotEmpty;
    final selected = answers[stepIndex] ?? const <GuidedOption>[];
    return OnboardingScaffold(
      phase: 7,
      title: 'Shape your path.',
      subtitle: stepIndex == 3
          ? 'Set up the details for each action.'
          : 'Pick an answer or type one. Shelby maps typed replies to the closest choice.',
      scrollBody: false,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error.isNotEmpty) ...[
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _red,
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
          ],
          PrimaryButton(
            label: hasReflection ? 'Review Goal Plan' : 'Complete the choices',
            icon: Icons.arrow_forward_rounded,
            enabled: hasReflection,
            onPressed: () => _push(context, const GoalQuestionnaireScreen()),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: ListView.separated(
                controller: scrollController,
                primary: false,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                itemCount: messages.length + (hasReflection ? 1 : 2),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (!hasReflection && index == messages.length) {
                    if (stepIndex == 3) {
                      return ActionConfigWidget(
                        actions: _selectedD2Actions,
                        onConfirm: _onActionsConfigured,
                      );
                    }
                    return GuidedChatControls(
                      step: _stepForControls,
                      options: currentOptions,
                      selected: selected,
                      controller: controller,
                      canContinueMulti: canContinueMulti,
                      onOptionTap: chooseOption,
                      onContinue: continueMultiSelect,
                      onSubmitTyped: submitTypedAnswer,
                    );
                  }
                  final resetIndex = messages.length + (hasReflection ? 0 : 1);
                  if (index == resetIndex) {
                    return GuidedChatResetButton(onPressed: resetGuidedChat);
                  }
                  final message = messages[index];
                  return ChatBubble(
                    fromUser: message.fromUser,
                    text: message.text,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  GuidedOption _closestOption(String answer, List<GuidedOption> options) {
    final normalized = answer.toLowerCase();
    GuidedOption best = options.first;
    var bestScore = -1;
    for (final option in options) {
      final searchable = [
        option.label,
        option.text,
        option.detail ?? '',
        ...option.keywords,
      ].join(' ').toLowerCase();
      final score = searchable
          .split(RegExp(r'[^a-z0-9]+'))
          .where((word) => word.length > 2 && normalized.contains(word))
          .length;
      if (score > bestScore) {
        best = option;
        bestScore = score;
      }
    }
    return best;
  }

  GuidedOption? _firstAnswer(int index) {
    final selected = answers[index] ?? const <GuidedOption>[];
    return selected.isEmpty ? null : selected.first;
  }

  String _surfacePhrase(GuidedOption option) {
    return switch (_trimPeriod(option.text)) {
      'I keep meaning to check my spending, but the habit slips when life gets busy' =>
        'checking your spending gets harder when life gets busy',
      'I notice extra purchases around weekends, payday, or certain stores' =>
        'extra purchases tend to show up around specific days, paydays, or stores',
      'I feel thrown off when bills, income, or timing do not line up' =>
        'bills, income, or timing can throw your plan off',
      'I save a little, but regular expenses keep pulling that money back out' =>
        'regular expenses keep pulling money back out of savings',
      'Surprise expenses or due dates disrupt my monthly plan' =>
        'surprise expenses or due dates disrupt your monthly plan',
      'I want a cushion, but I need help making saving feel automatic' =>
        'you want saving to feel more automatic',
      'Debt payments keep taking up budget space every month' =>
        'debt payments keep taking up budget space',
      'I want to start investing, but I have not completed the setup steps' =>
        'starter investing still needs clear setup steps',
      'When more money comes in, it seems to disappear into more spending' =>
        'extra income can disappear into extra spending',
      'I have several things I care about, and it is hard to know what to fund first' =>
        'you have several meaningful goals competing for attention',
      'I want to save for something meaningful without messing up my bills' =>
        'you want to fund something meaningful while keeping bills steady',
      'I spend on hobbies or travel without a clear funded bucket' =>
        'hobby or travel spending needs its own funded bucket',
      final value => value.toLowerCase(),
    };
  }

  String _summarySentence(
    GuidedOption? option,
    String Function(GuidedOption) phraseFor,
  ) {
    if (option == null) return '';
    final phrase = phraseFor(option);
    if (phrase.isEmpty) return '';
    return phrase[0].toUpperCase() + phrase.substring(1);
  }

  String _summaryList(List<GuidedOption> options) {
    final values = options.map((o) => _trimPeriod(o.text)).toList();
    if (values.length <= 1) return values.join();
    if (values.length == 2) return '${values.first} and ${values.last}';
    return '${values.sublist(0, values.length - 1).join(', ')}, and ${values.last}';
  }

  String _trimPeriod(String value) {
    final trimmed = value.trim();
    return trimmed.endsWith('.')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}

// ─── Add a goal after onboarding ───────────────────────────────────────────
//
// Reuses the same D1/D2 catalog and chat widgets as onboarding's goal-focus
// and action-select steps, but as a standalone flow reachable from the
// Goals tab: pick a motivation (excluding ones with no goal left to adopt),
// pick one goal under it, pick actions, configure them, done. Actions are
// added on top of whatever's already selected rather than replacing it.

class AddGoalMotivationScreen extends StatelessWidget {
  const AddGoalMotivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final available = motivationsWithAvailableGoal(state);
    final branches =
        _goalBranches.where((branch) => available.contains(branch.layer)).toList();
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                color: _brand,
                icon: const Icon(Icons.chevron_left_rounded, size: 32),
              ),
              const SizedBox(height: 4),
              Text('Add a new goal',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text(
                'Which area would you like to focus on next?',
                style: TextStyle(
                    color: _body, height: 1.35, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: branches.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "You've already set up every goal Shelby offers right now — nice work!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: _body, fontWeight: FontWeight.w700),
                          ),
                        ),
                      )
                    : ListView(
                        children: [
                          for (final branch in branches)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: SelectableOption(
                                icon: branch.icon,
                                title: branch.layer,
                                body: branch.layerDescription,
                                selected: false,
                                onTap: () => _push(
                                  context,
                                  AddGoalChatScreen(layer: branch.layer),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddGoalChatScreen extends StatefulWidget {
  const AddGoalChatScreen({super.key, required this.layer});
  final String layer;

  @override
  State<AddGoalChatScreen> createState() => _AddGoalChatScreenState();
}

class _AddGoalChatScreenState extends State<AddGoalChatScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  final List<ChatMessage> messages = [];
  int stepIndex = 0; // 0 = goal focus, 1 = action select, 2 = configure
  final Map<int, List<GuidedOption>> answers = {};
  String? _selectedGoalId;
  bool _seeded = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    messages.add(ChatMessage(
        false, 'Which goal under ${widget.layer} would you like to focus on?'));
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  List<GuidedOption> get _goalOptions {
    final state = AppScope.of(context);
    final ids = (_motivationGoalIds[widget.layer] ?? const <String>[])
        .where((id) => !isGoalAdopted(state, id))
        .toList();
    return [
      for (var i = 0; i < ids.length; i++)
        GuidedOption(
          label: String.fromCharCode(65 + i),
          text: _d1GoalById(ids[i]).description,
          goalTitle: ids[i],
        ),
    ];
  }

  List<GuidedOption> get _actionOptions {
    final ids = _goalActionIds[_selectedGoalId] ?? const <String>[];
    return [
      for (final id in ids)
        GuidedOption(label: id, text: _d2Actions[id]?.text ?? id, goalTitle: id),
    ];
  }

  List<D2Action> get _selectedD2Actions {
    return (answers[1] ?? const <GuidedOption>[])
        .map((o) => _d2Actions[o.goalTitle])
        .whereType<D2Action>()
        .toList();
  }

  bool get _isMultiSelectStep => stepIndex == 1;

  bool get canContinueMulti =>
      _isMultiSelectStep && (answers[stepIndex]?.isNotEmpty ?? false);

  GuidedStep get _stepForControls {
    if (stepIndex == 0) {
      return GuidedStep(
        title: 'Goal',
        question: 'Which goal would you like to focus on?',
        options: _goalOptions,
      );
    }
    return GuidedStep(
      title: 'Actions',
      question: 'Pick the actions for this goal.',
      options: _actionOptions,
      multiSelect: true,
    );
  }

  List<GuidedOption> get currentOptions =>
      stepIndex == 0 ? _goalOptions : _actionOptions;

  void chooseOption(GuidedOption option) {
    if (stepIndex == 0) {
      // Show the pick highlighted for a beat before advancing, so the tap
      // has visible feedback instead of jumping straight to the next step.
      setState(() {
        _selectedGoalId = option.goalTitle;
        answers[0] = [option];
      });
      Future.delayed(const Duration(milliseconds: 260), () {
        if (!mounted || stepIndex != 0) return;
        setState(() {
          messages.add(ChatMessage(true, option.text));
          stepIndex = 1;
          messages.add(const ChatMessage(false,
              'Here are the recommended actions for this goal. Unselect any you want to skip, then confirm.'));
        });
        _scrollToBottom();
      });
      return;
    }
    setState(() {
      if (_isMultiSelectStep) {
        final selected = [...answers[stepIndex] ?? <GuidedOption>[]];
        final idx =
            selected.indexWhere((o) => o.goalTitle == option.goalTitle);
        if (idx >= 0) {
          selected.removeAt(idx);
        } else {
          selected.add(option);
        }
        answers[stepIndex] = selected;
      }
    });
    _scrollToBottom();
  }

  void continueMultiSelect() {
    if (!canContinueMulti) return;
    setState(() {
      final selected = answers[stepIndex] ?? <GuidedOption>[];
      messages
          .add(ChatMessage(true, selected.map((o) => o.text).join(', ')));
      stepIndex = 2;
    });
    _scrollToBottom();
  }

  void submitTypedAnswer() {
    controller.clear();
  }

  Future<void> _onActionsConfigured(
      Map<String, Map<String, String>> values) async {
    if (_saving) return;
    setState(() => _saving = true);
    final state = AppScope.of(context);
    final actionIds = (answers[1] ?? const <GuidedOption>[])
        .map((o) => o.goalTitle ?? o.label)
        .toList();
    final fieldValues = <String, Map<String, String>>{};
    for (final id in actionIds) {
      final action = _d2Actions[id];
      if (action == null || !action.hasFields) continue;
      fieldValues[id] =
          values[id] ?? _initialActionFieldValues(state, action);
    }
    state.addGoalActions(actionIds, fieldValues);
    await state.saveProfile();
    if (!mounted) return;
    Navigator.of(context)
      ..pop()
      ..pop();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = answers[stepIndex] ?? const <GuidedOption>[];
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    color: _brand,
                    icon: const Icon(Icons.chevron_left_rounded, size: 32),
                  ),
                  Expanded(
                    child: Text(
                      widget.layer,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        if (stepIndex == 2) {
                          return _saving
                              ? const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : ActionConfigWidget(
                                  actions: _selectedD2Actions,
                                  onConfirm: _onActionsConfigured,
                                );
                        }
                        return GuidedChatControls(
                          step: _stepForControls,
                          options: currentOptions,
                          selected: selected,
                          controller: controller,
                          canContinueMulti: canContinueMulti,
                          onOptionTap: chooseOption,
                          onContinue: continueMultiSelect,
                          onSubmitTyped: submitTypedAnswer,
                        );
                      }
                      final message = messages[index];
                      return ChatBubble(
                          fromUser: message.fromUser, text: message.text);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionFieldSelector extends StatefulWidget {
  const ActionFieldSelector({
    super.key,
    required this.field,
    required this.initialValue,
    required this.onChanged,
    this.recommendations,
  });

  final ActionField field;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final List<String>? recommendations;

  @override
  State<ActionFieldSelector> createState() => _ActionFieldSelectorState();
}

class _ActionFieldSelectorState extends State<ActionFieldSelector> {
  late final List<String> recommendations;
  late final TextEditingController customController;
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    recommendations =
        widget.recommendations ?? _recommendationsForField(widget.field);
    final recommendedIndex = recommendations.indexOf(widget.initialValue);
    selectedIndex = recommendedIndex >= 0
        ? recommendedIndex
        : (widget.initialValue.isEmpty ? 0 : recommendations.length);
    customController = TextEditingController(
      text: selectedIndex == recommendations.length ? widget.initialValue : '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.initialValue.isEmpty) {
        widget.onChanged(recommendations.first);
      }
    });
  }

  @override
  void dispose() {
    customController.dispose();
    super.dispose();
  }

  void _select(int index) {
    setState(() => selectedIndex = index);
    widget.onChanged(index < recommendations.length
        ? recommendations[index]
        : customController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final customValue = customController.text.trim();
    final error = selectedIndex == 3
        ? _actionFieldError(widget.field, customValue)
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.field.label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800, color: _body)),
        const SizedBox(height: 6),
        for (var i = 0; i < recommendations.length; i++)
          RadioListTile<int>(
            dense: true,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            activeColor: _brand,
            value: i,
            groupValue: selectedIndex,
            title: Text(
              '${_fieldValueLabel(widget.field, recommendations[i])}${i == 0 ? '  Recommended' : ''}',
              style: const TextStyle(
                  color: _title, fontSize: 12, fontWeight: FontWeight.w800),
            ),
            onChanged: (_) => _select(i),
          ),
        RadioListTile<int>(
          dense: true,
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          activeColor: _brand,
          value: recommendations.length,
          groupValue: selectedIndex,
          title: const Text('Enter my own',
              style: TextStyle(
                  color: _title, fontSize: 12, fontWeight: FontWeight.w800)),
          onChanged: (_) => _select(3),
        ),
        if (selectedIndex == 3)
          TextField(
            controller: customController,
            keyboardType: widget.field.key == 'freq'
                ? TextInputType.text
                : const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              setState(() {});
              widget.onChanged(value.trim());
            },
            decoration: InputDecoration(
              hintText: widget.field.hint,
              suffixText: widget.field.isPercent ? '%' : null,
              errorText: error,
              isDense: true,
            ),
          ),
      ],
    );
  }
}

class ActionConfigWidget extends StatefulWidget {
  const ActionConfigWidget({
    super.key,
    required this.actions,
    required this.onConfirm,
  });
  final List<D2Action> actions;
  final void Function(Map<String, Map<String, String>> values) onConfirm;

  @override
  State<ActionConfigWidget> createState() => _ActionConfigWidgetState();
}

class _ActionConfigWidgetState extends State<ActionConfigWidget> {
  late final PageController _pageController;
  int _page = 0;
  var _values = <Map<String, String>>[];
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    final state = AppScope.of(context);
    _values = [
      for (final action in widget.actions)
        _initialActionFieldValues(state, action),
    ];
    _seeded = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_page < widget.actions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _confirm();
    }
  }

  void _confirm() {
    for (var i = 0; i < widget.actions.length; i++) {
      for (final field in widget.actions[i].fields) {
        if (_actionFieldError(field, _values[i][field.key] ?? '') != null) {
          return;
        }
      }
    }
    final values = <String, Map<String, String>>{};
    for (var i = 0; i < widget.actions.length; i++) {
      values[widget.actions[i].id] = Map<String, String>.from(_values[i]);
    }
    widget.onConfirm(values);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.actions.length;
    if (total == 0) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: PrimaryButton(label: 'Confirm', onPressed: _confirm),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${_page + 1} / $total',
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: _body),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 360,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: total,
            itemBuilder: (context, i) {
              final action = widget.actions[i];
              final state = AppScope.of(context);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.text,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                      if (action.hasFields) ...[
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.separated(
                            itemCount: action.fields.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 20),
                            itemBuilder: (context, fieldIndex) {
                              final field = action.fields[fieldIndex];
                              return ActionFieldSelector(
                                field: field,
                                initialValue: _values[i][field.key] ?? '',
                                recommendations: _recommendationsForActionField(
                                    state, action, field),
                                onChanged: (value) =>
                                    _values[i][field.key] = value,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        _RecommendationExplanationBox(
                          lines: [
                            for (final field in action.fields)
                              _recommendationFormulaForActionField(
                                  state, action, field),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: _page < total - 1 ? 'Next' : 'Confirm All',
          icon: _page < total - 1
              ? Icons.arrow_forward_rounded
              : Icons.check_rounded,
          onPressed: _goNext,
        ),
      ],
    );
  }
}

class _RecommendationExplanationBox extends StatelessWidget {
  const _RecommendationExplanationBox({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.functions_rounded, size: 15, color: _purple),
              SizedBox(width: 6),
              Text(
                'Why this recommendation',
                style: TextStyle(
                  color: _title,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                line,
                style: const TextStyle(
                  color: _body,
                  fontSize: 10.5,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GuidedChatControls extends StatelessWidget {
  const GuidedChatControls({
    super.key,
    required this.step,
    required this.options,
    required this.selected,
    required this.controller,
    required this.canContinueMulti,
    required this.onOptionTap,
    required this.onContinue,
    required this.onSubmitTyped,
  });

  final GuidedStep step;
  final List<GuidedOption> options;
  final List<GuidedOption> selected;
  final TextEditingController controller;
  final bool canContinueMulti;
  final ValueChanged<GuidedOption> onOptionTap;
  final VoidCallback onContinue;
  final VoidCallback onSubmitTyped;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GuidedChatOptionButton(
                  option: option,
                  multiSelect: step.multiSelect,
                  selected: selected.contains(option),
                  onTap: () => onOptionTap(option),
                ),
              ),
            ),
            if (step.multiSelect) ...[
              const SizedBox(height: 6),
              SizedBox(
                height: 38,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _brand,
                    disabledBackgroundColor: _border,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: _body,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: canContinueMulti ? onContinue : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 6),
            GuidedChatComposer(
              controller: controller,
              onSubmit: onSubmitTyped,
            ),
          ],
        ),
      ),
    );
  }
}

class GuidedChatResetButton extends StatelessWidget {
  const GuidedChatResetButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.refresh_rounded, size: 17),
        label: const Text('Reset chat'),
        style: TextButton.styleFrom(
          foregroundColor: _purple,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class GuidedChatComposer extends StatelessWidget {
  const GuidedChatComposer({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 1,
              textInputAction: TextInputAction.send,
              decoration: const InputDecoration(
                hintText: 'Type your own answer',
                hintStyle: TextStyle(
                  color: _body,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(12, 10, 8, 10),
              ),
              style: const TextStyle(
                color: _title,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          SizedBox(
            width: 38,
            height: 38,
            child: IconButton(
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                backgroundColor: _brand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onSubmit,
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
            ),
          ),
          const SizedBox(width: 2),
        ],
      ),
    );
  }
}

class GuidedChatOptionButton extends StatelessWidget {
  const GuidedChatOptionButton({
    super.key,
    required this.option,
    required this.multiSelect,
    required this.selected,
    required this.onTap,
  });

  final GuidedOption option;
  final bool multiSelect;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _bellySoft : _bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _brand : _border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _brand : _surface,
                shape: BoxShape.circle,
                border: Border.all(color: selected ? _brand : _border),
              ),
              child: selected
                  ? Icon(
                      multiSelect
                          ? Icons.check_rounded
                          : Icons.radio_button_checked_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : Text(
                      option.label.isEmpty ? '' : option.label.substring(0, 1),
                      style: const TextStyle(
                        color: _brand,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.text,
                    style: const TextStyle(
                      color: _title,
                      fontSize: 12,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (option.detail != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      option.detail!,
                      style: const TextStyle(
                        color: _body,
                        fontSize: 10.5,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FinancialBaselineScreen extends StatefulWidget {
  const FinancialBaselineScreen({super.key});

  @override
  State<FinancialBaselineScreen> createState() =>
      _FinancialBaselineScreenState();
}

class _FinancialBaselineScreenState extends State<FinancialBaselineScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 11,
      title: 'Financial Scaffolding.',
      subtitle:
          'Quantify your economic standing for the financial pyramid health index.',
      bottom: PrimaryButton(
        label: 'Choose Tracking Variables',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const TrackingVariablesScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaselineSummaryStrip(
            assets: state.totalAssets,
            liabilities: state.totalLiabilities,
            netWorth: state.totalAssets - state.totalLiabilities,
          ),
          const SizedBox(height: 18),
          EditableMoneyItemList(
            title: 'Assets',
            total: state.totalAssets,
            items: state.assets,
            icon: Icons.savings_rounded,
            onAdd: () => _showMoneyItemDialog(context, isLiability: false),
            onEdit: (item) => _showMoneyItemDialog(
              context,
              item: item,
              isLiability: false,
            ),
            onDelete: state.removeAsset,
          ),
          const SizedBox(height: 24),
          EditableMoneyItemList(
            title: 'Liabilities',
            total: state.totalLiabilities,
            items: state.liabilities,
            icon: Icons.credit_card_rounded,
            danger: true,
            onAdd: () => _showMoneyItemDialog(context, isLiability: true),
            onEdit: (item) => _showMoneyItemDialog(
              context,
              item: item,
              isLiability: true,
            ),
            onDelete: state.removeLiability,
          ),
        ],
      ),
    );
  }

  Future<void> _showMoneyItemDialog(
    BuildContext context, {
    MoneyItem? item,
    required bool isLiability,
  }) async {
    final state = AppScope.of(context);
    final nameController = TextEditingController(text: item?.name ?? '');
    final descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    final valueController = TextEditingController(
      text:
          item == null || item.value == 0 ? '' : item.value.toStringAsFixed(0),
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final title = item == null
            ? (isLiability ? 'Add Liability' : 'Add Asset')
            : (isLiability ? 'Edit Liability' : 'Edit Asset');
        return AlertDialog(
          backgroundColor: _surface,
          title: Text(
            title,
            style: const TextStyle(color: _title, fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: inputDecoration(
                  isLiability ? 'Credit Card' : 'Investment Portfolio',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                textInputAction: TextInputAction.next,
                decoration: inputDecoration(
                  isLiability ? 'Visa Gold' : 'Vanguard ETF',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration('Amount').copyWith(
                  prefixText: '₱ ',
                  prefixStyle: const TextStyle(
                    color: _title,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (item != null)
              TextButton(
                onPressed: () {
                  if (isLiability) {
                    state.removeLiability(item);
                  } else {
                    state.removeAsset(item);
                  }
                  Navigator.of(dialogContext).pop();
                  setState(() {});
                },
                child: const Text('Delete', style: TextStyle(color: _red)),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(valueController.text) ?? 0;
                if (item == null) {
                  final newItem = MoneyItem(
                    nameController.text.trim().isEmpty
                        ? (isLiability ? 'New Liability' : 'New Asset')
                        : nameController.text.trim(),
                    descriptionController.text.trim().isEmpty
                        ? 'Tap to refine later'
                        : descriptionController.text.trim(),
                    value,
                  );
                  state.addMoneyItem(newItem, isLiability: isLiability);
                } else {
                  state.updateMoneyItem(
                    item,
                    name: nameController.text,
                    description: descriptionController.text,
                    value: value,
                  );
                }
                Navigator.of(dialogContext).pop();
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    valueController.dispose();
  }
}

class BaselineSummaryStrip extends StatelessWidget {
  const BaselineSummaryStrip({
    super.key,
    required this.assets,
    required this.liabilities,
    required this.netWorth,
  });

  final double assets;
  final double liabilities;
  final double netWorth;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(child: ProfileStat(label: 'Assets', value: money(assets))),
          Container(width: 1, height: 42, color: _border),
          Expanded(
            child: ProfileStat(label: 'Liabilities', value: money(liabilities)),
          ),
          Container(width: 1, height: 42, color: _border),
          Expanded(child: ProfileStat(label: 'Net', value: money(netWorth))),
        ],
      ),
    );
  }
}

class EditableMoneyItemList extends StatelessWidget {
  const EditableMoneyItemList({
    super.key,
    required this.title,
    required this.total,
    required this.items,
    required this.icon,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.danger = false,
  });

  final String title;
  final double total;
  final List<MoneyItem> items;
  final IconData icon;
  final VoidCallback onAdd;
  final ValueChanged<MoneyItem> onEdit;
  final ValueChanged<MoneyItem> onDelete;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title, action: money(total), danger: danger),
        const SizedBox(height: 12),
        if (items.isEmpty)
          AppCard(
            child: Text(
              danger ? 'No liabilities added yet.' : 'No assets added yet.',
              style: const TextStyle(color: _body, fontWeight: FontWeight.w700),
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Dismissible(
                key: ValueKey(item),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 22),
                  decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) => onDelete(item),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => onEdit(item),
                  child: FinancialItemCard(
                    item: item,
                    icon: icon,
                    danger: danger,
                  ),
                ),
              ),
            ),
          ),
        DashedAction(
          label: danger ? 'Add Liability' : 'Add Asset',
          onTap: onAdd,
          danger: danger,
        ),
      ],
    );
  }
}

class TrackingVariablesScreen extends StatefulWidget {
  const TrackingVariablesScreen({super.key});

  @override
  State<TrackingVariablesScreen> createState() =>
      _TrackingVariablesScreenState();
}

class _TrackingVariablesScreenState extends State<TrackingVariablesScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final essential = [
      'Income',
      'Expenses',
      'Savings progress',
      'Assets and liabilities',
      'Debt payments',
      'Goal allocation',
    ];
    final interfering = [
      'Family obligations',
      'Irregular income',
      'Debt due dates',
      'Social spending pressure',
      'Emergency purchases',
      'Subscription creep',
    ];
    return OnboardingScaffold(
      phase: 12,
      title: 'Choose what Shellby tracks.',
      subtitle:
          'Preparation defines the variables before collection starts: what counts, what gets in the way, and what stays optional.',
      bottom: PrimaryButton(
        label: 'Check Feasibility',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const GoalFeasibilityScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(index: 1, title: 'Goal-related variables'),
          const SizedBox(height: 12),
          ...essential.map(
            (value) => ToggleRow(
              title: value,
              selected: state.trackingVariables.contains(value),
              onTap: () => setState(() => state.toggleTrackingVariable(value)),
            ),
          ),
          const SizedBox(height: 24),
          SectionLabel(index: 2, title: 'Interfering variables'),
          const SizedBox(height: 12),
          ...interfering.map(
            (value) => ToggleRow(
              title: value,
              selected: state.interferingVariables.contains(value),
              onTap: () =>
                  setState(() => state.toggleInterferingVariable(value)),
            ),
          ),
        ],
      ),
    );
  }
}

class GoalQuestionnaireScreen extends StatelessWidget {
  const GoalQuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 8,
      title: 'Conversation summary.',
      subtitle: 'Here is the clearest version of what you told Shellby.',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: 'See Recommended Plan',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => _push(context, const RecommendedPlanScreen()),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GuidedSummaryCard(state: state),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: () {
                state.primaryConcern = _goalBranches.first.layer;
                state.resetGuidedPathDetails();
                _pushFinancialConcernWithFullHistory(context);
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Redo Conversation'),
              style: TextButton.styleFrom(
                foregroundColor: _purple,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendedPlanScreen extends StatefulWidget {
  const RecommendedPlanScreen({super.key});

  @override
  State<RecommendedPlanScreen> createState() => _RecommendedPlanScreenState();
}

class _RecommendedPlanScreenState extends State<RecommendedPlanScreen> {
  void _redoConversation(AppState state) {
    state.primaryConcern = _goalBranches.first.layer;
    state.resetGuidedPathDetails();
    _pushFinancialConcernWithFullHistory(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final branch = _branchForLayer(state.primaryConcern);
    final goal = _d1GoalById(state.selectedGoalId);
    final actions = state.selectedActionIds
        .map((id) => _d2Actions[id])
        .whereType<D2Action>()
        .toList();
    final dataIds = <String>{
      for (final action in actions) ...?_actionDataMatrix[action.id],
    };
    final dataPoints = _planDataPoints.values
        .where((point) => dataIds.contains(point.id))
        .toList();
    return OnboardingScaffold(
      phase: 9,
      title: 'Recommended plan.',
      subtitle:
          'Built directly from the motivation, goal, actions, and specifics you selected.',
      bottom: PrimaryButton(
        label: 'Link FakeMaya',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const FakeMayaOnboardingScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecommendedPlanSection(
            number: 1,
            title: 'Motivation',
            icon: Icons.favorite_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.primaryConcern,
                    style: const TextStyle(
                        color: _title,
                        fontSize: 16,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(branch.layerDescription,
                    style: const TextStyle(
                        color: _body,
                        height: 1.35,
                        fontWeight: FontWeight.w700)),
                if (state.chatSurfaceSummary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('You shared: ${state.chatSurfaceSummary}',
                      style: const TextStyle(
                          color: _purple,
                          height: 1.3,
                          fontWeight: FontWeight.w800)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _RecommendedPlanSection(
            number: 2,
            title: 'Goal',
            icon: Icons.flag_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${goal.id}: ${goal.title}',
                    style: const TextStyle(
                        color: _title,
                        fontSize: 16,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(goal.description,
                    style: const TextStyle(
                        color: _body,
                        height: 1.35,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _RecommendedPlanSection(
            number: 3,
            title: 'Actions',
            icon: Icons.checklist_rounded,
            child: Column(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  _PlanActionRow(
                      action: actions[i],
                      values:
                          state.actionFieldValues[actions[i].id] ?? const {}),
                  if (i < actions.length - 1)
                    const Divider(height: 20, color: _border),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _RecommendedPlanSection(
            number: 4,
            title: 'Data to be collected',
            icon: Icons.storage_rounded,
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final point in dataPoints) _PlanDataChip(point: point)
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('How the plan will work',
              style: TextStyle(
                  color: _title, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          const Text(
              'For each selected action, here is what you do and what Shellby handles.',
              style: TextStyle(
                  color: _body, height: 1.3, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (var i = 0; i < actions.length; i++) ...[
            _ActionCollectionProcessCard(
              index: i + 1,
              action: actions[i],
              values: state.actionFieldValues[actions[i].id] ?? const {},
              data: (_actionDataMatrix[actions[i].id] ?? const [])
                  .map((id) => _planDataPoints[id])
                  .whereType<PlanDataPoint>()
                  .toList(),
            ),
            const SizedBox(height: 10),
          ],
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: () => _redoConversation(state),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Redo Conversation'),
              style: TextButton.styleFrom(
                foregroundColor: _purple,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _configuredActionText(D2Action action, Map<String, String> values) {
  if (action.id == 'A9') {
    final amount =
        values['amt'] ?? _recommendationsForField(action.fields[0]).first;
    return 'Deposit at least ₱$amount into the Emergency Fund each month.';
  }
  var text = action.text;
  for (final field in action.fields) {
    final value = values[field.key] ?? _recommendationsForField(field).first;
    final replacement = field.key == 'freq' ? value : value.replaceAll(',', '');
    text = text.replaceFirst('X', replacement);
  }
  return text;
}

Map<String, String> _initialActionFieldValues(
  AppState state,
  D2Action action, [
  Map<String, String> existing = const {},
]) {
  return {
    for (final field in action.fields)
      field.key: existing[field.key] ??
          _recommendationsForActionField(state, action, field).first,
  };
}

class _RecommendedPlanSection extends StatelessWidget {
  const _RecommendedPlanSection(
      {required this.number,
      required this.title,
      required this.icon,
      required this.child});
  final int number;
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBubble(icon),
              const SizedBox(width: 10),
              Text('$number. $title',
                  style: const TextStyle(
                      color: _title,
                      fontSize: 17,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PlanActionRow extends StatelessWidget {
  const _PlanActionRow({required this.action, required this.values});
  final D2Action action;
  final Map<String, String> values;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: _brand.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8)),
          child: Text(action.id,
              style: const TextStyle(
                  color: _brand, fontSize: 11, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 9),
        Expanded(
            child: Text(_configuredActionText(action, values),
                style: const TextStyle(
                    color: _title, height: 1.35, fontWeight: FontWeight.w800))),
      ],
    );
  }
}

class _PlanDataChip extends StatelessWidget {
  const _PlanDataChip({required this.point});
  final PlanDataPoint point;

  @override
  Widget build(BuildContext context) {
    final color = switch (point.kind) {
      'Time' => _purple,
      'Indicator' => _brand,
      _ => _body,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: .2))),
      child: Text('${point.id} · ${point.label}',
          style: TextStyle(
              color: color, fontSize: 10.5, fontWeight: FontWeight.w800)),
    );
  }
}

String _userCollectionStep(D2Action action, List<PlanDataPoint> data) {
  final sourceLabels = data
      .where((point) => point.kind == 'Source')
      .map((point) => point.label.toLowerCase())
      .take(3)
      .join(', ');
  return switch (action.id) {
    'A2' ||
    'A3' =>
      'Connect a financial account or log purchases, including the amount and category. Shellby only needs you to correct a category when it is wrong.',
    'A5' =>
      'Add each bill, its due date, and payment amount. Mark it paid if Shellby cannot detect the payment automatically.',
    'A9' =>
      'Choose the Emergency Fund account or bucket. Confirm a deposit when it is made outside a connected account.',
    'A19' =>
      'Confirm the Everyday Fund account or bucket and keep income, expense, and available cash balances connected or updated.',
    'A20' =>
      'Keep income sources connected or logged, including new side income or salary changes Shellby cannot import automatically.',
    'A22' =>
      'Confirm the Emergency Fund account or bucket and keep essential expense estimates connected or updated.',
    'A10' =>
      'Mark Emergency Fund withdrawals and confirm the income deposit that starts the replenishment window.',
    'A11' ||
    'A13' ||
    'A18' =>
      'Connect or enter the relevant debt balances and payments, then confirm any extra payment Shellby cannot detect.',
    'A12' ||
    'A14' ||
    'A15' ||
    'A23' =>
      'Connect or enter the investment account and confirm contributions that are not imported automatically.',
    'A24' ||
    'A25' =>
      'Keep the investment account connected or record portfolio gains and losses that Shellby cannot import automatically.',
    'A16' ||
    'A17' =>
      'Choose the goal fund, target date, and destination bucket, then confirm transfers that are not imported.',
    _ =>
      'Connect an account or enter the activity needed for this rule: $sourceLabels. Confirm anything Shellby cannot import automatically.',
  };
}

String _appCollectionStep(D2Action action, List<PlanDataPoint> data) {
  final indicators = data
      .where((point) => point.kind == 'Indicator')
      .map((point) => point.label.toLowerCase())
      .join(' and ');
  final indicatorText =
      indicators.isEmpty ? 'progress against the rule' : indicators;
  return switch (action.id) {
    'A1' ||
    'A4' ||
    'A6' ||
    'A7' ||
    'A8' ||
    'A9' ||
    'A13' ||
    'A14' ||
    'A15' ||
    'A16' ||
    'A17' ||
    'A18' =>
      'When matching money arrives, Shellby calculates the configured amount, suggests the transfer, records its source and destination, and updates $indicatorText.',
    'A12' =>
      'When income arrives, Shellby calculates the configured investment contribution, records the transfer to the Investment Portfolio, and updates $indicatorText.',
    'A23' =>
      'Shellby compares the current Investment Portfolio value with the configured target, tracks the remaining gap, and updates $indicatorText.',
    'A24' =>
      'Shellby totals investment gains recorded this month, compares them with the configured earnings target, and updates $indicatorText.',
    'A25' =>
      'Shellby totals investment losses recorded this month, shows how much of the configured loss limit remains, and warns when it is reached.',
    'A2' ||
    'A3' =>
      'Shellby totals matching expenses during the month, compares them with the selected limit, and warns you before or when the limit is reached. It then updates $indicatorText.',
    'A19' =>
      'Shellby uses your monthly expense baseline to calculate the Everyday Fund target, compares it with available cash, and reminds you when the fund drops below the configured months.',
    'A20' =>
      'Shellby compares detected monthly income with the configured earnings target, tracks the monthly gap or surplus, and updates $indicatorText.',
    'A22' =>
      'Shellby multiplies monthly essential expenses by the configured months, compares the target with the Emergency Fund balance, and updates $indicatorText.',
    'A5' =>
      'Shellby counts backward from each due date, reminds you when payment should happen, detects or asks for confirmation, and updates $indicatorText.',
    'A10' =>
      'Shellby starts the configured day counter after income arrives, tracks the replenishment transfer, and reminds you before the window closes.',
    'A11' =>
      'Shellby compares each debt payment with the required minimum, calculates the extra percentage, and updates the outstanding balance and $indicatorText.',
    _ =>
      'Shellby records the linked activity, checks it against the configured rule, reminds you when action is needed, and updates $indicatorText.',
  };
}

class _ActionCollectionProcessCard extends StatelessWidget {
  const _ActionCollectionProcessCard(
      {required this.index,
      required this.action,
      required this.values,
      required this.data});
  final int index;
  final D2Action action;
  final Map<String, String> values;
  final List<PlanDataPoint> data;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$index. ${action.id}',
              style: const TextStyle(
                  color: _brand, fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(_configuredActionText(action, values),
              style: const TextStyle(
                  color: _title, height: 1.35, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          _CollectionRoleRow(
              icon: Icons.person_rounded,
              label: 'You',
              text: _userCollectionStep(action, data)),
          const SizedBox(height: 10),
          _CollectionRoleRow(
              icon: Icons.auto_awesome_rounded,
              label: 'Shellby',
              text: _appCollectionStep(action, data)),
        ],
      ),
    );
  }
}

class _CollectionRoleRow extends StatelessWidget {
  const _CollectionRoleRow(
      {required this.icon, required this.label, required this.text});
  final IconData icon;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _purple, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  color: _body, height: 1.35, fontWeight: FontWeight.w700),
              children: [
                TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                        color: _title, fontWeight: FontWeight.w900)),
                TextSpan(text: text)
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RecommendedPlanOption extends StatelessWidget {
  const RecommendedPlanOption({
    super.key,
    required this.concern,
    required this.selected,
    required this.isTopRecommendation,
    required this.onTap,
  });

  final GoalConcern concern;
  final bool selected;
  final bool isTopRecommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? _bellySoft : _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _purple : _border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? _purple : _body,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          concern.goalTitle,
                          style: const TextStyle(
                            color: _title,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (isTopRecommendation)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _brand.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Best fit',
                            style: TextStyle(
                              color: _brand,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    concern.goalDescription,
                    style: const TextStyle(
                      color: _body,
                      height: 1.3,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Retained for compatibility with older saved baseline forms.
// ignore: unused_element
String? _baselineError(BaselineField field, String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'This starting value is required.';
  if (field.format == 'money') {
    final amount = double.tryParse(trimmed.replaceAll(',', ''));
    if (amount == null) return 'Enter a valid amount.';
    if (amount < 0 || amount > 1000000000)
      return 'Use an amount from ₱0 to ₱1,000,000,000.';
    const positiveKeys = {
      'monthly_expenses',
      'essential_expenses',
      'discretionary_spend',
      'income_baseline',
      'emergency_target',
      'minimum_debt_payment'
    };
    if (positiveKeys.contains(field.key) && amount <= 0)
      return 'Enter an amount greater than zero.';
    return null;
  }
  if (field.format == 'categories') {
    return trimmed.split(',').any((item) => item.trim().isNotEmpty)
        ? null
        : 'Enter at least one category.';
  }
  if (field.format == 'category_amounts') {
    final valid = trimmed.split('\n').every((line) {
      final parts = line.split(':');
      return parts.length == 2 &&
          parts.first.trim().isNotEmpty &&
          (double.tryParse(parts.last.trim().replaceAll(',', '')) ?? -1) >= 0;
    });
    return valid ? null : 'Use one line per category: Category: amount.';
  }
  if (field.format == 'bills') {
    final valid = trimmed.split('\n').every((line) {
      final parts = line.split('|').map((part) => part.trim()).toList();
      return parts.length == 3 &&
          parts[0].isNotEmpty &&
          (double.tryParse(parts[1].replaceAll(',', '')) ?? -1) >= 0 &&
          DateTime.tryParse(parts[2]) != null;
    });
    return valid ? null : 'Use Bill | amount | YYYY-MM-DD on each line.';
  }
  if (field.format == 'goals') {
    final valid = trimmed.split('\n').every((line) {
      final parts = line.split('|').map((part) => part.trim()).toList();
      return parts.length == 5 &&
          parts[0].isNotEmpty &&
          (double.tryParse(parts[1].replaceAll(',', '')) ?? -1) >= 0 &&
          (double.tryParse(parts[2].replaceAll(',', '')) ?? 0) > 0 &&
          DateTime.tryParse(parts[3]) != null &&
          (int.tryParse(parts[4]) ?? 0) > 0;
    });
    return valid
        ? null
        : 'Use Goal | balance | target | YYYY-MM-DD | priority.';
  }
  if (field.format == 'cycle') {
    return RegExp(r'^(weekly|monthly|every\s+([1-9]|1[0-2])\s+weeks?)$',
                caseSensitive: false)
            .hasMatch(trimmed)
        ? null
        : 'Use Weekly, Every 1–12 weeks, or Monthly.';
  }
  return null;
}

class MonthlyIncomeScreen extends StatefulWidget {
  const MonthlyIncomeScreen({super.key});

  @override
  State<MonthlyIncomeScreen> createState() => _MonthlyIncomeScreenState();
}

class _MonthlyIncomeScreenState extends State<MonthlyIncomeScreen> {
  final formKey = GlobalKey<FormState>();
  final incomes = <_IncomeLedgerDraft>[];
  bool seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (seeded) return;
    final state = AppScope.of(context);
    if (state.onboardingIncomeLedger.isNotEmpty) {
      incomes
          .addAll(state.onboardingIncomeLedger.map(_IncomeLedgerDraft.fromMap));
    } else {
      final salary =
          state.monthlySalary > 0 ? state.monthlySalary : state.income;
      incomes.add(
        _IncomeLedgerDraft(
          name: 'Salary or main income',
          amount: salary > 0 ? salary.toStringAsFixed(0) : '',
          stable: state.incomeType.toLowerCase().contains('fixed'),
          scheduled: state.incomeRhythm.toLowerCase().contains('monthly'),
          payDay:
              state.incomeRhythm.toLowerCase().contains('monthly') ? 15 : null,
        ),
      );
    }
    if (incomes.isEmpty) incomes.add(_IncomeLedgerDraft());
    seeded = true;
  }

  @override
  void dispose() {
    for (final income in incomes) {
      income.dispose();
    }
    super.dispose();
  }

  void _addIncome() => setState(() => incomes.add(_IncomeLedgerDraft()));

  void _removeIncome(int index) {
    if (incomes.length == 1) return;
    setState(() => incomes.removeAt(index).dispose());
  }

  void _continue() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final state = AppScope.of(context);
    state.onboardingIncomeLedger
      ..clear()
      ..addAll(incomes.map((income) => income.toMap()));
    final total =
        incomes.fold<double>(0, (total, income) => total + income.amountValue);
    final stableTotal = incomes
        .where((income) => income.stable)
        .fold<double>(0, (total, income) => total + income.amountValue);
    final variableTotal = math.max(0.0, total - stableTotal);
    state.income = total;
    state.monthlySalary = stableTotal;
    state.irregularIncomeFloor = variableTotal;
    state.onboardingBaselines['income_baseline'] = total.toStringAsFixed(2);
    state.onboardingBaselines['stable_income'] = stableTotal.toStringAsFixed(2);
    state.onboardingBaselines['variable_income'] =
        variableTotal.toStringAsFixed(2);
    _push(context, const InitialBaselineScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      phase: 4,
      title: 'Monthly income.',
      subtitle:
          'List each expected monthly income source, mark whether it is stable, and add an expected pay day for scheduled income. This becomes Shellby’s starting income baseline.',
      bottom: PrimaryButton(
        label: 'Continue to Expenses',
        icon: Icons.arrow_forward_rounded,
        onPressed: _continue,
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _bellySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                '✓ Stable = predictable income   •   📅 Scheduled = expected on a regular pay day',
                style: TextStyle(
                  color: _body,
                  fontSize: 11,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < incomes.length; i++) ...[
              _IncomeLedgerCard(
                index: i,
                income: incomes[i],
                canRemove: incomes.length > 1,
                onChanged: () => setState(() {}),
                onRemove: () => _removeIncome(i),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: _addIncome,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add another income'),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeLedgerDraft {
  _IncomeLedgerDraft({
    String name = '',
    String amount = '',
    this.stable = false,
    this.scheduled = false,
    this.payDay,
  })  : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: amount);

  factory _IncomeLedgerDraft.fromMap(Map<String, dynamic> value) =>
      _IncomeLedgerDraft(
        name: value['name']?.toString() ?? '',
        amount: value['amount']?.toString() ?? '',
        stable: value['stable'] as bool? ?? false,
        scheduled: value['scheduled'] as bool? ?? false,
        payDay: (value['payDay'] as num?)?.toInt(),
      );

  final TextEditingController nameController;
  final TextEditingController amountController;
  bool stable;
  bool scheduled;
  int? payDay;

  double get amountValue =>
      double.tryParse(amountController.text.replaceAll(',', '')) ?? 0;

  Map<String, dynamic> toMap() => {
        'name': nameController.text.trim(),
        'amount': amountValue,
        'stable': stable,
        'scheduled': scheduled,
        'payDay': scheduled ? payDay : null,
      };

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class _IncomeLedgerCard extends StatelessWidget {
  const _IncomeLedgerCard({
    required this.index,
    required this.income,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final _IncomeLedgerDraft income;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tooltip(
                message: 'Stable income',
                child: Checkbox(
                  activeColor: _brand,
                  value: income.stable,
                  onChanged: (value) {
                    income.stable = value ?? false;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: TextFormField(
                  controller: income.nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: inputDecoration('Income source').copyWith(
                    labelText: 'Income',
                    isDense: true,
                  ),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Enter a source.' : null,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 112,
                child: TextFormField(
                  controller: income.amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: inputDecoration('Amount').copyWith(
                    labelText: 'Monthly',
                    prefixText: '₱ ',
                    isDense: true,
                  ),
                  validator: (value) {
                    final amount = double.tryParse(
                      (value ?? '').replaceAll(',', ''),
                    );
                    if (amount == null || amount <= 0) return 'Required';
                    if (amount > 100000000) return 'Too high';
                    return null;
                  },
                ),
              ),
              if (canRemove)
                IconButton(
                  tooltip: 'Remove income',
                  visualDensity: VisualDensity.compact,
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: _body,
                    size: 19,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                selected: income.scheduled,
                selectedColor: _purple.withValues(alpha: .12),
                checkmarkColor: _purple,
                avatar: Icon(
                  Icons.event_available_rounded,
                  size: 17,
                  color: income.scheduled ? _purple : _body,
                ),
                label: const Text('Scheduled income'),
                onSelected: (value) {
                  income.scheduled = value;
                  if (value) income.payDay ??= 15;
                  onChanged();
                },
              ),
              if (income.scheduled)
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<int>(
                    value: income.payDay,
                    isExpanded: true,
                    decoration: inputDecoration('Pay day').copyWith(
                      labelText: 'Expected pay day',
                      isDense: true,
                    ),
                    items: [
                      for (var day = 1; day <= 31; day++)
                        DropdownMenuItem(
                          value: day,
                          child: Text('Day $day monthly'),
                        ),
                    ],
                    onChanged: (value) {
                      income.payDay = value;
                      onChanged();
                    },
                    validator: (value) => income.scheduled && value == null
                        ? 'Choose a pay day.'
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class InitialBaselineScreen extends StatefulWidget {
  const InitialBaselineScreen({super.key});

  @override
  State<InitialBaselineScreen> createState() => _InitialBaselineScreenState();
}

class _InitialBaselineScreenState extends State<InitialBaselineScreen> {
  final formKey = GlobalKey<FormState>();
  final expenses = <_ExpenseLedgerDraft>[];
  bool seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (seeded) return;
    final state = AppScope.of(context);
    if (state.onboardingExpenseLedger.isNotEmpty) {
      expenses.addAll(
          state.onboardingExpenseLedger.map(_ExpenseLedgerDraft.fromMap));
    } else {
      expenses.addAll([
        _ExpenseLedgerDraft(name: 'Electric Bill', essential: true),
        _ExpenseLedgerDraft(name: 'Water Bill', essential: true),
        _ExpenseLedgerDraft(name: 'Food and Drinks', essential: true),
        _ExpenseLedgerDraft(name: 'Transport', essential: true),
      ]);
    }
    if (expenses.isEmpty) expenses.add(_ExpenseLedgerDraft());
    seeded = true;
  }

  @override
  void dispose() {
    for (final expense in expenses) {
      expense.dispose();
    }
    super.dispose();
  }

  void _addExpense() => setState(() => expenses.add(_ExpenseLedgerDraft()));

  void _removeExpense(int index) {
    if (expenses.length == 1) return;
    setState(() => expenses.removeAt(index).dispose());
  }

  void _continue() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final state = AppScope.of(context);
    state.onboardingExpenseLedger
      ..clear()
      ..addAll(expenses.map((expense) => expense.toMap()));
    final total = expenses.fold<double>(
        0, (total, expense) => total + expense.amountValue);
    final essentialTotal = expenses
        .where((expense) => expense.essential)
        .fold<double>(0, (total, expense) => total + expense.amountValue);
    state.onboardingBaselines['monthly_expenses'] = total.toStringAsFixed(2);
    state.onboardingBaselines['essential_expenses'] =
        essentialTotal.toStringAsFixed(2);
    _push(context, const PreparationOrientScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      phase: 5,
      title: 'Monthly expenses.',
      subtitle:
          'List each expected monthly expense, mark whether it is essential, and add an expected due day for scheduled bills. These values will change over time—this is just an initial baseline.',
      bottom: PrimaryButton(
          label: 'See How Shelby Helps',
          icon: Icons.arrow_forward_rounded,
          onPressed: _continue),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _bellySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                '✓ Essential = needed for basic living   •   📅 Scheduled = expected on a regular due day',
                style: TextStyle(
                  color: _body,
                  fontSize: 11,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < expenses.length; i++) ...[
              _ExpenseLedgerCard(
                index: i,
                expense: expenses[i],
                canRemove: expenses.length > 1,
                onChanged: () => setState(() {}),
                onRemove: () => _removeExpense(i),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: _addExpense,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add another expense'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseLedgerDraft {
  _ExpenseLedgerDraft(
      {String name = '',
      String amount = '',
      this.essential = false,
      this.scheduled = false,
      this.dueDay})
      : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: amount);

  factory _ExpenseLedgerDraft.fromMap(Map<String, dynamic> value) =>
      _ExpenseLedgerDraft(
        name: value['name']?.toString() ?? '',
        amount: value['amount']?.toString() ?? '',
        essential: value['essential'] as bool? ?? false,
        scheduled: value['scheduled'] as bool? ?? false,
        dueDay: (value['dueDay'] as num?)?.toInt(),
      );

  final TextEditingController nameController;
  final TextEditingController amountController;
  bool essential;
  bool scheduled;
  int? dueDay;

  double get amountValue =>
      double.tryParse(amountController.text.replaceAll(',', '')) ?? 0;

  Map<String, dynamic> toMap() => {
        'name': nameController.text.trim(),
        'amount': amountValue,
        'essential': essential,
        'scheduled': scheduled,
        'dueDay': scheduled ? dueDay : null,
      };

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class _ExpenseLedgerCard extends StatelessWidget {
  const _ExpenseLedgerCard(
      {required this.index,
      required this.expense,
      required this.canRemove,
      required this.onChanged,
      required this.onRemove});
  final int index;
  final _ExpenseLedgerDraft expense;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tooltip(
                message: 'Essential expense',
                child: Checkbox(
                  activeColor: _brand,
                  value: expense.essential,
                  onChanged: (value) {
                    expense.essential = value ?? false;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: TextFormField(
                  controller: expense.nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: inputDecoration('Expense name').copyWith(
                    labelText: 'Expense',
                    isDense: true,
                  ),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Enter a name.' : null,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 112,
                child: TextFormField(
                  controller: expense.amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: inputDecoration('Amount').copyWith(
                    labelText: 'Monthly',
                    prefixText: '₱ ',
                    isDense: true,
                  ),
                  validator: (value) {
                    final amount = double.tryParse(
                      (value ?? '').replaceAll(',', ''),
                    );
                    if (amount == null || amount <= 0) return 'Required';
                    if (amount > 1000000) return 'Too high';
                    return null;
                  },
                ),
              ),
              if (canRemove)
                IconButton(
                  tooltip: 'Remove expense',
                  visualDensity: VisualDensity.compact,
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: _body,
                    size: 19,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                selected: expense.scheduled,
                selectedColor: _purple.withValues(alpha: .12),
                checkmarkColor: _purple,
                avatar: Icon(
                  Icons.calendar_month_rounded,
                  size: 17,
                  color: expense.scheduled ? _purple : _body,
                ),
                label: const Text('Scheduled bill'),
                onSelected: (value) {
                  expense.scheduled = value;
                  if (value) expense.dueDay ??= 1;
                  onChanged();
                },
              ),
              if (expense.scheduled)
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<int>(
                    value: expense.dueDay,
                    isExpanded: true,
                    decoration: inputDecoration('Due day').copyWith(
                      labelText: 'Expected due day',
                      isDense: true,
                    ),
                    items: [
                      for (var day = 1; day <= 31; day++)
                        DropdownMenuItem(
                          value: day,
                          child: Text('Day $day monthly'),
                        ),
                    ],
                    onChanged: (value) {
                      expense.dueDay = value;
                      onChanged();
                    },
                    validator: (value) => expense.scheduled && value == null
                        ? 'Choose a due day.'
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class FakeMayaOnboardingScreen extends StatefulWidget {
  const FakeMayaOnboardingScreen({super.key});

  @override
  State<FakeMayaOnboardingScreen> createState() =>
      _FakeMayaOnboardingScreenState();
}

class _FakeMayaOnboardingScreenState extends State<FakeMayaOnboardingScreen> {
  Future<void> _link() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FakeMayaLoginSheet(),
    );
    if (!mounted) return;
    final state = AppScope.of(context);
    final summary = state.fakeMayaLink?.summary;
    if (summary != null) {
      state.onboardingBaselines.addAll({
        'cash_balance': summary.wallet.toStringAsFixed(2),
        'savings_balance':
            (summary.savings + summary.timeDeposit).toStringAsFixed(2),
        'emergency_balance': summary.savings.toStringAsFixed(2),
        'investment_balance': summary.timeDeposit.toStringAsFixed(2),
        'goals':
            '${summary.goalName} | ${summary.goalBalance.toStringAsFixed(2)} | ${summary.goalTarget.toStringAsFixed(2)} | ${DateTime.now().add(const Duration(days: 180)).toIso8601String().split('T').first} | 1',
      });
      await state.saveProfile();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final linked = state.fakeMayaLink;
    return OnboardingScaffold(
      phase: 10,
      title: 'Link FakeMaya.',
      subtitle:
          'Linking imports hard starting balances and future transactions. You can continue manually if you prefer.',
      bottom: PrimaryButton(
        label:
            linked == null ? 'Continue Without Linking' : 'Use Linked Balances',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const AppPermissionScreen()),
      ),
      child: AppCard(
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                  color: Color(0xFF00B14F), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Text('m',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 12),
            Text(
                linked == null
                    ? 'No FakeMaya account linked'
                    : 'Linked as ${linked.name}',
                style: const TextStyle(
                    color: _title, fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(
              linked == null
                  ? 'Shellby can sync wallet, savings, time deposit, goal balances, and transactions.'
                  : 'Starting balances were updated from FakeMaya. You can revise estimates later.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _body, height: 1.35, fontWeight: FontWeight.w700),
            ),
            if (linked != null) ...[
              const SizedBox(height: 16),
              _FakeMayaBalanceGrid(summary: linked.summary),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Synced accounts',
                  style: TextStyle(
                    color: _title,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _FakeMayaAccountList(summary: linked.summary),
            ],
            const SizedBox(height: 16),
            PrimaryButton(
              label: linked == null
                  ? 'Link FakeMaya Account'
                  : 'Relink FakeMaya Account',
              icon: Icons.account_balance_rounded,
              onPressed: _link,
            ),
          ],
        ),
      ),
    );
  }
}

class AppPermissionScreen extends StatefulWidget {
  const AppPermissionScreen({super.key});

  @override
  State<AppPermissionScreen> createState() => _AppPermissionScreenState();
}

class _AppPermissionScreenState extends State<AppPermissionScreen> {
  bool busy = false;

  Future<void> _allow() async {
    if (busy) return;
    setState(() => busy = true);
    var notificationGranted = false;
    try {
      final status = await Permission.notification.request();
      notificationGranted = status.isGranted;
    } catch (_) {
      notificationGranted = false;
    }
    if (!mounted) return;
    AppScope.of(context).acceptAppPermissions(
      notificationGranted: notificationGranted,
    );
    _push(context, const PersonalDataConsentScreen());
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      phase: 11,
      title: 'App permissions.',
      subtitle:
          'Shellby will ask before using phone features or connecting outside data sources.',
      bottom: PrimaryButton(
        label: busy ? 'Requesting...' : 'Allow',
        icon: Icons.notifications_active_rounded,
        enabled: !busy,
        onPressed: _allow,
      ),
      child: const Column(
        children: [
          PermissionInfoCard(
            icon: Icons.notifications_active_rounded,
            title: 'Notifications',
            body:
                'Used for payday reminders, bill-day nudges, check-ins, missed contribution alerts, and goal progress prompts.',
          ),
          SizedBox(height: 12),
          PermissionInfoCard(
            icon: Icons.account_balance_rounded,
            title: 'Third Party Data Linking',
            body:
                'Used for FakeMaya and any external bank or e-wallet you explicitly choose to connect.',
          ),
          SizedBox(height: 12),
          PermissionInfoCard(
            icon: Icons.sync_rounded,
            title: 'Automatic Data Gathering',
            body:
                'Used to update allowed financial data automatically instead of asking you to enter every item by hand.',
          ),
        ],
      ),
    );
  }
}

class PersonalDataConsentScreen extends StatelessWidget {
  const PersonalDataConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 12,
      title: 'Personal data consent.',
      subtitle:
          'Shellby collects only the specific data needed to build and track your plan.',
      bottom: PrimaryButton(
        label: 'I Agree',
        icon: Icons.check_circle_rounded,
        onPressed: () {
          state.acceptPersonalDataConsent();
          _push(context, const DataRetentionConsentScreen());
        },
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              children: [
                ConsentDataRow(
                  label: 'Account details',
                  value: 'Name, email address, user ID, and profile photo.',
                ),
                ConsentDataRow(
                  label: 'Profile context',
                  value:
                      'Age or life stage, occupation, industry, employment status, and financial responsibility.',
                ),
                ConsentDataRow(
                  label: 'Money rhythm',
                  value:
                      'Income type, income schedule, bill schedule, and check-in rhythm.',
                ),
                ConsentDataRow(
                  label: 'Conversation answers',
                  value:
                      'Selected motivation, Surface response, goal, actions, specifics, helpful situations, and expected hurdles.',
                ),
                ConsentDataRow(
                  label: 'Starting baseline and plan',
                  value:
                      'The one-time balances, averages, bills, categories, debts, investments, or goal inventory required by your selected actions.',
                ),
                ConsentDataRow(
                  label: 'Permissions and consent',
                  value:
                      'Notification choice, future data-linking permission, automatic data-gathering permission, personal data consent, and data retention consent.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DataRetentionConsentScreen extends StatelessWidget {
  const DataRetentionConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 13,
      title: 'Data retention.',
      subtitle:
          'Your data stays available only while it is needed for your Shellby account and financial plan.',
      bottom: PrimaryButton(
        label: 'I Agree',
        icon: Icons.check_circle_rounded,
        onPressed: () {
          state.acceptDataRetentionConsent();
          _push(context, const PreparationCommitmentScreen());
        },
      ),
      child: const Column(
        children: [
          PermissionInfoCard(
            icon: Icons.schedule_rounded,
            title: 'How long data is kept',
            body:
                'Shellby keeps your account, onboarding, consent, goal, and financial tracking data while your account is active so your plan can continue across sessions.',
          ),
          SizedBox(height: 12),
          PermissionInfoCard(
            icon: Icons.restart_alt_rounded,
            title: 'Reset control',
            body:
                'You can reset your conversation, goal details, consent choices, or other stored data from the Settings menu.',
          ),
          SizedBox(height: 12),
          PermissionInfoCard(
            icon: Icons.delete_outline_rounded,
            title: 'Deletion control',
            body:
                'If you delete your account, Shellby will remove your stored profile and app data except records that must be kept for legal or security reasons.',
          ),
        ],
      ),
    );
  }
}

class PermissionInfoCard extends StatelessWidget {
  const PermissionInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBubble(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: _body,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConsentDataRow extends StatelessWidget {
  const ConsentDataRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_rounded, color: _brand, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: _body,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlanStepRow extends StatelessWidget {
  const PlanStepRow({super.key, required this.step});

  final ({IconData icon, String title, String body}) step;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: _surface,
            shape: BoxShape.circle,
          ),
          child: Icon(step.icon, color: _brand, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: const TextStyle(
                  color: _title,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                step.body,
                style: const TextStyle(
                  color: _body,
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _optionSummaryForStep(int stepIndex, GuidedOption option) {
  final phrase = switch (stepIndex) {
    0 => _surfaceSummaryPhrase(option),
    1 => _focusSummaryPhrase(option),
    2 => _timeframeSummaryPhrase(option),
    3 => _difficultySummaryPhrase(option),
    _ => _cleanOptionText(option.text),
  };
  if (phrase.isEmpty) return '';
  return phrase[0].toUpperCase() + phrase.substring(1);
}

String _surfaceSummaryPhrase(GuidedOption option) {
  return switch (_cleanOptionText(option.text)) {
    'I keep meaning to check my spending, but the habit slips when life gets busy' =>
      'checking your spending gets harder when life gets busy',
    'I notice extra purchases around weekends, payday, or certain stores' =>
      'extra purchases tend to show up around specific days, paydays, or stores',
    'I feel thrown off when bills, income, or timing do not line up' =>
      'bills, income, or timing can throw your plan off',
    'I save a little, but regular expenses keep pulling that money back out' =>
      'regular expenses keep pulling money back out of savings',
    'Surprise expenses or due dates disrupt my monthly plan' =>
      'surprise expenses or due dates disrupt your monthly plan',
    'I want a cushion, but I need help making saving feel automatic' =>
      'you want saving to feel more automatic',
    'Debt payments keep taking up budget space every month' =>
      'debt payments keep taking up budget space',
    'I want to start investing, but I have not completed the setup steps' =>
      'starter investing still needs clear setup steps',
    'When more money comes in, it seems to disappear into more spending' =>
      'extra income can disappear into extra spending',
    'I have several things I care about, and it is hard to know what to fund first' =>
      'you have several meaningful goals competing for attention',
    'I want to save for something meaningful without messing up my bills' =>
      'you want to fund something meaningful while keeping bills steady',
    'I spend on hobbies or travel without a clear funded bucket' =>
      'hobby or travel spending needs its own funded bucket',
    final value => value.toLowerCase(),
  };
}

String _focusSummaryPhrase(GuidedOption option) {
  return switch (option.goalTitle) {
    'Expense Tracking Routine' =>
      'remembering to track your spending and keep momentum',
    'Spending Trigger Tracker' => 'tracking repeat spending triggers',
    'Irregular Income Buffer' =>
      'how unexpected bills or changing income cycles disrupt your plans',
    'Safety Shield Boundary' => 'protecting your savings from regular expenses',
    'Bill Due-Date Buffer' => 'building a buffer around upcoming bills',
    'Payday Safety Sweep' => 'setting money aside consistently on your own',
    'Debt Payoff Map' =>
      'building a clear strategy to pay down your existing debts',
    'Starter Investing Habit' =>
      'completing starter investing setup steps and contributions',
    'Lifestyle Creep Monitor' =>
      'keeping spending steady when your income increases',
    'Milestone Bucket Plan' =>
      'balancing multiple future milestones at the same time',
    'Future Lifestyle Fund' =>
      'saving for one major milestone while keeping regular bills covered',
    'Planned Experience Fund' =>
      'planning hobbies and travel from a funded bucket',
    _ => _cleanOptionText(option.text),
  };
}

String _timeframeSummaryPhrase(GuidedOption option) {
  return switch (_cleanOptionText(option.text)) {
    '1 Month' => '1 month',
    '3 Months' => '3 months',
    '6 Months' => '6 months',
    '1 Year' => '1 year',
    '2 Years+' => '2+ years',
    '1 to 3 Months' => '1 to 3 months',
    final value => value.toLowerCase(),
  };
}

String _difficultySummaryPhrase(GuidedOption option) {
  return switch (_cleanOptionText(option.text)) {
    'Relaxed Pace' => 'a relaxed pace',
    'Balanced Pace' => 'a balanced pace',
    'High Focus Pace' => 'a high-focus pace',
    'Conservative Pace' => 'a conservative pace',
    'Aggressive Pace' => 'an aggressive pace',
    'Safe & Slow' => 'a safe and slow pace',
    'Intentional' => 'an intentional approach',
    'Lifestyle First' => 'a lifestyle-first approach',
    final value => value.toLowerCase(),
  };
}

String _cleanOptionText(String value) {
  final trimmed = value.trim();
  return trimmed.endsWith('.')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
}

String _joinSummaryValues(List<String> values) {
  if (values.length <= 1) return values.join();
  if (values.length == 2) return '${values.first} and ${values.last}';
  return '${values.sublist(0, values.length - 1).join(', ')}, and ${values.last}';
}

// Kept for the legacy recommendation helpers used by older saved flows.
// ignore: unused_element
GoalConcern? _concernForGoalTitle(GoalBranch branch, String? goalTitle) {
  if (goalTitle == null) return null;
  for (final concern in branch.concerns) {
    if (concern.goalTitle == goalTitle) return concern;
  }
  return null;
}

void _applyRecommendedConcern(AppState state, GoalConcern concern) {
  state.setRecommendedGoal(
    title: concern.goalTitle,
    description: concern.goalDescription,
    monthlyTarget: _monthlyTargetForConcern(state, concern),
  );
  state.configureGoalActions(
    actionIds: concern.actionIds,
    enableEmotionalLogs: concern.enableEmotionalLogs,
    enableStressIndicators: concern.enableStressIndicators,
  );
}

String _optionSummaryForGoalTitle(String layer, String goalTitle) {
  final pathway = _pathwayForLayer(layer);
  for (final option in pathway.steps[1].options) {
    if (option.goalTitle == goalTitle) return _optionSummaryForStep(1, option);
  }
  return goalTitle;
}

class GuidedSummaryCard extends StatefulWidget {
  const GuidedSummaryCard({super.key, required this.state});

  final AppState state;

  @override
  State<GuidedSummaryCard> createState() => _GuidedSummaryCardState();
}

class _GuidedSummaryCardState extends State<GuidedSummaryCard> {
  AppState get state => widget.state;

  GuidedPathway get pathway => _pathwayForLayer(state.primaryConcern);

  List<D2Action> get selectedActions => state.selectedActionIds
      .map((id) => _d2Actions[id])
      .whereType<D2Action>()
      .toList();

  String _actionDetails(D2Action action) {
    final values =
        state.actionFieldValues[action.id] ?? const <String, String>{};
    final details = <String>[];
    for (final field in action.fields) {
      final value = values[field.key]?.trim() ?? '';
      if (value.isEmpty) continue;
      details.add('${field.label}: ${_fieldValueLabel(field, value)}');
    }
    if (details.isNotEmpty) return details.join(' • ');
    return action.hasFields
        ? 'No details entered'
        : 'No additional details required';
  }

  GuidedOption _selectedOption(int stepIndex, String summary) {
    final options = pathway.steps[stepIndex].options;
    for (final option in options) {
      if (_optionSummaryForStep(stepIndex, option) == summary) return option;
    }
    return options.first;
  }

  // stepIndex 1 = Situations (pathway.steps[1]), stepIndex 2 = Challenges (pathway.steps[2])
  List<GuidedOption> _selectedMultiOptions(int stepIndex, String summary) {
    final options = pathway.steps[stepIndex].options;
    final normalized = summary.toLowerCase();
    final selected = options
        .where((option) =>
            normalized.contains(_cleanOptionText(option.text).toLowerCase()))
        .toList();
    return selected.isEmpty ? [options.first] : selected;
  }

  void _updateSurface(GuidedOption option) {
    setState(() {
      state.updateGuidedChatSummary(surface: _optionSummaryForStep(0, option));
    });
  }

  Future<void> _editGoal(BuildContext context) async {
    final goalIds = _motivationGoalIds[pathway.layer] ?? const ['G1'];
    final goals = goalIds.map(_d1GoalById).toList();
    final selected = await showModalBottomSheet<D1Goal>(
      context: context,
      backgroundColor: _surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
          children: [
            const Text('Specify',
                style: TextStyle(
                    color: _title, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            for (final goal in goals)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: Text(goal.title,
                    style: const TextStyle(
                        color: _title, fontWeight: FontWeight.w900)),
                subtitle: Text(goal.description,
                    style: const TextStyle(
                        color: _body, fontWeight: FontWeight.w700)),
                trailing: goal.id == state.selectedGoalId
                    ? const Icon(Icons.check_circle_rounded, color: _brand)
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(goal),
              ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    final actionIds = _goalActionIds[selected.id] ?? const <String>[];
    final initialValues = <String, Map<String, String>>{
      for (final id in actionIds)
        if ((_d2Actions[id]?.hasFields ?? false))
          id: _initialActionFieldValues(state, _d2Actions[id]!),
    };
    setState(() {
      state.selectedGoalId = selected.id;
      state.setRecommendedGoal(
          title: selected.title,
          description: selected.description,
          monthlyTarget: 0);
      state.configureGoalActions(actionIds: actionIds);
      state.actionFieldValues
        ..clear()
        ..addAll(initialValues);
      state.updateGuidedChatSummary(goalFocus: selected.title);
    });
    await state.saveProfile();
  }

  Future<void> _editActions(BuildContext context) async {
    final actionIds = _goalActionIds[state.selectedGoalId] ?? const <String>[];
    final options =
        actionIds.map((id) => _d2Actions[id]).whereType<D2Action>().toList();
    final chosen = state.selectedActionIds.toSet();
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: _surface,
          title: const Text('Selected actions',
              style: TextStyle(color: _title, fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final action in options)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: _brand,
                    value: chosen.contains(action.id),
                    title: Text('${action.id}: ${action.text}',
                        style: const TextStyle(
                            color: _title, fontWeight: FontWeight.w800)),
                    onChanged: (value) => setDialogState(() {
                      if (value ?? false) {
                        chosen.add(action.id);
                      } else {
                        chosen.remove(action.id);
                      }
                    }),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: chosen.isEmpty
                  ? null
                  : () => Navigator.of(dialogContext).pop(chosen),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result == null || result.isEmpty) return;
    setState(() {
      state.configureGoalActions(actionIds: actionIds.where(result.contains));
      state.actionFieldValues.removeWhere((id, _) => !result.contains(id));
      for (final id in result) {
        final action = _d2Actions[id];
        if (action == null || !action.hasFields) continue;
        state.actionFieldValues.putIfAbsent(
          id,
          () => _initialActionFieldValues(state, action),
        );
      }
    });
    await state.saveProfile();
  }

  Future<void> _editActionDetails(BuildContext context, D2Action action) async {
    if (!action.hasFields) return;
    final existing =
        state.actionFieldValues[action.id] ?? const <String, String>{};
    final values = _initialActionFieldValues(state, action, existing);
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: _surface,
          title: Text('${action.id} details',
              style:
                  const TextStyle(color: _title, fontWeight: FontWeight.w900)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final field in action.fields) ...[
                    ActionFieldSelector(
                      field: field,
                      initialValue: values[field.key] ?? '',
                      recommendations:
                          _recommendationsForActionField(state, action, field),
                      onChanged: (value) =>
                          setDialogState(() => values[field.key] = value),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: action.fields.every((field) =>
                      _actionFieldError(field, values[field.key] ?? '') == null)
                  ? () => Navigator.of(dialogContext)
                      .pop(Map<String, String>.from(values))
                  : null,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    setState(() => state.actionFieldValues[action.id] = result);
    await state.saveProfile();
  }

  Future<void> _editMulti({
    required BuildContext context,
    required int stepIndex,
    required String title,
    required List<GuidedOption> selected,
  }) async {
    final options = pathway.steps[stepIndex].options;
    final chosen = selected.toSet();
    final result = await showDialog<List<GuidedOption>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: _surface,
              title: Text(
                title,
                style: const TextStyle(
                  color: _title,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: options
                    .map(
                      (option) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: _brand,
                        value: chosen.contains(option),
                        title: Text(
                          option.text,
                          style: const TextStyle(
                            color: _title,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: option.detail == null
                            ? null
                            : Text(
                                option.detail!,
                                style: const TextStyle(
                                  color: _body,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                        onChanged: (value) {
                          setDialogState(() {
                            if (value ?? false) {
                              chosen.add(option);
                            } else {
                              chosen.remove(option);
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: chosen.isEmpty
                      ? null
                      : () => Navigator.of(dialogContext).pop(chosen.toList()),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result == null || result.isEmpty) return;
    final summary = _joinSummaryValues(
      result.map((option) => _cleanOptionText(option.text)).toList(),
    );
    setState(() {
      // stepIndex 1 = Situations, stepIndex 2 = Challenges
      if (stepIndex == 1) {
        state.updateGuidedChatSummary(situations: summary);
      } else if (stepIndex == 2) {
        state.updateGuidedChatSummary(challenges: summary);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final surface = _selectedOption(0, state.chatSurfaceSummary);
    final situations = _selectedMultiOptions(1, state.chatSituationsSummary);
    final challenges = _selectedMultiOptions(2, state.chatChallengesSummary);
    final actions = selectedActions;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              IconBubble(Icons.forum_rounded),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'What you told Shellby',
                  style: TextStyle(
                    color: _title,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GuidedSummaryOptionRow(
            icon: Icons.lightbulb_rounded,
            label: 'Surface',
            value: _cleanOptionText(surface.text),
            options: pathway.steps[0].options,
            onChanged: _updateSurface,
          ),
          const SizedBox(height: 10),
          GuidedSummaryEditRow(
            icon: Icons.flag_rounded,
            label: 'Specify',
            value: state.selectedGoal,
            onTap: () => _editGoal(context),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 10),
            GuidedSummaryEditRow(
              icon: Icons.checklist_rounded,
              label: 'Selected actions',
              value: actions
                  .map((action) => '${action.id}: ${action.text}')
                  .join('\n'),
              onTap: () => _editActions(context),
            ),
            for (final action
                in actions.where((action) => action.hasFields)) ...[
              const SizedBox(height: 10),
              GuidedSummaryEditRow(
                icon: Icons.tune_rounded,
                label: '${action.id} details',
                value: _actionDetails(action),
                onTap: () => _editActionDetails(context, action),
              ),
            ],
          ],
          const SizedBox(height: 10),
          GuidedSummaryEditRow(
            icon: Icons.notifications_active_rounded,
            label: 'Useful reminders',
            value: _joinSummaryValues(
              situations
                  .map((option) => _cleanOptionText(option.text))
                  .toList(),
            ),
            onTap: () => _editMulti(
              context: context,
              stepIndex: 1,
              title: 'Useful reminders',
              selected: situations,
            ),
          ),
          const SizedBox(height: 10),
          GuidedSummaryEditRow(
            icon: Icons.warning_rounded,
            label: 'Hurdles to watch',
            value: _joinSummaryValues(
              challenges
                  .map((option) => _cleanOptionText(option.text))
                  .toList(),
            ),
            onTap: () => _editMulti(
              context: context,
              stepIndex: 2,
              title: 'Hurdles to watch',
              selected: challenges,
            ),
          ),
        ],
      ),
    );
  }
}

class GuidedSummaryOptionRow extends StatelessWidget {
  const GuidedSummaryOptionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String value;
  final List<GuidedOption> options;
  final ValueChanged<GuidedOption> onChanged;

  Future<void> _showOptions(BuildContext context) async {
    final selected = await showModalBottomSheet<GuidedOption>(
      context: context,
      backgroundColor: _surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ...options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.of(sheetContext).pop(option),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border),
                        ),
                        child: Text(
                          option.displayText,
                          style: const TextStyle(
                            color: _title,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showOptions(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _brand, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _body,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      color: _title,
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: _purple, size: 20),
          ],
        ),
      ),
    );
  }
}

class GuidedSummaryEditRow extends StatelessWidget {
  const GuidedSummaryEditRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _brand, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _body,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      color: _title,
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.edit_rounded, color: _purple, size: 17),
            ],
          ],
        ),
      ),
    );
  }
}

String _summaryFallback(String value, String fallback) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

// Kept for compatibility with older goal-title based plans.
// ignore: unused_element
List<({IconData icon, String title, String body})> _planStepsForGoal(
  AppState state,
) {
  final targetRule = _targetRuleForGoal(state).toLowerCase();
  return switch (state.selectedGoal) {
    'Expense Tracking Routine' => [
        (
          icon: Icons.receipt_long_rounded,
          title: 'Start with a simple log',
          body:
              'Record income and expenses on your chosen check-in rhythm so the app can build a reliable baseline.',
        ),
        (
          icon: Icons.notifications_active_rounded,
          title: 'Use reminders',
          body:
              'Let Shellby remind you around the moments you selected in the chat.',
        ),
        (
          icon: Icons.insights_rounded,
          title: 'Review the pattern',
          body:
              'After the cycle, compare planned spending with what actually happened.',
        ),
      ],
    'Spending Trigger Tracker' => [
        (
          icon: Icons.sell_rounded,
          title: 'Tag repeat triggers',
          body:
              'When logging expenses, tag useful context like category, store, day, and payday timing.',
        ),
        (
          icon: Icons.warning_rounded,
          title: 'Watch budget leaks',
          body:
              'Shellby will flag spending that rises above your usual daily average or selected trigger pattern.',
        ),
        (
          icon: Icons.tune_rounded,
          title: 'Adjust one rule',
          body:
              'Pick one spending rule to test during the first cycle instead of changing everything at once.',
        ),
      ],
    'Irregular Income Buffer' => [
        (
          icon: Icons.calendar_month_rounded,
          title: 'Plan from low-income months',
          body:
              'Use conservative income estimates so fixed bills stay covered when income changes.',
        ),
        (
          icon: Icons.savings_rounded,
          title: 'Build a buffer',
          body:
              'Start with $targetRule, then convert it to an amount after the financial baseline.',
        ),
        (
          icon: Icons.sync_alt_rounded,
          title: 'Update after each payday',
          body:
              'Adjust the month plan whenever actual income lands higher or lower than expected.',
        ),
      ],
    'Bill Due-Date Buffer' => [
        (
          icon: Icons.event_available_rounded,
          title: 'Map upcoming due dates',
          body:
              'List the bills that usually disrupt your plan and sort them by due date.',
        ),
        (
          icon: Icons.account_balance_wallet_rounded,
          title: 'Reserve before bills hit',
          body:
              'Use $targetRule as the first buffer rule until actual bills and income are entered.',
        ),
        (
          icon: Icons.notifications_active_rounded,
          title: 'Flag shortfalls early',
          body:
              'Shellby will warn you before a bill date if the reserved amount is not enough.',
        ),
      ],
    'Starter Investing Habit' => [
        (
          icon: Icons.checklist_rounded,
          title: 'Complete the starter checklist',
          body:
              'Track basic setup steps before focusing on larger contribution targets.',
        ),
        (
          icon: Icons.repeat_rounded,
          title: 'Set a small recurring habit',
          body:
              'Use $targetRule as the first draft contribution rule until the financial baseline is added.',
        ),
        (
          icon: Icons.show_chart_rounded,
          title: 'Review monthly consistency',
          body:
              'The app will track whether the habit happened, not just the ending balance.',
        ),
      ],
    'Planned Experience Fund' => [
        (
          icon: Icons.flag_rounded,
          title: 'Create one funded bucket',
          body:
              'Choose the hobby, travel, or experience bucket that should be funded first.',
        ),
        (
          icon: Icons.savings_rounded,
          title: 'Set the allocation',
          body:
              'Use $targetRule as the first funding rule until the app can calculate an exact amount.',
        ),
        (
          icon: Icons.verified_rounded,
          title: 'Spend only when ready',
          body:
              'Shellby will treat the bucket as ready once the selected condition is met.',
        ),
      ],
    'Debt Payoff Map' => [
        (
          icon: Icons.list_alt_rounded,
          title: 'Add debt details',
          body:
              'Record balances, due dates, minimum payments, and interest if available.',
        ),
        (
          icon: Icons.payments_rounded,
          title: 'Choose the payoff amount',
          body:
              'Start with $targetRule, then calculate the amount after debt details are entered.',
        ),
        (
          icon: Icons.trending_down_rounded,
          title: 'Track balance movement',
          body:
              'Review whether balances are actually shrinking after each payment cycle.',
        ),
      ],
    'Lifestyle Creep Monitor' => [
        (
          icon: Icons.price_check_rounded,
          title: 'Lock the current baseline',
          body:
              'Save your current fixed and variable spending before income changes.',
        ),
        (
          icon: Icons.trending_up_rounded,
          title: 'Watch new expenses',
          body:
              'Shellby will flag fixed expenses that rise after a raise or income increase.',
        ),
        (
          icon: Icons.savings_rounded,
          title: 'Route extra income',
          body:
              'Decide where new surplus should go before it blends into regular spending.',
        ),
      ],
    _ => [
        (
          icon: Icons.flag_rounded,
          title: 'Define the target',
          body:
              'Use the recommended goal as the first measurable outcome Shellby will track.',
        ),
        (
          icon: Icons.savings_rounded,
          title: 'Set the first allocation',
          body:
              'Start with $targetRule, then convert it to an amount after the baseline is added.',
        ),
        (
          icon: Icons.fact_check_rounded,
          title: 'Review progress',
          body:
              'Check whether the plan is working before increasing difficulty.',
        ),
      ],
  };
}

String _targetRuleForGoal(AppState state) {
  if (state.selectedGoal == 'Irregular Income Buffer') {
    return state.needsTarget > 0
        ? 'Fill ${money(state.needsTarget)} Needs first, then ${100 - state.needsPercent}% of each peso builds Buffer'
        : 'Set your monthly survival amount on the Goals page to activate the two-jar system';
  }
  if (state.monthlySalary > 0) {
    return 'Allocate 10% of monthly salary';
  }

  final pace = state.chatDifficultySummary.toLowerCase();
  final relaxed = pace.contains('relaxed') ||
      pace.contains('safe and slow') ||
      pace.contains('conservative');
  final high = pace.contains('high-focus') ||
      pace.contains('aggressive') ||
      pace.contains('lifestyle-first');

  return switch (state.selectedGoal) {
    'Expense Tracking Routine' ||
    'Spending Trigger Tracker' ||
    'Cash Flow Stability Plan' =>
      high
          ? 'Keep spending under 50% of net income'
          : relaxed
              ? 'Keep spending under 90% of net income'
              : 'Keep spending under 75% of net income',
    'Safety Shield Boundary' ||
    'Bill Due-Date Buffer' ||
    'Payday Safety Sweep' ||
    'Emergency Cushion' =>
      high
          ? 'Save 20% of incoming funds'
          : relaxed
              ? 'Save 5% of incoming funds'
              : 'Save 10% of incoming funds',
    'Debt Payoff Map' => high
        ? 'Put most leftover cash toward debt'
        : relaxed
            ? 'Pay minimums plus a fixed extra amount'
            : 'Split extra cash between debt payoff and savings',
    'Starter Investing Habit' => high
        ? 'Invest up to 20% of available surplus'
        : relaxed
            ? 'Start with 5% of available surplus'
            : 'Start with 10% of available surplus',
    'Lifestyle Creep Monitor' => high
        ? 'Route most new income to goals'
        : relaxed
            ? 'Route 5% of new income to goals'
            : 'Route 10% of new income to goals',
    'Milestone Bucket Plan' ||
    'Planned Experience Fund' ||
    'Shared Future Alignment' ||
    'Future Lifestyle Fund' =>
      high
          ? 'Allocate 20% of monthly income to buckets'
          : relaxed
              ? 'Allocate 5% of monthly income to buckets'
              : 'Allocate 10% of monthly income to buckets',
    _ => high
        ? 'Start with 20% of monthly income'
        : relaxed
            ? 'Start with 5% of monthly income'
            : 'Start with 10% of monthly income',
  };
}

String _firstTrackingActionForGoal(String selectedGoal) {
  return switch (selectedGoal) {
    'Expense Tracking Routine' ||
    'Spending Trigger Tracker' ||
    'Irregular Income Buffer' ||
    'Cash Flow Stability Plan' =>
      'Log income and expenses',
    'Bill Due-Date Buffer' ||
    'Safety Shield Boundary' ||
    'Payday Safety Sweep' ||
    'Emergency Cushion' =>
      'Set the first buffer amount',
    'Debt Payoff Map' => 'Add debt balances and due dates',
    'Starter Investing Habit' ||
    'Lifestyle Creep Monitor' ||
    'Net Worth Growth Plan' =>
      'Record a saving or investing habit',
    'Milestone Bucket Plan' ||
    'Planned Experience Fund' ||
    'Shared Future Alignment' ||
    'Future Lifestyle Fund' =>
      'Create a milestone bucket',
    _ => 'Add the first tracking action',
  };
}

IconData _goalIconFor(String selectedGoal) {
  for (final branch in _goalBranches) {
    if (branch.defaultGoalTitle == selectedGoal ||
        branch.concerns.any((concern) => concern.goalTitle == selectedGoal)) {
      return branch.icon;
    }
  }
  return Icons.flag_rounded;
}

class GoalFeasibilityScreen extends StatelessWidget {
  const GoalFeasibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final score = state.feasibilityScore.round();
    return OnboardingScaffold(
      phase: 13,
      title: 'Feasibility check.',
      subtitle:
          'A goal should be specific and challenging, but still realistic for your cash flow and confidence level.',
      centerTitle: true,
      bottom: PrimaryButton(
        label: 'Preview Health Index',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const PyramidPreviewScreen()),
      ),
      child: Column(
        children: [
          const Ghost(size: 104, mood: GhostMood.thinking),
          const SizedBox(height: 18),
          GoalCard(
            title: state.selectedGoal,
            description: state.selectedGoalDescription,
            progress: score,
            icon: _goalIconFor(state.selectedGoal),
            tag: score >= 75
                ? 'Strong fit'
                : score >= 50
                    ? 'Adjustable'
                    : 'Needs care',
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                SummaryRow('Monthly surplus', money(state.monthlySurplus)),
                SummaryRow(
                  'Required allocation',
                  money(state.requiredMonthlyContribution),
                ),
                SummaryRow(
                  'Savings rate',
                  '${state.savingsRate.toStringAsFixed(1)}%',
                ),
                SummaryRow(
                  'Debt-to-income',
                  '${state.debtToIncome.toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PyramidPreviewScreen extends StatelessWidget {
  const PyramidPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 14,
      title: 'Preview your OT2 index.',
      subtitle:
          'This is Shellby’s first read on your financial pyramid before regular tracking begins.',
      bottom: PrimaryButton(
        label: 'Choose Sharing Structure',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const SocialStructureScreen()),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const FinancialPyramid(),
              Positioned(
                right: 0,
                top: -12,
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Health Score', style: sliderCaption),
                      Text(
                        '${state.healthScore.round()}',
                        style: const TextStyle(
                          color: _brand,
                          fontSize: 40,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              children: [
                SummaryRow(
                  'Sustenance',
                  '${state.savingsRate.toStringAsFixed(1)}% saved',
                ),
                SummaryRow(
                  'Protection',
                  '${state.emergencyMonths.toStringAsFixed(1)} months',
                ),
                SummaryRow(
                  'Borrowing pressure',
                  '${state.debtToIncome.toStringAsFixed(1)}% DTI',
                ),
                SummaryRow(
                  'Mindset',
                  'Confidence ${state.confidence.round()} / Pressure ${state.anxiety.round()}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConsentPrivacyScreen extends StatefulWidget {
  const ConsentPrivacyScreen({super.key});

  @override
  State<ConsentPrivacyScreen> createState() => _ConsentPrivacyScreenState();
}

class _ConsentPrivacyScreenState extends State<ConsentPrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 12,
      title: 'Choose data permissions.',
      subtitle:
          'Consent is tied to your goal. Essential data powers your plan; optional data expands AI and cooperative features.',
      bottom: PrimaryButton(
        label: 'Choose Sharing Structure',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const SocialStructureScreen()),
      ),
      child: Column(
        children: [
          ConsentToggle(
            title: 'Financial baseline',
            body: 'Required for health score, feasibility, and goal tracking.',
            value: state.consentBaseline,
            locked: true,
            onChanged: (_) {},
          ),
          ConsentToggle(
            title: 'AI analysis',
            body:
                'Use your baseline and goal to generate plain-language nudges.',
            value: state.consentAi,
            onChanged: (value) => setState(() => state.consentAi = value),
          ),
          ConsentToggle(
            title: 'Anonymous peer benchmarks',
            body:
                'Compare against similar life-stage groups without showing identity.',
            value: state.consentBenchmarking,
            onChanged: (value) =>
                setState(() => state.consentBenchmarking = value),
          ),
          ConsentToggle(
            title: 'Community feedback',
            body: 'Let Shellby use posts and votes with your selected context.',
            value: state.consentCommunity,
            onChanged: (value) =>
                setState(() => state.consentCommunity = value),
          ),
          ConsentToggle(
            title: 'Trusted circle sharing',
            body:
                'Allow selected friends or collaborators to see chosen summaries.',
            value: state.consentTrustedCircle,
            onChanged: (value) =>
                setState(() => state.consentTrustedCircle = value),
          ),
        ],
      ),
    );
  }
}

class SocialStructureScreen extends StatefulWidget {
  const SocialStructureScreen({super.key});

  @override
  State<SocialStructureScreen> createState() => _SocialStructureScreenState();
}

class _SocialStructureScreenState extends State<SocialStructureScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final options = [
      (
        'Private only',
        'Only you see your goals, score, and financial details.',
        Icons.lock_rounded,
      ),
      (
        'Anonymous peer benchmarks',
        'See percentiles and norms without exposing your identity.',
        Icons.groups_rounded,
      ),
      (
        'Trusted circle',
        'Share selected summaries with people you explicitly choose.',
        Icons.verified_user_rounded,
      ),
      (
        'Collaborative goal',
        'Prepare for shared goals, payment settling, or pooled contributions.',
        Icons.handshake_rounded,
      ),
    ];
    return OnboardingScaffold(
      phase: 15,
      title: 'Set the social boundary.',
      subtitle:
          'Cooperative finance only works when the sharing structure is explicit before tracking starts.',
      bottom: PrimaryButton(
        label: 'Review Preparation Contract',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const PreparationCommitmentScreen()),
      ),
      child: Column(
        children: options
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SelectableOption(
                  icon: option.$3,
                  title: option.$1,
                  body: option.$2,
                  selected: state.socialStructure == option.$1,
                  onTap: () =>
                      setState(() => state.socialStructure = option.$1),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class PreparationCommitmentScreen extends StatelessWidget {
  const PreparationCommitmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final goal = _d1GoalById(state.selectedGoalId);
    final actions = state.selectedActionIds
        .map((id) => _d2Actions[id])
        .whereType<D2Action>()
        .toList();
    final dataIds = <String>{
      for (final action in actions) ...?_actionDataMatrix[action.id],
    };
    final dataPoints = _planDataPoints.values
        .where((point) => dataIds.contains(point.id))
        .toList();
    String dataSummary(String kind) {
      final matching = dataPoints.where((point) => point.kind == kind).toList();
      if (matching.isEmpty) return 'None required';
      return matching.map((point) => '${point.id} ${point.label}').join('\n');
    }

    String allowed(bool value) => value ? 'Allowed' : 'Not allowed';
    final baselineRows = state.onboardingBaselines.entries
        .where((entry) => _baselineFields.containsKey(entry.key))
        .map((entry) {
      final field = _baselineFields[entry.key]!;
      final value = field.format == 'money' ? '₱${entry.value}' : entry.value;
      return (field.label, value);
    }).toList();
    final incomeRows = state.onboardingIncomeLedger.map((income) {
      final scheduled = income['scheduled'] as bool? ?? false;
      final payDay = (income['payDay'] as num?)?.toInt();
      final details = <String>[
        (income['stable'] as bool? ?? false) ? 'Stable' : 'Variable',
        if (scheduled)
          'Scheduled monthly${payDay == null ? '' : ' on day $payDay'}',
      ];
      final amount = (income['amount'] as num?)?.toDouble() ?? 0;
      return (
        income['name']?.toString() ?? 'Income',
        '₱${amount.toStringAsFixed(2)} · ${details.join(' · ')}'
      );
    }).toList();
    final expenseRows = state.onboardingExpenseLedger.map((expense) {
      final scheduled = expense['scheduled'] as bool? ?? false;
      final dueDay = (expense['dueDay'] as num?)?.toInt();
      final details = <String>[
        (expense['essential'] as bool? ?? false)
            ? 'Essential'
            : 'Non-essential',
        if (scheduled)
          'Scheduled monthly${dueDay == null ? '' : ' on day $dueDay'}',
      ];
      final amount = (expense['amount'] as num?)?.toDouble() ?? 0;
      return (
        expense['name']?.toString() ?? 'Expense',
        '₱${amount.toStringAsFixed(2)} · ${details.join(' · ')}'
      );
    }).toList();
    return OnboardingScaffold(
      phase: 14,
      title: 'Final Review.',
      subtitle:
          'Here is the record of the choices you made before Shellby starts your plan.',
      bottom: PrimaryButton(
        label: 'Start First Tracking Step',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const FirstCollectionHandoffScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReviewSection(
            icon: Icons.person_rounded,
            title: 'Profile context',
            rows: [
              ('Name', _summaryFallback(state.name, 'Not provided')),
              ('Life stage', _summaryFallback(state.age, 'Not selected')),
              (
                'Occupation',
                _summaryFallback(state.occupation, 'Not provided')
              ),
              ('Industry', state.industry),
            ],
          ),
          const SizedBox(height: 12),
          ReviewSection(
            icon: Icons.chat_bubble_rounded,
            title: 'Shape your path',
            rows: [
              ('Motivation', state.primaryConcern),
              (
                'Surface',
                _summaryFallback(
                  state.chatSurfaceSummary,
                  'No conversation summary recorded.',
                ),
              ),
              (
                'Specify',
                _summaryFallback(
                    state.chatGoalFocusSummary, state.selectedGoal),
              ),
              (
                'Helpful reminders',
                _summaryFallback(state.chatSituationsSummary, 'Not selected'),
              ),
              (
                'Hurdles to watch',
                _summaryFallback(state.chatChallengesSummary, 'Not selected'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ReviewSection(
            icon: Icons.event_repeat_rounded,
            title: 'Money rhythm',
            rows: [
              ('Employment status', state.employmentStatus),
              ('Income type', state.incomeType),
              ('Income rhythm', state.incomeRhythm),
              ('Bills rhythm', state.billsRhythm),
              ('Financial responsibility', state.responsibility),
              ('Check-in rhythm', state.checkInRhythm),
            ],
          ),
          const SizedBox(height: 12),
          ReviewSection(
            icon: Icons.flag_rounded,
            title: 'Goal and actions',
            rows: [
              ('Selected goal', '${goal.id}: ${goal.title}'),
              ('Goal outcome', goal.description),
              if (actions.isEmpty) ('Selected actions', 'No actions selected'),
              for (final action in actions)
                (
                  action.id,
                  _configuredActionText(
                      action, state.actionFieldValues[action.id] ?? const {})
                ),
            ],
          ),
          const SizedBox(height: 12),
          ReviewSection(
            icon: Icons.storage_rounded,
            title: 'Monthly money ledgers',
            rows: [
              if (incomeRows.isEmpty) ('Income', 'No monthly income recorded'),
              ...incomeRows,
              if (expenseRows.isEmpty)
                ('Expenses', 'No monthly expenses recorded'),
              ...expenseRows,
              if (baselineRows.isNotEmpty) ...baselineRows,
              (
                'FakeMaya',
                state.hasFakeMayaLink
                    ? 'Linked as ${state.fakeMayaLink!.name}'
                    : 'Not linked'
              ),
            ],
          ),
          const SizedBox(height: 12),
          ReviewSection(
            icon: Icons.storage_rounded,
            title: 'Data collection plan',
            rows: [
              ('Dates and timing', dataSummary('Time')),
              ('Information you provide or link', dataSummary('Source')),
              ('Indicators Shellby calculates', dataSummary('Indicator')),
            ],
          ),
          const SizedBox(height: 12),
          ReviewSection(
            icon: Icons.sync_alt_rounded,
            title: 'Collection workflow',
            rows: [
              if (actions.isEmpty)
                ('Workflow', 'No action workflow configured'),
              for (final action in actions)
                (
                  action.id,
                  'You: ${_userCollectionStep(action, (_actionDataMatrix[action.id] ?? const []).map((id) => _planDataPoints[id]).whereType<PlanDataPoint>().toList())}\n\nShellby: ${_appCollectionStep(action, (_actionDataMatrix[action.id] ?? const []).map((id) => _planDataPoints[id]).whereType<PlanDataPoint>().toList())}',
                ),
            ],
          ),
          const SizedBox(height: 12),
          ReviewSection(
            icon: Icons.security_rounded,
            title: 'Permissions and consent',
            rows: [
              ('Notifications', allowed(state.notificationsAllowed)),
              (
                'Third-party data linking',
                allowed(state.thirdPartyDataLinkingAllowed)
              ),
              (
                'Automatic data gathering',
                allowed(state.automaticDataGatheringAllowed)
              ),
              (
                'Personal data consent',
                state.personalDataConsent ? 'Agreed' : 'Not agreed'
              ),
              (
                'Data retention consent',
                state.dataRetentionConsent ? 'Agreed' : 'Not agreed'
              ),
              ('AI analysis', allowed(state.consentAi)),
            ],
          ),
          const SizedBox(height: 12),
          ReviewSection(
            icon: Icons.tune_rounded,
            title: 'Tracking and sharing',
            rows: [
              (
                'Goal-related tracking',
                state.trackingVariables.isEmpty
                    ? 'None selected'
                    : state.trackingVariables.join(', ')
              ),
              (
                'Interfering factors',
                state.interferingVariables.isEmpty
                    ? 'None selected'
                    : state.interferingVariables.join(', ')
              ),
              ('Sharing structure', state.socialStructure),
              ('Anonymous benchmarks', allowed(state.consentBenchmarking)),
              ('Community feedback', allowed(state.consentCommunity)),
              ('Trusted circle sharing', allowed(state.consentTrustedCircle)),
            ],
          ),
          const SizedBox(height: 12),
          const PrepInfoCard(
            icon: Icons.edit_rounded,
            title: 'You can still make changes later',
            body:
                'You can reset conversation details, goal choices, and stored data from the Settings menu.',
          ),
        ],
      ),
    );
  }
}

class ReviewSection extends StatelessWidget {
  const ReviewSection({
    super.key,
    required this.icon,
    required this.title,
    required this.rows,
  });

  final IconData icon;
  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBubble(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.$1,
                    style: const TextStyle(
                      color: _body,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    row.$2,
                    style: const TextStyle(
                      color: _title,
                      height: 1.28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FirstCollectionHandoffScreen extends StatelessWidget {
  const FirstCollectionHandoffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 15,
      title: 'Get ready to start your journey with Shelby!',
      subtitle: 'Your onboarding choices are ready.',
      centerTitle: true,
      bottom: PrimaryButton(
        label: 'Start with Shelby',
        icon: Icons.arrow_forward_rounded,
        onPressed: () async {
          try {
            if (!state.isSignedIn) {
              await state.signInWithGoogle(
                saveAfterSignIn: false,
                forceFreshGoogleSession: true,
              );
            }
            await state.saveProfile(markOnboardingComplete: true);
            if (!context.mounted) return;
            _pushReplacement(context, const MainShell());
          } catch (error) {
            if (!context.mounted) return;
            _showAuthError(context, error);
          }
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/images/shellby_arms_out.webp',
              height: 400,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}
