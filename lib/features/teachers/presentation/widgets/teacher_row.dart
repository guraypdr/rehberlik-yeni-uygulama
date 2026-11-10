import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/teacher.dart';

/// Listede tek bir öğretmen satırı.
class TeacherRow extends StatefulWidget {
  const TeacherRow({super.key, required this.teacher, required this.onDelete});

  final Teacher teacher;
  final VoidCallback onDelete;

  @override
  State<TeacherRow> createState() => _TeacherRowState();
}

class _TeacherRowState extends State<TeacherRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: widget.teacher.fullName,
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
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  widget.teacher.name.isNotEmpty
                      ? widget.teacher.name.substring(0, 1).toUpperCase()
                      : '?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.teacher.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge,
                    ),
                    Text(
                      widget.teacher.branch ?? 'Branş belirtilmemiş',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    if (widget.teacher.email != null &&
                        widget.teacher.email!.isNotEmpty)
                      Text(
                        widget.teacher.email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    if (widget.teacher.phone != null &&
                        widget.teacher.phone!.isNotEmpty)
                      Text(
                        widget.teacher.phone!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                key: Key('teacher_delete_${widget.teacher.id}'),
                onPressed: widget.onDelete,
                visualDensity: VisualDensity.compact,
                tooltip: 'Öğretmeni sil',
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
