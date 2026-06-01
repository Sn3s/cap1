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
    await tester.pumpWidget(const ShellbyApp());

    expect(find.text('Shelby'), findsOneWidget);
    expect(find.text('Your Finance friend'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    expect(find.text('Let Shelby know you.'), findsOneWidget);
    expect(find.text('NAME'), findsOneWidget);
    expect(find.text('EMAIL'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const ShellbyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);

    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: LifeContextScreen()),
      ),
    );

    expect(find.text('What are you doing now?'), findsOneWidget);
    expect(find.text('AGE & LIFE STAGE'), findsOneWidget);

    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: LifeRhythmScreen()),
      ),
    );

    expect(find.text('How does money move for you?'), findsOneWidget);
  });
}
