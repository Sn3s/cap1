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

    expect(find.text('Shellby chat is off'), findsOneWidget);
    expect(find.text('Review AI privacy settings'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  test('all action-stage reviews are blocked until AI consent is enabled',
      () async {
    final state = AppState();
    const coach = ShellbyAiCoach();

    for (final review in <Future<ActionStageResult> Function()>[
      () => coach.recommendAvailableCashActionStage(state: state),
      () => coach.recommendEmergencyFundActionStage(state: state),
      () => coach.recommendInvestmentActionStage(state: state),
      () => coach.recommendLifestyleActionStage(state: state),
    ]) {
      await expectLater(review(), throwsA(isA<AiConsentRequiredException>()));
    }
  });
}
