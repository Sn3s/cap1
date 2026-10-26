import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('benchmark aggregation uses only valid coarse contribution bands', () {
    final aggregate = BenchmarkAggregate.fromContributions(const [
      {
        'emergencyBand': 'under_one',
        'savingBand': 'none',
      },
      {
        'emergencyBand': 'one_to_three',
        'savingBand': 'some',
      },
      {
        'emergencyBand': 'three_plus',
        'savingBand': 'twenty_plus',
      },
      {
        'emergencyBand': 'not-a-band',
        'savingBand': 'some',
      },
    ]);

    expect(aggregate.eligibleCount, 3);
    expect(aggregate.emergencyBands, {
      'under_one': 1,
      'one_to_three': 1,
      'three_plus': 1,
    });
    expect(aggregate.savingBands, {
      'none': 1,
      'some': 1,
      'twenty_plus': 1,
    });
  });

  test('benchmark savings rate uses saved manual balances after relaunch', () {
    final state = AppState()
      ..setVariableIncomeBaseline(24000, notify: false)
      ..manualAccountBalances['Savings'] = 6000;

    expect(state.benchmarkSavingsRate, .25);
  });

  test('benchmark aggregation keeps optional standing bands anonymous', () {
    final aggregate = BenchmarkAggregate.fromContributions(const [
      {
        'emergencyBand': 'one_to_three',
        'savingBand': 'some',
        'cashflowBand': 'balanced',
        'goalBand': 'building',
        'pyramidBand': 'developing',
      },
      {
        'emergencyBand': 'three_plus',
        'savingBand': 'twenty_plus',
        'cashflowBand': 'stable',
        'goalBand': 'on_track',
        'pyramidBand': 'advancing',
      },
    ]);

    expect(aggregate.cashflowBands, {'balanced': 1, 'stable': 1});
    expect(aggregate.goalBands, {'building': 1, 'on_track': 1});
    expect(aggregate.pyramidBands, {'developing': 1, 'advancing': 1});
  });

  testWidgets('privacy settings expose all cooperative controls',
      (tester) async {
    final state = AppState()..uid = 'signed-in-user';
    await tester.pumpWidget(AppScope(
      state: state,
      child: const MaterialApp(home: CommunityPrivacyScreen()),
    ));

    expect(find.text('Anonymous peer benchmarks'), findsOneWidget);
    expect(find.text('Community feedback'), findsOneWidget);
    expect(find.text('Trusted circle sharing'), findsOneWidget);

    await tester.tap(find.text('Anonymous peer benchmarks'));
    await tester.pump();
    expect(state.consentBenchmarking, isTrue);

    await tester.tap(find.text('Trusted circle sharing'));
    await tester.pump();
    expect(state.consentTrustedCircle, isTrue);
  });
}
