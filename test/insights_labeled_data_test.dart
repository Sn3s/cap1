import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('insights use labeled spending grouped by financial layer',
      (tester) async {
    final now = DateTime.now();
    final state = AppState()..fakeMayaLink = _linkWithTransactions(now);

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: InsightsPage())),
      ),
    );
    await tester.pump();

    expect(find.text('₱ 1,000.00'), findsOneWidget);
    expect(find.text('Cash Flow & Basic Needs'), findsOneWidget);
    expect(find.text('Financial Safety'), findsOneWidget);
    expect(find.text('Accumulating Wealth'), findsOneWidget);
    expect(find.text('Financial Freedom'), findsOneWidget);
    expect(find.text('Food & drink'), findsOneWidget);
    expect(find.text('Health'), findsOneWidget);
    expect(find.text('Investment'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Transport'), findsNothing);
    expect(find.text('Transfer'), findsNothing);
  });
}

FakeMayaLink _linkWithTransactions(DateTime now) {
  FakeMayaTransaction expense(
    String id,
    String category,
    double amount, {
    bool excluded = false,
  }) {
    return FakeMayaTransaction(
      id: id,
      title: 'Sent money (simulated)',
      detail: 'To: Merchant',
      age: 'Just now',
      amountText: '- ₱${amount.toStringAsFixed(2)}',
      createdAt: now,
      category: category,
      excludedFromInsights: excluded,
    );
  }

  final transactions = [
    expense('food', 'Food & drink', 100),
    expense('health', 'Health', 200),
    expense('investment', 'Investment', 300),
    expense('travel', 'Travel', 400),
    expense('excluded', 'Transport', 500, excluded: true),
    expense('transfer', 'Transfer', 600),
    FakeMayaTransaction(
      id: 'income',
      title: 'Cash in',
      detail: 'From: Employer',
      age: 'Just now',
      amountText: '+ ₱700.00',
      createdAt: now,
      category: 'Food & drink',
    ),
  ];

  return FakeMayaLink(
    userId: 'user',
    email: 'user@example.com',
    name: 'User',
    phone: '',
    provider: 'email',
    accessToken: '',
    refreshToken: '',
    expiresAt: null,
    summary: FakeMayaAccountSummary(
      wallet: 1000,
      savings: 0,
      timeDeposit: 0,
      goalName: 'Goal',
      goalEmoji: '🎯',
      goalBalance: 0,
      goalTarget: 10000,
      creditLimit: 0,
      creditUsed: 0,
      transactions: transactions,
      updatedAt: now,
    ),
  );
}
