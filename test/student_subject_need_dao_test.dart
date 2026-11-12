import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rehberlik_app/core/database/app_database.dart';
import 'package:rehberlik_app/features/special_education/data/student_subject_need_dao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'öğrenciye ait derslerde BEP ve destek eğitim ihtiyaçlarını saklar',
    () async {
      final directory = await Directory.systemTemp.createTemp();
      final database = await AppDatabase.open(
        p.join(directory.path, 'student_subject_needs.db'),
      );

      try {
        final gradeLevelId = await database.db.insert('grade_levels', {
          'label': '9. Sınıf',
          'sort_order': 1,
        });
        final firstClassId = await database.db.insert('classes', {
          'grade_level_id': gradeLevelId,
          'branch': 'A',
        });
        final secondClassId = await database.db.insert('classes', {
          'grade_level_id': gradeLevelId,
          'branch': 'B',
        });
        final studentId = await database.db.insert('students', {
          'class_id': firstClassId,
          'number': '101',
          'name': 'Zeynep',
          'surname': 'Kaya',
          'created_at': '2026-11-12',
        });
        final otherStudentId = await database.db.insert('students', {
          'class_id': secondClassId,
          'number': '102',
          'name': 'Ali',
          'surname': 'Demir',
          'created_at': '2026-11-12',
        });
        final teacherId = await database.db.insert('teachers', {
          'name': 'Ayşe',
          'surname': 'Yılmaz',
        });
        final subjectId = await database.db.insert('class_subjects', {
          'class_id': firstClassId,
          'subject_name': 'Matematik',
          'weekly_hours': 6,
          'teacher_id': teacherId,
        });
        final otherSubjectId = await database.db.insert('class_subjects', {
          'class_id': firstClassId,
          'subject_name': 'Türkçe',
          'weekly_hours': 5,
        });
        final otherClassSubjectId = await database.db.insert('class_subjects', {
          'class_id': secondClassId,
          'subject_name': 'Fen Bilimleri',
          'weekly_hours': 4,
        });
        final dao = StudentSubjectNeedDao(database);

        expect(await dao.fetchForStudent(studentId), hasLength(2));
        await dao.setNeeds(
          studentId: studentId,
          classSubjectId: subjectId,
          requiresSupportEducation: true,
          requiresBep: false,
        );
        await dao.setNeeds(
          studentId: studentId,
          classSubjectId: otherSubjectId,
          requiresSupportEducation: false,
          requiresBep: true,
        );
        final needs = await dao.fetchForStudent(studentId);

        final mathNeed = needs.singleWhere(
          (need) => need.classSubjectId == subjectId,
        );
        expect(mathNeed.subjectName, 'Matematik');
        expect(mathNeed.weeklyHours, 6);
        expect(mathNeed.teacherName, 'Ayşe Yılmaz');
        expect(mathNeed.requiresSupportEducation, isTrue);
        expect(mathNeed.requiresBep, isFalse);
        expect(
          needs
              .singleWhere((need) => need.classSubjectId == otherSubjectId)
              .requiresBep,
          isTrue,
        );

        await dao.setNeeds(
          studentId: studentId,
          classSubjectId: subjectId,
          requiresBep: true,
        );
        await dao.setNeeds(
          studentId: studentId,
          classSubjectId: subjectId,
          requiresSupportEducation: false,
        );
        final independentlyUpdated = (await dao.fetchForStudent(
          studentId,
        )).singleWhere((need) => need.classSubjectId == subjectId);
        expect(independentlyUpdated.requiresSupportEducation, isFalse);
        expect(independentlyUpdated.requiresBep, isTrue);

        await expectLater(
          dao.setNeeds(
            studentId: studentId,
            classSubjectId: otherClassSubjectId,
            requiresSupportEducation: true,
            requiresBep: true,
          ),
          throwsArgumentError,
        );

        await dao.setNeeds(
          studentId: studentId,
          classSubjectId: subjectId,
          requiresSupportEducation: false,
          requiresBep: false,
        );
        expect(
          (await dao.fetchForStudent(studentId))
              .singleWhere((need) => need.classSubjectId == subjectId)
              .requiresSupportEducation,
          isFalse,
        );
        await dao.setNeeds(
          studentId: studentId,
          classSubjectId: subjectId,
          requiresSupportEducation: true,
          requiresBep: true,
        );

        await database.db.delete(
          'students',
          where: 'id = ?',
          whereArgs: [otherStudentId],
        );
        await database.db.delete(
          'class_subjects',
          where: 'id = ?',
          whereArgs: [subjectId],
        );
        expect(
          await database.db.query(
            'student_subject_needs',
            where: 'class_subject_id = ?',
            whereArgs: [subjectId],
          ),
          isEmpty,
        );
      } finally {
        await database.close();
        await directory.delete(recursive: true);
      }
    },
  );

  test('v16 veritabanına ders ihtiyacı tablosunu ekler', () async {
    final directory = await Directory.systemTemp.createTemp();
    final path = p.join(directory.path, 'student_subject_needs_v16.db');
    final oldDatabase = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 16,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE students (id INTEGER PRIMARY KEY, class_id INTEGER NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE class_subjects (id INTEGER PRIMARY KEY)',
          );
        },
      ),
    );
    await oldDatabase.close();

    final database = await AppDatabase.open(path);
    try {
      final tables = await database.db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'student_subject_needs'",
      );
      expect(tables, hasLength(1));
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
}
