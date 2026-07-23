import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lifestyle ledger totals only include the current month', () {
    final state = AppState();
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1, 15);
    state.d1Ledger.addAll([
      {
        'type': 'lifestyle_subscription_reserve',
        'date': now.toIso8601String(),
        'amount': 1500.0,
      },
      {
        'type': 'lifestyle_payday',
        'date': now.toIso8601String(),
        'amount': 1000.0,
        'sourceTransactionId': 'income-1',
      },
      {
        'type': 'lifestyle_subscription_reserve',
        'date': previousMonth.toIso8601String(),
        'amount': 900.0,
      },
    ]);

    expect(state.lifestyleReservedThisMonth, 1500);
    expect(state.lifestylePaydayContributionsThisMonth, 1000);
    expect(state.hasLifestylePaydayAllocation('income-1'), isTrue);
    expect(state.hasLifestylePaydayAllocation('income-2'), isFalse);
  });

  test('activity target starts from the first recorded contribution', () {
    final state = AppState();
    final first = DateTime(2026, 7, 2);
    final second = DateTime(2026, 7, 20);
    state.d1Ledger.addAll([
      {
        'type': 'lifestyle_activity_deposit',
        'date': second.toIso8601String(),
        'amount': 1000.0,
      },
      {
        'type': 'lifestyle_activity_deposit',
        'date': first.toIso8601String(),
        'amount': 500.0,
      },
    ]);

    expect(state.lifestyleActivityStartedAt, first);
  });

  testWidgets('Lifestyle Fund goal shows its configured actions',
      (tester) async {
    final state = AppState()
      ..selectedGoalId = 'G8'
      ..selectedActionIds.addAll(['A26', 'A27', 'A28', 'A29'])
      ..actionFieldValues.addAll({
        'A26': {'amt': '1500'},
        'A27': {'amt': '1000'},
        'A28': {'amt': '1200'},
        'A29': {'amt': '10000', 'months': '6'},
      });

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: GoalsPage())),
      ),
    );
    await tester.drag(
      find.byType(ListView).first,
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Lifestyle Fund'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lifestyle Fund'));
    await tester.pumpAndSettle();

    expect(find.text('Lifestyle Fund'), findsOneWidget);
    expect(find.textContaining('subscriptions and memberships'), findsWidgets);
    expect(find.textContaining('Everyday Enjoyment Fund'), findsWidgets);
  });
}
