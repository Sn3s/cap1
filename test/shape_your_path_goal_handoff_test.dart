import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const cases = [
    (
      goalId: 'G2',
      layer: 'Cash Flow & Basic Needs',
      title: 'Stable Cash Flow',
      actionId: 'A6',
      actionText:
          'Distribute X% of incoming income across separate spending and savings accounts immediately upon receipt.',
      replacedTitle: 'Maintain Available Cash',
    ),
    (
      goalId: 'G4',
      layer: 'Financial Safety',
      title: 'Pay Bills on Time',
      actionId: 'A4',
      actionText:
          'Set aside ₱X from each income received for upcoming bill and payment obligations.',
      replacedTitle: 'Maintain Available Cash',
    ),
    (
      goalId: 'G6',
      layer: 'Accumulating Wealth',
      title: 'Reduce Debt',
      actionId: 'A11',
      actionText:
          'Pay an additional X% above the minimum required debt payment each payment cycle.',
      replacedTitle: 'Grow Investments',
    ),
    (
      goalId: 'G7',
      layer: 'Financial Freedom',
      title: 'Milestone Savings',
      actionId: 'A16',
      actionText:
          'Contribute ₱X or X% of income to each goal-based savings fund every payday.',
      replacedTitle: 'Lifestyle Fund',
    ),
  ];

  for (final item in cases) {
    testWidgets(
        'Shape your path keeps ${item.goalId} ${item.title} as the displayed goal',
        (tester) async {
      final state = AppState()
        ..primaryConcern = item.layer
        ..selectedGoalId = item.goalId
        ..selectedActionIds.add(item.actionId);

      await tester.pumpWidget(
        AppScope(
          state: state,
          child: const MaterialApp(home: GoalsPage()),
        ),
      );
      await tester.pump();

      expect(find.text(item.title), findsOneWidget);
      expect(find.text(item.replacedTitle), findsNothing);

      await tester.tap(find.text(item.title));
      await tester.pumpAndSettle();

      expect(find.text(item.title), findsOneWidget);
      expect(find.text(item.actionText), findsOneWidget);
    });
  }
}
