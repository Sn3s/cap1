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

  test('FakeMaya investments do not use sample prices as balances', () async {
    final unfetchedBtc = FakeMayaInvestmentHolding.fromSymbolUnits('BTC', .01)!;
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
          goalName: 'Personal Goal',
          goalEmoji: '',
          goalBalance: 0,
          goalTarget: 10000,
          investmentHoldings: [unfetchedBtc],
          creditLimit: 0,
          creditUsed: 0,
          transactions: const [],
          updatedAt: null,
        ),
      );

    await state.setAccountFakeMayaSync('Wallet', true);

    expect(unfetchedBtc.price, 0);
    expect(
        state.assets.where((item) => item.name.contains('Bitcoin')), isEmpty);

    state.fakeMayaLink = FakeMayaLink(
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
        goalName: 'Personal Goal',
        goalEmoji: '',
        goalBalance: 0,
        goalTarget: 10000,
        investmentHoldings: [
          unfetchedBtc.copyWith(price: 4000000),
        ],
        creditLimit: 0,
        creditUsed: 0,
        transactions: const [],
        updatedAt: null,
      ),
    );
    await state.setAccountFakeMayaSync('Wallet', true);

    final bitcoin = state.assets.singleWhere(
      (item) => item.name == 'Bitcoin (BTC)',
    );
    expect(bitcoin.value, 40000);
  });

  test('FakeMaya goal savings account only exists when buckets exist', () {
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
        summary: const FakeMayaAccountSummary(
          wallet: 5000,
          savings: 0,
          timeDeposit: 0,
          goalName: 'Personal Goal',
          goalEmoji: '',
          goalBalance: 0,
          goalTarget: 10000,
          personalGoals: [],
          creditLimit: 5000,
          creditUsed: 0,
          transactions: [],
          updatedAt: null,
        ),
      );

    expect(state.accountExistsInFakeMaya('Wallet'), isTrue);
    expect(state.accountExistsInFakeMaya('Goal Savings'), isFalse);
    expect(
      state.fakeMayaBucketExists(FakeMayaPersonalGoal.essentialExpenseFundId),
      isFalse,
    );

    state.fakeMayaLink = FakeMayaLink(
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
        goalName: 'Emergency Fund',
        goalEmoji: '',
        goalBalance: 1000,
        goalTarget: 10000,
        personalGoals: [
          FakeMayaPersonalGoal.defaultForId('B2'),
        ],
        creditLimit: 5000,
        creditUsed: 0,
        transactions: const [],
        updatedAt: null,
      ),
    );

    expect(state.accountExistsInFakeMaya('Goal Savings'), isTrue);
    expect(
      state.fakeMayaBucketExists(FakeMayaPersonalGoal.emergencyFundId),
      isTrue,
    );
    expect(
      state.fakeMayaBucketExists(FakeMayaPersonalGoal.essentialExpenseFundId),
      isFalse,
    );
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
      contains('Every 15th'),
    );
    expect(state.allTransactions, hasLength(1));
    expect(state.allTransactions.single.title, 'Maya Easy Credit bill');
    expect(
      state.allTransactions.single.detail,
      contains('Next cycle bill'),
    );
    expect(state.allTransactions.single.amount, -1250);
    expect(state.allTransactions.single.excludedFromInsights, isTrue);
  });

  test('FakeMaya credit cycle bill date matches the billing day', () {
    const summary = FakeMayaAccountSummary(
      wallet: 5000,
      savings: 0,
      timeDeposit: 0,
      goalName: 'Investment Fund',
      goalEmoji: '',
      goalBalance: 0,
      goalTarget: 10000,
      creditLimit: 5000,
      creditUsed: 2500,
      creditBillingDay: 27,
      transactions: [],
      updatedAt: null,
    );

    expect(summary.nextCreditCycleBillDate?.day, 27);
    expect(summary.creditLiability?.description, contains('Every 27th'));
    expect(
      summary.creditBillTransaction?.detail,
      contains('Next cycle bill'),
    );
  });

  test('FakeMaya billing day resolves to the next matching calendar date', () {
    const summary = FakeMayaAccountSummary(
      wallet: 5000,
      savings: 0,
      timeDeposit: 0,
      goalName: 'Investment Fund',
      goalEmoji: '',
      goalBalance: 0,
      goalTarget: 10000,
      creditLimit: 5000,
      creditUsed: 2500,
      creditBillingDay: 15,
      transactions: [],
      updatedAt: null,
    );

    final nextCycle = summary.nextCreditCycleBillDate;
    expect(nextCycle, isNotNull);
    expect(nextCycle!.day, 15);
    expect(nextCycle.isBefore(DateTime.now()), isFalse);
  });

  test('FakeMaya credit can be read from top-level wallet row fields', () {
    final summary = FakeMayaAccountSummary.fromMap({
      'wallet': 5000,
      'savings': 0,
      'time_deposit': 0,
      'goal_balance': 0,
      'credit_limit': 5000,
      'credit_used': 2500,
      'app_state': {
        'wallet': 5000,
        'savings': 0,
        'timeDeposit': 0,
        'transactions': [],
      },
    });

    expect(summary.creditLimit, 5000);
    expect(summary.creditUsed, 2500);
    expect(summary.creditLiability?.value, 2500);
  });

  test('FakeMaya credit replaces stale credit card payment placeholders',
      () async {
    final state = AppState()
      ..onboardingExpenseLedger.add({
        'name': 'Credit card payment',
        'amount': 3500,
        'expenseType': ExpenseLayer.debtInvestments.name,
      })
      ..fakeMayaLink = FakeMayaLink(
        userId: 'demo',
        email: 'accumulating@gmail.com',
        name: 'Accumulating',
        phone: '',
        provider: 'email',
        accessToken: '',
        refreshToken: '',
        expiresAt: null,
        summary: FakeMayaAccountSummary(
          wallet: 5000,
          savings: 0,
          timeDeposit: 0,
          goalName: 'Investment Fund',
          goalEmoji: '',
          goalBalance: 0,
          goalTarget: 10000,
          creditLimit: 5000,
          creditUsed: 2500,
          creditBillingDay: 15,
          transactions: const [],
          updatedAt: DateTime(2026, 7, 9),
        ),
      );

    await state.setAccountFakeMayaSync('Wallet', true);

    expect(
      state.onboardingExpenseLedger
          .where((row) => row['name'] == 'Credit card payment'),
      isEmpty,
    );
    expect(
      state.liabilities
          .singleWhere((item) => item.name == 'Maya Easy Credit')
          .value,
      2500,
    );
    expect(state.allTransactions.single.amount, -2500);
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
