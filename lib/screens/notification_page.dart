import 'package:flutter/material.dart' hide Notification;
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_card.dart';
import '../utils/app_theme.dart';
import '../models/data_models.dart';
import '../widgets/custom_page_header.dart';

// Halaman notifikasi untuk melihat riwayat aktivitas dan pengingat
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NotificationType? _selectedFilter;
  bool _unreadOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).loadNotifications();
    });
  }

  // Dialog konfirmasi untuk menghapus semua data notifikasi
  void _clearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua'),
        content: const Text(
          'Apakah kamu yakin ingin menghapus semua notifikasi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<NotificationProvider>(
                context,
                listen: false,
              ).clearAllNotifications();
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _markAllRead(BuildContext context) {
    Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan tombol aksi 'Tandai Terbaca'
            CustomPageHeader(
              title: 'Kembali',
              action: TextButton(
                onPressed: () => _markAllRead(context),
                child: const Text(
                  'Tandai Terbaca',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  // Get filtered list
                  final notifications = provider.getNotifications(
                    type: _selectedFilter,
                    unreadOnly: _unreadOnly,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page Title & Subtitle
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Notifikasi',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Lihat semua aktivitas terbaru',
                              style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Chip Filter Kategori Notifikasi
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _buildFilterChip('Semua', null, isAll: true),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Belum Terbaca',
                              null,
                              isUnread: true,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Tugas',
                              NotificationType.assignment,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Jadwal',
                              NotificationType.classStarting,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Daftar List Notifikasi
                      Expanded(
                        child: notifications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.notifications_off_outlined,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      provider.isLoading
                                          ? 'Memuat...'
                                          : 'Tidak ada notifikasi',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  final notification = notifications[index];
                                  return NotificationCard(
                                    notification: notification,
                                    onTap: () {
                                      if (!notification.isRead) {
                                        provider.markAsRead(notification.id!);
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _clearAll(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete_sweep, color: Colors.white),
        tooltip: 'Hapus Semua',
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    NotificationType? type, {
    bool isAll = false,
    bool isUnread = false,
  }) {
    final bool isSelected = isAll
        ? (_selectedFilter == null && !_unreadOnly)
        : isUnread
        ? _unreadOnly
        : _selectedFilter == type;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (isAll) {
            _selectedFilter = null;
            _unreadOnly = false;
          } else if (isUnread) {
            _unreadOnly = selected;
            // If unread is selected, we keep the type filter or clear it?
            // Usually unread is a separate toggle or replaces type.
            // Use simple logic: unread overwrites "All" state but let's allow combining?
            // For now, behave like tabs:
            if (selected) _selectedFilter = null;
          } else {
            _selectedFilter = selected ? type : null;
            _unreadOnly = false;
          }
        });
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
        ),
      ),
    );
  }
}
