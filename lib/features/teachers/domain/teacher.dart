/// Okuldaki öğretmen.
class Teacher {
  const Teacher({
    required this.id,
    required this.name,
    required this.surname,
    this.branch,
  });

  final int id;
  final String name;
  final String surname;
  final String? branch;

  String get fullName => '$name $surname';

  Teacher copyWith({String? name, String? surname, String? branch}) => Teacher(
    id: id,
    name: name ?? this.name,
    surname: surname ?? this.surname,
    branch: branch ?? this.branch,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'surname': surname,
    'branch': branch,
  };

  static Teacher fromMap(Map<String, Object?> map) => Teacher(
    id: map['id']! as int,
    name: map['name']! as String,
    surname: map['surname']! as String,
    branch: map['branch'] as String?,
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
