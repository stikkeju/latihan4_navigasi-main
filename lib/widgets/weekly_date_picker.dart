import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';

// Widget ini berfungsi sebagai kalender mingguan horizontal yang bisa digeser
class WeeklyDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  // Menerima tanggal saat ini dan fungsi callback saat tanggal dipilih
  const WeeklyDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bagian atas: Menampilkan bulan dan kontrol navigasi mingguan
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol untuk mundur satu minggu
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  onDateSelected(
                    selectedDate.subtract(const Duration(days: 7)),
                  );
                },
              ),
              // Menampilkan informasi bulan dan tanggal yang dipilih
              Column(
                children: [
                  Text(
                    DateFormat('MMMM', 'id_ID').format(selectedDate),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    DateFormat('EEEE dd', 'id_ID').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              // Tombol untuk maju satu minggu
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  onDateSelected(selectedDate.add(const Duration(days: 7)));
                },
              ),
            ],
          ),
        ),
        // Bagian bawah: List horizontal tanggal dalam seminggu
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 7,
            itemBuilder: (context, index) {
              // Menghitung tanggal mundur dari hari dalam minggu ini
              final date = selectedDate.subtract(
                Duration(days: selectedDate.weekday - 1 - index),
              );
              // Menandai apakah tanggal ini sedang dipilih
              final isSelected =
                  date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              // Menandai apakah tanggal ini adalah hari ini (real-time)
              final isToday =
                  date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;

              // Widget interaktif untuk setiap tanggal
              return GestureDetector(
                onTap: () {
                  onDateSelected(date);
                },
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nama hari singkat (Sen, Sel, dll)
                      Text(
                        DateFormat('EEE', 'id_ID').format(date).substring(0, 3),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Tanggal (angka)
                      Text(
                        date.day.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                      // Titik penanda hari ini jika tidak dipilih
                      if (isToday && !isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
