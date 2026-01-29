import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/data_models.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/weekly_date_picker.dart';
import '../widgets/jadwal_card.dart';
import 'add_jadwal_form_page.dart';

// Halaman jadwal yang menampilkan daftar kelas harian atau list semua jadwal
class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  _JadwalPageState createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header halaman jadwal
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jadwal',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tab Bar untuk navigasi Harian / Semua
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: const [
                          Tab(text: 'Harian'),
                          Tab(text: 'Semua'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Konten TabView
              Expanded(
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                        WeeklyDatePicker(
                          selectedDate: _selectedDate,
                          onDateSelected: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),
                        Expanded(
                          child: Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              return _buildDailyList(userProvider);
                            },
                          ),
                        ),
                      ],
                    ),

                    // Tab 2: Tampilan List Semua Jadwal
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        return _buildAllList(userProvider);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddJadwalFormPage(),
              ),
            );
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // Membangun tampilan daftar jadwal untuk tanggal tertentu (Harian)
  Widget _buildDailyList(UserProvider userProvider) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final jadwalList = userProvider.jadwalList
        .where((j) => j.tanggal == dateStr)
        .toList();

    jadwalList.sort((a, b) => a.jamMulai.compareTo(b.jamMulai));

    if (jadwalList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada jadwal hari ini',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: jadwalList.length,
      itemBuilder: (context, index) {
        return JadwalCard(jadwal: jadwalList[index]);
      },
    );
  }

  // Membangun daftar semua jadwal yang dikelompokkan berdasarkan tanggal
  Widget _buildAllList(UserProvider userProvider) {
    final allJadwal = List<Jadwal>.from(userProvider.jadwalList);

    // Sort by Date then Time
    allJadwal.sort((a, b) {
      final dateCmp = (a.tanggal ?? '').compareTo(b.tanggal ?? '');
      if (dateCmp != 0) return dateCmp;
      return a.jamMulai.compareTo(b.jamMulai);
    });

    if (allJadwal.isEmpty) {
      return Center(
        child: Text(
          'Belum ada jadwal tersimpan',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    // Group by Date
    // Map<String, List<Jadwal>>
    final Map<String, List<Jadwal>> grouped = {};
    for (var j in allJadwal) {
      if (j.tanggal != null) {
        if (!grouped.containsKey(j.tanggal)) {
          grouped[j.tanggal!] = [];
        }
        grouped[j.tanggal!]!.add(j);
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final jadwals = grouped[dateKey]!;

        // Formatted Header Date
        DateTime? date;
        try {
          date = DateFormat('yyyy-MM-dd').parse(dateKey);
        } catch (e) {
          date = DateTime.now();
        }
        final formattedDate = DateFormat(
          'EEEE, d MMMM yyyy',
          'id_ID',
        ).format(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...jadwals.map((j) => JadwalCard(jadwal: j)).toList(),
          ],
        );
      },
    );
  }
}
