import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app/rehberlik_app.dart';
import 'core/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Windows/Linux/macOS için sqflite FFI başlat.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // SharedPreferences (tema + son dosyalar) uygulama başlamadan hazırlanır.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // SharedPreferences örneğini enjekte ediyoruz.
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const RehberlikApp(),
    ),
  );
}
