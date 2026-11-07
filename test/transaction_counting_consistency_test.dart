import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

FakeMayaTransaction _expense(
  String id,
  double amount, {
  required DateTime date,
  bool excluded = false,
  String title = 'Merchant purchase',
  String? category = 'Food & drink',
  String? source = 'Basic Needs Fund',
}) =>
    FakeMayaTransaction(
      id: id,
      title: title,
      detail: 'Test record',
      age: 'Just now',
      amountText: '-₱${amount.toStringAsFixed(2)}',
      createdAt: date,
      category: category,
      source: source,
      excludedFromInsights: excluded,
    );

void main() {
  test('analysis, goals, Health Score, and Chat share counted transactions',
      () {
    final now = AppClock.now();
    final state = AppState()
      ..onboardingExpenseLedger.add({
        'name': 'Food plan',
        'amount': 200.0,
        'essential': true,
        'expenseType': ExpenseLayer.basicNeeds.name,
        'scheduled': false,
      })
      ..categorySpendingBudgets['Food & drink'] = 200
      ..selectedActionIds.add('A3')
      ..manualTransactions.addAll([
        _expense('counted', 100, date: now),
        _expense(
          'transfer',
          300,
          date: now,
          title: 'Fund transfer',
          category: 'Transfer',
          source: 'E-wallet',
        ),
        _expense(
          'excluded',
          120,
          date: now,
          excluded: true,
          title: 'Excluded purchase',
        ),
        _expense(
          'unlabelled',
          70,
          date: now,
          category: null,
          source: null,
        ),
      ]);

    expect(state.categoryBudgetSpent('Food & drink'), 100);
    expect(isCashFlowGoalOnTrack(state), isTrue);

    final integration = IntegrationService.fromState(state);
    final integratedSpend = integration.weekRecords
        .fold(0.0, (total, week) => total + week.weekExpense);
    expect(integratedSpend, 100);

    final health = computeHealthScore(state);
    final categoryBudget =
        health.actions.singleWhere((action) => action.actionId == 'A3');
    expect(categoryBudget.detail, contains('100'));
    expect(categoryBudget.completion, 1);

    const coach = ShellbyAiCoach();
    final chatInput = coach.chatInputForTesting(
      state,
      const [ChatMessage(true, 'How much did I spend on food?')],
    );
    expect(chatInput, contains('1 labelled, non-transfer record'));
    expect(chatInput, contains('spending ₱ 100.00'));
    expect(chatInput, isNot(contains('Fund transfer')));
    expect(chatInput, isNot(contains('Excluded purchase')));
  });

  test('a removable manual entry reverses its local balance and disappears',
      () async {
    final state = AppState();
    final timestamp = AppClock.now();
    await state.addManualCashTransaction(
      transactionId: 'manual-gift',
      title: 'Birthday gift',
      detail: 'From family',
      amount: 500,
      occurredAt: timestamp,
      category: 'Gift',
      source: 'Cash on Hand',
    );

    expect(state.cashOnHandBalance, 500);
    expect(state.canDeleteManualTransaction('manual-gift'), isTrue);
    expect(await state.deleteManualTransaction('manual-gift'), isTrue);
    expect(state.cashOnHandBalance, 0);
    expect(state.manualTransactions, isEmpty);
  });
}
