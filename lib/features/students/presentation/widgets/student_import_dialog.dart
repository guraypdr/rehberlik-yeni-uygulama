import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../classes/presentation/classes_provider.dart';
import '../students_provider.dart';
import '../../domain/student.dart';

/// Excel veya CSV'den kopyalanan öğrenci satırlarını toplu içe aktarma dialogu.
///
/// Sütun Formatı:
///   Okul No | Adı | Soyadı | Cinsiyet (Kız/Erkek) | Şube (Örn: 9/A veya 9-A)
class StudentImportDialog extends ConsumerStatefulWidget {
  const StudentImportDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const StudentImportDialog(),
    );
  }

  @override
  ConsumerState<StudentImportDialog> createState() => _StudentImportDialogState();
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
    final classesState = ref.watch(classesProvider).valueOrNull;
    final classes = classesState?.classes ?? [];

    final validCount = _parsedRows.where((r) => r.isValid).length;
    final errorCount = _parsedRows.where((r) => !r.isValid).length;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.file_upload_outlined, color: cs.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Text('Excel / CSV ile Öğrenci İçe Aktar'),
        ],
      ),
      content: SizedBox(
        width: 640,
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bilgi bannerı
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
                          style: t.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '1. Okul No  |  2. Adı  |  3. Soyadı  |  4. Cinsiyet (Kız/Erkek)  |  5. Şube (Örn: 9/A)',
                          style: t.bodySmall?.copyWith(fontFamily: 'monospace'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Excel tablonuzdaki hücreleri seçip kopyalayın (Ctrl+C) ve aşağıdaki alana yapıştırın (Ctrl+V).',
                          style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Örnek Şablonu Kopyala',
                    icon: const Icon(Icons.copy_outlined, size: 16),
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(
                        text: "101\tAhmet\tYılmaz\tErkek\t9/A\n"
                            "102\tAyşe\tKaya\tKız\t9/A\n"
                            "103\tMehmet\tDemir\tErkek\t10/B",
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Örnek veri panoya kopyalandı!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Metin yapıştırma alanı
            TextField(
              controller: _textCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    "101\tAhmet\tYılmaz\tErkek\t9/A\n102\tAyşe\tKaya\tKız\t9/B\n...",
                hintStyle: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                suffixIcon: IconButton(
                  tooltip: 'Yapıştır ve Ayrıştır',
                  icon: const Icon(Icons.paste_rounded),
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      _textCtrl.text = data!.text!;
                      _parseInput(classes);
                    }
                  },
                ),
              ),
              onChanged: (_) => _parseInput(classes),
            ),
            const SizedBox(height: AppSpacing.md),

            // Durum özeti
            if (_parsedRows.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    'Önizleme (${_parsedRows.length} satır algılandı):',
                    style: t.labelMedium,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '$validCount geçerli',
                      style: t.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (errorCount > 0) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '$errorCount hatalı/şube bulunamadı',
                        style: t.bodySmall?.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Tablo önizleme
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: ListView.separated(
                    itemCount: _parsedRows.length,
                    separatorBuilder: (_, index) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final r = _parsedRows[idx];
                      return Container(
                        color: r.isValid
                            ? Colors.transparent
                            : AppColors.danger.withValues(alpha: 0.05),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs + 2,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Text(
                                r.number,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('${r.name} ${r.surname}'),
                            ),
                            SizedBox(
                              width: 70,
                              child: Text(
                                r.gender,
                                style: TextStyle(
                                  color: r.gender == 'Kız'
                                      ? Colors.pink
                                      : Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                r.classText,
                                style: TextStyle(
                                  color: r.matchedClassId != null
                                      ? AppColors.textPrimary
                                      : AppColors.danger,
                                  fontWeight: r.matchedClassId != null
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (!r.isValid)
                              Tooltip(
                                message: r.errorReason ?? 'Hata',
                                child: const Icon(
                                  Icons.error_outline,
                                  color: AppColors.danger,
                                  size: 16,
                                ),
                              )
                            else
                              const Icon(
                                Icons.check_circle_outline,
                                color: AppColors.success,
                                size: 16,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Text(
                    'Yukarıdaki alana Excel verilerinizi yapıştırın.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
            ],

            if (_parseError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_parseError!, style: const TextStyle(color: AppColors.danger)),
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
          onPressed: (_importing || validCount == 0) ? null : () => _doImport(),
          icon: _importing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check, size: 16),
          label: Text(_importing ? 'Aktarılıyor...' : '$validCount Öğrenciyi İçe Aktar'),
        ),
      ],
    );
  }

  void _parseInput(List<dynamic> classes) {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      setState(() {
        _parsedRows = [];
        _parseError = null;
      });
      return;
    }

    final lines = text.split(RegExp(r'\r?\n'));
    final parsed = <_ParsedRow>[];

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Tab, noktalı virgül veya virgül ile ayır
      final parts = line.split(RegExp(r'[\t;]'));
      if (parts.length < 3) continue;

      final number = parts[0].trim();
      final name = parts[1].trim();
      final surname = parts.length > 2 ? parts[2].trim() : '';
      String gender = 'Erkek';
      String classText = '';

      if (parts.length > 3) {
        final g = parts[3].trim().toLowerCase();
        if (g.startsWith('k')) {
          gender = 'Kız';
        } else if (g.startsWith('e')) {
          gender = 'Erkek';
        }
      }

      if (parts.length > 4) {
        classText = parts[4].trim();
      }

      // Şubeyi bul
      int? matchedClassId;
      String? error;

      if (number.isEmpty || name.isEmpty || surname.isEmpty) {
        error = 'Numara, Ad ve Soyad zorunludur';
      } else if (classText.isEmpty) {
        // Eğer tek şube varsa ona bağla, yoksa hata
        if (classes.length == 1) {
          matchedClassId = classes.first.id as int;
        } else {
          error = 'Şube belirtilmedi';
        }
      } else {
        // classText ile şube eşleştir (örn "9/A", "9-A", "9 A", "9. Sınıf / A")
        final normalized = classText.replaceAll('-', '/').replaceAll(' ', '').toUpperCase();
        for (final c in classes) {
          final cNorm = '${c.gradeLevelLabel}/${c.branch}'
              .replaceAll(' ', '')
              .toUpperCase();
          final cShort = '${_extractLevelNum(c.gradeLevelLabel)}/${c.branch}'
              .toUpperCase();

          if (normalized == cNorm ||
              normalized == cShort ||
              normalized.endsWith('/${c.branch.toUpperCase()}')) {
            matchedClassId = c.id as int;
            break;
          }
        }
        if (matchedClassId == null) {
          error = 'Sistemde "$classText" şubesi bulunamadı';
        }
      }

      parsed.add(_ParsedRow(
        number: number,
        name: name,
        surname: surname,
        gender: gender,
        classText: classText.isEmpty ? (matchedClassId != null ? 'Varsayılan' : '-') : classText,
        matchedClassId: matchedClassId,
        errorReason: error,
      ));
    }

    setState(() {
      _parsedRows = parsed;
      _parseError = null;
    });
  }

  String _extractLevelNum(String label) {
    final m = RegExp(r'\d+').firstMatch(label);
    return m != null ? m.group(0)! : label;
  }

  Future<void> _doImport() async {
    final valid = _parsedRows.where((r) => r.isValid).toList();
    if (valid.isEmpty) return;

    setState(() => _importing = true);

    try {
      final now = DateTime.now().toIso8601String();
      final students = valid.map((r) {
        return Student(
          id: 0,
          classId: r.matchedClassId!,
          number: r.number,
          name: r.name,
          surname: r.surname,
          gender: r.gender,
          status: 'Aktif',
          createdAt: now,
        );
      }).toList();

      final count = await ref.read(studentsProvider.notifier).addBatch(students);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$count öğrenci başarıyla içe aktarıldı!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _parseError = 'Aktarım sırasında hata: $e');
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
    required this.classText,
    this.matchedClassId,
    this.errorReason,
  });

  final String number;
  final String name;
  final String surname;
  final String gender;
  final String classText;
  final int? matchedClassId;
  final String? errorReason;

  bool get isValid => matchedClassId != null && errorReason == null;
}
