import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../providers/user_provider.dart';
import '../screens/add_jadwal_form_page.dart';

// Widget ini menampilkan detail satu item jadwal dalam bentuk kartu
class JadwalCard extends StatelessWidget {
  final Jadwal jadwal;

  const JadwalCard({super.key, required this.jadwal});

  @override
  Widget build(BuildContext context) {
    // Menghitung durasi jadwal (jam:menit)
    String durationStr = '';
    try {
      final start = TimeOfDay(
        hour: int.parse(jadwal.jamMulai.split(':')[0]),
        minute: int.parse(jadwal.jamMulai.split(':')[1]),
      );
      final end = TimeOfDay(
        hour: int.parse(jadwal.jamSelesai.split(':')[0]),
        minute: int.parse(jadwal.jamSelesai.split(':')[1]),
      );
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;
      final diff = endMinutes - startMinutes;
      if (diff > 0) {
        final hours = diff ~/ 60;
        final mins = diff % 60;
        if (hours > 0) durationStr += '$hours Jam ';
        if (mins > 0) durationStr += '$mins Mnt';
      }
    } catch (e) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      // Memberikan dekorasi bayangan halus pada kartu
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
          // Baris 1: Waktu Mulai, Durasi, dan Tombol Edit
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Color(0xFF1A1A1A)),
              const SizedBox(width: 8),
              Text(
                jadwal.jamMulai,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                durationStr.isNotEmpty ? '($durationStr)' : '',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              // Tombol opsi (titik tiga) untuk mengedit jadwal
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddJadwalFormPage(jadwal: jadwal),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.more_vert, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Baris 2: Nama Mata Kuliah
          Text(
            jadwal.mataKuliah,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),

          // Baris 3: Nama Dosen (diambil dari UserProvider)
          Consumer<UserProvider>(
            builder: (context, provider, child) {
              final mk = provider.mataKuliahList.firstWhere(
                (m) => m.nama == jadwal.mataKuliah,
                orElse: () => MataKuliah(nama: '', dosen: ''),
              );
              return Text(
                mk.dosen.isNotEmpty ? mk.dosen : 'Dosen',
                style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
              );
            },
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Baris 4: Ruangan dan Jenis Perkuliahan
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Color(0xFF666666),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  jadwal.ruangan,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
              // Badge Jenis (Kuliah, Praktikum, dll)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  jadwal.jenis ?? 'Kuliah',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
