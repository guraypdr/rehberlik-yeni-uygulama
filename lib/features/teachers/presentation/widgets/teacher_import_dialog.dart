import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/teacher.dart';
import '../teachers_provider.dart';

class TeacherImportDialog extends ConsumerStatefulWidget {
  const TeacherImportDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const TeacherImportDialog(),
  );

  @override
  ConsumerState<TeacherImportDialog> createState() =>
      _TeacherImportDialogState();
}

class _TeacherImportDialogState extends ConsumerState<TeacherImportDialog> {
  final _textController = TextEditingController();
  List<_TeacherRow> _rows = [];
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
      title: const Text('Excel’den Toplu Öğretmen Ekle'),
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
                          'Adı | Soyadı | Branş | E-posta | Cep telefonu',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Excel’deki satırları kopyalayıp aşağıya yapıştırın. '
                          'İlk üç sütun zorunludur; e-posta ve telefon isteğe bağlıdır.',
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
              key: const Key('teacher_import_input'),
              controller: _textController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Ayşe\\tYılmaz\\tTürkçe\\tayse@example.com\\t05551234567\\n'
                    'Mehmet\\tKaya\\tMatematik',
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
              const _TeacherPreviewRow(
                name: 'Ad',
                surname: 'Soyad',
                branch: 'Branş',
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
                        child: _TeacherPreviewRow(
                          name: row.name,
                          surname: row.surname,
                          branch: row.branch,
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
          key: const Key('teacher_import_confirm'),
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
              : const Icon(Icons.check, size: 16),
          label: Text(
            _importing ? 'Ekleniyor...' : '$validCount Öğretmeni Ekle',
          ),
        ),
      ],
    );
  }

  Future<void> _copyTemplate() async {
    await Clipboard.setData(
      const ClipboardData(
        text:
            'Adı\tSoyadı\tBranş\tE-posta\tCep telefonu\n'
            'Ayşe\tYılmaz\tTürkçe\tayse@example.com\t05551234567\n'
            'Mehmet\tKaya\tMatematik\t\t',
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

    final rows = <_TeacherRow>[];
    for (final line in text.split(RegExp(r'\r?\n'))) {
      if (line.trim().isEmpty) continue;
      final columns = line.split(RegExp(r'[\t;]'));
      if (_isHeader(columns)) continue;

      final name = columns.elementAtOrNull(0)?.trim() ?? '';
      final surname = columns.elementAtOrNull(1)?.trim() ?? '';
      final branch = columns.elementAtOrNull(2)?.trim() ?? '';
      final email = columns.elementAtOrNull(3)?.trim() ?? '';
      final phone = columns.elementAtOrNull(4)?.trim() ?? '';
      final errors = <String>[];

      if (columns.length < 3 || columns.length > 5) {
        errors.add('Her satırda 3-5 sütun olmalı');
      }
      if (name.isEmpty) errors.add('Ad boş');
      if (surname.isEmpty) errors.add('Soyad boş');
      if (branch.isEmpty) errors.add('Branş boş');
      if (email.isNotEmpty &&
          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
        errors.add('E-posta geçerli değil');
      }
      rows.add(
        _TeacherRow(
          name: name,
          surname: surname,
          branch: branch,
          email: email,
          phone: phone,
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
    final first = columns.first.trim().toLowerCase();
    return first == 'ad' || first == 'adı' || first == 'isim';
  }

  Future<void> _importRows() async {
    final teachers = _rows
        .where((row) => row.isValid)
        .map(
          (row) => Teacher(
            id: 0,
            name: row.name,
            surname: row.surname,
            branch: row.branch,
            email: row.email.isEmpty ? null : row.email,
            phone: row.phone.isEmpty ? null : row.phone,
          ),
        )
        .toList();
    if (teachers.isEmpty) return;

    setState(() => _importing = true);
    try {
      final count = await ref
          .read(teachersProvider.notifier)
          .addBatch(teachers);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count öğretmen eklendi.'),
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

class _TeacherRow {
  const _TeacherRow({
    required this.name,
    required this.surname,
    required this.branch,
    required this.email,
    required this.phone,
    this.error,
  });

  final String name;
  final String surname;
  final String branch;
  final String email;
  final String phone;
  final String? error;

  bool get isValid => error == null;
}

class _TeacherPreviewRow extends StatelessWidget {
  const _TeacherPreviewRow({
    required this.name,
    required this.surname,
    required this.branch,
    this.isHeader = false,
    this.isValid = true,
  });

  final String name;
  final String surname;
  final String branch;
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
          Expanded(flex: 2, child: Text(name, maxLines: 1, style: style)),
          Expanded(flex: 2, child: Text(surname, maxLines: 1, style: style)),
          Expanded(flex: 2, child: Text(branch, maxLines: 1, style: style)),
          Icon(
            isHeader
                ? Icons.person_outline
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
