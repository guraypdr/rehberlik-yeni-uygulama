import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/student.dart';
import 'student_form_menu.dart';
import 'student_info_form_sheet.dart';
import 'student_info_form_status.dart';
import 'student_profile_page.dart';

/// Öğrenci kartı widget'ı.
class StudentCard extends StatelessWidget {
  const StudentCard({super.key, required this.student, required this.onDelete});

  final Student student;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final isFemale = student.gender == 'Kız';
    final genderColor = isFemale
        ? const Color(0xFFE91E63)
        : const Color(0xFF1976D2);

    return InkWell(
      onTap: () => StudentProfilePage.show(context, student),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst satır: Avatar + No + Adı + Menü
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: genderColor.withValues(alpha: 0.12),
                  child: Text(
                    student.name.isNotEmpty
                        ? student.name.characters.first.toUpperCase()
                        : 'Ö',
                    style: TextStyle(
                      color: genderColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              student.fullName,
                              style: t.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              '#${student.number}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        student.displayClass,
                        style: t.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      StudentInfoFormStatus(
                        student: student,
                        showProgressBar: true,
                      ),
                    ],
                  ),
                ),
                StudentFormMenu(
                  onSelected: (action) {
                    switch (action) {
                      case StudentFormAction.studentInfo:
                        StudentInfoFormSheet.show(context, student);
                    }
                  },
                ),
                IconButton(
                  tooltip: 'Öğrenciyi Sil',
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),

            // Temel öğrenci bilgileri
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _Badge(label: student.gender, color: genderColor),
                _Badge(
                  label: student.boardingStatus,
                  color: student.boardingStatus == 'Yatılı'
                      ? Colors.deepPurple
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
