import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Kelas ini mengatur tema aplikasi secara global agar konsisten
class AppTheme {
  // Definisi warna-warna utama aplikasi
  static const Color primaryColor = Color(0xFF303F9F);
  static const Color secondaryColor = Color(0xFF9BB6F7);
  static const Color scaffoldBackgroundColor = Colors.white;

  // Mengembalikan konfigurasi tema terang (light theme)
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      brightness: Brightness.light,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      // Pengaturan font default menggunakan JetBrains Mono
      fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
      textTheme: GoogleFonts.jetBrainsMonoTextTheme(),
      // Kustomisasi tampilan AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
        prefixIconColor: primaryColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      // Pengaturan khusus untuk TimePicker agar sesuai desain
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        hourMinuteShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: Colors.grey, width: 0.5), // Default border
        ),
        dayPeriodBorderSide: const BorderSide(color: Colors.grey, width: 0.5),
        dayPeriodColor: MaterialStateColor.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? primaryColor.withOpacity(0.2)
              : Colors.transparent,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        hourMinuteColor: MaterialStateColor.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? primaryColor.withOpacity(0.1)
              : Colors.grey.shade100,
        ),
        hourMinuteTextColor: MaterialStateColor.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? primaryColor
              : Colors.black,
        ),
        dialHandColor: primaryColor,
        dialBackgroundColor: Colors.grey.shade100,
        hourMinuteTextStyle: const TextStyle(
          fontSize: 30, // Reduce font size slightly if needed, default is large
          fontWeight: FontWeight.bold,
        ),
        dayPeriodTextStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        helpTextStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}
