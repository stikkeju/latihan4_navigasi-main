import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/data_models.dart';
import '../providers/user_provider.dart';
import 'add_tugas_form_page.dart';
import '../utils/app_theme.dart';

// Halaman detail untuk melihat informasi lengkap sebuah tugas
class DetailTugasPage extends StatelessWidget {
  final Tugas tugas;

  const DetailTugasPage({super.key, required this.tugas});

  // Helper untuk mendapatkan warna background badge prioritas
  Color _getPriorityBgColor(String priority) {
    switch (priority.toLowerCase()) {
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

  // Helper untuk mendapatkan warna teks badge prioritas
  Color _getPriorityTextColor(String priority) {
    switch (priority.toLowerCase()) {
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
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Find the latest version of the task
        // If not found (deleted), we should probably pop or show error
        final currentTugasIndex = userProvider.tugasList.indexWhere(
          (t) => t.id == tugas.id,
        );

        // Handle case where task might have been deleted but page is still active
        if (currentTugasIndex == -1) {
          // If we are here, it means the task was deleted.
          // Ideally we shouldn't be here, or we should show empty state / close page.
          // Given this is a detail page, let's just use the passed `tugas` (stale)
          // or pop frame after build. But safely, we can just return Scaffold with stale data or empty.
          // Better for UX: pop immediately if not found?
          // For now, let's just use stale data if not found, but this shouldn't happen
          // unless external delete.
          // Actually, if we just edited it, it should be there.
          // Let's rely on finding it.
        }

        final currentTugas = currentTugasIndex != -1
            ? userProvider.tugasList[currentTugasIndex]
            : tugas;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: Column(
              children: [
                // Header Kustom dengan Tombol Aksi (Edit & Hapus)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(color: AppTheme.primaryColor),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Kembali',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddTugasFormPage(tugas: currentTugas),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Hapus Tugas'),
                              content: const Text(
                                'Apakah Anda yakin ingin menghapus tugas ini?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (currentTugasIndex != -1) {
                                      userProvider.deleteTugas(
                                        currentTugasIndex,
                                      );
                                    }
                                    Navigator.pop(ctx); // Close Dialog
                                    Navigator.pop(context); // Close Detail Page
                                  },
                                  child: const Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detail Tugas',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Kartu ringkasan tugas (Judul, Matkul, Status)
                        Container(
                          padding: const EdgeInsets.all(16),
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
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: currentTugas.selesai
                                      ? AppTheme.primaryColor
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: currentTugas.selesai
                                        ? AppTheme.primaryColor
                                        : const Color(0xFFBDBDBD),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: currentTugas.selesai
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentTugas.deskripsi,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentTugas.mataKuliah ?? 'Mata Kuliah',
                                      style: const TextStyle(
                                        fontSize: 13,
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
                                            color: _getPriorityBgColor(
                                              currentTugas.priority,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            currentTugas.priority,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: _getPriorityTextColor(
                                                currentTugas.priority,
                                              ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Deadline: ${currentTugas.deadline}',
                                          style: const TextStyle(
                                            fontSize: 12,
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
                        const SizedBox(height: 20),

                        // Bagian detail informasi tugas (Waktu, Kategori, Prioritas)
                        Container(
                          padding: const EdgeInsets.all(20),
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
                                'Detail',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (currentTugas.tanggal != null)
                                _buildDetailRow(
                                  Icons.calendar_today_outlined,
                                  'Deadline',
                                  DateFormat(
                                    'MMM dd, yyyy',
                                    'id_ID',
                                  ).format(currentTugas.tanggal!),
                                ),
                              const SizedBox(height: 12),
                              if (currentTugas.waktu != null)
                                _buildDetailRow(
                                  Icons.access_time,
                                  'Waktu',
                                  currentTugas.waktu!.format(context),
                                ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                Icons.label_outline,
                                'Kategori',
                                'Tugas',
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                Icons.flag_outlined,
                                'Prioritas',
                                currentTugas.priority,
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                Icons.notifications,
                                'Notifikasi',
                                currentTugas.isReminderActive
                                    ? 'Aktif'
                                    : 'Tidak Aktif',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tombol aksi ubah status tugas
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (currentTugas.id != null) {
                                    userProvider.toggleStatusTugas(
                                      currentTugas.id!,
                                      !currentTugas.selesai,
                                    );
                                  }
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  currentTugas.selesai
                                      ? 'Tandai Belum Selesai'
                                      : 'Tandai Selesai',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF666666)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
