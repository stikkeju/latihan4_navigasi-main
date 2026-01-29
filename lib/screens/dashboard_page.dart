import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/schedule_card.dart';
import '../widgets/task_card.dart';
import '../utils/app_theme.dart';
import 'notification_page.dart';
// If you don't have direct imports for pages to navigate to, we can use Navigator.push with MaterialPageRoute if we have the classes, or named routes if defined.
// Based on previous context, 'TugasPage' exists. 'JadwalPage' might need checking, usually it's used in main_page navigation.
// Let's assume we can navigate to them. If they are part of the main bottom nav, we might need to switch tab index instead of pushing new page, but user asked for "direction to page", push is safer for "See All".

// Halaman dashboard utama yang menampilkan ringkasan jadwal dan tugas
class DashboardPage extends StatefulWidget {
  final Function(int)?
  onTabChange; // Optional: if we want to switch tabs instead

  const DashboardPage({super.key, this.onTabChange});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Inisialisasi locale format tanggal dan memuat data user & notifikasi
    initializeDateFormatting('id_ID', null).then((_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUserData();
      // Load notifications to get unread count
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).loadNotifications();
      // Ensure notifications are scheduled
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).scheduleAllNotifications(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final currentUser = userProvider.currentUser;
          final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

          final todaySchedules = userProvider.jadwalList
              .where((j) => j.tanggal == todayStr)
              .toList();

          final upcomingTasks = userProvider.tugasList
              .where((t) => !t.selesai)
              .take(5)
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              await userProvider.loadUserData();
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  // Header dashboard dengan sapaan dan statistik
                  child: DashboardHeader(
                    userName: currentUser?.nama ?? 'Mahasiswa',
                    date: DateFormat(
                      'EEEE, dd MMMM yyyy',
                      'id_ID',
                    ).format(DateTime.now()),
                    totalMatkul: userProvider.mataKuliahList.length,
                    totalTugas: userProvider.tugasList
                        .where((t) => !t.selesai)
                        .length,
                    onNotificationTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationPage(),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bagian untuk Jadwal Hari Ini
                        _buildSectionHeader(context, 'Jadwal Hari Ini', () {
                          if (widget.onTabChange != null) {
                            // Jadwal is at index 3
                            widget.onTabChange!(3);
                          }
                        }),
                        const SizedBox(height: 12),
                        if (todaySchedules.isEmpty)
                          _buildEmptyState('Tidak ada jadwal kuliah hari ini')
                        else
                          ...todaySchedules.map(
                            (jadwal) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: ScheduleCard(schedule: jadwal),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Bagian untuk Tugas Mendatang
                        _buildSectionHeader(context, 'Tugas Mendatang', () {
                          if (widget.onTabChange != null) {
                            // Tugas is at index 1
                            widget.onTabChange!(1);
                          }
                        }),
                        const SizedBox(height: 12),
                        if (upcomingTasks.isEmpty)
                          _buildEmptyState('Tidak ada tugas pending')
                        else
                          ...upcomingTasks.map(
                            (tugas) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: TaskCard(
                                task: tugas,
                                onToggle: (id) {
                                  Provider.of<UserProvider>(
                                    context,
                                    listen: false,
                                  ).toggleStatusTugas(id, !tugas.selesai);
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget pembantu untuk judul seksi dengan tombol 'Lihat Semua'
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onSeeAll,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Tampilan state kosong jika tidak ada data
  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Text(message, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}
