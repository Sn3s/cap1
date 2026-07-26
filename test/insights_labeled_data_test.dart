import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('emergency payments stay out of basic-needs cash flow', () {
    final state = _reflectionState();
    final emergency = state.allTransactions.singleWhere(
      (transaction) => transaction.transactionId == 'clinic-emergency',
    );
    final integratedSpend = IntegrationService.fromState(state)
        .weekRecords
        .fold(0.0, (sum, week) => sum + week.weekExpense);
    final expectedBasicNeedsSpend = state.allTransactions
        .where((transaction) =>
            transaction.amount < 0 &&
            transaction.isLabeled &&
            transaction.source == 'Basic Needs Fund')
        .fold(0.0, (sum, transaction) => sum + transaction.amount.abs());

    expect(emergency.category, 'Health');
    expect(emergency.source, 'Emergency Fund');
    expect(integratedSpend, expectedBasicNeedsSpend);
  });

  testWidgets('overview summarizes flow, categories, funds, and activity',
      (tester) async {
    final now = DateTime.now();
    final transactions = [
      _tx('income-1', 'Allowance', 'Income', 6000,
          now.subtract(const Duration(days: 4))),
      _tx('food-1', 'Paid merchant', 'Food & drink', -420,
          now.subtract(const Duration(days: 3))),
      _tx('ride-1', 'Sent money', 'Transport', -260,
          now.subtract(const Duration(days: 1))),
    ];
    final state = AppState()
      ..fakeMayaSyncedAccounts.add('Wallet')
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
          wallet: 0,
          savings: 0,
          timeDeposit: 0,
          goalName: '',
          goalEmoji: '',
          goalBalance: 0,
          goalTarget: 0,
          creditLimit: 0,
          creditUsed: 0,
          transactions: transactions,
          updatedAt: now,
        ),
      );

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: Scaffold(body: InsightsPage())),
      ),
    );
    await tester.pump();

    expect(find.text('Money Summary'), findsOneWidget);
    expect(find.text('Where Your Money Went'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Which Funds You Used'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Which Funds You Used'), findsOneWidget);
    expect(find.text('Basic Needs Fund'), findsWidgets);
    expect(find.text('14-Day Financial Pattern'), findsOneWidget);
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
    expect(find.text('Emergency fund'), findsNothing);
    expect(find.text('Accumulating wealth'), findsNothing);
    expect(find.text('Financial freedom'), findsNothing);
    await tester.tap(find.text('Available cash'));
    await tester.pumpAndSettle();
    expect(find.text('Can this month’s available cash cover bills?'),
        findsOneWidget);
    expect(find.text('Bill readiness'), findsOneWidget);
    expect(find.text('MONTH · ACTION PROGRESS'), findsOneWidget);
    expect(find.textContaining('Set aside X% of each income received'),
        findsOneWidget);
    expect(find.textContaining('Limit spending in selected categories'),
        findsOneWidget);
    expect(find.textContaining('Cap discretionary spending'), findsNothing);
    expect(
        find.textContaining('Keep Everyday Fund days covered'), findsNothing);
    expect(find.textContaining('Bring in at least'), findsOneWidget);
    expect(find.textContaining('Keep at least'), findsOneWidget);
    expect(find.text('ACTION STAGE · LATEST 14 DAYS'), findsOneWidget);
    expect(find.text('This is where you earn money'), findsNothing);
    expect(find.text('This is where you spend money'), findsNothing);
    expect(find.text('Weekly cash flow'), findsNothing);
    expect(find.text('AI Analyze'), findsNothing);
  });

  testWidgets('available cash action resiliency opens score detail',
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

    final actionRow =
        find.textContaining('Set aside X% of each income received');
    await tester.ensureVisible(actionRow);
    await tester.pumpAndSettle();
    await tester.tap(actionRow);
    await tester.pumpAndSettle();

    expect(find.text('Set aside income for essentials resiliency'),
        findsOneWidget);
    expect(find.text('Data behind the score'), findsOneWidget);
    expect(find.text('Percentage rate per week'), findsOneWidget);
    expect(find.textContaining(RegExp(r'(Jan|Feb) \d+-(Jan|Feb) \d+')),
        findsWidgets);
  });

  testWidgets('emergency fund pairs movement overview with weekly detail',
      (tester) async {
    final state = _reflectionState()
      ..addedGoalIds.add('G3')
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

    expect(find.text('Emergency Fund'), findsOneWidget);
    expect(find.text('Build a safety net'), findsOneWidget);
    expect(find.textContaining('mo. covered'), findsOneWidget);
    expect(find.text('Current Fund'), findsOneWidget);
    expect(find.text('COVERAGE MILESTONES'), findsOneWidget);
    expect(find.text('3-Month Fund'), findsOneWidget);
    expect(find.text('6-Month Fund'), findsOneWidget);
    expect(find.text('Emergency fund movement'), findsOneWidget);
    expect(find.text('OVERVIEW · WEEKLY'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('DETAIL · SELECTED WEEK'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('DETAIL · SELECTED WEEK'), findsOneWidget);
    expect(find.textContaining('data coverage'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('ACTION STAGE · LATEST 14 DAYS'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('ACTION STAGE · LATEST 14 DAYS'), findsOneWidget);
  });

  testWidgets('tapping a month chip switches the available cash answer',
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

    expect(find.text('January 2026'), findsOneWidget);
    expect(find.text('February 2026'), findsOneWidget);
    expect(find.textContaining('February 2026 ·'), findsOneWidget);

    await tester.tap(find.text('January 2026'));
    await tester.pumpAndSettle();

    expect(find.textContaining('January 2026 ·'), findsOneWidget);
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
    ..bufferBalance = 2400
    // These include overlapping action ids, but Insights tabs should follow
    // the chosen/added goals rather than action overlap.
    ..selectedActionIds.addAll(
      ['A1', 'A3', 'A20', 'A19', 'A9', 'A8', 'A22', 'A10'],
    );
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
      sentence: week == 4 ? 'Higher utility bill' : 'Bill paid',
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
  final emergencyDate = start.add(const Duration(days: 32));
  transactions.add(_tx(
    'clinic-emergency',
    'Emergency payment',
    'Health',
    -1000,
    emergencyDate,
    source: 'Emergency Fund',
  ));
  state
    ..emergencyFundBalance = 11000
    ..d1Ledger.addAll([
      {
        'type': 'use_emergency',
        'date': emergencyDate.toIso8601String(),
        'amount': 1000,
        'label': 'Clinic visit',
        'sourceTransactionId': 'clinic-emergency',
      },
      {
        'type': 'emergency_deposit',
        'date': start.subtract(const Duration(days: 14)).toIso8601String(),
        'amount': 12000,
        'label': 'Opening emergency balance',
      },
    ]);
  state
    ..needsBalance = needs
    ..bufferBalance = buffer
    ..fakeMayaSyncedAccounts.add('Wallet')
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
  DateTime date, {
  String source = 'Basic Needs Fund',
}) {
  return FakeMayaTransaction(
    id: id,
    title: title,
    detail: 'To: Merchant',
    age: 'Seeded',
    amountText: '${amount < 0 ? '-' : '+'} ₱${amount.abs().toStringAsFixed(2)}',
    createdAt: date,
    category: category,
    source: category == null ? null : source,
  );
}
