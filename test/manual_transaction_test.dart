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

  test('essential fund allocation batches unallocated labeled incomes',
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

    await state.depositPendingIncomeToEssentialFund(
      incomes: state.pendingEssentialIncomeTransactions,
      percentage: 50,
    );

    expect(state.essentialExpensesBalance, 6250);
    expect(state.pendingEssentialIncomeTransactions, isEmpty);
    expect(
      state.d1Ledger.where((entry) => entry['type'] == 'essential_deposit'),
      hasLength(2),
    );
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
