import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/todos/data/todo_repository.dart';
import '../../features/todos/domain/todo_item.dart';
import '../../features/todos/presentation/todo_controller.dart';
import '../di/app_scope.dart';
import '../navigation/app_navigation.dart';
import 'app_sidebar.dart';

/// Uygulamanın ana yerleşimi: solda navigasyon, sağda içerik.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// Uygulamanın bağımlılıkları burada oluşturulur (composition root).
  /// Aşama 1'de veri kaynağı bellek içidir; sonraki aşamada burada Supabase
  /// repository kullanılacak, sayfalar değişmeyecek.
  late final AppDependencies _dependencies = AppDependencies(
    todos: TodoController(
      repository: InMemoryTodoRepository(seedItems: _sampleTodos()),
    ),
  );

  String _selectedId = initialDestinationId;

  @override
  void dispose() {
    _dependencies.todos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: _dependencies,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Pencere daraldığında menü ikon şeridine dönüşür; içerik alanı
          // esnek kalır.
          final collapsed = constraints.maxWidth < 1000;
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSidebar(
                    destinations: appDestinations,
                    selectedId: _selectedId,
                    collapsed: collapsed,
                    onSelected: _selectDestination,
                  ),
                  const VerticalDivider(width: 1, color: AppColors.border),
                  Expanded(
                    child: _buildContentArea(
                      contentWidth:
                          constraints.maxWidth -
                          (collapsed
                              ? AppSidebar.collapsedWidth
                              : AppSidebar.expandedWidth),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentArea({required double contentWidth}) {
    final padding = contentWidth < 720 ? AppSpacing.lg : AppSpacing.xxl;
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, AppSpacing.xl, padding, 0),
      child: Center(
        child: ConstrainedBox(
          // Geniş ekranlarda satırların okunabilirliğini korumak için içerik
          // alanı belli bir genişliği aşmaz.
          constraints: const BoxConstraints(maxWidth: 960),
          child: _buildPageStack(),
        ),
      ),
    );
  }

  /// Sayfalar `IndexedStack` içinde tutulur: yalnızca seçili sayfa görünür,
  /// diğerleri canlı kalır. Böylece menüden çıkıp geri dönüldüğünde metin
  /// kutusu ve kaydırma konumu gibi arayüz durumu korunur.
  Widget _buildPageStack() {
    final selectedIndex = appDestinations.indexWhere(
      (destination) => destination.id == _selectedId,
    );

    return IndexedStack(
      index: selectedIndex < 0 ? 0 : selectedIndex,
      children: [
        for (final destination in appDestinations)
          KeyedSubtree(
            key: ValueKey<String>('page_${destination.id}'),
            child: Builder(builder: destination.builder),
          ),
      ],
    );
  }

  void _selectDestination(String id) {
    if (_selectedId == id) {
      return;
    }
    setState(() => _selectedId = id);
  }
}

/// Aşama 1'de liste boş görünmesin diye kullanılan örnek görevler.
/// Veri kaynağı Supabase'e geçtiğinde bu liste kaldırılacaktır.
List<TodoItem> _sampleTodos() {
  final now = DateTime.now();
  return <TodoItem>[
    TodoItem(
      id: 'sample_1',
      title: 'Veli toplantı programını hazırlık',
      isCompleted: false,
      createdAt: now,
    ),
    TodoItem(
      id: 'sample_2',
      title: 'Öğrenci dosyalarını güncelle',
      isCompleted: false,
      createdAt: now.subtract(const Duration(minutes: 5)),
    ),
    TodoItem(
      id: 'sample_3',
      title: 'Sınıf öğretmeni ile görüşme notlarını paylaş',
      isCompleted: true,
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
  ];
}
