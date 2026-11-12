import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../teachers/domain/teacher.dart';
import '../../domain/class_subject.dart';
import '../class_subjects_provider.dart';
import 'class_subject_import_dialog.dart';

class ClassSubjectsSection extends ConsumerWidget {
  const ClassSubjectsSection({
    super.key,
    required this.classId,
    required this.teachers,
  });

  final int classId;
  final List<Teacher> teachers;

  Future<void> _editSubject(
    BuildContext context,
    WidgetRef ref,
    ClassSubject? subject,
  ) async {
    final draft = await showDialog<ClassSubjectDraft>(
      context: context,
      builder: (context) =>
          _ClassSubjectDialog(teachers: teachers, subject: subject),
    );
    if (draft == null || !context.mounted) return;

    final existingSubjects =
        ref.read(classSubjectsProvider(classId)).valueOrNull ?? [];
    final duplicate = existingSubjects.any(
      (item) =>
          item.id != subject?.id &&
          item.subjectName.toLowerCase() == draft.subjectName.toLowerCase(),
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu ders sınıfta zaten kayıtlı.')),
      );
      return;
    }

    try {
      final notifier = ref.read(classSubjectsProvider(classId).notifier);
      if (subject == null) {
        await notifier.add(
          classId: classId,
          subjectName: draft.subjectName,
          weeklyHours: draft.weeklyHours,
          teacherId: draft.teacherId,
        );
      } else {
        await notifier.saveSubject(
          subject: subject,
          subjectName: draft.subjectName,
          weeklyHours: draft.weeklyHours,
          teacherId: draft.teacherId,
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ders kaydedilemedi: $error')));
    }
  }

  Future<void> _importSubjects(BuildContext context) async {
    await ClassSubjectImportDialog.show(
      context,
      classId: classId,
      teachers: teachers,
    );
  }

  Future<void> _deleteSubject(
    BuildContext context,
    WidgetRef ref,
    ClassSubject subject,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dersi sil'),
        content: Text(
          '"${subject.subjectName}" dersini bu sınıftan silmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(classSubjectsProvider(classId).notifier)
          .delete(subject.id);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ders silinemedi: $error')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(classSubjectsProvider(classId));
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                'Sınıfta Okutulan Dersler',
                style: theme.textTheme.titleMedium,
              ),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  OutlinedButton.icon(
                    key: const Key('import_class_subjects_button'),
                    onPressed: () => _importSubjects(context),
                    icon: const Icon(Icons.table_view_outlined, size: 18),
                    label: const Text('Excel’den Yükle'),
                  ),
                  FilledButton.tonalIcon(
                    key: const Key('add_class_subject_button'),
                    onPressed: () => _editSubject(context, ref, null),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ders Ekle'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          subjectsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text('Dersler yüklenemedi: $error'),
            data: (subjects) => subjects.isEmpty
                ? Text(
                    'Bu sınıf için henüz ders eklenmedi.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  )
                : Column(
                    children: [
                      for (final subject in subjects)
                        _SubjectRow(
                          subject: subject,
                          teacher: teachers
                              .where(
                                (teacher) => teacher.id == subject.teacherId,
                              )
                              .firstOrNull,
                          onEdit: () => _editSubject(context, ref, subject),
                          onDelete: () => _deleteSubject(context, ref, subject),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    required this.subject,
    required this.teacher,
    required this.onEdit,
    required this.onDelete,
  });

  final ClassSubject subject;
  final Teacher? teacher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => ListTile(
    key: Key('class_subject_${subject.id}'),
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.menu_book_outlined),
    title: Text(subject.subjectName),
    subtitle: Text(
      '${subject.weeklyHours} saat/hafta · '
      '${teacher?.fullName ?? 'Öğretmen atanmamış'}',
    ),
    trailing: Wrap(
      children: [
        IconButton(
          key: Key('class_subject_edit_${subject.id}'),
          tooltip: 'Dersi düzenle',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          key: Key('class_subject_delete_${subject.id}'),
          tooltip: 'Dersi sil',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    ),
  );
}

class ClassSubjectDraft {
  const ClassSubjectDraft({
    required this.subjectName,
    required this.weeklyHours,
    this.teacherId,
  });

  final String subjectName;
  final int weeklyHours;
  final int? teacherId;
}

class _ClassSubjectDialog extends StatefulWidget {
  const _ClassSubjectDialog({required this.teachers, this.subject});

  final List<Teacher> teachers;
  final ClassSubject? subject;

  @override
  State<_ClassSubjectDialog> createState() => _ClassSubjectDialogState();
}

class _ClassSubjectDialogState extends State<_ClassSubjectDialog> {
  static const _unassignedTeacher = -1;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subjectController;
  late final TextEditingController _hoursController;
  late int _teacherId;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(
      text: widget.subject?.subjectName ?? '',
    );
    _hoursController = TextEditingController(
      text: '${widget.subject?.weeklyHours ?? 1}',
    );
    final initialTeacherId = widget.subject?.teacherId;
    _teacherId =
        widget.teachers.any((teacher) => teacher.id == initialTeacherId)
        ? initialTeacherId!
        : _unassignedTeacher;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ClassSubjectDraft(
        subjectName: _subjectController.text.trim(),
        weeklyHours: int.parse(_hoursController.text.trim()),
        teacherId: _teacherId == _unassignedTeacher ? null : _teacherId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.subject == null ? 'Sınıfa ders ekle' : 'Dersi düzenle'),
    content: SizedBox(
      width: 420,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const Key('class_subject_name_input'),
              controller: _subjectController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Ders adı'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Ders adı zorunludur.'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              key: const Key('class_subject_hours_input'),
              controller: _hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Haftalık ders saati',
                suffixText: 'saat',
              ),
              validator: (value) {
                final hours = int.tryParse(value?.trim() ?? '');
                if (hours == null || hours < 1 || hours > 40) {
                  return '1 ile 40 arasında bir sayı girin.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<int>(
              key: const Key('class_subject_teacher_dropdown'),
              initialValue: _teacherId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Ders öğretmeni'),
              items: [
                const DropdownMenuItem<int>(
                  value: _unassignedTeacher,
                  child: Text('Öğretmen atanmadı'),
                ),
                for (final teacher in widget.teachers)
                  DropdownMenuItem<int>(
                    value: teacher.id,
                    child: Text(
                      teacher.branch == null || teacher.branch!.isEmpty
                          ? teacher.fullName
                          : '${teacher.fullName} · ${teacher.branch}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _teacherId = value);
              },
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('İptal'),
      ),
      FilledButton(
        key: const Key('class_subject_save_button'),
        onPressed: _save,
        child: const Text('Kaydet'),
      ),
    ],
  );
}
