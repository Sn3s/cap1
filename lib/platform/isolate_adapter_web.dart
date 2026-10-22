import 'dart:async';

class SendPort {
  void send(Object? message) {}
}

class ReceivePort extends Stream<Object?> {
  final StreamController<Object?> _controller = StreamController<Object?>();

  SendPort get sendPort => SendPort();

  void close() => _controller.close();

  @override
  StreamSubscription<Object?> listen(
    void Function(Object?)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _controller.stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}

class Isolate {
  static const immediate = 0;

  static Future<Isolate> spawn(
    FutureOr<void> Function(List<Object?>) entryPoint,
    List<Object?> message, {
    String? debugName,
  }) =>
      Future<Isolate>.error(
        UnsupportedError('Local AI is unavailable on Web.'),
      );

  void kill({int priority = immediate}) {}
}
