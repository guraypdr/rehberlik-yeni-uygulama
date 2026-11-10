import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_header.dart';
import '../../setup/domain/school_profile.dart';
import '../../setup/presentation/widgets/field_chip_editor.dart';
import '../domain/grade_level.dart';
import '../domain/school_class.dart';
import 'classes_provider.dart';
import 'school_risk_map_page.dart';
import 'school_risk_provider.dart';
import 'widgets/class_card.dart';
import 'widgets/class_composer.dart';

/// Sınıflar modülü.
class ClassesPage extends ConsumerStatefulWidget {
  const ClassesPage({super.key});

  @override
  ConsumerState<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends ConsumerState<ClassesPage> {
  Future<void> _saveFields(List<String> fields) async {
    try {
      await ref.read(sessionProvider.notifier).updateSchoolFields(fields);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Okul alanları kaydedilemedi: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncClasses = ref.watch(classesProvider);
    final profile = ref.watch(sessionProvider).valueOrNull?.schoolProfile;
    final fields = profile?.fields ?? const <String>[];
    final supportsFields =
        profile?.schoolType == SchoolType.lise ||
        profile?.schoolType == SchoolType.meslekLisesi;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: PageHeader(title: 'Sınıflar', subtitle: subtitle)),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: OutlinedButton.icon(
                    key: const Key('open_school_risk_map'),
                    onPressed: () {
                      ref.invalidate(schoolRiskCountsProvider);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SchoolRiskMapPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.view_column_outlined, size: 18),
                    label: const Text('Okul Risk Haritası'),
                  ),
                ),
              ],
            ),
            if (supportsFields) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Okul Alanları',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Şubeleri alanlara göre gruplamak için alan ekleyin.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FieldChipEditor(fields: fields, onChanged: _saveFields),
                  ],
                ),
              ),
            ],
            ClassComposer(fields: fields, requiresField: supportsFields),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: state.classes.isEmpty
                  ? const _EmptyState()
                  : _ClassList(
                      classes: state.classes,
                      gradeLevels: state.gradeLevels,
                      fields: fields,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ClassList extends StatelessWidget {
  const _ClassList({
    required this.classes,
    required this.gradeLevels,
    required this.fields,
  });

  final List<SchoolClass> classes;
  final List<GradeLevel> gradeLevels;
  final List<String> fields;

  @override
  Widget build(BuildContext context) {
    final groupedClasses = <(String, List<SchoolClass>)>[];
    if (fields.isEmpty) {
      groupedClasses.add(('', classes));
    } else {
      for (final field in fields) {
        final fieldClasses = classes
            .where((schoolClass) => schoolClass.fieldName == field)
            .toList();
        if (fieldClasses.isNotEmpty) {
          groupedClasses.add((field, fieldClasses));
        }
      }
      final unassignedClasses = classes
          .where(
            (schoolClass) =>
                schoolClass.fieldName == null ||
                !fields.contains(schoolClass.fieldName),
          )
          .toList();
      if (unassignedClasses.isNotEmpty) {
        groupedClasses.add(('Alan belirtilmemiş', unassignedClasses));
      }
    }

    return ListView(
      key: const Key('class_list'),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        for (final group in groupedClasses) _fieldGroup(group.$1, group.$2),
      ],
    );
  }

  Widget _fieldGroup(String title, List<SchoolClass> classes) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final columnCount = constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 560
                ? 2
                : 1;
            const spacing = AppSpacing.md;
            final cardWidth =
                (constraints.maxWidth - spacing * (columnCount - 1)) /
                columnCount;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final schoolClass in classes)
                  SizedBox(width: cardWidth, child: _classCard(schoolClass)),
              ],
            );
          },
        ),
      ],
    ),
  );

  Widget _classCard(SchoolClass schoolClass) => ClassCard(
    key: ValueKey<int>(schoolClass.id),
    schoolClass: schoolClass,
    gradeLevels: gradeLevels,
    fields: fields,
  );
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
