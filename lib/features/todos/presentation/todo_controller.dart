import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/todo_repository.dart';
import '../domain/todo_item.dart';

/// Yapılacaklar sayfasının durum yönetimi.
///
/// Sayfa veriyi doğrudan repository'den değil buradan okur; böylece veri
/// kaynağı değiştiğinde (bellek -> Supabase) arayüzün değişmesi gerekmez.
class TodoController extends ChangeNotifier {
  TodoController({required TodoRepository repository})
    : _repository = repository {
    unawaited(load());
  }

  final TodoRepository _repository;

  List<TodoItem> _items = const <TodoItem>[];
  bool _isLoading = true;
  String? _errorMessage;

  /// Tamamlanmamış görevler önce, tamamlananlar en son gösterilir.
  List<TodoItem> get items => List<TodoItem>.unmodifiable(_items);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get pendingCount => _items.where((item) => !item.isCompleted).length;
  int get completedCount => _items.where((item) => item.isCompleted).length;
  bool get isEmpty => !_isLoading && _items.isEmpty;

  /// Özet metni: örneğin "3 açık görev • 1 tamamlandı".
  String get summary {
    if (isEmpty) {
      return 'Henüz görev yok';
    }
    if (completedCount == 0) {
      return '$pendingCount açık görev';
    }
    if (pendingCount == 0) {
      return 'Tüm görevler tamamlandı';
    }
    return '$pendingCount açık görev • $completedCount tamamlandı';
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = _sort(await _repository.fetchTodos());
    } catch (_) {
      _errorMessage = 'Görevler yüklenemedi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Yeni görev ekler. Boş başlık eklenmez.
  Future<void> addTodo(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return;
    }
    try {
      final created = await _repository.createTodo(title: trimmed);
      _items = _sort(<TodoItem>[..._items, created]);
      _errorMessage = null;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Görev eklenemedi.';
      notifyListeners();
    }
  }

  Future<void> toggleTodo(TodoItem todo) async {
    try {
      final updated = await _repository.setCompleted(
        id: todo.id,
        isCompleted: !todo.isCompleted,
      );
      _items = _sort(<TodoItem>[
        for (final item in _items) item.id == updated.id ? updated : item,
      ]);
      _errorMessage = null;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Görev güncellenemedi.';
      notifyListeners();
    }
  }

  Future<void> removeTodo(String id) async {
    try {
      await _repository.deleteTodo(id);
      _items = _items.where((item) => item.id != id).toList(growable: false);
      _errorMessage = null;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Görev silinemedi.';
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  /// Tamamlanmamışlar önce; kendi grupları içinde en yeni görev üstte.
  static List<TodoItem> _sort(List<TodoItem> items) {
    return List<TodoItem>.of(items)..sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
  }
}
