import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => AppClock.offset.value = Duration.zero);

  group('log-in streak', () {
    test('counts consecutive days and resets after a missed day', () async {
      final state = AppState(); // onboarding incomplete: saveProfile no-ops

      await state.recordAppOpen();
      expect(state.loginStreak, 1);
      await state.recordAppOpen(); // same day again
      expect(state.loginStreak, 1);

      AppClock.offset.value = const Duration(days: 1);
      await state.recordAppOpen();
      expect(state.loginStreak, 2);

      AppClock.offset.value = const Duration(days: 2);
      await state.recordAppOpen();
      expect(state.loginStreak, 3);
      expect(state.longestLoginStreak, 3);
      expect(state.openedAppToday, isTrue);

      // Skip a whole day: the streak is lost; today starts a new one.
      AppClock.offset.value = const Duration(days: 4);
      expect(state.openedAppToday, isFalse);
      await state.recordAppOpen();
      expect(state.loginStreak, 1);
      expect(state.longestLoginStreak, 3);
      expect(state.loginStreakBreaks.single['lostStreak'], 3);
      expect(state.loginStreakBreaks.single['missedDays'], 1);
    });
  });

  testWidgets('goal cards show a motivation streak that a missed action resets',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    // The test font is much wider than the real one; ignore layout overflow
    // noise from the existing card footer and check the streak logic only.
    final onError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (!details.exceptionAsString().contains('overflowed')) {
        onError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = onError);
    final state = AppState()
      ..seedAccumulatingWealthMockDataForTesting()
      ..onboardingComplete = false;

    String pill() => tester
        .widgetList<Text>(find.byType(Text))
        .map((w) => w.data ?? '')
        .firstWhere((t) => t.endsWith('🔥'));

    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: Scaffold(body: GoalsPage())),
    ));
    await tester.pumpAndSettle();
    final before = int.parse(pill().split(' ').first);
    expect(before, greaterThan(0));
    expect(find.text('On Track'), findsNothing);

    // A salary 5 days ago with no A12 transfer: the expected action was
    // missed, so the Grow Investments streak drops to 0.
    final link = state.fakeMayaLink!;
    state.fakeMayaLink = FakeMayaLink(
      userId: link.userId,
      email: link.email,
      name: link.name,
      phone: link.phone,
      provider: link.provider,
      accessToken: link.accessToken,
      refreshToken: link.refreshToken,
      expiresAt: link.expiresAt,
      summary: link.summary.copyWith(transactions: [
        FakeMayaTransaction(
          id: 'missed-salary',
          title: 'Cash in',
          detail: 'From: Employer payroll',
          age: '5 days ago',
          amountText: '+ ₱29,000.00',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        ...link.summary.transactions,
      ]),
    );
    state.notifyListeners();
    await tester.pumpAndSettle();
    expect(pill(), '0 🔥');

    // Doing the action brings it back.
    await state.depositIncomeToInvestment(
      transactionId: 'missed-salary',
      incomeAmount: 29000,
      incomeDate: DateTime.now().subtract(const Duration(days: 5)),
    );
    await tester.pumpAndSettle();
    expect(int.parse(pill().split(' ').first), greaterThan(0));
  });
}
