import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reflection demo onboarding baselines support its selected goal', () {
    final state = AppState()..seedReflectionDemoDataForTesting();

    expect(state.onboardingIncomeLedger, hasLength(1));
    expect(state.onboardingExpenseLedger, hasLength(4));
    expect(state.income, 15800);
    expect(state.monthlyExpenseLedgerTotal, 9000);
    expect(state.monthlyEssentialExpenseTotal, 9000);
    expect(state.expenses + state.variableExpenses, 9000);
    expect(state.monthlySurplus, 6800);
    expect(state.selectedGoalMonthlyTarget, 1350);
    expect(state.requiredMonthlyContribution, 1350);
    expect(state.feasibilityScore, greaterThanOrEqualTo(70));
  });

  test('reflection demo goal insights use aligned targets and funds', () {
    final state = AppState()..seedReflectionDemoDataForTesting();
    final integration = IntegrationService.fromState(state);
    final emergencyTransactions = state.allTransactions
        .where((transaction) => transaction.source == 'Emergency Fund')
        .toList();
    final basicNeedsTransactions = state.allTransactions
        .where((transaction) => transaction.source == 'Basic Needs Fund')
        .toList();

    expect(integration.needsTarget, 9000);
    expect(integration.bufferTarget, closeTo(3857.14, .01));
    expect(emergencyTransactions, isNotEmpty);
    expect(
      emergencyTransactions.every(
        (transaction) => transaction.category == 'Health',
      ),
      isTrue,
    );
    expect(
      basicNeedsTransactions.any(
        (transaction) => transaction.category == 'Bills & utilities',
      ),
      isTrue,
    );
    expect(state.emergencyFundTarget, 27000);
    expect(state.emergencyMonths, closeTo(11000 / 9000, .001));
  });
}
