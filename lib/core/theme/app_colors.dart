import 'package:flutter/material.dart';

/// Uygulama renk paleti — dinamik olmayan sabit renkler burada,
/// dinamik primary renk ThemeData.colorScheme üzerinden kullanılır.
class AppColors {
  AppColors._();

  // Yüzeyler
  static const Color background = Color(0xFFF5F7F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF2F4);
  static const Color sidebarBg = Color(0xFFFCFDFD);
  static const Color hover = Color(0xFFEDF1F3);

  // Çizgiler
  static const Color border = Color(0xFFE4E9EC);
  static const Color borderStrong = Color(0xFFCFD9DE);

  // Metin
  static const Color textPrimary = Color(0xFF1C2B33);
  static const Color textSecondary = Color(0xFF5B6E7A);
  static const Color textMuted = Color(0xFF8C9BA5);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Durum renkleri (sabit)
  static const Color success = Color(0xFF2E7D5B);
  static const Color warning = Color(0xFF96701F);
  static const Color danger = Color(0xFFB0553F);

  static const Color transparent = Color(0x00000000);
}
