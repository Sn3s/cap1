import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<AppState> manuallyTrackedCashFlowState() async {
    final state = AppState();
    final now = AppClock.now();
    state.onboardingExpenseLedger.add({
      'name': 'Groceries and transport',
      'amount': 1000.0,
      'essential': true,
      'expenseType': ExpenseLayer.basicNeeds.name,
      'scheduled': false,
      'dueDay': null,
    });
    state.appOpenDays.add(now.toIso8601String().substring(0, 10));
    await state.addManualCashTransaction(
      title: 'Part-time salary',
      detail: 'Campus payroll',
      amount: 2000,
      occurredAt: now,
      category: 'Salary',
      source: 'Cash on Hand',
    );
    await state.addManualCashTransaction(
      title: 'Groceries',
      detail: 'Market',
      amount: -200,
      occurredAt: now,
      category: 'Food & drink',
      source: 'Cash on Hand',
    );
    return state;
  }

  test('manual cash activity drives Cash Flow goal progress', () async {
    final state = await manuallyTrackedCashFlowState();

    expect(state.fakeMayaLink, isNull);
    expect(state.availableCashForGoals, 1800);
    expect(isCashFlowGoalOnTrack(state), isTrue);
    expect(cashFlowGoalPercent(state), greaterThan(0));
  });

  test('Cash Flow combines synced Wallet and manual cash exactly once',
      () async {
    final state = await manuallyTrackedCashFlowState()
      ..fakeMayaLink = FakeMayaLink(
        userId: 'linked-user',
        email: 'linked@example.com',
        name: 'Linked user',
        phone: '',
        provider: 'email',
        accessToken: '',
        refreshToken: '',
        expiresAt: null,
        summary: FakeMayaAccountSummary(
          wallet: 700,
          savings: 0,
          timeDeposit: 0,
          goalName: 'Personal Goal',
          goalEmoji: '',
          goalBalance: 0,
          goalTarget: 0,
          creditLimit: 0,
          creditUsed: 0,
          transactions: const [],
          updatedAt: null,
        ),
      );

    await state.setAccountFakeMayaSync('Wallet', true);

    expect(state.allTransactions, hasLength(2));
    expect(state.accountBalance('Wallet'), 700);
    expect(state.accountBalance('Cash on Hand'), 1800);
    expect(state.availableCashForGoals, 2500);
    expect(isCashFlowGoalOnTrack(state), isTrue);
  });

  test('manual income is counted by the Health Score cash-in action', () async {
    final state = await manuallyTrackedCashFlowState();
    state.selectedActionIds
      ..clear()
      ..add('A20');
    state.actionFieldValues['A20'] = {'amt': '1500'};

    final breakdown = computeHealthScore(state);
    final cashIn =
        breakdown.actions.singleWhere((action) => action.actionId == 'A20');

    expect(cashIn.completion, 1);
    expect(cashIn.detail, contains('2,000'));
  });

  test('manual spending continues to drive category-budget health', () async {
    final state = await manuallyTrackedCashFlowState();
    state.selectedActionIds
      ..clear()
      ..add('A3');
    // Matches the category canonicalized by the manual-entry form.
    state.categorySpendingBudgets['Groceries / Food'] = 500;

    final breakdown = computeHealthScore(state);
    final budget =
        breakdown.actions.singleWhere((action) => action.actionId == 'A3');

    expect(budget.completion, 1);
    expect(budget.detail, contains('200'));
  });

  test('manual income does not count as a missed unverified fund transfer',
      () async {
    final state = await manuallyTrackedCashFlowState();
    state.selectedActionIds
      ..clear()
      ..add('A1');

    final breakdown = computeHealthScore(state);
    final essential =
        breakdown.actions.singleWhere((action) => action.actionId == 'A1');

    expect(essential.completion, isNull);
    expect(essential.detail, contains('Link FakeMaya'));
    expect(breakdown.deductions.where((item) => item.code == 'D3'), isEmpty);
  });
}
