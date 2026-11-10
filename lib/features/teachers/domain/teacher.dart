/// Okuldaki öğretmen.
class Teacher {
  const Teacher({
    required this.id,
    required this.name,
    required this.surname,
    this.branch,
    this.email,
    this.phone,
  });

  final int id;
  final String name;
  final String surname;
  final String? branch;
  final String? email;
  final String? phone;

  String get fullName => '$name $surname';

  Teacher copyWith({
    String? name,
    String? surname,
    String? branch,
    String? email,
    String? phone,
  }) => Teacher(
    id: id,
    name: name ?? this.name,
    surname: surname ?? this.surname,
    branch: branch ?? this.branch,
    email: email ?? this.email,
    phone: phone ?? this.phone,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'surname': surname,
    'branch': branch,
    'email': email,
    'phone': phone,
  };

  static Teacher fromMap(Map<String, Object?> map) => Teacher(
    id: map['id']! as int,
    name: map['name']! as String,
    surname: map['surname']! as String,
    branch: map['branch'] as String?,
    email: map['email'] as String?,
    phone: map['phone'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Teacher &&
          other.id == id &&
          other.name == name &&
          other.surname == surname;

  @override
  int get hashCode => Object.hash(id, name, surname);

  @override
  String toString() => 'Teacher($id, $fullName)';
}
