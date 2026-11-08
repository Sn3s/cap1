import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Goals shows a cautious, revisitable pyramid path',
      (tester) async {
    final state = AppState()
      ..primaryConcern = 'Cash Flow & Basic Needs'
      ..selectedGoalId = 'G1'
      ..achievedGoalIds.add('G1');

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: GoalsPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pyramid path'), findsOneWidget);
    expect(find.text('Completed · Not enough data'), findsOneWidget);
    expect(find.text('Next recommended · Not enough data'), findsOneWidget);
    expect(
      find.text('Completed and current layers stay available to revisit.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cash Flow & Basic Needs'));
    await tester.pumpAndSettle();
    expect(find.text('Maintain Available Cash'), findsWidgets);
  });

  testWidgets(
      'Pyramid detail exposes only the stress account’s selected layers',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Every local stress fixture starts with the Cash Flow plan only. The
    // history size must not make the dashboard expose the other three plans.
    final state = AppState()..seedStressTestDataForTesting(100);

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: DashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    // The dashboard itself correctly limits cards to the selected plan.
    expect(find.text('Cash Flow & Basic Needs'), findsWidgets);
    expect(find.text('Financial Safety'), findsNothing);

    await tester.tap(find.text('Cash Flow & Basic Needs'));
    await tester.pumpAndSettle();

    // Opening that card must not turn the full goal catalog into editable
    // tabs. A Cash Flow-only account sees its own layer and nothing else.
    expect(find.text('Cash Flow & Basic Needs'), findsWidgets);
    expect(find.text('Financial Safety'), findsNothing);
    expect(find.text('Accumulating Wealth'), findsNothing);
    expect(find.text('Financial Freedom'), findsNothing);
  });
}
