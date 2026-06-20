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
    ('Cash Flow Stability Plan', 'FakeMaya Wallet', false),
    ('Emergency Cushion', 'FakeMaya Savings', true),
    ('Net Worth Growth Plan', 'FakeMaya Time Deposit', true),
    ('Future Lifestyle Fund', 'FakeMaya Personal Goal', true),
  ];

  for (final item in cases) {
    testWidgets('${item.$1} uses ${item.$2}', (tester) async {
      final state = AppState()
        ..selectedGoal = item.$1
        ..fakeMayaLink = _fakeMayaLink();

      await tester.pumpWidget(
        AppScope(
          state: state,
          child: const MaterialApp(home: Scaffold(body: GoalsPage())),
        ),
      );
      await tester.pump();

      expect(find.textContaining(item.$2), findsWidgets);
      expect(find.text('Allocate'), item.$3 ? findsOneWidget : findsNothing);
    });
  }

  testWidgets('irregular income goal follows the ACT6 collection trace',
      (tester) async {
    final now = DateTime.now();
    final state = AppState()
      ..selectedGoal = 'Irregular Income Buffer'
      ..irregularIncomeFloor = 15000
      ..fakeMayaLink = _fakeMayaLink(
        transactions: [
          FakeMayaTransaction(
            id: 'income-1',
            title: 'Cash in',
            detail: 'From: Client A',
            age: 'Just now',
            amountText: '+ ₱10,000.00',
            createdAt: now.subtract(const Duration(days: 2)),
          ),
          FakeMayaTransaction(
            id: 'income-2',
            title: 'Cash in',
            detail: 'From: Client B',
            age: 'Just now',
            amountText: '+ ₱7,000.00',
            createdAt: now.subtract(const Duration(days: 1)),
          ),
          FakeMayaTransaction(
            id: 'expense-1',
            title: 'Sent money (simulated)',
            detail: 'To: Utility',
            age: 'Just now',
            amountText: '- ₱1,000.00',
            createdAt: now,
            category: 'Bills & utilities',
          ),
        ],
      );

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: GoalsPage())),
      ),
    );
    await tester.pump();

    expect(find.text('Collection trace'), findsOneWidget);
    expect(find.text('SURPLUS'), findsOneWidget);
    expect(find.text('SHORTFALL'), findsOneWidget);
    expect(find.text('Record plan adjustment'), findsNWidgets(2));
    expect(find.text('Weekly anxiety check-in'), findsOneWidget);
    expect(find.textContaining('1/1 categorized'), findsOneWidget);
  });
}

FakeMayaLink _fakeMayaLink({
  List<FakeMayaTransaction> transactions = const [],
}) {
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
      wallet: 1100,
      savings: 2200,
      timeDeposit: 3300,
      goalName: 'My Goal',
      goalEmoji: '🎯',
      goalBalance: 4400,
      goalTarget: 10000,
      creditLimit: 0,
      creditUsed: 0,
      transactions: transactions,
      updatedAt: null,
    ),
  );
}
