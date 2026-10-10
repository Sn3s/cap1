import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Every Goals-page transfer is paid for by the FakeMaya Wallet. Without a
// linked Wallet holding enough, nothing moves, so no action creates money.
void main() {
  FakeMayaTransaction income(String id, double amount) => FakeMayaTransaction(
        id: id,
        title: 'Cash in',
        detail: 'From: Employer payroll',
        age: 'Just now',
        amountText: '+ ₱${amount.toStringAsFixed(2)}',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

  AppState linked({required double wallet}) {
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
      summary: link.summary.copyWith(wallet: wallet),
    );
    state.billsObligationsBalance = 0;
    return state;
  }

  final now = DateTime.now();
  // Each Goals-page transfer, by the number users see.
  final transfers = <String, Future<void> Function(AppState)>{
    'A1': (s) => s.depositPendingIncomeToEssentialFund(
        incomes: [income('a1', 10000)], percentage: 50),
    'A5': (s) => s.depositMonthlyEmergencyFund(5000),
    'A6': (s) => s.depositIncomeToEmergencyFund(
        transactionId: 'a6',
        incomeAmount: 10000,
        incomeDate: now,
        percentage: 50),
    'A8': (s) => s.replenishD1EmergencyFund(5000),
    'A9': (s) => s.depositIncomeToInvestment(
        transactionId: 'a9',
        incomeAmount: 10000,
        incomeDate: now,
        percentage: 50),
    'A10': (s) => s.depositMonthlyInvestment(5000),
    'A12': (s) => s.depositLifestyleSubscriptionReserve(5000),
    'A13': (s) => s.depositLifestylePayday(
        transactionId: 'a13', incomeAmount: 50000, incomeDate: now),
  };

  for (final entry in transfers.entries) {
    test('${entry.key} creates no money without a FakeMaya link', () async {
      final state = AppState();
      await expectLater(entry.value(state), throwsA(isA<FakeMayaException>()));
      expect(state.essentialExpensesBalance, 0);
      expect(state.emergencyFundBalance, 0);
      expect(state.investmentBalance, 0);
      expect(state.lifestyleFundBalance, 0);
      expect(state.d1Ledger, isEmpty);
    });

    test('${entry.key} is refused when the Wallet is empty', () async {
      final state = linked(wallet: 0);
      await expectLater(
        entry.value(state),
        throwsA(isA<FakeMayaException>().having(
            (e) => e.message, 'message', 'Deposit into Fakemaya to proceed')),
      );
      expect(state.fakeMayaLink!.summary.wallet, 0);
    });
  }

  test('A8 Replenish refills the Emergency Fund bucket, not Savings', () async {
    final state = linked(wallet: 10000);
    final summary = state.fakeMayaLink!.summary;
    final savingsBefore = summary.savings;
    final bucketBefore = summary
            .personalGoalById(FakeMayaPersonalGoal.emergencyFundId)
            ?.balance ??
        0;

    await state.replenishD1EmergencyFund(3000);

    final after = state.fakeMayaLink!.summary;
    expect(after.wallet, 7000);
    expect(after.savings, savingsBefore);
    expect(
        after.personalGoalById(FakeMayaPersonalGoal.emergencyFundId)!.balance,
        bucketBefore + 3000);
  });

  testWidgets(
      'A5 card blocks the deposit and says why when the Wallet is empty',
      (tester) async {
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
    final state = linked(wallet: 0)
      ..selectedGoalId = 'G3'
      ..selectedActionIds.add('A9');
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(
        home: Scaffold(body: GoalsPage(initialGoalId: 'G3')),
      ),
    ));
    await tester.pumpAndSettle();
    while (find.byType(Dialog).evaluate().isNotEmpty) {
      Navigator.of(tester.element(find.byType(Dialog).first)).pop();
      await tester.pumpAndSettle();
    }
    await tester.dragUntilVisible(find.text('Deposit into Fakemaya to proceed'),
        find.byType(ListView).first, const Offset(0, -250));
    expect(find.text('Deposit into Fakemaya to proceed'), findsOneWidget);
    final button = tester.widget<PrimaryButton>(find.ancestor(
        of: find.textContaining('Deposit ₱'),
        matching: find.byType(PrimaryButton)));
    expect(button.enabled, isFalse);
  });
}
