import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
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
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Yeni Öğretmen',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                const TeacherComposer(),
              ],
            ),
          ),
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
        AppCard(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
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
    return const EmptyState(
      icon: Icons.person_off_outlined,
      title: 'Henüz öğretmen yok',
      message: 'Yukarıdaki alandan yeni bir öğretmen ekleyebilirsiniz.',
    );
  }
}
