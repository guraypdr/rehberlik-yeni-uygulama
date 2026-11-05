import '../../../core/database/app_database.dart';
import '../domain/student.dart';

/// Öğrenciler tablosu için veri erişim nesnesi.
class StudentDao {
  const StudentDao(this._db);

  final AppDatabase _db;

  /// Tüm öğrencileri şube ve sınıf düzeyi bilgileriyle birlikte çeker.
  Future<List<Student>> fetchAll() async {
    final rows = await _db.db.rawQuery('''
      SELECT 
        s.*,
        (g.label || ' / ' || c.branch) AS class_name,
        g.label AS grade_level_label
      FROM students s
      JOIN classes c ON s.class_id = c.id
      JOIN grade_levels g ON c.grade_level_id = g.id
      ORDER BY g.sort_order ASC, c.branch ASC, s.name ASC, s.surname ASC
    ''');
    return rows.map(Student.fromMap).toList();
  }

  /// ID ile tek bir öğrenciyi çeker.
  Future<Student?> getById(int id) async {
    final rows = await _db.db.rawQuery(
      '''
      SELECT 
        s.*,
        (g.label || ' / ' || c.branch) AS class_name,
        g.label AS grade_level_label
      FROM students s
      JOIN classes c ON s.class_id = c.id
      JOIN grade_levels g ON c.grade_level_id = g.id
      WHERE s.id = ?
    ''',
      [id],
    );
    if (rows.isEmpty) return null;
    return Student.fromMap(rows.first);
  }

  /// Temel bilgilerle hızlı öğrenci ekler.
  Future<Student> insertBasic({
    required int classId,
    required String number,
    required String name,
    required String surname,
    required String gender,
    String boardingStatus = 'Gündüzlü',
  }) async {
    final now = DateTime.now().toIso8601String();
    final map = {
      'class_id': classId,
      'number': number,
      'name': name.trim(),
      'surname': surname.trim(),
      'gender': gender,
      'boarding_status': boardingStatus,
      'status': 'Aktif',
      'created_at': now,
    };
    final id = await _db.db.insert('students', map);
    final inserted = await getById(id);
    return inserted ??
        Student(
          id: id,
          classId: classId,
          number: number,
          name: name,
          surname: surname,
          gender: gender,
          boardingStatus: boardingStatus,
          createdAt: now,
        );
  }

  /// Tam öğrenci kaydı ekler.
  Future<Student> insert(Student student) async {
    final map = student.toMap()..remove('id');
    final id = await _db.db.insert('students', map);
    return (await getById(id)) ?? student.copyWith(id: id);
  }

  /// Toplu öğrenci ekler (Excel / CSV içe aktarım için).
  Future<int> insertBatch(List<Student> students) async {
    final batch = _db.db.batch();
    for (final s in students) {
      final map = s.toMap()..remove('id');
      batch.insert('students', map);
    }
    final results = await batch.commit(noResult: false);
    return results.length;
  }

  /// Öğrenci bilgilerini günceller.
  Future<void> update(Student student) async {
    final map = student.toMap()..remove('id');
    await _db.db.update(
      'students',
      map,
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  /// Öğrenciyi siler.
  Future<void> delete(int id) async {
    await _db.db.delete('students', where: 'id = ?', whereArgs: [id]);
  }
}
