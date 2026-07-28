// TEMPORARY verification test - not part of the permanent suite.
import 'dart:async';
import 'dart:convert';
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

  final output = Directory('/tmp/freedom-insights-verify');
  setUpAll(() {
    if (output.existsSync()) output.deleteSync(recursive: true);
    output.createSync(recursive: true);
  });

  testWidgets('financial freedom insights page renders', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1179, 6800);
    view.devicePixelRatio = 3;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    await HttpOverrides.runZoned(() async {
      final state = AppState()..seedReflectionDemoDataForTesting();
      await tester.pumpWidget(
        RepaintBoundary(
          key: const ValueKey('freedom'),
          child: AppScope(
            state: state,
            child: const MaterialApp(home: Scaffold(body: InsightsPage())),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Financial freedom'));
      await tester.pumpAndSettle();
      await _capture(tester, 'freedom', output);
    }, createHttpClient: (_) => _FakeHttpClient());
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

class _FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _FakeHttpClientRequest(url);

  @override
  Future<HttpClientRequest> postUrl(Uri url) async =>
      _FakeHttpClientRequest(url);

  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  bool autoUncompress = true;
  @override
  String? userAgent;

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not faked');
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(this.uri);
  final Uri uri;

  @override
  Future<HttpClientResponse> close() async {
    // Force the AI coach's Gemini call to fail fast (not with a
    // SocketException/TimeoutException, so it doesn't trigger the heavy
    // local-model Isolate fallback) so this pure layout-verification test
    // doesn't hang on real model inference.
    return _FakeHttpClientResponse(
      utf8.encode(jsonEncode({'error': 'not available in test'})),
      statusCode: 404,
    );
  }

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  void write(Object? object) {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not faked');
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _FakeHttpClientResponse(this._bytes, {required this.statusCode});
  final List<int> _bytes;

  @override
  final int statusCode;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not faked');
}
