import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// Widget header kustom untuk menjaga konsistensi tampilan antar halaman
class CustomPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Widget? action;

  const CustomPageHeader({
    super.key,
    this.title = 'Kembali',
    this.onBackPressed,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Padding dikurangi agar tinggi header lebih standar dan rapi
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(color: AppTheme.primaryColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
