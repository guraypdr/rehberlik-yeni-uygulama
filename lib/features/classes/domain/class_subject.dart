/// Bir sınıfta okutulan ders ve bu derse atanmış öğretmen.
class ClassSubject {
  const ClassSubject({
    required this.id,
    required this.classId,
    required this.subjectName,
    required this.weeklyHours,
    this.teacherId,
  });

  final int id;
  final int classId;
  final String subjectName;
  final int weeklyHours;
  final int? teacherId;

  static ClassSubject fromMap(Map<String, Object?> map) => ClassSubject(
    id: map['id']! as int,
    classId: map['class_id']! as int,
    subjectName: map['subject_name']! as String,
    weeklyHours: map['weekly_hours']! as int,
    teacherId: map['teacher_id'] as int?,
  );
}
