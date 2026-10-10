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
      replacedTitle: 'Build Emergency Fund',
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
        'backlog goal ${item.goalId} ${item.title} is hidden; the working '
        'goal for the motivation shows instead',
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

      // G2, G4, G6 and G7 are backlog (no working features yet): profiles
      // that picked one before they were hidden land on the working goal.
      expect(find.text(item.title), findsNothing);
      expect(find.text(item.replacedTitle), findsOneWidget);
      expect(find.text(item.actionText), findsNothing);
    });
  }
}
