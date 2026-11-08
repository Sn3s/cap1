import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
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
            (transaction) =>
                ledgerTransactions.contains(transaction.transactionId),
          ),
          isTrue,
        );
      }
      expect(state.jarLedger, isNotEmpty);
      expect(state.investmentValuationHistory, hasLength(13));
      expect(state.pendingEmergencyReplenishment, greaterThan(0));
      expect(state.actionFieldValues['A1']?['pct'], '35');
      final integration = IntegrationService.fromState(state);
      final expectedBasicNeedsSpend = summary.transactions
          .where((transaction) =>
              transaction.amount < 0 &&
              transaction.countsTowardFinancialInsights &&
              transaction.source == 'Basic Needs Fund')
          .fold<double>(
            0,
            (total, transaction) => total + transaction.amount.abs(),
          );
      expect(integration.dayRecords, isNotEmpty);
      expect(integration.weekRecords, isNotEmpty);
      expect(
        integration.weekRecords.fold<double>(
          0,
          (total, week) => total + week.weekExpense,
        ),
        closeTo(expectedBasicNeedsSpend, .001),
      );
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

  testWidgets('10,000 transaction profile mounts Goals and Insights',
      (tester) async {
    final state = AppState()..seedStressTestDataForTesting(10000);
    expect(state.consentAi, isFalse);

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: GoalsPage())),
      ),
    );
    expect(find.text('Preparing your history'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Preparing your history'), findsNothing);
    expect(find.byType(GoalsPage), findsOneWidget);

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: InsightsPage())),
      ),
    );
    expect(find.text('Preparing your history'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Goal Insights'), findsOneWidget);
    await tester.tap(find.text('Available cash'));
    await tester.pump();
    expect(find.text('Available Cash'), findsOneWidget);
  });

  testWidgets('local stress profile can explicitly enable Shellby chat',
      (tester) async {
    final state = AppState()..seedStressTestDataForTesting(100);
    expect(state.isSignedIn, isFalse);
    expect(state.isLocalStressTestProfile, isTrue);
    expect(state.consentAi, isFalse);

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: CommunityPrivacyScreen()),
      ),
    );
    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    expect(state.consentAi, isTrue);
  });

  test('local stress profile signs out without Firebase', () async {
    final state = AppState()..seedStressTestDataForTesting(100);

    await state.signOut();

    expect(state.isLocalStressTestProfile, isFalse);
    expect(state.fakeMayaLink, isNull);
    expect(state.email, isEmpty);
    expect(state.consentAi, isFalse);
  });
}
