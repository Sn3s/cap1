import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reminder times are normalized, sorted, and formatted', () async {
    final state = AppState();

    await state.setNotificationReminderTimes([20 * 60, 8 * 60 + 30, 20 * 60]);

    expect(state.notificationReminderMinutes, [510, 1200]);
  });

  testWidgets('header time button opens notification settings', (tester) async {
    final state = AppState();
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(
          home: Scaffold(
            body: PageHeader(eyebrow: 'HOME', title: 'Today'),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.schedule_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Transaction reminders'), findsOneWidget);
    expect(find.text('8:00 PM'), findsOneWidget);
    expect(find.text('Send test notification'), findsOneWidget);
  });
}
