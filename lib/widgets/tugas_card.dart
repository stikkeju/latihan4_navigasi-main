import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/data_models.dart';
import '../utils/app_theme.dart';

// Widget kartu ringkasan tugas (versi lebih sederhana/compact)
class TugasCard extends StatelessWidget {
  final Tugas tugas;
  final VoidCallback? onTap;
  final Function(bool?)? onCheckChanged;

  const TugasCard({
    super.key,
    required this.tugas,
    this.onTap,
    this.onCheckChanged,
  });

  // Mendapatkan warna background badge berdasarkan prioritas
  Color _getPriorityBackgroundColor() {
    switch (tugas.priority.toLowerCase()) {
      case 'tinggi':
        return const Color(0xFFFFEBEE);
      case 'sedang':
        return const Color(0xFFE3F2FD);
      case 'rendah':
        return const Color(0xFFE8F5E9);
      default:
        return const Color(0xFFE3F2FD);
    }
  }

  // Mendapatkan warna teks badge berdasarkan prioritas
  Color _getPriorityTextColor() {
    switch (tugas.priority.toLowerCase()) {
      case 'tinggi':
        return const Color(0xFFEF5350);
      case 'sedang':
        return const Color(0xFF2196F3);
      case 'rendah':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF2196F3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tugas.selesai ? const Color(0xFFF5F5F5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: tugas.selesai
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Widget checkbox yang bisa diklik untuk ubah status
            GestureDetector(
              onTap: () => onCheckChanged?.call(!tugas.selesai),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: tugas.selesai
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  border: Border.all(
                    color: tugas.selesai
                        ? AppTheme.primaryColor
                        : const Color(0xFFBDBDBD),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: tugas.selesai
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Detail tugas termasuk deskripsi, matkul, dan deadline
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tugas.deskripsi,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                      decoration: tugas.selesai
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (tugas.mataKuliah != null)
                    Text(
                      tugas.mataKuliah!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityBackgroundColor(),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tugas.priority.isNotEmpty ? tugas.priority : 'Tugas',
                          style: TextStyle(
                            fontSize: 10,
                            color: _getPriorityTextColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (tugas.waktu != null)
                        Text(
                          'Deadline: ${_formatDate(tugas.tanggal)} ${tugas.waktu!.format(context)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF999999),
                          ),
                        )
                      else if (tugas.tanggal != null)
                        Text(
                          'Deadline: ${_formatDate(tugas.tanggal)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF999999),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }
}
