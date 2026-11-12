import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rehberlik_app/core/database/app_database.dart';
import 'package:rehberlik_app/features/classes/data/class_subject_dao.dart';
import 'package:rehberlik_app/features/classes/domain/class_subject.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('dersleri ve öğretmen atamalarını sınıfa göre saklar', () async {
    final directory = await Directory.systemTemp.createTemp();
    final database = await AppDatabase.open(
      p.join(directory.path, 'class_subjects.db'),
    );

    try {
      final gradeLevelId = await database.db.insert('grade_levels', {
        'label': '9. Sınıf',
        'sort_order': 1,
      });
      final teacherId = await database.db.insert('teachers', {
        'name': 'Ayşe',
        'surname': 'Yılmaz',
      });
      final classId = await database.db.insert('classes', {
        'grade_level_id': gradeLevelId,
        'branch': 'A',
      });
      final dao = ClassSubjectDao(database);
      final subject = await dao.insert(
        classId: classId,
        subjectName: '  Matematik  ',
        weeklyHours: 6,
        teacherId: teacherId,
      );

      expect(subject.subjectName, 'Matematik');
      final fetched = (await dao.fetchForClass(classId)).single;
      expect(fetched.teacherId, teacherId);
      expect(fetched.weeklyHours, 6);

      await database.db.delete(
        'teachers',
        where: 'id = ?',
        whereArgs: [teacherId],
      );
      expect((await dao.fetchForClass(classId)).single.teacherId, isNull);

      await database.db.delete(
        'classes',
        where: 'id = ?',
        whereArgs: [classId],
      );
      expect(await dao.fetchForClass(classId), isEmpty);
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });

  test('dersleri toplu olarak saatleriyle sınıfa ekler', () async {
    final directory = await Directory.systemTemp.createTemp();
    final database = await AppDatabase.open(
      p.join(directory.path, 'class_subjects_batch.db'),
    );

    try {
      final gradeLevelId = await database.db.insert('grade_levels', {
        'label': '10. Sınıf',
        'sort_order': 2,
      });
      final classId = await database.db.insert('classes', {
        'grade_level_id': gradeLevelId,
        'branch': 'B',
      });
      final dao = ClassSubjectDao(database);
      await dao.insertBatch(
        classId: classId,
        subjects: [
          ClassSubject(
            id: 0,
            classId: classId,
            subjectName: 'Matematik',
            weeklyHours: 6,
          ),
          ClassSubject(
            id: 0,
            classId: classId,
            subjectName: 'Fizik',
            weeklyHours: 3,
          ),
        ],
      );

      final subjects = await dao.fetchForClass(classId);
      expect(subjects.map((subject) => subject.subjectName), [
        'Fizik',
        'Matematik',
      ]);
      expect(subjects.map((subject) => subject.weeklyHours), [3, 6]);
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });

  test('v15 veritabanına ders saatini kaydı koruyarak ekler', () async {
    final directory = await Directory.systemTemp.createTemp();
    final path = p.join(directory.path, 'class_subjects_v15.db');
    final oldDatabase = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 15,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE classes (id INTEGER PRIMARY KEY, branch TEXT NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE teachers (id INTEGER PRIMARY KEY, name TEXT NOT NULL)',
          );
          await db.execute('''
            CREATE TABLE class_subjects (
              id INTEGER PRIMARY KEY,
              class_id INTEGER NOT NULL,
              subject_name TEXT NOT NULL,
              teacher_id INTEGER
            )
          ''');
          await db.insert('class_subjects', {
            'id': 8,
            'class_id': 2,
            'subject_name': 'Fen Bilimleri',
          });
        },
      ),
    );
    await oldDatabase.close();

    final database = await AppDatabase.open(path);
    try {
      final subjects = await database.db.query(
        'class_subjects',
        where: 'id = ?',
        whereArgs: [8],
      );
      expect(subjects, hasLength(1));
      expect(subjects.single['subject_name'], 'Fen Bilimleri');
      expect(subjects.single['weekly_hours'], 1);
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
}
