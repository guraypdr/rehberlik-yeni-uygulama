import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/features/todos/domain/todo_item.dart';

void main() {
  group('TodoItem domain modeli', () {
    final todo = TodoItem(
      id: 1,
      title: 'Test görevi',
      isCompleted: false,
      createdAt: DateTime(2026, 1, 1),
    );

    test('copyWith tamamlama durumunu değiştirir', () {
      final completed = todo.copyWith(isCompleted: true);
      expect(completed.isCompleted, isTrue);
      expect(completed.id, 1);
    });

    test('fromMap / toMap dönüşümü tutarlı', () {
      final map = todo.toMap();
      final restored = TodoItem.fromMap(map);
      expect(restored.id, todo.id);
      expect(restored.title, todo.title);
      expect(restored.isCompleted, todo.isCompleted);
    });
  });
}
