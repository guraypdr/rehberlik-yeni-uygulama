import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../classes_provider.dart';

/// Yeni şube ekleme alanı.
///
/// Sınıf düzeyi dropdown'dan seçilir, şube harfi (A, B …) girilir.
class ClassComposer extends ConsumerStatefulWidget {
  const ClassComposer({
    super.key,
    this.fields = const [],
    this.requiresField = false,
  });

  final List<String> fields;
  final bool requiresField;

  @override
  ConsumerState<ClassComposer> createState() => _ClassComposerState();
}

class _ClassComposerState extends ConsumerState<ClassComposer> {
  final TextEditingController _branchController = TextEditingController();
  int? _selectedGradeLevelId;
  String? _selectedGradeLevelLabel;
  String? _selectedField;

  @override
  void dispose() {
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final branch = _branchController.text.trim().toUpperCase();
    if (branch.isEmpty ||
        _selectedGradeLevelId == null ||
        (widget.requiresField && _selectedField == null)) {
      return;
    }

    await ref
        .read(classesProvider.notifier)
        .addClass(
          gradeLevelId: _selectedGradeLevelId!,
          gradeLevelLabel: _selectedGradeLevelLabel!,
          branch: branch,
          fieldName: _selectedField,
        );
    _branchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final asyncClasses = ref.watch(classesProvider);
    final gradeLevels = asyncClasses.valueOrNull?.gradeLevels ?? [];
    final hasFields = widget.fields.isNotEmpty;
    if (_selectedField != null && !widget.fields.contains(_selectedField)) {
      _selectedField = null;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 760;

        final levelDropdown = DropdownButtonFormField<int>(
          key: const Key('class_level_dropdown'),
          initialValue: _selectedGradeLevelId,
          decoration: const InputDecoration(
            hintText: 'Sınıf düzeyi',
            prefixIcon: Icon(Icons.school_outlined, size: 20),
          ),
          items: [
            for (final level in gradeLevels)
              DropdownMenuItem<int>(value: level.id, child: Text(level.label)),
          ],
          onChanged: (val) {
            if (val == null) return;
            final level = gradeLevels.firstWhere((l) => l.id == val);
            setState(() {
              _selectedGradeLevelId = val;
              _selectedGradeLevelLabel = level.label;
            });
          },
        );

        final branchField = TextField(
          key: const Key('class_branch_input'),
          controller: _branchController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.characters,
          maxLength: 3,
          onSubmitted: (_) => _submit(),
          decoration: const InputDecoration(
            hintText: 'Şube (A, B…)',
            prefixIcon: Icon(Icons.meeting_room_outlined, size: 20),
            counterText: '',
          ),
        );

        final fieldDropdown = DropdownButtonFormField<String>(
          key: const Key('class_field_dropdown'),
          initialValue: _selectedField,
          decoration: const InputDecoration(
            hintText: 'Alan',
            prefixIcon: Icon(Icons.category_outlined, size: 20),
          ),
          items: [
            for (final field in widget.fields)
              DropdownMenuItem<String>(value: field, child: Text(field)),
          ],
          onChanged: (value) => setState(() => _selectedField = value),
        );

        final addButton = FilledButton.icon(
          key: const Key('class_add_button'),
          onPressed: widget.requiresField && !hasFields ? null : _submit,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Ekle'),
        );

        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              levelDropdown,
              const SizedBox(height: AppSpacing.sm),
              branchField,
              if (hasFields) ...[
                const SizedBox(height: AppSpacing.sm),
                fieldDropdown,
              ] else if (widget.requiresField) ...[
                const SizedBox(height: AppSpacing.sm),
                const Text('Şube eklemek için önce okul alanı ekleyin.'),
              ],
              const SizedBox(height: AppSpacing.sm),
              addButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 3, child: levelDropdown),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: branchField),
            if (hasFields) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(flex: 2, child: fieldDropdown),
            ] else if (widget.requiresField) ...[
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Text('Şube eklemek için önce okul alanı ekleyin.'),
              ),
            ],
            const SizedBox(width: AppSpacing.md),
            addButton,
          ],
        );
      },
    );
  }
}
