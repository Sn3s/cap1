import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FakeMayaPersonalGoal investmentFund(AppState state) =>
      state.fakeMayaLink!.summary.investmentFund!;

  // saveProfile() is a no-op before onboarding completes, which keeps these
  // tests off Firebase while still exercising the FakeMaya bucket writes.
  AppState seeded() => AppState()
    ..seedAccumulatingWealthMockDataForTesting()
    ..onboardingComplete = false;

  // What FakeMaya's Crypto page writes when the user buys [amount] of BTC:
  // the Investment Fund pays for it and the units land in holdings.
  void buyBitcoinInFakeMaya(AppState state, double amount, double price) {
    final link = state.fakeMayaLink!;
    final summary = link.summary;
    final units = amount / price;
    state.fakeMayaLink = FakeMayaLink(
      userId: link.userId,
      email: link.email,
      name: link.name,
      phone: link.phone,
      provider: link.provider,
      accessToken: link.accessToken,
      refreshToken: link.refreshToken,
      expiresAt: link.expiresAt,
      summary: summary.copyWith(
        personalGoals: summary.personalGoalsWithWithdrawal(
          FakeMayaPersonalGoal.investmentFundId,
          amount,
        ),
        investmentHoldings: [
          for (final h in summary.investmentHoldings)
            h.symbol == 'BTC' ? h.copyWith(units: h.units + units) : h,
        ],
        investmentTransactions: [
          FakeMayaStockTransaction(
            side: 'Bought',
            symbol: 'BTC',
            name: 'Bitcoin',
            shares: units,
            unitLabel: 'coins',
            type: 'crypto',
            amount: amount,
            createdAt: DateTime.now(),
          ),
          ...summary.investmentTransactions,
        ],
      ),
    );
  }

  test('Investment Fund balance is exactly the FakeMaya B3 balance', () {
    final state = seeded();

    expect(state.investmentBalance, investmentFund(state).balance);
    expect(
      state.investmentPortfolioValue,
      closeTo(state.investmentBalance + state.investmentHoldingsValue, 0.01),
    );
  });

  test('buying ₱200 of BTC moves it from the fund into holdings', () {
    final state = seeded();
    final fundBefore = state.investmentBalance;
    final holdingsBefore = state.investmentHoldingsValue;
    final portfolioBefore = state.investmentPortfolioValue;

    // Live price differs from the weekly snapshot on purpose.
    buyBitcoinInFakeMaya(state, 200, 4100000);

    expect(investmentFund(state).balance, fundBefore - 200);
    expect(state.investmentBalance, fundBefore - 200);
    expect(state.investmentHoldingsValue, closeTo(holdingsBefore + 200, 0.01));
    expect(state.investmentPortfolioValue, closeTo(portfolioBefore, 0.01));
  });

  test('A12 income transfer lands in the Investment Fund and A23', () async {
    final state = seeded();
    final before = investmentFund(state).balance;
    final portfolioBefore = state.investmentPortfolioValue;
    final walletBefore = state.fakeMayaLink!.summary.wallet;

    await state.depositIncomeToInvestment(
      transactionId: 'test-income-a12',
      incomeAmount: 5000,
      incomeDate: DateTime.now(),
      percentage: 10,
    );

    expect(investmentFund(state).balance, before + 500);
    expect(state.investmentPortfolioValue, portfolioBefore + 500);
    expect(state.fakeMayaLink!.summary.wallet, walletBefore - 500);
  });

  test('A23 Add investment updates the Investment Fund once', () async {
    final state = seeded();
    final before = investmentFund(state).balance;
    final portfolioBefore = state.investmentPortfolioValue;

    await state.depositMonthlyInvestment(1200);

    expect(investmentFund(state).balance, before + 1200);
    expect(state.investmentPortfolioValue, portfolioBefore + 1200);
  });

  test('changing the A23 target updates the FakeMaya bucket target', () async {
    final state = seeded();

    await state.setInvestmentPortfolioTarget(150000);

    expect(state.configuredInvestmentPortfolioTarget, 150000);
    expect(state.actionFieldValues['A23']?['amt'], '150000');
    expect(investmentFund(state).target, 150000);
  });
}
