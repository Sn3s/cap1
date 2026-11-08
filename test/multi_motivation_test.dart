import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AppState _fourMotivationState() {
  final state = AppState()..seedReflectionDemoDataForTesting();
  // This must be a normal account, not the special Reflection Demo account,
  // so the test proves real users can carry all four motivations.
  state.email = 'four-motivations@example.com';
  state.consentAi = false;
  state.addedGoalIds
    ..clear()
    ..addAll(const {'G3', 'G5', 'G8'});
  return state;
}

void main() {
  test('four active motivations contribute once each to the health score', () {
    final breakdown = computeHealthScore(_fourMotivationState());
    final actionIds = breakdown.actions.map((line) => line.actionId).toList();

    expect(actionIds.toSet(), hasLength(actionIds.length));
    expect(actionIds, containsAll(const {'A1', 'A8', 'A12', 'A27'}));
    expect(breakdown.score, isNotNull);
    expect(breakdown.score, inInclusiveRange(0, 100));
  });

  test('investment windfalls and month-end sweeps are eligible health actions',
      () {
    final state = AppState();
    state.selectedActionIds.addAll(const {'A13', 'A14'});

    final actions =
        computeHealthScore(state).actions.map((line) => line.actionId);
    expect(actions, containsAll(const {'A13', 'A14'}));
  });

  test('a Lifestyle Fund cannot be complete before money is set aside', () {
    final state = AppState()
      ..variableExpenses = 1000
      ..actionFieldValues['A28'] = {'amt': '250'};

    expect(lifestyleGoalPercent(state), 0);

    state.lifestyleFundBalance = 1000;
    expect(lifestyleGoalPercent(state), 100);
  });

  test('all four motivations retain their own FakeMaya goal bucket', () async {
    final state = _fourMotivationState()..mockDataEnabled = true;
    for (final motivation in const [
      'Cash Flow & Basic Needs',
      'Financial Safety',
      'Accumulating Wealth',
      'Financial Freedom',
    ]) {
      await state.ensureFakeMayaBucketForMotivation(motivation);
    }

    expect(
      state.fakeMayaLink!.summary.personalGoals.map((goal) => goal.id).toSet(),
      containsAll(const {'B1', 'B2', 'B3', 'B4'}),
    );
  });

  testWidgets('a normal account can see all four active goals and insights',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final state = _fourMotivationState();

    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: Scaffold(body: GoalsPage())),
    ));
    await tester.pumpAndSettle();
    for (final goal in const [
      'Maintain Available Cash',
      'Build Emergency Fund',
      'Grow Investments',
      'Lifestyle Fund',
    ]) {
      final goalFinder = find.text(goal);
      await tester.scrollUntilVisible(
        goalFinder,
        260,
        scrollable: find.byType(Scrollable).first,
      );
      expect(goalFinder, findsOneWidget);
    }

    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: Scaffold(body: InsightsPage())),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Available cash'), findsOneWidget);
    expect(find.text('Emergency fund'), findsOneWidget);
    expect(find.text('Accumulating wealth'), findsOneWidget);
    expect(find.text('Financial freedom'), findsOneWidget);
    expect(find.text('Total Goals Score'), findsOneWidget);
    expect(
      find.text('Equal-weight average across 4 active goals.'),
      findsOneWidget,
    );
    expect(find.text('Cash Flow & Safety balance'), findsNothing);

    for (final (tab, scoreTitle) in const [
      ('Available cash', 'Cash Flow Goal Score'),
      ('Emergency fund', 'Financial Safety Goal Score'),
      ('Accumulating wealth', 'Accumulating Wealth Goal Score'),
      ('Financial freedom', 'Financial Freedom Goal Score'),
    ]) {
      await tester.tap(find.text(tab).first);
      await tester.pumpAndSettle();
      expect(find.text('Goal Insights'), findsOneWidget);
      expect(find.text(scoreTitle), findsOneWidget);
    }
  });
}
