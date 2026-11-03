import 'package:flutter/material.dart';

/// Uygulamada seçilebilen bir tema rengi.
class ColorSeed {
  const ColorSeed(this.label, this.color);

  final String label;
  final Color color;

  /// Rengi hex string'e çevirir (SharedPrefs'e kayıt için).
  String toHex() =>
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

  static Color fromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse(cleaned, radix: 16));
  }
}

/// Uygulamada seçilebilecek tema renkleri.
const List<ColorSeed> appColorSeeds = [
  ColorSeed('Okyanus', Color(0xFF35657F)), // varsayılan
  ColorSeed('Orman', Color(0xFF2E7D5B)),
  ColorSeed('Mor', Color(0xFF6A4C9C)),
  ColorSeed('Tuğla', Color(0xFF8B4513)),
  ColorSeed('Çelik', Color(0xFF4A6572)),
  ColorSeed('Gece Mavisi', Color(0xFF1A3A5C)),
  ColorSeed('Vişne', Color(0xFF8B1A4A)),
  ColorSeed('Zeytun', Color(0xFF556B2F)),
  ColorSeed('Bakır', Color(0xFF7C4A1E)),
  ColorSeed('Koyu Gri', Color(0xFF424242)),
  ColorSeed('İndigo', Color(0xFF3949AB)),
  ColorSeed('Kahve', Color(0xFF5D4037)),
];
