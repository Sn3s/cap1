import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppState> _pumpLifeContext(WidgetTester tester) async {
  // Phone-height surface; wide enough that the test font doesn't overflow
  // the age dropdown.
  tester.view.physicalSize = const Size(520, 874);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final state = AppState()..age = 'Early Career';
  await tester.pumpWidget(AppScope(
    state: state,
    child: const MaterialApp(home: LifeContextScreen()),
  ));
  await tester.pumpAndSettle();
  return state;
}

PrimaryButton _continueButton(WidgetTester tester) =>
    tester.widget<PrimaryButton>(find.widgetWithText(
      PrimaryButton,
      'Map Money Rhythm',
    ));

void main() {
  testWidgets('custom typed occupation and industry can continue',
      (tester) async {
    final state = await _pumpLifeContext(tester);
    expect(_continueButton(tester).enabled, isFalse);

    await tester.enterText(
        find.widgetWithText(TextField, 'Type or search occupations'),
        '  Barista ');
    await tester.enterText(
        find.widgetWithText(TextField, 'Type or search industries'),
        'Specialty Coffee');
    await tester.pump();

    expect(state.occupation, 'Barista');
    expect(state.industry, 'Specialty Coffee');
    expect(_continueButton(tester).enabled, isTrue);
  });

  testWidgets('suggestions open above the field and stay open while scrolled',
      (tester) async {
    await _pumpLifeContext(tester);
    final field = find.widgetWithText(TextField, 'Type or search occupations');
    await tester.tap(field);
    // Keyboard of ~336 logical px.
    tester.view.viewInsets = const FakeViewPadding(bottom: 336);
    await tester.pumpAndSettle();

    // The suggestions sit inside the page's ListView in the widget tree
    // (that nesting is what used to close them), so take the nearest one.
    final optionsList = find
        .ancestor(
          of: find.text(occupationPresets.first),
          matching: find.byType(ListView),
        )
        .first;
    expect(optionsList, findsOneWidget);
    expect(find.text('Other'), findsNothing);
    final fieldRect = tester.getRect(field);
    final listRect = tester.getRect(optionsList);
    expect(listRect.bottom, lessThanOrEqualTo(fieldRect.top + 1));
    expect(listRect.bottom, lessThanOrEqualTo(874 - 336));

    final position = tester
        .state<ScrollableState>(find
            .descendant(of: optionsList, matching: find.byType(Scrollable))
            .first)
        .position;

    await tester.drag(optionsList, const Offset(0, -120));
    await tester.pumpAndSettle();

    // Scrolled, and the field kept focus so the suggestions stayed open.
    expect(position.pixels, greaterThan(0));
    expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
    // Page ListView + still-open suggestions ListView.
    expect(find.byType(ListView), findsNWidgets(2));
  });
}
