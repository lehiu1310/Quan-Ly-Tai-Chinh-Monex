import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:monex/data/app_state.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _askedPermission = false;

  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    await _plugin.cancelAll();
  }

  Future<void> scheduleReminder(ReminderEntry reminder) async {
    await _ensureNotificationPermission();

    final now = DateTime.now();
    var scheduled = DateTime(
      reminder.dueDate.year,
      reminder.dueDate.month,
      reminder.dueDate.day,
      9,
    ).subtract(const Duration(days: 1));
    if (scheduled.isBefore(now)) {
      scheduled = now.add(const Duration(seconds: 15));
    }

    await _plugin.zonedSchedule(
      reminder.id.hashCode & 0x7fffffff,
      'Sắp đến hạn: ${reminder.title}',
      'Khoản ${money(reminder.amount)} đến hạn ngày ${shortDate(reminder.dueDate)}',
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'monex_bills',
          'Nhắc hóa đơn',
          channelDescription: 'Thông báo các hóa đơn và khoản cần trả.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _ensureNotificationPermission() async {
    if (_askedPermission) return;
    _askedPermission = true;
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }
}

final NotificationService notificationService = NotificationService();
