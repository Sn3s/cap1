import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Checks the approved point system:
//   Score = 85 x sum(w x completion) / sum(w) + Engagement (15) - Deductions
void main() {
  final now = DateTime.now();

  /// One salary 5 days ago, only the given actions active, opened every day
  /// for 30 days (E1 = 10). The salary is unlabelled but younger than 7 days,
  /// so E2 = 0 and there's no D7.
  AppState scenario({
    required Set<String> actions,
    double? investedFromSalary,
  }) {
    final state = AppState()
      ..seedAccumulatingWealthMockDataForTesting()
      ..onboardingComplete = false;
    state.selectedActionIds
      ..clear()
      ..addAll(actions);
    state.actionFieldValues['A12'] = {'pct': '10'};
    state.d1Ledger.clear();
    state.investmentValuationHistory.clear();
    state.loginStreakBreaks.clear();
    state.appOpenDays
      ..clear()
      ..addAll([
        for (var i = 0; i < 30; i++)
          now.subtract(Duration(days: i)).toIso8601String().substring(0, 10),
      ]);
    final salary = FakeMayaTransaction(
      id: 'salary-1',
      title: 'Cash in',
      detail: 'From: Employer payroll',
      age: '5 days ago',
      amountText: '+ ₱10,000.00',
      createdAt: now.subtract(const Duration(days: 5)),
    );
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
      summary: link.summary.copyWith(transactions: [salary]),
    );
    if (investedFromSalary != null) {
      state.d1Ledger.add({
        'type': 'investment_deposit',
        'date': now.subtract(const Duration(days: 4)).toIso8601String(),
        'sourceTransactionId': 'salary-1',
        'amount': investedFromSalary,
      });
    }
    return state;
  }

  test('1 action done fully: 85 action points + engagement', () {
    final breakdown = computeHealthScore(
      scenario(actions: {'A12'}, investedFromSalary: 1000),
    );
    expect(breakdown.actionPoints, closeTo(85, 1e-9));
    expect(breakdown.engagementPoints, closeTo(10, 1e-9));
    expect(breakdown.deductions, isEmpty);
    expect(breakdown.score, closeTo(95, 1e-9));
    expect(breakdown.actions.single.number, 'A9'); // display numbering
  });

  test('1 action half done: 42.5 action points', () {
    final breakdown = computeHealthScore(
      scenario(actions: {'A12'}, investedFromSalary: 500),
    );
    expect(breakdown.actionPoints, closeTo(42.5, 1e-9));
    expect(breakdown.score, closeTo(52.5, 1e-9));
  });

  test('a missed allocation earns nothing and deducts 1 (D3)', () {
    final breakdown = computeHealthScore(scenario(actions: {'A12'}));
    expect(breakdown.actionPoints, closeTo(0, 1e-9));
    expect(breakdown.deductions.single.code, 'D3');
    expect(breakdown.deductions.single.points, -1);
    expect(breakdown.score, closeTo(9, 1e-9));
  });

  test('weights: A9 (15, 100%) + A11 (10, 50%) = 68 action points', () {
    // A30 counts as 50% until a full week of valuations exists.
    final breakdown = computeHealthScore(
      scenario(actions: {'A12', 'A30'}, investedFromSalary: 1000),
    );
    expect(breakdown.actionPoints, closeTo(68, 1e-9));
    expect(breakdown.score, closeTo(78, 1e-9));
  });

  test('no actions: no score yet', () {
    final breakdown = computeHealthScore(scenario(actions: {}));
    expect(breakdown.score, isNull);
    expect(breakdown.band, 'No actions yet');
  });

  test('D6 and D7 follow the approved formulas', () {
    final state = scenario(actions: {'A12'}, investedFromSalary: 1000);
    state.loginStreakBreaks.add({
      'date': now.subtract(const Duration(days: 3)).toIso8601String(),
      'lostStreak': 14,
    });
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
      summary: link.summary.copyWith(transactions: [
        ...link.summary.transactions,
        for (var i = 0; i < 2; i++)
          FakeMayaTransaction(
            id: 'coffee-$i',
            title: 'Purchase',
            detail: 'Coffee shop',
            age: '10 days ago',
            amountText: '- ₱150.00',
            createdAt: now.subtract(Duration(days: 10 + i)),
          ),
      ]),
    );
    final breakdown = computeHealthScore(state);
    final byCode = {for (final d in breakdown.deductions) d.code: d.points};
    expect(byCode['D6'], closeTo(-3, 1e-9)); // -(1 + 14/7)
    expect(byCode['D7'], closeTo(-1, 1e-9)); // 2 x -0.5
  });

  test('every demo account gets a score between 0 and 100', () {
    for (final seed in <void Function(AppState)>[
      (s) => s.seedCashFlowMockDataForTesting(),
      (s) => s.seedEmergencyFundMockDataForTesting(),
      (s) => s.seedAccumulatingWealthMockDataForTesting(),
      (s) => s.seedFinancialFreedomMockDataForTesting(),
      (s) => s.seedReflectionDemoDataForTesting(),
    ]) {
      final state = AppState();
      seed(state);
      final score = state.healthScore;
      expect(score, isNotNull);
      expect(score, inInclusiveRange(0, 100));
    }
  });

  testWidgets('Financial Health Score page shows the breakdown',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final state = scenario(actions: {'A12', 'A30'}, investedFromSalary: 1000);
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: FinancialHealthScoreScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Financial Health Score'), findsOneWidget);
    expect(find.text('78'), findsOneWidget); // ring
    expect(find.text('Healthy'), findsOneWidget);
    expect(find.text('Actions'), findsWidgets);
    expect(find.text('Engagement'), findsWidgets);
    expect(find.text('Deductions'), findsWidgets);
    expect(find.text('A9'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Opened Shellby'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Opened Shellby'), findsOneWidget);
  });
}
