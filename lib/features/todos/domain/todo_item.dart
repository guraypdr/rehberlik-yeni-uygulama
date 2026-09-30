/// Yapılacaklar listesindeki tek bir görev.
///
/// Sonraki aşamalarda açıklama, son tarih, öncelik, öğrenci bağlantısı,
/// kategori ve hatırlatma alanları bu modele eklenecek. Bu aşamada yalnızca
/// listeyi çalıştırmak için gereken alanlar yer alır.
class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  TodoItem copyWith({String? title, bool? isCompleted}) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TodoItem &&
            other.id == id &&
            other.title == title &&
            other.isCompleted == isCompleted &&
            other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, title, isCompleted, createdAt);

  @override
  String toString() =>
      'TodoItem(id: $id, title: $title, isCompleted: $isCompleted)';
}
