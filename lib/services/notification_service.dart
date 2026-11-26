import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/domain/notification_planner.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules planned reminders with Android.
class DeviceNotificationService implements NotificationScheduler {
  static const String _notificationIcon = '@drawable/ic_notification';
  static const int _testNotificationId = 1000000;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } on Exception {
      // Scheduling uses absolute instants, so the default zone stays accurate.
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_notificationIcon),
      ),
    );

    final android = _android;
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'windows',
        AppCopy.channelWindows,
        importance: Importance.defaultImportance,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'warnings',
        AppCopy.channelWarnings,
        importance: Importance.high,
        enableVibration: true,
      ),
    );
  }

  @override
  Future<void> reschedule(List<PlannedNotification> plan) async {
    await _plugin.cancelAll();
    final canUseExact =
        await _android?.canScheduleExactNotifications() ?? false;
    final mode = canUseExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    for (final notification in plan) {
      await _plugin.zonedSchedule(
        id: notification.id,
        title: AppCopy.appName,
        body: notification.body,
        scheduledDate: tz.TZDateTime.from(notification.at, tz.local),
        notificationDetails: _details(notification.channel),
        androidScheduleMode: mode,
      );
    }
  }

  @override
  Future<void> showTest() => _plugin.show(
    id: _testNotificationId,
    title: AppCopy.appName,
    body: AppCopy.testNotificationBody,
    notificationDetails: _details(ReminderChannel.warnings),
  );

  NotificationDetails _details(ReminderChannel channel) {
    return NotificationDetails(
      android: switch (channel) {
        ReminderChannel.windows => const AndroidNotificationDetails(
          'windows',
          AppCopy.channelWindows,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        ReminderChannel.warnings => const AndroidNotificationDetails(
          'warnings',
          AppCopy.channelWarnings,
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
        ),
      },
    );
  }
}
