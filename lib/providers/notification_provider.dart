import 'package:flutter/material.dart' hide Notification;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';
import '../services/database_helper.dart';
import '../services/notification_helper.dart';
import '../services/notification_prefs.dart';

// Provider untuk mengelola state notifikasi dan logika penjadwalan
class NotificationProvider with ChangeNotifier {
  List<Notification> _notifications = [];
  bool _isLoading = false;

  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  // Menghitung jumlah notifikasi yang belum dibaca (exclude future notifications)
  int get unreadCount => _notifications
      .where((n) => !n.isRead && n.createdAt.isBefore(DateTime.now()))
      .length;

  List<Notification> getNotifications({
    NotificationType? type,
    bool unreadOnly = false,
  }) {
    return _notifications.where((n) {
      if (unreadOnly && n.isRead) return false;
      if (type != null && n.type != type) return false;
      // Filter out future notifications (they are scheduled but not yet "received")
      if (n.createdAt.isAfter(DateTime.now())) return false;
      return true;
    }).toList();
  }

  // Memuat daftar notifikasi dari database
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await DatabaseHelper.instance.getNotifications();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNotification(Notification notification) async {
    try {
      await DatabaseHelper.instance.insertNotification(notification);
      // Trigger local notification
      await NotificationHelper().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: notification.title,
        body: notification.message,
      );
      await loadNotifications();
    } catch (e) {
      debugPrint('Error adding notification: $e');
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await DatabaseHelper.instance.markNotificationAsRead(id);
      await loadNotifications();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await DatabaseHelper.instance.markAllNotificationsAsRead();
      await loadNotifications();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await DatabaseHelper.instance.clearAllNotifications();
      await loadNotifications();
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
    }
  }

  // Logika utama untuk menjadwalkan ulang semua notifikasi berdasarkan jadwal & tugas
  Future<void> scheduleAllNotifications(BuildContext context) async {
    // Note: context is not really needed if we use simple logic, but good for Snackbars if we want feedback here,
    // though usually UI handles feedback.
    // Let's keep it context-free if possible, or pass context for logging.
    _isLoading = true;
    notifyListeners();

    try {
      final helper = NotificationHelper();
      await helper.cancelAllNotifications();

      // Clear pending future notifications from DB to avoid duplicates
      await DatabaseHelper.instance.clearFutureNotifications();

      // Load prefs
      final prefs = await SharedPreferences.getInstance();
      final notifPrefs = NotificationPrefs(prefs);

      final taskEnabled = notifPrefs.isTaskNotificationsEnabled();
      final courseEnabled = notifPrefs.isCourseNotificationsEnabled();
      final taskOffset = notifPrefs.getTaskReminderOffset();
      final courseOffset = notifPrefs.getCourseReminderOffset();

      debugPrint('--- Scheduling Notifications ---');
      debugPrint(
        'Task Offset: $taskOffset min, Course Offset: $courseOffset min',
      );
      debugPrint('Task Enabled: $taskEnabled, Course Enabled: $courseEnabled');
      debugPrint('Current Time: ${DateTime.now()}');

      int scheduledCount = 0;

      if (courseEnabled) {
        final jadwalList = await DatabaseHelper.instance.getJadwalList();
        // Logic to schedule based on specific date if available
        for (final jadwal in jadwalList) {
          if (jadwal.tanggal != null && jadwal.jamMulai.isNotEmpty) {
            try {
              // Parse date YYYY-MM-DD
              final dateParts = jadwal.tanggal!.split('-');
              final timeParts = jadwal.jamMulai.split(':');

              final scheduleTime = DateTime(
                int.parse(dateParts[0]),
                int.parse(dateParts[1]),
                int.parse(dateParts[2]),
                int.parse(timeParts[0]),
                int.parse(timeParts[1]),
              );

              final reminderTime = scheduleTime.subtract(
                Duration(minutes: courseOffset),
              );

              debugPrint(
                'Jadwal: ${jadwal.mataKuliah}, Time: $scheduleTime, Reminder: $reminderTime',
              );

              if (reminderTime.isAfter(DateTime.now())) {
                await helper.scheduleNotification(
                  id: jadwal.id! + 10000,
                  title: 'Kelas Segera Dimulai',
                  body:
                      '${jadwal.mataKuliah} di ${jadwal.ruangan} pukul ${jadwal.jamMulai}',
                  scheduledDate: reminderTime,
                  payload: 'jadwal_${jadwal.id}',
                );

                // Persist to DB (will be hidden until time passes)
                final notif = Notification(
                  title: 'Kelas Segera Dimulai: ${jadwal.mataKuliah}',
                  message:
                      '${jadwal.mataKuliah} di ${jadwal.ruangan} pukul ${jadwal.jamMulai}',
                  type: NotificationType.classStarting,
                  createdAt: reminderTime,
                  relatedId: jadwal.id,
                  isRead: false,
                );
                await DatabaseHelper.instance.insertNotification(notif);

                scheduledCount++;
                debugPrint('-> SCHEDULED (Jadwal)');
              } else {
                debugPrint('-> SKIPPED (Already passed)');
              }
            } catch (e) {
              debugPrint('Error parsing jadwal date/time: $e');
            }
          }
        }
      }

      if (taskEnabled) {
        final tugasList = await DatabaseHelper.instance.getTugasList();
        for (final tugas in tugasList) {
          if (!tugas.selesai && tugas.tanggal != null && tugas.waktu != null) {
            final deadline = DateTime(
              tugas.tanggal!.year,
              tugas.tanggal!.month,
              tugas.tanggal!.day,
              tugas.waktu!.hour,
              tugas.waktu!.minute,
            );
            final reminderTime = deadline.subtract(
              Duration(minutes: taskOffset),
            );

            debugPrint(
              'Tugas: ${tugas.deskripsi}, Deadline: $deadline, Reminder: $reminderTime',
            );

            if (reminderTime.isAfter(DateTime.now())) {
              await helper.scheduleNotification(
                id: tugas.id! + 20000,
                title: 'Deadline Tugas',
                body: '${tugas.mataKuliah ?? 'Tugas'}: ${tugas.deskripsi}',
                scheduledDate: reminderTime,
                payload: 'tugas_${tugas.id}',
              );

              // Persist to DB
              final notif = Notification(
                title: 'Deadline Tugas: ${tugas.mataKuliah ?? 'Tugas'}',
                message: '${tugas.deskripsi} (Deadline: ${tugas.deadline})',
                type: NotificationType.assignment,
                createdAt: reminderTime,
                relatedId: tugas.id,
                isRead: false,
              );
              await DatabaseHelper.instance.insertNotification(notif);

              scheduledCount++;
              debugPrint('-> SCHEDULED (Tugas)');
            } else {
              debugPrint('-> SKIPPED (Already passed)');
            }
          }
        }
      }
      debugPrint('Total Scheduled: $scheduledCount');
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sends immediate notifications for all tasks and schedules (FOR TESTING PURPOSES)
  // Fungsi debug untuk memicu notifikasi tes secara langsung
  Future<void> triggerAllNotificationsNow(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final helper = NotificationHelper();
      int count = 0;

      // 1. Jadwal
      final jadwalList = await DatabaseHelper.instance.getJadwalList();
      for (final jadwal in jadwalList) {
        final notif = Notification(
          title: 'Test Jadwal: ${jadwal.mataKuliah}',
          message:
              '${jadwal.mataKuliah} di ${jadwal.ruangan} pukul ${jadwal.jamMulai}',
          type: NotificationType.classStarting,
          createdAt: DateTime.now(),
          relatedId: jadwal.id,
          isRead: false,
        );

        await DatabaseHelper.instance.insertNotification(notif);

        await helper.showNotification(
          id: jadwal.id! + 10000,
          title: notif.title,
          body: notif.message,
          payload: 'jadwal_${jadwal.id}',
        );
        count++;
        await Future.delayed(
          const Duration(milliseconds: 200),
        ); // Delay to prevent flooding
      }

      // 2. Tugas
      final tugasList = await DatabaseHelper.instance.getTugasList();
      for (final tugas in tugasList) {
        if (!tugas.selesai) {
          final notif = Notification(
            title: 'Test Tugas: ${tugas.mataKuliah ?? 'Tugas'}',
            message: '${tugas.deskripsi} (Deadline: ${tugas.deadline})',
            type: NotificationType.assignment,
            createdAt: DateTime.now(),
            relatedId: tugas.id,
            isRead: false,
          );

          await DatabaseHelper.instance.insertNotification(notif);

          await helper.showNotification(
            id: tugas.id! + 20000,
            title: notif.title,
            body: notif.message,
            payload: 'tugas_${tugas.id}',
          );
          count++;
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
      debugPrint('Triggered $count test notifications');

      // Reload notifications to update UI
      await loadNotifications();
    } catch (e) {
      debugPrint('Error triggering notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
