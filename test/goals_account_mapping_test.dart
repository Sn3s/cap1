import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const cases = [
    ('Cash Flow & Basic Needs', 'B1', 'Essential Expense Fund'),
    ('Financial Safety', 'B2', 'Emergency Fund'),
    ('Accumulating Wealth', 'B3', 'Investment Fund'),
    ('Financial Freedom', 'B4', 'Personal Lifestyle Fund'),
  ];

  for (final item in cases) {
    test('${item.$1} maps to its dedicated FakeMaya goal bucket', () {
      expect(fakeMayaBucketIdForMotivation(item.$1), item.$2);
      expect(fakeMayaBucketNameForMotivation(item.$1), item.$3);
    });
  }

  testWidgets('Goals shows the selected goal and goals explicitly added later',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final state = AppState()
      ..selectedGoalId = 'G1'
      ..addedGoalIds.add('G3');

    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: Scaffold(body: GoalsPage())),
    ));
    await tester.pumpAndSettle();

    final emergencyGoal = find.text('Build Emergency Fund');
    await tester.scrollUntilVisible(emergencyGoal, 250,
        scrollable: find.byType(Scrollable).first);
    expect(emergencyGoal, findsOneWidget);
    expect(find.text('Maintain Available Cash'), findsWidgets);
  });
}
