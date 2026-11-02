import 'dart:convert';

import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('manual cash transactions update the account and combined ledger',
      () async {
    final state = AppState();
    final date = DateTime(2026, 7, 9, 10, 30);

    await state.addManualCashTransaction(
      title: 'Cash allowance',
      detail: 'Weekly cash',
      amount: 1000,
      occurredAt: date,
      category: 'Gift',
      source: 'Basic Needs Fund',
    );
    await state.addManualCashTransaction(
      title: 'Lunch',
      detail: 'Campus canteen',
      amount: -250,
      occurredAt: date.add(const Duration(hours: 2)),
      category: 'Food & drink',
      source: 'Basic Needs Fund',
    );

    expect(state.cashOnHandBalance, 750);
    expect(state.manualTransactions, hasLength(2));
    expect(state.allTransactions, hasLength(2));
    expect(state.manualTransactions.last.account, 'Cash on Hand');
    expect(state.manualTransactions.last.category, 'Food & drink');
    expect(state.manualTransactions.last.source, 'Basic Needs Fund');
  });

  test('manual cash expense cannot exceed the account balance', () async {
    final state = AppState();

    await expectLater(
      state.addManualCashTransaction(
        title: 'Purchase',
        detail: '',
        amount: -100,
        occurredAt: DateTime(2026, 7, 9),
        category: 'Shopping',
        source: 'Basic Needs Fund',
      ),
      throwsStateError,
    );
  });

  test('unexpected expense uses Needs, Buffer, then Emergency Fund', () async {
    final state = AppState()
      ..cashOnHandBalance = 1500
      ..needsTarget = 1000
      ..needsBalance = 200
      ..bufferBalance = 300
      ..emergencyFundBalance = 500;

    final preview = state.planUnexpectedExpenseRecovery(900);
    expect(preview.fromNeeds, 200);
    expect(preview.fromBuffer, 300);
    expect(preview.fromEmergencyFund, 400);
    expect(preview.uncovered, 0);
    expect(preview.amountToRebuild, 700);

    await state.addManualCashTransaction(
      title: 'Urgent clinic visit',
      detail: 'Walk-in consultation',
      amount: -900,
      occurredAt: DateTime(2026, 10, 30, 9),
      category: 'Health',
      source: 'Cash on Hand',
      unexpectedExpense: true,
    );

    expect(state.cashOnHandBalance, 600);
    expect(state.needsBalance, 0);
    expect(state.bufferBalance, 0);
    expect(state.emergencyFundBalance, 100);
    expect(state.manualTransactions.single.tag, 'Unexpected expense');
    expect(state.jarLedger.first.type, JarEventType.unexpectedExpense);
    expect(state.jarLedger.first.needsOut, 200);
    expect(state.jarLedger.first.bufferOut, 300);
    expect(state.jarLedger.first.emergencyOut, 400);
    expect(state.pendingEmergencyReplenishment, 400);
    expect(
      state.d1Ledger.single,
      containsPair('sourceTransactionId', state.manualTransactions.single.id),
    );
  });

  test('unexpected expense reports any amount that needs another source', () {
    final state = AppState()
      ..needsBalance = 100
      ..bufferBalance = 50
      ..emergencyFundBalance = 200;

    final preview = state.planUnexpectedExpenseRecovery(500);

    expect(preview.isFullyCovered, isFalse);
    expect(preview.fromNeeds, 100);
    expect(preview.fromBuffer, 50);
    expect(preview.fromEmergencyFund, 200);
    expect(preview.uncovered, 150);
  });

  test('unexpected expense type is ignored for money in', () async {
    final state = AppState();

    await state.addManualCashTransaction(
      title: 'Allowance',
      detail: 'Weekly',
      amount: 500,
      occurredAt: DateTime(2026, 10, 30, 9),
      category: 'Gift',
      source: 'Cash on Hand',
      unexpectedExpense: true,
    );

    expect(state.manualTransactions.single.tag, isNull);
    expect(state.jarLedger, isEmpty);
    expect(state.d1Ledger, isEmpty);
  });

  test('relabeling an unexpected expense preserves its recovery allocation',
      () async {
    final state = AppState()
      ..cashOnHandBalance = 1000
      ..needsBalance = 100
      ..bufferBalance = 100
      ..emergencyFundBalance = 500;

    await state.addManualCashTransaction(
      title: 'Urgent care',
      detail: 'Clinic',
      amount: -400,
      occurredAt: DateTime(2026, 10, 30, 9),
      category: 'Health',
      source: 'Cash on Hand',
      unexpectedExpense: true,
    );
    final transaction = state.manualTransactions.single;
    final emergencyAfterRecovery = state.emergencyFundBalance;

    await state.labelFakeMayaTransaction(
      transactionId: transaction.transactionId,
      category: 'Health',
      source: 'Cash on Hand',
      note: 'Receipt attached',
    );

    expect(state.emergencyFundBalance, emergencyAfterRecovery);
    expect(
      state.d1Ledger.where((entry) => entry['type'] == 'use_emergency'),
      hasLength(1),
    );
    expect(
      state.jarLedger
          .where((event) => event.type == JarEventType.unexpectedExpense),
      hasLength(1),
    );
    expect(state.manualTransactions.single.tag, 'Unexpected expense');
    expect(state.manualTransactions.single.note, 'Receipt attached');
  });

  test(
      'unexpected expense withdraws a linked Emergency Fund only for its remainder',
      () async {
    final state = AppState()
      ..seedEmergencyFundMockDataForTesting()
      ..cashOnHandBalance = 1000
      ..needsBalance = 100
      ..bufferBalance = 100;
    final beforeGoal = state.fakeMayaLink!.summary
        .personalGoalById(FakeMayaPersonalGoal.emergencyFundId)!
        .balance;

    await state.addManualCashTransaction(
      title: 'Emergency medicine',
      detail: 'Pharmacy',
      amount: -500,
      occurredAt: DateTime(2026, 10, 30, 9),
      category: 'Health',
      source: 'Cash on Hand',
      unexpectedExpense: true,
    );

    final afterGoal = state.fakeMayaLink!.summary
        .personalGoalById(FakeMayaPersonalGoal.emergencyFundId)!
        .balance;
    expect(afterGoal, beforeGoal - 300);
    expect(state.jarLedger.first.emergencyOut, 300);
  });

  test('essential fund allocation is refused without a FakeMaya Wallet',
      () async {
    final state = AppState();
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day, 8);

    await state.addManualCashTransaction(
      title: 'Old salary',
      detail: 'Previous day salary',
      amount: 9000,
      occurredAt: date.subtract(const Duration(days: 1)),
      category: 'Salary',
      source: 'Wallet',
    );
    await state.addManualCashTransaction(
      title: 'Racket income',
      detail: 'Client payment',
      amount: 5000,
      occurredAt: date,
      category: 'Business income',
      source: 'Wallet',
    );
    await state.addManualCashTransaction(
      title: 'Gift income',
      detail: 'Family gift',
      amount: 7500,
      occurredAt: date.add(const Duration(minutes: 10)),
      category: 'Gift',
      source: 'Wallet',
    );

    expect(state.pendingEssentialIncomeTransactions, hasLength(2));

    // Without a FakeMaya Wallet to pay for it, nothing can be set aside:
    // the transfer is refused instead of creating money.
    await expectLater(
      state.depositPendingIncomeToEssentialFund(
        incomes: state.pendingEssentialIncomeTransactions,
        percentage: 50,
      ),
      throwsA(isA<FakeMayaException>()),
    );

    expect(state.essentialExpensesBalance, 0);
    expect(state.pendingEssentialIncomeTransactions, hasLength(2));
  });

  test('essential fund allocation ignores FakeMaya goal transfers', () {
    final now = DateTime.now();
    final state = AppState()
      ..fakeMayaLink = FakeMayaLink(
        userId: 'user-1',
        email: 'main@gmail.com',
        name: 'Main',
        phone: '+63 917 000 0000',
        provider: 'email',
        accessToken: 'token',
        refreshToken: 'refresh',
        expiresAt: now.add(const Duration(hours: 1)),
        summary: FakeMayaAccountSummary(
          wallet: 1700,
          savings: 0,
          timeDeposit: 0,
          goalName: 'Essential Expense Fund',
          goalEmoji: '🏠',
          goalBalance: 300,
          goalTarget: 25000,
          selectedGoalId: 'B1',
          personalGoals: FakeMayaPersonalGoal.defaultGoals(),
          creditLimit: 0,
          creditUsed: 0,
          transactions: [
            FakeMayaTransaction(
              id: 'goal-transfer-1',
              title: 'Deposited to goal',
              detail: 'Essential Expense Fund',
              age: 'Just now',
              amountText: '+ ₱300.00',
              createdAt: now,
              category: 'Other income',
              source: 'E-wallet',
            ),
          ],
          updatedAt: now,
        ),
      );

    expect(state.pendingEssentialIncomeTransactions, isEmpty);
  });

  test('labeling a cash-out from Basic Needs Fund updates action ledger',
      () async {
    final now = DateTime.now();
    final state = AppState()
      ..essentialExpensesBalance = 1000
      ..fakeMayaLink = FakeMayaLink(
        userId: 'user-1',
        email: 'main@gmail.com',
        name: 'Main',
        phone: '+63 917 000 0000',
        provider: 'email',
        accessToken: 'token',
        refreshToken: 'refresh',
        expiresAt: now.add(const Duration(hours: 1)),
        summary: FakeMayaAccountSummary(
          wallet: 5000,
          savings: 0,
          timeDeposit: 0,
          goalName: 'Essential Expense Fund',
          goalEmoji: '🏠',
          goalBalance: 1000,
          goalTarget: 25000,
          selectedGoalId: 'B1',
          personalGoals: [
            FakeMayaPersonalGoal.defaultForId('B1').copyWith(balance: 1000),
          ],
          creditLimit: 0,
          creditUsed: 0,
          transactions: [
            FakeMayaTransaction(
              id: 'expense-1',
              title: 'Paid merchant',
              detail: 'To: Grocery Mart',
              age: 'Just now',
              amountText: '- ₱250.00',
              createdAt: now,
              account: 'Wallet',
            ),
          ],
          updatedAt: now,
        ),
      );

    await state.labelFakeMayaTransaction(
      transactionId: 'expense-1',
      category: 'Food & drink',
      source: 'Basic Needs Fund',
    );
    await state.labelFakeMayaTransaction(
      transactionId: 'expense-1',
      category: 'Food & drink',
      source: 'Basic Needs Fund',
    );

    // With FakeMaya linked, the fund balance is bucket B1. Labeling alone
    // moves no money (pulling from the bucket is a separate step), so B1 is
    // unchanged; the use is still recorded once in the action ledger.
    expect(state.essentialExpensesBalance, 1000);
    expect(
      state.d1Ledger.where((entry) => entry['type'] == 'use_essential'),
      hasLength(1),
    );
    expect(state.d1Ledger.single['amount'], 250);
    expect(state.d1Ledger.single['sourceTransactionId'], 'expense-1');

    await state.labelFakeMayaTransaction(
      transactionId: 'expense-1',
      category: 'Food & drink',
      source: 'E-wallet',
    );

    expect(state.essentialExpensesBalance, 1000);
    expect(
      state.d1Ledger.where((entry) => entry['type'] == 'use_essential'),
      isEmpty,
    );
  });

  test('labeling a cash-out from Emergency Fund updates safety ledger',
      () async {
    final now = DateTime.now();
    final state = AppState()
      ..emergencyFundBalance = 5000
      ..fakeMayaLink = FakeMayaLink(
        userId: 'user-1',
        email: 'main@gmail.com',
        name: 'Main',
        phone: '+63 917 000 0000',
        provider: 'email',
        accessToken: 'token',
        refreshToken: 'refresh',
        expiresAt: now.add(const Duration(hours: 1)),
        summary: FakeMayaAccountSummary(
          wallet: 5000,
          savings: 0,
          timeDeposit: 0,
          goalName: 'Emergency Fund',
          goalEmoji: '🛟',
          goalBalance: 5000,
          goalTarget: 60000,
          selectedGoalId: 'B2',
          personalGoals: [
            FakeMayaPersonalGoal.defaultForId('B2').copyWith(balance: 5000),
          ],
          creditLimit: 0,
          creditUsed: 0,
          transactions: [
            FakeMayaTransaction(
              id: 'emergency-expense-1',
              title: 'Emergency payment',
              detail: 'To: Urgent care',
              age: 'Just now',
              amountText: '- ₱1200.00',
              createdAt: now,
              account: 'Wallet',
            ),
          ],
          updatedAt: now,
        ),
      );

    await state.labelFakeMayaTransaction(
      transactionId: 'emergency-expense-1',
      category: 'Health',
      source: 'Emergency Fund',
    );

    expect(state.emergencyFundBalance, 3800);
    expect(state.pendingEmergencyReplenishment, 1200);
    expect(
      state.d1Ledger.where((entry) => entry['type'] == 'use_emergency'),
      hasLength(1),
    );
    expect(
      state.d1Ledger.single['sourceTransactionId'],
      'emergency-expense-1',
    );
  });

  test('FakeMaya summary preserves personal goal balances', () {
    final summary = FakeMayaAccountSummary.fromMap({
      'wallet': 12500,
      'savings': 0,
      'time_deposit': 0,
      'goal_balance': 7250,
      'app_state': {
        'selectedGoalId': 'B1',
        'personalGoals': [
          {
            'id': 'B1',
            'name': 'Essential Expense Fund',
            'label': 'Personal Goal 1',
            'emoji': '🏠',
            'account': '8189 3753 6101',
            'balance': 6250,
            'target': 25000,
            'daysLeft': 180,
            'rate': 8,
          },
          {
            'id': 'B2',
            'name': 'Upcoming bill and payment obligations',
            'label': 'Personal Goal 2',
            'emoji': '🧾',
            'account': '8189 3753 6102',
            'balance': 1000,
            'target': 25000,
            'daysLeft': 180,
            'rate': 8,
          },
        ],
        'transactions': [],
      },
    });

    expect(summary.goalBalance, 7250);
    expect(summary.essentialExpenseFund?.balance, 6250);
    expect(summary.personalGoalById('B2')?.balance, 1000);
    expect(
      summary.toFakeMayaAppState()['personalGoals'],
      isA<List<Map<String, dynamic>>>(),
    );
  });

  test('FakeMaya personal goal deposit targets essential fund bucket', () {
    final summary = FakeMayaAccountSummary(
      wallet: 12500,
      savings: 0,
      timeDeposit: 0,
      goalName: 'Essential Expense Fund',
      goalEmoji: '🏠',
      goalBalance: 0,
      goalTarget: 25000,
      selectedGoalId: 'B1',
      personalGoals: FakeMayaPersonalGoal.defaultGoals(),
      creditLimit: 0,
      creditUsed: 0,
      transactions: const [],
      updatedAt: null,
    );

    final goals = summary.personalGoalsWithDeposit('B1', 6250);
    final essential = goals.firstWhere((goal) => goal.id == 'B1');
    final otherGoals = goals.where((goal) => goal.id != 'B1');

    expect(essential.name, 'Essential Expense Fund');
    expect(essential.balance, 6250);
    expect(otherGoals.every((goal) => goal.balance == 0), isTrue);
  });

  test('FakeMaya personal goal payload with emojis is UTF-8 encodable', () {
    final summary = FakeMayaAccountSummary(
      wallet: 1700,
      savings: 0,
      timeDeposit: 0,
      goalName: 'Essential Expense Fund',
      goalEmoji: '🏠',
      goalBalance: 300,
      goalTarget: 25000,
      selectedGoalId: 'B1',
      personalGoals: FakeMayaPersonalGoal.defaultGoals()
          .map((goal) => goal.id == 'B1' ? goal.copyWith(balance: 300) : goal)
          .toList(),
      creditLimit: 0,
      creditUsed: 0,
      transactions: const [],
      updatedAt: null,
    );
    final body = {
      'wallet': summary.wallet,
      'savings': summary.savings,
      'time_deposit': summary.timeDeposit,
      'goal_balance': summary.goalBalance,
      'app_state': summary.toFakeMayaAppState(),
    };

    expect(utf8.encode(jsonEncode(body)), isNotEmpty);
  });

  test('FakeMaya personal goal deposit can target lifestyle bucket', () {
    final summary = FakeMayaAccountSummary(
      wallet: 5000,
      savings: 0,
      timeDeposit: 0,
      goalName: 'Personal Lifestyle Fund',
      goalEmoji: '✨',
      goalBalance: 0,
      goalTarget: 25000,
      selectedGoalId: 'B4',
      personalGoals: FakeMayaPersonalGoal.defaultGoals(),
      creditLimit: 0,
      creditUsed: 0,
      transactions: const [],
      updatedAt: null,
    );

    final goals = summary.personalGoalsWithDeposit('B4', 1200);
    final lifestyle = goals.firstWhere((goal) => goal.id == 'B4');
    final otherGoals = goals.where((goal) => goal.id != 'B4');

    expect(lifestyle.name, 'Personal Lifestyle Fund');
    expect(lifestyle.balance, 1200);
    expect(otherGoals.every((goal) => goal.balance == 0), isTrue);
  });

  testWidgets(
      'the global add-transaction button opens the manual transaction sheet',
      (tester) async {
    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: MainShell()),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Add transaction'), findsOneWidget);
    await tester.tap(find.byTooltip('Add transaction'));
    await tester.pumpAndSettle();

    expect(find.text('Log transaction'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Cash on Hand'), findsOneWidget);
    expect(find.text('Money out'), findsWidgets);
    expect(find.text('Money in'), findsWidgets);
    expect(find.text('Save transaction'), findsOneWidget);
  });
}
