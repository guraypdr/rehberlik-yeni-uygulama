import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../data/todo_dao.dart';
import '../domain/todo_item.dart';

/// Yapılacaklar listesi durum sınıfı.
class TodosState {
  const TodosState({
    this.items = const [],
    this.errorMessage,
  });

  final List<TodoItem> items;
  final String? errorMessage;

  int get pendingCount => items.where((i) => !i.isCompleted).length;
  int get completedCount => items.where((i) => i.isCompleted).length;
  bool get isEmpty => items.isEmpty;

  String get summary {
    if (isEmpty) return 'Henüz görev yok';
    if (completedCount == 0) return '$pendingCount açık görev';
    if (pendingCount == 0) return 'Tüm görevler tamamlandı';
    return '$pendingCount açık görev • $completedCount tamamlandı';
  }

  TodosState copyWith({List<TodoItem>? items, String? errorMessage,
      bool clearError = false}) =>
      TodosState(
        items: items ?? this.items,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

/// Yapılacaklar AsyncNotifier.
class TodosNotifier extends AsyncNotifier<TodosState> {
  TodoDao? _dao;

  @override
  Future<TodosState> build() async {
    final db = ref.watch(databaseProvider);
    if (db == null) return const TodosState();
    _dao = TodoDao(db);
    final items = await _dao!.fetchAll();
    return TodosState(items: items);
  }

  Future<void> addTodo(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty || _dao == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final created = await _dao!.insert(trimmed);
      final current = state.valueOrNull ?? const TodosState();
      return current.copyWith(items: [created, ...current.items]);
    });
  }

  Future<void> toggleTodo(TodoItem todo) async {
    if (_dao == null) return;
    final current = state.valueOrNull;
    if (current == null) return;
    final newVal = !todo.isCompleted;
    await _dao!.setCompleted(todo.id, isCompleted: newVal);
    final updated = todo.copyWith(isCompleted: newVal);
    final newItems = _sort([
      for (final item in current.items)
        item.id == todo.id ? updated : item,
    ]);
    state = AsyncValue.data(current.copyWith(items: newItems));
  }

  Future<void> removeTodo(int id) async {
    if (_dao == null) return;
    await _dao!.delete(id);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(
      current.copyWith(items: current.items.where((i) => i.id != id).toList()),
    );
  }

  static List<TodoItem> _sort(List<TodoItem> items) {
    return List<TodoItem>.of(items)..sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return b.createdAt.compareTo(a.createdAt);
    });
  }
}

final todosProvider =
    AsyncNotifierProvider<TodosNotifier, TodosState>(TodosNotifier.new);
