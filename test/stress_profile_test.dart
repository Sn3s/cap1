import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final count in [100, 1000, 10000]) {
    test('local stress profile seeds $count coherent transactions', () {
      final state = AppState()..seedStressTestDataForTesting(count);
      final summary = state.fakeMayaLink!.summary;
      final now = AppClock.now();

      expect(state.mockDataEnabled, isTrue);
      expect(state.fakeMayaLink!.provider, 'mock');
      expect(summary.transactions, hasLength(count));
      expect(summary.personalGoals, hasLength(4));
      expect(
        summary.transactions.every(
          (transaction) =>
              transaction.createdAt == null ||
              !transaction.createdAt!.isAfter(now),
        ),
        isTrue,
      );
      expect(
        summary.transactions.where((transaction) => transaction.isLabeled),
        isNotEmpty,
      );
      expect(
        summary.transactions
            .where((transaction) => transaction.needsFinancialLabel),
        isNotEmpty,
      );
      expect(
        summary.transactions
            .where((transaction) => transaction.isInternalFakeMayaTransfer),
        isNotEmpty,
      );
      expect(state.recurringTransactionSuggestions, isNotEmpty);

      // The stress profile is an end-to-end financial history, not just a
      // large table used to exercise pagination. Its transaction sources and
      // the production ledger must agree so every screen is stressing the
      // same calculation snapshot.
      final incomeTransactions = summary.transactions
          .where((transaction) => transaction.amount > 0)
          .toList();
      expect(incomeTransactions, isNotEmpty);
      for (final income in incomeTransactions) {
        expect(
          state.d1Ledger.where((entry) =>
              entry['type'] == 'payday_allocation_plan' &&
              entry['sourceTransactionId'] == income.transactionId),
          hasLength(1),
        );
      }
      for (final source in const [
        ('Basic Needs Fund', 'use_essential'),
        ('Emergency Fund', 'use_emergency'),
        ('Personal Lifestyle Fund', 'lifestyle_spend'),
      ]) {
        final sourcedTransactions = summary.transactions
            .where((transaction) => transaction.source == source.$1)
            .toList();
        final ledgerTransactions = state.d1Ledger
            .where((entry) => entry['type'] == source.$2)
            .map((entry) => entry['sourceTransactionId'])
            .toSet();
        expect(sourcedTransactions, isNotEmpty);
        expect(
          sourcedTransactions.every(
            (transaction) => ledgerTransactions.contains(transaction.transactionId),
          ),
          isTrue,
        );
      }
      expect(state.jarLedger, isNotEmpty);
      expect(state.investmentValuationHistory, hasLength(13));
      expect(state.pendingEmergencyReplenishment, greaterThan(0));
      expect(state.actionFieldValues['A1']?['pct'], '35');
      expect(
        state.essentialExpensesBalance,
        closeTo(summary.essentialExpenseFund!.balance, .001),
      );
      expect(
        state.investmentBalance,
        closeTo(summary.investmentFund!.balance, .001),
      );
      expect(
        state.lifestyleFundBalance,
        closeTo(summary.personalLifestyleFund!.balance, .001),
      );
    });
  }
}
