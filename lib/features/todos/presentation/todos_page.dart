import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/di/app_scope.dart';
import '../../../shared/widgets/page_header.dart';
import '../domain/todo_item.dart';
import 'todo_controller.dart';
import 'widgets/todo_composer.dart';
import 'widgets/todo_row.dart';

/// Yapılacaklar Listesi.
///
/// Aşama 1'de görevler bellekte tutulur. Veri kaynağı
/// [TodoController] üzerinden değiştirilebilir olacaktır.
class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).todos;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          // Alt bileşenler (özellikle ekleme alanı) içerik genişliğine göre
          // dizilsin diye tüm satırlar tam genişlikte açılır.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(title: 'Yapılacaklar', subtitle: controller.summary),
            const TodoComposer(),
            const SizedBox(height: AppSpacing.xl),
            Expanded(child: _TodoList(controller: controller)),
          ],
        );
      },
    );
  }
}

class _TodoList extends StatelessWidget {
  const _TodoList({required this.controller});

  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final items = controller.items;
    if (items.isEmpty) {
      return const _EmptyState();
    }

    final pending = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();

    return ListView(
      key: const Key('todo_list'),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        if (pending.isNotEmpty)
          _TodoGroup(
            title: 'Açık görevler',
            items: pending,
            controller: controller,
          ),
        if (pending.isNotEmpty && completed.isNotEmpty)
          const SizedBox(height: AppSpacing.xl),
        if (completed.isNotEmpty)
          _TodoGroup(
            title: 'Tamamlananlar',
            items: completed,
            controller: controller,
          ),
      ],
    );
  }
}

/// Başlıklı, tek yüzeyli görev grubu. Her görev kendi kutusunda değil, aynı
/// yüzeyde satır olarak gösterilir; arayüz kalabalıklaşmaz.
class _TodoGroup extends StatelessWidget {
  const _TodoGroup({
    required this.title,
    required this.items,
    required this.controller,
  });

  final String title;
  final List<TodoItem> items;
  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(title.toUpperCase(), style: theme.textTheme.labelMedium),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                if (index > 0)
                  const Divider(
                    height: 1,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                  ),
                TodoRow(
                  key: ValueKey<String>(items[index].id),
                  todo: items[index],
                  onToggle: () => controller.toggleTodo(items[index]),
                  onDelete: () => controller.removeTodo(items[index].id),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              color: AppColors.textMuted,
              size: 30,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Listeniz boş', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Yukarıdaki alandan yeni bir görev ekleyebilirsiniz.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
