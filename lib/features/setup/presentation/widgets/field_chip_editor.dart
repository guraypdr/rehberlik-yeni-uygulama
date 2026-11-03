import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Meslek lisesi alan listesini yönetir.
///
/// Kullanıcı metin kutusuna alan adı yazar, Enter/Ekle ile chip oluşturur;
/// chip'in X'ine basarak siler.
class FieldChipEditor extends StatefulWidget {
  const FieldChipEditor({
    super.key,
    required this.fields,
    required this.onChanged,
  });

  final List<String> fields;
  final ValueChanged<List<String>> onChanged;

  @override
  State<FieldChipEditor> createState() => _FieldChipEditorState();
}

class _FieldChipEditorState extends State<FieldChipEditor> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (widget.fields.contains(text)) {
      _controller.clear();
      return;
    }
    widget.onChanged([...widget.fields, text]);
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _remove(String field) {
    widget.onChanged(widget.fields.where((f) => f != field).toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chip listesi
        if (widget.fields.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final field in widget.fields)
                Chip(
                  label: Text(field),
                  backgroundColor: colorScheme.primaryContainer,
                  side: BorderSide.none,
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _remove(field),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Girdi satırı
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Alan adı (örn. Bilişim)',
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(
              onPressed: _add,
              icon: const Icon(Icons.add),
              tooltip: 'Alan Ekle',
            ),
          ],
        ),
      ],
    );
  }
}
