import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rehberlik_app/core/database/app_database.dart';
import 'package:rehberlik_app/features/classes/data/student_risk_dao.dart';
import 'package:rehberlik_app/features/classes/domain/student_risk_question.dart';
import 'package:rehberlik_app/features/students/data/student_dao.dart';
import 'package:rehberlik_app/features/students/domain/student.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'sınıf cevapları hayır ile başlar ve değişiklikler kaydedilir',
    () async {
      final directory = await Directory.systemTemp.createTemp();
      final database = await AppDatabase.open(
        p.join(directory.path, 'student_risk.db'),
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
        final student = await StudentDao(database).insertBasic(
          classId: 1,
          number: '101',
          name: 'Ayşe',
          surname: 'Kaya',
          gender: 'Kız',
        );
        final dao = StudentRiskDao(database);
        final questionKeys = [
          for (final question in studentRiskManualQuestions) question.key,
        ];

        final initial = await dao.initializeAndFetch(
          classId: 1,
          questionKeys: questionKeys,
        );
        expect(initial[student.id], hasLength(questionKeys.length));
        expect(initial[student.id]!.values, everyElement(isFalse));

        await dao.setAnswer(
          studentId: student.id,
          questionKey: questionKeys.first,
          answer: true,
        );
        final updated = await dao.initializeAndFetch(
          classId: 1,
          questionKeys: questionKeys,
        );
        expect(updated[student.id]![questionKeys.first], isTrue);
        expect(
          await database.db.query('class_risk_responses'),
          hasLength(questionKeys.length),
        );
        expect(await dao.isClassRiskMapCompleted(1), isFalse);
        await dao.markClassRiskMapCompleted(1);
        expect(await dao.isClassRiskMapCompleted(1), isTrue);
      } finally {
        await database.close();
        await directory.delete(recursive: true);
      }
    },
  );

  test('öğrenci formundan gelen cevaplar soru tipine göre hesaplanır', () {
    const student = Student(
      id: 1,
      classId: 2,
      number: '101',
      name: 'Ayşe',
      surname: 'Kaya',
      createdAt: '2026-11-10',
      motherEducation: 'İlkokul',
      fatherEducation: 'Lise',
      siblingCount: 5,
      motherIsAlive: false,
      fatherIsAlive: false,
      familyHasChronicIllness: true,
      hasChronicIllness: true,
    );

    bool answer(String key) => studentRiskQuestions
        .singleWhere((question) => question.key == key)
        .answerFromStudent(student)!;

    expect(answer('mother_low_education'), isTrue);
    expect(answer('father_low_education'), isFalse);
    expect(answer('only_child'), isFalse);
    expect(answer('five_or_more_siblings'), isTrue);
    expect(answer('mother_deceased'), isTrue);
    expect(answer('father_deceased'), isTrue);
    expect(answer('both_parents_deceased'), isTrue);
    expect(answer('family_chronic_illness'), isTrue);
    expect(answer('student_chronic_illness'), isTrue);
  });
}
