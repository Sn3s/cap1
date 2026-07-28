import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Financial Freedom mock overwrite seeds four months of actionable data',
      () async {
    final state = AppState()..seedFinancialFreedomMockDataForTesting();
    final summary = state.fakeMayaLink!.summary;
    final transactions = summary.transactions;
    final transactionMonths = {
      for (final transaction in transactions)
        if (transaction.createdAt case final createdAt?)
          '${createdAt.year}-${createdAt.month}',
    };
    final currentMonthLifestylePaydays = state.d1Ledger.where((entry) {
      final date = DateTime.tryParse(entry['date']?.toString() ?? '');
      return entry['type'] == 'lifestyle_payday' &&
          date != null &&
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month;
    }).toList();
    final currentMonthSubscriptionReserve = state.d1Ledger.where((entry) {
      final date = DateTime.tryParse(entry['date']?.toString() ?? '');
      return entry['type'] == 'lifestyle_subscription_reserve' &&
          date != null &&
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month;
    }).toList();

    expect(state.canOverwriteWithMockData, isTrue);
    expect(state.mockDataEnabled, isTrue);
    expect(state.selectedGoalId, 'G8');
    expect(state.primaryConcern, 'Financial Freedom');
    expect(state.selectedActionIds, containsAll(['A26', 'A27', 'A28', 'A29']));
    expect(state.actionFieldValues['A26']?['amt'], '2500');
    expect(state.actionFieldValues['A27']?['amt'], '1500');
    expect(state.actionFieldValues['A28']?['amt'], '2200');
    expect(state.actionFieldValues['A29']?['amt'], '45000');
    expect(transactionMonths.length, 4);
    expect(transactions.length, greaterThanOrEqualTo(35));
    expect(state.lifestyleHobbies.length, 3);
    expect(currentMonthLifestylePaydays.length, greaterThanOrEqualTo(1));
    expect(
      currentMonthLifestylePaydays
          .map((entry) => (entry['amount'] as num).toDouble()),
      contains(1500),
    );
    expect(
      currentMonthSubscriptionReserve
          .map((entry) => (entry['amount'] as num).toDouble()),
      contains(2500),
    );
    expect(
      transactions.where(
        (transaction) =>
            transaction.amount < 0 &&
            transaction.source == 'Lifestyle Fund' &&
            transaction.isLabeled,
      ),
      isNotEmpty,
    );
    expect(
      summary
          .personalGoalById(FakeMayaPersonalGoal.personalLifestyleFundId)
          ?.balance,
      state.lifestyleFundBalance,
    );
    expect(
      summary
          .personalGoalById(FakeMayaPersonalGoal.personalLifestyleFundId)
          ?.target,
      54000,
    );

    final beforeRefresh = summary.toMap();
    await state.refreshFakeMayaAccount();
    expect(state.fakeMayaLink!.summary.toMap(), beforeRefresh);
  });
}
