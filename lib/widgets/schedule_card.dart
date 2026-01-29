import 'package:flutter/material.dart';
import '../models/data_models.dart';

// Widget kartu untuk menampilkan informasi jadwal kuliah harian
class ScheduleCard extends StatelessWidget {
  final Jadwal schedule;
  final VoidCallback? onTap;

  const ScheduleCard({Key? key, required this.schedule, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ikon penanda jadwal di sebelah kiri
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E5FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF3F51B5),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Konten teks informasi jadwal (nama matkul, jam, ruangan)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.mataKuliah,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        schedule.jamMulai,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      if (schedule.ruangan.isNotEmpty) ...[
                        const Text(
                          ' • ',
                          style: TextStyle(color: Color(0xFF666666)),
                        ),
                        Text(
                          schedule.ruangan,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Badge kecil untuk menandai jenis kelas (Praktikum/Teori)
            if (schedule.jenis != null && schedule.jenis!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: schedule.jenis == 'Praktikum'
                      ? const Color(0xFFFFEEF5)
                      : const Color(0xFFE8F5FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  schedule.jenis!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: schedule.jenis == 'Praktikum'
                        ? const Color(0xFFD946EF)
                        : const Color(0xFF06B6D4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
