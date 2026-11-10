import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/student.dart';
import '../../domain/student_interview.dart';
import '../students_provider.dart';
import 'interview_dialog.dart';

class StudentInterviewsDialog extends ConsumerWidget {
  const StudentInterviewsDialog({super.key, required this.student});

  final Student student;

  static Future<void> show(BuildContext context, Student student) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => StudentInterviewsDialog(student: student),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interviews = ref.watch(studentInterviewsProvider(student.id));
    final size = MediaQuery.sizeOf(context);

    return AlertDialog(
      title: Text(
        'Görüşmeler · ${student.fullName}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      content: SizedBox(
        width: (size.width - 80).clamp(300.0, 680.0).toDouble(),
        height: (size.height - 240).clamp(280.0, 520.0).toDouble(),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                key: const Key('student_add_interview'),
                onPressed: () => InterviewDialog.show(
                  context,
                  studentId: student.id,
                  studentName: student.fullName,
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Yeni Görüşme Ekle'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: interviews.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Text('Görüşmeler yüklenemedi: $error'),
                ),
                data: (items) => items.isEmpty
                    ? const Center(
                        child: Text('Kayıtlı görüşme bulunmuyor.'),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) => _InterviewTile(
                          studentId: student.id,
                          interview: items[index],
                        ),
                      ),
              ),
            ),
          ],
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

class _InterviewTile extends ConsumerWidget {
  const _InterviewTile({
    required this.studentId,
    required this.interview,
  });

  final int studentId;
  final StudentInterview interview;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    title: Text(interview.subject),
    subtitle: Text('${interview.typeLabel} · ${interview.date}'),
    trailing: IconButton(
      tooltip: 'Görüşmeyi sil',
      icon: const Icon(Icons.delete_outline),
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Görüşmeyi Sil'),
            content: const Text('Bu görüşme kaydını silmek istiyor musunuz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sil'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await ref
              .read(studentInterviewsProvider(studentId).notifier)
              .deleteInterview(interview.id);
        }
      },
    ),
  );
}
