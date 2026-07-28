import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Cash Flow mock overwrite seeds four months of actionable data',
      () async {
    final state = AppState()..seedCashFlowMockDataForTesting();
    final transactions = state.fakeMayaLink!.summary.transactions;
    final transactionMonths = {
      for (final transaction in transactions)
        if (transaction.createdAt case final createdAt?)
          '${createdAt.year}-${createdAt.month}',
    };

    expect(state.canOverwriteWithMockData, isTrue);
    expect(state.mockDataEnabled, isTrue);
    expect(state.selectedGoalId, 'G1');
    expect(state.primaryConcern, 'Cash Flow & Basic Needs');
    expect(state.selectedActionIds, containsAll(['A1', 'A3', 'A20', 'A19']));
    expect(state.selectedActionIds, isNot(contains('A8')));
    expect(state.actionFieldValues['A1']?['pct'], '55');
    expect(
        state.actionFieldValues['A3']?['categories'], 'Food & drink,Transport');
    expect(state.actionFieldValues['A20']?['amt'], '30000');
    expect(state.actionFieldValues['A19']?['amt'], '9000');
    expect(transactionMonths.length, 4);
    expect(transactions.length, greaterThanOrEqualTo(40));
    expect(state.monthlyEssentialExpenseTotal, greaterThan(0));
    expect(state.essentialExpensesBalance, greaterThan(0));
    expect(
      state.fakeMayaLink!.summary
          .personalGoalById(FakeMayaPersonalGoal.essentialExpenseFundId)
          ?.balance,
      state.essentialExpensesBalance,
    );
    expect(
      state.d1Ledger.where((entry) {
        final date = DateTime.tryParse(entry['date']?.toString() ?? '');
        return entry['type'] == 'essential_deposit' &&
            date != null &&
            date.year == DateTime.now().year &&
            date.month == DateTime.now().month;
      }).length,
      greaterThanOrEqualTo(2),
    );
    expect(
      state.fakeMayaLink!.summary.transactions.where(
        (transaction) =>
            transaction.amount < 0 &&
            transaction.source == 'Basic Needs Fund' &&
            transaction.isLabeled,
      ),
      isNotEmpty,
    );

    final beforeRefresh = state.fakeMayaLink!.summary.toMap();
    await state.refreshFakeMayaAccount();
    expect(state.fakeMayaLink!.summary.toMap(), beforeRefresh);
  });
}
