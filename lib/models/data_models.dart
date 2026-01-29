import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class User {
  // Model ini saya gunakan untuk menyimpan data pengguna yang login
  int? id;
  String nim;
  String password;
  String nama;
  String? jurusan;
  int? semester;
  String? email;
  String? photoUrl;

  User({
    this.id,
    required this.nim,
    required this.password,
    required this.nama,
    this.jurusan,
    this.semester,
    this.email,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nim': nim,
      'password': password,
      'nama': nama,
      'jurusan': jurusan,
      'semester': semester,
      'email': email,
      'photo_url': photoUrl,
    };
  }

  // Factory method untuk membuat objek User dari Map database
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nim: map['nim'],
      password: map['password'],
      nama: map['nama'],
      jurusan: map['jurusan'],
      semester: map['semester'],
      email: map['email'],
      photoUrl: map['photo_url'],
    );
  }
}

// Model untuk merepresentasikan mata kuliah
class MataKuliah {
  int? id;
  String nama;
  int sks;
  String dosen;
  String? deskripsi;

  MataKuliah({
    this.id,
    required this.nama,
    this.sks = 0,
    this.dosen = '',
    this.deskripsi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_mk': nama,
      'sks': sks,
      'dosen': dosen,
      'deskripsi': deskripsi,
    };
  }

  // Mengubah Map menjadi objek MataKuliah
  factory MataKuliah.fromMap(Map<String, dynamic> map) {
    return MataKuliah(
      id: map['id'],
      nama: map['nama_mk'],
      sks: map['sks'] ?? 0,
      dosen: map['dosen'] ?? '',
      deskripsi: map['deskripsi'],
    );
  }
}

// Model untuk data jadwal kuliah per hari
class Jadwal {
  int? id;
  int mkId; // ID mata kuliah terkait
  String mataKuliah; // Nama mata kuliah untuk tampilan UI
  String? hari;
  String? tanggal;
  String jamMulai;
  String jamSelesai;
  String ruangan;
  String? jenis; // e.g., 'Kuliah', 'Praktikum'

  Jadwal({
    this.id,
    required this.mkId,
    required this.mataKuliah,
    this.hari,
    this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangan,
    this.jenis,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mk_id': mkId,
      'hari': hari,
      'tanggal': tanggal,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'ruangan': ruangan,
      'jenis': jenis,
    };
  }

  factory Jadwal.fromMap(Map<String, dynamic> map, String mkName) {
    return Jadwal(
      id: map['id'],
      mkId: map['mk_id'],
      mataKuliah: mkName,
      hari: map['hari'],
      tanggal: map['tanggal'],
      jamMulai: map['jam_mulai'] ?? '',
      jamSelesai: map['jam_selesai'] ?? '',
      ruangan: map['ruangan'] ?? '',
      jenis: map['jenis'],
    );
  }
}

// Model untuk mencatat tugas-tugas kuliah
class Tugas {
  int? id;
  int? mkId;
  String? mataKuliah; // Nama mata kuliah untuk tampilan UI
  String deskripsi;
  DateTime? tanggal;
  TimeOfDay? waktu;
  bool selesai;
  String priority;
  bool isReminderActive; // Renamed from isReminder
  DateTime? createdAt;
  DateTime? completedAt;

  Tugas({
    this.id,
    this.mkId,
    this.mataKuliah,
    required this.deskripsi,
    this.tanggal,
    this.waktu,
    this.selesai = false,
    this.priority = 'sedang',
    this.isReminderActive = false,
    this.createdAt,
    this.completedAt,
  }) {
    createdAt ??= DateTime.now();
  }

  // Getter untuk memformat deadline menjadi string yang mudah dibaca
  String get deadline {
    if (tanggal == null) return '-';
    // Use standard format
    final dateStr = DateFormat('dd MMM yyyy', 'id_ID').format(tanggal!);
    final timeStr = waktu != null
        ? " ${waktu!.hour.toString().padLeft(2, '0')}:${waktu!.minute.toString().padLeft(2, '0')}"
        : "";
    return "$dateStr$timeStr";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mk_id': mkId,
      'deskripsi': deskripsi,
      'deadline': tanggal
          ?.toIso8601String(), // Saving strictly date part if adhering to old, but better save generic
      'waktu_jam': waktu?.hour,
      'waktu_menit': waktu?.minute,
      'is_selesai': selesai ? 1 : 0,
      'priority': priority,
      'is_reminder_active': isReminderActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  // Membuat objek Tugas dari Map, menangani parsing tanggal dan waktu
  factory Tugas.fromMap(Map<String, dynamic> map, String? mkName) {
    DateTime? tgl;
    TimeOfDay? wkt;

    if (map['deadline'] != null) {
      try {
        tgl = DateTime.parse(map['deadline']);
      } catch (e) {}
    }

    if (map['waktu_jam'] != null && map['waktu_menit'] != null) {
      wkt = TimeOfDay(hour: map['waktu_jam'], minute: map['waktu_menit']);
    } else if (tgl != null) {
      // Fallback if we stored full date-time in deadline
      wkt = TimeOfDay.fromDateTime(tgl);
    }

    return Tugas(
      id: map['id'],
      mkId: map['mk_id'],
      mataKuliah: mkName,
      deskripsi: map['deskripsi'],
      tanggal: tgl,
      waktu: wkt,
      selesai: (map['is_selesai'] ?? 0) == 1,
      priority: map['priority'] ?? 'sedang',
      isReminderActive: (map['is_reminder_active'] ?? 0) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
    );
  }
}

// Enum untuk jenis-jenis notifikasi
enum NotificationType {
  assignment,
  classStarting,
  taskCompleted,
  courseMaterial,
  quiz,
}

// Model untuk notifikasi aplikasi
class Notification {
  int? id;
  String title;
  String message;
  NotificationType type;
  bool isRead;
  DateTime createdAt;
  int? relatedId; // e.g. taskId or jadwaId

  Notification({
    this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.relatedId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'related_id': relatedId,
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      type: _parseType(map['type']),
      isRead: (map['is_read'] ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at']),
      relatedId: map['related_id'],
    );
  }

  static NotificationType _parseType(String typeStr) {
    return NotificationType.values.firstWhere(
      (e) => e.toString() == typeStr,
      orElse: () => NotificationType.assignment,
    );
  }
}
