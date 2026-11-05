import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/setup/data/school_profile_dao.dart';
import '../domain/school_profile.dart';
import 'widgets/field_chip_editor.dart';

/// Okul kurulum sihirbazı — 2 adımlı.
///
/// Adım 1: Okul adı, türü, hazırlık ve alan seçimi.
/// Adım 2: Önizleme ve veritabanı oluşturma.
class SetupPage extends ConsumerStatefulWidget {
  const SetupPage({super.key});

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends ConsumerState<SetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  SchoolType _schoolType = SchoolType.lise;
  bool _hasPrep = false;
  List<String> _fields = [];

  int _step = 0; // 0 = form, 1 = önizleme

  bool get _showPrepSwitch => _schoolType == SchoolType.lise;
  bool get _showFieldEditor =>
      _schoolType == SchoolType.lise || _schoolType == SchoolType.meslekLisesi;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionAsync = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: _step == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Geri',
                onPressed: () => setState(() => _step = 0),
              )
            : IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'İptal',
                onPressed: () => context.go('/'),
              ),
        title: Text(
          _step == 0 ? 'Okul Bilgileri' : 'Önizleme',
          style: theme.textTheme.titleMedium,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _step == 0
                  ? _buildFormStep(theme)
                  : _buildPreviewStep(theme, sessionAsync),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Adım 1 — Form
  // ---------------------------------------------------------------------------

  Widget _buildFormStep(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Okul adı
          Text('Okul Adı', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _nameController,
            autofocus: true,
            maxLength: 120,
            decoration: const InputDecoration(
              hintText: 'Örn. Ankara Anadolu Lisesi',
              counterText: '',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Okul adı zorunludur.';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Okul türü
          Text('Okul Türü', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          _SchoolTypeSelector(
            value: _schoolType,
            onChanged: (t) => setState(() {
              _schoolType = t;
              _hasPrep = false;
              _fields = [];
            }),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Hazırlık sınıfı (yalnızca Lise)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _showPrepSwitch
                ? _PrepSwitch(
                    value: _hasPrep,
                    onChanged: (v) => setState(() => _hasPrep = v),
                  )
                : const SizedBox.shrink(),
          ),

          // Alan editörü (liseler)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _showFieldEditor
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Okul Alanları', style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Şubeleri gruplamak için okulunuzdaki alanları ekleyin.',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FieldChipEditor(
                        fields: _fields,
                        onChanged: (fields) => setState(() => _fields = fields),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          FilledButton(onPressed: _goToPreview, child: const Text('İleri →')),
        ],
      ),
    );
  }

  void _goToPreview() {
    if (!_formKey.currentState!.validate()) return;
    if (_showFieldEditor && _fields.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('En az bir alan ekleyin.')));
      return;
    }
    setState(() => _step = 1);
  }

  // ---------------------------------------------------------------------------
  // Adım 2 — Önizleme
  // ---------------------------------------------------------------------------

  Widget _buildPreviewStep(
    ThemeData theme,
    AsyncValue<SessionState> sessionAsync,
  ) {
    final profile = SchoolProfile(
      name: _nameController.text.trim(),
      schoolType: _schoolType,
      hasPrep: _hasPrep,
      fields: _fields,
      createdAt: DateTime.now(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PreviewCard(profile: profile),
        const SizedBox(height: AppSpacing.xl),

        if (sessionAsync.hasError)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              sessionAsync.error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.danger,
              ),
            ),
          ),

        FilledButton.icon(
          onPressed: sessionAsync.isLoading ? null : _createDatabase,
          icon: sessionAsync.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: const Text('Veritabanı Oluştur'),
        ),
      ],
    );
  }

  Future<void> _createDatabase() async {
    final profile = SchoolProfileDaoInput(
      name: _nameController.text.trim(),
      schoolType: _schoolType,
      hasPrep: _hasPrep,
      fields: _fields,
    );

    // Kullanıcıdan kayıt konumu iste.
    final safeName = profile.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Veritabanını nereye kaydedelim?',
      fileName: '$safeName.rdb',
      type: FileType.custom,
      allowedExtensions: ['rdb'],
    );

    if (savePath == null) return; // Kullanıcı iptal etti.

    // .rdb uzantısını garantile.
    final finalPath = savePath.endsWith('.rdb') ? savePath : '$savePath.rdb';

    if (!mounted) return;
    await ref
        .read(sessionProvider.notifier)
        .createNewFile(filePath: finalPath, input: profile);
  }
}

// ---------------------------------------------------------------------------
// Alt widget'lar
// ---------------------------------------------------------------------------

class _SchoolTypeSelector extends StatelessWidget {
  const _SchoolTypeSelector({required this.value, required this.onChanged});

  final SchoolType value;
  final ValueChanged<SchoolType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final type in SchoolType.values)
          ChoiceChip(
            label: Text(type.label),
            selected: value == type,
            onSelected: (_) => onChanged(type),
          ),
      ],
    );
  }
}

class _PrepSwitch extends StatelessWidget {
  const _PrepSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
          border: Border.all(color: AppColors.border),
        ),
        child: SwitchListTile(
          title: const Text('Hazırlık Sınıfı'),
          subtitle: const Text('Okulunuzda hazırlık sınıfı var mı?'),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.profile});

  final SchoolProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final levels = profile.gradeLevelLabels;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(theme, 'Okul Adı', profile.name),
          const SizedBox(height: AppSpacing.md),
          _row(theme, 'Okul Türü', profile.schoolType.label),
          if (profile.schoolType == SchoolType.lise) ...[
            const SizedBox(height: AppSpacing.md),
            _row(theme, 'Hazırlık Sınıfı', profile.hasPrep ? 'Var' : 'Yok'),
          ],
          if (profile.fields.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _row(theme, 'Alanlar', profile.fields.join(', ')),
          ],
          const Divider(height: AppSpacing.xl),
          Text(
            'Oluşturulacak sınıf düzeyleri:',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final label in levels)
                Chip(
                  label: Text(label, style: theme.textTheme.bodySmall),
                  backgroundColor: colorScheme.primaryContainer,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${levels.length} sınıf düzeyi oluşturulacak.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
      ],
    );
  }
}
