import '../../../core/database/app_database.dart';
import '../domain/class_subject.dart';

/// Sınıf-ders-öğretmen ilişkileri için veri erişim nesnesi.
class ClassSubjectDao {
  const ClassSubjectDao(this._database);

  final AppDatabase _database;

  Future<List<ClassSubject>> fetchForClass(int classId) async {
    final rows = await _database.db.query(
      'class_subjects',
      where: 'class_id = ?',
      whereArgs: [classId],
      orderBy: 'subject_name COLLATE NOCASE ASC',
    );
    return rows.map(ClassSubject.fromMap).toList();
  }

  Future<ClassSubject> insert({
    required int classId,
    required String subjectName,
    required int weeklyHours,
    int? teacherId,
  }) async {
    final normalizedName = subjectName.trim();
    final id = await _database.db.insert('class_subjects', {
      'class_id': classId,
      'subject_name': normalizedName,
      'weekly_hours': weeklyHours,
      'teacher_id': teacherId,
    });
    return ClassSubject(
      id: id,
      classId: classId,
      subjectName: normalizedName,
      weeklyHours: weeklyHours,
      teacherId: teacherId,
    );
  }

  Future<List<ClassSubject>> insertBatch({
    required int classId,
    required List<ClassSubject> subjects,
  }) async {
    return _database.db.transaction((txn) async {
      final inserted = <ClassSubject>[];
      for (final subject in subjects) {
        final normalizedName = subject.subjectName.trim();
        final id = await txn.insert('class_subjects', {
          'class_id': classId,
          'subject_name': normalizedName,
          'weekly_hours': subject.weeklyHours,
          'teacher_id': subject.teacherId,
        });
        inserted.add(
          ClassSubject(
            id: id,
            classId: classId,
            subjectName: normalizedName,
            weeklyHours: subject.weeklyHours,
            teacherId: subject.teacherId,
          ),
        );
      }
      return inserted;
    });
  }

  Future<ClassSubject> update({
    required int id,
    required int classId,
    required String subjectName,
    required int weeklyHours,
    int? teacherId,
  }) async {
    final normalizedName = subjectName.trim();
    await _database.db.update(
      'class_subjects',
      {
        'subject_name': normalizedName,
        'weekly_hours': weeklyHours,
        'teacher_id': teacherId,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return ClassSubject(
      id: id,
      classId: classId,
      subjectName: normalizedName,
      weeklyHours: weeklyHours,
      teacherId: teacherId,
    );
  }

  Future<void> delete(int id) async {
    await _database.db.delete(
      'class_subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
