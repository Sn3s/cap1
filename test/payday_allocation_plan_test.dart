import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AppState seeded({double wallet = 20000}) {
    final state = AppState()
      ..seedMainMockDataForTesting()
      ..onboardingComplete = false;
    state.selectedActionIds
      ..clear()
      ..addAll(const {'A1', 'A8', 'A12', 'A27'});
    state.actionFieldValues
      ..clear()
      ..addAll({
        'A1': {'pct': '55'},
        'A8': {'pct': '10'},
        'A12': {'pct': '10'},
        'A27': {'pct': '10'},
      });
    state.billObligations.clear();
    final link = state.fakeMayaLink!;
    state.fakeMayaLink = FakeMayaLink(
      userId: link.userId,
      email: link.email,
      name: link.name,
      phone: link.phone,
      provider: link.provider,
      accessToken: link.accessToken,
      refreshToken: link.refreshToken,
      expiresAt: link.expiresAt,
      summary: link.summary.copyWith(wallet: wallet),
    );
    state.billsObligationsBalance = 0;
    return state;
  }

  FakeMayaTransaction income(String id, {double amount = 10000}) =>
      FakeMayaTransaction(
        id: id,
        title: 'Salary received',
        detail: 'Employer payroll',
        age: 'Just now',
        amountText: '+ ₱${amount.toStringAsFixed(2)}',
        category: 'Salary',
        source: 'Wallet',
        createdAt: AppClock.now(),
      );

  test('a multi-goal payday plan never allocates more than its income', () {
    final state = seeded();
    final payday = income('payday-1');
    state.manualTransactions.add(payday);

    final plan = state.paydayAllocationPlanFor(payday);

    expect(state.usesCoordinatedPaydayAllocationPlan, isTrue);
    expect(state.pendingPaydayAllocationTransactions, contains(payday));
    expect(plan.essentialExpenses, 5500);
    expect(plan.emergencyFund, 1000);
    expect(plan.investmentFund, 1000);
    expect(plan.lifestyleFund, 1000);
    expect(plan.unpaidBills, 0);
    expect(plan.committed, 8500);
    expect(plan.unassigned, 1500);
    expect(plan.committed + plan.unassigned, payday.amount);
  });

  test('Basic Needs bills take priority over lower layers', () async {
    final state = seeded();
    final payday = income('payday-with-bill');
    state.manualTransactions.add(payday);
    await state.recordBasicNeedsBillPlan(
      sourceExpenseKey: 'rent',
      name: 'Rent',
      expectedAmount: 3000,
      fromEssentialFund: 0,
      fromWallet: 3000,
      fromSavings: 0,
      dueDate: AppClock.now().add(const Duration(days: 3)),
    );

    final plan = state.paydayAllocationPlanFor(payday);

    expect(plan.unpaidBills, 3000);
    expect(plan.essentialExpenses, 5500);
    expect(plan.emergencyFund, 1000);
    expect(plan.investmentFund, 500);
    expect(plan.lifestyleFund, 0);
    expect(plan.shortfall, 1500);
    expect(plan.committed, payday.amount);
  });

  test('applying the plan updates each fund once and closes the income queue',
      () async {
    final state = seeded();
    final payday = income('payday-apply');
    state.manualTransactions.add(payday);
    final walletBefore = state.fakeMayaLink!.summary.wallet;
    final essentialBefore = state.essentialExpensesBalance;
    final emergencyBefore = state.emergencyFundBalance;
    final investmentBefore = state.investmentBalance;
    final lifestyleBefore = state.lifestyleFundBalance;

    final plan = await state.applyPaydayAllocationPlan(payday);

    expect(state.fakeMayaLink!.summary.wallet,
        walletBefore - plan.totalFundTransfers);
    expect(state.essentialExpensesBalance,
        closeTo(essentialBefore + plan.essentialExpenses, .01));
    expect(state.emergencyFundBalance,
        closeTo(emergencyBefore + plan.emergencyFund, .01));
    expect(state.investmentBalance,
        closeTo(investmentBefore + plan.investmentFund, .01));
    expect(state.lifestyleFundBalance,
        closeTo(lifestyleBefore + plan.lifestyleFund, .01));
    expect(state.hasCoordinatedPaydayAllocationForIncome(payday.transactionId),
        isTrue);
    expect(
      state.pendingPaydayAllocationTransactions
          .map((transaction) => transaction.transactionId),
      isNot(contains(payday.transactionId)),
    );
    expect(
      state.d1Ledger
          .where(
              (entry) => entry['sourceTransactionId'] == payday.transactionId)
          .map((entry) => entry['type']),
      containsAll(const [
        'essential_deposit',
        'emergency_deposit',
        'investment_deposit',
        'lifestyle_payday',
        'payday_allocation_plan',
      ]),
    );
  });
}
