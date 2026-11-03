import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../navigation/app_navigation.dart';
import 'app_sidebar.dart';

/// Uygulamanın ana yerleşimi: solda navigasyon, sağda içerik.
///
/// Eski [AppShell] composition root rolünü üstleniyordu. Bu sorumluluk
/// artık Riverpod provider'larına ve [sessionProvider]'a taşındı.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  String _selectedId = initialDestinationId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final collapsed = constraints.maxWidth < 1000;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSidebar(
                  destinations: appDestinations,
                  selectedId: _selectedId,
                  collapsed: collapsed,
                  onSelected: _selectDestination,
                ),
                const VerticalDivider(width: 1, color: AppColors.border),
                Expanded(
                  child: _buildContentArea(
                    contentWidth:
                        constraints.maxWidth -
                        (collapsed
                            ? AppSidebar.collapsedWidth
                            : AppSidebar.expandedWidth),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentArea({required double contentWidth}) {
    final padding = contentWidth < 720 ? AppSpacing.lg : AppSpacing.xxl;
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, AppSpacing.xl, padding, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: _buildPageStack(),
        ),
      ),
    );
  }

  Widget _buildPageStack() {
    final selectedIndex = appDestinations.indexWhere(
      (d) => d.id == _selectedId,
    );
    return IndexedStack(
      index: selectedIndex < 0 ? 0 : selectedIndex,
      children: [
        for (final destination in appDestinations)
          KeyedSubtree(
            key: ValueKey<String>('page_${destination.id}'),
            child: Builder(builder: destination.builder),
          ),
      ],
    );
  }

  void _selectDestination(String id) {
    if (_selectedId == id) return;
    setState(() => _selectedId = id);
  }
}
