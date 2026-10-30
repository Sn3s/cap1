import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cap1/main.dart';

void main() {
  test('AI consent is off by default and can be enabled explicitly', () async {
    final state = AppState();

    expect(state.consentAi, isFalse);

    await state.setConsentAi(true);

    expect(state.consentAi, isTrue);
  });

  testWidgets('chat blocks AI use until the user grants consent',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: ShellbyChatPage()),
      ),
    );

    expect(find.text('AI insights are off'), findsOneWidget);
    expect(find.text('Review AI privacy settings'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
