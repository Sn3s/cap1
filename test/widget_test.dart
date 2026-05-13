// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:cap1/main.dart';

void main() {
  testWidgets('Ahead welcome flow smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AheadApp());

    expect(
      find.text("Welcome! Let's personalize Ahead for you!"),
      findsOneWidget,
    );
    expect(find.text('Get Started'), findsOneWidget);

    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: PersonalBaseline()),
      ),
    );

    expect(find.text('Establish your context.'), findsOneWidget);
  });
}
