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

  testWidgets('activity exposes the manual transaction sheet', (tester) async {
    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: const MaterialApp(home: Scaffold(body: ActivityPage())),
      ),
    );
    await tester.pump();

    expect(find.text('Transaction'), findsOneWidget);
    await tester.tap(find.text('Transaction'));
    await tester.pumpAndSettle();

    expect(find.text('Log cash transaction'), findsOneWidget);
    expect(find.text('Account: Cash on Hand'), findsOneWidget);
    expect(find.text('Money out'), findsWidgets);
    expect(find.text('Money in'), findsWidgets);
    expect(find.text('Save transaction'), findsOneWidget);
  });
}
