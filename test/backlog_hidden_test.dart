import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Backlog goals (G4, G6, G7) and actions (A2, A4-A7, A11, A15-A18)
// stay in the code for future work but must never reach a user.
void main() {
  const backlogActions = [
    'A2', 'A4', 'A5', 'A6', 'A7', 'A11', //
    'A15', 'A16', 'A17', 'A18',
  ];

  test('backlog actions cannot be selected', () {
    final state = AppState()
      ..configureGoalActions(actionIds: ['A1', 'A5', 'A13', 'A3']);
    expect(state.selectedActionIds, {'A1', 'A3', 'A13'});

    state.addActionsForGoal(['A12', 'A13', 'A14', ...backlogActions]);
    expect(state.selectedActionIds, {'A1', 'A3', 'A12', 'A13', 'A14'});
  });

  testWidgets('a profile that picked a backlog goal keeps supported goals',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final onError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (!details.exceptionAsString().contains('overflowed')) {
        onError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = onError);

    final state = AppState()
      ..primaryConcern = 'Accumulating Wealth'
      ..selectedGoalId = 'G6' // Reduce Debt, now backlog
      ..addedGoalIds.addAll(['G2', 'G7']);
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: Scaffold(body: GoalsPage())),
    ));
    await tester.pumpAndSettle();

    final workingGoal = find.text('Grow Investments');
    await tester.scrollUntilVisible(
      workingGoal,
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(workingGoal, findsOneWidget);
    for (final title in [
      'Reduce Debt',
      'Pay Bills on Time',
      'Milestone Savings',
    ]) {
      expect(find.text(title), findsNothing, reason: title);
    }
    expect(find.text('Stable Cash Flow'), findsOneWidget);
  });

  test('cashflow demo drops the accidentally added Emergency Fund goal', () {
    final state = AppState()
      ..email = 'cashflow@gmail.com'
      ..selectedActionIds.addAll(['A1', 'A3', 'A9', 'A8', 'A22', 'A10'])
      ..addedGoalIds.add('G3')
      ..actionFieldValues['A9'] = {'amt': '2000'};

    expect(state.removeCashFlowDemoEmergencyGoal(), isTrue);
    expect(state.addedGoalIds, isNot(contains('G3')));
    expect(state.selectedActionIds, {'A1', 'A3'});
    expect(state.actionFieldValues.containsKey('A9'), isFalse);

    final other = AppState()
      ..email = 'emergency@gmail.com'
      ..addedGoalIds.add('G3');
    expect(other.removeCashFlowDemoEmergencyGoal(), isFalse);
    expect(other.addedGoalIds, contains('G3'));
  });
}
