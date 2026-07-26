import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reflection demo baselines support every Goals-screen goal', () {
    final state = AppState()..seedReflectionDemoDataForTesting();

    expect(state.onboardingIncomeLedger, hasLength(1));
    expect(state.onboardingExpenseLedger, hasLength(9));
    expect(state.income, 32000);
    expect(state.monthlyExpenseLedgerTotal, 15198);
    expect(state.monthlyEssentialExpenseTotal, 9000);
    expect(
      state.onboardingExpenseLedger.map(expenseLayerForLedger).toSet(),
      ExpenseLayer.values.toSet(),
    );
    expect(state.monthlySurplus, 18002);
    expect(state.selectedGoalId, 'G1');
    expect(state.selectedActionIds, hasLength(16));
    expect(state.actionFieldValues['A22']?['months'], '3');
    expect(state.actionFieldValues['A29'], {
      'amt': '12000',
      'months': '6',
    });
    expect(state.selectedGoalMonthlyTarget, 4000);
    expect(state.requiredMonthlyContribution, 4000);
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
    expect(state.emergencyMonths, closeTo(26500 / 9000, .001));
    expect(state.investmentBalance, 32000);
    expect(state.investmentEarningsThisMonth, 900);
    expect(state.investmentLossesThisMonth, 250);
    expect(state.lifestyleFundBalance, 2800);
    expect(state.lifestyleActivityBalance, 3500);
    expect(state.lifestyleReservedThisMonth, 1200);
    expect(
      state.allTransactions.any(
        (transaction) => transaction.source == 'Lifestyle Fund',
      ),
      isTrue,
    );
  });

  test('reflection demo leaves useful next actions across all goals', () {
    final state = AppState()..seedReflectionDemoDataForTesting();
    final latestIncome = state.allTransactions
        .where((transaction) => transaction.amount > 0)
        .reduce((a, b) => (a.createdAt ?? DateTime(2000)).isAfter(
              b.createdAt ?? DateTime(2000),
            )
                ? a
                : b);

    expect(
      state.hasEssentialAllocationForIncome(latestIncome.transactionId),
      isFalse,
    );
    expect(
      state.hasEmergencyAllocationForIncome(latestIncome.transactionId),
      isFalse,
    );
    expect(
      state.hasInvestmentAllocationForIncome(latestIncome.transactionId),
      isFalse,
    );
    expect(
      state.hasLifestylePaydayAllocation(latestIncome.transactionId),
      isFalse,
    );
    expect(state.pendingEmergencyReplenishment, greaterThan(0));
    expect(state.investedThisMonth, 3500);
    expect(state.lifestyleReservedThisMonth, lessThan(2100));
    expect(state.lifestyleActivityBalance, lessThan(12000));
  });

  testWidgets('reflection demo renders every configured goal screen',
      (tester) async {
    final state = AppState()..seedReflectionDemoDataForTesting();
    const expectations = {
      'G1': 'Bring in at least',
      'G3': 'Emergency Fund each month',
      'G5': 'Build the Investment Portfolio',
      'G8': 'subscriptions and memberships',
    };

    for (final entry in expectations.entries) {
      await tester.pumpWidget(
        AppScope(
          state: state,
          child: MaterialApp(
            home: Scaffold(
              body: GoalsPage(
                key: ValueKey(entry.key),
                initialGoalId: entry.key,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining(entry.value), findsWidgets);
    }
  });
}
