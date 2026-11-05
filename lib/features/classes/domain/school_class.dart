/// Okuldaki bir şube (sınıf).
class SchoolClass {
  const SchoolClass({
    required this.id,
    required this.gradeLevelId,
    required this.gradeLevelLabel,
    required this.branch,
    this.fieldName,
    this.teacherId,
  });

  final int id;
  final int gradeLevelId;

  /// Arayüzde gösterilecek düzey etiketi (örn. "9. Sınıf").
  final String gradeLevelLabel;

  /// Şube harfi (A, B, C …).
  final String branch;

  /// Meslek lisesi alanı (opsiyonel).
  final String? fieldName;

  /// Sınıf öğretmeninin id'si (opsiyonel).
  final int? teacherId;

  String get displayName =>
      '${gradeLevelLabel.replaceFirst(RegExp(r'\.\s*Sınıf$'), '')}/$branch';

  SchoolClass copyWith({
    int? gradeLevelId,
    String? gradeLevelLabel,
    String? branch,
    String? fieldName,
    int? teacherId,
    bool clearTeacher = false,
    bool clearField = false,
  }) => SchoolClass(
    id: id,
    gradeLevelId: gradeLevelId ?? this.gradeLevelId,
    gradeLevelLabel: gradeLevelLabel ?? this.gradeLevelLabel,
    branch: branch ?? this.branch,
    fieldName: clearField ? null : (fieldName ?? this.fieldName),
    teacherId: clearTeacher ? null : (teacherId ?? this.teacherId),
  );

  static SchoolClass fromMap(
    Map<String, Object?> map,
    String gradeLevelLabel,
  ) => SchoolClass(
    id: map['id']! as int,
    gradeLevelId: map['grade_level_id']! as int,
    gradeLevelLabel: gradeLevelLabel,
    branch: map['branch']! as String,
    fieldName: map['field_name'] as String?,
    teacherId: map['teacher_id'] as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchoolClass && other.id == id && other.branch == branch;

  @override
  int get hashCode => Object.hash(id, branch);

  @override
  String toString() => 'SchoolClass($id, $displayName)';
}
