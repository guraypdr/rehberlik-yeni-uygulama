import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../students/domain/student.dart';
import '../../../students/presentation/students_provider.dart';
import '../../../teachers/domain/teacher.dart';
import '../../../teachers/presentation/teachers_provider.dart';
import '../../domain/grade_level.dart';
import '../../domain/school_class.dart';
import '../classes_provider.dart';
import '../class_dashboard_page.dart';
import 'class_edit_dialog.dart';

/// Tek bir şubenin kompakt kartı.
class ClassCard extends ConsumerStatefulWidget {
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
  ConsumerState<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends ConsumerState<ClassCard> {
  bool _hovered = false;

  Future<void> _editClass() async {
    final updated = await showDialog<SchoolClass>(
      context: context,
      builder: (context) => ClassEditDialog(
        schoolClass: widget.schoolClass,
        gradeLevels: widget.gradeLevels,
        fields: widget.fields,
      ),
    );
    if (updated != null) {
      await ref.read(classesProvider.notifier).updateClass(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final schoolClass = widget.schoolClass;

    final teachers =
        ref.watch(teachersProvider).valueOrNull ?? const <Teacher>[];
    final students =
        ref.watch(studentsProvider).valueOrNull ?? const <Student>[];
    final teacher = teachers
        .where((item) => item.id == schoolClass.teacherId)
        .firstOrNull;
    final studentCount = students
        .where((student) => student.classId == schoolClass.id)
        .length;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AppCard(
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        borderColor: _hovered
            ? cs.primary.withValues(alpha: 0.45)
            : AppColors.border,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: Key('class_open_${schoolClass.id}'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ClassDashboardPage(schoolClass: schoolClass),
              ),
            ),
            child: Container(
              // Sol renkli şerit.
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: cs.primary, width: 4)),
              ),
              padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ClassBadge(color: cs.primary),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              schoolClass.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              schoolClass.gradeLevelLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _MiniIconButton(
                        key: Key('class_edit_${schoolClass.id}'),
                        icon: Icons.edit_outlined,
                        tooltip: 'Sınıfı düzenle',
                        onPressed: _editClass,
                      ),
                      _MiniIconButton(
                        key: Key('class_delete_${schoolClass.id}'),
                        icon: Icons.delete_outline_rounded,
                        tooltip: 'Şubeyi sil',
                        color: AppColors.danger,
                        onPressed: () => ref
                            .read(classesProvider.notifier)
                            .deleteClass(schoolClass.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 15,
                        color: teacher == null
                            ? AppColors.textMuted
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          teacher?.fullName ?? 'Rehber öğretmen atanmadı',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: teacher == null
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _CountPill(count: studentCount, color: cs.primary),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kart başlığındaki gradyan ikon rozeti.
class _ClassBadge extends StatelessWidget {
  const _ClassBadge({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.16)!,
            Color.lerp(color, Colors.black, 0.16)!,
          ],
        ),
      ),
      child: const Icon(Icons.groups_rounded, size: 21, color: Colors.white),
    );
  }
}

/// Kart içindeki küçük öğrenci sayısı etiketi.
class _CountPill extends StatelessWidget {
  const _CountPill({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_alt_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kart başlığındaki kompakt ikon butonu.
class _MiniIconButton extends StatelessWidget {
  const _MiniIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 17,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      color: color,
      icon: Icon(icon),
    );
  }
}
