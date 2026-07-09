import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('overview summarizes flow, categories, funds, and activity',
      (tester) async {
    final state = _reflectionState();

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: InsightsPage())),
      ),
    );
    await tester.pump();

    expect(find.text('Money summary'), findsOneWidget);
    expect(find.text('Where money was spent'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Which funds handled the most money'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Which funds handled the most money'), findsOneWidget);
    expect(find.text('Basic Needs Fund'), findsWidgets);
    expect(find.text('AI Analyze'), findsOneWidget);
  });

  testWidgets('available cash pairs weekly overview with selected-week detail',
      (tester) async {
    final state = _reflectionState();

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: InsightsPage())),
      ),
    );
    await tester.pump();

    expect(find.text('Goal Insights'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Available cash'), findsOneWidget);
    expect(find.text('Emergency fund'), findsOneWidget);
    await tester.tap(find.text('Available cash'));
    await tester.pumpAndSettle();
    expect(find.text('Basic-needs spending'), findsOneWidget);
    expect(find.text('AI Analyze'), findsOneWidget);
    expect(find.text('OVERVIEW · WEEKLY'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('DETAIL · SELECTED WEEK'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('DETAIL · SELECTED WEEK'), findsOneWidget);
    expect(find.textContaining('days complete'), findsOneWidget);
  });

  testWidgets('emergency fund pairs movement overview with weekly detail',
      (tester) async {
    final state = _reflectionState()
      ..emergencyFundBalance = 12000
      ..expenses = 6000;

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: InsightsPage())),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Emergency fund'));
    await tester.pumpAndSettle();

    expect(find.text('Emergency fund movement'), findsOneWidget);
    expect(find.text('OVERVIEW · WEEKLY'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('DETAIL · SELECTED WEEK'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('DETAIL · SELECTED WEEK'), findsOneWidget);
    expect(find.textContaining('data coverage'), findsOneWidget);
  });

  testWidgets('tapping an overview week filters the detail panel',
      (tester) async {
    final state = _reflectionState();

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: InsightsPage())),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Available cash'));
    await tester.pumpAndSettle();

    final firstWeek = find.bySemanticsLabel(RegExp(r'Week of Jan 5,'));
    expect(firstWeek, findsOneWidget);
    await tester.tap(firstWeek);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Jan 5–Jan 11'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Jan 5–Jan 11'), findsOneWidget);
    expect(find.textContaining('Food & drink'), findsWidgets);
  });
}

AppState _reflectionState() {
  final start = DateTime(2026, 1, 5);
  final state = AppState()
    ..selectedGoal = 'Irregular Income Buffer'
    ..selectedGoalId = 'GOAL1C'
    ..needsTarget = 9000
    ..needsPercent = 70
    ..needsBalance = 7800
    ..bufferBalance = 2400;
  var needs = 3200.0;
  var buffer = 900.0;
  final transactions = <FakeMayaTransaction>[];
  for (var week = 0; week < 7; week++) {
    final base = start.add(Duration(days: week * 7));
    final income = week.isEven ? 6000.0 : 4200.0;
    final toNeeds = (income * .70).clamp(0.0, state.needsTarget - needs);
    final toBuffer = income - toNeeds;
    needs += toNeeds;
    buffer += toBuffer;
    state.jarLedger.add(JarEvent(
      timestamp: base,
      type: JarEventType.income,
      needsIn: toNeeds,
      needsOut: 0,
      bufferIn: toBuffer,
      bufferOut: 0,
      sentence: 'Income split',
    ));
    final bill = week == 4 ? 5200.0 : 1800.0;
    final needsOut = bill.clamp(0.0, needs);
    final bufferOut = (bill - needsOut).clamp(0.0, buffer);
    needs -= needsOut;
    buffer -= bufferOut;
    state.jarLedger.add(JarEvent(
      timestamp: base.add(const Duration(days: 4)),
      type: JarEventType.billPaid,
      needsIn: 0,
      needsOut: needsOut,
      bufferIn: 0,
      bufferOut: bufferOut,
      sentence: week == 4 ? 'Emergency shortfall bill' : 'Bill paid',
    ));
    transactions.addAll([
      _tx('food-$week', 'Paid merchant', 'Food & drink', -420,
          base.add(const Duration(days: 1))),
      _tx('ride-$week', 'Sent money', 'Transport', -260,
          base.add(const Duration(days: 5))),
    ]);
  }
  transactions.add(_tx(
    'unclassified',
    'Paid merchant',
    null,
    -350,
    start.add(const Duration(days: 17)),
  ));
  state
    ..needsBalance = needs
    ..bufferBalance = buffer
    ..fakeMayaLink = FakeMayaLink(
      userId: 'user',
      email: 'user@example.com',
      name: 'User',
      phone: '',
      provider: 'email',
      accessToken: '',
      refreshToken: '',
      expiresAt: null,
      summary: FakeMayaAccountSummary(
        wallet: needs,
        savings: buffer,
        timeDeposit: 0,
        goalName: 'Available Cash',
        goalEmoji: '',
        goalBalance: 0,
        goalTarget: 10000,
        creditLimit: 0,
        creditUsed: 0,
        transactions: transactions,
        updatedAt: start,
      ),
    );
  return state;
}

FakeMayaTransaction _tx(
  String id,
  String title,
  String? category,
  double amount,
  DateTime date,
) {
  return FakeMayaTransaction(
    id: id,
    title: title,
    detail: 'To: Merchant',
    age: 'Seeded',
    amountText: '${amount < 0 ? '-' : '+'} ₱${amount.abs().toStringAsFixed(2)}',
    createdAt: date,
    category: category,
    source: category == null ? null : 'Basic Needs Fund',
  );
}
