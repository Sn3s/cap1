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
    expect(recognized.category, 'Salary');
    expect(recognized.source, 'Basic Needs Fund');
    expect(recognized.subcategory, 'Main job');
    expect(recognized.tag, 'Work');
    expect(recognized.note, isNull);
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
