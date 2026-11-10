import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';

class StudentRiskDao {
  const StudentRiskDao(this._database);

  final AppDatabase _database;

  Future<Map<int, Map<String, bool>>> initializeAndFetch({
    required int classId,
    required List<String> questionKeys,
  }) async {
    final db = _database.db;
    return db.transaction((transaction) async {
      final students = await transaction.query(
        'students',
        columns: ['id'],
        where: 'class_id = ?',
        whereArgs: [classId],
      );
      final now = DateTime.now().toIso8601String();
      final batch = transaction.batch();
      for (final student in students) {
        final studentId = student['id']! as int;
        for (final questionKey in questionKeys) {
          batch.insert('class_risk_responses', {
            'student_id': studentId,
            'question_key': questionKey,
            'answer': 0,
            'updated_at': now,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
      await batch.commit(noResult: true);

      final rows = await transaction.rawQuery(
        '''
        SELECT responses.student_id, responses.question_key, responses.answer
        FROM class_risk_responses AS responses
        JOIN students ON students.id = responses.student_id
        WHERE students.class_id = ?
        ''',
        [classId],
      );
      final result = <int, Map<String, bool>>{};
      for (final row in rows) {
        final studentId = row['student_id']! as int;
        result.putIfAbsent(
          studentId,
          () => <String, bool>{},
        )[row['question_key']! as String] = row['answer'] == 1;
      }
      return result;
    });
  }

  Future<void> setAnswer({
    required int studentId,
    required String questionKey,
    required bool answer,
  }) async {
    await _database.db.insert('class_risk_responses', {
      'student_id': studentId,
      'question_key': questionKey,
      'answer': answer ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> isClassRiskMapCompleted(int classId) async {
    final rows = await _database.db.query(
      'class_risk_map_status',
      columns: ['class_id'],
      where: 'class_id = ?',
      whereArgs: [classId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> markClassRiskMapCompleted(int classId) async {
    await _database.db.insert('class_risk_map_status', {
      'class_id': classId,
      'completed_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
