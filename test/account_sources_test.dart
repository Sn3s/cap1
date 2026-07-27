import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accounts remain manual until individually synced', () async {
    final state = AppState()
      ..fakeMayaLink = FakeMayaLink(
        userId: 'demo',
        email: 'demo@example.com',
        name: 'Demo',
        phone: '',
        provider: 'email',
        accessToken: '',
        refreshToken: '',
        expiresAt: null,
        summary: FakeMayaAccountSummary(
          wallet: 5000,
          savings: 9000,
          timeDeposit: 12000,
          goalName: 'Trip',
          goalEmoji: '',
          goalBalance: 3000,
          goalTarget: 10000,
          creditLimit: 0,
          creditUsed: 0,
          transactions: [
            FakeMayaTransaction(
              id: 'maya-1',
              title: 'Paid merchant',
              detail: 'To: Store',
              age: 'Today',
              amountText: '- ₱500.00',
              createdAt: DateTime(2026, 7, 9),
              category: 'Groceries',
              source: 'Basic Needs Fund',
            ),
          ],
          updatedAt: DateTime(2026, 7, 9),
        ),
      );

    expect(state.accountBalance('Wallet'), 0);
    expect(state.allTransactions, isEmpty);

    await state.setAccountFakeMayaSync('Savings', true);
    expect(state.accountBalance('Savings'), 9000);
    expect(state.accountBalance('Wallet'), 0);
    expect(state.allTransactions, isEmpty);
    expect(state.assets.map((item) => item.name), ['Savings']);

    await state.setAccountFakeMayaSync('Wallet', true);
    expect(state.accountBalance('Wallet'), 5000);
    expect(state.allTransactions, hasLength(1));
    expect(
      state.assets.map((item) => item.name),
      containsAll(['Wallet', 'Savings']),
    );

    await state.setAccountFakeMayaSync('Savings', false);
    expect(state.accountBalance('Savings'), 0);
    expect(state.accountBalance('Wallet'), 5000);
    expect(state.assets.map((item) => item.name), ['Wallet']);
  });

  test('FakeMaya credit used is tracked as a liability and bill transaction',
      () async {
    final state = AppState()
      ..fakeMayaLink = FakeMayaLink(
        userId: 'demo',
        email: 'demo@example.com',
        name: 'Demo',
        phone: '',
        provider: 'email',
        accessToken: '',
        refreshToken: '',
        expiresAt: null,
        summary: FakeMayaAccountSummary(
          wallet: 5000,
          savings: 0,
          timeDeposit: 0,
          goalName: 'Trip',
          goalEmoji: '',
          goalBalance: 0,
          goalTarget: 10000,
          creditLimit: 5000,
          creditUsed: 1250,
          creditBillingDay: 15,
          transactions: const [],
          updatedAt: DateTime(2026, 7, 9),
        ),
      );

    await state.setAccountFakeMayaSync('Savings', true);

    expect(state.liabilities.map((item) => item.name),
        contains('Maya Easy Credit'));
    expect(
      state.liabilities
          .singleWhere((item) => item.name == 'Maya Easy Credit')
          .value,
      1250,
    );
    expect(
      state.liabilities
          .singleWhere((item) => item.name == 'Maya Easy Credit')
          .description,
      contains('Due'),
    );
    expect(state.allTransactions, hasLength(1));
    expect(state.allTransactions.single.title, 'Maya Easy Credit bill');
    expect(state.allTransactions.single.amount, -1250);
    expect(state.allTransactions.single.excludedFromInsights, isTrue);
  });

  test('manual transactions update the selected manual account', () async {
    final state = AppState();

    await state.addManualCashTransaction(
      title: 'Wallet opening balance',
      detail: 'Manual setup',
      amount: 2000,
      occurredAt: DateTime(2026, 7, 9),
      category: 'Other income',
      source: 'Basic Needs Fund',
      account: 'Wallet',
    );

    expect(state.accountBalance('Wallet'), 2000);
    expect(state.accountBalance('Cash on Hand'), 0);
    expect(state.manualTransactions.single.account, 'Wallet');
  });

  testWidgets('settings accounts use generic account names', (tester) async {
    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: LinkedAccountsScreen()),
      ),
    );

    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('Cash on Hand'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Savings'), findsOneWidget);
    expect(find.text('Time Deposit'), findsOneWidget);
    expect(find.text('Goal Savings'), findsOneWidget);
    expect(find.text('Manual'), findsWidgets);
  });
}
