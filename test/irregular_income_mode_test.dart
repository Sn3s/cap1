import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

AppState _state({
  required String incomeType,
  required String incomeRhythm,
}) {
  return AppState()
    ..incomeType = incomeType
    ..incomeRhythm = incomeRhythm;
}

FakeMayaTransaction _cashIn({
  required String id,
  required double amount,
  String detail = 'From: Freelance payment',
}) {
  return FakeMayaTransaction(
    id: id,
    title: 'Cash in',
    detail: detail,
    age: 'Just now',
    amountText: '+ ₱${amount.toStringAsFixed(2)}',
    createdAt: DateTime(2026, 10, 8, 10),
    account: 'Wallet',
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('irregular mode is driven by income timing', () {
    expect(
      _state(incomeType: 'Variable', incomeRhythm: 'Irregular')
          .usesIrregularIncomeMode,
      isTrue,
    );
    expect(
      _state(incomeType: 'Fixed', incomeRhythm: 'Irregular')
          .usesIrregularIncomeMode,
      isTrue,
    );
    expect(
      _state(incomeType: 'Variable', incomeRhythm: 'Monthly')
          .usesIrregularIncomeMode,
      isFalse,
    );
    expect(
      _state(incomeType: 'Fixed', incomeRhythm: 'Twice a month')
          .usesIrregularIncomeMode,
      isFalse,
    );
  });

  test('income source defaults preserve amount and timing distinctions', () {
    final fixedIrregular =
        _state(incomeType: 'Fixed', incomeRhythm: 'Irregular')
            .suggestedIncomeSourceDefaults;
    expect(fixedIrregular.stable, isTrue);
    expect(fixedIrregular.scheduled, isFalse);

    final variableIrregular =
        _state(incomeType: 'Variable', incomeRhythm: 'Irregular')
            .suggestedIncomeSourceDefaults;
    expect(variableIrregular.stable, isFalse);
    expect(variableIrregular.scheduled, isFalse);

    final fixedWeekly = _state(incomeType: 'Fixed', incomeRhythm: 'Weekly')
        .suggestedIncomeSourceDefaults;
    expect(fixedWeekly.stable, isTrue);
    expect(fixedWeekly.scheduled, isTrue);
    expect(fixedWeekly.repeatFrequency, 'Weekly');

    final fixedTwiceMonthly =
        _state(incomeType: 'Fixed', incomeRhythm: 'Twice a month')
            .suggestedIncomeSourceDefaults;
    expect(fixedTwiceMonthly.stable, isTrue);
    expect(fixedTwiceMonthly.scheduled, isTrue);
    expect(fixedTwiceMonthly.repeatFrequency, 'Twice a month');

    final variableMonthly =
        _state(incomeType: 'Variable', incomeRhythm: 'Monthly')
            .suggestedIncomeSourceDefaults;
    expect(variableMonthly.stable, isFalse);
    expect(variableMonthly.scheduled, isTrue);
    expect(variableMonthly.repeatFrequency, 'Monthly');

    final both = _state(incomeType: 'Both', incomeRhythm: 'Monthly')
        .suggestedIncomeSourceDefaults;
    expect(both.stable, isFalse);
    expect(both.scheduled, isFalse);
  });

  testWidgets('saved income-source settings are retained in onboarding',
      (tester) async {
    final state = _state(incomeType: 'Variable', incomeRhythm: 'Irregular')
      ..onboardingIncomeLedger.add({
        'name': 'Existing client',
        'amount': 12000.0,
        'stable': true,
        'scheduled': true,
        'payDay': 15,
        'scheduleAnchorType': 'next',
        'scheduleAnchorDate': DateTime(2026, 10, 15).toIso8601String(),
        'repeatFrequency': 'Monthly',
      });

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: MonthlyIncomeScreen()),
      ),
    );

    expect(find.text('Existing client'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isTrue);
    expect(tester.widget<FilterChip>(find.byType(FilterChip)).selected, isTrue);
  });

  test('typical variable income is planning context, not available cash', () {
    final state = _state(incomeType: 'Variable', incomeRhythm: 'Irregular')
      ..setVariableIncomeBaseline(30000)
      ..income = 30000
      ..needsTarget = 18000;

    expect(state.effectiveVariableIncomeBaseline, 30000);
    expect(state.needsBalance, 0);
    expect(state.bufferBalance, 0);
    expect(state.jarLedger, isEmpty);
  });

  test('actual irregular income uses the existing Needs-Buffer split', () {
    final state = _state(incomeType: 'Variable', incomeRhythm: 'Irregular')
      ..needsTarget = 18000
      ..needsPercent = 70;

    final result = state.onIncomeEvent(10000, sourceLabel: 'Freelance payment');

    expect(result.toNeeds, 7000);
    expect(result.toBuffer, 3000);
    expect(state.needsBalance, 7000);
    expect(state.bufferBalance, 3000);
  });

  test('Needs caps incoming income and sends the overflow to Buffer', () {
    final state = _state(incomeType: 'Fixed', incomeRhythm: 'Irregular')
      ..needsTarget = 18000
      ..needsBalance = 16000
      ..needsPercent = 70;

    final result = state.onIncomeEvent(10000);

    expect(result.toNeeds, 2000);
    expect(result.toBuffer, 8000);
    expect(result.overflow, isTrue);
    expect(state.needsBalance, 18000);
    expect(state.bufferBalance, 8000);
  });

  test('a FakeMaya cash-in is processed only once', () async {
    final state = _state(incomeType: 'Variable', incomeRhythm: 'Irregular')
      ..needsTarget = 18000
      ..needsPercent = 70;
    final income = _cashIn(id: 'cash-in-1', amount: 10000);

    expect(
      await state.processNewIrregularIncomeTransactions([income, income]),
      1,
    );
    expect(state.needsBalance, 7000);
    expect(state.bufferBalance, 3000);
    expect(state.processedIncomeTransactionIds, contains('cash-in-1'));

    expect(
      await state.processNewIrregularIncomeTransactions([income]),
      0,
    );
    expect(state.needsBalance, 7000);
    expect(state.bufferBalance, 3000);
  });

  test('transfers and excluded entries are never treated as income', () async {
    final state = _state(incomeType: 'Variable', incomeRhythm: 'Irregular')
      ..needsTarget = 18000;
    const transfer = FakeMayaTransaction(
      id: 'transfer-1',
      title: 'Received transfer',
      detail: 'From: Personal savings',
      age: 'Just now',
      amountText: '+ ₱5000.00',
      account: 'Wallet',
    );
    const excludedCashIn = FakeMayaTransaction(
      id: 'cash-in-excluded',
      title: 'Cash in',
      detail: 'From: Freelance payment',
      age: 'Just now',
      amountText: '+ ₱5000.00',
      account: 'Wallet',
      excludedFromInsights: true,
    );
    const ownedAccountCashIn = FakeMayaTransaction(
      id: 'cash-in-owned-account',
      title: 'Cash in',
      detail: 'From: Savings',
      age: 'Just now',
      amountText: '+ ₱5000.00',
      account: 'Wallet',
    );

    expect(
      await state.processNewIrregularIncomeTransactions(
        [transfer, excludedCashIn, ownedAccountCashIn],
      ),
      0,
    );
    expect(state.jarLedger, isEmpty);
    expect(state.processedIncomeTransactionIds, isEmpty);
  });

  test('the initial FakeMaya snapshot is a baseline, not retroactive income',
      () {
    final state = _state(incomeType: 'Variable', incomeRhythm: 'Irregular');
    final historical = _cashIn(id: 'historical-cash-in', amount: 5000);
    final newCashIn = _cashIn(id: 'new-cash-in', amount: 8000);

    expect(
      state.newFakeMayaTransactionsSince(
        existingTransactions: [historical],
        refreshedTransactions: [historical],
      ),
      isEmpty,
    );
    expect(
      state.newFakeMayaTransactionsSince(
        existingTransactions: [historical],
        refreshedTransactions: [historical, newCashIn],
      ).map((transaction) => transaction.transactionId),
      ['new-cash-in'],
    );
  });

  test('processed income IDs survive irregular-income state persistence',
      () async {
    final original = _state(incomeType: 'Variable', incomeRhythm: 'Irregular')
      ..needsTarget = 18000;
    await original.processNewIrregularIncomeTransactions([
      _cashIn(id: 'cash-in-persisted', amount: 5000),
    ]);

    final restored = AppState()
      ..importIrregularIncomeState(original.exportIrregularIncomeState());

    expect(restored.effectiveVariableIncomeBaseline, 0);
    expect(
        restored.processedIncomeTransactionIds, contains('cash-in-persisted'));
  });

  test('hybrid profiles do not turn unscheduled estimates into cash', () async {
    final state = _state(incomeType: 'Both', incomeRhythm: 'Monthly')
      ..income = 50000
      ..setVariableIncomeBaseline(12000)
      ..needsTarget = 18000
      ..onboardingIncomeLedger.addAll([
        {
          'name': 'Salary',
          'amount': 38000.0,
          'stable': true,
          'scheduled': true,
        },
        {
          'name': 'Freelance work',
          'amount': 12000.0,
          'stable': false,
          'scheduled': false,
        },
      ]);

    expect(state.usesIrregularIncomeMode, isFalse);
    expect(state.hasScheduledIncomeSources, isTrue);
    expect(state.hasUnscheduledIncomeSources, isTrue);
    expect(state.usesEventBasedIncomeHandling, isTrue);
    expect(state.needsBalance, 0);
    expect(state.bufferBalance, 0);
    expect(
      await state.processNewIrregularIncomeTransactions([
        _cashIn(id: 'hybrid-freelance', amount: 8000),
      ]),
      1,
    );
    expect(state.needsBalance, 5600);
    expect(state.bufferBalance, 2400);
  });

  test('manual unscheduled income uses the same deduplicated allocation',
      () async {
    final state = _state(incomeType: 'Variable', incomeRhythm: 'Irregular')
      ..needsTarget = 18000
      ..needsPercent = 70;
    final occurredAt = DateTime(2026, 10, 8, 10);

    await state.addManualCashTransaction(
      transactionId: 'manual-freelance-1',
      title: 'Client payment',
      detail: 'Freelance project',
      amount: 10000,
      occurredAt: occurredAt,
      category: 'Business income',
      source: 'Basic Needs Fund',
    );
    await state.addManualCashTransaction(
      transactionId: 'manual-freelance-1',
      title: 'Client payment duplicate',
      detail: 'Freelance project',
      amount: 10000,
      occurredAt: occurredAt,
      category: 'Business income',
      source: 'Basic Needs Fund',
    );
    await state.addManualCashTransaction(
      transactionId: 'manual-owned-transfer',
      title: 'Transfer from savings',
      detail: 'Move money between my accounts',
      amount: 5000,
      occurredAt: occurredAt,
      category: 'Salary',
      source: 'Basic Needs Fund',
    );

    expect(state.needsBalance, 7000);
    expect(state.bufferBalance, 3000);
    expect(state.processedIncomeTransactionIds, contains('manual-freelance-1'));
    expect(state.processedIncomeTransactionIds,
        isNot(contains('manual-owned-transfer')));
  });

  test('received income batches save one final allocation state', () async {
    final state = _state(incomeType: 'Variable', incomeRhythm: 'Irregular')
      ..needsTarget = 18000
      ..needsPercent = 70;

    expect(
      await state.processNewIrregularIncomeTransactions([
        _cashIn(id: 'batch-1', amount: 10000),
        _cashIn(id: 'batch-2', amount: 10000),
      ]),
      2,
    );
    expect(state.needsBalance, 14000);
    expect(state.bufferBalance, 6000);
    expect(state.jarLedger, hasLength(2));
  });
}
