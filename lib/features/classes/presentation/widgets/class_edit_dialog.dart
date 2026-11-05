import 'package:flutter/material.dart';

import '../../domain/grade_level.dart';
import '../../domain/school_class.dart';

class ClassEditDialog extends StatefulWidget {
  const ClassEditDialog({
    super.key,
    required this.schoolClass,
    required this.gradeLevels,
    required this.fields,
  });

  final SchoolClass schoolClass;
  final List<GradeLevel> gradeLevels;
  final List<String> fields;

  @override
  State<ClassEditDialog> createState() => _ClassEditDialogState();
}

class _ClassEditDialogState extends State<ClassEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _branchController;
  late int _gradeLevelId;
  String? _fieldName;

  @override
  void initState() {
    super.initState();
    _branchController = TextEditingController(text: widget.schoolClass.branch);
    _gradeLevelId = widget.schoolClass.gradeLevelId;
    _fieldName = widget.fields.contains(widget.schoolClass.fieldName)
        ? widget.schoolClass.fieldName
        : null;
  }

  @override
  void dispose() {
    _branchController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final gradeLevel = widget.gradeLevels.firstWhere(
      (level) => level.id == _gradeLevelId,
    );
    Navigator.of(context).pop(
      widget.schoolClass.copyWith(
        gradeLevelId: gradeLevel.id,
        gradeLevelLabel: gradeLevel.label,
        branch: _branchController.text.trim().toUpperCase(),
        fieldName: _fieldName,
        clearField: _fieldName == null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sınıfı Düzenle'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              key: const Key('edit_class_level_dropdown'),
              initialValue: _gradeLevelId,
              decoration: const InputDecoration(labelText: 'Sınıf düzeyi'),
              items: [
                for (final level in widget.gradeLevels)
                  DropdownMenuItem<int>(
                    value: level.id,
                    child: Text(level.label),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _gradeLevelId = value);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('edit_class_branch_input'),
              controller: _branchController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 3,
              decoration: const InputDecoration(
                labelText: 'Şube',
                hintText: 'A, B…',
                counterText: '',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Şube adı zorunludur.'
                  : null,
            ),
            if (widget.fields.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('edit_class_field_dropdown'),
                initialValue: _fieldName,
                decoration: const InputDecoration(labelText: 'Alan'),
                items: [
                  for (final field in widget.fields)
                    DropdownMenuItem<String>(value: field, child: Text(field)),
                ],
                onChanged: (value) => setState(() => _fieldName = value),
                validator: (value) =>
                    value == null ? 'Alan seçmeniz gerekiyor.' : null,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        FilledButton(
          key: const Key('edit_class_save_button'),
          onPressed: _save,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
