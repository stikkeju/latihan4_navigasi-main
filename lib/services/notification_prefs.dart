import 'package:shared_preferences/shared_preferences.dart';

// Kelas untuk menyimpan preferensi pengaturan notifikasi pengguna di SharedPreferences
class NotificationPrefs {
  final SharedPreferences _prefs;

  static const String keyTaskReminderOffset =
      'notification_task_reminder_offset';
  static const String keyCourseReminderOffset =
      'notification_course_reminder_offset';
  static const String keyTaskNotificationsEnabled = 'notification_task_enabled';
  static const String keyCourseNotificationsEnabled =
      'notification_course_enabled';

  NotificationPrefs(this._prefs);

  /// Get task reminder offset in minutes. Default: 60 (1 hour)
  // Mendapatkan offset waktu pengingat tugas dalam menit (default 60 menit)
  int getTaskReminderOffset() {
    return _prefs.getInt(keyTaskReminderOffset) ?? 60;
  }

  /// Set task reminder offset in minutes
  // Menyimpan pengaturan offset waktu untuk tugas
  Future<void> setTaskReminderOffset(int minutes) async {
    await _prefs.setInt(keyTaskReminderOffset, minutes);
  }

  /// Get course reminder offset in minutes. Default: 15
  // Mendapatkan offset waktu pengingat kuliah dalam menit (default 15 menit)
  int getCourseReminderOffset() {
    return _prefs.getInt(keyCourseReminderOffset) ?? 15;
  }

  /// Set course reminder offset in minutes
  Future<void> setCourseReminderOffset(int minutes) async {
    await _prefs.setInt(keyCourseReminderOffset, minutes);
  }

  /// Check if task notifications are enabled globally. Default: true
  // Mengecek apakah notifikasi tugas diaktifkan
  bool isTaskNotificationsEnabled() {
    return _prefs.getBool(keyTaskNotificationsEnabled) ?? true;
  }

  /// Set global task notification state
  Future<void> setTaskNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(keyTaskNotificationsEnabled, enabled);
  }

  /// Check if course notifications are enabled globally. Default: true
  bool isCourseNotificationsEnabled() {
    return _prefs.getBool(keyCourseNotificationsEnabled) ?? true;
  }

  /// Set global course notification state
  Future<void> setCourseNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(keyCourseNotificationsEnabled, enabled);
  }
}
