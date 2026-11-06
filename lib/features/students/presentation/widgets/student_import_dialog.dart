import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/student.dart';
import '../students_provider.dart';

/// Excel'den kopyalanan beş sütunlu öğrenci listesini sınıfa aktarır.
class StudentImportDialog extends ConsumerStatefulWidget {
  const StudentImportDialog({
    super.key,
    required this.classId,
    required this.className,
  });

  final int classId;
  final String className;

  static Future<void> show(
    BuildContext context, {
    required int classId,
    required String className,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          StudentImportDialog(classId: classId, className: className),
    );
  }

  @override
  ConsumerState<StudentImportDialog> createState() =>
      _StudentImportDialogState();
}

class _StudentImportDialogState extends ConsumerState<StudentImportDialog> {
  final _textCtrl = TextEditingController();
  List<_ParsedRow> _parsedRows = [];
  bool _importing = false;
  String? _parseError;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = (screenSize.width - 80).clamp(280.0, 680.0).toDouble();
    final dialogHeight = (screenSize.height - 240)
        .clamp(320.0, 520.0)
        .toDouble();
    final validCount = _parsedRows.where((row) => row.isValid).length;
    final errorCount = _parsedRows.length - validCount;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.file_upload_outlined,
              color: cs.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${widget.className} - Toplu Öğrenci Ekle',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
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
                  Icon(Icons.info_outline, size: 18, color: cs.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Excel sütun sırası:',
                          style: t.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Öğrenci No | Adı | Soyadı | Cinsiyeti | Pansiyon Durum',
                          style: t.bodySmall?.copyWith(fontFamily: 'monospace'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Excel’deki satırları kopyalayıp aşağıya yapıştırın. '
                          'Öğrenciler doğrudan ${widget.className} sınıfına eklenir.',
                          style: t.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Örnek şablonu kopyala',
                    icon: const Icon(Icons.copy_outlined, size: 16),
                    onPressed: () async {
                      await Clipboard.setData(
                        const ClipboardData(
                          text:
                              'Öğrenci No\tAdı\tSoyadı\tCinsiyeti\t'
                              'Pansiyon Durum\n'
                              '101\tAhmet\tYılmaz\tErkek\tGündüzlü\n'
                              '102\tAyşe\tKaya\tKız\tYatılı',
                        ),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Örnek şablon panoya kopyalandı.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _textCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    '101\tAhmet\tYılmaz\tErkek\tGündüzlü\n'
                    '102\tAyşe\tKaya\tKız\tYatılı',
                hintStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                suffixIcon: IconButton(
                  tooltip: 'Panodan yapıştır',
                  icon: const Icon(Icons.paste_rounded),
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text == null) return;
                    _textCtrl.text = data!.text!;
                    _parseInput();
                  },
                ),
              ),
              onChanged: (_) => _parseInput(),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_parsedRows.isEmpty)
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
                  Text(
                    'Önizleme (${_parsedRows.length} satır)',
                    style: t.labelMedium,
                  ),
                  const Spacer(),
                  Text(
                    '$validCount geçerli',
                    style: t.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (errorCount > 0) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '$errorCount hatalı',
                      style: t.bodySmall?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              _PreviewRow(
                number: 'Öğrenci No',
                name: 'Adı',
                surname: 'Soyadı',
                gender: 'Cinsiyeti',
                boardingStatus: 'Pansiyon',
                isHeader: true,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: ListView.separated(
                    itemCount: _parsedRows.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final row = _parsedRows[index];
                      return Tooltip(
                        message: row.errorReason ?? '',
                        child: _PreviewRow(
                          number: row.number,
                          name: row.name,
                          surname: row.surname,
                          gender: row.gender,
                          boardingStatus: row.boardingStatus,
                          isValid: row.isValid,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            if (_parseError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _parseError!,
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
          onPressed: (_importing || validCount == 0) ? null : _doImport,
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
            _importing ? 'Aktarılıyor...' : '$validCount Öğrenciyi Ekle',
          ),
        ),
      ],
    );
  }

  void _parseInput() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      setState(() {
        _parsedRows = [];
        _parseError = null;
      });
      return;
    }

    final rows = <_ParsedRow>[];
    for (final rawLine in text.split(RegExp(r'\r?\n'))) {
      if (rawLine.trim().isEmpty) continue;

      final columns = rawLine.split(RegExp(r'[\t;]'));
      if (_isHeader(columns)) continue;

      final number = columns.isNotEmpty ? columns[0].trim() : '';
      final name = columns.length > 1 ? columns[1].trim() : '';
      final surname = columns.length > 2 ? columns[2].trim() : '';
      final gender = columns.length > 3 ? _normalizeGender(columns[3]) : null;
      final boardingStatus = columns.length > 4
          ? _normalizeBoardingStatus(columns[4])
          : null;
      final errors = <String>[];

      if (number.isEmpty) errors.add('Öğrenci numarası boş');
      if (name.isEmpty) errors.add('Ad boş');
      if (surname.isEmpty) errors.add('Soyadı boş');
      if (gender == null) errors.add('Cinsiyet Kız veya Erkek olmalı');
      if (boardingStatus == null) {
        errors.add('Pansiyon durumu Yatılı veya Gündüzlü olmalı');
      }
      if (columns.length != 5) errors.add('Her satırda 5 sütun olmalı');

      rows.add(
        _ParsedRow(
          number: number,
          name: name,
          surname: surname,
          gender: gender ?? columns.elementAtOrNull(3)?.trim() ?? '-',
          boardingStatus:
              boardingStatus ?? columns.elementAtOrNull(4)?.trim() ?? '-',
          errorReason: errors.isEmpty ? null : errors.join(', '),
        ),
      );
    }

    setState(() {
      _parsedRows = rows;
      _parseError = null;
    });
  }

  bool _isHeader(List<String> columns) {
    if (columns.length < 5) return false;
    final first = columns.first.trim().toLowerCase();
    return first.contains('öğrenci') || first == 'okul no' || first == 'no';
  }

  String? _normalizeGender(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'kız' || normalized == 'kiz') return 'Kız';
    if (normalized == 'erkek') return 'Erkek';
    return null;
  }

  String? _normalizeBoardingStatus(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'yatılı' || normalized == 'yatili') return 'Yatılı';
    if (normalized == 'gündüzlü' || normalized == 'gunduzlu') {
      return 'Gündüzlü';
    }
    return null;
  }

  Future<void> _doImport() async {
    final validRows = _parsedRows.where((row) => row.isValid).toList();
    if (validRows.isEmpty) return;

    setState(() => _importing = true);
    try {
      final now = DateTime.now().toIso8601String();
      final students = validRows
          .map(
            (row) => Student(
              id: 0,
              classId: widget.classId,
              number: row.number,
              name: row.name,
              surname: row.surname,
              gender: row.gender,
              boardingStatus: row.boardingStatus,
              createdAt: now,
            ),
          )
          .toList();
      final count = await ref
          .read(studentsProvider.notifier)
          .addBatch(students);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count öğrenci ${widget.className} sınıfına eklendi.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _parseError = 'Aktarım sırasında hata: $error');
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }
}

class _ParsedRow {
  const _ParsedRow({
    required this.number,
    required this.name,
    required this.surname,
    required this.gender,
    required this.boardingStatus,
    this.errorReason,
  });

  final String number;
  final String name;
  final String surname;
  final String gender;
  final String boardingStatus;
  final String? errorReason;

  bool get isValid => errorReason == null;
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.number,
    required this.name,
    required this.surname,
    required this.gender,
    required this.boardingStatus,
    this.isHeader = false,
    this.isValid = true,
  });

  final String number;
  final String name;
  final String surname;
  final String gender;
  final String boardingStatus;
  final bool isHeader;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: isHeader ? FontWeight.w700 : null,
      color: isHeader ? AppColors.textSecondary : null,
    );
    return Container(
      color: isHeader
          ? AppColors.surfaceMuted
          : isValid
          ? null
          : AppColors.danger.withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(number, style: style, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: Text(name, style: style, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: Text(surname, style: style, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 1,
            child: Text(gender, style: style, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: Text(
              boardingStatus,
              style: style,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isHeader)
            Icon(
              isValid ? Icons.check_circle_outline : Icons.error_outline,
              color: isValid ? AppColors.success : AppColors.danger,
              size: 16,
            ),
        ],
      ),
    );
  }
}
