import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

export '../theme/app_theme.dart';
export '../theme/color_seed.dart';

const String _kThemeColorKey = 'theme_seed_color';

/// Tema durumu.
class ThemeState {
  const ThemeState({required this.seedColor});

  final Color seedColor;

  ThemeData get lightTheme => AppTheme.light(seedColor: seedColor);

  ThemeState copyWith({Color? seedColor}) =>
      ThemeState(seedColor: seedColor ?? this.seedColor);
}

/// SharedPreferences erişimi için provider.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override this in main.dart');
});

/// Tema notifier — seçili rengi okur/yazar.
class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final hex = prefs.getString(_kThemeColorKey);
    final color = hex != null
        ? ColorSeed.fromHex(hex)
        : appColorSeeds.first.color;
    return ThemeState(seedColor: color);
  }

  /// Rengi değiştirir ve kalıcı kaydeder.
  Future<void> setSeedColor(Color color) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final hex = ColorSeed('', color).toHex();
    await prefs.setString(_kThemeColorKey, hex);
    state = state.copyWith(seedColor: color);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
