import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

FakeMayaTransaction _expense({
  required String id,
  required DateTime date,
  double amount = 299,
  String merchant = 'Netflix',
  String? category,
}) =>
    FakeMayaTransaction(
      id: id,
      title: 'Sent money',
      detail: 'To: $merchant',
      age: 'Just now',
      amountText: '- ₱${amount.toStringAsFixed(2)}',
      createdAt: date,
      category: category,
      source: category == null ? null : 'E-wallet',
    );

void main() {
  test('detects a stable monthly merchant payment', () {
    final suggestions = detectRecurringTransactionSuggestions([
      _expense(id: 'one', date: DateTime(2026, 1, 5)),
      _expense(id: 'two', date: DateTime(2026, 2, 5), amount: 305),
      _expense(id: 'three', date: DateTime(2026, 3, 5), amount: 300),
    ]);

    expect(suggestions, hasLength(1));
    expect(suggestions.single.merchantName, 'Netflix');
    expect(suggestions.single.frequency, 'Monthly');
    expect(suggestions.single.typicalAmount, 300);
    expect(suggestions.single.nextExpectedAt, DateTime(2026, 4, 5));
  });

  test('rejects irregular timing, one-off spending, and internal transfers',
      () {
    expect(
      detectRecurringTransactionSuggestions([
        _expense(id: 'one', date: DateTime(2026, 1, 1), merchant: 'Grab'),
        _expense(id: 'two', date: DateTime(2026, 1, 5), merchant: 'Grab'),
        _expense(id: 'three', date: DateTime(2026, 3, 10), merchant: 'Grab'),
      ]),
      isEmpty,
    );
    expect(
      detectRecurringTransactionSuggestions([
        FakeMayaTransaction(
          id: 'transfer-one',
          title: 'Transferred from',
          detail: 'My Savings',
          age: 'Just now',
          amountText: '- ₱200.00',
          createdAt: DateTime(2026, 1, 1),
        ),
        FakeMayaTransaction(
          id: 'transfer-two',
          title: 'Transferred from',
          detail: 'My Savings',
          age: 'Just now',
          amountText: '- ₱200.00',
          createdAt: DateTime(2026, 2, 1),
        ),
        FakeMayaTransaction(
          id: 'transfer-three',
          title: 'Transferred from',
          detail: 'My Savings',
          age: 'Just now',
          amountText: '- ₱200.00',
          createdAt: DateTime(2026, 3, 1),
        ),
      ]),
      isEmpty,
    );
  });

  test('accepting a suggestion creates a scheduled expense once', () async {
    final state = AppState();
    state.manualTransactions.addAll([
      _expense(id: 'one', date: DateTime(2026, 1, 5)),
      _expense(id: 'two', date: DateTime(2026, 2, 5)),
      _expense(id: 'three', date: DateTime(2026, 3, 5)),
    ]);
    final suggestion = state.recurringTransactionSuggestions.single;

    await state.acceptRecurringTransactionSuggestion(
      suggestion,
      category: 'Subscriptions',
      expenseLayer: ExpenseLayer.nonEssentials,
      anchorDate: suggestion.lastOccurredAt,
    );

    expect(state.onboardingExpenseLedger, hasLength(1));
    expect(state.onboardingExpenseLedger.single['scheduled'], isTrue);
    expect(state.onboardingExpenseLedger.single['repeatFrequency'], 'Monthly');
    expect(state.recurringTransactionSuggestions, isEmpty);
  });
}
