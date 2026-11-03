import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// SQLite veritabanı bağlantısı ve migration yönetimi.
///
/// Her `.rdb` dosyası tek bir [AppDatabase] örneğiyle temsil edilir.
/// Farklı bir dosya açıldığında eski örnek kapatılır, yenisi oluşturulur.
class AppDatabase {
  AppDatabase._({required Database db}) : _db = db;

  final Database _db;

  /// Veritabanı bağlantısına doğrudan erişim (DAO'lar için).
  Database get db => _db;

  static const int _currentVersion = 1;

  /// Verilen dosya yolunda veritabanını açar; yoksa oluşturur.
  static Future<AppDatabase> open(String path) async {
    final db = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _currentVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      ),
    );
    return AppDatabase._(db: db);
  }

  /// Bağlantıyı kapatır.
  Future<void> close() async {
    await _db.close();
  }

  // ---------------------------------------------------------------------------
  // Migration'lar
  // ---------------------------------------------------------------------------

  static Future<void> _onConfigure(Database db) async {
    // Yabancı anahtar kısıtlamalarını aktif et.
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    _createV1Tables(batch);
    await batch.commit(noResult: true);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // İleride yeni sütun/tablo eklendiğinde buraya migration adımları gelir.
    // Örnek: if (oldVersion < 2) { await db.execute('ALTER TABLE ...'); }
    debugPrint('DB upgrade: $oldVersion → $newVersion');
  }

  static void _createV1Tables(Batch batch) {
    // Okul profili — tek satır, id=1 zorunludur.
    batch.execute('''
      CREATE TABLE school_profile (
        id           INTEGER PRIMARY KEY CHECK (id = 1),
        name         TEXT    NOT NULL,
        school_type  TEXT    NOT NULL,
        has_prep     INTEGER NOT NULL DEFAULT 0,
        fields       TEXT,
        created_at   TEXT    NOT NULL
      )
    ''');

    // Sınıf düzeyleri (9. Sınıf, Hazırlık vb.)
    batch.execute('''
      CREATE TABLE grade_levels (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        label      TEXT    NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');

    // Şubeler
    batch.execute('''
      CREATE TABLE classes (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        grade_level_id INTEGER NOT NULL REFERENCES grade_levels(id) ON DELETE CASCADE,
        branch         TEXT    NOT NULL,
        field_name     TEXT,
        teacher_id     INTEGER REFERENCES teachers(id) ON DELETE SET NULL
      )
    ''');

    // Öğretmenler
    batch.execute('''
      CREATE TABLE teachers (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT NOT NULL,
        surname  TEXT NOT NULL,
        branch   TEXT
      )
    ''');

    // Öğrenciler (ileriki aşama için hazır)
    batch.execute('''
      CREATE TABLE students (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        class_id  INTEGER NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
        no        INTEGER NOT NULL,
        name      TEXT    NOT NULL,
        surname   TEXT    NOT NULL,
        tc_no     TEXT,
        notes     TEXT
      )
    ''');

    // Yapılacaklar
    batch.execute('''
      CREATE TABLE todos (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        title        TEXT    NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at   TEXT    NOT NULL
      )
    ''');
  }
}
