import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../students/domain/student.dart';
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
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ders ihtiyacı kaydedilemedi: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsAsync = ref.watch(studentSubjectNeedsProvider(student.id));
    final size = MediaQuery.sizeOf(context);

    return AlertDialog(
      title: Text('${student.fullName} · Ders ihtiyaçları'),
      content: SizedBox(
        width: (size.width - 80).clamp(300.0, 680.0).toDouble(),
        height: (size.height - 260).clamp(240.0, 520.0).toDouble(),
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
                      'programına devam eder.',
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
}
