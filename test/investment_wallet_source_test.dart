import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// A10 "Add investment" (internal A23) moves money out of the FakeMaya Wallet
// into the Investment Fund bucket. The wallet is the only source.
void main() {
  /// Wallet ₱[wallet], Investment Fund ₱[fund], no holdings.
  AppState scenario({required double wallet, required double fund}) {
    final state = AppState()
      ..seedAccumulatingWealthMockDataForTesting()
      ..onboardingComplete = false;
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
      summary: link.summary.copyWith(
        wallet: wallet,
        investmentHoldings: const [],
        personalGoals: [
          for (final goal in link.summary.personalGoals)
            if (goal.id == FakeMayaPersonalGoal.investmentFundId)
              goal.copyWith(balance: fund)
            else
              goal,
        ],
      ),
    );
    state.actionFieldValues['A23'] = {'amt': '100000'};
    return state;
  }

  test('₱6,000 moves from a ₱10,000 wallet into a ₱5,000 Investment Fund',
      () async {
    final state = scenario(wallet: 10000, fund: 5000);

    await state.depositMonthlyInvestment(6000);

    expect(state.fakeMayaLink!.summary.wallet, 4000);
    expect(state.fakeMayaLink!.summary.investmentFund!.balance, 11000);
    expect(state.investmentBalance, 11000);
    expect(state.investmentPortfolioValue, 11000);
  });

  test('no money is created: more than the wallet, or no FakeMaya, fails',
      () async {
    final state = scenario(wallet: 1000, fund: 5000);
    await expectLater(state.depositMonthlyInvestment(6000),
        throwsA(isA<FakeMayaException>()));
    expect(state.fakeMayaLink!.summary.wallet, 1000);
    expect(state.investmentBalance, 5000);

    final unlinked = AppState();
    await expectLater(unlinked.depositMonthlyInvestment(6000),
        throwsA(isA<FakeMayaException>()));
    expect(unlinked.investmentBalance, 0);
  });

  Future<void> openAddInvestment(WidgetTester tester, AppState state) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final onError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (!details.exceptionAsString().contains('overflowed')) {
        onError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = onError);
    state
      ..selectedGoalId = 'G5'
      ..selectedActionIds.add('A23');
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(
        home: Scaffold(body: GoalsPage(initialGoalId: 'G5')),
      ),
    ));
    await tester.pumpAndSettle();
    while (find.byType(Dialog).evaluate().isNotEmpty) {
      Navigator.of(tester.element(find.byType(Dialog).first)).pop();
      await tester.pumpAndSettle();
    }
    await tester.dragUntilVisible(find.text('Add investment'),
        find.byType(ListView).first, const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add investment'));
    await tester.pumpAndSettle();
  }

  testWidgets('the pop-up says the money comes from the Wallet',
      (tester) async {
    final state = scenario(wallet: 10000, fund: 5000);
    await openAddInvestment(tester, state);

    expect(find.textContaining('taken from your FakeMaya Wallet'),
        findsOneWidget);
    await tester.enterText(find.byType(TextField), '6000');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm transfer'));
    await tester.pumpAndSettle();

    expect(state.fakeMayaLink!.summary.wallet, 4000);
    expect(state.investmentBalance, 11000);
  });

  testWidgets('an empty Wallet blocks the transfer', (tester) async {
    final state = scenario(wallet: 0, fund: 5000);
    await openAddInvestment(tester, state);

    expect(find.text('Deposit into Fakemaya to proceed'), findsOneWidget);
    final confirm = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirm transfer'));
    expect(confirm.onPressed, isNull);
  });
}
