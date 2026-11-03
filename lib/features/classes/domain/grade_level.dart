/// Sınıf düzeyi (9. Sınıf, Hazırlık vb.).
class GradeLevel {
  const GradeLevel({
    required this.id,
    required this.label,
    required this.sortOrder,
  });

  final int id;
  final String label;
  final int sortOrder;

  static GradeLevel fromMap(Map<String, Object?> map) => GradeLevel(
        id: map['id']! as int,
        label: map['label']! as String,
        sortOrder: map['sort_order']! as int,
      );

  @override
  String toString() => 'GradeLevel($id, $label)';
}
