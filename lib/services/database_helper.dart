import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/data_models.dart';

// Kelas helper untuk mengelola database lokal SQLite secara singleton
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter untuk mengakses objek database, menginisialisasi jika belum ada
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  // Membuka koneksi database di path lokal
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1, // Set version to 1 as requested
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  // Mengaktifkan fitur foreign key constraint di SQLite
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Membuat tabel-tabel yang diperlukan saat database pertama kali dibuat
  Future<void> _createDB(Database db, int version) async {
    // 1. Users Table
    await db.execute('''
      -- Tabel Users untuk menyimpan data profil pengguna
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nim TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        nama TEXT NOT NULL,
        jurusan TEXT,
        semester INTEGER,
        email TEXT,
        photo_url TEXT
      )
    ''');

    // 2. Mata Kuliah Table
    await db.execute('''
      CREATE TABLE mata_kuliah (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_mk TEXT NOT NULL UNIQUE,
        sks INTEGER DEFAULT 0,
        dosen TEXT,
        deskripsi TEXT
      )
    ''');

    // 3. Jadwal Table
    // Modified schema to include 'tanggal' to match current App feature usage (Schedules on specific dates)
    await db.execute('''
      -- Tabel Jadwal Kuliah dengan referensi ke Mata Kuliah
      CREATE TABLE jadwal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mk_id INTEGER NOT NULL,
        hari TEXT,
        tanggal TEXT, -- Storing date string "YYYY-MM-DD"
        jam_mulai TEXT,
        jam_selesai TEXT,
        ruangan TEXT,
        jenis TEXT,
        FOREIGN KEY (mk_id) REFERENCES mata_kuliah (id) ON DELETE CASCADE
      )
    ''');

    // 4. Tugas Table
    await db.execute('''
      -- Tabel Tugas dengan deadline dan status pengerjaan
      CREATE TABLE tugas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mk_id INTEGER,
        deskripsi TEXT NOT NULL,
        deadline TEXT, -- ISO8601 String
        waktu_jam INTEGER,
        waktu_menit INTEGER,
        is_selesai INTEGER DEFAULT 0,
        priority TEXT DEFAULT 'sedang',
        is_reminder_active INTEGER DEFAULT 0,
        created_at TEXT,
        completed_at TEXT,
        FOREIGN KEY (mk_id) REFERENCES mata_kuliah (id) ON DELETE CASCADE
      )
    ''');

    // 5. Notifications Table
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        created_at TEXT,
        related_id INTEGER
      )
    ''');
  }

  // --- CRUD Operations ---

  // User
  // Mendaftarkan user baru ke database
  Future<int> registerUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  // Mencari user berdasarkan NIM dan password untuk proses login
  Future<User?> loginUser(String nim, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'nim = ? AND password = ?',
      whereArgs: [nim, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Mata Kuliah
  Future<int> insertMataKuliah(MataKuliah mk) async {
    final db = await instance.database;
    return await db.insert('mata_kuliah', mk.toMap());
  }

  // Mengambil semua data mata kuliah
  Future<List<MataKuliah>> getMataKuliahList() async {
    final db = await instance.database;
    final maps = await db.query('mata_kuliah');
    return maps.map((e) => MataKuliah.fromMap(e)).toList();
  }

  Future<int> updateMataKuliah(MataKuliah mk) async {
    final db = await instance.database;
    return await db.update(
      'mata_kuliah',
      mk.toMap(),
      where: 'id = ?',
      whereArgs: [mk.id],
    );
  }

  Future<int> deleteMataKuliah(int id) async {
    final db = await instance.database;
    return await db.delete(
      'mata_kuliah',
      where: 'id = ?',
      whereArgs: [
        id,
      ], // Cascade should handle children, but must be enabled in SQLite config
      // Note: By default foreign key constraints are disabled in SQLite.
      // We might need 'PRAGMA foreign_keys = ON;' in onConfigure.
    );
  }

  // Jadwal
  Future<int> insertJadwal(Jadwal jadwal) async {
    final db = await instance.database;
    return await db.insert('jadwal', jadwal.toMap());
  }

  // Mengambil data jadwal beserta nama mata kuliahnya (Join)
  Future<List<Jadwal>> getJadwalList() async {
    final db = await instance.database;
    // Join with mata_kuliah to get names
    final result = await db.rawQuery('''
      SELECT jadwal.*, mata_kuliah.nama_mk 
      FROM jadwal
      INNER JOIN mata_kuliah ON jadwal.mk_id = mata_kuliah.id
    ''');

    return result.map((e) {
      final map = Map<String, dynamic>.from(e);
      final mkName = map['nama_mk'] as String;
      return Jadwal.fromMap(map, mkName);
    }).toList();
  }

  Future<int> updateJadwal(Jadwal jadwal) async {
    final db = await instance.database;
    return await db.update(
      'jadwal',
      jadwal.toMap(),
      where: 'id = ?',
      whereArgs: [jadwal.id],
    );
  }

  Future<int> deleteJadwal(int id) async {
    final db = await instance.database;
    return await db.delete('jadwal', where: 'id = ?', whereArgs: [id]);
  }

  // Tugas
  Future<int> insertTugas(Tugas tugas) async {
    final db = await instance.database;
    return await db.insert('tugas', tugas.toMap());
  }

  // Mengambil daftar tugas, dijoin dengan mata kuliah jika ada
  Future<List<Tugas>> getTugasList() async {
    final db = await instance.database;
    // Join with mata_kuliah (Left join in case mk_id is null)
    final result = await db.rawQuery('''
      SELECT tugas.*, mata_kuliah.nama_mk 
      FROM tugas
      LEFT JOIN mata_kuliah ON tugas.mk_id = mata_kuliah.id
    ''');

    return result.map((e) {
      final map = Map<String, dynamic>.from(e);
      final mkName = map['nama_mk'] as String?;
      return Tugas.fromMap(map, mkName);
    }).toList();
  }

  Future<int> updateTugas(Tugas tugas) async {
    final db = await instance.database;
    return await db.update(
      'tugas',
      tugas.toMap(),
      where: 'id = ?',
      whereArgs: [tugas.id],
    );
  }

  Future<int> deleteTugas(int id) async {
    final db = await instance.database;
    return await db.delete('tugas', where: 'id = ?', whereArgs: [id]);
  }

  // Mengubah status selesai/belum selesai suatu tugas
  Future<int> toggleStatusTugas(int id, bool isSelesai) async {
    final db = await instance.database;
    return await db.update(
      'tugas',
      // We might want to set completed_at here too if done
      {
        'is_selesai': isSelesai ? 1 : 0,
        'completed_at': isSelesai ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Notifications
  Future<int> insertNotification(Notification notification) async {
    final db = await instance.database;
    return await db.insert('notifications', notification.toMap());
  }

  Future<List<Notification>> getNotifications() async {
    final db = await instance.database;
    final result = await db.query('notifications', orderBy: 'created_at DESC');
    return result.map((e) => Notification.fromMap(e)).toList();
  }

  Future<int> markNotificationAsRead(int id) async {
    final db = await instance.database;
    return await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markAllNotificationsAsRead() async {
    final db = await instance.database;
    return await db.update('notifications', {'is_read': 1});
  }

  Future<int> clearAllNotifications() async {
    final db = await instance.database;
    return await db.delete('notifications');
  }

  Future<int> clearFutureNotifications() async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    return await db.delete(
      'notifications',
      where: 'created_at > ?',
      whereArgs: [now],
    );
  }
}
