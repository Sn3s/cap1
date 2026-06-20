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
      subcategory: 'Main job',
      tag: 'Work',
      note: 'June payroll',
    );
    final rule = TransactionLabelRule.fromTransaction(labeled);
    final recognized = rule.applyTo(matching);

    expect(source.patternKey, matching.patternKey);
    expect(recognized.category, 'Salary');
    expect(recognized.subcategory, 'Main job');
    expect(recognized.tag, 'Work');
    expect(recognized.note, isNull);
  });
}
