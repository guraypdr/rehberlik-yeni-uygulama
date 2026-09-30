import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../navigation/app_navigation.dart';

/// Sol menüdeki tek bir modül bağlantısı.
class SidebarItem extends StatefulWidget {
  const SidebarItem({
    super.key,
    required this.destination,
    required this.selected,
    required this.collapsed,
    required this.onSelected,
  });

  final AppDestination destination;
  final bool selected;
  final bool collapsed;
  final ValueChanged<String> onSelected;

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = widget.selected;
    final backgroundColor = selected
        ? AppColors.primarySoft
        : _hovered
        ? AppColors.hover
        : AppColors.transparent;
    final foregroundColor = selected
        ? AppColors.primaryHover
        : AppColors.textSecondary;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      height: 44,
      padding: EdgeInsets.symmetric(
        horizontal: widget.collapsed ? 0 : AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: widget.collapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Icon(widget.destination.icon, size: 20, color: foregroundColor),
          if (!widget.collapsed) ...[
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                widget.destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: widget.destination.label,
      child: _wrapWithTooltip(
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: Material(
            color: AppColors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => widget.onSelected(widget.destination.id),
              hoverColor: AppColors.transparent,
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  /// Menü daraldığında etiket görünmediği için adı ipucu olarak gösterilir.
  Widget _wrapWithTooltip(Widget child) {
    if (!widget.collapsed) {
      return child;
    }
    return Tooltip(message: widget.destination.label, child: child);
  }
}
