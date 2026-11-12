import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/page_header.dart';
import '../domain/todo_item.dart';
import 'todos_provider.dart';
import 'widgets/todo_composer.dart';
import 'widgets/todo_row.dart';

/// Yapılacaklar Listesi.
class TodosPage extends ConsumerWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(todosProvider);

    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(title: 'Yapılacaklar', subtitle: state.summary),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Yeni Görev',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                const TodoComposer(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(child: _TodoList(state: state)),
        ],
      ),
    );
  }
}

class _TodoList extends ConsumerWidget {
  const _TodoList({required this.state});

  final TodosState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isEmpty) return const _EmptyState();

    final pending = state.items.where((i) => !i.isCompleted).toList();
    final completed = state.items.where((i) => i.isCompleted).toList();
    final notifier = ref.read(todosProvider.notifier);

    return ListView(
      key: const Key('todo_list'),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        if (pending.isNotEmpty)
          _TodoGroup(
            title: 'Açık görevler',
            items: pending,
            notifier: notifier,
          ),
        if (pending.isNotEmpty && completed.isNotEmpty)
          const SizedBox(height: AppSpacing.xl),
        if (completed.isNotEmpty)
          _TodoGroup(
            title: 'Tamamlananlar',
            items: completed,
            notifier: notifier,
          ),
      ],
    );
  }
}

class _TodoGroup extends StatelessWidget {
  const _TodoGroup({
    required this.title,
    required this.items,
    required this.notifier,
  });

  final String title;
  final List<TodoItem> items;
  final TodosNotifier notifier;

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
        AppCard(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                  ),
                TodoRow(
                  key: ValueKey<int>(items[i].id),
                  todo: items[i],
                  onToggle: () => notifier.toggleTodo(items[i]),
                  onDelete: () => notifier.removeTodo(items[i].id),
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
    return const EmptyState(
      icon: Icons.inbox_outlined,
      title: 'Listeniz boş',
      message: 'Yukarıdaki alandan yeni bir görev ekleyebilirsiniz.',
    );
  }
}
