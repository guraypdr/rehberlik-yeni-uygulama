import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../students/domain/student.dart';
import '../../../teachers/domain/teacher.dart';
import '../../../teachers/presentation/teachers_provider.dart';
import '../../domain/student_subject_need.dart';
import '../student_subject_needs_provider.dart';

class StudentSubjectNeedsDialog extends ConsumerWidget {
  const StudentSubjectNeedsDialog({super.key, required this.student});

  final Student student;

  static Future<void> show(BuildContext context, Student student) =>
      showDialog<void>(
        context: context,
        builder: (_) => StudentSubjectNeedsDialog(student: student),
      );

  Future<void> _updateNeed(
    BuildContext context,
    WidgetRef ref,
    StudentSubjectNeed need, {
    bool? requiresSupportEducation,
    bool? requiresBep,
    bool? isExempt,
  }) async {
    try {
      await ref
          .read(studentSubjectNeedsProvider(student.id).notifier)
          .setNeeds(
            need: need,
            requiresSupportEducation: requiresSupportEducation,
            requiresBep: requiresBep,
            isExempt: isExempt,
          );
    } catch (error) {
      _showError(context, 'Ders ihtiyacı kaydedilemedi: $error');
    }
  }

  Future<void> _updateSupportPlan(
    BuildContext context,
    WidgetRef ref,
    StudentSubjectNeed need, {
    int? supportHours,
    int? supportTeacherId,
    bool clearSupportTeacher = false,
  }) async {
    try {
      await ref
          .read(studentSubjectNeedsProvider(student.id).notifier)
          .setSupportPlan(
            need: need,
            supportHours: supportHours ?? need.effectiveSupportHours,
            supportTeacherId: clearSupportTeacher
                ? null
                : (supportTeacherId ?? need.supportTeacherId),
          );
    } catch (error) {
      _showError(context, 'Destek eğitimi planı kaydedilemedi: $error');
    }
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsAsync = ref.watch(studentSubjectNeedsProvider(student.id));
    final teachers =
        ref.watch(teachersProvider).valueOrNull ?? const <Teacher>[];
    final size = MediaQuery.sizeOf(context);

    return AlertDialog(
      title: Text('${student.fullName} · Ders ihtiyaçları'),
      content: SizedBox(
        width: (size.width - 80).clamp(300.0, 720.0).toDouble(),
        height: (size.height - 260).clamp(240.0, 560.0).toDouble(),
        child: needsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Öğrencinin dersleri yüklenemedi: $error')),
          data: (needs) => needs.isEmpty
              ? const EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'Ders bulunmuyor',
                  message: 'Bu öğrencinin sınıfına henüz ders eklenmemiş.',
                )
              : ListView(
                  children: [
                    Text(
                      '${student.displayClass} dersleri için ihtiyaçları seçin. '
                      'Destek Eğitim, BEP ve Muaf seçeneklerinden biri '
                      'işaretlenebilir; hiçbiri seçilmezse ders normal eğitim '
                      'programına devam eder. Destek eğitimi seçilen derslerde '
                      'kararlaştırılan ders saati ve dersi verecek öğretmen '
                      'belirlenir.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final need in needs)
                      AppCard(
                        key: Key('student_subject_need_${need.classSubjectId}'),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              need.subjectName,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${need.weeklyHours} saat/hafta'
                              '${need.teacherName == null ? '' : ' · ${need.teacherName}'}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.xs,
                              children: [
                                FilterChip(
                                  key: Key(
                                    'support_need_${need.classSubjectId}',
                                  ),
                                  selected: need.requiresSupportEducation,
                                  label: const Text('Destek Eğitim'),
                                  onSelected: (selected) => _updateNeed(
                                    context,
                                    ref,
                                    need,
                                    requiresSupportEducation: selected,
                                    requiresBep: selected ? false : null,
                                    isExempt: selected ? false : null,
                                  ),
                                ),
                                FilterChip(
                                  key: Key('bep_need_${need.classSubjectId}'),
                                  selected: need.requiresBep,
                                  label: const Text('BEP'),
                                  onSelected: (selected) => _updateNeed(
                                    context,
                                    ref,
                                    need,
                                    requiresBep: selected,
                                    requiresSupportEducation: selected
                                        ? false
                                        : null,
                                    isExempt: selected ? false : null,
                                  ),
                                ),
                                FilterChip(
                                  key: Key(
                                    'exempt_need_${need.classSubjectId}',
                                  ),
                                  selected: need.isExempt,
                                  label: const Text('Muaf'),
                                  onSelected: (selected) => _updateNeed(
                                    context,
                                    ref,
                                    need,
                                    isExempt: selected,
                                    requiresSupportEducation: selected
                                        ? false
                                        : null,
                                    requiresBep: selected ? false : null,
                                  ),
                                ),
                              ],
                            ),
                            if (need.requiresSupportEducation) ...[
                              const SizedBox(height: AppSpacing.sm),
                              _supportPlan(
                                context,
                                ref,
                                need,
                                teachers,
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
      ],
    );
  }

  /// Destek eğitimi kararı verilen dersin saat tablosu ve öğretmen seçimi.
  Widget _supportPlan(
    BuildContext context,
    WidgetRef ref,
    StudentSubjectNeed need,
    List<Teacher> teachers,
  ) {
    final hours = need.effectiveSupportHours ?? need.suggestedSupportHours;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Haftalık Ders Saati',
                  style: textTheme.bodySmall,
                ),
              ),
              Text('${need.weeklyHours}', style: textTheme.bodyMedium),
            ],
          ),
          const Divider(height: AppSpacing.md),
          Padding(
            key: Key('support_hours_${need.classSubjectId}'),
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Destek Eğitimi Ders Saati',
                    style: textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  key: Key('support_hours_decrease_${need.classSubjectId}'),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Azalt',
                  onPressed: hours <= 1
                      ? null
                      : () => _updateSupportPlan(
                          context,
                          ref,
                          need,
                          supportHours: hours - 1,
                        ),
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                ),
                Text(
                  '$hours',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  key: Key('support_hours_increase_${need.classSubjectId}'),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Artır',
                  onPressed: hours >= need.weeklyHours
                      ? null
                      : () => _updateSupportPlan(
                          context,
                          ref,
                          need,
                          supportHours: hours + 1,
                        ),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                ),
              ],
            ),
          ),
          const Divider(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Destek Eğitim Öğretmeni',
                  style: textTheme.bodySmall,
                ),
              ),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<int?>(
                  key: Key('support_teacher_${need.classSubjectId}'),
                  initialValue: need.supportTeacherId,
                  isDense: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Öğretmen seçin',
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Öğretmen seçilmedi'),
                    ),
                    for (final teacher in teachers)
                      DropdownMenuItem<int?>(
                        value: teacher.id,
                        child: Text(teacher.fullName),
                      ),
                  ],
                  onChanged: (value) => _updateSupportPlan(
                    context,
                    ref,
                    need,
                    supportTeacherId: value,
                    clearSupportTeacher: value == null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
