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

    expect(find.text('₱ 1,000.00'), findsWidgets);

    await tester.tap(find.text('Pyramid'));
    await tester.pump();

    expect(find.text('Cash Flow & Basic Needs'), findsOneWidget);
    expect(find.text('Financial Safety'), findsOneWidget);
    expect(find.text('Accumulating Wealth'), findsOneWidget);
    expect(find.text('Financial Freedom'), findsOneWidget);

    await tester.tap(find.text('Spending'));
    await tester.pump();

    expect(find.text('Food & drink'), findsOneWidget);
    expect(find.text('Health'), findsOneWidget);
    expect(find.text('Investment'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Transport'), findsNothing);
    expect(find.text('Transfer'), findsNothing);
  });

  testWidgets('insights show every FakeMaya account without duplicates',
      (tester) async {
    final now = DateTime.now();
    final link = _linkWithTransactions(
      now,
      wallet: 1000,
      savings: 2000,
      timeDeposit: 3000,
      goalBalance: 4000,
    );
    final state = AppState()
      ..fakeMayaLink = link
      ..assets.addAll([
        MoneyItem('FakeMaya Wallet', 'Linked from FakeMaya', 1000),
        MoneyItem('FakeMaya Savings', 'Linked from FakeMaya', 2000),
      ]);

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: InsightsPage())),
      ),
    );
    await tester.pump();

    expect(find.text('FakeMaya Wallet'), findsOneWidget);
    expect(find.text('FakeMaya Savings'), findsOneWidget);
    expect(find.text('FakeMaya Time Deposit'), findsOneWidget);
    expect(find.text('FakeMaya Goal'), findsOneWidget);
    expect(find.text('Maya Wallet'), findsNothing);
    expect(find.text('Maya Savings'), findsNothing);
    expect(find.text('₱ 10,000.00'), findsWidgets);
    expect(find.text('₱ 20,000.00'), findsNothing);
  });

  testWidgets('insights show existing FakeMaya accounts with zero balances',
      (tester) async {
    final now = DateTime.now();
    final state = AppState()
      ..fakeMayaLink = _linkWithTransactions(now, wallet: 1000);

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: InsightsPage())),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Accounts'));
    await tester.pump();

    expect(find.text('FakeMaya Wallet'), findsOneWidget);
    expect(find.text('FakeMaya Savings'), findsOneWidget);
    expect(find.text('FakeMaya Time Deposit'), findsOneWidget);
    expect(find.text('FakeMaya Goal'), findsOneWidget);
    expect(find.text('₱ 0.00'), findsWidgets);
  });
}

FakeMayaLink _linkWithTransactions(
  DateTime now, {
  double wallet = 1000,
  double savings = 0,
  double timeDeposit = 0,
  double goalBalance = 0,
}) {
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
      wallet: wallet,
      savings: savings,
      timeDeposit: timeDeposit,
      goalName: 'Goal',
      goalEmoji: '🎯',
      goalBalance: goalBalance,
      goalTarget: 10000,
      creditLimit: 0,
      creditUsed: 0,
      transactions: transactions,
      updatedAt: now,
    ),
  );
}
