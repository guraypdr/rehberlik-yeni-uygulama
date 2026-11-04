/// Rehberlik servisi görüşme kaydı.
class StudentInterview {
  const StudentInterview({
    required this.id,
    required this.studentId,
    required this.type,
    required this.date,
    required this.subject,
    required this.notes,
    this.actionPlan,
    required this.createdAt,
  });

  final int id;
  final int studentId;

  /// 'student' (Bireysel), 'parent' (Veli), 'teacher' (Öğretmen)
  final String type;

  /// ISO-8601 YYYY-MM-DD
  final String date;

  final String subject;
  final String notes;
  final String? actionPlan;
  final String createdAt;

  String get typeLabel {
    switch (type) {
      case 'parent':
        return 'Veli Görüşmesi';
      case 'teacher':
        return 'Öğretmen Görüşmesi';
      case 'student':
      default:
        return 'Bireysel Görüşme';
    }
  }

  StudentInterview copyWith({
    int? id,
    int? studentId,
    String? type,
    String? date,
    String? subject,
    String? notes,
    String? actionPlan,
    String? createdAt,
  }) =>
      StudentInterview(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        type: type ?? this.type,
        date: date ?? this.date,
        subject: subject ?? this.subject,
        notes: notes ?? this.notes,
        actionPlan: actionPlan ?? this.actionPlan,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        'id': id == 0 ? null : id,
        'student_id': studentId,
        'type': type,
        'date': date,
        'subject': subject,
        'notes': notes,
        'action_plan': actionPlan,
        'created_at': createdAt,
      };

  static StudentInterview fromMap(Map<String, Object?> map) => StudentInterview(
        id: map['id'] as int,
        studentId: map['student_id'] as int,
        type: map['type'] as String,
        date: map['date'] as String,
        subject: map['subject'] as String,
        notes: map['notes'] as String,
        actionPlan: map['action_plan'] as String?,
        createdAt: map['created_at'] as String,
      );
}

