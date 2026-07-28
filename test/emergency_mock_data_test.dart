import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Emergency Fund mock overwrite seeds four months of actionable data',
      () async {
    final state = AppState()..seedEmergencyFundMockDataForTesting();
    final transactions = state.fakeMayaLink!.summary.transactions;
    final transactionMonths = {
      for (final transaction in transactions)
        if (transaction.createdAt case final createdAt?)
          '${createdAt.year}-${createdAt.month}',
    };
    final latestIncome = transactions.firstWhere(
      (transaction) =>
          transaction.amount > 0 &&
          transaction.title.toLowerCase().contains('cash in'),
    );
    final configuredCoverageMonths =
        double.parse(state.actionFieldValues['A22']!['months']!);
    final configuredCoverageTarget =
        state.monthlyEssentialExpenseTotal * configuredCoverageMonths;
    final sixMonthGoalTarget = state.monthlyEssentialExpenseTotal * 6;

    expect(state.canOverwriteWithMockData, isTrue);
    expect(state.mockDataEnabled, isTrue);
    expect(state.selectedGoalId, 'G3');
    expect(state.primaryConcern, 'Financial Safety');
    expect(state.selectedActionIds, containsAll(['A9', 'A8', 'A22', 'A10']));
    expect(state.actionFieldValues['A8']?['pct'], '10');
    expect(state.actionFieldValues['A9']?['amt'], '6500');
    expect(state.actionFieldValues['A22']?['months'], '3');
    expect(state.actionFieldValues['A10']?['days'], '5');
    expect(state.safetyShieldTargetMonths, 6);
    expect(transactionMonths.length, 4);
    expect(transactions.length, greaterThanOrEqualTo(35));
    expect(state.pendingEmergencyReplenishment, 5600);
    expect(
      state.d1Ledger.where((entry) {
        final date = DateTime.tryParse(entry['date']?.toString() ?? '');
        return entry['type'] == 'emergency_deposit' &&
            date != null &&
            date.year == DateTime.now().year &&
            date.month == DateTime.now().month;
      }).map((entry) => (entry['amount'] as num).toDouble()),
      containsAll([500, 800, 600, 250, 2100]),
    );
    expect(
      state.d1Ledger.where((entry) {
        final date = DateTime.tryParse(entry['date']?.toString() ?? '');
        return entry['type'] == 'use_emergency' &&
            date != null &&
            date.year == DateTime.now().year &&
            date.month == DateTime.now().month;
      }),
      hasLength(2),
    );
    expect(
      state.hasEmergencyAllocationForIncome(latestIncome.transactionId),
      isTrue,
    );
    expect(state.unallocatedFakeMayaWallet, greaterThan(5600));
    expect(state.monthlyEssentialExpenseTotal, greaterThan(0));
    expect(
      state.displayedEmergencyFundBalance / configuredCoverageTarget,
      greaterThanOrEqualTo(.80),
    );
    expect(
      state.displayedEmergencyFundBalance / configuredCoverageTarget,
      lessThan(1),
    );
    expect(state.displayedEmergencyFundBalance,
        lessThan(configuredCoverageTarget));
    expect(
      state.d1Ledger.where((entry) {
        final date = DateTime.tryParse(entry['date']?.toString() ?? '');
        return entry['type'] == 'emergency_deposit' &&
            date != null &&
            date.year == DateTime.now().year &&
            date.month == DateTime.now().month;
      }).fold<double>(
        0,
        (total, entry) => total + (entry['amount'] as num).toDouble(),
      ),
      6350,
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
      sixMonthGoalTarget,
    );

    final beforeRefresh = state.fakeMayaLink!.summary.toMap();
    await state.refreshFakeMayaAccount();
    expect(state.fakeMayaLink!.summary.toMap(), beforeRefresh);
  });
}
