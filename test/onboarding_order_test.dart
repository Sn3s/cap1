import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('money rhythm continues to monthly income', (tester) async {
    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: LifeRhythmScreen()),
      ),
    );

    expect(find.text('Phase 3/15'), findsOneWidget);
    await tester.tap(find.text('Add Monthly Income'));
    await tester.pumpAndSettle();

    expect(find.text('Monthly income.'), findsOneWidget);
    expect(find.text('Phase 4/15'), findsOneWidget);
  });

  testWidgets('moved baseline and later phases use the new numbering',
      (tester) async {
    final screens = <(Widget, String)>[
      (const InitialBaselineScreen(), 'Phase 5/15'),
      (const FinancialConcernScreen(), 'Phase 6/15'),
      (const MotivationSurfaceScreen(), 'Phase 7/15'),
      (const GoalQuestionnaireScreen(), 'Phase 8/15'),
      (const RecommendedPlanScreen(), 'Phase 9/15'),
      (const FakeMayaOnboardingScreen(), 'Phase 10/15'),
      (const AppPermissionScreen(), 'Phase 11/15'),
      (const PersonalDataConsentScreen(), 'Phase 12/15'),
      (const DataRetentionConsentScreen(), 'Phase 13/15'),
      (const PreparationCommitmentScreen(), 'Phase 14/15'),
      (const FirstCollectionHandoffScreen(), 'Phase 15/15'),
    ];

    for (final screen in screens) {
      await tester.pumpWidget(
        AppScope(
          state: AppState(),
          child: MaterialApp(home: screen.$1),
        ),
      );
      await tester.pump();
      expect(find.text(screen.$2), findsOneWidget);
    }
  });

  testWidgets('FakeMaya now continues to app permissions', (tester) async {
    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: FakeMayaOnboardingScreen()),
      ),
    );

    await tester.tap(find.text('Continue Without Linking'));
    await tester.pumpAndSettle();

    expect(find.text('App permissions.'), findsOneWidget);
    expect(find.text('Phase 11/15'), findsOneWidget);
  });
}
