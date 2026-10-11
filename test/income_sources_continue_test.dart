import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Continue to Expenses explains a missing income date instead of '
      'staying greyed out', (tester) async {
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

    // A fixed monthly income starts with "Has a predictable schedule" on.
    final state = AppState()
      ..incomeType = 'fixed'
      ..incomeRhythm = 'monthly';
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: MonthlyIncomeScreen()),
    ));
    await tester.pumpAndSettle();

    PrimaryButton continueButton() => tester.widget<PrimaryButton>(
        find.widgetWithText(PrimaryButton, 'Continue to Expenses'));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Salary');
    await tester.enterText(fields.at(1), '25000');
    await tester.pumpAndSettle();
    expect(continueButton().enabled, isTrue);

    // No date yet: tapping says what's missing and stays on the page.
    await tester.tap(find.text('Continue to Expenses'));
    await tester.pump();
    expect(find.textContaining('Choose a date for Salary'), findsOneWidget);
    expect(find.text('Your income sources.'), findsOneWidget);
    expect(state.onboardingIncomeLedger, isEmpty);

    // Pick the date, then Continue saves the income and moves on.
    final dateButton = find.widgetWithText(OutlinedButton, 'Choose date');
    await tester.ensureVisible(dateButton);
    await tester.pumpAndSettle();
    await tester.tap(dateButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // The message clears as soon as the date is set.
    expect(find.textContaining('Choose a date for Salary'), findsNothing);
    await tester.tap(find.text('Continue to Expenses'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(state.onboardingIncomeLedger.single['name'], 'Salary');
    expect(state.income, 25000);
  });

  testWidgets('"Has a predictable schedule" is a chip that fills green when '
      'chosen and toggles the income schedule', (tester) async {
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
      ..incomeType = 'fixed'
      ..incomeRhythm = 'monthly';
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: MonthlyIncomeScreen()),
    ));
    await tester.pumpAndSettle();

    final chip = find.widgetWithText(FilterChip, 'Has a predictable schedule');
    FilterChip chipWidget() => tester.widget<FilterChip>(chip);
    expect(chip, findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(
      find.descendant(
        of: chip,
        matching: find.byIcon(Icons.event_available_rounded),
      ),
      findsOneWidget,
    );
    expect(chipWidget().selected, isTrue);
    final selectedColor = chipWidget().selectedColor;
    expect(selectedColor, isNot(chipWidget().backgroundColor));
    expect(find.text('Income schedule'), findsOneWidget);

    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(chipWidget().selected, isFalse);
    expect(find.text('Income schedule'), findsNothing);

    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(chipWidget().selected, isTrue);
    expect(find.text('Income schedule'), findsOneWidget);
  });

  testWidgets('"Same amount each month" replaces the unlabeled stable-income '
      'checkbox and toggles on its own', (tester) async {
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
      ..incomeType = 'fixed'
      ..incomeRhythm = 'monthly';
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: MonthlyIncomeScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsNothing);
    final amountChip =
        find.widgetWithText(FilterChip, 'Same amount each month');
    final scheduleChip =
        find.widgetWithText(FilterChip, 'Has a predictable schedule');
    expect(
      find.descendant(
          of: amountChip, matching: find.byIcon(Icons.balance_rounded)),
      findsOneWidget,
    );
    // A fixed salary starts as a stable amount on a predictable schedule.
    expect(tester.widget<FilterChip>(amountChip).selected, isTrue);
    expect(tester.widget<FilterChip>(scheduleChip).selected, isTrue);

    await tester.tap(amountChip);
    await tester.pumpAndSettle();
    expect(tester.widget<FilterChip>(amountChip).selected, isFalse);
    // Independent of the schedule.
    expect(tester.widget<FilterChip>(scheduleChip).selected, isTrue);
    expect(find.text('Income schedule'), findsOneWidget);
  });
}
