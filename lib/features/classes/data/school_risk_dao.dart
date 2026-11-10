import '../../../core/database/app_database.dart';
import '../../students/domain/student.dart';
import '../domain/student_risk_question.dart';

typedef SchoolRiskCounts = Map<int, Map<String, int>>;

class SchoolRiskDao {
  const SchoolRiskDao(this._database);

  final AppDatabase _database;

  Future<SchoolRiskCounts> fetchCounts(List<Student> students) async {
    final counts = <int, Map<String, int>>{
      for (final student in students)
        student.classId: {
          for (final question in studentRiskQuestions) question.key: 0,
        },
    };
    if (students.isEmpty) return counts;

    final manualKeys = [
      for (final question in studentRiskManualQuestions) question.key,
    ];
    final placeholders = List.filled(manualKeys.length, '?').join(', ');
    final rows = await _database.db.rawQuery(
      '''
      SELECT responses.student_id, responses.question_key
      FROM class_risk_responses AS responses
      JOIN students ON students.id = responses.student_id
      WHERE responses.answer = 1
        AND responses.question_key IN ($placeholders)
      ''',
      manualKeys,
    );
    final positiveAnswers = {
      for (final row in rows)
        '${row['student_id']}:${row['question_key']}',
    };

    for (final student in students) {
      final classCounts = counts[student.classId]!;
      for (final question in studentRiskQuestions) {
        final answer = question.fromStudentForm
            ? question.answerFromStudent(student) ?? false
            : positiveAnswers.contains('${student.id}:${question.key}');
        if (answer) classCounts[question.key] = classCounts[question.key]! + 1;
      }
    }
    return counts;
  }
}
