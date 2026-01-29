import 'dart:io';
import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../utils/app_theme.dart';

// Widget khusus untuk menampilkan foto dan identitas utama pengguna di profil
class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding dan dekorasi kartu utama
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Bagian Foto Profil
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                  // Menampilkan gambar jika url tersedia, jika tidak tampilkan ikon default
                  image: user.photoUrl != null && user.photoUrl!.isNotEmpty
                      ? DecorationImage(
                          image: _getProfileImageProvider(user.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                    ? const Icon(
                        Icons.person_outline,
                        size: 40,
                        color: AppTheme.primaryColor,
                      )
                    : null,
              ),
              const SizedBox(width: 20),

              // Bagian Identitas Nama dan NIM
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nama,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.nim,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Baris Informasi Tambahan (Email, Jurusan, Semester)
          if (user.email != null)
            _buildInfoRow(Icons.email_outlined, user.email!),
          const SizedBox(height: 12),
          if (user.jurusan != null)
            _buildInfoRow(Icons.school_outlined, user.jurusan!),
          const SizedBox(height: 12),
          if (user.semester != null)
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Semester ${user.semester}',
            ),
        ],
      ),
    );
  }

  // Fungsi pembantu untuk membuat baris info dengan ikon
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  // Menentukan provider gambar berdasarkan apakah itu URL web atau path lokal
  ImageProvider _getProfileImageProvider(String photoUrl) {
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return NetworkImage(photoUrl);
    }
    return FileImage(File(photoUrl));
  }
}
