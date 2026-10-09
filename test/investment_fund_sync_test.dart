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

  group('A30 annual return from weekly valuations', () {
    tearDown(() => AppClock.offset.value = Duration.zero);

    test('matches the hand-checked formula', () {
      final state = seeded();
      final t0 = DateTime(2026, 9, 1);
      state.investmentValuationHistory
        ..clear()
        ..addAll([
          {
            'valuedAt': t0.toIso8601String(),
            'holdingsValue': 1000.0,
            'netFlow': 0.0
          },
          {
            'valuedAt': t0.add(const Duration(days: 7)).toIso8601String(),
            'holdingsValue': 1100.0,
            'netFlow': 50.0, // bought ₱50 during week 1
          },
          {
            'valuedAt': t0.add(const Duration(days: 14)).toIso8601String(),
            'holdingsValue': 1150.0,
            'netFlow': 0.0,
          },
        ]);
      state.d1Ledger
        ..removeWhere((e) => e['type'] == 'investment_return_baseline')
        ..add({
          'type': 'investment_return_baseline',
          'date': t0.toIso8601String(),
          'anchorValuedAt': t0.toIso8601String(),
        });
      state.actionFieldValues['A30'] = {'pct': '12'};

      // week 1: (1100 - 1000 - 50) / (1000 + 50) = 50 / 1050
      // week 2: (1150 - 1100 - 0) / (1100 + 0)  = 50 / 1100
      const r1 = 50 / 1050;
      const r2 = 50 / 1100;
      const since = (1 + r1) * (1 + r2) - 1; // ≈ 9.52%
      expect(state.investmentReturnTrackedDays, 14);
      expect(state.investmentNetReturnSinceBaseline, closeTo(100, 1e-9));
      expect(state.investmentReturnPercentSinceBaseline,
          closeTo(since * 100, 1e-9));
      expect(state.investmentAnnualizedReturnPercent,
          closeTo(since * 100 * 365 / 14, 1e-9)); // ≈ 248%
      expect(state.investmentTargetReturnToDatePercent,
          closeTo(12 * 14 / 365, 1e-9)); // ≈ 0.46%
      expect(state.isInvestmentAnnualReturnOnTrack, isTrue);
    });

    test('a buy is not counted as a gain at the next weekly valuation',
        () async {
      final state = seeded();
      final weeksBefore = state.investmentValuationHistory.length;
      final btc = state.fakeMayaLink!.summary.investmentHoldings
          .firstWhere((h) => h.symbol == 'BTC');
      final valueBefore = state.investmentHoldingsValue;

      buyBitcoinInFakeMaya(state, 200, btc.price);
      // Last demo valuation was 3 days ago; 5 more days makes it due.
      AppClock.offset.value = const Duration(days: 5);
      await state.refreshFakeMayaAccount();

      expect(state.investmentValuationHistory.length, weeksBefore + 1);
      final latest = state.investmentValuationHistory.last;
      expect(latest['netFlow'], closeTo(200, 1e-9));
      expect(latest['holdingsValue'], closeTo(valueBefore + 200, 1e-6));
      expect(state.investmentWeeklyReturns.last.gain, closeTo(0, 1e-6));
    });

    test('demo account shows a positive annualized return', () {
      final state = seeded();
      expect(state.hasInvestmentReturnWeek, isTrue);
      expect(state.investmentAnnualizedReturnPercent, greaterThan(0));
      expect(
          state.investmentValuationHistory
              .every((e) => (e['holdingsValue'] as num) > 0),
          isTrue);
    });
  });

  group('selling holdings in FakeMaya', () {
    // What FakeMaya's confirmed sell writes: units leave holdings, the
    // proceeds land in the wallet (not the Investment Fund).
    void sellBitcoinInFakeMaya(AppState state, double proceeds, double price) {
      final link = state.fakeMayaLink!;
      final summary = link.summary;
      final units = proceeds / price;
      final createdAt = DateTime.now();
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
          wallet: summary.wallet + proceeds,
          investmentHoldings: [
            for (final h in summary.investmentHoldings)
              h.symbol == 'BTC' ? h.copyWith(units: h.units - units) : h,
          ],
          investmentTransactions: [
            FakeMayaStockTransaction(
              side: 'Sold',
              symbol: 'BTC',
              name: 'Bitcoin',
              shares: units,
              unitLabel: 'coins',
              type: 'crypto',
              amount: proceeds,
              createdAt: createdAt,
            ),
            ...summary.investmentTransactions,
          ],
          transactions: [
            FakeMayaTransaction(
              title: 'Sold crypto',
              detail: 'Bitcoin (BTC) · To My Wallet',
              age: 'Just now',
              amountText: '+ ₱5,000.00',
              createdAt: createdAt,
            ),
            ...summary.transactions,
          ],
        ),
      );
    }

    test('scenario 1: sell ₱5,000 of BTC', () {
      final state = seeded();
      final fundBefore = state.investmentBalance;
      final holdingsBefore = state.investmentHoldingsValue;
      final portfolioBefore = state.investmentPortfolioValue;
      final walletBefore = state.fakeMayaLink!.summary.wallet;

      // Sold above the weekly price, so the proceeds include a gain.
      sellBitcoinInFakeMaya(state, 5000, 4200000);

      expect(state.investmentBalance, fundBefore); // fund untouched
      expect(investmentFund(state).balance, fundBefore);
      expect(
          state.investmentHoldingsValue, closeTo(holdingsBefore - 5000, 1e-6));
      expect(state.investmentPortfolioValue,
          closeTo(portfolioBefore - 5000, 1e-6));
      expect(state.fakeMayaLink!.summary.wallet, walletBefore + 5000);

      final sale =
          state.allTransactions.firstWhere((tx) => tx.title == 'Sold crypto');
      expect(sale.amount, 5000);
      expect(sale.isLabeled, isFalse); // shows on Home to be labelled
      expect(sale.isInternalFakeMayaTransfer, isFalse);
    });

    test('Total Invested counts buys only; sales and prices do not move it',
        () {
      final state = seeded();
      final end = DateTime(2100);
      final investedBefore = state.investmentTotalInvestedBefore(end);
      expect(investedBefore, closeTo(state.investmentHoldingsCostBasis, 1e-6));

      buyBitcoinInFakeMaya(state, 100, 4000000);
      expect(state.investmentTotalInvestedBefore(end),
          closeTo(investedBefore + 100, 1e-6));

      sellBitcoinInFakeMaya(state, 5000, 4200000);
      expect(state.investmentTotalInvestedBefore(end),
          closeTo(investedBefore + 100, 1e-6));
    });

    test('Unrealized = holdings value - amount still invested', () {
      final state = seeded();
      expect(
        state.investmentUnrealizedGain,
        closeTo(
            state.investmentHoldingsValue - state.investmentHoldingsCostBasis,
            1e-9),
      );
    });

    test('a buy paid from the Investment Fund is not wallet spending', () {
      const buy = FakeMayaTransaction(
        title: 'Bought crypto',
        detail: 'Bitcoin (BTC) · From Investment Fund',
        age: 'Just now',
        amountText: '- ₱200.00',
      );
      const walletBuy = FakeMayaTransaction(
        title: 'Bought crypto',
        detail: 'Bitcoin (BTC) · From My Wallet',
        age: 'Just now',
        amountText: '- ₱200.00',
      );
      expect(buy.isInternalFakeMayaTransfer, isTrue);
      expect(walletBuy.isInternalFakeMayaTransfer, isFalse);
    });
  });
}
