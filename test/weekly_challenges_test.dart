import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

FakeMayaTransaction _transaction({
  required String id,
  required DateTime createdAt,
  String? category,
  String? source,
  DateTime? labeledAt,
}) =>
    FakeMayaTransaction(
      id: id,
      title: 'Test purchase',
      detail: 'Test merchant',
      age: 'today',
      amountText: '-₱100',
      createdAt: createdAt,
      category: category,
      source: source,
      labeledAt: labeledAt,
    );

void main() {
  test('weekly challenge recommends transaction labelling before judging goals',
      () {
    final state = AppState();
    final now = DateTime(2026, 11, 4);
    state.manualTransactions.addAll([
      _transaction(id: 'one', createdAt: now),
      _transaction(id: 'two', createdAt: now),
      _transaction(id: 'three', createdAt: now),
      _transaction(id: 'four', createdAt: now),
    ]);

    final challenge = state.recommendWeeklyChallenge(now: now);

    expect(challenge, isNotNull);
    expect(challenge!.kind, WeeklyChallengeKind.labelRecentTransactions);
    expect(challenge.target, 3);
    expect(challenge.title, 'Tidy your records');
    expect(challenge.reason, contains('Label 3 recent transactions'));
    expect(challenge.reason, isNot(contains('4 records')));
  });

  test('label challenge progress is based on records labelled during its week',
      () {
    final state = AppState();
    final start = DateTime(2026, 11, 3);
    final challenge = WeeklyChallenge(
      id: 'label-week',
      kind: WeeklyChallengeKind.labelRecentTransactions,
      title: 'Label 3 recent transactions',
      reason: 'More data is needed.',
      progressLabel: 'labelled records',
      target: 3,
      startedAt: start,
      endsAt: start.add(const Duration(days: 7)),
    );
    state.manualTransactions.addAll([
      _transaction(
        id: 'new-label',
        createdAt: start.subtract(const Duration(days: 20)),
        category: 'Food',
        source: 'Cash on Hand',
        labeledAt: start.add(const Duration(days: 1)),
      ),
      _transaction(
        id: 'old-label',
        createdAt: start.subtract(const Duration(days: 20)),
        category: 'Food',
        source: 'Cash on Hand',
        labeledAt: start.subtract(const Duration(days: 1)),
      ),
    ]);

    expect(state.weeklyChallengeProgress(challenge), 1);
    expect(state.weeklyChallengeIsComplete(challenge), isFalse);
  });

  test('accepted challenge persists its lifecycle fields and can be skipped',
      () async {
    final state = AppState();
    final challenge = WeeklyChallenge(
      id: 'challenge-1',
      kind: WeeklyChallengeKind.reviewRecurringPayment,
      title: 'Review a recurring payment',
      reason: 'A repeated payment needs review.',
      progressLabel: 'payment reviewed',
      target: 1,
      startedAt: DateTime(2026, 11, 3),
      endsAt: DateTime(2026, 11, 10),
      referenceKey: 'merchant|Monthly',
    );

    await state.acceptWeeklyChallenge(challenge);
    expect(state.activeWeeklyChallenge?.id, challenge.id);
    expect(state.weeklyChallenges.single.toMap()['status'], 'active');

    await state.skipWeeklyChallenge(challenge.id);
    expect(state.weeklyChallenges.single.status, WeeklyChallengeStatus.skipped);
  });

  test('saved legacy challenges load with the universal shareable template',
      () {
    final restored = WeeklyChallenge.fromMap({
      'id': 'legacy-internet',
      'kind': 'reviewRecurringPayment',
      'title': 'Review Internet',
      'reason': 'A monthly Internet bill needs review.',
      'progressLabel': 'payment reviewed',
      'target': 1,
      'startedAt': '2026-11-02T00:00:00.000',
      'endsAt': '2026-11-09T00:00:00.000',
      'referenceKey': 'out|internet|Monthly',
      'status': 'active',
    });

    expect(restored?.title, 'Review a recurring payment');
    expect(restored?.reason, isNot(contains('Internet')));
    expect(restored?.referenceKey, 'out|internet|Monthly');
  });

  test('completed challenges require current qualifying evidence', () async {
    final state = AppState();
    final now = AppClock.now();
    final challenge = WeeklyChallenge(
      id: 'complete-from-evidence',
      kind: WeeklyChallengeKind.labelRecentTransactions,
      title: 'Label one record',
      reason: 'Data quality first.',
      progressLabel: 'labelled records',
      target: 1,
      startedAt: now.subtract(const Duration(days: 1)),
      endsAt: now.add(const Duration(days: 1)),
    );
    state.manualTransactions.add(_transaction(
      id: 'qualifying-label',
      createdAt: now.subtract(const Duration(days: 5)),
      category: 'Food',
      source: 'Cash on Hand',
      labeledAt: now,
    ));
    state.weeklyChallenges.add(challenge);

    await state.completeWeeklyChallenge(challenge.id);

    expect(
        state.weeklyChallenges.single.status, WeeklyChallengeStatus.completed);
    final restored =
        WeeklyChallenge.fromMap(state.weeklyChallenges.single.toMap());
    expect(restored?.status, WeeklyChallengeStatus.completed);
    expect(restored?.id, challenge.id);
  });

  test('expired challenges cannot be completed or skipped later', () async {
    final state = AppState();
    final expired = WeeklyChallenge(
      id: 'expired',
      kind: WeeklyChallengeKind.reviewRecurringPayment,
      title: 'Old challenge',
      reason: 'Old.',
      progressLabel: 'payment reviewed',
      target: 1,
      startedAt: DateTime(2020, 1, 1),
      endsAt: DateTime(2020, 1, 8),
      referenceKey: 'handled',
    );
    state.weeklyChallenges.add(expired);
    state.handledRecurringTransactionSuggestionKeys.add('handled');

    await state.completeWeeklyChallenge(expired.id);
    await state.skipWeeklyChallenge(expired.id);

    expect(state.weeklyChallenges.single.status, WeeklyChallengeStatus.active);
    expect(state.weeklyChallenges.single.effectiveStatus(AppClock.now()),
        WeeklyChallengeStatus.expired);
  });

  testWidgets('Home presents and accepts a deterministic weekly challenge',
      (tester) async {
    final state = AppState();
    final now = DateTime(2026, 11, 4);
    state.manualTransactions.addAll([
      _transaction(id: 'one', createdAt: now),
      _transaction(id: 'two', createdAt: now),
      _transaction(id: 'three', createdAt: now),
    ]);
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: DashboardPage()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Recommended this week'), findsOneWidget);
    await tester.tap(find.text('Accept challenge'));
    await tester.pumpAndSettle();
    expect(state.activeWeeklyChallenge, isNotNull);
    expect(find.text('This week’s challenge'), findsOneWidget);
  });
}
