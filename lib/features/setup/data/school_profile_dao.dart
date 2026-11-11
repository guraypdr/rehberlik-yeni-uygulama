import '../../../core/database/app_database.dart';
import '../domain/school_profile.dart';

/// Kurulum formundan gelen ham girdi.
class SchoolProfileDaoInput {
  const SchoolProfileDaoInput({
    required this.name,
    required this.counselorName,
    required this.counselorSurname,
    required this.schoolType,
    this.hasPrep = false,
    this.fields = const [],
  });

  final String name;
  final String counselorName;
  final String counselorSurname;
  final SchoolType schoolType;
  final bool hasPrep;
  final List<String> fields;

  SchoolProfile toProfile() => SchoolProfile(
    name: name,
    counselorName: counselorName,
    counselorSurname: counselorSurname,
    schoolType: schoolType,
    hasPrep: hasPrep,
    fields: fields,
    createdAt: DateTime.now(),
  );
}

/// Okul profili ve sınıf düzeyleri için veri erişim nesnesi.
class SchoolProfileDao {
  const SchoolProfileDao(this._db);

  final AppDatabase _db;

  /// Profili ve sınıf düzeylerini tek bir transaction içinde kaydeder.
  Future<void> insertProfileAndGradeLevels(SchoolProfile profile) async {
    await _db.db.transaction((txn) async {
      await txn.insert('school_profile', profile.toMap());

      final labels = profile.gradeLevelLabels;
      for (var i = 0; i < labels.length; i++) {
        await txn.insert('grade_levels', {'label': labels[i], 'sort_order': i});
      }
    });
  }

  /// Profili okur; kayıt yoksa null döner.
  Future<SchoolProfile?> fetchProfile() async {
    final rows = await _db.db.query(
      'school_profile',
      where: 'id = 1',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SchoolProfile.fromMap(rows.first);
  }

  /// Updates the field list without changing the rest of the school profile.
  Future<void> updateFields(List<String> fields) async {
    final profile = await fetchProfile();
    if (profile == null) {
      throw StateError('Okul profili bulunamadı.');
    }

    final updated = await _db.db.update('school_profile', {
      'fields': profile.copyWith(fields: fields).toMap()['fields'],
    }, where: 'id = 1');
    if (updated != 1) {
      throw StateError('Okul alanları kaydedilemedi.');
    }
  }
}
