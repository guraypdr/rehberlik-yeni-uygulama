import 'package:flutter/material.dart';

/// Uygulamanın renk paleti.
///
/// Tüm renkler bu dosyada toplanır; widget'lar `Color(...)` değeri
/// tanımlamaz. Koyu tema eklendiğinde buraya karşılık gelen koyu değerler
/// tanımlanıp [AppTheme] içinden seçilir.
class AppColors {
  AppColors._();

  // Vurgu rengi: sakin, uzun süre bakılabilir bir mavi-gri tonu.
  static const Color primary = Color(0xFF35657F);
  static const Color primaryHover = Color(0xFF2A5065);

  /// Seçili menü öğesi ve vurgu yüzeyleri için açık ton.
  static const Color primarySoft = Color(0xFFE6EFF3);
  static const Color primaryBorder = Color(0xFFBED4DE);

  // Yüzeyler. İçerik alanı düz bırakılır, yalnızca yüzeyler ayrışır.
  static const Color background = Color(0xFFF5F7F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF2F4);
  static const Color sidebarBackground = Color(0xFFFCFDFD);
  static const Color hover = Color(0xFFEDF1F3);

  // Çizgiler.
  static const Color border = Color(0xFFE4E9EC);
  static const Color borderStrong = Color(0xFFCFD9DE);

  // Metin.
  static const Color textPrimary = Color(0xFF1C2B33);
  static const Color textSecondary = Color(0xFF5B6E7A);
  static const Color textMuted = Color(0xFF8C9BA5);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Durum renkleri. Uyarı ve hata tonları bilinçli olarak yumuşatıldı.
  static const Color success = Color(0xFF2E7D5B);
  static const Color warning = Color(0xFF96701F);
  static const Color danger = Color(0xFFB0553F);

  static const Color transparent = Color(0x00000000);
}
