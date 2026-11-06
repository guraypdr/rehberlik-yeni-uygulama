import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../students/presentation/students_provider.dart';
import '../../../students/presentation/widgets/quick_student_dialog.dart';
import '../../../students/presentation/widgets/student_import_dialog.dart';
import '../../../students/presentation/widgets/student_info_form_sheet.dart';
import '../../../students/presentation/widgets/student_info_form_status.dart';
import '../../../students/presentation/widgets/student_profile_page.dart';
import '../../domain/school_class.dart';

class ClassStudentsDialog extends ConsumerWidget {
  const ClassStudentsDialog({super.key, required this.schoolClass});

  final SchoolClass schoolClass;

  static Future<void> show(BuildContext context, SchoolClass schoolClass) {
    return showDialog<void>(
      context: context,
      builder: (_) => ClassStudentsDialog(schoolClass: schoolClass),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final studentsAsync = ref.watch(studentsProvider);
    final students =
        studentsAsync.valueOrNull
            ?.where((student) => student.classId == schoolClass.id)
            .toList() ??
        const [];

    return Dialog(
      child: SizedBox(
        width: screenSize.width < 800 ? screenSize.width - 80 : 720.0,
        height: screenSize.height < 650
            ? screenSize.height - 80
            : screenSize.height * 0.78,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schoolClass.displayName,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${students.length} öğrenci',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Kapat',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  FilledButton.icon(
                    key: Key('add_student_${schoolClass.id}'),
                    icon: const Icon(Icons.person_add_outlined, size: 18),
                    label: const Text('Sınıfa Öğrenci Ekle'),
                    onPressed: () => QuickStudentDialog.show(
                      context,
                      initialClassId: schoolClass.id,
                      onStudentCreated: (student, openDetails) {
                        if (openDetails) {
                          StudentInfoFormSheet.show(context, student);
                        }
                      },
                    ),
                  ),
                  OutlinedButton.icon(
                    key: Key('bulk_add_students_${schoolClass.id}'),
                    icon: const Icon(Icons.file_upload_outlined, size: 18),
                    label: const Text('Toplu Öğrenci Ekle'),
                    onPressed: () => StudentImportDialog.show(
                      context,
                      classId: schoolClass.id,
                      className: schoolClass.displayName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: studentsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      Center(child: Text('Öğrenciler yüklenemedi: $error')),
                  data: (allStudents) {
                    final classStudents = allStudents
                        .where((student) => student.classId == schoolClass.id)
                        .toList();
                    if (classStudents.isEmpty) {
                      return const Center(
                        child: Text(
                          'Bu sınıfta henüz öğrenci yok.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: classStudents.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final student = classStudents[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            child: Text(
                              student.name.characters.firstOrNull ?? 'Ö',
                            ),
                          ),
                          title: Text(
                            '${student.number} · ${student.fullName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${student.gender} · ${student.boardingStatus}',
                              ),
                              const SizedBox(height: 4),
                              StudentInfoFormStatus(student: student),
                            ],
                          ),
                          onTap: () =>
                              StudentProfilePage.show(context, student),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
