import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_header.dart';
import '../domain/school_class.dart';
import 'classes_provider.dart';
import 'widgets/class_card.dart';
import 'widgets/class_composer.dart';

/// Sınıflar modülü.
class ClassesPage extends ConsumerWidget {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncClasses = ref.watch(classesProvider);

    return asyncClasses.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (state) {
        final subtitle = state.classes.isEmpty
            ? 'Henüz sınıf eklenmedi'
            : '${state.classes.length} şube';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(title: 'Sınıflar', subtitle: subtitle),
            const ClassComposer(),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: state.classes.isEmpty
                  ? const _EmptyState()
                  : _ClassList(classes: state.classes),
            ),
          ],
        );
      },
    );
  }
}

class _ClassList extends StatelessWidget {
  const _ClassList({required this.classes});

  final List<SchoolClass> classes;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('class_list'),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        for (final schoolClass in classes)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ClassCard(
              key: ValueKey<int>(schoolClass.id),
              schoolClass: schoolClass,
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
              Icons.meeting_room_outlined,
              color: AppColors.textMuted,
              size: 30,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Henüz sınıf yok', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Yukarıdaki alandan yeni bir sınıf ekleyebilirsiniz.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
