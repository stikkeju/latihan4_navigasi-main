import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// Widget ini saya buat untuk menampilkan tombol filter yang bisa dipilih
class FilterButton extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  // Konstruktor untuk menerima data dan callback fungsi
  const FilterButton({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Menentukan apakah tombol ini sedang aktif berdasarkan nilainya
    final isSelected = groupValue == value;

    // Mendeteksi ketukan pengguna untuk mengganti filter
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        // Memberikan padding agar teks tidak terlalu mepet
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        // Mengatur gaya visual tombol, berbeda jika aktif atau tidak
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border.all(color: Colors.grey.withOpacity(0.3)),
          // Memberikan bayangan hanya jika tombol aktif
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        // Menampilkan label tombol dengan warna yang sesuai status
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}
