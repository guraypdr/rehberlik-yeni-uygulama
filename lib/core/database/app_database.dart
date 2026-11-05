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

  static const int _currentVersion = 3;

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
    _createCoreTables(batch);
    _createStudentsTable(batch);
    _createInterviewsTable(batch);
    await batch.commit(noResult: true);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    debugPrint('DB upgrade: $oldVersion → $newVersion');
    if (oldVersion < 2) {
      // V1'den V2'ye geçiş: students tablosunu genişlet, student_interviews tablosunu ekle
      try {
        await db.execute('ALTER TABLE students RENAME TO _students_old');
        final batch = db.batch();
        _createStudentsTable(batch);
        _createInterviewsTable(batch);
        await batch.commit(noResult: true);

        await db.execute('''
          INSERT INTO students (
            id, class_id, number, name, surname, tc_no, general_notes, created_at
          )
          SELECT id, class_id, CAST(no AS TEXT), name, surname, tc_no, notes, datetime('now', 'localtime')
          FROM _students_old
        ''');
        await db.execute('DROP TABLE _students_old');
      } catch (e) {
        debugPrint('Migration error or fresh table needed: $e');
        final batch = db.batch();
        _createStudentsTable(batch);
        _createInterviewsTable(batch);
        await batch.commit(noResult: true);
      }
    }
    if (oldVersion >= 2 && oldVersion < 3) {
      await db.execute(
        "ALTER TABLE students ADD COLUMN boarding_status TEXT NOT NULL DEFAULT 'Gündüzlü'",
      );
    }
  }

  static void _createCoreTables(Batch batch) {
    // Okul profili — tek satır, id=1 zorunludur.
    batch.execute('''
      CREATE TABLE IF NOT EXISTS school_profile (
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
      CREATE TABLE IF NOT EXISTS grade_levels (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        label      TEXT    NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');

    // Şubeler
    batch.execute('''
      CREATE TABLE IF NOT EXISTS classes (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        grade_level_id INTEGER NOT NULL REFERENCES grade_levels(id) ON DELETE CASCADE,
        branch         TEXT    NOT NULL,
        field_name     TEXT,
        teacher_id     INTEGER REFERENCES teachers(id) ON DELETE SET NULL
      )
    ''');

    // Öğretmenler
    batch.execute('''
      CREATE TABLE IF NOT EXISTS teachers (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT NOT NULL,
        surname  TEXT NOT NULL,
        branch   TEXT
      )
    ''');

    // Yapılacaklar
    batch.execute('''
      CREATE TABLE IF NOT EXISTS todos (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        title        TEXT    NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at   TEXT    NOT NULL
      )
    ''');
  }

  static void _createStudentsTable(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS students (
        id                         INTEGER PRIMARY KEY AUTOINCREMENT,
        class_id                   INTEGER NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
        number                     TEXT    NOT NULL,
        name                       TEXT    NOT NULL,
        surname                    TEXT    NOT NULL,
        gender                     TEXT    NOT NULL DEFAULT 'Erkek',
        boarding_status            TEXT    NOT NULL DEFAULT 'Gündüzlü',
        tc_no                      TEXT,
        birth_date                 TEXT,
        photo_path                 TEXT,
        enrollment_date            TEXT,
        status                     TEXT    NOT NULL DEFAULT 'Aktif',
        transfer_school            TEXT,
        transfer_grade             TEXT,
        has_repeated_grade         INTEGER NOT NULL DEFAULT 0,
        repeat_reason              TEXT,
        special_status             TEXT,

        -- Aile ve Veli Bilgileri
        mother_name                TEXT,
        mother_surname             TEXT,
        mother_is_biological       INTEGER NOT NULL DEFAULT 1,
        mother_is_alive            INTEGER NOT NULL DEFAULT 1,
        mother_job                 TEXT,
        mother_phone               TEXT,
        mother_address             TEXT,
        mother_has_disability      INTEGER NOT NULL DEFAULT 0,
        mother_disability_details  TEXT,

        father_name                TEXT,
        father_surname             TEXT,
        father_is_biological       INTEGER NOT NULL DEFAULT 1,
        father_is_alive            INTEGER NOT NULL DEFAULT 1,
        father_job                 TEXT,
        father_phone               TEXT,
        father_address             TEXT,
        father_has_disability      INTEGER NOT NULL DEFAULT 0,
        father_disability_details  TEXT,

        parents_together           TEXT    NOT NULL DEFAULT 'Birlikte',
        lives_with                 TEXT    NOT NULL DEFAULT 'Anne-Baba',
        guardian_type              TEXT    NOT NULL DEFAULT 'Anne-Baba',
        guardian_name              TEXT,
        guardian_phone             TEXT,
        sibling_count              INTEGER NOT NULL DEFAULT 0,
        sibling_details            TEXT,
        household_members          TEXT,
        family_notes               TEXT,
        family_risk_level          TEXT    NOT NULL DEFAULT 'Düşük',

        -- Sağlık Durumu Bilgileri
        has_chronic_illness        INTEGER NOT NULL DEFAULT 0,
        chronic_illness_details    TEXT,
        uses_regular_medication    INTEGER NOT NULL DEFAULT 0,
        medication_details         TEXT,
        has_psychological_history  INTEGER NOT NULL DEFAULT 0,
        psychological_details      TEXT,

        general_notes              TEXT,
        created_at                 TEXT    NOT NULL
      )
    ''');
  }

  static void _createInterviewsTable(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS student_interviews (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id  INTEGER NOT NULL REFERENCES students(id) ON DELETE CASCADE,
        type        TEXT    NOT NULL, -- 'student', 'parent', 'teacher'
        date        TEXT    NOT NULL,
        subject     TEXT    NOT NULL,
        notes       TEXT    NOT NULL,
        action_plan TEXT,
        created_at  TEXT    NOT NULL
      )
    ''');
  }
}
