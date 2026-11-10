import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rehberlik_app/core/database/app_database.dart';
import 'package:rehberlik_app/features/classes/data/school_risk_dao.dart';
import 'package:rehberlik_app/features/classes/data/student_risk_dao.dart';
import 'package:rehberlik_app/features/classes/domain/student_risk_question.dart';
import 'package:rehberlik_app/features/students/data/student_dao.dart';
import 'package:rehberlik_app/features/students/domain/student.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'sınıf başına formdan türetilen ve elle girilen cevapları sayar',
    () async {
      final directory = await Directory.systemTemp.createTemp();
      final database = await AppDatabase.open(
        p.join(directory.path, 'school_risk.db'),
      );

      try {
        await database.db.insert('grade_levels', {
          'label': '9. Sınıf',
          'sort_order': 1,
        });
        await database.db.insert('classes', {
          'grade_level_id': 1,
          'branch': 'A',
        });
        await database.db.insert('classes', {
          'grade_level_id': 1,
          'branch': 'B',
        });
        final studentDao = StudentDao(database);
        final firstStudent = await studentDao.insert(
          Student(
            id: 0,
            classId: 1,
            number: '101',
            name: 'Ayşe',
            surname: 'Kaya',
            createdAt: '2026-11-10',
            motherEducation: 'İlkokul',
            siblingCount: 0,
          ),
        );
        final secondStudent = await studentDao.insert(
          Student(
            id: 0,
            classId: 2,
            number: '102',
            name: 'Mehmet',
            surname: 'Demir',
            createdAt: '2026-11-10',
            motherEducation: 'Lise',
            siblingCount: 2,
          ),
        );
        final studentRiskDao = StudentRiskDao(database);
        final manualQuestionKeys = [
          for (final question in studentRiskManualQuestions) question.key,
        ];
        await studentRiskDao.initializeAndFetch(
          classId: 1,
          questionKeys: manualQuestionKeys,
        );
        await studentRiskDao.setAnswer(
          studentId: firstStudent.id,
          questionKey: 'parents_separated',
          answer: true,
        );

        final counts = await SchoolRiskDao(
          database,
        ).fetchCounts([firstStudent, secondStudent]);

        expect(counts[1]!['mother_low_education'], 1);
        expect(counts[2]!['mother_low_education'], 0);
        expect(counts[1]!['only_child'], 1);
        expect(counts[2]!['only_child'], 0);
        expect(counts[1]!['parents_separated'], 1);
        expect(counts[2]!['parents_separated'], 0);
        expect(counts[2]!.keys, hasLength(studentRiskQuestions.length));
      } finally {
        await database.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
