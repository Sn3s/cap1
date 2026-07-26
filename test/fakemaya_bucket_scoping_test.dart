import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a fresh wallet row has zero buckets, not all 4', () {
    final summary = FakeMayaAccountSummary.fromMap({
      'wallet': 1000,
      'savings': 0,
      'time_deposit': 0,
      'goal_balance': 0,
      'app_state': {
        'wallet': 1000,
        'savings': 0,
        'timeDeposit': 0,
        'selectedGoalId': null,
        'personalGoals': [],
        'creditLimit': 15000,
        'creditUsed': 0,
        'transactions': [],
      },
    });

    expect(summary.personalGoals, isEmpty);
  });

  test(
      'an account with only the Emergency Fund bucket created shows just that one',
      () {
    final summary = FakeMayaAccountSummary.fromMap({
      'wallet': 1000,
      'savings': 0,
      'time_deposit': 0,
      'goal_balance': 0,
      'app_state': {
        'wallet': 1000,
        'savings': 0,
        'timeDeposit': 0,
        'selectedGoalId': 'B2',
        'personalGoals': [
          FakeMayaPersonalGoal.defaultForId('B2').toMap(),
        ],
        'creditLimit': 15000,
        'creditUsed': 0,
        'transactions': [],
      },
    });

    expect(summary.personalGoals, hasLength(1));
    expect(summary.personalGoals.single.id, 'B2');
    expect(summary.personalGoals.single.name, 'Emergency Fund');
  });

  test('a pre-migration row with only a legacy `goal` object migrates to '
      'exactly one Essential Expense Fund bucket, not all 4', () {
    final summary = FakeMayaAccountSummary.fromMap({
      'wallet': 1000,
      'savings': 0,
      'time_deposit': 0,
      'goal_balance': 500,
      'app_state': {
        'wallet': 1000,
        'savings': 0,
        'timeDeposit': 0,
        'goal': {
          'name': 'japan',
          'emoji': '👠',
          'balance': 500,
          'target': 25000,
        },
      },
    });

    expect(summary.personalGoals, hasLength(1));
    expect(summary.personalGoals.single.balance, 500);
  });

  test('depositing into a bucket id when none exist yet creates only that '
      'bucket', () {
    const summary = FakeMayaAccountSummary(
      wallet: 1000,
      savings: 0,
      timeDeposit: 0,
      goalName: 'Essential Expense Fund',
      goalEmoji: '🏠',
      goalBalance: 0,
      goalTarget: 25000,
      personalGoals: [],
      creditLimit: 15000,
      creditUsed: 0,
      transactions: [],
      updatedAt: null,
    );

    final goals = summary.personalGoalsWithDeposit('B3', 750);
    expect(goals, hasLength(1));
    expect(goals.single.id, 'B3');
    expect(goals.single.balance, 750);
  });
}
