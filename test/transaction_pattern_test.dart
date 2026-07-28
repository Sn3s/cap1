import 'package:flutter_test/flutter_test.dart';

import 'package:cap1/main.dart';

void main() {
  test('counterparty pattern ignores FakeMaya detail decoration', () {
    const cashIn = FakeMayaTransaction(
      title: 'Cash in',
      detail: 'From: ACME Payroll',
      age: 'Just now',
      amountText: '+ ₱1,000.00',
    );
    const sentMoney = FakeMayaTransaction(
      title: 'Sent money (simulated)',
      detail: 'To: ACME Payroll · Simulated expense',
      age: 'Just now',
      amountText: '- ₱100.00',
    );

    expect(cashIn.counterpartyKey, 'acme payroll');
    expect(sentMoney.counterpartyKey, 'acme payroll');
    expect(cashIn.patternKey, isNot(sentMoney.patternKey));
  });

  test('learned rule copies labels but keeps notes transaction-specific', () {
    const source = FakeMayaTransaction(
      id: 'first',
      title: 'Cash in',
      detail: 'From: ACME Payroll',
      age: 'Just now',
      amountText: '+ ₱1,000.00',
    );
    const matching = FakeMayaTransaction(
      id: 'second',
      title: 'Cash in',
      detail: 'from: acme payroll',
      age: 'Just now',
      amountText: '+ ₱1,000.00',
    );
    const differentAmount = FakeMayaTransaction(
      id: 'third',
      title: 'Cash in',
      detail: 'from: acme payroll',
      age: 'Just now',
      amountText: '+ ₱2,000.00',
    );
    final labeled = source.copyWithLabel(
      category: 'Salary',
      source: 'Basic Needs Fund',
      subcategory: 'Main job',
      tag: 'Work',
      note: 'June payroll',
    );
    final rule = TransactionLabelRule.fromTransaction(labeled);
    final recognized = rule.applyTo(matching);

    expect(source.patternKey, matching.patternKey);
    expect(source.patternKey, isNot(differentAmount.patternKey));
    expect(recognized.category, 'Salary');
    expect(recognized.source, 'E-wallet');
    expect(recognized.subcategory, 'Main job');
    expect(recognized.tag, 'Work');
    expect(recognized.note, isNull);
  });

  test('FakeMaya cash ins automatically target the e-wallet', () {
    const transaction = FakeMayaTransaction(
      title: 'Cash in',
      detail: 'From: ACME Payroll',
      age: 'Just now',
      amountText: '+ ₱1,000.00',
    );
    final labeled = transaction.copyWithLabel(
      category: 'Salary',
      source: transaction.automaticDestination ?? 'Basic Needs Fund',
    );

    expect(transaction.isFakeMayaCashIn, isTrue);
    expect(transaction.automaticDestination, 'E-wallet');
    expect(TransactionLabelRule.fromTransaction(labeled).source, 'E-wallet');
  });

  test('FakeMaya refresh keeps labels when id and timestamp change', () {
    final saved = FakeMayaTransaction(
      id: 'old-server-id',
      title: 'Paid merchant',
      detail: 'To: Grocery Mart · Card payment',
      age: 'Yesterday',
      amountText: '- ₱750.00',
      createdAt: DateTime.utc(2026, 7, 25, 10),
      account: 'Wallet',
    ).copyWithLabel(
      category: 'Groceries',
      source: 'Basic Needs Fund',
      subcategory: 'Weekly food',
      tag: 'Personal',
      note: 'Remembered locally',
    );
    final fresh = FakeMayaTransaction(
      id: 'new-server-id',
      title: 'Paid merchant',
      detail: 'To: Grocery Mart',
      age: 'Yesterday',
      amountText: '- ₱750.00',
      createdAt: DateTime.utc(2026, 7, 25, 10, 5),
      account: 'Wallet',
    );

    final merged = AppState().mergeFakeMayaTransactionLabelsForTesting(
      savedTransactions: [saved],
      freshTransactions: [fresh],
    );

    expect(merged.single.transactionId, 'new-server-id');
    expect(merged.single.category, 'Groceries');
    expect(merged.single.source, 'Basic Needs Fund');
    expect(merged.single.subcategory, 'Weekly food');
    expect(merged.single.tag, 'Personal');
    expect(merged.single.note, 'Remembered locally');
    expect(merged.single.isLabeled, isTrue);
  });

  test('FakeMaya goal deposits are internal transfers, not cash-in', () {
    const transaction = FakeMayaTransaction(
      title: 'Deposited to goal',
      detail: 'Essential Expense Fund',
      age: 'Just now',
      amountText: '+ ₱300.00',
    );

    expect(transaction.isInternalFakeMayaTransfer, isTrue);
    expect(transaction.isFakeMayaCashIn, isFalse);
    expect(transaction.automaticDestination, isNull);
  });

  test('legacy labels gain a source when loaded', () {
    final ordinary = FakeMayaTransaction.fromMap({
      'title': 'Paid merchant',
      'detail': 'To: Store',
      'age': 'Seeded',
      'amount': '- ₱500.00',
      'category': 'Groceries',
    });
    final oldFundCategory = FakeMayaTransaction.fromMap({
      'title': 'Paid merchant',
      'detail': 'To: Clinic',
      'age': 'Seeded',
      'amount': '- ₱500.00',
      'category': 'Emergency fund',
    });

    expect(ordinary.category, 'Groceries');
    expect(ordinary.source, 'Basic Needs Fund');
    expect(ordinary.isLabeled, isTrue);
    expect(oldFundCategory.category, 'Other expense');
    expect(oldFundCategory.source, 'Emergency Fund');
    expect(oldFundCategory.isLabeled, isTrue);
  });
}
