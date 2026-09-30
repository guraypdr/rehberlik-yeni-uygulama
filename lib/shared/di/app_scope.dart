import 'package:flutter/widgets.dart';

import '../../features/todos/presentation/todo_controller.dart';

/// Uygulama genelinde paylaşılan, uygulama ömrü boyunca yaşayan
/// bağımlılıklar.
///
/// Yeni bir modül eklendiğinde repository ve controller buraya bir alan olarak
/// eklenir; sayfalar `context` üzerinden erişir, böylece sayfaların
/// constructor'ları bağımlılık listesiyle şişmez.
class AppDependencies {
  const AppDependencies({required this.todos});

  final TodoController todos;
}

/// [AppDependencies] değerini alt ağaca taşır.
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.dependencies, required super.child});

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope bulunamadı.');
    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      oldWidget.dependencies != dependencies;
}
