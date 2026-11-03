import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_header.dart';
import '../domain/teacher.dart';
import 'teachers_provider.dart';
import 'widgets/teacher_composer.dart';
import 'widgets/teacher_row.dart';

/// Öğretmenler modülü.
class TeachersPage extends ConsumerWidget {
  const TeachersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTeachers = ref.watch(teachersProvider);

    return asyncTeachers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (teachers) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Öğretmenler',
            subtitle: teachers.isEmpty
                ? 'Henüz öğretmen eklenmedi'
                : '${teachers.length} öğretmen',
          ),
          const TeacherComposer(),
          const SizedBox(height: AppSpacing.xl),
          Expanded(child: _TeacherList(teachers: teachers)),
        ],
      ),
    );
  }
}

class _TeacherList extends ConsumerWidget {
  const _TeacherList({required this.teachers});

  final List<Teacher> teachers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (teachers.isEmpty) return const _EmptyState();

    final notifier = ref.read(teachersProvider.notifier);

    return ListView(
      key: const Key('teacher_list'),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < teachers.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                  ),
                TeacherRow(
                  key: ValueKey<int>(teachers[i].id),
                  teacher: teachers[i],
                  onDelete: () => notifier.deleteTeacher(teachers[i].id),
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
              Icons.person_off_outlined,
              color: AppColors.textMuted,
              size: 30,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Henüz öğretmen yok', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Yukarıdaki alandan yeni bir öğretmen ekleyebilirsiniz.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
