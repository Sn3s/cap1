import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FakeMayaTransaction income(
    String id, {
    String? category,
    String? source,
    DateTime? createdAt,
    DateTime? labeledAt,
    bool excluded = false,
  }) =>
      FakeMayaTransaction(
        id: id,
        title: 'Salary received',
        detail: 'Employer payroll',
        age: 'Just now',
        amountText: '+ ₱10000',
        category: category,
        source: source,
        createdAt: createdAt,
        labeledAt: labeledAt,
        excludedFromInsights: excluded,
      );

  test(
      'detected income needs a complete salary label before emergency allocation',
      () {
    final now = DateTime.now();
    final state = AppState();
    for (final transaction in [
      income('unlabeled', createdAt: now),
      income('incomplete', category: 'Salary', createdAt: now),
      income('gift', category: 'Gift', source: 'Wallet', createdAt: now),
      income('excluded',
          category: 'Salary', source: 'Wallet', createdAt: now, excluded: true),
      income('old',
          category: 'Salary',
          source: 'Wallet',
          createdAt: now.subtract(const Duration(days: 1))),
    ]) {
      state.manualTransactions
        ..clear()
        ..add(transaction);
      expect(state.latestEmergencyFundIncomeTransaction, isNull,
          reason: transaction.id);
    }
    final salary =
        income('salary', category: 'Salary', source: 'Wallet', createdAt: now);
    state.manualTransactions
      ..clear()
      ..add(salary);
    expect(state.latestEmergencyFundIncomeTransaction, same(salary));
    expect(state.pendingEssentialIncomeTransactions, contains(salary));
    state.d1Ledger
        .add({'type': 'essential_deposit', 'sourceTransactionId': 'salary'});
    expect(state.latestEmergencyFundIncomeTransaction, same(salary));
  });

  test('salary eligibility uses label date when creation date is missing', () {
    final salary = income('salary',
        category: 'Salary', source: 'Wallet', labeledAt: DateTime.now());
    final state = AppState()..manualTransactions.add(salary);
    expect(state.latestEmergencyFundIncomeTransaction, same(salary));
  });
}
