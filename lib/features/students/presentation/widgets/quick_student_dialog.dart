import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../classes/presentation/classes_provider.dart';
import '../students_provider.dart';
import '../../domain/student.dart';

/// Modern, görsel önizlemeli hızlı öğrenci ekleme modalı.
class QuickStudentDialog extends ConsumerStatefulWidget {
  const QuickStudentDialog({
    super.key,
    this.initialClassId,
    this.onStudentCreated,
  });

  final int? initialClassId;
  final void Function(Student student, bool openDetails)? onStudentCreated;

  static Future<void> show(
    BuildContext context, {
    int? initialClassId,
    void Function(Student student, bool openDetails)? onStudentCreated,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => QuickStudentDialog(
        initialClassId: initialClassId,
        onStudentCreated: onStudentCreated,
      ),
    );
  }

  @override
  ConsumerState<QuickStudentDialog> createState() => _QuickStudentDialogState();
}

class _QuickStudentDialogState extends ConsumerState<QuickStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();

  String _gender = 'Kız';
  String _boardingStatus = 'Gündüzlü';
  int? _selectedGradeLevelId;
  int? _selectedClassId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.initialClassId;
    _nameCtrl.addListener(() => setState(() {}));
    _surnameCtrl.addListener(() => setState(() {}));
    _numberCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final classesState = ref.watch(classesProvider).valueOrNull;
    final classes = classesState?.classes ?? [];
    final gradeLevels = classesState?.gradeLevels ?? [];

    // Başlangıçta şube ve sınıf düzeyini senkronize et
    if (_selectedClassId != null && _selectedGradeLevelId == null) {
      final match = classes.where((c) => c.id == _selectedClassId).firstOrNull;
      if (match != null) {
        _selectedGradeLevelId = match.gradeLevelId;
      }
    }

    if (_selectedGradeLevelId == null && gradeLevels.isNotEmpty) {
      _selectedGradeLevelId = gradeLevels.first.id;
    }

    // Seçili sınıf düzeyine ait şubeler
    final currentBranches = classes
        .where((c) => c.gradeLevelId == _selectedGradeLevelId)
        .toList();

    if (_selectedClassId == null && currentBranches.isNotEmpty) {
      _selectedClassId = currentBranches.first.id;
    }

    final selectedClass = classes
        .where((c) => c.id == _selectedClassId)
        .firstOrNull;

    final isFemale = _gender == 'Kız';
    final genderColor = isFemale
        ? const Color(0xFFE91E63)
        : const Color(0xFF1976D2);
    final genderGradient = isFemale
        ? const LinearGradient(
            colors: [Color(0xFFF06292), Color(0xFFE91E63)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final fullName = '${_nameCtrl.text.trim()} ${_surnameCtrl.text.trim()}'
        .trim();
    final initials = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim().characters.first.toUpperCase()
        : 'Ö';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      elevation: 12,
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Üst Başlık & Canlı Profil Önizleme Kartı ─────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.05),
                    border: const Border(
                      bottom: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Başlık ve Kapat Butonu
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs + 2),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: const Icon(
                              Icons.person_add_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Yeni Öğrenci Ekle',
                            style: t.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Kapat',
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Canlı Önizleme Kartı (Live Preview)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: genderColor.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: genderColor.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: genderGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: genderColor.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            // İsim, Numara, Şube
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName.isNotEmpty
                                        ? fullName
                                        : 'Öğrenci Adı ve Soyadı',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: fullName.isNotEmpty
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      // Okul No Rozeti
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceMuted,
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.sm,
                                          ),
                                          border: Border.all(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        child: Text(
                                          _numberCtrl.text.trim().isNotEmpty
                                              ? 'No: ${_numberCtrl.text.trim()}'
                                              : 'No: —',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      // Şube Rozeti
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cs.primary.withValues(
                                            alpha: 0.10,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.pill,
                                          ),
                                        ),
                                        child: Text(
                                          selectedClass != null
                                              ? '${selectedClass.gradeLevelLabel} / ${selectedClass.branch}'
                                              : 'Şube Seçilmedi',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: cs.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      // Cinsiyet Rozeti
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: genderColor.withValues(
                                            alpha: 0.10,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.pill,
                                          ),
                                        ),
                                        child: Text(
                                          _gender,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: genderColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 2. Form İçeriği ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Adı ve Soyadı
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameCtrl,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  labelText: 'Adı *',
                                  hintText: 'Örn. Ahmet',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    size: 18,
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Ad zorunludur'
                                    : null,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: TextFormField(
                                controller: _surnameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Soyadı *',
                                  hintText: 'Örn. Yılmaz',
                                  prefixIcon: Icon(
                                    Icons.badge_outlined,
                                    size: 18,
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Soyad zorunludur'
                                    : null,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Okul Numarası ve Cinsiyet
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Okul No
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                controller: _numberCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Öğrenci No *',
                                  hintText: 'Örn. 142',
                                  prefixIcon: Icon(
                                    Icons.numbers_outlined,
                                    size: 18,
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Numara zorunludur'
                                    : null,
                                keyboardType: TextInputType.text,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            // Cinsiyet Seçimi (Modern Toggle Kartları)
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cinsiyet',
                                    style: t.labelSmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _GenderPill(
                                          label: 'Kız',
                                          icon: Icons.female,
                                          isSelected: _gender == 'Kız',
                                          color: const Color(0xFFE91E63),
                                          onTap: () =>
                                              setState(() => _gender = 'Kız'),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: _GenderPill(
                                          label: 'Erkek',
                                          icon: Icons.male,
                                          isSelected: _gender == 'Erkek',
                                          color: const Color(0xFF1976D2),
                                          onTap: () =>
                                              setState(() => _gender = 'Erkek'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        DropdownButtonFormField<String>(
                          initialValue: _boardingStatus,
                          decoration: const InputDecoration(
                            labelText: 'Pansiyon Durumu',
                            prefixIcon: Icon(Icons.hotel_outlined, size: 18),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Yatılı',
                              child: Text('Yatılı'),
                            ),
                            DropdownMenuItem(
                              value: 'Gündüzlü',
                              child: Text('Gündüzlü'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _boardingStatus = value);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // ── Sınıf ve Şube Seçimi (Görsel Seçici) ─────────────
                        if (widget.initialClassId == null) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.meeting_room_outlined,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Sınıf Düzeyi ve Şube *',
                                style: t.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          if (classes.isEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                border: Border.all(
                                  color: AppColors.warning.withValues(
                                    alpha: 0.30,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      'Kayıt yapabilmek için önce Sınıflar sayfasından en az bir şube tanımlamalısınız.',
                                      style: t.bodySmall?.copyWith(
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // Sınıf Düzeyi Butonları (9. Sınıf, 10. Sınıf vb.)
                            if (gradeLevels.length > 1) ...[
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (final g in gradeLevels) ...[
                                      _LevelChip(
                                        label: g.label,
                                        isSelected:
                                            _selectedGradeLevelId == g.id,
                                        onTap: () {
                                          setState(() {
                                            _selectedGradeLevelId = g.id;
                                            final br = classes
                                                .where(
                                                  (c) => c.gradeLevelId == g.id,
                                                )
                                                .toList();
                                            if (br.isNotEmpty) {
                                              _selectedClassId = br.first.id;
                                            } else {
                                              _selectedClassId = null;
                                            }
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                            ],

                            // Seçili Düzeyin Şubeleri (A, B, C, D vb.)
                            if (currentBranches.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        for (final c in currentBranches) ...[
                                          _BranchButton(
                                            branch: c.branch,
                                            fieldName: c.fieldName,
                                            isSelected:
                                                _selectedClassId == c.id,
                                            onTap: () {
                                              setState(
                                                () => _selectedClassId = c.id,
                                              );
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Bu sınıf düzeyinde henüz şube açılmamış.',
                                  style: t.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ] else ...[
                          InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Sınıf / Şube',
                              prefixIcon: Icon(Icons.meeting_room_outlined),
                            ),
                            child: Text(
                              selectedClass?.displayName ?? 'Sınıf bulunamadı',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── 3. Alt Butonlar ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Vazgeç'),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed:
                            (_saving ||
                                classes.isEmpty ||
                                _selectedClassId == null)
                            ? null
                            : () => _submit(openDetails: false),
                        child: const Text('Kaydet'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilledButton.icon(
                        onPressed:
                            (_saving ||
                                classes.isEmpty ||
                                _selectedClassId == null)
                            ? null
                            : () => _submit(openDetails: true),
                        icon: _saving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text(
                          'Kaydet ve Öğrenci Bilgi Formunu Doldur',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit({required bool openDetails}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClassId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir şube seçiniz.')));
      return;
    }

    setState(() => _saving = true);

    try {
      final student = await ref
          .read(studentsProvider.notifier)
          .addBasicStudent(
            classId: _selectedClassId!,
            number: _numberCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            surname: _surnameCtrl.text.trim(),
            gender: _gender,
            boardingStatus: _boardingStatus,
          );

      if (mounted) {
        Navigator.of(context).pop();
        if (student != null && widget.onStudentCreated != null) {
          widget.onStudentCreated!(student, openDetails);
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Öğrenci kaydedilemedi: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Yardımcı Özel Seçici Widget'ları
// ────────────────────────────────────────────────────────────────────────────

class _GenderPill extends StatelessWidget {
  const _GenderPill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(Icons.check_circle_rounded, color: color, size: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: isSelected ? cs.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _BranchButton extends StatelessWidget {
  const _BranchButton({
    required this.branch,
    this.fieldName,
    required this.isSelected,
    required this.onTap,
  });

  final String branch;
  final String? fieldName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? cs.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Şube $branch',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (fieldName != null) ...[
              const SizedBox(width: 4),
              Text(
                '($fieldName)',
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.85)
                      : AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
