import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cap1/main.dart';

void main() {
  testWidgets('account creation begins with credentials and explains setup',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: WelcomeScreen()),
      ),
    );

    expect(
      find.text(
          'Create your account, then build your first plan in about 4 minutes.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account.'), findsOneWidget);
    expect(find.text('CONFIRM PASSWORD'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.textContaining('Already have an account?'), findsOneWidget);
  });

  testWidgets('forgot-password opens a validated reset-email form',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset your password'), findsOneWidget);
    expect(find.text('Send reset link'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
  });
}
