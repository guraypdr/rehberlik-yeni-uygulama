import '../../../core/database/app_database.dart';
import '../domain/teacher.dart';

/// Öğretmenler tablosu için veri erişim nesnesi.
class TeacherDao {
  const TeacherDao(this._db);

  final AppDatabase _db;

  Future<List<Teacher>> fetchAll() async {
    final rows = await _db.db.query('teachers', orderBy: 'surname ASC, name ASC');
    return rows.map(Teacher.fromMap).toList();
  }

  Future<Teacher> insert({
    required String name,
    required String surname,
    required String branch,
    String? email,
    String? phone,
  }) async {
    final id = await _db.db.insert('teachers', {
      'name': name,
      'surname': surname,
      'branch': branch,
      'email': email,
      'phone': phone,
    });
    return Teacher(
      id: id,
      name: name,
      surname: surname,
      branch: branch,
      email: email,
      phone: phone,
    );
  }

  Future<int> insertBatch(List<Teacher> teachers) async {
    if (teachers.isEmpty) return 0;
    final batch = _db.db.batch();
    for (final teacher in teachers) {
      final values = teacher.toMap()..remove('id');
      batch.insert('teachers', values);
    }
    final results = await batch.commit(noResult: false);
    return results.length;
  }

  Future<void> update(Teacher teacher) async {
    await _db.db.update(
      'teachers',
      teacher.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [teacher.id],
    );
  }

  Future<void> delete(int id) async {
    await _db.db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }
}
