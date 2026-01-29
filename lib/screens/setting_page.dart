import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/notification_provider.dart';
import '../services/notification_prefs.dart';
import '../services/notification_helper.dart';
import '../utils/app_theme.dart';

import '../widgets/custom_page_header.dart';

// Halaman pengaturan aplikasi, termasuk preferensi notifikasi dan uji coba
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late NotificationPrefs _prefs;
  bool _isLoading = true;

  bool _taskEnabled = true;
  bool _courseEnabled = true;
  int _taskReminderOffset = 60;
  int _courseReminderOffset = 15;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  // Memuat preferensi pengguna dari SharedPreferences
  Future<void> _loadPrefs() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    _prefs = NotificationPrefs(sharedPrefs);

    setState(() {
      _taskEnabled = _prefs.isTaskNotificationsEnabled();
      _courseEnabled = _prefs.isCourseNotificationsEnabled();
      _taskReminderOffset = _prefs.getTaskReminderOffset();
      _courseReminderOffset = _prefs.getCourseReminderOffset();
      _isLoading = false;
    });
  }

  // Fungsi debug untuk mengirim notifikasi tes langsung
  Future<void> _testNotification() async {
    await NotificationHelper().showNotification(
      id: 9999,
      title: 'Test Notifikasi',
      body: 'Notifikasi berhasil dikirim!',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notifikasi dikirim')));
  }

  // Fungsi debug untuk memicu ulang semua penjadwalan notifikasi
  Future<void> _triggerAllNotifications(BuildContext context) async {
    try {
      final provider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      await provider.triggerAllNotificationsNow(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi test dikirim untuk semua data'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim test: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header matching others
            const CustomPageHeader(title: 'Kembali'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pengaturan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bagian Pengaturan Preferensi Notifikasi
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Preferensi Notifikasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Toggle Notifikasi Tugas
                          _buildSwitchTile(
                            title: 'Notifikasi Tugas',
                            subtitle: 'Aktifkan pengingat untuk tugas',
                            value: _taskEnabled,
                            onChanged: (val) async {
                              await _prefs.setTaskNotificationsEnabled(val);
                              setState(() => _taskEnabled = val);
                            },
                          ),

                          if (_taskEnabled) ...[
                            const Divider(height: 24),
                            _buildDropdownTile(
                              title: 'Ingatkan Tugas',
                              subtitle: 'Waktu sebelum deadline',
                              value: _taskReminderOffset,
                              items: const [
                                DropdownMenuItem(
                                  value: 15,
                                  child: Text('15 Menit'),
                                ),
                                DropdownMenuItem(
                                  value: 30,
                                  child: Text('30 Menit'),
                                ),
                                DropdownMenuItem(
                                  value: 60,
                                  child: Text('1 Jam'),
                                ),
                                DropdownMenuItem(
                                  value: 360,
                                  child: Text('6 Jam'),
                                ),
                                DropdownMenuItem(
                                  value: 720,
                                  child: Text('12 Jam'),
                                ),
                                DropdownMenuItem(
                                  value: 1440,
                                  child: Text('24 Jam'),
                                ),
                              ],
                              onChanged: (val) async {
                                if (val != null) {
                                  await _prefs.setTaskReminderOffset(val);
                                  setState(() => _taskReminderOffset = val);
                                }
                              },
                            ),
                          ],

                          const Divider(height: 24),

                          // Toggle Notifikasi Jadwal Kuliah
                          _buildSwitchTile(
                            title: 'Notifikasi Jadwal Kuliah',
                            subtitle: 'Aktifkan pengingat untuk jadwal kuliah',
                            value: _courseEnabled,
                            onChanged: (val) async {
                              await _prefs.setCourseNotificationsEnabled(val);
                              setState(() => _courseEnabled = val);
                            },
                          ),

                          if (_courseEnabled) ...[
                            const Divider(height: 24),
                            _buildDropdownTile(
                              title: 'Ingatkan Jadwal',
                              subtitle: 'Waktu sebelum kelas dimulai',
                              value: _courseReminderOffset,
                              items: const [
                                DropdownMenuItem(
                                  value: 15,
                                  child: Text('15 Menit'),
                                ),
                                DropdownMenuItem(
                                  value: 30,
                                  child: Text('30 Menit'),
                                ),
                                DropdownMenuItem(
                                  value: 60,
                                  child: Text('1 Jam'),
                                ),
                              ],
                              onChanged: (val) async {
                                if (val != null) {
                                  await _prefs.setCourseReminderOffset(val);
                                  setState(() => _courseReminderOffset = val);
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bagian Uji Coba fitur notifikasi (Debug)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Uji Coba',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _testNotification,
                              icon: const Icon(
                                Icons.notifications_active_outlined,
                              ),
                              label: const Text('Kirim Notifikasi Test'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await NotificationHelper()
                                    .testScheduledNotification();
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Menjadwalkan notifikasi dalam 5 detik...',
                                    ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.timer),
                              label: const Text(
                                'Test Jadwal 5 Detik (Exact Alarm)',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _triggerAllNotifications(context),
                              icon: const Icon(Icons.playlist_add_check),
                              label: const Text('Test Semua Notifikasi (Data)'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required int value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              items: items,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
