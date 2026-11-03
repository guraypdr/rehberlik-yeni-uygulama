import '../../../core/database/app_database.dart';
import '../domain/todo_item.dart';

/// Yapılacaklar tablosu için veri erişim nesnesi.
class TodoDao {
  const TodoDao(this._db);

  final AppDatabase _db;

  Future<List<TodoItem>> fetchAll() async {
    final rows = await _db.db.query(
      'todos',
      orderBy: 'is_completed ASC, created_at DESC',
    );
    return rows.map(TodoItem.fromMap).toList();
  }

  Future<TodoItem> insert(String title) async {
    final now = DateTime.now();
    final id = await _db.db.insert('todos', {
      'title': title,
      'is_completed': 0,
      'created_at': now.toIso8601String(),
    });
    return TodoItem(id: id, title: title, isCompleted: false, createdAt: now);
  }

  Future<void> setCompleted(int id, {required bool isCompleted}) async {
    await _db.db.update(
      'todos',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    await _db.db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
