// TEMPORARY verification test - not part of the permanent suite.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final output = Directory('/tmp/uiux-verify2');
  setUpAll(() {
    if (output.existsSync()) output.deleteSync(recursive: true);
    output.createSync(recursive: true);
  });

  testWidgets('available cash action cards - no gauges on main card',
      (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1179, 4200);
    view.devicePixelRatio = 3;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final state = _reflectionState();
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('cards'),
        child: AppScope(
          state: state,
          child: MaterialApp(home: Scaffold(body: InsightsPage())),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Available cash'));
    await tester.pumpAndSettle();
    await _capture(tester, 'cards', output);
  });

  testWidgets('action full breakdown popup - not cropped', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1179, 2600);
    view.devicePixelRatio = 3;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final state = _reflectionState();
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('popup2'),
        child: AppScope(
          state: state,
          child: MaterialApp(home: Scaffold(body: InsightsPage())),
        ),
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
    await _capture(tester, 'popup2', output);
  });

  testWidgets('label transaction sheet alignment', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1179, 3200);
    view.devicePixelRatio = 3;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final state = _reflectionState();
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('label'),
        child: AppScope(
          state: state,
          child: const MaterialApp(home: RecentActivityPage()),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Emergency payment'));
    await tester.pumpAndSettle();
    await _capture(tester, 'label', output);
  });
}

Future<void> _capture(WidgetTester tester, String name, Directory output) async {
  final boundary =
      tester.renderObject<RenderRepaintBoundary>(find.byKey(ValueKey(name)));
  final image = await boundary.toImage(pixelRatio: 1);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  final bytes = byteData!.buffer.asUint8List();
  File('${output.path}/$name.png').writeAsBytesSync(bytes);
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
        goalBalance: 3450,
        goalTarget: 10000,
        creditLimit: 0,
        creditUsed: 0,
        transactions: transactions,
        updatedAt: start,
        personalGoals: [
          FakeMayaPersonalGoal.defaultForId('B1').copyWith(balance: 1500),
          FakeMayaPersonalGoal.defaultForId('B2').copyWith(balance: 11000),
          FakeMayaPersonalGoal.defaultForId('B3').copyWith(balance: 800),
          FakeMayaPersonalGoal.defaultForId('B4').copyWith(balance: 250),
        ],
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
