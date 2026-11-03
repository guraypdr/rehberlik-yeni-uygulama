import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/todo_item.dart';

/// Listede tek bir görev satırı: tamamlama kutusu, başlık ve silme düğmesi.
class TodoRow extends StatefulWidget {
  const TodoRow({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  final TodoItem todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  State<TodoRow> createState() => _TodoRowState();
}

class _TodoRowState extends State<TodoRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = widget.todo.isCompleted;
    final titleColor = completed ? AppColors.textMuted : AppColors.textPrimary;

    return Semantics(
      label: widget.todo.title,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Container(
          color: _hovered ? AppColors.hover : AppColors.transparent,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              _Checkbox(
                key: Key('todo_checkbox_${widget.todo.id}'),
                value: completed,
                onChanged: (_) => widget.onToggle(),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  widget.todo.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: titleColor,
                    decoration: completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                key: Key('todo_delete_${widget.todo.id}'),
                onPressed: widget.onDelete,
                visualDensity: VisualDensity.compact,
                tooltip: 'Görevi sil',
                icon: const Icon(Icons.delete_outline_rounded, size: 19),
                color: _hovered ? AppColors.danger : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Semantics(
      checked: value,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                color: value ? primary : AppColors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? primary : AppColors.borderStrong,
                  width: 1.5,
                ),
              ),
              child: value
                  ? Icon(Icons.check_rounded, size: 14, color: onPrimary)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
