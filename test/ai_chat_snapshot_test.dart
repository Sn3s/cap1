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

  test('transaction-count questions use total history, not analytics rows', () {
    final now = AppClock.now();
    final state = AppState()
      ..manualTransactions.addAll([
        FakeMayaTransaction(
          id: 'food',
          title: 'Campus market',
          detail: 'Groceries',
          age: 'Just now',
          amountText: '-₱500',
          createdAt: now,
          category: 'Food',
          source: 'Cash on Hand',
        ),
        FakeMayaTransaction(
          id: 'pay',
          title: 'Freelance payment',
          detail: 'Project payment',
          age: 'Just now',
          amountText: '₱2,000',
          createdAt: now.subtract(const Duration(hours: 1)),
          category: 'Income',
          source: 'Wallet',
        ),
        FakeMayaTransaction(
          id: 'unlabelled',
          title: 'Merchant pending',
          detail: 'Needs classification',
          age: 'Just now',
          amountText: '-₱120',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        FakeMayaTransaction(
          id: 'transfer',
          title: 'Fund transfer',
          detail: 'To: Savings',
          age: 'Just now',
          amountText: '-₱300',
          createdAt: now.subtract(const Duration(hours: 3)),
          category: 'Transfer',
          source: 'Wallet',
        ),
      ]);
    const coach = ShellbyAiCoach();
    const question = [ChatMessage(true, 'How many transactions have I had?')];

    final input = coach.chatInputForTesting(state, question);
    final reply = coach.transactionCountReplyForTesting(state, question);

    expect(input, contains('Total recorded transaction rows: 4'));
    expect(input, contains('Internal transfers/fund allocations: 1'));
    expect(input,
        contains('External dated records available for financial analysis: 3'));
    expect(reply, isNotNull);
    expect(reply!.answer, contains('4 transactions'));
    expect(reply.answer, contains('1 is internal'));
    expect(reply.answer, contains('3 external dated records'));
    expect(reply.basis, startsWith('4 recorded transactions'));
    expect(reply.dataStatus, AiChatDataStatus.enoughData);
  });

  test('a correction after a count answer remains bound to total history', () {
    final now = AppClock.now();
    final state = AppState()
      ..manualTransactions.addAll([
        FakeMayaTransaction(
          id: 'labelled',
          title: 'Salary',
          detail: 'Payday',
          age: 'Just now',
          amountText: '₱1,000',
          createdAt: now,
          category: 'Income',
          source: 'Wallet',
        ),
        FakeMayaTransaction(
          id: 'transfer',
          title: 'Fund transfer',
          detail: 'To: Savings',
          age: 'Just now',
          amountText: '-₱100',
          createdAt: now.subtract(const Duration(hours: 1)),
          category: 'Transfer',
          source: 'Wallet',
        ),
      ]);
    const coach = ShellbyAiCoach();

    final reply = coach.transactionCountReplyForTesting(state, const [
      ChatMessage(true, 'How many transactions have I had?'),
      ChatMessage(false, 'You have recorded 1 total transaction.'),
      ChatMessage(true, 'Not 2?'),
    ]);

    expect(reply, isNotNull);
    expect(reply!.answer, startsWith('You have recorded 2 transactions'));
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

  test('chat data status is deterministic when records need labels', () {
    final now = AppClock.now();
    final state = AppState()
      ..manualTransactions.add(
        FakeMayaTransaction(
          id: 'unlabelled-grocery',
          title: 'Market purchase',
          detail: 'Receipt pending',
          age: 'Just now',
          amountText: '-₱250',
          createdAt: now,
        ),
      );
    const coach = ShellbyAiCoach();
    const conversation = [ChatMessage(true, 'How is my spending?')];

    expect(
      coach.chatDataStatusForTesting(state, conversation),
      AiChatDataStatus.missingData,
    );

    state.manualTransactions.add(
      FakeMayaTransaction(
        id: 'labelled-grocery',
        title: 'Market purchase',
        detail: 'Groceries',
        age: 'Just now',
        amountText: '-₱500',
        createdAt: now,
        category: 'Food',
        source: 'Cash on Hand',
      ),
    );
    expect(
      coach.chatDataStatusForTesting(state, conversation),
      AiChatDataStatus.partialData,
    );
  });

  test('chat context retains the newest messages in a long conversation', () {
    final messages = [
      for (var index = 0; index < 20; index++)
        ChatMessage(true, 'Question $index'),
    ];
    const coach = ShellbyAiCoach();
    final input = coach.chatInputForTesting(AppState(), messages);

    expect(input, contains('User: Question 19'));
    expect(input, isNot(contains('User: Question 0')));
  });
}
