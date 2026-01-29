import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Helper untuk menangani notifikasi lokal menggunakan flutter_local_notifications
class NotificationHelper {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final NotificationHelper _instance = NotificationHelper._internal();

  factory NotificationHelper() {
    return _instance;
  }

  NotificationHelper._internal();

  // Menginisialisasi plugin notifikasi dan konfigurasi zona waktu
  Future<void> initNotifications() async {
    tz.initializeTimeZones();
    // Default to Jakarta/WIB if possible or UTC
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      // Fallback or ignore
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final platformImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (platformImplementation != null) {
      await platformImplementation.requestNotificationsPermission();
      // Required for Android 12+ to schedule exact notifications
      await platformImplementation.requestExactAlarmsPermission();
    }
  }

  // Menampilkan notifikasi segera (instant notification)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'channel_id',
          'General Notifications',
          channelDescription: 'General notifications for the app',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Menjadwalkan notifikasi pada waktu tertentu di masa depan
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.exactAllowWhileIdle,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tzScheduleDate = tz.TZDateTime.from(scheduledDate, tz.local);

    debugPrint('--- NotificationHelper Debug ---');
    debugPrint('Device Time (DateTime.now): ${DateTime.now()}');
    debugPrint('TZ Location: ${tz.local.name}');
    debugPrint('TZ Time (tz.now): ${tz.TZDateTime.now(tz.local)}');
    debugPrint('Input Date: $scheduledDate');
    debugPrint('Final Scheduled TZ Date: $tzScheduleDate');

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduleDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'scheduled_channel_v2',
            'Scheduled Notifications V2',
            channelDescription: 'Notifications for tasks and schedules',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('-> Success scheduling notification with mode: $scheduleMode');
    } catch (e) {
      debugPrint('-> Failed to schedule with mode $scheduleMode: $e');
      if (scheduleMode == AndroidScheduleMode.exactAllowWhileIdle) {
        debugPrint('-> Falling back to inexact notification');
        try {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            tzScheduleDate,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'scheduled_channel_v2',
                'Scheduled Notifications V2',
                channelDescription: 'Notifications for tasks and schedules',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: payload,
          );
        } catch (ex) {
          debugPrint('-> Failed even with inexact scheduling: $ex');
        }
      }
    }
  }

  Future<void> testScheduledNotification() async {
    final now = DateTime.now();
    final scheduledDate = now.add(const Duration(seconds: 5));

    debugPrint('--- TEST 5 SECONDS (AlarmClock Mode) ---');
    debugPrint('Now: $now');
    debugPrint('Scheduled: $scheduledDate');

    await scheduleNotification(
      id: 88888,
      title: 'Test Jadwal 5 Detik',
      body: 'Jika ini muncul, berarti Exact Alarm berfungsi!',
      scheduledDate: scheduledDate,
      payload: 'test_5_sec_alarm_clock',
      scheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  // Membatalkan semua notifikasi yang terjadwal
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
