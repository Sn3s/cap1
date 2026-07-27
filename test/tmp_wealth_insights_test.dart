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

  final output = Directory('/tmp/wealth-insights-verify');
  setUpAll(() {
    if (output.existsSync()) output.deleteSync(recursive: true);
    output.createSync(recursive: true);
  });

  testWidgets('accumulating wealth insights page renders', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1179, 6400);
    view.devicePixelRatio = 3;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final state = AppState()..seedReflectionDemoDataForTesting();
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('wealth'),
        child: AppScope(
          state: state,
          child: const MaterialApp(home: Scaffold(body: InsightsPage())),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Accumulating wealth'));
    // The metrics grid + portfolio card kick off network calls (CoinGecko) on
    // init; let those settle (or fail/timeout gracefully) before capturing.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await _capture(tester, 'wealth', output);
  });

  testWidgets('accumulating wealth drilldown popup', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1179, 2400);
    view.devicePixelRatio = 3;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final state = AppState()..seedReflectionDemoDataForTesting();
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('drilldown'),
        child: AppScope(
          state: state,
          child: const MaterialApp(home: Scaffold(body: InsightsPage())),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Accumulating wealth'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    // Tap somewhere in the middle of the chart area to trigger the
    // drill-down crosshair/tooltip.
    final chart = find.byType(CustomPaint).first;
    await tester.tapAt(tester.getCenter(chart));
    await tester.pump();
    await _capture(tester, 'drilldown', output);
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
