import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Recent Activity loads another page after reaching the bottom',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final now = AppClock.now();
    final state = AppState()
      ..manualTransactions.addAll([
        for (var index = 0; index < 25; index++)
          FakeMayaTransaction(
            id: 'pagination-$index',
            title: 'Page transaction $index',
            detail: 'Test merchant',
            age: 'Seeded',
            amountText: '- ₱100.00',
            createdAt: now.subtract(Duration(minutes: index)),
            category: 'Food & drink',
            source: 'Cash on Hand',
          ),
      ]);

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: RecentActivityPage()),
      ),
    );

    expect(find.text('Page transaction 0'), findsOneWidget);
    expect(find.text('Page transaction 10'), findsNothing);
    expect(
      find.text('Scroll down or load older transactions'),
      findsOneWidget,
    );
    expect(find.text('Load 10 more'), findsOneWidget);

    await tester.tap(find.text('Load 10 more'));
    await tester.pump();

    expect(find.text('Page transaction 10'), findsOneWidget);
    expect(find.text('Page transaction 20'), findsNothing);

    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, -1600),
      1800,
    );
    await tester.pumpAndSettle();

    expect(find.text('Page transaction 20'), findsOneWidget);
  });
}
