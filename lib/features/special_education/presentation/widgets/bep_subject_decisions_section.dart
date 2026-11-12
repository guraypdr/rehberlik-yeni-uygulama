import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/bep_subject_decision.dart';
import '../../domain/student_subject_need.dart';

/// Öğrencinin ders ihtiyaçlarından otomatik üretilen BEP kararlarını ve
/// ders tablolarını gösterir.
///
/// Veriler her çizimde güncel ders ihtiyaçlarından okunduğu için uygulama
/// içinde ders bilgileri değiştiğinde kararlar da değişir.
class BepSubjectDecisionsSection extends StatelessWidget {
  const BepSubjectDecisionsSection({super.key, required this.needs});

  final List<StudentSubjectNeed> needs;

  @override
  Widget build(BuildContext context) {
    if (needs.isEmpty) return const SizedBox.shrink();

    final decisions = buildBepSubjectDecisions(needs);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const Key('bep_subject_decisions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Öğrencinin Ders Durumuna Göre Kararlar',
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Bu kararlar öğrencinin ders ihtiyaçlarından otomatik oluşturulur ve '
          'ders bilgileri güncellendiğinde birlikte güncellenir.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
        for (var index = 0; index < decisions.length; index++)
          Padding(
            key: Key('bep_subject_decision_$index'),
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${index + 1}. ${decisions[index].text}'),
                const SizedBox(height: AppSpacing.xs),
                if (decisions[index].hasRows)
                  _table(decisions[index].rows)
                else
                  Text(
                    decisions[index].emptyText,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _table(List<BepSubjectDecisionRow> rows) => Table(
    border: TableBorder.all(color: AppColors.surfaceMuted),
    columnWidths: const {
      0: FlexColumnWidth(3),
      1: FlexColumnWidth(3),
      2: FlexColumnWidth(1.4),
    },
    children: [
      TableRow(
        decoration: const BoxDecoration(color: AppColors.surfaceMuted),
        children: [
          _cell('Ders Adı', bold: true),
          _cell('Dersi Verecek Öğretmen', bold: true),
          _cell('Ders Saati', bold: true),
        ],
      ),
      for (final row in rows)
        TableRow(
          children: [
            _cell(row.subjectName),
            _cell(row.teacherName),
            _cell('${row.weeklyHours}'),
          ],
        ),
    ],
  );

  Widget _cell(String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.all(AppSpacing.sm),
    child: Text(
      value,
      style: TextStyle(
        fontSize: 13,
        fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
      ),
    ),
  );
}
