import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../students/domain/student.dart';
import '../../students/presentation/students_provider.dart';
import '../../teachers/presentation/teachers_provider.dart';
import '../domain/bep_meeting.dart';
import '../domain/student_subject_need.dart';
import 'bep_meetings_provider.dart';
import 'student_subject_needs_provider.dart';
import 'widgets/bep_meeting_dialog.dart';
import 'widgets/bep_meeting_preview_dialog.dart';
import 'widgets/bep_subject_decisions_section.dart';
import 'widgets/student_subject_needs_dialog.dart';

class SpecialEducationStudentProfilePage extends ConsumerWidget {
  const SpecialEducationStudentProfilePage({super.key, required this.student});

  final Student student;

  static Future<void> show(BuildContext context, Student student) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SpecialEducationStudentProfilePage(student: student),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStudent = ref
        .watch(studentsProvider)
        .valueOrNull
        ?.where((s) => s.id == student.id)
        .firstOrNull ?? student;
    final meetingsAsync = ref.watch(bepMeetingsProvider);
    final teachersAsync = ref.watch(teachersProvider);
    final subjectsAsync = ref.watch(studentSubjectNeedsProvider(student.id));
    final meetings =
        (meetingsAsync.valueOrNull ?? const <BepMeeting>[])
            .where((meeting) => meeting.studentId == student.id)
            .toList()
          ..sort((a, b) {
            final dateComparison = a.meetingDate.compareTo(b.meetingDate);
            if (dateComparison != 0) return dateComparison;
            return a.id.compareTo(b.id);
          });

    return Scaffold(
      appBar: AppBar(title: Text('Özel Eğitim · ${currentStudent.fullName}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              _StudentSummary(student: currentStudent),
              const SizedBox(height: AppSpacing.xl),
              _MeasuresSection(student: currentStudent),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  _sectionTitle(
                    context,
                    title: 'Ders Durumu',
                    subtitle:
                        'Öğrencinin dersleri: destek eğitim, BEP, muafiyet ve '
                        'normal eğitim programı.',
                  ),
                  OutlinedButton.icon(
                    key: const Key('student_subject_needs'),
                    onPressed: () =>
                        StudentSubjectNeedsDialog.show(context, student),
                    icon: const Icon(Icons.checklist_rtl_outlined, size: 18),
                    label: const Text('Ders İhtiyaçları'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              subjectsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) =>
                    Text('Öğrencinin dersleri yüklenemedi: $error'),
                data: (subjects) => subjects.isEmpty
                    ? const AppCard(
                        child: Text(
                          'Bu öğrencinin sınıfına henüz ders eklenmemiş.',
                        ),
                      )
                    : _SubjectCategoryTabs(subjects: subjects),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  _sectionTitle(
                    context,
                    title: 'BEP Toplantıları',
                    subtitle: '${meetings.length} toplantı kaydı',
                  ),
                  FilledButton.icon(
                    key: const Key('add_student_bep_meeting'),
                    onPressed: teachersAsync.hasValue
                        ? () => BepMeetingDialog.show(
                            context,
                            students: [student],
                            teachers: teachersAsync.valueOrNull ?? const [],
                            initialStudentId: student.id,
                          )
                        : null,
                    icon: const Icon(Icons.event_available_outlined),
                    label: const Text('Toplantı Ekle'),
                  ),
                ],
              ),
              if (teachersAsync.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    'Öğretmenler yüklenemedi: ${teachersAsync.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              meetingsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) =>
                    Text('BEP toplantıları yüklenemedi: $error'),
                data: (_) => meetings.isEmpty
                    ? const AppCard(
                        child: Text(
                          'Bu öğrenci için henüz BEP toplantısı eklenmedi.',
                          key: Key('student_bep_meetings_empty'),
                        ),
                      )
                    : Column(
                        children: [
                          for (var index = 0; index < meetings.length; index++)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: _MeetingCard(
                                meeting: meetings[index],
                                meetingNumber: index + 1,
                                student: student,
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppSpacing.xs),
      Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
      ),
    ],
  );
}

class _StudentSummary extends StatelessWidget {
  const _StudentSummary({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.sm,
      children: [
        _SummaryItem(label: 'Öğrenci', value: student.fullName),
        _SummaryItem(label: 'Öğrenci No', value: student.number),
        _SummaryItem(label: 'Sınıf / Şube', value: student.displayClass),
        _SummaryItem(label: 'Cinsiyet', value: student.gender),
      ],
    ),
  );
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 200,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    ),
  );
}

/// Öğrencinin derslerini dört kategoriye ayıran sekmeli görünüm.
class _SubjectCategoryTabs extends StatelessWidget {
  const _SubjectCategoryTabs({required this.subjects});

  final List<StudentSubjectNeed> subjects;

  @override
  Widget build(BuildContext context) {
    final categories = [
      _SubjectCategory(
        keyName: 'profile_tab_support',
        label: 'Destek Eğitim',
        icon: Icons.support_outlined,
        items: subjects.where((s) => s.requiresSupportEducation).toList(),
        emptyMessage: 'Destek eğitime ihtiyaç duyulan ders yok.',
      ),
      _SubjectCategory(
        keyName: 'profile_tab_bep',
        label: 'BEP Planı',
        icon: Icons.assignment_outlined,
        items: subjects.where((s) => s.requiresBep).toList(),
        emptyMessage: 'BEP hazırlanan ders yok.',
      ),
      _SubjectCategory(
        keyName: 'profile_tab_exempt',
        label: 'Muaf',
        icon: Icons.block_outlined,
        items: subjects.where((s) => s.isExempt).toList(),
        emptyMessage: 'Muaf olunan ders yok.',
      ),
      _SubjectCategory(
        keyName: 'profile_tab_normal',
        label: 'Normal Program',
        icon: Icons.school_outlined,
        items: subjects.where((s) => s.isNormalProgram).toList(),
        emptyMessage: 'Normal eğitim programına devam edilen ders yok.',
      ),
    ];

    return DefaultTabController(
      length: categories.length,
      child: AppCard(
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                for (final category in categories)
                  Tab(text: '${category.label} (${category.items.length})'),
              ],
            ),
            const Divider(height: 1),
            SizedBox(
              height: 300,
              child: TabBarView(
                children: [
                  for (final category in categories)
                    _SubjectList(category: category),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCategory {
  const _SubjectCategory({
    required this.keyName,
    required this.label,
    required this.icon,
    required this.items,
    required this.emptyMessage,
  });

  final String keyName;
  final String label;
  final IconData icon;
  final List<StudentSubjectNeed> items;
  final String emptyMessage;
}

class _SubjectList extends StatelessWidget {
  const _SubjectList({required this.category});

  final _SubjectCategory category;

  @override
  Widget build(BuildContext context) {
    if (category.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            category.emptyMessage,
            key: Key('${category.keyName}_empty'),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return ListView.separated(
      key: Key(category.keyName),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: category.items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final subject = category.items[index];
        final teacherSuffix = subject.teacherName == null
            ? ''
            : ' · ${subject.teacherName}';
        return ListTile(
          key: Key('${category.keyName}_${subject.classSubjectId}'),
          dense: true,
          leading: Icon(category.icon, size: 18, color: AppColors.textMuted),
          title: Text(subject.subjectName),
          subtitle: Text('${subject.weeklyHours} saat/hafta$teacherSuffix'),
        );
      },
    );
  }
}

class _MeetingCard extends ConsumerWidget {
  const _MeetingCard({
    required this.meeting,
    required this.meetingNumber,
    required this.student,
  });

  final BepMeeting meeting;
  final int meetingNumber;
  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppCard(
    padding: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(
      key: Key('student_bep_meeting_${meeting.id}'),
      leading: const Icon(Icons.event_note_outlined),
      title: Text('$meetingNumber. Toplantı'),
      subtitle: Text(
        '${_formatDate(meeting.meetingDate)} · ${meeting.teacherNames.join(', ')}',
      ),
      childrenPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: [
        for (var index = 0; index < meeting.agendaItems.length; index++)
          _MeetingText(
            label: 'Gündem ${index + 1}',
            value: meeting.agendaItems[index],
          ),
        if (meeting.decisions.isNotEmpty) ...[
          const Divider(),
          for (var index = 0; index < meeting.decisions.length; index++)
            _MeetingText(
              label: 'Karar ${index + 1}',
              value: meeting.decisions[index],
            ),
        ],
        const SizedBox(height: AppSpacing.sm),
        BepSubjectDecisionsSection(
          needs:
              ref
                  .watch(studentSubjectNeedsProvider(meeting.studentId))
                  .valueOrNull ??
              const [],
        ),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              key: Key('edit_student_bep_meeting_${meeting.id}'),
              onPressed: () async {
                final teachers = ref.read(teachersProvider).valueOrNull;
                if (teachers == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Öğretmenler yüklenemedi.')),
                  );
                  return;
                }
                await BepMeetingDialog.show(
                  context,
                  students: [student],
                  teachers: teachers,
                  initialMeeting: meeting,
                );
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Düzenle'),
            ),
            FilledButton.tonalIcon(
              key: Key('preview_student_bep_meeting_${meeting.id}'),
              onPressed: () => BepMeetingPreviewDialog.show(
                context,
                meeting: meeting,
                meetingNumber: meetingNumber,
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Tutanağı Görüntüle'),
            ),
            TextButton.icon(
              key: Key('delete_student_bep_meeting_${meeting.id}'),
              onPressed: () => _delete(context, ref),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Sil'),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Toplantı silinsin mi?'),
        content: Text(
          '${student.fullName} için ${_formatDate(meeting.meetingDate)} '
          'tarihli toplantı silinecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            key: Key('confirm_delete_student_bep_meeting_${meeting.id}'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(bepMeetingsProvider.notifier).deleteMeeting(meeting.id);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('BEP toplantısı silinemedi: $error')),
      );
    }
  }
}

class _MeetingText extends StatelessWidget {
  const _MeetingText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text('$label: $value'),
    ),
  );
}

String _formatDate(String date) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return date;
  return '${parsed.day.toString().padLeft(2, '0')}.'
      '${parsed.month.toString().padLeft(2, '0')}.${parsed.year}';
}

class _MeasuresSection extends ConsumerWidget {
  const _MeasuresSection({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measures = student.schoolAndClassroomMeasures?.trim() ?? '';
    final hasMeasures = measures.isNotEmpty;
    final lines = hasMeasures
        ? measures
            .split(RegExp(r'\n+'))
            .map((line) => line.trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), ''))
            .where((line) => line.isNotEmpty)
            .toList()
        : const <String>[];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Öğrenciye Yönelik Okul ve Sınıf İçinde Alınacak Tedbirler',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Toplantı tutanağındaki alınan kararlar bölümünün en başında otomatik olarak yer alır.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                key: const Key('edit_student_measures'),
                onPressed: () =>
                    _MeasuresEditDialog.show(context, ref, student),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(hasMeasures ? 'Düzenle' : 'Tedbir Ekle'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (hasMeasures)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              line,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Bu öğrenci için henüz okul ve sınıf içinde alınacak tedbir belirlenmemiş. '
                      'BEP toplantı tutanağına yansıtılmak üzere "Tedbir Ekle" butonuna tıklayarak ekleyebilirsiniz.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MeasuresEditDialog extends StatefulWidget {
  const _MeasuresEditDialog({required this.student, required this.ref});

  final Student student;
  final WidgetRef ref;

  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    Student student,
  ) =>
      showDialog<void>(
        context: context,
        builder: (_) => _MeasuresEditDialog(student: student, ref: ref),
      );

  @override
  State<_MeasuresEditDialog> createState() => _MeasuresEditDialogState();
}

class _MeasuresEditDialogState extends State<_MeasuresEditDialog> {
  late final TextEditingController _controller;
  bool _saving = false;

  static const _quickSuggestions = [
    'Ön sırada oturtulması',
    'Sınavlarda ek süre verilmesi',
    'Yönergelerin basitleştirilerek verilmesi',
    'Görsel ve somut materyallerle desteklenmesi',
    'Dikkati dağıtıcı unsurlardan uzak tutulması',
    'Büyük puntolu materyal sağlanması',
    'Sık aralıklarla kısa molalar verilmesi',
    'Birebir yönerge ve pekiştireç verilmesi',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.student.schoolAndClassroomMeasures ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSuggestion(String text) {
    final current = _controller.text.trim();
    if (current.contains(text)) return;
    if (current.isEmpty) {
      _controller.text = text;
    } else {
      _controller.text = '$current\n$text';
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updatedText = _controller.text.trim();
      final updated = widget.student.copyWith(
        schoolAndClassroomMeasures: updatedText.isEmpty ? null : updatedText,
      );
      await widget.ref.read(studentsProvider.notifier).updateStudent(updated);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Okul ve sınıf içi tedbirler kaydedildi.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kaydedilemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Okul ve Sınıf İçi Tedbirler'),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Öğrencinin sınıf ve okul ortamında ihtiyaç duyduğu eğitsel ve fiziksel tedbirleri girin. '
                'Bu tedbirler BEP Toplantı Tutanağındaki alınan kararlar bölümünün en başında otomatik olarak yer alır.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Hızlı Öneriler (Tıklayarak ekleyin):',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final suggestion in _quickSuggestions)
                    ActionChip(
                      label: Text(
                        suggestion,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _addSuggestion(suggestion),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                key: const Key('measures_text_field'),
                controller: _controller,
                maxLines: 6,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText:
                      'Alınacak Tedbirler (Her satıra bir tedbir yazabilirsiniz)',
                  hintText:
                      'Örnek:\nÖn sırada oturtulması\nSınavlarda ek süre verilmesi',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        FilledButton.icon(
          key: const Key('save_student_measures'),
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: const Text('Kaydet'),
        ),
      ],
    );
  }
}
