# Aplikasi Pengingat Jadwal Kuliah

Aplikasi Flutter sederhana untuk manajemen jadwal kuliah dan tugas. Ini adalah versi pengembangan (v1.1) yang sudah dilengkapi dengan fitur notifikasi lokal.

## Fitur
*   **Jadwal Kuliah**: Catat jadwal mata kuliah, ruang, dan waktu.
*   **Manajemen Tugas**: To-do list dengan prioritas dan deadline.
*   **Notifikasi**: Pengingat otomatis sebelum jadwal dimulai (Local Notification).
*   **History**: Riwayat notifikasi yang terlewat.

## Tech Stack
*   **Framework**: Flutter
*   **Local DB**: SQLite (`sqflite`)
*   **State**: Provider
*   **Notif**: Flutter Local Notifications

## Struktur Folder
```
lib/
├── models/         # Data Class (Jadwal, Tugas, Notification)
├── providers/      # State Management (UserProvider, NotificationProvider)
├── screens/        # Halaman Utama (Clean UI)
├── services/       # Logika Bisnis (DatabaseHelper, NotificationHelper)
├── utils/          # Konstanta & Tema (AppTheme, AppRoutes)
├── widgets/        # Komponen UI Reusable (Card, Header, Input)
└── main.dart       # Entry Point
```

## Cara Menjalankan Aplikasi
1.  **Clone Repository**
    ```bash
    git clone https://github.com/username/latihan4_navigasi-main.git
    ```
2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```
3.  **Run Application**
    Pastikan emulator atau device terhubung.
    ```bash
    flutter run
    ```

---
