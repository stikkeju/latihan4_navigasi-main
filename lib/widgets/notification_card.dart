import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/data_models.dart' as model;

// Widget kartu untuk menampilkan satu item notifikasi dalam daftar
class NotificationCard extends StatelessWidget {
  final model.Notification notification;
  final VoidCallback? onTap;

  const NotificationCard({super.key, required this.notification, this.onTap});

  // Memilih ikon yang sesuai berdasarkan tipe notifikasi
  IconData get _icon {
    switch (notification.type) {
      case model.NotificationType.assignment:
        return Icons.assignment_outlined;
      case model.NotificationType.classStarting:
        return Icons.class_outlined;
      case model.NotificationType.taskCompleted:
        return Icons.check_circle_outline;
      case model.NotificationType.courseMaterial:
        return Icons.menu_book_outlined;
      case model.NotificationType.quiz:
        return Icons.quiz_outlined;
    }
  }

  // Menentukan warna utama ikon berdasarkan tipe notifikasi
  Color get _color {
    switch (notification.type) {
      case model.NotificationType.assignment:
        return const Color(0xFFE53935);
      case model.NotificationType.classStarting:
        return const Color(0xFF1E88E5);
      case model.NotificationType.taskCompleted:
        return const Color(0xFF43A047);
      case model.NotificationType.courseMaterial:
        return const Color(0xFFFB8C00);
      case model.NotificationType.quiz:
        return const Color(0xFF8E24AA);
    }
  }

  // Menentukan warna latar belakang ikon agar kontras dan estetik
  Color get _bgColor {
    switch (notification.type) {
      case model.NotificationType.assignment:
        return const Color(0xFFFFEBEE);
      case model.NotificationType.classStarting:
        return const Color(0xFFE3F2FD);
      case model.NotificationType.taskCompleted:
        return const Color(0xFFE8F5E9);
      case model.NotificationType.courseMaterial:
        return const Color(0xFFFFF3E0);
      case model.NotificationType.quiz:
        return const Color(0xFFF3E5F5);
    }
  }

  // Memformat waktu notifikasi menjadi "X menit/jam yang lalu" atau tanggal
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('d MMM y').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon, color: _color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
