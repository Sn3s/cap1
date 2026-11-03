import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> withdrawal({
    required String id,
    required DateTime date,
    required double amount,
  }) =>
      {
        'type': 'use_emergency',
        'date': date.toIso8601String(),
        'withdrawalId': id,
        'amount': amount,
      };

  Map<String, dynamic> replenish({
    required DateTime date,
    required double amount,
    List<Map<String, dynamic>>? allocations,
  }) =>
      {
        'type': 'ef_replenish',
        'date': date.toIso8601String(),
        'amount': amount,
        if (allocations != null) 'allocations': allocations,
      };

  test('a replenishment only restores the withdrawal it allocates to', () {
    final state = AppState();
    final first = DateTime(2026, 1, 3);
    final second = DateTime(2026, 1, 5);
    state.d1Ledger.addAll([
      withdrawal(id: 'first', date: first, amount: 500),
      withdrawal(id: 'second', date: second, amount: 700),
      replenish(
        date: DateTime(2026, 1, 10),
        amount: 500,
        allocations: const [
          {'withdrawalId': 'first', 'amount': 500.0},
        ],
      ),
    ]);

    final records = state.emergencyReplenishmentRecords;
    expect(records[0].isFullyReplenished, isTrue);
    expect(records[1].outstandingAmount, 700);
    expect(state.pendingRecordedEmergencyReplenishment, 700);
  });

  test('partial A10 replenishments accumulate without exceeding withdrawal',
      () {
    final state = AppState();
    state.d1Ledger.addAll([
      withdrawal(id: 'clinic', date: DateTime(2026, 2, 1), amount: 800),
      replenish(
        date: DateTime(2026, 2, 4),
        amount: 300,
        allocations: const [
          {'withdrawalId': 'clinic', 'amount': 300.0},
        ],
      ),
      replenish(
        date: DateTime(2026, 2, 9),
        amount: 500,
        allocations: const [
          {'withdrawalId': 'clinic', 'amount': 500.0},
        ],
      ),
    ]);

    final record = state.emergencyReplenishmentRecords.single;
    expect(record.replenishedAmount, 800);
    expect(record.outstandingAmount, 0);
    expect(record.fullyReplenishedAt, DateTime(2026, 2, 9));
  });

  test('legacy replenishments are replayed once in oldest-first order', () {
    final state = AppState();
    state.d1Ledger.addAll([
      withdrawal(id: 'first', date: DateTime(2026, 3, 1), amount: 400),
      withdrawal(id: 'second', date: DateTime(2026, 3, 2), amount: 600),
      replenish(date: DateTime(2026, 3, 8), amount: 500),
    ]);

    final records = state.emergencyReplenishmentRecords;
    expect(records[0].outstandingAmount, 0);
    expect(records[1].outstandingAmount, 500);
    expect(state.pendingRecordedEmergencyReplenishment, 500);
  });

  test('A9 counts new Emergency Fund contributions, not A10 restorations', () {
    final state = AppState();
    final month = DateTime(2026, 4, 1);
    state.d1Ledger.addAll([
      {
        'type': 'emergency_deposit',
        'date': DateTime(2026, 4, 2).toIso8601String(),
        'amount': 300.0,
      },
      {
        'type': 'ef_replenish',
        'date': DateTime(2026, 4, 3).toIso8601String(),
        'amount': 700.0,
      },
    ]);

    expect(state.emergencyFundContributionsForMonth(month), 300);
  });
}
