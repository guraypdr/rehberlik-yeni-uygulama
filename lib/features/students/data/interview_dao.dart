import '../../../core/database/app_database.dart';
import '../domain/student_interview.dart';

/// Rehberlik görüşmeleri tablosu için veri erişim nesnesi.
class InterviewDao {
  const InterviewDao(this._db);

  final AppDatabase _db;

  /// Belirli bir öğrencinin görüşme kayıtlarını tarihe göre sıralı getirir.
  Future<List<StudentInterview>> fetchByStudentId(int studentId) async {
    final rows = await _db.db.query(
      'student_interviews',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(StudentInterview.fromMap).toList();
  }

  /// Yeni görüşme kaydı ekler.
  Future<StudentInterview> insert({
    required int studentId,
    required String type,
    required String date,
    required String subject,
    required String notes,
    String? actionPlan,
  }) async {
    final now = DateTime.now().toIso8601String();
    final id = await _db.db.insert('student_interviews', {
      'student_id': studentId,
      'type': type,
      'date': date,
      'subject': subject.trim(),
      'notes': notes.trim(),
      'action_plan': actionPlan?.trim(),
      'created_at': now,
    });
    return StudentInterview(
      id: id,
      studentId: studentId,
      type: type,
      date: date,
      subject: subject,
      notes: notes,
      actionPlan: actionPlan,
      createdAt: now,
    );
  }

  /// Görüşme kaydını siler.
  Future<void> delete(int id) async {
    await _db.db.delete(
      'student_interviews',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

