import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'Accumulating Wealth mock overwrite seeds four months of actionable data',
      () async {
    final state = AppState()..seedAccumulatingWealthMockDataForTesting();
    final summary = state.fakeMayaLink!.summary;
    final transactions = summary.transactions;
    final transactionMonths = {
      for (final transaction in transactions)
        if (transaction.createdAt case final createdAt?)
          '${createdAt.year}-${createdAt.month}',
    };
    final currentMonthInvestmentDeposits = state.d1Ledger.where((entry) {
      final date = DateTime.tryParse(entry['date']?.toString() ?? '');
      return entry['type'] == 'investment_deposit' &&
          date != null &&
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month;
    }).toList();

    expect(state.canOverwriteWithMockData, isTrue);
    expect(state.mockDataEnabled, isTrue);
    expect(state.selectedGoalId, 'G5');
    expect(state.primaryConcern, 'Accumulating Wealth');
    expect(state.selectedActionIds, containsAll(['A12', 'A23', 'A30']));
    expect(state.actionFieldValues['A12']?['pct'], '10');
    expect(state.actionFieldValues['A23']?['amt'], '120000');
    expect(state.actionFieldValues['A30']?['pct'], '12');
    expect(transactionMonths.length, 4);
    expect(transactions.length, greaterThanOrEqualTo(30));
    expect(currentMonthInvestmentDeposits, isNotEmpty);
    expect(
      currentMonthInvestmentDeposits
          .map((entry) => (entry['amount'] as num).toDouble()),
      contains(2900),
    );
    expect(summary.investmentHoldings.map((holding) => holding.symbol),
        containsAll(['BTC', 'NVDA']));
    expect(summary.investmentTransactions.length, greaterThanOrEqualTo(3));
    expect(
        state.investmentPortfolioValue, greaterThan(state.investmentBalance));
    expect(state.investmentPortfolioValue / 120000, greaterThan(.75));
    expect(state.investmentPortfolioValue / 120000, lessThan(1));
    expect(state.investmentAnnualizedReturnPercent, greaterThan(0));
    expect(
      summary.personalGoalById(FakeMayaPersonalGoal.investmentFundId)?.balance,
      state.investmentBalance,
    );
    expect(
      summary.personalGoalById(FakeMayaPersonalGoal.investmentFundId)?.target,
      120000,
    );

    final beforeRefresh = summary.toMap();
    await state.refreshFakeMayaAccount();
    expect(state.fakeMayaLink!.summary.toMap(), beforeRefresh);
    await state.refreshFakeMayaAssetPrices();
    expect(state.fakeMayaLink!.summary.toMap(), beforeRefresh);
  });
}
