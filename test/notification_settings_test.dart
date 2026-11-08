import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reminder times are normalized, sorted, and formatted', () async {
    final state = AppState();

    await state.setNotificationReminderTimes([20 * 60, 8 * 60 + 30, 20 * 60]);

    expect(state.notificationReminderMinutes, [510, 1200]);
  });

  testWidgets('header Help opens a contextual tutorial', (tester) async {
    final state = AppState();
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(
          home: Scaffold(
            body: PageHeader(eyebrow: 'GOOD MORNING', title: 'Today'),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.schedule_rounded), findsNothing);
    await tester.tap(find.byIcon(Icons.help_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Help with Home'), findsOneWidget);
    expect(find.text('Weekly challenge'), findsOneWidget);
    expect(find.text('Pyramid'), findsOneWidget);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.text('Help with Home'), findsNothing);
  });
}
