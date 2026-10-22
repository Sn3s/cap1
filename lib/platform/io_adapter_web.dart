import 'dart:async';
import 'dart:convert';

import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

/// Web implementations for the small `dart:io` surface used by optional
/// native integrations. HTTP maps to browser Fetch/XHR, so browser CORS rules
/// still apply to external services such as FakeMaya.
class Platform {
  static bool get isIOS => false;
  static bool get isAndroid => false;
  static bool get isMacOS => false;
}

class SocketException implements Exception {
  const SocketException(
      [this.message = 'Network sockets are unavailable on Web.']);

  final String message;

  @override
  String toString() => message;
}

class File {
  File(this.path);

  final String path;

  Future<bool> exists() async => false;
  Future<String> readAsString() =>
      throw UnsupportedError('File I/O is unavailable on Web.');
  Future<int> length() async => 0;
  Future<File> writeAsString(String contents) async => this;
  Future<File> writeAsBytes(List<int> bytes, {bool flush = false}) async =>
      this;
  Future<void> delete() async {}
}

class Directory {
  Directory(this.path);

  final String path;

  Future<bool> exists() async => false;
  Future<Directory> create({bool recursive = false}) async => this;
}

class HttpStatus {
  static const tooManyRequests = 429;
}

class HttpHeaders {
  static const contentTypeHeader = 'content-type';
  static const authorizationHeader = 'authorization';
}

class ContentType {
  const ContentType._(this.value);

  static const json = ContentType._('application/json');

  final String value;
}

class _Headers {
  final _values = <String, String>{};

  set contentType(ContentType? value) {
    if (value == null) return;
    _values[HttpHeaders.contentTypeHeader] = value.value;
  }

  void set(String name, Object value) {
    _values[name] = value.toString();
  }

  Map<String, String> get values => Map.unmodifiable(_values);
}

class HttpClient {
  Duration? connectionTimeout;

  Future<HttpClientRequest> getUrl(Uri uri) async =>
      HttpClientRequest._('GET', uri);
  Future<HttpClientRequest> postUrl(Uri uri) async =>
      HttpClientRequest._('POST', uri);
  Future<HttpClientRequest> openUrl(String method, Uri uri) async =>
      HttpClientRequest._(method, uri);

  // BrowserClient has no persistent socket to close; each request owns its
  // short-lived client and response stream.
  void close({bool force = false}) {}
}

class HttpClientRequest {
  HttpClientRequest._(this._method, this._uri);

  final String _method;
  final Uri _uri;
  final headers = _Headers();
  final _body = <int>[];

  void add(List<int> bytes) => _body.addAll(bytes);
  void write(Object? object) => _body.addAll(utf8.encode(object.toString()));

  Future<HttpClientResponse> close() async {
    final client = BrowserClient();
    try {
      final request = http.Request(_method, _uri)
        ..headers.addAll(headers.values)
        ..bodyBytes = _body;
      final response = await client.send(request);
      return HttpClientResponse(response.statusCode, response.stream);
    } on http.ClientException catch (error) {
      client.close();
      throw SocketException(error.message);
    }
  }
}

class HttpClientResponse extends Stream<List<int>> {
  HttpClientResponse(this.statusCode, this._stream);

  final int statusCode;
  final Stream<List<int>> _stream;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}
