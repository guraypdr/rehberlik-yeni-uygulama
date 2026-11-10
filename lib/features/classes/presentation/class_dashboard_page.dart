import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../students/domain/student.dart';
import '../../students/presentation/students_provider.dart';
import '../../students/presentation/widgets/student_profile_page.dart';
import '../../teachers/domain/teacher.dart';
import '../../teachers/presentation/teachers_provider.dart';
import '../domain/school_class.dart';
import 'class_risk_map_page.dart';
import 'class_risk_map_overview_page.dart';
import 'classes_provider.dart';
import 'student_risk_provider.dart';

class ClassDashboardPage extends ConsumerWidget {
  const ClassDashboardPage({super.key, required this.schoolClass});

  final SchoolClass schoolClass;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);
    final teachersAsync = ref.watch(teachersProvider);
    final classesAsync = ref.watch(classesProvider);
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
            final currentClass =
                classesAsync.valueOrNull?.classes
                    .where((item) => item.id == schoolClass.id)
                    .firstOrNull ??
                schoolClass;
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
                .where((item) => item.id == currentClass.teacherId)
                .firstOrNull;
            final riskMapCompleted = riskMapCompletedAsync.valueOrNull ?? false;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
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
                        _AdvisorCard(
                          teacher: teacher,
                          onEdit: () async {
                            final classState = ref
                                .read(classesProvider)
                                .valueOrNull;
                            if (classState == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Sınıf bilgileri yüklenmeden atama yapılamaz.',
                                  ),
                                ),
                              );
                              return;
                            }
                            final teacherId = await showDialog<int>(
                              context: context,
                              builder: (context) => _AdvisorAssignmentDialog(
                                schoolClass: currentClass,
                                classes: classState.classes,
                                teachers: teachers,
                              ),
                            );
                            if (teacherId == null || !context.mounted) return;
                            final assignedTeacherId = teacherId == -1
                                ? null
                                : teacherId;
                            try {
                              await ref
                                  .read(classesProvider.notifier)
                                  .updateClass(
                                    currentClass.copyWith(
                                      teacherId: assignedTeacherId,
                                      clearTeacher: assignedTeacherId == null,
                                    ),
                                  );
                              if (!context.mounted) return;
                              final assignedTeacher = teachers
                                  .where((item) => item.id == assignedTeacherId)
                                  .firstOrNull;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    assignedTeacherId == null
                                        ? 'Rehber öğretmen ataması kaldırıldı.'
                                        : '${assignedTeacher?.fullName ?? 'Öğretmen'}, '
                                              '${currentClass.displayName} sınıfına atandı.',
                                  ),
                                ),
                              );
                            } catch (error) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Rehber öğretmen atanamadı: $error',
                                  ),
                                ),
                              );
                            }
                          },
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
                                      schoolClass: currentClass,
                                    )
                                  : ClassRiskMapPage(schoolClass: currentClass),
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
                                ? 'Risk Haritası'
                                : 'Risk Haritasını Doldur',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (students.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Center(
                          child: Text('Bu sınıfta henüz öğrenci yok.'),
                        ),
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
                              if (index > 0)
                                const Divider(height: 1, indent: 72),
                              _StudentTile(student: students[index]),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
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
      width: 230,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
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

class _AdvisorCard extends StatelessWidget {
  const _AdvisorCard({required this.teacher, required this.onEdit});

  final Teacher? teacher;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 230,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.assignment_ind_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sınıf Rehber Öğretmeni',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      teacher?.fullName ?? 'Atanmamış',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('class_advisor_edit_button'),
                tooltip: 'Rehber öğretmeni ata veya düzenle',
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdvisorAssignmentDialog extends StatefulWidget {
  const _AdvisorAssignmentDialog({
    required this.schoolClass,
    required this.classes,
    required this.teachers,
  });

  final SchoolClass schoolClass;
  final List<SchoolClass> classes;
  final List<Teacher> teachers;

  @override
  State<_AdvisorAssignmentDialog> createState() =>
      _AdvisorAssignmentDialogState();
}

class _AdvisorAssignmentDialogState extends State<_AdvisorAssignmentDialog> {
  late int _selectedTeacherId;

  @override
  void initState() {
    super.initState();
    _selectedTeacherId = widget.schoolClass.teacherId ?? -1;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Sınıf rehber öğretmeni'),
    content: SizedBox(
      width: 420,
      child: DropdownButtonFormField<int>(
        key: const Key('class_advisor_dropdown'),
        initialValue: _selectedTeacherId,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Öğretmen'),
        items: [
          const DropdownMenuItem<int>(value: -1, child: Text('Atanmamış')),
          for (final teacher in widget.teachers) _teacherMenuItem(teacher),
        ],
        onChanged: (value) {
          if (value != null) setState(() => _selectedTeacherId = value);
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('İptal'),
      ),
      FilledButton(
        key: const Key('class_advisor_save_button'),
        onPressed: () => Navigator.of(context).pop(_selectedTeacherId),
        child: const Text('Ata'),
      ),
    ],
  );

  DropdownMenuItem<int> _teacherMenuItem(Teacher teacher) {
    final assignedClass = widget.classes
        .where(
          (schoolClass) =>
              schoolClass.id != widget.schoolClass.id &&
              schoolClass.teacherId == teacher.id,
        )
        .firstOrNull;
    final branch = teacher.branch;
    final teacherLabel = branch == null || branch.isEmpty
        ? teacher.fullName
        : '${teacher.fullName} · $branch';

    return DropdownMenuItem<int>(
      value: teacher.id,
      enabled: assignedClass == null,
      child: Text(
        assignedClass == null
            ? teacherLabel
            : '$teacherLabel · ${assignedClass.displayName} sınıfında',
        overflow: TextOverflow.ellipsis,
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
