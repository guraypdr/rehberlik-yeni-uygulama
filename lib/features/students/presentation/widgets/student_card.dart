import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/student.dart';
import 'interview_dialog.dart';
import 'student_detail_sheet.dart';

/// Öğrenci kartı widget'ı.
class StudentCard extends StatelessWidget {
  const StudentCard({
    super.key,
    required this.student,
    required this.onDelete,
  });

  final Student student;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final isFemale = student.gender == 'Kız';
    final genderColor = isFemale ? const Color(0xFFE91E63) : const Color(0xFF1976D2);

    return InkWell(
      onTap: () => StudentDetailSheet.show(context, student),
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
                              style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Hızlı Görüşme Ekle',
                  icon: const Icon(Icons.add_comment_outlined, size: 18),
                  onPressed: () {
                    InterviewDialog.show(
                      context,
                      studentId: student.id,
                      studentName: student.fullName,
                    );
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

            // Rozetler & Bilgi etiketleri
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _Badge(
                  label: student.gender,
                  color: genderColor,
                ),
                if (student.status != 'Aktif')
                  _Badge(
                    label: student.status,
                    color: AppColors.warning,
                  ),
                if (student.familyRiskLevel != 'Düşük')
                  _Badge(
                    label: '${student.familyRiskLevel} Risk',
                    color: student.familyRiskLevel == 'Kritik' ||
                            student.familyRiskLevel == 'Yüksek'
                        ? AppColors.danger
                        : AppColors.warning,
                  ),
                if (student.specialStatus != null &&
                    student.specialStatus!.isNotEmpty)
                  _Badge(
                    label: student.specialStatus!,
                    color: Colors.purple,
                  ),
                if (student.hasChronicIllness)
                  const _Badge(
                    label: 'Kronik Sağlık',
                    color: Colors.teal,
                  ),
                if (student.parentsTogether != 'Birlikte')
                  _Badge(
                    label: student.parentsTogether,
                    color: Colors.deepOrange,
                  ),
              ],
            ),

            // Alt bilgi: Veli veya iletişim (varsa)
            if (student.guardianPhone != null || student.motherPhone != null || student.fatherPhone != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    student.guardianPhone ??
                        student.motherPhone ??
                        student.fatherPhone ??
                        '',
                    style: t.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  if (student.guardianName != null && student.guardianName!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      '(${student.guardianName})',
                      style: t.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ],
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
