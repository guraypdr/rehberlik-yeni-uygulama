import '../domain/todo_item.dart';

/// Yapılacaklar veri kaynağı.
///
/// Aşama 1'de bellek içi [InMemoryTodoRepository] kullanılır. Sonraki
/// aşamada bu arayüzün sunucu tabanlı bir uygulaması (örneğin
/// `SupabaseTodoRepository`) eklenerek veri Supabase'e taşınabilecek. Bu
/// yüzden tüm işlemler asenkron tanımlanmıştır ve arayüzün parçası değildir.
///
/// Sunucuya geçildiğinde kayıtların oturumdaki kullanıcıyla ilişkilendirilmesi
/// bu katmanda ele alınacaktır.
abstract interface class TodoRepository {
  Future<List<TodoItem>> fetchTodos();

  Future<TodoItem> createTodo({required String title});

  Future<TodoItem> setCompleted({
    required String id,
    required bool isCompleted,
  });

  Future<void> deleteTodo(String id);
}

/// Aşama 1 için bellek içi uygulama.
///
/// Veriler yalnızca uygulama açıkken tutulur, kapatıldığında kaybolur.
class InMemoryTodoRepository implements TodoRepository {
  InMemoryTodoRepository({List<TodoItem> seedItems = const <TodoItem>[]})
    : _items = List<TodoItem>.of(seedItems);

  final List<TodoItem> _items;
  int _nextId = 1;

  @override
  Future<List<TodoItem>> fetchTodos() async {
    return List<TodoItem>.unmodifiable(_items);
  }

  @override
  Future<TodoItem> createTodo({required String title}) async {
    final todo = TodoItem(
      id: 'todo_${_nextId++}',
      title: title,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    _items.add(todo);
    return todo;
  }

  @override
  Future<TodoItem> setCompleted({
    required String id,
    required bool isCompleted,
  }) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      throw StateError('Görev bulunamadı: $id');
    }
    final updated = _items[index].copyWith(isCompleted: isCompleted);
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteTodo(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}
