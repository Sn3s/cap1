import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // saveProfile() is a no-op before onboarding completes, which keeps these
  // tests off Firebase while still exercising the FakeMaya bucket writes.
  AppState seeded() => AppState()
    ..seedFinancialFreedomMockDataForTesting()
    ..onboardingComplete = false;

  FakeMayaPersonalGoal lifestyleFund(AppState state) =>
      state.fakeMayaLink!.summary.personalLifestyleFund!;

  test('Lifestyle Fund available is exactly the FakeMaya B4 balance', () {
    final state = seeded();
    expect(state.lifestyleFundBalance, lifestyleFund(state).balance);
  });

  test('spending from the bucket in FakeMaya lowers it in Shellby', () {
    final state = seeded();
    final before = state.lifestyleFundBalance;
    final link = state.fakeMayaLink!;
    state.fakeMayaLink = FakeMayaLink(
      userId: link.userId,
      email: link.email,
      name: link.name,
      phone: link.phone,
      provider: link.provider,
      accessToken: link.accessToken,
      refreshToken: link.refreshToken,
      expiresAt: link.expiresAt,
      summary: link.summary.copyWith(
        personalGoals: link.summary.personalGoalsWithWithdrawal(
          FakeMayaPersonalGoal.personalLifestyleFundId,
          300,
        ),
      ),
    );
    expect(state.lifestyleFundBalance, before - 300);
  });

  test('A27 allocates the configured % of an income, once', () async {
    final state = seeded();
    state.actionFieldValues['A27'] = {'pct': '10'};
    final before = lifestyleFund(state).balance;
    final walletBefore = state.fakeMayaLink!.summary.wallet;

    await state.depositLifestylePayday(
      transactionId: 'test-income-a27',
      incomeAmount: 20000,
      incomeDate: DateTime.now(),
    );
    await state.depositLifestylePayday(
      transactionId: 'test-income-a27',
      incomeAmount: 20000,
      incomeDate: DateTime.now(),
    );

    expect(lifestyleFund(state).balance, before + 2000);
    expect(state.lifestyleFundBalance, before + 2000);
    expect(state.fakeMayaLink!.summary.wallet, walletBefore - 2000);
    expect(state.hasLifestylePaydayAllocation('test-income-a27'), isTrue);
  });

  test('Reset Account zeroes balances and history but keeps onboarding',
      () async {
    final state = seeded();
    final actions = {...state.selectedActionIds};
    final settings = {...state.actionFieldValues};
    final concern = state.primaryConcern;

    await state.resetAccountData();

    final summary = state.fakeMayaLink!.summary;
    expect(summary.wallet, 0);
    expect(summary.savings, 0);
    expect(summary.transactions, isEmpty);
    expect(summary.investmentHoldings, isEmpty);
    expect(summary.personalGoals.every((goal) => goal.balance == 0), isTrue);
    expect(summary.personalLifestyleFund, isNotNull); // bucket kept at ₱0
    expect(state.lifestyleFundBalance, 0);
    expect(state.investmentBalance, 0);
    expect(state.d1Ledger, isEmpty);
    expect(state.allTransactions, isEmpty);
    expect(
        state.lifestyleHobbies
            .every((h) => state.lifestyleHobbyBalance(h['id'].toString()) == 0),
        isTrue);
    expect(state.selectedActionIds, actions);
    expect(state.actionFieldValues, settings);
    expect(state.primaryConcern, concern);
  });

  group('A29 sub-buckets', () {
    void setSummary(AppState state, FakeMayaAccountSummary summary) {
      final link = state.fakeMayaLink!;
      state.fakeMayaLink = FakeMayaLink(
        userId: link.userId,
        email: link.email,
        name: link.name,
        phone: link.phone,
        provider: link.provider,
        accessToken: link.accessToken,
        refreshToken: link.refreshToken,
        expiresAt: link.expiresAt,
        summary: summary,
      );
    }

    // Lifestyle Fund ₱10,000 with empty "Japan Trip" and "Shopping".
    AppState scenario() {
      final state = seeded();
      state.lifestyleHobbies
        ..clear()
        ..addAll([
          {
            'id': 'japan',
            'name': 'Japan Trip',
            'target': 60000.0,
            'months': 6,
            'createdAt': DateTime.now().toIso8601String(),
          },
          {
            'id': 'shopping',
            'name': 'Shopping',
            'target': 8000.0,
            'months': 3,
            'createdAt': DateTime.now().toIso8601String(),
          },
        ]);
      final fund = state.fakeMayaLink!.summary.personalLifestyleFund!;
      setSummary(
        state,
        state.fakeMayaLink!.summary.copyWith(personalGoals: [
          for (final goal in state.fakeMayaLink!.summary.personalGoals)
            goal.id == fund.id
                ? goal.copyWith(balance: 10000, subBuckets: const [])
                : goal,
        ]),
      );
      return state;
    }

    test('hobbies get ₱0 sub-buckets with their target and deadline', () async {
      final state = scenario();
      expect(state.lifestyleHobbiesNeedingSubBuckets.length, 2);

      await state.createLifestyleSubBuckets();

      expect(state.lifestyleHobbiesNeedingSubBuckets, isEmpty);
      final japan = state.lifestyleSubBucketFor('japan')!;
      expect(japan.name, 'Japan Trip');
      expect(japan.balance, 0);
      expect(japan.target, 60000);
      expect(japan.deadline,
          state.lifestyleHobbyDeadline(state.lifestyleHobbies.first));
      expect(state.lifestyleFundBalance, 10000); // fund untouched
    });

    test('scenario: transfer ₱5,000 from the fund to Japan Trip', () async {
      final state = scenario();
      await state.createLifestyleSubBuckets();
      final walletBefore = state.fakeMayaLink!.summary.wallet;

      await state.transferToLifestyleHobby(hobbyId: 'japan', amount: 5000);

      expect(state.lifestyleFundBalance, 5000);
      expect(lifestyleFund(state).balance, 5000);
      expect(state.lifestyleSubBucketFor('japan')!.balance, 5000);
      expect(state.lifestyleHobbyBalance('japan'), 5000);
      expect(state.lifestyleSubBucketFor('shopping')!.balance, 0);
      expect(state.lifestyleHobbyBalance('shopping'), 0);
      expect(state.fakeMayaLink!.summary.wallet, walletBefore);
    });

    test('cannot transfer more than the Lifestyle Fund holds', () async {
      final state = scenario();
      await state.createLifestyleSubBuckets();
      expect(
        () => state.transferToLifestyleHobby(hobbyId: 'japan', amount: 10001),
        throwsA(isA<FakeMayaException>()),
      );
      expect(state.lifestyleFundBalance, 10000);
    });

    test('removing a hobby returns its sub-bucket money to the fund', () async {
      final state = scenario();
      await state.createLifestyleSubBuckets();
      await state.transferToLifestyleHobby(hobbyId: 'japan', amount: 5000);

      await state.removeLifestyleHobby('japan');

      expect(state.lifestyleSubBucketFor('japan'), isNull);
      expect(state.lifestyleFundBalance, 10000);
    });

    test('sub-buckets survive a save/load of the FakeMaya data', () async {
      final state = scenario();
      await state.createLifestyleSubBuckets();
      await state.transferToLifestyleHobby(hobbyId: 'japan', amount: 5000);
      final summary = state.fakeMayaLink!.summary;

      final reloaded = FakeMayaAccountSummary.fromMap({
        'wallet': summary.wallet,
        'savings': summary.savings,
        'time_deposit': summary.timeDeposit,
        'goal_balance': summary.goalBalance,
        'app_state': summary.toFakeMayaAppState(),
      });

      final japan = reloaded.personalLifestyleFund!.subBucketById('japan')!;
      expect(japan.balance, 5000);
      expect(japan.target, 60000);
      expect(japan.deadline, isNotNull);
      expect(reloaded.personalLifestyleFund!.balance, 5000);
    });

    test('Freedom demo hobbies are funded from the fund', () {
      final state = seeded();
      expect(state.lifestyleHobbiesNeedingSubBuckets, isEmpty);
      expect(state.lifestyleFundBalance, greaterThan(0));
      for (final hobby in state.lifestyleHobbies) {
        final id = hobby['id'].toString();
        expect(state.lifestyleHobbyBalance(id),
            state.lifestyleSubBucketFor(id)!.balance);
      }
    });
  });

  group('Insights: total vs available, monthly set aside', () {
    void addTransaction(AppState state, FakeMayaTransaction tx) {
      final link = state.fakeMayaLink!;
      state.fakeMayaLink = FakeMayaLink(
        userId: link.userId,
        email: link.email,
        name: link.name,
        phone: link.phone,
        provider: link.provider,
        accessToken: link.accessToken,
        refreshToken: link.refreshToken,
        expiresAt: link.expiresAt,
        summary: link.summary
            .copyWith(transactions: [tx, ...link.summary.transactions]),
      );
    }

    test('Total Lifestyle Fund = available + earmarked sub-buckets', () {
      final state = seeded();
      final subs = lifestyleFund(state).subBuckets;
      final earmarked = subs.fold<double>(0, (t, sub) => t + sub.balance);
      expect(earmarked, greaterThan(0));
      expect(state.lifestyleEarmarkedBalance, earmarked);
      expect(state.lifestyleFundTotal, state.lifestyleFundBalance + earmarked);
    });

    test('set aside counts A26 + a direct FakeMaya deposit (5,000 + 500)',
        () async {
      final state = seeded();
      final month = DateTime(DateTime.now().year, DateTime.now().month);
      final before = state.lifestyleFundInflowsForMonth(month);

      await state.depositLifestyleSubscriptionReserve(5000); // A26
      addTransaction(
        state,
        FakeMayaTransaction(
          title: 'Deposited to goal', // FakeMaya's own Deposit button
          detail: 'Personal Lifestyle Fund',
          age: 'Just now',
          amountText: '+ ₱500.00',
          createdAt: DateTime.now(),
        ),
      );

      expect(state.lifestyleFundInflowsForMonth(month), before + 5500);
    });

    test('transfers into hobby sub-buckets do not count as set aside',
        () async {
      final state = seeded();
      final month = DateTime(DateTime.now().year, DateTime.now().month);
      final before = state.lifestyleFundInflowsForMonth(month);
      final hobbyId = state.lifestyleHobbies.first['id'].toString();

      await state.transferToLifestyleHobby(hobbyId: hobbyId, amount: 500);

      expect(state.lifestyleFundInflowsForMonth(month), before);
      expect(state.lifestyleFundTotal, isNot(state.lifestyleFundBalance));
    });
  });
}
