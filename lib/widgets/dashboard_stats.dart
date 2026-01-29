import 'package:flutter/material.dart';

// Widget ini menampilkan statistik ringkas (tanggal, jumlah matkul, tugas) di dashboard
class DashboardStats extends StatelessWidget {
  final String date;
  final int totalMatkul;
  final int totalTugas;

  // Konstruktor untuk inisialisasi data statistik
  const DashboardStats({
    super.key,
    required this.date,
    required this.totalMatkul,
    required this.totalTugas,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Kartu pertama: Menampilkan tanggal hari ini
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                date,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Baris kedua: Menampilkan jumlah mata kuliah dan tugas
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Kolom kiri: Jumlah mata kuliah
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$totalMatkul Matkul',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
              // Kolom kanan: Jumlah tugas
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$totalTugas Tugas',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
