import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Onboarding and "+ Add Goal" share the 4-step flow: motivation, Surface,
// "Your goal + first actions" (★ suggestion), numbers.
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

  testWidgets('onboarding: Surface leads straight to the goal and its habits',
      (tester) async {
    phone(tester);
    final state = AppState()..primaryConcern = 'Accumulating Wealth';
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: MotivationSurfaceScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(
        find.textContaining('I want to start investing', findRichText: true));
    await tester.pumpAndSettle();

    // Surface B -> A12 internally, shown to users as A9.
    expect(find.text('★ Suggested for you'), findsOneWidget);
    expect(
        find.textContaining('Strengthen your foundation', findRichText: true),
        findsNothing);

    // The goal message sits above the habit options in the chat.
    await tester.drag(find.byType(ListView).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.textContaining('Which goal would you like', findRichText: true),
        findsNothing);
    expect(
        find.textContaining('Your goal: Grow Investments', findRichText: true),
        findsOneWidget);
    expect(
        find.textContaining('Which actions do you want to start with',
            findRichText: true),
        findsOneWidget);
  });

  testWidgets('onboarding: M1 goes to its goal; no foundation add-on',
      (tester) async {
    phone(tester);
    final state = AppState()..primaryConcern = 'Cash Flow & Basic Needs';
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: MotivationSurfaceScreen()),
    ));
    await tester.pumpAndSettle();
    await tester
        .tap(find.textContaining('I feel thrown off', findRichText: true));
    await tester.pumpAndSettle();
    expect(
        find.textContaining('Strengthen your foundation', findRichText: true),
        findsNothing);
    await tester.drag(find.byType(ListView).first, const Offset(0, 2000));
    await tester.pumpAndSettle();

    expect(
        find.textContaining('Your goal: Maintain Available Cash',
            findRichText: true),
        findsOneWidget);
  });

  testWidgets('+ Add Goal walks the same 4 steps and saves the habits',
      (tester) async {
    phone(tester);
    final state = AppState()
      ..primaryConcern = 'Cash Flow & Basic Needs'
      ..selectedGoalId = 'G1'
      ..onboardingComplete = false;
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: AddGoalScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Add another motivation'), findsOneWidget);

    // 1. Motivation
    await tester.tap(find.text('Financial Safety'));
    await tester.pumpAndSettle();
    // 2. Surface
    await tester.tap(find.textContaining('Surprise expenses or due dates',
        findRichText: true));
    await tester.pumpAndSettle();
    // 3. Your goal + first actions (Surface B -> A22, shown as A7)
    expect(
        find.textContaining('Your goal: Build Emergency Fund',
            findRichText: true),
        findsOneWidget);
    expect(find.text('★ Suggested for you'), findsOneWidget);
    final suggested = find
        .ancestor(
          of: find.text('★ Suggested for you'),
          matching: find.byType(InkWell),
        )
        .first;
    expect(
      tester
          .widgetList<Text>(
              find.descendant(of: suggested, matching: find.byType(Text)))
          .first
          .data,
      startsWith('A7 · '),
    );
    await tester.tap(suggested);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    // 4. Numbers
    expect(
        find.textContaining("Let's set the numbers for each action.",
            findRichText: true),
        findsOneWidget);
    expect(state.selectedActionIds.contains('A22'), isFalse); // not yet saved

    // Pick the recommended value, then confirm.
    await tester.tap(find.byType(RadioListTile<int>).first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Confirm All'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm All'));
    await tester.pumpAndSettle();
    // Same bucket prompt as the original flow; skip it here.
    if (find.text('Not now').evaluate().isNotEmpty) {
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
    }
    expect(state.addedGoalIds, contains('G3'));
    expect(state.selectedActionIds, contains('A22'));
    expect(state.actionFieldValues['A22'], isNotNull);
  });

  testWidgets('M3 Surface no longer offers the debt choice', (tester) async {
    phone(tester);
    final state = AppState()..primaryConcern = 'Accumulating Wealth';
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: MotivationSurfaceScreen()),
    ));
    await tester.pumpAndSettle();
    expect(
        find.textContaining('Debt payments', findRichText: true), findsNothing);
    expect(find.textContaining('I want to start investing', findRichText: true),
        findsOneWidget);
  });
}
