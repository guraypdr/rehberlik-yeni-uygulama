import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/grade_level.dart';
import '../../domain/school_class.dart';
import '../classes_provider.dart';
import 'class_edit_dialog.dart';
import 'class_students_dialog.dart';

/// Tek bir şubenin kartı.
class ClassCard extends ConsumerWidget {
  const ClassCard({
    super.key,
    required this.schoolClass,
    required this.gradeLevels,
    this.fields = const [],
  });

  final SchoolClass schoolClass;
  final List<GradeLevel> gradeLevels;
  final List<String> fields;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(classesProvider.notifier);

    Future<void> editClass() async {
      final updated = await showDialog<SchoolClass>(
        context: context,
        builder: (context) => ClassEditDialog(
          schoolClass: schoolClass,
          gradeLevels: gradeLevels,
          fields: fields,
        ),
      );
      if (updated != null) await notifier.updateClass(updated);
    }

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Düzey rozeti
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.sm),
                ),
              ),
              child: Text(
                schoolClass.gradeLevelLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: () => ClassStudentsDialog.show(context, schoolClass),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        schoolClass.displayName,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Öğrencileri görüntüle ve ekle',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              key: Key('class_edit_${schoolClass.id}'),
              onPressed: editClass,
              visualDensity: VisualDensity.compact,
              tooltip: 'Sınıfı düzenle',
              icon: const Icon(Icons.edit_outlined, size: 19),
            ),
            IconButton(
              key: Key('class_delete_${schoolClass.id}'),
              onPressed: () => notifier.deleteClass(schoolClass.id),
              visualDensity: VisualDensity.compact,
              tooltip: 'Şubeyi sil',
              icon: const Icon(Icons.delete_outline_rounded, size: 19),
              color: AppColors.danger,
            ),
          ],
        ),
      ),
    );
  }
}
