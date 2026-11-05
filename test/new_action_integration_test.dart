import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Everyday Fund coverage counts a local Essential Fund only once', () {
    final state = AppState()
      ..onboardingComplete = true
      ..selectedActionIds.add('A21')
      ..actionFieldValues['A21'] = {'days': '7'}
      ..manualAccountBalances['Wallet'] = 800
      ..essentialExpensesBalance = 200
      ..cashOnHandBalance = 200
      ..onboardingExpenseLedger.add({
        'amount': 3000.0,
        'layer': 'basicNeeds',
      });

    final action = computeHealthScore(state)
        .actions
        .singleWhere((line) => line.actionId == 'A21');

    // ₱200 Essential Fund + (₱800 Wallet - local ₱200 Fund) + ₱200 cash
    // = ₱1,000. At ₱100/day, that covers 10 days and clears a 7-day target.
    expect(action.completion, 1);
    expect(action.detail, contains('10.0 of 7 days'));
  });

  test('a windfall decision is explicit and cannot be recorded twice',
      () async {
    final state = AppState();
    final receivedAt = DateTime(2026, 1, 15);

    await state.markWindfallNotInvested(
      transactionId: 'bonus-1',
      cashInAmount: 5000,
      cashInDate: receivedAt,
    );
    await state.markWindfallNotInvested(
      transactionId: 'bonus-1',
      cashInAmount: 5000,
      cashInDate: receivedAt,
    );

    expect(state.hasInvestmentWindfallDecision('bonus-1'), isTrue);
    expect(
      state.d1Ledger
          .where((entry) => entry['type'] == 'investment_windfall_skipped'),
      hasLength(1),
    );
  });

  test('income pattern is saved independently from the generic tag', () async {
    final receipt = FakeMayaTransaction(
      id: 'gift-1',
      title: 'Cash in',
      detail: 'From: Family',
      age: 'Just now',
      amountText: '+ ₱2,000.00',
      createdAt: DateTime(2026, 1, 15),
    );
    final state = AppState()..manualTransactions.add(receipt);

    await state.labelFakeMayaTransaction(
      transactionId: receipt.transactionId,
      category: 'Gift',
      source: 'Wallet',
      incomeClassification: IncomeClassification.unexpected,
      tag: 'Family',
    );

    final labelled = state.manualTransactions.single;
    expect(labelled.incomeClassification, IncomeClassification.unexpected);
    expect(labelled.isUnexpectedIncome, isTrue);
    expect(labelled.tag, 'Family');
    expect(
      FakeMayaTransaction.fromMap(labelled.toMap()).incomeClassification,
      IncomeClassification.unexpected,
    );
  });

  test('a partial month-end sweep moves and records only the chosen amount',
      () async {
    final state = AppState()
      ..seedAccumulatingWealthMockDataForTesting()
      // The transfer is what this test verifies; avoid the production
      // Firebase persistence branch in a headless unit test.
      ..onboardingComplete = false;
    final before = state.fakeMayaLink!.summary.wallet;
    final target = state.monthlySurplus * .50;
    final partial = target / 2;

    await state.sweepUnspentFundsToInvestment(
      percentage: 50,
      amount: partial,
    );

    final sweep = state.d1Ledger.firstWhere(
      (entry) => entry['type'] == 'investment_sweep',
    );
    expect((sweep['amount'] as num).toDouble(), closeTo(partial, .01));
    expect((sweep['unspentAmount'] as num).toDouble(),
        closeTo(state.monthlySurplus, .01));
    expect(state.fakeMayaLink!.summary.wallet, closeTo(before - partial, .01));
    expect(state.hasInvestmentSweepForCurrentMonth, isTrue);
  });
}
