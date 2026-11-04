import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../students_provider.dart';

/// Yeni rehberlik görüşmesi ekleme dialogu.
class InterviewDialog extends ConsumerStatefulWidget {
  const InterviewDialog({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  final int studentId;
  final String studentName;

  static Future<void> show(
    BuildContext context, {
    required int studentId,
    required String studentName,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => InterviewDialog(
        studentId: studentId,
        studentName: studentName,
      ),
    );
  }

  @override
  ConsumerState<InterviewDialog> createState() => _InterviewDialogState();
}

class _InterviewDialogState extends ConsumerState<InterviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _actionPlanCtrl = TextEditingController();

  String _type = 'student';
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _notesCtrl.dispose();
    _actionPlanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.record_voice_over_outlined,
                color: cs.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Yeni Görüşme Kaydı', style: TextStyle(fontSize: 16)),
                Text(
                  widget.studentName,
                  style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 540,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Görüşme türü seçimi
                Text('Görüşme Türü', style: t.labelSmall),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'student',
                      label: Text('Bireysel (Öğrenci)'),
                      icon: Icon(Icons.person_outline, size: 16),
                    ),
                    ButtonSegment(
                      value: 'parent',
                      label: Text('Veli Görüşmesi'),
                      icon: Icon(Icons.family_restroom_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: 'teacher',
                      label: Text('Öğretmen Görüşmesi'),
                      icon: Icon(Icons.school_outlined, size: 16),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (set) {
                    setState(() => _type = set.first);
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Tarih ve Konu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Görüşme Tarihi',
                            prefixIcon: Icon(Icons.calendar_today_outlined, size: 16),
                          ),
                          child: Text(
                            '${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        controller: _subjectCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Görüşme Konusu *',
                          hintText: 'Örn. Uyum, motivasyon, devamsızlık',
                          prefixIcon: Icon(Icons.topic_outlined, size: 16),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Konu zorunludur'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Görüşme Notları
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Görüşme Detayları ve Notlar *',
                    hintText:
                        'Görüşmede ele alınan konular, öğrencinin/velinin paylaşımları...',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Görüşme notu zorunludur'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // Alınan Kararlar / Takip Planı
                TextFormField(
                  controller: _actionPlanCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Alınan Kararlar / Takip Planı (Opsiyonel)',
                    hintText: 'Sonraki görüşme tarihi, yönlendirme veya takip adımları...',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save_outlined, size: 16),
          label: const Text('Görüşmeyi Kaydet'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final dateStr =
          '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

      await ref
          .read(studentInterviewsProvider(widget.studentId).notifier)
          .addInterview(
            type: _type,
            date: dateStr,
            subject: _subjectCtrl.text.trim(),
            notes: _notesCtrl.text.trim(),
            actionPlan: _actionPlanCtrl.text.trim().isEmpty
                ? null
                : _actionPlanCtrl.text.trim(),
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Görüşme kaydı eklendi.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

