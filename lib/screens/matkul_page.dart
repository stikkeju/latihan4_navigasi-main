import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/matkul_card.dart';
import 'add_matkul_form_page.dart';

// Halaman daftar mata kuliah yang diambil mahasiswa
class MatkulPage extends StatefulWidget {
  const MatkulPage({super.key});

  @override
  _MatkulPageState createState() => _MatkulPageState();
}

class _MatkulPageState extends State<MatkulPage> {
  // Tabs removed as per feedback

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
              // Header halaman dengan tombol tambah mata kuliah
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mata Kuliah',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          final count = userProvider.mataKuliahList.length;
                          return Text(
                            '$count Mata Kuliah diambil',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddMatkulFormPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Daftar kartu mata kuliah (List of Cards)
              Expanded(
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final mataKuliahList = userProvider.mataKuliahList;

                    if (mataKuliahList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada mata kuliah',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: mataKuliahList.length,
                      itemBuilder: (context, index) {
                        final mk = mataKuliahList[index];
                        return MatkulCard(matkul: mk);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
