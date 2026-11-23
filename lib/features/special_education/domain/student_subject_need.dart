/// Destek eğitimi için önerilen haftalık ders saati: ders saatinin %40'ı,
/// yukarı yuvarlanır ve en az 1 saat olur.
int suggestedSupportHoursFor(int weeklyHours) {
  final hours = (weeklyHours * 0.4).ceil();
  return hours < 1 ? 1 : hours;
}

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
    this.supportHours,
    this.supportTeacherId,
    this.supportTeacherName,
  });

  final int studentId;
  final int classSubjectId;
  final String subjectName;
  final int weeklyHours;
  final bool requiresSupportEducation;
  final bool requiresBep;
  final bool isExempt;
  final String? teacherName;

  /// Destek eğitim odasında alınacak haftalık ders saati (karar saati).
  final int? supportHours;

  /// Destek eğitimini verecek öğretmen.
  final int? supportTeacherId;
  final String? supportTeacherName;

  /// Ders normal eğitim programına devam ediyor (hiçbir özel durum yok).
  bool get isNormalProgram =>
      !requiresSupportEducation && !requiresBep && !isExempt;

  /// Destek eğitimi saati için önerilen varsayılan değer: ders saatinin
  /// %40'ı, yukarı yuvarlanır ve en az 1 saat olur.
  int get suggestedSupportHours => suggestedSupportHoursFor(weeklyHours);

  /// Kararlaştırılan destek eğitimi ders saati (seçilmemişse önerilen değer).
  int? get effectiveSupportHours =>
      requiresSupportEducation ? (supportHours ?? suggestedSupportHours) : null;

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
        supportHours: map['support_hours'] as int?,
        supportTeacherId: map['support_teacher_id'] as int?,
        supportTeacherName: map['support_teacher_name'] as String?,
      );
}
