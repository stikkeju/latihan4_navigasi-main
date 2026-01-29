import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';
import '../services/database_helper.dart';

// Provider State Management utama untuk data pengguna, mata kuliah, jadwal, dan tugas
class UserProvider extends ChangeNotifier {
  User? _currentUser;
  List<MataKuliah> _mataKuliahList = [];
  List<Jadwal> _jadwalList = [];
  List<Tugas> _tugasList = [];

  User? get currentUser => _currentUser;
  List<MataKuliah> get mataKuliahList => _mataKuliahList;
  List<Jadwal> get jadwalList => _jadwalList;
  List<Tugas> get tugasList => _tugasList;

  // Derived getters for Dashboard
  int get totalTugas => _tugasList.length;
  int get tugasSelesai => _tugasList.where((t) => t.selesai).length;
  int get tugasBelumSelesai => totalTugas - tugasSelesai;
  // Menghitung progress penyelesaian tugas dalam persen
  double get progress =>
      totalTugas == 0 ? 0 : (tugasSelesai / totalTugas) * 100;

  // --- Auth Methods ---

  // Proses login user: verifikasi DB, simpan sesi, dan muat data
  Future<bool> login(String nim, String password) async {
    final user = await DatabaseHelper.instance.loginUser(nim, password);
    if (user != null) {
      _currentUser = user;

      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id!);

      await loadUserData();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> register(User user) async {
    await DatabaseHelper.instance.registerUser(user);
    // Auto-login after register? Or redirect to login?
    // Usually redirect to login.
  }

  // Logout: menghapus sesi lokal dan mereset state
  Future<void> logout() async {
    _currentUser = null;
    _mataKuliahList = [];
    _jadwalList = [];
    _tugasList = [];

    // Clear session
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    notifyListeners();
  }

  // Mengecek apakah user sudah login sebelumnya (persistent login)
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (maps.isNotEmpty) {
        _currentUser = User.fromMap(maps.first);
        await loadUserData();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> updateUser(User user) async {
    await DatabaseHelper.instance.updateUser(user);
    _currentUser = user; // Update local state immediately
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_currentUser != null && _currentUser!.id != null) {
      await DatabaseHelper.instance.deleteUser(_currentUser!.id!);
      await logout();
    }
  }

  // Memuat seluruh data user (Matkul, Jadwal, Tugas) dari database
  Future<void> loadUserData() async {
    if (_currentUser == null) return;
    _mataKuliahList = await DatabaseHelper.instance.getMataKuliahList();
    _jadwalList = await DatabaseHelper.instance.getJadwalList();
    _tugasList = await DatabaseHelper.instance.getTugasList();
    notifyListeners();
  }

  // --- Mata Kuliah Methods ---

  Future<void> addMataKuliah(MataKuliah mk) async {
    await DatabaseHelper.instance.insertMataKuliah(mk);
    await loadUserData(); // Refresh list
  }

  Future<void> updateMataKuliah(MataKuliah mk) async {
    // mk already has the correct ID (preserved in form)
    await DatabaseHelper.instance.updateMataKuliah(mk);
    await loadUserData();
  }

  Future<void> deleteMataKuliah(int id) async {
    await DatabaseHelper.instance.deleteMataKuliah(id);
    await loadUserData();
  }

  // --- Jadwal Methods ---

  // Menambahkan jadwal baru, otomatis mencari ID Mata Kuliah jika perlu
  Future<void> addJadwal(Jadwal jadwal) async {
    // Resolve mk_id if not present
    if (jadwal.mkId == 0) {
      try {
        final mk = _mataKuliahList.firstWhere(
          (m) => m.nama == jadwal.mataKuliah,
        );
        jadwal.mkId = mk.id!;
      } catch (e) {
        print("Error adding jadwal: MK not found");
        return; // Don't insert if MK invalid
      }
    }
    await DatabaseHelper.instance.insertJadwal(jadwal);
    await loadUserData();
  }

  Future<void> updateJadwal(int index, Jadwal jadwal) async {
    final oldJadwal = _jadwalList[index];
    jadwal.id = oldJadwal.id;

    if (jadwal.mkId == 0) {
      try {
        final mk = _mataKuliahList.firstWhere(
          (m) => m.nama == jadwal.mataKuliah,
        );
        jadwal.mkId = mk.id!;
      } catch (e) {
        print("Error updating jadwal: MK not found");
        return;
      }
    }
    await DatabaseHelper.instance.updateJadwal(jadwal);
    await loadUserData();
  }

  Future<void> deleteJadwal(int index) async {
    final jadwal = _jadwalList[index];
    if (jadwal.id != null) {
      await DatabaseHelper.instance.deleteJadwal(jadwal.id!);
      await loadUserData();
    }
  }

  // --- Tugas Methods ---

  // Menambahkan tugas baru dan menyimpannya di database
  Future<void> addTugas(Tugas tugas) async {
    // Resolve MK ID if exists
    if (tugas.mataKuliah != null && tugas.mataKuliah!.isNotEmpty) {
      try {
        final mk = _mataKuliahList.firstWhere(
          (m) => m.nama == tugas.mataKuliah,
        );
        tugas.mkId = mk.id;
      } catch (e) {
        tugas.mkId = null;
      }
    }
    await DatabaseHelper.instance.insertTugas(tugas);
    await loadUserData();
  }

  Future<void> updateTugas(int index, Tugas tugas) async {
    final oldTugas = _tugasList[index];
    tugas.id = oldTugas.id;
    // Resolve MK ID if exists
    if (tugas.mataKuliah != null && tugas.mataKuliah!.isNotEmpty) {
      try {
        final mk = _mataKuliahList.firstWhere(
          (m) => m.nama == tugas.mataKuliah,
        );
        tugas.mkId = mk.id;
      } catch (e) {
        tugas.mkId = null;
      }
    }
    await DatabaseHelper.instance.updateTugas(tugas);
    await loadUserData();
  }

  Future<void> toggleStatusTugas(int id, bool newStatus) async {
    await DatabaseHelper.instance.toggleStatusTugas(id, newStatus);
    await loadUserData();
  }

  Future<void> deleteTugas(int index) async {
    final tugas = _tugasList[index];
    if (tugas.id != null) {
      await DatabaseHelper.instance.deleteTugas(tugas.id!);
      await loadUserData();
    }
  }
}
