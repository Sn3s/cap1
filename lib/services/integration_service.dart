part of '../main.dart';

class DayRecord {
  const DayRecord({
    required this.date,
    required this.incomeTotal,
    required this.expenseTotal,
    required this.feeTotal,
    required this.needsBalanceEnd,
    required this.bufferBalanceEnd,
    required this.withdrawalAmount,
    required this.refillAmount,
    required this.isSalaryWeek,
    required this.isBillWeek,
    required this.hadEmergency,
    required this.syncedWithMaya,
    required this.numUnclassified,
    required this.wasInferred,
    required this.transactions,
    required this.events,
  });

  final DateTime date;
  final double incomeTotal;
  final double expenseTotal;
  final double feeTotal;
  final double needsBalanceEnd;
  final double bufferBalanceEnd;
  final double withdrawalAmount;
  final double refillAmount;
  final bool isSalaryWeek;
  final bool isBillWeek;
  final bool hadEmergency;
  final bool syncedWithMaya;
  final int numUnclassified;
  final bool wasInferred;
  final List<FakeMayaTransaction> transactions;
  final List<JarEvent> events;

  bool get fullyClassified =>
      syncedWithMaya && !wasInferred && numUnclassified == 0;
}

class WeekRecord {
  const WeekRecord({
    required this.start,
    required this.end,
    required this.days,
    required this.weekIncome,
    required this.weekExpense,
    required this.weekRefill,
    required this.avgSpendPerDay,
    required this.propDaysClassified,
    required this.needsBalanceEnd,
    required this.bufferBalanceEnd,
    required this.isSalaryWeek,
    required this.isBillWeek,
    required this.hadEmergency,
  });

  final DateTime start;
  final DateTime end;
  final List<DayRecord> days;
  final double weekIncome;
  final double weekExpense;
  final double weekRefill;
  final double avgSpendPerDay;
  final double propDaysClassified;
  final double needsBalanceEnd;
  final double bufferBalanceEnd;
  final bool isSalaryWeek;
  final bool isBillWeek;
  final bool hadEmergency;
}

class IntegrationService {
  /// Builds the chronological record once.  This is intentionally a factory
  /// instead of two initializer expressions: Insights and Goals can contain
  /// several years of activity, and rebuilding the same daily history twice
  /// made large, valid histories block the UI thread.
  factory IntegrationService.fromState(AppState state) {
    final days = _buildDayRecords(state);
    return IntegrationService._(
      bufferTarget: _bufferTargetFor(state),
      needsTarget: state.needsTarget,
      dayRecords: days,
      weekRecords: _buildWeekRecords(days, _cycleWeekdayFor(state)),
    );
  }

  IntegrationService._({
    required this.bufferTarget,
    required this.needsTarget,
    required this.dayRecords,
    required this.weekRecords,
  }) {
    jarIntegritySeries = jarIntegrity(weekRecords, needsTarget, bufferTarget);
    bufferResilienceSeries =
        bufferResilience(weekRecords, needsTarget, bufferTarget);
    refillConsistencySeries = refillConsistency(weekRecords);
  }

  final double bufferTarget;
  final double needsTarget;
  final List<DayRecord> dayRecords;
  final List<WeekRecord> weekRecords;
  late final List<double> jarIntegritySeries;
  late final List<double> bufferResilienceSeries;
  late final List<double> refillConsistencySeries;
}

/// jarIntegrity
/// Plain-language definition: how intact the Needs and Buffer jars are compared
/// with their targets at the end of each week.
/// Formula: average(min(1, needsBalance / needsTarget),
/// min(1, bufferBalance / bufferTarget)).
/// Reflection question: "How intact are my jars vs my targets?"
List<double> jarIntegrity(
  List<WeekRecord> records,
  double needsTarget,
  double bufferTarget,
) {
  return records.map((week) {
    final needs = _safeRatio(week.needsBalanceEnd, needsTarget).clamp(0.0, 1.0);
    final buffer =
        _safeRatio(week.bufferBalanceEnd, bufferTarget).clamp(0.0, 1.0);
    return (needs + buffer) / 2;
  }).toList();
}

/// bufferResilience
/// Plain-language definition: whether jars remain intact during weeks with
/// bill pressure or emergency context.
/// Formula: jarIntegrity * (1 + 0.5 * interference), where interference is
/// 0/1/2 from bill-week + emergency flags.
/// Reflection question: "Do I keep my jars intact even in hard weeks?"
List<double> bufferResilience(
  List<WeekRecord> records,
  double needsTarget,
  double bufferTarget,
) {
  final integrity = jarIntegrity(records, needsTarget, bufferTarget);
  return records.asMap().entries.map((entry) {
    final week = entry.value;
    final interference =
        (week.isBillWeek ? 1 : 0) + (week.hadEmergency ? 1 : 0);
    return integrity[entry.key] * (1 + 0.5 * interference);
  }).toList();
}

/// refillConsistency
/// Plain-language definition: how variable weekly Buffer refills are across the
/// observed period; lower values mean steadier top-ups.
/// Formula: rolling stdev(weekly refill amounts) / mean(weekly refill amounts).
/// Reflection question: "Do I top up steadily or in panic lumps?"
List<double> refillConsistency(List<WeekRecord> records) {
  final out = <double>[];
  final values = <double>[];
  for (final week in records) {
    values.add(week.weekRefill);
    final positive = values.where((value) => value > 0).toList();
    if (positive.isEmpty) {
      out.add(0);
      continue;
    }
    final mean = positive.reduce((a, b) => a + b) / positive.length;
    if (mean == 0) {
      out.add(0);
      continue;
    }
    final variance = positive
            .map((value) => math.pow(value - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        positive.length;
    out.add(math.sqrt(variance) / mean);
  }
  return out;
}

List<DayRecord> _buildDayRecords(AppState state) {
  // Index once by calendar day. The previous implementation filtered every
  // event and every transaction again for each day in the date range. A
  // 10,000-record history spanning years therefore did tens of millions of
  // comparisons on the browser's main thread.
  final eventsByDay = <DateTime, List<JarEvent>>{};
  final transactionsByDay = <DateTime, List<FakeMayaTransaction>>{};
  final dates = <DateTime>{};
  for (final event in state.jarLedger) {
    final day = _day(event.timestamp);
    dates.add(day);
    eventsByDay.putIfAbsent(day, () => []).add(event);
  }
  for (final transaction in state.allTransactions) {
    final timestamp = transaction.createdAt;
    if (timestamp == null) continue;
    final day = _day(timestamp);
    dates.add(day);
    transactionsByDay.putIfAbsent(day, () => []).add(transaction);
  }
  // Preserve the chronological order callers previously received from the
  // globally sorted lists, while keeping lookup cost constant per day.
  for (final events in eventsByDay.values) {
    events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  for (final transactions in transactionsByDay.values) {
    transactions.sort((a, b) => (a.createdAt ?? DateTime(1970))
        .compareTo(b.createdAt ?? DateTime(1970)));
  }
  if (dates.isEmpty) return const [];
  final sortedDates = dates.toList()..sort();
  var current = sortedDates.first;
  final last = sortedDates.last;
  double needs = 0;
  double buffer = 0;
  final out = <DayRecord>[];
  while (!current.isAfter(last)) {
    final sameDayEvents = eventsByDay[current] ?? const <JarEvent>[];
    final sameDayTransactions =
        transactionsByDay[current] ?? const <FakeMayaTransaction>[];
    var withdrawalAmount = 0.0;
    var refillAmount = 0.0;
    var isBillDay = false;
    var isSalaryDay = false;
    var emergency = false;
    for (final event in sameDayEvents) {
      needs += event.needsIn - event.needsOut;
      buffer += event.bufferIn - event.bufferOut;
      withdrawalAmount += event.bufferOut;
      refillAmount += event.bufferIn;
      isBillDay |= event.type == JarEventType.billPaid;
      isSalaryDay |= event.type == JarEventType.income;
      emergency |= _looksEmergency(event);
    }
    var expenses = 0.0;
    var income = 0.0;
    var feeTotal = 0.0;
    var numUnclassified = 0;
    for (final transaction in sameDayTransactions) {
      if (!transaction.isLabeled) numUnclassified++;
      if (!transaction.countsTowardFinancialInsights) continue;
      if (transaction.amount < 0 &&
          transaction.source?.toLowerCase() == 'basic needs fund') {
        expenses += transaction.amount.abs();
      }
      if (transaction.amount > 0 && !transaction.isInternalFakeMayaTransfer) {
        income += transaction.amount;
      }
      if ((transaction.category ?? '').toLowerCase().contains('fee') ||
          transaction.title.toLowerCase().contains('fee')) {
        feeTotal += transaction.amount.abs();
      }
    }
    final hasData = sameDayEvents.isNotEmpty || sameDayTransactions.isNotEmpty;
    out.add(DayRecord(
      date: current,
      incomeTotal: income,
      expenseTotal: expenses,
      feeTotal: feeTotal,
      needsBalanceEnd: needs,
      bufferBalanceEnd: buffer,
      withdrawalAmount: withdrawalAmount,
      refillAmount: refillAmount,
      isSalaryWeek: isSalaryDay,
      isBillWeek: isBillDay,
      hadEmergency: emergency,
      syncedWithMaya: sameDayTransactions.isNotEmpty,
      numUnclassified: numUnclassified,
      wasInferred: hasData && sameDayTransactions.isEmpty,
      transactions: sameDayTransactions,
      events: sameDayEvents,
    ));
    current = current.add(const Duration(days: 1));
  }
  return out;
}

List<WeekRecord> _buildWeekRecords(List<DayRecord> days, int cycleWeekday) {
  if (days.isEmpty) return const [];
  final groups = <DateTime, List<DayRecord>>{};
  for (final day in days) {
    final start = _weekStart(day.date, cycleWeekday);
    groups.putIfAbsent(start, () => []).add(day);
  }
  final starts = groups.keys.toList()..sort();
  return starts.map((start) {
    final weekDays = groups[start]!..sort((a, b) => a.date.compareTo(b.date));
    final classified = weekDays.where((day) => day.fullyClassified).length;
    return WeekRecord(
      start: start,
      end: start.add(const Duration(days: 6)),
      days: List.unmodifiable(weekDays),
      weekIncome: weekDays.fold(0.0, (sum, day) => sum + day.incomeTotal),
      weekExpense: weekDays.fold(0.0, (sum, day) => sum + day.expenseTotal),
      weekRefill: weekDays.fold(0.0, (sum, day) => sum + day.refillAmount),
      avgSpendPerDay: weekDays.isEmpty
          ? 0
          : weekDays.fold(0.0, (sum, day) => sum + day.expenseTotal) /
              weekDays.length,
      propDaysClassified: weekDays.isEmpty ? 0 : classified / weekDays.length,
      needsBalanceEnd: weekDays.last.needsBalanceEnd,
      bufferBalanceEnd: weekDays.last.bufferBalanceEnd,
      isSalaryWeek: weekDays.any((day) => day.isSalaryWeek),
      isBillWeek: weekDays.any((day) => day.isBillWeek),
      hadEmergency: weekDays.any((day) => day.hadEmergency),
    );
  }).toList();
}

double _bufferTargetFor(AppState state) {
  if (state.needsTarget <= 0) return 0;
  final needsShare = state.needsPercent.clamp(1, 99) / 100;
  return state.needsTarget * ((1 - needsShare) / needsShare);
}

int _cycleWeekdayFor(AppState state) {
  final incomeDates = state.jarLedger
      .where((event) => event.type == JarEventType.income)
      .map((event) => event.timestamp.weekday)
      .toList();
  if (incomeDates.isNotEmpty) return incomeDates.first;
  return state.salaryWeekday.clamp(DateTime.monday, DateTime.sunday);
}

DateTime _weekStart(DateTime value, int startWeekday) {
  final date = _day(value);
  final diff = (date.weekday - startWeekday) % DateTime.daysPerWeek;
  return date.subtract(Duration(days: diff));
}

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

bool _looksEmergency(JarEvent event) {
  final text = event.sentence.toLowerCase();
  return text.contains('emergency') ||
      text.contains('shortfall') ||
      event.bufferOut >= 1000 && event.type == JarEventType.billPaid;
}

double _safeRatio(double value, double denominator) =>
    denominator <= 0 ? 0 : value / denominator;
