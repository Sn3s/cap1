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
}
