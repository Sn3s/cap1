import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

/// Replaces the linked FakeMaya summary's holdings.
void _setHoldings(AppState state, List<FakeMayaInvestmentHolding> holdings) {
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
    summary: link.summary.copyWith(investmentHoldings: holdings),
  );
}

void main() {
  test('headline holdings value matches FakeMaya (units × synced price)', () {
    final state = AppState()..seedAccumulatingWealthMockDataForTesting();
    final summary = state.fakeMayaLink!.summary;
    final fakeMayaScreenValue = summary.investmentHoldings
        .where((h) => h.units > 0)
        .fold<double>(0, (sum, h) => sum + h.units * h.price);

    expect(state.investmentHoldingsLiveValue,
        closeTo(fakeMayaScreenValue, 1e-9));
    expect(
      state.investmentPortfolioLiveValue,
      closeTo(state.investmentBalance + fakeMayaScreenValue, 1e-9),
    );
  });

  test('a ₱20,000 BTC buy shows the same ₱19,999.89 FakeMaya shows', () {
    final state = AppState()..seedAccumulatingWealthMockDataForTesting();
    const price = 3785577.87;
    // FakeMaya rounds coins to 8 decimals, then values them at a price
    // that has since moved slightly.
    final units = double.parse((20000 / price).toStringAsFixed(8));
    const laterPrice = price * (1 - 0.0000055);
    final btc = state.fakeMayaLink!.summary.investmentHoldings
        .firstWhere((h) => h.symbol == 'BTC')
        .copyWith(units: units, price: laterPrice, costBasis: 20000);
    _setHoldings(state, [btc]);

    expect(money(state.investmentHoldingsLiveValue), money(units * laterPrice));
    expect(state.investmentHoldingsLiveValue, lessThan(20000));
    expect(state.investmentHoldingsLiveReturnPercent, lessThan(0));
  });

  test('a holding without a synced price counts at what was invested', () {
    final state = AppState()..seedAccumulatingWealthMockDataForTesting();
    final btc = state.fakeMayaLink!.summary.investmentHoldings
        .firstWhere((h) => h.symbol == 'BTC')
        .copyWith(price: 0, costBasis: 1234);
    _setHoldings(state, [btc]);
    expect(state.investmentHoldingsLiveValue, 1234);
  });

  test('weekly value, graph inputs and Health Score are untouched', () {
    final state = AppState()..seedAccumulatingWealthMockDataForTesting();
    final weekly = state.investmentHoldingsValue;
    final portfolio = state.investmentPortfolioValue;
    final score = state.healthScore;

    // Reading the live value must not change anything else.
    state.investmentHoldingsLiveValue;
    state.investmentPortfolioLiveValue;

    expect(state.investmentHoldingsValue, weekly);
    expect(state.investmentPortfolioValue, portfolio);
    expect(state.healthScore, score);
    expect(state.investmentPortfolioValue,
        closeTo(state.investmentBalance + state.investmentHoldingsValue, 1e-9));
  });
}
