import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../students/domain/student.dart';
import '../../students/presentation/students_provider.dart';
import '../../students/presentation/widgets/student_profile_page.dart';
import '../../teachers/presentation/teachers_provider.dart';
import '../domain/bep_meeting.dart';
import 'bep_meetings_provider.dart';
import 'widgets/bep_meeting_dialog.dart';

class SpecialEducationPage extends ConsumerWidget {
  const SpecialEducationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);
    final teachersAsync = ref.watch(teachersProvider);
    final meetingsAsync = ref.watch(bepMeetingsProvider);
    final textTheme = Theme.of(context).textTheme;
    final specialStudents =
        studentsAsync.valueOrNull
            ?.where((student) => student.hasSpecialEducation == true)
            .toList()
          ?..sort(_compareStudents);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Özel Eğitim', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Özel eğitim öğrencisi olarak işaretlenen öğrenciler.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              key: const Key('add_bep_meeting'),
              onPressed: studentsAsync.hasValue && teachersAsync.hasValue
                  ? () => BepMeetingDialog.show(
                      context,
                      students: specialStudents ?? const [],
                      teachers: teachersAsync.valueOrNull ?? const [],
                    )
                  : null,
              icon: const Icon(Icons.event_available_outlined),
              label: const Text('BEP Toplantısı Ekle'),
            ),
          ),
          if (teachersAsync.hasError)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Öğretmenler yüklenemedi: ${teachersAsync.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          studentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) =>
                Center(child: Text('Öğrenciler yüklenemedi: $error')),
            data: (allStudents) {
              final students = specialStudents ?? [];

              if (students.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      'Özel eğitim öğrencisi olarak işaretlenmiş öğrenci yok.',
                      key: Key('special_education_empty'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return Card(
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    key: const Key('special_education_students_table'),
                    showCheckboxColumn: false,
                    columns: const [
                      DataColumn(label: Text('Sıra')),
                      DataColumn(label: Text('Öğrenci No')),
                      DataColumn(label: Text('Ad Soyad')),
                      DataColumn(label: Text('Sınıf / Şube')),
                      DataColumn(label: Text('Cinsiyet')),
                    ],
                    rows: [
                      for (var index = 0; index < students.length; index++)
                        _studentRow(context, index, students[index]),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('BEP Toplantıları', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          meetingsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) =>
                Center(child: Text('BEP toplantıları yüklenemedi: $error')),
            data: (meetings) {
              if (meetings.isEmpty) {
                return const Text(
                  'Henüz BEP toplantısı eklenmedi.',
                  key: Key('bep_meetings_empty'),
                );
              }
              final meetingNumbers = _meetingNumbers(meetings);
              return Card(
                elevation: 0,
                child: Column(
                  children: [
                    for (final meeting in meetings)
                      ExpansionTile(
                        key: Key('bep_meeting_${meeting.id}'),
                        title: Text(
                          '${meetingNumbers[meeting.id]}. Toplantı · '
                          '${meeting.studentName} · ${meeting.studentNumber}',
                        ),
                        subtitle: Text(
                          '${_formatMeetingDate(meeting.meetingDate)} · '
                          '${meeting.className}',
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        children: [
                          _MeetingDetail(
                            label: 'Katılan öğretmenler',
                            value: meeting.teacherNames.join(', '),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          for (
                            var index = 0;
                            index < meeting.agendaItems.length;
                            index++
                          )
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.xs,
                                ),
                                child: Text(
                                  '${index + 1}. ${meeting.agendaItems[index]}',
                                ),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Alınan Kararlar', style: textTheme.titleSmall),
                          if (meeting.decisions.isEmpty)
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Karar kaydı bulunmuyor.'),
                            )
                          else
                            for (
                              var index = 0;
                              index < meeting.decisions.length;
                              index++
                            )
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Text(
                                    '${index + 1}. ${meeting.decisions[index]}',
                                  ),
                                ),
                              ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              key: Key('delete_bep_meeting_${meeting.id}'),
                              onPressed: () =>
                                  _confirmDelete(context, ref, meeting),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Toplantıyı Sil'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static int _compareStudents(Student a, Student b) {
    final classComparison = a.displayClass.compareTo(b.displayClass);
    if (classComparison != 0) return classComparison;
    final nameComparison = a.name.compareTo(b.name);
    if (nameComparison != 0) return nameComparison;
    return a.surname.compareTo(b.surname);
  }

  static String _formatMeetingDate(String date) {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    return '${parsed.day.toString().padLeft(2, '0')}.'
        '${parsed.month.toString().padLeft(2, '0')}.${parsed.year}';
  }

  static Map<int, int> _meetingNumbers(List<BepMeeting> meetings) {
    final chronological = [...meetings]
      ..sort((a, b) {
        final studentComparison = a.studentId.compareTo(b.studentId);
        if (studentComparison != 0) return studentComparison;
        final dateComparison = a.meetingDate.compareTo(b.meetingDate);
        if (dateComparison != 0) return dateComparison;
        return a.id.compareTo(b.id);
      });
    final countsByStudent = <int, int>{};
    final numbersByMeeting = <int, int>{};
    for (final meeting in chronological) {
      final count = (countsByStudent[meeting.studentId] ?? 0) + 1;
      countsByStudent[meeting.studentId] = count;
      numbersByMeeting[meeting.id] = count;
    }
    return numbersByMeeting;
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BepMeeting meeting,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Toplantı silinsin mi?'),
        content: Text(
          '${meeting.studentName} için kayıtlı BEP toplantısı silinecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            key: Key('confirm_delete_bep_meeting_${meeting.id}'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !context.mounted) return;
    try {
      await ref.read(bepMeetingsProvider.notifier).deleteMeeting(meeting.id);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('BEP toplantısı silinemedi: $error')),
        );
      }
    }
  }

  DataRow _studentRow(BuildContext context, int index, Student student) =>
      DataRow(
        onSelectChanged: (_) => StudentProfilePage.show(
          context,
          student,
          sourceDestinationId: 'special_education',
        ),
        cells: [
          DataCell(Text('${index + 1}')),
          DataCell(Text(student.number)),
          DataCell(
            InkWell(
              key: Key('special_education_student_${student.id}'),
              onTap: () => StudentProfilePage.show(
                context,
                student,
                sourceDestinationId: 'special_education',
              ),
              child: Text(student.fullName),
            ),
          ),
          DataCell(Text(student.displayClass)),
          DataCell(Text(student.gender)),
        ],
      );
}

class _MeetingDetail extends StatelessWidget {
  const _MeetingDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text('$label: $value'),
    ),
  );
}
