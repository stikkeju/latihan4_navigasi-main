import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/data_models.dart';

// Widget kartu tugas yang detail untuk halaman daftar tugas utama
class TaskCard extends StatelessWidget {
  final Tugas task;
  final Function(int) onToggle;
  final VoidCallback? onTap;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onToggle,
    this.onTap,
  }) : super(key: key);

  // Logika untuk menampilkan label tanggal yang ramah pengguna (Hari ini, Besok, dll)
  String _getDateLabel(DateTime? deadline) {
    if (deadline == null) return 'Tanpa Deadline';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);
    final difference = deadlineDate.difference(today).inDays;

    if (difference < 0) {
      return 'Sudah lewat';
    } else if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Besok';
    } else if (difference <= 7) {
      return '$difference hari lagi';
    } else {
      return DateFormat('dd MMM').format(deadline);
    }
  }

  // Menentukan warna teks tanggal (merah jika terlewat)
  Color _getDateColor(DateTime? deadline) {
    if (deadline == null) return const Color(0xFF06B6D4);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);

    if (deadlineDate.isBefore(today)) {
      return Colors.red;
    }
    return const Color(0xFF06B6D4);
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFFF5252);
      case 'medium':
        return const Color(0xFFFFA726);
      case 'low':
        return const Color(0xFF66BB6A);
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityBgColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFFFEBEE);
      case 'medium':
        return const Color(0xFFFFF3E0);
      case 'low':
        return const Color(0xFFE8F5E9);
      default:
        return Colors.grey[100]!;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'Tinggi';
      case 'medium':
        return 'Sedang';
      case 'low':
        return 'Rendah';
      default:
        return priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menggabungkan tanggal dan waktu menjadi satu objek DateTime jika tersedia
    DateTime? deadlineDate;
    if (task.tanggal != null) {
      if (task.waktu != null) {
        deadlineDate = DateTime(
          task.tanggal!.year,
          task.tanggal!.month,
          task.tanggal!.day,
          task.waktu!.hour,
          task.waktu!.minute,
        );
      } else {
        deadlineDate = task.tanggal;
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox kustom untuk menandai status selesai
                InkWell(
                  onTap: () => onToggle(task.id!),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: task.selesai
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE0E0E0),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      color: task.selesai
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                    ),
                    child: task.selesai
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Konten teks deskripsi dan detail tugas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.deskripsi,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                          decoration: task.selesai
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (task.mataKuliah != null) ...[
                        Text(
                          task.mataKuliah!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Color(0xFF666666),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            deadlineDate != null
                                ? DateFormat(
                                    'dd MMMM yyyy, HH:mm',
                                    'id_ID',
                                  ).format(deadlineDate)
                                : 'Tanpa Deadline',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Kolom badge untuk status deadline dan prioritas
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Badge tanggal
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getDateLabel(deadlineDate),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getDateColor(deadlineDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Badge prioritas
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityBgColor(task.priority),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getPriorityLabel(task.priority),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getPriorityColor(task.priority),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
