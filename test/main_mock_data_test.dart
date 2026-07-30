import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Main mock overwrite seeds cash flow and emergency fund data', () async {
    final state = AppState()..seedMainMockDataForTesting();
    final transactions = state.fakeMayaLink!.summary.transactions;
    final transactionMonths = {
      for (final transaction in transactions)
        if (transaction.createdAt case final createdAt?)
          '${createdAt.year}-${createdAt.month}',
    };

    expect(state.canOverwriteWithMockData, isTrue);
    expect(state.mockDataEnabled, isTrue);
    expect(state.email, 'main@gmail.com');
    expect(state.selectedGoalId, 'G1');
    expect(state.primaryConcern, 'Cash Flow & Basic Needs');
    expect(state.addedGoalIds, contains('G3'));
    expect(
      state.selectedActionIds,
      containsAll(['A1', 'A3', 'A20', 'A19', 'A9', 'A8', 'A22', 'A10']),
    );
    expect(state.actionFieldValues['A1']?['pct'], '55');
    expect(state.actionFieldValues['A8']?['pct'], '10');
    expect(state.actionFieldValues['A9']?['amt'], '4200');
    expect(state.actionFieldValues['A22']?['months'], '3');
    expect(transactionMonths.length, 4);
    expect(transactions.length, greaterThanOrEqualTo(50));
    expect(state.essentialExpensesBalance, greaterThan(0));
    expect(state.displayedEmergencyFundBalance, greaterThan(0));
    expect(state.pendingEmergencyReplenishment, 3600);
    expect(
      state.confirmedFakeMayaBucketMotivations,
      containsAll(['Cash Flow & Basic Needs', 'Financial Safety']),
    );
    expect(
      state.d1Ledger.where((entry) => entry['type'] == 'essential_deposit'),
      isNotEmpty,
    );
    expect(
      state.d1Ledger.where((entry) => entry['type'] == 'emergency_deposit'),
      isNotEmpty,
    );
    expect(
      state.d1Ledger.where((entry) => entry['type'] == 'use_emergency'),
      isNotEmpty,
    );
    expect(
      state.fakeMayaLink!.summary
          .personalGoalById(FakeMayaPersonalGoal.essentialExpenseFundId)
          ?.balance,
      state.essentialExpensesBalance,
    );
    expect(
      state.fakeMayaLink!.summary
          .personalGoalById(FakeMayaPersonalGoal.emergencyFundId)
          ?.balance,
      state.emergencyFundBalance,
    );
    expect(
      state.fakeMayaLink!.summary
          .personalGoalById(FakeMayaPersonalGoal.emergencyFundId)
          ?.target,
      state.monthlyEssentialExpenseTotal * 6,
    );
    expect(
      transactions.where(
        (transaction) =>
            transaction.amount < 0 &&
            transaction.source == 'Emergency Fund' &&
            transaction.isLabeled,
      ),
      isNotEmpty,
    );

    final beforeRefresh = state.fakeMayaLink!.summary.toMap();
    await state.refreshFakeMayaAccount();
    expect(state.fakeMayaLink!.summary.toMap(), beforeRefresh);
  });
}
