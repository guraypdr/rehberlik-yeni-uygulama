import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rehberlik_app/core/database/app_database.dart';
import 'package:rehberlik_app/features/setup/data/school_profile_dao.dart';
import 'package:rehberlik_app/features/students/data/student_dao.dart';
import 'package:rehberlik_app/features/students/domain/student.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('v5 öğrenci kayıtlarını temel kayıt ve bilgi formuna ayırır', () async {
    final directory = await Directory.systemTemp.createTemp();
    final path = p.join(directory.path, 'legacy_students.db');
    AppDatabase? database;

    try {
      final legacyDatabase = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 5,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE grade_levels (
                id INTEGER PRIMARY KEY,
                label TEXT NOT NULL,
                sort_order INTEGER NOT NULL
              )
            ''');
            await db.insert('grade_levels', {
              'id': 1,
              'label': '9. Sınıf',
              'sort_order': 1,
            });
            await db.execute('''
              CREATE TABLE classes (
                id INTEGER PRIMARY KEY,
                grade_level_id INTEGER NOT NULL,
                branch TEXT NOT NULL
              )
            ''');
            await db.insert('classes', {
              'id': 7,
              'grade_level_id': 1,
              'branch': 'A',
            });
            await db.execute('''
              CREATE TABLE students (
                id INTEGER PRIMARY KEY,
                class_id INTEGER NOT NULL,
                number TEXT NOT NULL,
                name TEXT NOT NULL,
                surname TEXT NOT NULL,
                gender TEXT NOT NULL DEFAULT 'Erkek',
                boarding_status TEXT NOT NULL DEFAULT 'Gündüzlü',
                birth_place TEXT,
                birth_date TEXT,
                address TEXT,
                preschool_education TEXT,
                likes_activities TEXT,
                move_or_school_change TEXT,
                extracurricular_activities TEXT,
                technology_devices TEXT,
                technology_usage TEXT,
                influential_event TEXT,
                influential_event_details TEXT,
                mother_name TEXT,
                mother_surname TEXT,
                mother_birth_place TEXT,
                mother_birth_date TEXT,
                mother_is_alive INTEGER,
                mother_is_biological INTEGER,
                mother_has_disability INTEGER,
                mother_disability_details TEXT,
                mother_education TEXT,
                mother_job TEXT,
                father_name TEXT,
                father_surname TEXT,
                father_birth_place TEXT,
                father_birth_date TEXT,
                father_is_alive INTEGER,
                father_is_biological INTEGER,
                father_has_disability INTEGER,
                father_disability_details TEXT,
                father_education TEXT,
                father_job TEXT,
                sibling_count INTEGER,
                child_order TEXT,
                household_chronic_illness TEXT,
                household_members TEXT,
                tc_no TEXT,
                general_notes TEXT,
                created_at TEXT NOT NULL
              )
            ''');
            await db.insert('students', {
              'id': 1,
              'class_id': 7,
              'number': '101',
              'name': 'Ayşe',
              'surname': 'Kaya',
              'gender': 'Kız',
              'boarding_status': 'Yatılı',
              'birth_place': 'Ankara',
              'birth_date': '2010-01-02',
              'address': 'Çankaya',
              'preschool_education': 'Evet',
              'likes_activities': 'Kitap okumak',
              'move_or_school_change': '2025 yılında taşındı',
              'technology_devices': 'Tablet',
              'technology_usage': 'Günde 2 saat 15 dakika',
              'mother_name': 'Fatma',
              'mother_is_alive': 1,
              'mother_is_biological': 0,
              'sibling_count': 2,
              'child_order': '2',
              'household_chronic_illness': 'Astım',
              'household_members': 'Anne, baba ve çocuklar',
              'tc_no': 'silinmeli',
              'general_notes': 'silinmeli',
              'created_at': '2026-01-01',
            });
            await db.execute('''
              CREATE TABLE student_interviews (
                id INTEGER PRIMARY KEY,
                student_id INTEGER NOT NULL,
                type TEXT NOT NULL,
                date TEXT NOT NULL,
                subject TEXT NOT NULL,
                notes TEXT NOT NULL,
                action_plan TEXT,
                created_at TEXT NOT NULL
              )
            ''');
            await db.insert('student_interviews', {
              'id': 4,
              'student_id': 1,
              'type': 'student',
              'date': '2026-01-01',
              'subject': 'Uyum',
              'notes': 'Görüşme kaydı',
              'created_at': '2026-01-01',
            });
          },
        ),
      );
      await legacyDatabase.close();

      database = await AppDatabase.open(path);
      final students = await database.db.query('students');
      final forms = await database.db.query('student_info_forms');
      final columns = (await database.db.rawQuery(
        'PRAGMA table_info(students)',
      )).map((row) => row['name']).toSet();

      expect(students, hasLength(1));
      expect(students.single['boarding_status'], 'Yatılı');
      expect(students.single['number'], '101');
      expect(columns, {
        'id',
        'class_id',
        'number',
        'name',
        'surname',
        'gender',
        'boarding_status',
        'created_at',
      });
      expect(forms, hasLength(1));
      expect(forms.single['has_special_education'], 0);
      expect(forms.single['birth_place'], 'Ankara');
      expect(forms.single['preschool_education'], 1);
      expect(forms.single['has_recent_move_or_school_change'], 1);
      expect(
        forms.single['move_or_school_change_details'],
        '2025 yılında taşındı',
      );
      expect(forms.single['technology_usage_minutes'], 135);
      expect(forms.single['mother_is_biological'], 0);
      expect(forms.single['sibling_count'], 2);
      expect(forms.single['child_order'], 2);
      expect(forms.single['family_has_chronic_illness'], 1);
      expect(forms.single['household_chronic_illness_details'], 'Astım');
      expect(
        await database.db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'class_risk_responses'",
        ),
        hasLength(1),
      );
      expect(
        await database.db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'class_risk_map_status'",
        ),
        hasLength(1),
      );
      final teacherColumns = (await database.db.rawQuery(
        'PRAGMA table_info(teachers)',
      )).map((row) => row['name']).toSet();
      expect(teacherColumns, containsAll(['email', 'phone']));
      expect(await database.db.query('student_interviews'), hasLength(1));
      final dao = StudentDao(database);
      final student = await dao.getById(1);
      expect(student?.birthPlace, 'Ankara');
      expect(student?.preschoolEducation, isTrue);
      expect(student?.technologyUsageMinutes, 135);
      expect(student?.motherIsBiological, isFalse);

      await dao.update(
        Student(
          id: student!.id,
          classId: student.classId,
          number: student.number,
          name: student.name,
          surname: student.surname,
          gender: student.gender,
          boardingStatus: student.boardingStatus,
          createdAt: student.createdAt,
          birthPlace: 'İzmir',
        ),
      );
      expect((await dao.getById(1))?.birthPlace, 'İzmir');

      final added = await dao.insertBasic(
        classId: 7,
        number: '102',
        name: 'Mehmet',
        surname: 'Demir',
        gender: 'Erkek',
      );
      expect(added.fullName, 'Mehmet Demir');
    } finally {
      await database?.close();
      await directory.delete(recursive: true);
    }
  });

  test('v13 okul profiline psikolojik danışman alanlarını ekler', () async {
    final directory = await Directory.systemTemp.createTemp();
    final path = p.join(directory.path, 'school_profile_v13.db');
    final legacyDatabase = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 13,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE school_profile (
              id INTEGER PRIMARY KEY,
              name TEXT NOT NULL,
              school_type TEXT NOT NULL,
              has_prep INTEGER NOT NULL DEFAULT 0,
              fields TEXT,
              created_at TEXT NOT NULL
            )
          ''');
          await db.insert('school_profile', {
            'id': 1,
            'name': 'Ankara Anadolu Lisesi',
            'school_type': 'lise',
            'has_prep': 0,
            'created_at': '2026-01-01',
          });
        },
      ),
    );
    await legacyDatabase.close();

    final database = await AppDatabase.open(path);
    try {
      final rows = await database.db.query('school_profile');
      expect(rows, hasLength(1));
      expect(rows.single['name'], 'Ankara Anadolu Lisesi');
      expect(rows.single['counselor_name'], '');
      expect(rows.single['counselor_surname'], '');
      await database.db.update('school_profile', {
        'counselor_name': 'Ayşe',
        'counselor_surname': 'Yılmaz',
      }, where: 'id = 1');
      final profile = await SchoolProfileDao(database).fetchProfile();
      expect(profile?.counselorName, 'Ayşe');
      expect(profile?.counselorSurname, 'Yılmaz');
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });

  test(
    'v20 okul personeli tablosunu ve BEP personel katılımcılarını ekler',
    () async {
      final directory = await Directory.systemTemp.createTemp();
      final path = p.join(directory.path, 'school_staff_v20.db');
      final legacyDatabase = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 19,
          onCreate: (db, version) async {
            await db.execute('''
            CREATE TABLE school_profile (
              id INTEGER PRIMARY KEY,
              name TEXT NOT NULL,
              counselor_name TEXT NOT NULL DEFAULT '',
              counselor_surname TEXT NOT NULL DEFAULT '',
              school_type TEXT NOT NULL,
              has_prep INTEGER NOT NULL DEFAULT 0,
              fields TEXT,
              created_at TEXT NOT NULL
            )
          ''');
            await db.insert('school_profile', {
              'id': 1,
              'name': 'Ankara Anadolu Lisesi',
              'counselor_name': 'Elif',
              'counselor_surname': 'Şahin',
              'school_type': 'lise',
              'created_at': '2026-01-01',
            });
            await db.execute('''
            CREATE TABLE bep_meetings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              student_id INTEGER NOT NULL,
              meeting_date TEXT NOT NULL,
              agenda_items TEXT NOT NULL,
              decisions TEXT NOT NULL DEFAULT '[]',
              parent_attendees TEXT NOT NULL DEFAULT '[]',
              created_at TEXT NOT NULL
            )
          ''');
          },
        ),
      );
      await legacyDatabase.close();

      final database = await AppDatabase.open(path);
      try {
        // Kurulumdaki tek psikolojik danışman yeni tabloya taşınır.
        final staff = await database.db.query('school_staff');
        expect(staff, hasLength(1));
        expect(staff.single['role'], 'counselor');
        expect(staff.single['name'], 'Elif');
        expect(staff.single['surname'], 'Şahin');

        final meetingColumns = (await database.db.rawQuery(
          'PRAGMA table_info(bep_meetings)',
        )).map((row) => row['name']).toSet();
        expect(meetingColumns, contains('staff_attendees'));
      } finally {
        await database.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
