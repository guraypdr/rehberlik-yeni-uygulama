/// Yapılacaklar listesindeki tek bir görev.
class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  final int id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  TodoItem copyWith({String? title, bool? isCompleted}) => TodoItem(
    id: id,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'is_completed': isCompleted ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
  };

  static TodoItem fromMap(Map<String, Object?> map) => TodoItem(
    id: map['id']! as int,
    title: map['title']! as String,
    isCompleted: (map['is_completed'] as int) == 1,
    createdAt: DateTime.parse(map['created_at']! as String),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoItem &&
          other.id == id &&
          other.title == title &&
          other.isCompleted == isCompleted;

  @override
  int get hashCode => Object.hash(id, title, isCompleted);

  @override
  String toString() => 'TodoItem($id, $title, completed=$isCompleted)';
}
