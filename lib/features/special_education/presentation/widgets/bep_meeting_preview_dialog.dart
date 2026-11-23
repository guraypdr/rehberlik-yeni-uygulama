import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/providers/session_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../classes/presentation/classes_provider.dart';
import '../../../settings/domain/school_staff.dart';
import '../../../settings/presentation/school_staff_provider.dart';
import '../../../students/presentation/students_provider.dart';
import '../../../teachers/domain/teacher.dart';
import '../../../teachers/presentation/teachers_provider.dart';
import '../../data/bep_meeting_pdf.dart';
import '../../domain/bep_meeting.dart';
import '../../domain/student_subject_need.dart';
import '../student_subject_needs_provider.dart';

class BepMeetingPreviewDialog extends ConsumerWidget {
  const BepMeetingPreviewDialog({
    super.key,
    required this.meeting,
    required this.meetingNumber,
  });

  final BepMeeting meeting;
  final int meetingNumber;

  static Future<void> show(
    BuildContext context, {
    required BepMeeting meeting,
    required int meetingNumber,
  }) => showDialog<void>(
    context: context,
    builder: (_) =>
        BepMeetingPreviewDialog(meeting: meeting, meetingNumber: meetingNumber),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    // Kararlar güncel ders ihtiyaçlarından üretilir; veri değişince tutanak
    // da yeniden oluşturulur.
    final subjectNeeds =
        ref.watch(studentSubjectNeedsProvider(meeting.studentId)).valueOrNull ??
        const <StudentSubjectNeed>[];
    final schoolName = ref
        .watch(sessionProvider)
        .valueOrNull
        ?.schoolProfile
        ?.name;
    final student = ref
        .watch(studentsProvider)
        .valueOrNull
        ?.where((s) => s.id == meeting.studentId)
        .firstOrNull;
    final staff =
        ref.watch(schoolStaffProvider).valueOrNull ?? const <SchoolStaff>[];
    final classes =
        ref.watch(classesProvider).valueOrNull?.classes ?? const [];
    final teachers =
        ref.watch(teachersProvider).valueOrNull ?? const <Teacher>[];
    final matchingClass = student?.classId != null
        ? classes.where((c) => c.id == student!.classId).firstOrNull
        : null;
    final classTeacher = matchingClass?.teacherId != null
        ? teachers.where((t) => t.id == matchingClass!.teacherId).firstOrNull
        : null;
    final classTeacherName = classTeacher?.fullName;

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.xl),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: SizedBox(
        width: (size.width - 48).clamp(280.0, 900.0).toDouble(),
        height: (size.height * 0.88).clamp(320.0, 900.0).toDouble(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'BEP Toplantı Tutanağı Önizleme',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${meeting.studentName} · $meetingNumber. Toplantı · '
                          '${_formatDate(meeting.meetingDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('close_bep_meeting_preview'),
                    tooltip: 'Kapat',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.background,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: PdfPreview(
                      key: const Key('bep_meeting_pdf_preview'),
                      pdfFileName: 'BEP_Toplantı_Tutanağı_$meetingNumber.pdf',
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      build: (_) async => (await BepMeetingPdf.build(
                        meeting: meeting,
                        meetingNumber: meetingNumber,
                        subjectNeeds: subjectNeeds,
                        schoolName: schoolName,
                        schoolAndClassroomMeasures:
                            student?.schoolAndClassroomMeasures,
                        staff: staff,
                        classTeacherName: classTeacherName,
                      )).save(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
