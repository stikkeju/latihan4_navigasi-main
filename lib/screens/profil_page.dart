import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_routes.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/profile_menu_item.dart';
import 'edit_profile_page.dart';
import 'setting_page.dart';

// Halaman profil pengguna yang menampilkan statistik akademik dan menu pengaturan
class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;

        if (user == null) {
          return const Scaffold(
            body: Center(child: Text("User not logged in")),
          );
        }

        // Calculate stats
        final matkulCount = userProvider.mataKuliahList.length;
        final tugasSelesai = userProvider.tugasList
            .where((t) => t.selesai)
            .length;
        final tugasAktif = userProvider.tugasList
            .where((t) => !t.selesai)
            .length;
        final totalTugas = tugasSelesai + tugasAktif;
        final progress = totalTugas > 0 ? tugasSelesai / totalTugas : 0.0;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header judul halaman
                  const Text(
                    'Profil',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kartu Profil Utama (Foto, Nama, NIM)
                  ProfileHeader(user: user),

                  const SizedBox(height: 24),

                  // Kartu Statistik Ringkas (Matkul, Selesai, Aktif)
                  Row(
                    children: [
                      Expanded(
                        child: ProfileStatCard(
                          icon: Icons.book_outlined,
                          label: 'Matkul',
                          value: matkulCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ProfileStatCard(
                          icon: Icons.check_box_outlined,
                          label: 'Tugas Selesai',
                          value: tugasSelesai.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ProfileStatCard(
                          icon: Icons.notifications_none_outlined,
                          label: 'Tugas Aktif',
                          value: tugasAktif.toString(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Widget indikator progress penyelesaian tugas
                  Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Progress Tugas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tugas Selesai ($tugasSelesai dari $totalTugas)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: const Color(0xFFF5F5F5),
                                color: const Color(0xFF4CAF50),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Daftar menu pengaturan profil
                  Container(
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
                        ProfileMenuItem(
                          icon: Icons.person_outline,
                          title: 'Edit Profil',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProfilePage(user: user),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 24),
                        ProfileMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Pengaturan',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tombol Logout dengan konfirmasi (langsung saat ini)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        userProvider.logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout, color: Color(0xFF1A1A1A)),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
