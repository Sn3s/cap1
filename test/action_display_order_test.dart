import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Users see A1-A15 in order; internal IDs (A26-A29 for Financial Freedom)
// never show, and active actions always list in that order.
void main() {
  void phone(WidgetTester tester) {
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
  }

  List<String> badges(WidgetTester tester) => [
        for (final text in tester.widgetList<Text>(find.byType(Text)))
          if (RegExp(r'^A\d+$').hasMatch(text.data ?? '')) text.data!,
      ];

  test('active actions iterate in display order, whatever the pick order',
      () {
    final state = AppState()
      ..selectedActionIds.addAll(['A29', 'A28', 'A26', 'A12', 'A1', 'A27']);
    expect(state.selectedActionIds.toList(),
        ['A1', 'A12', 'A26', 'A27', 'A28', 'A29']);
  });

  testWidgets('Financial Freedom cards and Edit actions use A12-A15 in order',
      (tester) async {
    phone(tester);
    final state = AppState()
      ..selectedGoalId = 'G8'
      ..selectedActionIds.addAll(['A29', 'A28', 'A26']);
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: Scaffold(body: GoalsPage())),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Lifestyle Fund'));
    await tester.tap(find.text('Lifestyle Fund'));
    await tester.pumpAndSettle();
    // Dismiss the FakeMaya sub-bucket prompt if one opened.
    while (find.byType(Dialog).evaluate().isNotEmpty) {
      Navigator.of(tester.element(find.byType(Dialog).first)).pop();
      await tester.pumpAndSettle();
    }

    final seen = <String>[];
    for (var i = 0; i < 20; i++) {
      for (final badge in badges(tester)) {
        if (!seen.contains(badge)) seen.add(badge);
      }
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300),
          warnIfMissed: false);
      await tester.pumpAndSettle();
    }
    expect(seen, ['A12', 'A14', 'A15']);

    await tester.ensureVisible(find.text('Edit actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit actions'));
    await tester.pumpAndSettle();
    expect(find.text('Lifestyle Fund Actions'), findsOneWidget);
    final sheetBadges = [
      for (final checkbox in tester.widgetList(find.byType(Checkbox)))
        tester
            .widgetList<Text>(find.descendant(
                of: find.ancestor(
                    of: find.byWidget(checkbox), matching: find.byType(Row))
                    .first,
                matching: find.byType(Text)))
            .first
            .data!,
    ];
    expect(sheetBadges, ['A12', 'A13', 'A14', 'A15']);
  });

  test('a one-day-old account gets no credit for weeks before it existed', () {
    final state = AppState()
      ..selectedActionIds.add('A28')
      ..appOpenDays.add(DateTime.now().toIso8601String().substring(0, 10));
    final line = computeHealthScore(state)
        .actions
        .firstWhere((line) => line.actionId == 'A28');
    expect(line.counted, isFalse);
    expect(computeHealthScore(state).score, isNull);
  });

  test('Reset account brings the Health Score back to zero', () async {
    final state = AppState()
      ..seedAccumulatingWealthMockDataForTesting()
      ..onboardingComplete = false;
    expect(state.healthScore, isNotNull);
    await state.resetAccountData().catchError((_) {});
    expect(state.allTransactions, isEmpty);
    expect(state.healthScore ?? 0, 0);
  });
}
