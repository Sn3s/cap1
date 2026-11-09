import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const cases = [
    ('Cash Flow & Basic Needs', 'B1', 'Essential Expense Fund'),
    ('Financial Safety', 'B2', 'Emergency Fund'),
    ('Accumulating Wealth', 'B3', 'Investment Fund'),
    ('Financial Freedom', 'B4', 'Personal Lifestyle Fund'),
  ];

  for (final item in cases) {
    test('${item.$1} maps to its dedicated FakeMaya goal bucket', () {
      expect(fakeMayaBucketIdForMotivation(item.$1), item.$2);
      expect(fakeMayaBucketNameForMotivation(item.$1), item.$3);
    });
  }

  test('Stable Cash Flow cash-in planning never changes money balances', () {
    final state = AppState()
      ..cashOnHandBalance = 4200
      ..essentialExpensesBalance = 1800;
    final beforeCash = state.cashOnHandBalance;
    final beforeEssential = state.essentialExpensesBalance;

    state.setStableCashFlowExpectedIncomeWindow(14);

    expect(state.stableCashFlowPlanningDays, 14);
    expect(state.stableCashFlowExpectedIncomeOn, isNotNull);
    expect(state.stableCashFlowPlanNeedsReview, isFalse);
    expect(state.cashOnHandBalance, beforeCash);
    expect(state.essentialExpensesBalance, beforeEssential);
  });

  testWidgets('Goals shows the selected goal and goals explicitly added later',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final state = AppState()
      ..selectedGoalId = 'G1'
      ..addedGoalIds.add('G3');

    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: Scaffold(body: GoalsPage())),
    ));
    await tester.pumpAndSettle();

    final emergencyGoal = find.text('Build Emergency Fund');
    await tester.scrollUntilVisible(emergencyGoal, 250,
        scrollable: find.byType(Scrollable).first);
    expect(emergencyGoal, findsOneWidget);
    expect(find.text('Maintain Available Cash'), findsWidgets);
  });

  testWidgets(
      'Stable Cash Flow renders its own goal card and shared action plan',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final state = AppState()
      ..primaryConcern = 'Cash Flow & Basic Needs'
      ..selectedGoalId = 'G2'
      ..selectedActionIds.addAll(['A1', 'A19', 'A31'])
      ..setStableCashFlowExpectedIncomeWindow(14);

    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: Scaffold(body: GoalsPage())),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Stable Cash Flow'), findsOneWidget);
    await tester.tap(find.text('Stable Cash Flow'));
    await tester.pumpAndSettle();

    expect(find.text('STABLE CASH FLOW POSITION'), findsOneWidget);
    expect(find.text('Cash-in this month'), findsOneWidget);
    expect(find.text('Expected cash-in'), findsOneWidget);
  });

  for (final item in const [
    (
      motivation: 'Cash Flow & Basic Needs',
      label: 'CASH FLOW & BASIC NEEDS',
      foundationLine: null,
    ),
    (
      motivation: 'Financial Safety',
      label: 'FINANCIAL SAFETY',
      foundationLine: 'Foundation goal for your Financial Safety plan',
    ),
    (
      motivation: 'Accumulating Wealth',
      label: 'ACCUMULATING WEALTH',
      foundationLine: 'Foundation goal for your Accumulating Wealth plan',
    ),
    (
      motivation: 'Financial Freedom',
      label: 'FINANCIAL FREEDOM',
      foundationLine: 'Foundation goal for your Financial Freedom plan',
    ),
  ]) {
    testWidgets(
        'shared Maintain Available Cash is presented under ${item.motivation}',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final state = AppState()
        ..primaryConcern = item.motivation
        ..motivation = item.motivation
        ..selectedGoalId = 'G1';

      await tester.pumpWidget(AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: GoalsPage())),
      ));
      await tester.pumpAndSettle();

      expect(find.text(item.label), findsOneWidget);
      if (item.foundationLine case final line?) {
        expect(find.text(line), findsOneWidget);
      } else {
        expect(find.textContaining('Foundation goal for your'), findsNothing);
      }
    });
  }

  for (final item in const [
    (motivation: 'Financial Safety', goalId: 'G3', label: 'FINANCIAL SAFETY'),
    (
      motivation: 'Accumulating Wealth',
      goalId: 'G5',
      label: 'ACCUMULATING WEALTH',
    ),
    (
      motivation: 'Financial Freedom',
      goalId: 'G8',
      label: 'FINANCIAL FREEDOM',
    ),
  ]) {
    testWidgets('dedicated ${item.motivation} goal keeps its own motivation',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final state = AppState()
        ..primaryConcern = item.motivation
        ..motivation = item.motivation
        ..selectedGoalId = item.goalId;

      await tester.pumpWidget(AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: GoalsPage())),
      ));
      await tester.pumpAndSettle();

      expect(find.text(item.label), findsOneWidget);
      expect(find.textContaining('Foundation goal for your'), findsNothing);
    });
  }
}
