import '../../../core/database/app_database.dart';
import '../domain/student_subject_need.dart';

class StudentSubjectNeedDao {
  const StudentSubjectNeedDao(this._database);

  final AppDatabase _database;

  Future<List<StudentSubjectNeed>> fetchForStudent(int studentId) async {
    final rows = await _database.db.rawQuery(
      '''
      SELECT
        s.id AS student_id,
        cs.id AS class_subject_id,
        cs.subject_name,
        cs.weekly_hours,
        CASE WHEN n.requires_support_education IS NULL THEN 0
          ELSE n.requires_support_education END AS requires_support_education,
        CASE WHEN n.requires_bep IS NULL THEN 0
          ELSE n.requires_bep END AS requires_bep,
        t.name || ' ' || t.surname AS teacher_name
      FROM students s
      JOIN class_subjects cs ON cs.class_id = s.class_id
      LEFT JOIN student_subject_needs n
        ON n.student_id = s.id AND n.class_subject_id = cs.id
      LEFT JOIN teachers t ON t.id = cs.teacher_id
      WHERE s.id = ?
      ORDER BY cs.subject_name COLLATE NOCASE ASC
      ''',
      [studentId],
    );
    return rows.map(StudentSubjectNeed.fromMap).toList();
  }

  Future<void> setNeeds({
    required int studentId,
    required int classSubjectId,
    bool? requiresSupportEducation,
    bool? requiresBep,
  }) async {
    await _database.db.transaction((txn) async {
      final validSubject = await txn.rawQuery(
        '''
        SELECT 1
        FROM students s
        JOIN class_subjects cs ON cs.class_id = s.class_id
        WHERE s.id = ? AND cs.id = ?
        ''',
        [studentId, classSubjectId],
      );
      if (validSubject.isEmpty) {
        throw ArgumentError('Ders bu öğrencinin sınıfına ait değil.');
      }

      final currentRows = await txn.query(
        'student_subject_needs',
        columns: ['requires_support_education', 'requires_bep'],
        where: 'student_id = ? AND class_subject_id = ?',
        whereArgs: [studentId, classSubjectId],
      );
      final current = currentRows.firstOrNull;
      final nextRequiresSupportEducation =
          requiresSupportEducation ??
          (current?['requires_support_education'] as int? ?? 0) == 1;
      final nextRequiresBep =
          requiresBep ?? (current?['requires_bep'] as int? ?? 0) == 1;

      if (!nextRequiresSupportEducation && !nextRequiresBep) {
        await txn.delete(
          'student_subject_needs',
          where: 'student_id = ? AND class_subject_id = ?',
          whereArgs: [studentId, classSubjectId],
        );
        return;
      }

      await txn.rawInsert(
        '''
        INSERT INTO student_subject_needs (
          student_id, class_subject_id, requires_support_education, requires_bep
        ) VALUES (?, ?, ?, ?)
        ON CONFLICT(student_id, class_subject_id) DO UPDATE SET
          requires_support_education = excluded.requires_support_education,
          requires_bep = excluded.requires_bep
        ''',
        [
          studentId,
          classSubjectId,
          nextRequiresSupportEducation ? 1 : 0,
          nextRequiresBep ? 1 : 0,
        ],
      );
    });
  }
}
