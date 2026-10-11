import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('"Scheduled bill" is a chip with its calendar icon that fills '
      'green when chosen and toggles the bill schedule', (tester) async {
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

    await tester.pumpWidget(AppScope(
      state: AppState(),
      child: const MaterialApp(home: InitialBaselineScreen()),
    ));
    await tester.pumpAndSettle();

    final billChip = find.widgetWithText(FilterChip, 'Scheduled bill');
    FilterChip chip() => tester.widget<FilterChip>(billChip);
    expect(billChip, findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(chip().selectedColor, isNot(chip().backgroundColor));
    expect(
      find.descendant(
        of: billChip,
        matching: find.byIcon(Icons.calendar_month_rounded),
      ),
      findsOneWidget,
    );
    expect(chip().selected, isFalse);
    expect(find.text('Bill schedule'), findsNothing);

    await tester.ensureVisible(billChip);
    await tester.pumpAndSettle();
    await tester.tap(billChip);
    await tester.pumpAndSettle();
    expect(chip().selected, isTrue);
    expect(find.text('Bill schedule'), findsOneWidget);

    await tester.tap(billChip);
    await tester.pumpAndSettle();
    expect(chip().selected, isFalse);
    expect(find.text('Bill schedule'), findsNothing);
  });
}
