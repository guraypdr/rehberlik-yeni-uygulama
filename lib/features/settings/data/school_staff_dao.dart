import '../../../core/database/app_database.dart';
import '../domain/school_staff.dart';

/// Okul idari kadrosu (müdür, müdür yardımcısı, psikolojik danışman) veri erişimi.
class SchoolStaffDao {
  const SchoolStaffDao(this._database);

  final AppDatabase _database;

  /// Personeli rol sırasına göre (müdür, müdür yardımcısı, danışman) döner.
  Future<List<SchoolStaff>> fetchAll() async {
    final rows = await _database.db.rawQuery('''
      SELECT id, role, name, surname
      FROM school_staff
      ORDER BY CASE role
        WHEN 'principal' THEN 0
        WHEN 'vice_principal' THEN 1
        ELSE 2
      END, id
    ''');
    return rows.map(SchoolStaff.fromMap).toList();
  }

  /// Tek olan okul müdürünü kaydeder; varsa önceki kaydı değiştirir.
  Future<void> savePrincipal({
    required String name,
    required String surname,
  }) async {
    await _database.db.transaction((txn) async {
      await txn.delete(
        'school_staff',
        where: 'role = ?',
        whereArgs: [SchoolStaffRole.principal.storageKey],
      );
      await txn.insert('school_staff', {
        'role': SchoolStaffRole.principal.storageKey,
        'name': name,
        'surname': surname,
      });
    });
  }

  /// Çoklu eklenebilen personel (müdür yardımcısı, psikolojik danışman) ekler.
  Future<void> addMember({
    required SchoolStaffRole role,
    required String name,
    required String surname,
  }) async {
    if (role == SchoolStaffRole.principal) {
      throw ArgumentError('Okul müdürü için savePrincipal kullanılmalıdır.');
    }
    await _database.db.insert('school_staff', {
      'role': role.storageKey,
      'name': name,
      'surname': surname,
    });
  }

  Future<void> update({
    required int id,
    required String name,
    required String surname,
  }) async {
    final updated = await _database.db.update(
      'school_staff',
      {'name': name, 'surname': surname},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (updated != 1) {
      throw StateError('Personel kaydı güncellenemedi.');
    }
  }

  Future<void> delete(int id) async {
    await _database.db.delete('school_staff', where: 'id = ?', whereArgs: [id]);
  }
}
