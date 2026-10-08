part of '../main.dart';

/// Single source of "now" for the app. A developer offset can be applied
/// from Profile → Settings → Time travel to test time-sensitive features.
/// The offset is persisted so it survives app restarts.
///
/// OS-scheduled notifications still use the real device clock.
class AppClock {
  AppClock._();

  static const _fileName = 'app_clock_offset.json';

  /// Current offset from the real clock. Listen to rebuild on change.
  static final ValueNotifier<Duration> offset = ValueNotifier(Duration.zero);

  static DateTime now() => DateTime.now().add(offset.value);

  static bool get isOverridden => offset.value != Duration.zero;

  static Future<void> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final data = jsonDecode(await file.readAsString());
      if (data is Map && data['offsetMicroseconds'] is int) {
        offset.value = Duration(microseconds: data['offsetMicroseconds']);
      }
    } catch (_) {
      // A corrupt or unreadable override file falls back to real time.
    }
  }

  /// Shifts the clock so that [AppClock.now] reads [target] right now.
  static Future<void> setNow(DateTime target) =>
      setOffset(target.difference(DateTime.now()));

  static Future<void> shift(Duration delta) => setOffset(offset.value + delta);

  static Future<void> reset() => setOffset(Duration.zero);

  static Future<void> setOffset(Duration value) async {
    offset.value = value;
    try {
      final file = await _file();
      if (value == Duration.zero) {
        if (await file.exists()) await file.delete();
      } else {
        await file.writeAsString(
          jsonEncode({'offsetMicroseconds': value.inMicroseconds}),
        );
      }
    } catch (_) {
      // Persistence is best effort; the in-memory offset still applies.
    }
  }

  static Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }
}
