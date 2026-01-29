import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_routes.dart';
import '../widgets/tugas_card.dart';
import '../widgets/filter_button.dart';
import '../models/data_models.dart';

// Halaman daftar tugas dengan fitur pencarian dan filter status
class TugasPage extends StatefulWidget {
  const TugasPage({super.key});

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Mengubah filter tampilan tugas (Semua, Aktif, Selesai)
  void _applyFilter(String filter) {
    setState(() => _selectedFilter = filter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header halaman
              const Text(
                'Tugas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 20),

              // Widget kolom pencarian tugas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {}); // Rebuild to filter
                  },
                  decoration: const InputDecoration(
                    hintText: 'Cari tugas..',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol-tombol filter kategori tugas
              SizedBox(
                height: 48, // Fixed height to ensure visibility
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterButton(
                      label: 'Semua',
                      value: 'semua',
                      groupValue: _selectedFilter,
                      onChanged: _applyFilter,
                    ),
                    const SizedBox(width: 8),
                    FilterButton(
                      label: 'Aktif',
                      value: 'aktif',
                      groupValue: _selectedFilter,
                      onChanged: _applyFilter,
                    ),
                    const SizedBox(width: 8),
                    FilterButton(
                      label: 'Selesai',
                      value: 'selesai',
                      groupValue: _selectedFilter,
                      onChanged: _applyFilter,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Daftar tugas yang difilter dan dicari
              Expanded(
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    // Filter Logic
                    final allTugas = userProvider.tugasList;
                    final filteredTugas = allTugas.where((t) {
                      // 1. Search Query
                      final query = _searchController.text.toLowerCase();
                      if (query.isNotEmpty &&
                          !t.deskripsi.toLowerCase().contains(query)) {
                        return false;
                      }

                      // 2. Filter Tab
                      if (_selectedFilter == 'aktif' && t.selesai) return false;
                      if (_selectedFilter == 'selesai' && !t.selesai)
                        return false;

                      return true;
                    }).toList();

                    if (filteredTugas.isEmpty) {
                      return const Center(child: Text('Tidak ada tugas'));
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '(${filteredTugas.length}) Tugas ditemukan',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredTugas.length,
                            itemBuilder: (context, index) {
                              final tugas = filteredTugas[index];
                              return TugasCard(
                                tugas: tugas,
                                onTap: () {
                                  // Navigasi ke DetailTugasPage (akan dibuat)
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.detailTugas,
                                    arguments: tugas,
                                  );
                                },
                                onCheckChanged: (value) {
                                  // Call toggle with ID directly as safer alternative
                                  if (tugas.id != null) {
                                    userProvider.toggleStatusTugas(
                                      tugas.id!,
                                      !tugas.selesai,
                                    );
                                    // Sync notifications
                                    Provider.of<NotificationProvider>(
                                      context,
                                      listen: false,
                                    ).scheduleAllNotifications(context);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.pengingatTugas);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
