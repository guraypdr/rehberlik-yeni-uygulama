import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../navigation/app_navigation.dart';
import 'app_top_bar.dart';

/// Uygulamanın ana yerleşimi.
///
/// Üstte [AppTopBar] (yatay navigasyon), altında seçili sayfa içeriği.
/// Sayfalar [IndexedStack] içinde tutulur — değiştirince state kaybolmaz.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  String _selectedId = initialDestinationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Üst navigasyon çubuğu ──────────────────────────────────
            AppTopBar(
              destinations: appDestinations,
              selectedId: _selectedId,
              onSelected: _select,
            ),

            // ── Sayfa içeriği ──────────────────────────────────────────
            Expanded(child: _ContentArea(selectedId: _selectedId)),
          ],
        ),
      ),
    );
  }

  void _select(String id) {
    if (_selectedId == id) return;
    setState(() => _selectedId = id);
  }
}

class _ContentArea extends StatelessWidget {
  const _ContentArea({required this.selectedId});

  final String selectedId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hPad = constraints.maxWidth < 720
            ? AppSpacing.lg
            : AppSpacing.xxl;

        final selectedIndex = appDestinations.indexWhere(
          (d) => d.id == selectedId,
        );

        return Padding(
          padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xl, hPad, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: IndexedStack(
                index: selectedIndex < 0 ? 0 : selectedIndex,
                children: [
                  for (final dest in appDestinations)
                    KeyedSubtree(
                      key: ValueKey<String>('page_${dest.id}'),
                      child: Builder(builder: dest.builder),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
