import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../navigation/app_navigation.dart';
import 'sidebar_item.dart';

/// Sol navigasyon alanı.
///
/// Menü içeriğini [AppNavigation] listesinden alır; yeni modül eklemek için
/// bu dosyada değişiklik gerekmez.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.destinations,
    required this.selectedId,
    required this.onSelected,
    required this.collapsed,
  });

  final List<AppDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onSelected;

  /// Dar pencerede menü yalnızca ikon olarak gösterilir.
  final bool collapsed;

  static const double expandedWidth = 236;
  static const double collapsedWidth = 68;

  double get width => collapsed ? collapsedWidth : expandedWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('sidebar'),
      width: width,
      color: AppColors.sidebarBackground,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Brand(collapsed: collapsed),
            SizedBox(height: collapsed ? AppSpacing.xl : AppSpacing.xxl),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final destination in destinations)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: SidebarItem(
                        key: Key('sidebar_item_${destination.id}'),
                        destination: destination,
                        selected: destination.id == selectedId,
                        collapsed: collapsed,
                        onSelected: onSelected,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mark = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Icon(
        Icons.psychology_alt_outlined,
        color: AppColors.onPrimary,
        size: 21,
      ),
    );

    if (collapsed) {
      return Center(child: mark);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          mark,
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Rehberlik',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
