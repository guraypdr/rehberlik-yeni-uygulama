import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../teachers/domain/teacher.dart';
import '../../domain/class_subject.dart';
import '../class_subjects_provider.dart';

class ClassSubjectImportDialog extends ConsumerStatefulWidget {
  const ClassSubjectImportDialog({
    super.key,
    required this.classId,
    required this.teachers,
  });

  final int classId;
  final List<Teacher> teachers;

  static Future<void> show(
    BuildContext context, {
    required int classId,
    required List<Teacher> teachers,
  }) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        ClassSubjectImportDialog(classId: classId, teachers: teachers),
  );

  @override
  ConsumerState<ClassSubjectImportDialog> createState() =>
      _ClassSubjectImportDialogState();
}

class _ClassSubjectImportDialogState
    extends ConsumerState<ClassSubjectImportDialog> {
  final _textController = TextEditingController();
  List<_SubjectImportRow> _rows = [];
  bool _importing = false;
  String? _importError;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = (size.width - 80).clamp(300.0, 680.0).toDouble();
    final height = (size.height - 220).clamp(360.0, 560.0).toDouble();
    final validCount = _rows.where((row) => row.isValid).length;
    final invalidCount = _rows.length - validCount;

    return AlertDialog(
      title: const Text('Excel’den Toplu Ders Ekle'),
      content: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Excel sütun sırası:',
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Ders Adı | Haftalık Saat | Öğretmen (isteğe bağlı)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Excel satırlarını kopyalayıp aşağıya yapıştırın. '
                          'Öğretmen adı kayıtlı öğretmenlerle eşleşmelidir.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Örnek şablonu kopyala',
                    icon: const Icon(Icons.copy_outlined, size: 16),
                    onPressed: _copyTemplate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('class_subject_import_input'),
              controller: _textController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Matematik\t6\tAyşe Yılmaz\nTürk Dili ve Edebiyatı\t5',
                hintStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                suffixIcon: IconButton(
                  tooltip: 'Panodan yapıştır',
                  icon: const Icon(Icons.paste_rounded),
                  onPressed: _pasteFromClipboard,
                ),
              ),
              onChanged: (_) => _parseInput(),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_rows.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Excel verilerinizi yukarıdaki alana yapıştırın.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              )
            else ...[
              Row(
                children: [
                  Text('Önizleme (${_rows.length} satır)'),
                  const Spacer(),
                  Text(
                    '$validCount geçerli',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (invalidCount > 0) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '$invalidCount hatalı',
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              const _SubjectPreviewRow(
                name: 'Ders',
                hours: 'Saat',
                teacher: 'Öğretmen',
                isHeader: true,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: ListView.separated(
                    itemCount: _rows.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final row = _rows[index];
                      return Tooltip(
                        message: row.error ?? '',
                        child: _SubjectPreviewRow(
                          name: row.name,
                          hours: row.hoursText,
                          teacher: row.teacherName,
                          isValid: row.isValid,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            if (_importError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _importError!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _importing ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        FilledButton.icon(
          key: const Key('class_subject_import_confirm'),
          onPressed: _importing || validCount == 0 ? null : _importRows,
          icon: _importing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check, size: 18),
          label: Text('$validCount Dersi Ekle'),
        ),
      ],
    );
  }

  Future<void> _copyTemplate() async {
    await Clipboard.setData(
      const ClipboardData(
        text:
            'Ders Adı\tHaftalık Saat\tÖğretmen\n'
            'Matematik\t6\tAyşe Yılmaz\n'
            'Türk Dili ve Edebiyatı\t5\t',
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Örnek şablon panoya kopyalandı.')),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null) return;
    _textController.text = data!.text!;
    _parseInput();
  }

  void _parseInput() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _rows = [];
        _importError = null;
      });
      return;
    }

    final existingSubjects =
        ref.read(classSubjectsProvider(widget.classId)).valueOrNull ?? [];
    final seenNames = existingSubjects
        .map((subject) => subject.subjectName.toLowerCase())
        .toSet();
    final rows = <_SubjectImportRow>[];
    for (final line in text.split(RegExp(r'\r?\n'))) {
      if (line.trim().isEmpty) continue;
      final columns = line.split(RegExp(r'[\t;]'));
      if (_isHeader(columns)) continue;

      final name = columns.elementAtOrNull(0)?.trim() ?? '';
      final hoursText = columns.elementAtOrNull(1)?.trim() ?? '';
      final teacherName = columns.elementAtOrNull(2)?.trim() ?? '';
      final hours = int.tryParse(hoursText);
      final errors = <String>[];
      int? teacherId;

      if (columns.length < 2 || columns.length > 3) {
        errors.add('Her satırda 2-3 sütun olmalı');
      }
      if (name.isEmpty) errors.add('Ders adı boş');
      if (hours == null || hours < 1 || hours > 40) {
        errors.add('Ders saati 1-40 arasında olmalı');
      }
      final duplicateName =
          name.isNotEmpty && seenNames.contains(name.toLowerCase());
      if (duplicateName) {
        errors.add('Ders sınıfta zaten kayıtlı');
      }
      if (teacherName.isNotEmpty) {
        final matchingTeachers = widget.teachers
            .where(
              (teacher) =>
                  _normalize(teacher.fullName) == _normalize(teacherName),
            )
            .toList();
        if (matchingTeachers.length == 1) {
          teacherId = matchingTeachers.single.id;
        } else {
          errors.add(
            matchingTeachers.isEmpty
                ? 'Öğretmen kayıtlı değil'
                : 'Öğretmen adı birden fazla kayıtla eşleşiyor',
          );
        }
      }
      if (errors.isEmpty) seenNames.add(name.toLowerCase());

      rows.add(
        _SubjectImportRow(
          name: name,
          hoursText: hoursText,
          weeklyHours: hours ?? 0,
          teacherName: teacherName,
          teacherId: teacherId,
          error: errors.isEmpty ? null : errors.join(', '),
        ),
      );
    }
    setState(() {
      _rows = rows;
      _importError = null;
    });
  }

  bool _isHeader(List<String> columns) {
    final first = _normalize(columns.first);
    return first == 'ders' || first == 'ders adi' || first == 'ders adı';
  }

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll('ı', 'i').replaceAll('İ', 'i');

  Future<void> _importRows() async {
    final subjects = _rows
        .where((row) => row.isValid)
        .map(
          (row) => ClassSubject(
            id: 0,
            classId: widget.classId,
            subjectName: row.name,
            weeklyHours: row.weeklyHours,
            teacherId: row.teacherId,
          ),
        )
        .toList();
    if (subjects.isEmpty) return;

    setState(() => _importing = true);
    try {
      await ref
          .read(classSubjectsProvider(widget.classId).notifier)
          .addBatch(classId: widget.classId, subjects: subjects);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${subjects.length} ders eklendi.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _importError = 'Aktarım hatası: $error');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }
}

class _SubjectImportRow {
  const _SubjectImportRow({
    required this.name,
    required this.hoursText,
    required this.weeklyHours,
    required this.teacherName,
    required this.teacherId,
    this.error,
  });

  final String name;
  final String hoursText;
  final int weeklyHours;
  final String teacherName;
  final int? teacherId;
  final String? error;

  bool get isValid => error == null;
}

class _SubjectPreviewRow extends StatelessWidget {
  const _SubjectPreviewRow({
    required this.name,
    required this.hours,
    required this.teacher,
    this.isHeader = false,
    this.isValid = true,
  });

  final String name;
  final String hours;
  final String teacher;
  final bool isHeader;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal,
      color: isValid ? null : AppColors.danger,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, maxLines: 1, style: style)),
          Expanded(child: Text(hours, maxLines: 1, style: style)),
          Expanded(flex: 2, child: Text(teacher, maxLines: 1, style: style)),
          Icon(
            isHeader
                ? Icons.menu_book_outlined
                : isValid
                ? Icons.check_circle_outline
                : Icons.error_outline,
            size: 16,
            color: isValid ? AppColors.success : AppColors.danger,
          ),
        ],
      ),
    );
  }
}
