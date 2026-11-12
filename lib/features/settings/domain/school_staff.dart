/// Okul personelinin rolü.
enum SchoolStaffRole {
  principal('Okul Müdürü', 'principal'),
  vicePrincipal('Müdür Yardımcısı', 'vice_principal'),
  counselor('Psikolojik Danışman', 'counselor');

  const SchoolStaffRole(this.label, this.storageKey);

  /// Arayüzde gösterilen rol adı.
  final String label;

  /// Veritabanında saklanan rol değeri.
  final String storageKey;

  /// İdareci (okul müdürü veya müdür yardımcısı) mı?
  bool get isAdministrator =>
      this == SchoolStaffRole.principal ||
      this == SchoolStaffRole.vicePrincipal;

  static SchoolStaffRole fromStorageKey(String value) =>
      SchoolStaffRole.values.firstWhere((role) => role.storageKey == value);
}

/// Okulun idari kadrosunda yer alan bir kişi.
class SchoolStaff {
  const SchoolStaff({
    required this.id,
    required this.role,
    required this.name,
    required this.surname,
  });

  final int id;
  final SchoolStaffRole role;
  final String name;
  final String surname;

  String get fullName => '$name $surname'.trim();

  static SchoolStaff fromMap(Map<String, Object?> map) => SchoolStaff(
    id: map['id']! as int,
    role: SchoolStaffRole.fromStorageKey(map['role']! as String),
    name: map['name']! as String,
    surname: map['surname']! as String,
  );

  @override
  String toString() => 'SchoolStaff(${role.name}, $fullName)';
}
