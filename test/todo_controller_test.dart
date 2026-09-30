import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/features/todos/data/todo_repository.dart';
import 'package:rehberlik_app/features/todos/domain/todo_item.dart';
import 'package:rehberlik_app/features/todos/presentation/todo_controller.dart';

void main() {
  group('TodoController', () {
    late TodoController controller;

    setUp(() async {
      controller = TodoController(repository: InMemoryTodoRepository());
      await controller.load();
    });

    tearDown(() => controller.dispose());

    test('başlangıçta liste boştur', () {
      expect(controller.items, isEmpty);
      expect(controller.isEmpty, isTrue);
      expect(controller.summary, 'Henüz görev yok');
    });

    test('başlıktaki boşluklar temizlenerek görev ekler', () async {
      await controller.addTodo('  Veli görüşmesi  ');

      expect(controller.items, hasLength(1));
      expect(controller.items.single.title, 'Veli görüşmesi');
      expect(controller.items.single.isCompleted, isFalse);
      expect(controller.summary, '1 açık görev');
    });

    test('boş başlıklı görev eklemez', () async {
      await controller.addTodo('   ');

      expect(controller.items, isEmpty);
    });

    test('tamamlanan görevler listenin sonuna taşınır', () async {
      await controller.addTodo('Birinci');
      await controller.addTodo('İkinci');
      final first = controller.items.first;

      await controller.toggleTodo(first);

      expect(controller.items.first.title, 'İkinci');
      expect(controller.items.last.title, 'Birinci');
      expect(controller.items.last.isCompleted, isTrue);
      expect(controller.completedCount, 1);
    });

    test('görev tamamlandıktan sonra geri açılabilir', () async {
      await controller.addTodo('Rapor yaz');
      final todo = controller.items.single;

      await controller.toggleTodo(todo);
      await controller.toggleTodo(controller.items.single);

      expect(controller.items.single.isCompleted, isFalse);
      expect(controller.pendingCount, 1);
      expect(controller.completedCount, 0);
    });

    test('görev silinir', () async {
      await controller.addTodo('Silinecek');
      final id = controller.items.single.id;

      await controller.removeTodo(id);

      expect(controller.items, isEmpty);
    });

    test('repository hatası kullanıcıya mesaj olarak döner', () async {
      final controller = TodoController(repository: _FailingTodoRepository());
      await controller.load();

      expect(controller.errorMessage, 'Görevler yüklenemedi.');
      controller.dispose();
    });

    test('summary tüm görevler tamamlandığında bilgilendirir', () async {
      await controller.addTodo('Bir');
      await controller.addTodo('İki');
      for (final todo in controller.items) {
        await controller.toggleTodo(todo);
      }

      expect(controller.summary, 'Tüm görevler tamamlandı');
    });
  });

  group('TodoItem', () {
    test('copyWith yalnızca verilen alanı değiştirir', () {
      final createdAt = DateTime(2026, 1, 1);
      final todo = TodoItem(
        id: '1',
        title: 'Başlık',
        isCompleted: false,
        createdAt: createdAt,
      );

      final updated = todo.copyWith(isCompleted: true);

      expect(updated.id, todo.id);
      expect(updated.title, todo.title);
      expect(updated.createdAt, createdAt);
      expect(updated.isCompleted, isTrue);
    });

    test('aynı alanlara sahip iki görev eşittir', () {
      final createdAt = DateTime(2026, 1, 1);
      final first = TodoItem(
        id: '1',
        title: 'Başlık',
        isCompleted: false,
        createdAt: createdAt,
      );
      final second = TodoItem(
        id: '1',
        title: 'Başlık',
        isCompleted: false,
        createdAt: createdAt,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}

class _FailingTodoRepository implements TodoRepository {
  @override
  Future<List<TodoItem>> fetchTodos() async => throw StateError('Sunucu yok');

  @override
  Future<TodoItem> createTodo({required String title}) =>
      throw StateError('Sunucu yok');

  @override
  Future<TodoItem> setCompleted({
    required String id,
    required bool isCompleted,
  }) => throw StateError('Sunucu yok');

  @override
  Future<void> deleteTodo(String id) => throw StateError('Sunucu yok');
}
