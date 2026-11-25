import 'dart:convert';

import 'package:cap1/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ProfileUser extends Fake implements User {
  _ProfileUser(this.uid);

  @override
  final String uid;

  @override
  String? get displayName => null;

  @override
  String? get email => null;

  @override
  String? get photoURL => null;
}

void main() {
  final monday = DateTime(2026, 8, 3, 12);

  void at(int day) {
    final target = DateTime(monday.year, monday.month, monday.day + day, 12);
    AppClock.offset.value = target.difference(DateTime.now());
  }

  ShelbyBadge habit(AppState state) =>
      computeBadges(state).singleWhere((badge) => badge.id == 'habit_builder');

  Future<void> log(AppState state, String id) => state.addManualCashTransaction(
        transactionId: id,
        title: 'Private grocery receipt',
        detail: 'Private account detail',
        amount: -25,
        // A backdated receipt still belongs to the week the user logged it.
        occurredAt: monday.subtract(const Duration(days: 35)),
        category: 'Food',
        source: 'Cash on Hand',
      );

  Future<void> label(AppState state, String id, {bool excluded = false}) =>
      state.labelFakeMayaTransaction(
        transactionId: id,
        category: 'Food',
        source: 'Cash on Hand',
        excludedFromInsights: excluded,
      );

  setUp(() => at(0));
  tearDown(() => AppClock.offset.value = Duration.zero);

  test('one deliberate logging week at a time earns Habit Builder', () async {
    final state = AppState()
      ..cashOnHandBalance = 500
      ..incomeType = 'Variable'
      ..income = 30000;

    expect(habit(state).progressLabel, '0 of 4 weeks');
    for (var week = 0; week < 4; week++) {
      at(week * 7);
      await log(state, 'receipt-$week');
      await log(state, 'second-receipt-$week');
      expect(habit(state).current, week + 1);
      expect(habit(state).earned, week == 3);
    }
    expect(habit(state).progressLabel, 'Earned');
  });

  test('logins, pre-existing records, and income estimates never qualify',
      () async {
    final state = AppState()
      ..seedCashFlowMockDataForTesting()
      ..onboardingComplete = false
      ..uid = null;
    expect(state.allTransactions, isNotEmpty);
    for (var week = 0; week < 5; week++) {
      at(week * 7);
      await state.recordAppOpen();
    }
    expect(habit(state).progress, 0);
    expect(habit(state).earned, isFalse);
  });

  test('an open week leaves time to act; a closed gap resets progress',
      () async {
    final state = AppState()..cashOnHandBalance = 500;
    await log(state, 'a');
    at(6);
    expect(habit(state).current, 1); // Sunday
    at(7);
    expect(habit(state).current, 1); // Monday, week still open
    at(14);
    expect(habit(state).current, 0);
    await log(state, 'b');
    expect(habit(state).current, 1);
  });

  test('duplicate submissions, relabeling, and corrections are handled',
      () async {
    final state = AppState()..cashOnHandBalance = 500;
    await log(state, 'first');
    at(7);
    await log(state, 'first');
    await label(state, 'first');
    expect(habit(state).current, 1);
    await log(state, 'second');
    expect(habit(state).current, 2);

    await label(state, 'first', excluded: true);
    expect(habit(state).current, 1);
    await label(state, 'first');
    expect(habit(state).current, 2);
    expect(await state.deleteManualTransaction('first'), isTrue);
    expect(habit(state).current, 1);
  });

  test('FakeMaya refreshes do not count; an explicit first label does',
      () async {
    final state = AppState()
      ..seedCashFlowMockDataForTesting()
      ..onboardingComplete = false
      ..uid = null;
    final link = state.fakeMayaLink!;
    final tx = FakeMayaTransaction(
      id: 'external-receipt',
      title: 'Merchant purchase',
      detail: 'Store',
      age: 'Today',
      amountText: '-25',
      createdAt: monday,
    );
    final session = FakeMayaSession(
      userId: link.userId,
      email: link.email,
      name: link.name,
      phone: link.phone,
      provider: link.provider,
      accessToken: '',
      refreshToken: '',
      expiresAt: monday,
      summary: link.summary.copyWith(transactions: [tx]),
    );
    state.applyLinkedFakeMayaSessionForTesting(session);
    expect(habit(state).current, 0);
    await label(state, tx.transactionId);
    expect(habit(state).current, 1);
    at(7);
    state.applyLinkedFakeMayaSessionForTesting(session);
    state.applyLinkedFakeMayaSessionForTesting(session);
    await label(state, tx.transactionId);
    expect(habit(state).current, 1);
    await label(state, tx.transactionId, excluded: true);
    expect(habit(state).current, 0);
  });

  test('profile round trip keeps progress and earnings isolated by account',
      () async {
    final alice = _ProfileUser('alice');
    final bob = _ProfileUser('bob');
    final state = AppState()
      ..cashOnHandBalance = 500
      ..seenBadgeIds.add('health_60');
    for (var week = 0; week < 3; week++) {
      at(week * 7);
      await log(state, 'receipt-$week');
    }
    final restarted = AppState()
      ..restoreProfileForTesting(state.profileSnapshotForTesting(alice));
    expect(habit(restarted).current, 3);

    final otherProfile = AppState().profileSnapshotForTesting(bob)
      ..remove('financialHabitEvents'); // legacy profile
    restarted.restoreProfileForTesting(otherProfile);
    expect(restarted.uid, 'bob');
    expect(habit(restarted).current, 0);
    expect(restarted.seenBadgeIds, isEmpty);

    restarted.restoreProfileForTesting(state.profileSnapshotForTesting(alice));
    restarted.onboardingComplete = false; // Tests use the profile codec only.
    at(21);
    await log(restarted, 'fourth');
    final score = computeHealthScore(restarted);
    expect(
      restarted.collectNewlyEarnedBadges().map((badge) => badge.id),
      ['habit_builder'],
    );
    expect(restarted.collectNewlyEarnedBadges(), isEmpty);
    expect(computeHealthScore(restarted).score, score.score);
    expect(computeHealthScore(restarted).actionPoints, score.actionPoints);
    expect(computeHealthScore(restarted).deductionTotal, score.deductionTotal);

    final earned = AppState()
      ..restoreProfileForTesting(restarted.profileSnapshotForTesting(alice));
    earned.onboardingComplete = false;
    await earned.deleteManualTransaction('fourth');
    at(140);
    expect(habit(earned).earned, isTrue);
    expect(earned.seenBadgeIds, contains('health_60'));
    expect(earned.collectNewlyEarnedBadges(), isEmpty);
  });

  test('badge sharing contains only the generic achievement', () async {
    final state = AppState()..cashOnHandBalance = 500;
    for (var week = 0; week < 4; week++) {
      at(week * 7);
      await log(state, 'private-id-$week');
    }
    final share = habit(state).toShareable().toMap();
    expect(share, {
      'kind': 'badge',
      'title': 'Habit Builder',
      'value': 'Badge unlocked',
      'detail': 'You kept track of your money for four weeks in a row.',
      'colorValue': isA<int>(),
      'iconKey': 'habit',
    });
    expect(jsonEncode(share), isNot(contains('Private')));
  });

  test('a verified four-week run survives a delayed first badge check',
      () async {
    final state = AppState()..cashOnHandBalance = 500;
    for (var week = 0; week < 4; week++) {
      at(week * 7);
      await log(state, 'late-check-$week');
    }
    at(70);
    expect(state.collectNewlyEarnedBadges().map((badge) => badge.id),
        ['habit_builder']);
    expect(habit(state).earned, isTrue);
  });

  testWidgets('Financial Habits shows locked, progress and sharing states',
      (tester) async {
    final state = AppState()..cashOnHandBalance = 500;
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: Scaffold(body: BadgesCard())),
    ));
    expect(find.text('Financial Habits'), findsOneWidget);
    expect(find.text('0 of 4 weeks'), findsOneWidget);
    await tester.tap(find.text('Habit Builder'));
    await tester.pumpAndSettle();
    expect(find.textContaining('log a transaction'), findsOneWidget);
    expect(find.text('Share it!'), findsNothing);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    for (var week = 0; week < 4; week++) {
      at(week * 7);
      await log(state, 'widget-$week');
      await tester.pumpAndSettle();
      if (week < 3) {
        expect(find.text('${week + 1} of 4 weeks'), findsOneWidget);
      }
    }
    await tester.tap(find.text('Habit Builder'));
    await tester.pumpAndSettle();
    expect(find.text('Share it!'), findsOneWidget);
    expect(find.textContaining('kept track of your money'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the fourth activity triggers one celebration in the main shell',
      (tester) async {
    final state = AppState()..cashOnHandBalance = 500;
    for (var week = 0; week < 3; week++) {
      at(week * 7);
      await log(state, 'celebration-$week');
    }
    at(21);
    tester.view.physicalSize = const Size(430, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: MainShell()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('BADGE UNLOCKED'), findsNothing);

    await log(state, 'celebration-fourth');
    await tester.pumpAndSettle();
    expect(find.text('BADGE UNLOCKED'), findsOneWidget);
    expect(find.text('Habit Builder'), findsOneWidget);
    expect(state.seenBadgeIds, contains('habit_builder'));

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await log(state, 'celebration-extra');
    await tester.pumpAndSettle();
    expect(find.text('BADGE UNLOCKED'), findsNothing);
  });
}
