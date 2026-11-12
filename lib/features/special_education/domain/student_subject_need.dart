class StudentSubjectNeed {
  const StudentSubjectNeed({
    required this.studentId,
    required this.classSubjectId,
    required this.subjectName,
    required this.weeklyHours,
    required this.requiresSupportEducation,
    required this.requiresBep,
    required this.isExempt,
    this.teacherName,
  });

  final int studentId;
  final int classSubjectId;
  final String subjectName;
  final int weeklyHours;
  final bool requiresSupportEducation;
  final bool requiresBep;
  final bool isExempt;
  final String? teacherName;

  /// Ders normal eğitim programına devam ediyor (hiçbir özel durum yok).
  bool get isNormalProgram =>
      !requiresSupportEducation && !requiresBep && !isExempt;

  static StudentSubjectNeed fromMap(Map<String, Object?> map) =>
      StudentSubjectNeed(
        studentId: map['student_id']! as int,
        classSubjectId: map['class_subject_id']! as int,
        subjectName: map['subject_name']! as String,
        weeklyHours: map['weekly_hours']! as int,
        requiresSupportEducation:
            (map['requires_support_education']! as int) == 1,
        requiresBep: (map['requires_bep']! as int) == 1,
        isExempt: (map['is_exempt']! as int) == 1,
        teacherName: map['teacher_name'] as String?,
      );
}
