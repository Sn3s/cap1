part of '../main.dart';

/// A deterministic suggestion inferred from repeated outgoing transactions.
/// It deliberately contains only observed facts; Shellby never creates a bill
/// until the user reviews and accepts the suggestion.
class RecurringTransactionSuggestion {
  const RecurringTransactionSuggestion({
    required this.key,
    required this.merchantName,
    required this.typicalAmount,
    required this.frequency,
    required this.lastOccurredAt,
    required this.nextExpectedAt,
    required this.occurrences,
    this.category,
  });

  final String key;
  final String merchantName;
  final double typicalAmount;
  final String frequency;
  final DateTime lastOccurredAt;
  final DateTime nextExpectedAt;
  final int occurrences;
  final String? category;
}

/// Finds stable weekly, biweekly, and monthly outgoing-merchant patterns.
/// Three dated occurrences and a consistent interval and amount are required
/// to avoid turning ordinary spending into a bill suggestion.
List<RecurringTransactionSuggestion> detectRecurringTransactionSuggestions(
  Iterable<FakeMayaTransaction> transactions,
) {
  final groups = <String, List<FakeMayaTransaction>>{};
  for (final transaction in transactions) {
    if (transaction.amount >= 0 ||
        transaction.createdAt == null ||
        transaction.excludedFromInsights ||
        transaction.isInternalFakeMayaTransfer ||
        transaction.isWalletCashMovement) {
      continue;
    }
    final merchantKey = transaction.merchantCategoryKey;
    if (merchantKey.trim().isEmpty) continue;
    groups.putIfAbsent(merchantKey, () => []).add(transaction);
  }

  final suggestions = <RecurringTransactionSuggestion>[];
  for (final entry in groups.entries) {
    final unique = <String, FakeMayaTransaction>{};
    for (final transaction in entry.value) {
      unique[transaction.transactionId] = transaction;
    }
    final items = unique.values.toList()
      ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    if (items.length < 3) continue;

    final intervals = <int>[
      for (var index = 1; index < items.length; index++)
        items[index].createdAt!.difference(items[index - 1].createdAt!).inDays,
    ];
    if (intervals.any((days) => days <= 0)) continue;
    final intervalDays =
        _recurringMedian(intervals.map((value) => value.toDouble()));
    final frequency = _recurringFrequency(intervalDays);
    if (frequency == null) continue;
    final allowedIntervalVariance = switch (frequency) {
      'Weekly' => 2.0,
      'Every 2 weeks' => 3.0,
      _ => 6.0,
    };
    if (intervals
        .any((days) => (days - intervalDays).abs() > allowedIntervalVariance)) {
      continue;
    }

    final amounts = items.map((item) => item.amount.abs()).toList();
    final typicalAmount = _recurringMedian(amounts);
    final allowedAmountVariance = math.max(50.0, typicalAmount * .25);
    if (amounts.any(
        (amount) => (amount - typicalAmount).abs() > allowedAmountVariance)) {
      continue;
    }

    final latest = items.last;
    String? category;
    for (final item in items) {
      final value = item.category?.trim();
      if (value != null && value.isNotEmpty) {
        category = value;
        break;
      }
    }
    category ??= builtInMerchantCategoryFor(latest);
    final merchantName = _recurringMerchantName(latest);
    suggestions.add(RecurringTransactionSuggestion(
      key: '${entry.key}|$frequency',
      merchantName: merchantName,
      typicalAmount: typicalAmount,
      frequency: frequency,
      lastOccurredAt: latest.createdAt!,
      nextExpectedAt: _nextRecurringOccurrence(
        latest.createdAt!,
        frequency,
        intervalDays.round(),
      ),
      occurrences: items.length,
      category: category,
    ));
  }
  suggestions.sort((a, b) => b.lastOccurredAt.compareTo(a.lastOccurredAt));
  return suggestions;
}

double _recurringMedian(Iterable<double> values) {
  final sorted = values.toList()..sort();
  final middle = sorted.length ~/ 2;
  return sorted.length.isOdd
      ? sorted[middle]
      : (sorted[middle - 1] + sorted[middle]) / 2;
}

String? _recurringFrequency(double intervalDays) {
  if (intervalDays >= 5 && intervalDays <= 9) return 'Weekly';
  if (intervalDays >= 11 && intervalDays <= 17) return 'Every 2 weeks';
  if (intervalDays >= 24 && intervalDays <= 37) return 'Monthly';
  return null;
}

DateTime _nextRecurringOccurrence(
  DateTime lastOccurrence,
  String frequency,
  int intervalDays,
) {
  if (frequency != 'Monthly') {
    return lastOccurrence.add(Duration(days: intervalDays));
  }
  final nextMonth = DateTime(lastOccurrence.year, lastOccurrence.month + 1);
  final lastDayOfNextMonth =
      DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
  return DateTime(
    nextMonth.year,
    nextMonth.month,
    math.min(lastOccurrence.day, lastDayOfNextMonth),
    lastOccurrence.hour,
    lastOccurrence.minute,
  );
}

String _recurringMerchantName(FakeMayaTransaction transaction) {
  final detail = transaction.detail
      .replaceFirst(RegExp(r'^(from|to)\s*:\s*', caseSensitive: false), '')
      .split('·')
      .first
      .trim();
  return detail.isEmpty ? transaction.title.trim() : detail;
}
