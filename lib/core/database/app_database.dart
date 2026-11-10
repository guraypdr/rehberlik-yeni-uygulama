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

  static const int _currentVersion = 10;

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
    _createStudentInfoFormsTable(batch);
    _createClassRiskResponsesTable(batch);
    _createClassRiskMapStatusTable(batch);
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
            id, class_id, number, name, surname, created_at
          )
          SELECT id, class_id, CAST(no AS TEXT), name, surname, datetime('now', 'localtime')
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
    if (oldVersion >= 2 && oldVersion < 4) {
      await db.execute('ALTER TABLE students ADD COLUMN birth_place TEXT');
      await db.execute('ALTER TABLE students ADD COLUMN address TEXT');
      await db.execute(
        'ALTER TABLE students ADD COLUMN preschool_education TEXT',
      );
    }
    if (oldVersion >= 2 && oldVersion < 5) {
      for (final column in [
        'likes_activities',
        'recent_trauma',
        'move_or_school_change',
        'extracurricular_activities',
        'technology_devices',
        'technology_usage',
        'influential_event',
        'influential_event_details',
        'mother_birth_place',
        'mother_birth_date',
        'mother_education',
        'father_birth_place',
        'father_birth_date',
        'father_education',
        'sibling_order',
        'child_order',
        'household_chronic_illness',
      ]) {
        await db.execute('ALTER TABLE students ADD COLUMN $column TEXT');
      }
    }
    if (oldVersion < 6) {
      await _migrateStudentInfoForms(db);
    }
    if (oldVersion < 7) {
      final batch = db.batch();
      _createClassRiskResponsesTable(batch);
      await batch.commit(noResult: true);
    }
    if (oldVersion < 8) {
      final batch = db.batch();
      _createClassRiskMapStatusTable(batch);
      await batch.commit(noResult: true);
    }
    if (oldVersion < 10) {
      await _migrateTeacherContactFields(db);
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
        branch   TEXT,
        email    TEXT,
        phone    TEXT
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
        created_at                 TEXT    NOT NULL
      )
    ''');
  }

  static void _createStudentInfoFormsTable(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS student_info_forms (
        student_id                         INTEGER PRIMARY KEY REFERENCES students(id) ON DELETE CASCADE,
        birth_place                        TEXT,
        birth_date                         TEXT,
        address                            TEXT,
        preschool_education                INTEGER,
        uses_regular_medication            INTEGER,
        medication_details                 TEXT,
        has_chronic_illness                INTEGER,
        chronic_illness_details            TEXT,
        likes_activities                   TEXT,
        has_recent_move_or_school_change   INTEGER,
        move_or_school_change_details      TEXT,
        extracurricular_activities         TEXT,
        has_technology_device              INTEGER,
        technology_usage_minutes           INTEGER,
        has_influential_event              INTEGER,
        influential_event_details          TEXT,
        mother_name                        TEXT,
        mother_surname                     TEXT,
        mother_birth_place                 TEXT,
        mother_birth_date                  TEXT,
        mother_is_alive                    INTEGER,
        mother_is_biological               INTEGER,
        mother_has_disability              INTEGER,
        mother_disability_details          TEXT,
        mother_education                   TEXT,
        mother_job                         TEXT,
        father_name                        TEXT,
        father_surname                     TEXT,
        father_birth_place                 TEXT,
        father_birth_date                  TEXT,
        father_is_alive                    INTEGER,
        father_is_biological               INTEGER,
        father_has_disability              INTEGER,
        father_disability_details          TEXT,
        father_education                   TEXT,
        father_job                         TEXT,
        sibling_count                      INTEGER,
        child_order                        INTEGER,
        family_has_chronic_illness         INTEGER,
        household_chronic_illness_details  TEXT,
        household_members                  TEXT
      )
    ''');
  }

  static void _createClassRiskResponsesTable(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS class_risk_responses (
        student_id  INTEGER NOT NULL REFERENCES students(id) ON DELETE CASCADE,
        question_key TEXT NOT NULL,
        answer      INTEGER NOT NULL DEFAULT 0 CHECK (answer IN (0, 1)),
        updated_at  TEXT NOT NULL,
        PRIMARY KEY (student_id, question_key)
      )
    ''');
  }

  static void _createClassRiskMapStatusTable(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS class_risk_map_status (
        class_id INTEGER PRIMARY KEY REFERENCES classes(id) ON DELETE CASCADE,
        completed_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _migrateTeacherContactFields(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS teachers (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT NOT NULL,
        surname  TEXT NOT NULL,
        branch   TEXT,
        email    TEXT,
        phone    TEXT
      )
    ''');
    final columns = (await db.rawQuery(
      'PRAGMA table_info(teachers)',
    )).map((row) => row['name'] as String).toSet();
    if (!columns.contains('email')) {
      await db.execute('ALTER TABLE teachers ADD COLUMN email TEXT');
    }
    if (!columns.contains('phone')) {
      await db.execute('ALTER TABLE teachers ADD COLUMN phone TEXT');
    }
  }

  static Future<void> _migrateStudentInfoForms(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_info_forms (
        student_id                         INTEGER PRIMARY KEY REFERENCES students(id) ON DELETE CASCADE,
        birth_place                        TEXT,
        birth_date                         TEXT,
        address                            TEXT,
        preschool_education                INTEGER,
        uses_regular_medication            INTEGER,
        medication_details                 TEXT,
        has_chronic_illness                INTEGER,
        chronic_illness_details            TEXT,
        likes_activities                   TEXT,
        has_recent_move_or_school_change   INTEGER,
        move_or_school_change_details      TEXT,
        extracurricular_activities         TEXT,
        has_technology_device              INTEGER,
        technology_usage_minutes           INTEGER,
        has_influential_event              INTEGER,
        influential_event_details          TEXT,
        mother_name                        TEXT,
        mother_surname                     TEXT,
        mother_birth_place                 TEXT,
        mother_birth_date                  TEXT,
        mother_is_alive                    INTEGER,
        mother_is_biological               INTEGER,
        mother_has_disability              INTEGER,
        mother_disability_details          TEXT,
        mother_education                   TEXT,
        mother_job                         TEXT,
        father_name                        TEXT,
        father_surname                     TEXT,
        father_birth_place                 TEXT,
        father_birth_date                  TEXT,
        father_is_alive                    INTEGER,
        father_is_biological               INTEGER,
        father_has_disability              INTEGER,
        father_disability_details          TEXT,
        father_education                   TEXT,
        father_job                         TEXT,
        sibling_count                      INTEGER,
        child_order                        INTEGER,
        family_has_chronic_illness         INTEGER,
        household_chronic_illness_details  TEXT,
        household_members                  TEXT
      )
    ''');

    final columns = (await db.rawQuery(
      'PRAGMA table_info(students)',
    )).map((row) => row['name'] as String).toSet();
    final legacyRows = await db.query('students');
    final batch = db.batch();
    for (final row in legacyRows) {
      Object? value(String column) =>
          columns.contains(column) ? row[column] : null;
      final moveDetails = _legacyDetails(value('move_or_school_change'));
      final householdIllness = _legacyDetails(
        value('household_chronic_illness'),
      );
      final event = _legacyDetails(value('influential_event'));
      final minutes = _legacyUsageMinutes(value('technology_usage'));
      batch.insert('student_info_forms', {
        'student_id': row['id'],
        'birth_place': value('birth_place'),
        'birth_date': value('birth_date'),
        'address': value('address'),
        'preschool_education': _legacyBoolean(value('preschool_education')),
        'uses_regular_medication': _legacyBoolean(
          value('uses_regular_medication'),
        ),
        'medication_details': value('medication_details'),
        'has_chronic_illness': _legacyBoolean(value('has_chronic_illness')),
        'chronic_illness_details': value('chronic_illness_details'),
        'likes_activities': value('likes_activities'),
        'has_recent_move_or_school_change': _legacyPresence(
          value('move_or_school_change'),
        ),
        'move_or_school_change_details': moveDetails,
        'extracurricular_activities': value('extracurricular_activities'),
        'has_technology_device': _legacyPresence(value('technology_devices')),
        'technology_usage_minutes': minutes,
        'has_influential_event': _legacyPresence(
          value('influential_event_details') ?? value('influential_event'),
        ),
        'influential_event_details':
            value('influential_event_details') ?? event,
        'mother_name': value('mother_name'),
        'mother_surname': value('mother_surname'),
        'mother_birth_place': value('mother_birth_place'),
        'mother_birth_date': value('mother_birth_date'),
        'mother_is_alive': _legacyBoolean(value('mother_is_alive')),
        'mother_is_biological': _legacyBoolean(value('mother_is_biological')),
        'mother_has_disability': _legacyBoolean(value('mother_has_disability')),
        'mother_disability_details': value('mother_disability_details'),
        'mother_education': value('mother_education'),
        'mother_job': value('mother_job'),
        'father_name': value('father_name'),
        'father_surname': value('father_surname'),
        'father_birth_place': value('father_birth_place'),
        'father_birth_date': value('father_birth_date'),
        'father_is_alive': _legacyBoolean(value('father_is_alive')),
        'father_is_biological': _legacyBoolean(value('father_is_biological')),
        'father_has_disability': _legacyBoolean(value('father_has_disability')),
        'father_disability_details': value('father_disability_details'),
        'father_education': value('father_education'),
        'father_job': value('father_job'),
        'sibling_count': value('sibling_count'),
        'child_order': _legacyInteger(value('child_order')),
        'family_has_chronic_illness': _legacyPresence(
          value('household_chronic_illness'),
        ),
        'household_chronic_illness_details': householdIllness,
        'household_members': value('household_members'),
      });
    }
    await batch.commit(noResult: true);

    const retainedColumns = {
      'id',
      'class_id',
      'number',
      'name',
      'surname',
      'gender',
      'boarding_status',
      'created_at',
    };
    for (final column in columns.difference(retainedColumns)) {
      await db.execute('ALTER TABLE students DROP COLUMN $column');
    }
  }

  static int? _legacyBoolean(Object? value) {
    if (value == null) return null;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (const {'1', 'true', 'evet', 'var', 'yes'}.contains(normalized)) {
      return 1;
    }
    if (const {
      '0',
      'false',
      'hayır',
      'hayir',
      'yok',
      'bulunmuyor',
      'no',
    }.contains(normalized)) {
      return 0;
    }
    return normalized == '0.0' ? 0 : null;
  }

  static int? _legacyPresence(Object? value) =>
      _legacyBoolean(value) ?? (_legacyDetails(value) == null ? null : 1);

  static String? _legacyDetails(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty ||
        const {
          'yok',
          'hayır',
          'hayir',
          'bulunmuyor',
          'false',
          '0',
        }.contains(text.toLowerCase())) {
      return null;
    }
    return text;
  }

  static int? _legacyInteger(Object? value) {
    if (value == null) return null;
    return int.tryParse(value.toString().trim());
  }

  static int? _legacyUsageMinutes(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim().toLowerCase();
    if (text.isEmpty) return null;
    final hours = RegExp(r'(\d+)\s*saat').firstMatch(text);
    final minutes = RegExp(r'(\d+)\s*dakika').firstMatch(text);
    if (hours != null || minutes != null) {
      return (int.tryParse(hours?.group(1) ?? '0') ?? 0) * 60 +
          (int.tryParse(minutes?.group(1) ?? '0') ?? 0);
    }
    return int.tryParse(text);
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
