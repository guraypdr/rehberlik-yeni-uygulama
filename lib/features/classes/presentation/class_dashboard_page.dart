import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../students/domain/student.dart';
import '../../students/presentation/students_provider.dart';
import '../../students/presentation/widgets/student_profile_page.dart';
import '../../teachers/presentation/teachers_provider.dart';
import '../domain/school_class.dart';
import 'class_risk_map_page.dart';
import 'class_risk_map_overview_page.dart';
import 'student_risk_provider.dart';

class ClassDashboardPage extends ConsumerWidget {
  const ClassDashboardPage({super.key, required this.schoolClass});

  final SchoolClass schoolClass;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);
    final teachersAsync = ref.watch(teachersProvider);
    final riskMapCompletedAsync = ref.watch(
      classRiskMapCompletedProvider(schoolClass.id),
    );

    return Scaffold(
      appBar: AppBar(title: Text(schoolClass.displayName)),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Öğrenciler yüklenemedi: $error')),
        data: (allStudents) => teachersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Öğretmenler yüklenemedi: $error')),
          data: (teachers) {
            final students =
                allStudents
                    .where((student) => student.classId == schoolClass.id)
                    .toList()
                  ..sort((a, b) => a.number.compareTo(b.number));
            final femaleCount = students
                .where((student) => student.gender == 'Kız')
                .length;
            final maleCount = students
                .where((student) => student.gender == 'Erkek')
                .length;
            final teacher = teachers
                .where((item) => item.id == schoolClass.teacherId)
                .firstOrNull;
            final riskMapCompleted = riskMapCompletedAsync.valueOrNull ?? false;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    _SummaryCard(
                      label: 'Öğrenci Sayısı',
                      value: '${students.length}',
                      icon: Icons.people_outline,
                    ),
                    _SummaryCard(
                      label: 'Kız Öğrenci',
                      value: '$femaleCount',
                      icon: Icons.girl_outlined,
                    ),
                    _SummaryCard(
                      label: 'Erkek Öğrenci',
                      value: '$maleCount',
                      icon: Icons.boy_outlined,
                    ),
                    _SummaryCard(
                      label: 'Sınıf Rehber Öğretmeni',
                      value: teacher?.fullName ?? 'Atanmamış',
                      icon: Icons.person_outline,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Text(
                      'Öğrenciler',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    FilledButton.icon(
                      key: const Key('open_class_risk_map'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => riskMapCompleted
                              ? ClassRiskMapOverviewPage(
                                  schoolClass: schoolClass,
                                )
                              : ClassRiskMapPage(schoolClass: schoolClass),
                        ),
                      ),
                      icon: Icon(
                        riskMapCompleted
                            ? Icons.visibility_outlined
                            : Icons.grid_view_outlined,
                        size: 18,
                      ),
                      label: Text(
                        riskMapCompleted
                            ? 'Risk Haritasını Görüntüle'
                            : 'Sınıf Risk Haritası',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (students.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Center(child: Text('Bu sınıfta henüz öğrenci yok.')),
                  )
                else
                  Card(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index < students.length;
                          index++
                        ) ...[
                          if (index > 0) const Divider(height: 1),
                          _StudentTile(student: students[index]),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(value, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) => ListTile(
    key: Key('class_student_${student.id}'),
    leading: CircleAvatar(
      child: Text(student.name.characters.firstOrNull ?? 'Ö'),
    ),
    title: Text('${student.number} · ${student.fullName}'),
    subtitle: Text('${student.gender} · ${student.boardingStatus}'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => StudentProfilePage.show(context, student),
  );
}
