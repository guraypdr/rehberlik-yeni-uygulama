import '../../../core/database/app_database.dart';
import '../domain/grade_level.dart';
import '../domain/school_class.dart';

/// Sınıf ve sınıf düzeyi tabloları için veri erişim nesnesi.
class ClassDao {
  const ClassDao(this._db);

  final AppDatabase _db;

  // ── Grade levels ────────────────────────────────────────────────────────────

  Future<List<GradeLevel>> fetchGradeLevels() async {
    final rows = await _db.db.query('grade_levels', orderBy: 'sort_order ASC');
    return rows.map(GradeLevel.fromMap).toList();
  }

  // ── Classes ─────────────────────────────────────────────────────────────────

  /// Tüm sınıfları ilgili düzey etiketiyle birlikte döner.
  Future<List<SchoolClass>> fetchAll() async {
    final levels = await fetchGradeLevels();
    final levelMap = {for (final l in levels) l.id: l.label};

    final rows = await _db.db.rawQuery('''
      SELECT c.* FROM classes c
      JOIN grade_levels gl ON gl.id = c.grade_level_id
      ORDER BY gl.sort_order ASC, c.branch ASC
    ''');

    return rows.map((row) {
      final label = levelMap[row['grade_level_id'] as int] ?? '';
      return SchoolClass.fromMap(row, label);
    }).toList();
  }

  Future<SchoolClass> insert({
    required int gradeLevelId,
    required String gradeLevelLabel,
    required String branch,
    String? fieldName,
    int? teacherId,
  }) async {
    final id = await _db.db.insert('classes', {
      'grade_level_id': gradeLevelId,
      'branch': branch,
      'field_name': fieldName,
      'teacher_id': teacherId,
    });
    return SchoolClass(
      id: id,
      gradeLevelId: gradeLevelId,
      gradeLevelLabel: gradeLevelLabel,
      branch: branch,
      fieldName: fieldName,
      teacherId: teacherId,
    );
  }

  Future<void> update(SchoolClass cls) async {
    await _db.db.update(
      'classes',
      {
        'branch': cls.branch,
        'field_name': cls.fieldName,
        'teacher_id': cls.teacherId,
      },
      where: 'id = ?',
      whereArgs: [cls.id],
    );
  }

  Future<void> delete(int id) async {
    await _db.db.delete('classes', where: 'id = ?', whereArgs: [id]);
  }
}
