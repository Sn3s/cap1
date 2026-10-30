// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cap1/main.dart';

void main() {
  testWidgets('Shellby welcome flow smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: WelcomeScreen()),
      ),
    );

    expect(find.text('Shelby'), findsOneWidget);
    expect(find.text('Your Finance friend'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account.'), findsOneWidget);
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('CONFIRM PASSWORD'), findsOneWidget);
    expect(find.textContaining('Already have an account?'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: LifeContextScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('What are you doing now?'), findsOneWidget);
    expect(find.text('AGE & LIFE STAGE'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: LifeRhythmScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('How does money move for you?'), findsOneWidget);
  });
}
