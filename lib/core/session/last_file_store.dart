import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences üzerinde "son açılan dosyalar" listesini yönetir.
///
/// Maksimum [maxFiles] adet dosya yolu saklanır; en son açılan en başa gelir.
class LastFileStore {
  LastFileStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'recent_files';
  static const int maxFiles = 5;

  /// Son açılan dosyaların yollarını döner (en yeni önce).
  List<String> getRecentFiles() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return List<String>.from(decoded.whereType<String>());
  }

  /// Verilen yolu listenin başına ekler; varsa önce çıkarır, sonra ekler.
  Future<void> pushFile(String path) async {
    final list = getRecentFiles().toList();
    list.remove(path);
    list.insert(0, path);
    final trimmed = list.take(maxFiles).toList();
    await _prefs.setString(_key, jsonEncode(trimmed));
  }

  /// Listeden bir yolu kaldırır (dosya silindiğinde).
  Future<void> removeFile(String path) async {
    final list = getRecentFiles().toList()..remove(path);
    await _prefs.setString(_key, jsonEncode(list));
  }

  /// En son açılan dosyanın yolunu döner; yoksa null.
  String? get lastFile {
    final list = getRecentFiles();
    return list.isEmpty ? null : list.first;
  }
}
