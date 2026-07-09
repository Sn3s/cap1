part of '../main.dart';

class ShellbyNotificationService {
  ShellbyNotificationService._();

  static final instance = ShellbyNotificationService._();
  static const _firstReminderId = 4100;
  static const _maxReminders = 8;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Manila'));
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (_) {},
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    }
    return true;
  }

  Future<void> scheduleDailyReminders(List<int> minutesOfDay) async {
    await initialize();
    await cancelReminders();
    for (var index = 0;
        index < minutesOfDay.length && index < _maxReminders;
        index++) {
      final minutes = minutesOfDay[index].clamp(0, 1439);
      final hour = minutes ~/ 60;
      final minute = minutes % 60;
      await _plugin.zonedSchedule(
        _firstReminderId + index,
        'A quick money check-in',
        'Hi from Shelby. When you have a moment, log your cash transactions or sync your linked account.',
        _nextTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'shellby_transaction_reminders',
            'Transaction reminders',
            channelDescription:
                'Friendly reminders to log or sync transactions.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentSound: true,
            threadIdentifier: 'shellby_transaction_reminders',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'activity',
      );
    }
  }

  Future<void> cancelReminders() async {
    await initialize();
    for (var index = 0; index < _maxReminders; index++) {
      await _plugin.cancel(_firstReminderId + index);
    }
  }

  Future<void> showTestReminder() async {
    await initialize();
    await _plugin.show(
      4199,
      'Shelby reminders are ready',
      'I will gently remind you when it is time to log or sync transactions.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'shellby_transaction_reminders',
          'Transaction reminders',
          channelDescription: 'Friendly reminders to log or sync transactions.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
        ),
      ),
    );
  }

  tz.TZDateTime _nextTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
