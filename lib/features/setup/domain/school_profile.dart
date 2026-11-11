import 'dart:convert';

/// Okul türü seçenekleri.
enum SchoolType {
  ilkokul('İlkokul'),
  ortaokul('Ortaokul'),
  lise('Lise'),
  meslekLisesi('Meslek Lisesi');

  const SchoolType(this.label);
  final String label;

  static SchoolType fromString(String value) =>
      SchoolType.values.firstWhere((e) => e.name == value);
}

/// Okulun temel profili — kurulum sırasında bir kez oluşturulur,
/// sonradan değiştirilemez.
class SchoolProfile {
  const SchoolProfile({
    required this.name,
    this.counselorName = '',
    this.counselorSurname = '',
    required this.schoolType,
    this.hasPrep = false,
    this.fields = const [],
    required this.createdAt,
  });

  /// Okul adı.
  final String name;

  /// Psikolojik danışmanın adı ve soyadı.
  final String counselorName;
  final String counselorSurname;

  /// Okul türü.
  final SchoolType schoolType;

  /// Lise türünde hazırlık sınıfı var mı?
  final bool hasPrep;

  /// Okuldaki alanlar (örn. ["Sayısal", "Sözel"]).
  final List<String> fields;

  /// Veritabanının oluşturulma tarihi.
  final DateTime createdAt;

  SchoolProfile copyWith({
    List<String>? fields,
    String? counselorName,
    String? counselorSurname,
  }) => SchoolProfile(
    name: name,
    counselorName: counselorName ?? this.counselorName,
    counselorSurname: counselorSurname ?? this.counselorSurname,
    schoolType: schoolType,
    hasPrep: hasPrep,
    fields: fields ?? this.fields,
    createdAt: createdAt,
  );

  /// Bu okul türünde sınıf düzeyi etiketlerini döner (sıralı).
  List<String> get gradeLevelLabels {
    switch (schoolType) {
      case SchoolType.ilkokul:
        return ['1. Sınıf', '2. Sınıf', '3. Sınıf', '4. Sınıf'];
      case SchoolType.ortaokul:
        return ['5. Sınıf', '6. Sınıf', '7. Sınıf', '8. Sınıf'];
      case SchoolType.lise:
        return [
          if (hasPrep) 'Hazırlık',
          '9. Sınıf',
          '10. Sınıf',
          '11. Sınıf',
          '12. Sınıf',
        ];
      case SchoolType.meslekLisesi:
        return ['9. Sınıf', '10. Sınıf', '11. Sınıf', '12. Sınıf'];
    }
  }

  Map<String, Object?> toMap() => {
    'id': 1,
    'name': name,
    'counselor_name': counselorName,
    'counselor_surname': counselorSurname,
    'school_type': schoolType.name,
    'has_prep': hasPrep ? 1 : 0,
    'fields': fields.isEmpty ? null : jsonEncode(fields),
    'created_at': createdAt.toIso8601String(),
  };

  static SchoolProfile fromMap(Map<String, Object?> map) {
    final rawFields = map['fields'] as String?;
    List<String> fields = const [];
    if (rawFields != null && rawFields.isNotEmpty) {
      final decoded = jsonDecode(rawFields);
      if (decoded is List) fields = List<String>.from(decoded);
    }
    return SchoolProfile(
      name: map['name']! as String,
      counselorName: map['counselor_name'] as String? ?? '',
      counselorSurname: map['counselor_surname'] as String? ?? '',
      schoolType: SchoolType.fromString(map['school_type']! as String),
      hasPrep: (map['has_prep'] as int? ?? 0) == 1,
      fields: fields,
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }

  @override
  String toString() => 'SchoolProfile($name, ${schoolType.label})';
}
