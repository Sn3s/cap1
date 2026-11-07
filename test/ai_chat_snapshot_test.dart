import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chat snapshot uses labelled spending and ignores own-account transfers',
      () {
    final now = AppClock.now();
    final state = AppState()
      ..manualTransactions.addAll([
        FakeMayaTransaction(
          id: 'groceries',
          title: 'Campus market',
          detail: 'Weekly groceries',
          age: 'Just now',
          amountText: '-₱500',
          createdAt: now,
          category: 'Food',
          source: 'Cash on Hand',
          account: 'Cash on Hand',
        ),
        FakeMayaTransaction(
          id: 'salary',
          title: 'Freelance payment',
          detail: 'October project',
          age: 'Just now',
          amountText: '₱2,000',
          createdAt: now.subtract(const Duration(hours: 1)),
          category: 'Income',
          source: 'Wallet',
          account: 'Wallet',
        ),
        FakeMayaTransaction(
          id: 'own-transfer',
          title: 'Cash in',
          detail: 'From: Savings',
          age: 'Just now',
          amountText: '₱1,000',
          createdAt: now.subtract(const Duration(hours: 2)),
          category: 'Transfer',
          source: 'Savings',
          account: 'Wallet',
        ),
      ]);

    const coach = ShellbyAiCoach();
    final input = coach.chatInputForTesting(
      state,
      const [ChatMessage(true, 'How much did I spend on food?')],
    );

    expect(input, contains('CANONICAL SHELLBY SNAPSHOT'));
    expect(input, contains('income ₱ 2,000.00'));
    expect(input, contains('spending ₱ 500.00'));
    expect(input, contains('Food ₱ 500.00'));
    expect(input, contains('Campus market'));
    expect(input, contains('RECORDS RELEVANT TO THE LATEST QUESTION'));
    expect(input, isNot(contains('Cash in')));
    expect(input, isNot(contains('From: Savings')));
  });

  test('chat reply labels limited data without changing its answer', () {
    const reply = AiChatReply(
      answer: 'I need more labelled records to compare months.',
      basis: '0 labelled, non-transfer records through no dated records',
      dataStatus: AiChatDataStatus.missingData,
    );

    expect(reply.displayText, contains(reply.answer));
    expect(reply.displayText, contains('Based on:'));
    expect(reply.displayText, contains('Limited data'));
  });
}
