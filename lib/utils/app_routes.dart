import 'package:flutter/material.dart';
import '../screens/login_page.dart';
import '../screens/main_page.dart';
import '../screens/matkul_page.dart';
import '../screens/jadwal_page.dart';
import '../screens/add_tugas_form_page.dart';
import '../screens/tugas_page.dart';
import '../screens/profil_page.dart';
import '../screens/register_page.dart';
import '../screens/detail_tugas_page.dart'; // Import Detail Page
import '../models/data_models.dart'; // Import Tugas model

import '../screens/splash_screen.dart';

// Kelas ini berisi daftar rute navigasi agar lebih terpusat dan mudah diatur
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String matkul = '/matkul';
  static const String aturJadwal = '/atur_jadwal';
  static const String pengingatTugas = '/add_tugas'; // Updated path name
  static const String laporanTugas = '/tugas'; // Updated path name
  static const String detailTugas = '/detail_tugas'; // New Route
  static const String profil = '/profil';

  // Daftar pemetaan string rute ke halaman widget yang sesuai
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    dashboard: (context) => const MainPage(),
    matkul: (context) => const MatkulPage(),
    aturJadwal: (context) => const JadwalPage(),
    pengingatTugas: (context) => const AddTugasFormPage(),
    laporanTugas: (context) => const TugasPage(),
    profil: (context) => const ProfilPage(),
    detailTugas: (context) {
      // Mengambil argumen tugas yang dikirim saat navigasi
      final tugas = ModalRoute.of(context)!.settings.arguments as Tugas;
      return DetailTugasPage(tugas: tugas);
    },
  };
}
