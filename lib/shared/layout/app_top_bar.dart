import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../app/app_router.dart';
import '../../core/providers/session_provider.dart';
import '../../core/theme/app_theme.dart';
import '../navigation/app_navigation.dart';

/// Referans görüntüsündeki üst yatay navigasyon çubuğu.
///
/// Yapı:
///   [Logo + Okul Adı]  [Nav linkleri...]  [Dosya | Ayarlar]
///
/// Dar ekranlarda nav linkleri yerine hamburger menü açılır.
class AppTopBar extends ConsumerStatefulWidget {
  const AppTopBar({
    super.key,
    required this.destinations,
    required this.selectedId,
    required this.onSelected,
  });

  final List<AppDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onSelected;

  /// Çubuğun yüksekliği — içerik alanı padding hesaplamak için dışarıdan okunabilir.
  static const double height = 58.0;

  @override
  ConsumerState<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends ConsumerState<AppTopBar> {
  @override
  Widget build(BuildContext context) {
    final session   = ref.watch(sessionProvider).valueOrNull;
    final profile   = session?.schoolProfile;
    final filePath  = session?.filePath;
    final fileName  = filePath != null ? p.basenameWithoutExtension(filePath) : null;

    return Container(
      height: AppTopBar.height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          bottom: BorderSide(color: AppColors.border),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 800px altında nav linkleri sığmaz → hamburger göster
            final compact = constraints.maxWidth < 800;

            return Row(
              children: [
                // ── Logo + Okul adı ─────────────────────────────────────
                _Brand(schoolName: profile?.name ?? 'Rehberlik'),

                // ── Nav linkleri (geniş ekran) ───────────────────────────
                if (!compact) ...[
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    child: _NavLinks(
                      destinations: widget.destinations,
                      selectedId: widget.selectedId,
                      onSelected: widget.onSelected,
                    ),
                  ),
                ] else
                  const Spacer(),

                // ── Sağ aksiyonlar ───────────────────────────────────────
                _RightActions(
                  fileName: fileName,
                  compact: compact,
                  destinations: widget.destinations,
                  selectedId: widget.selectedId,
                  onSelected: widget.onSelected,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Logo + Okul adı
// ────────────────────────────────────────────────────────────────────────────

class _Brand extends StatelessWidget {
  const _Brand({required this.schoolName});
  final String schoolName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t  = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // İkon kutu
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
          ),
          child: Icon(Icons.psychology_alt_outlined,
              color: cs.onPrimary, size: 18),
        ),
        const SizedBox(width: AppSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            schoolName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.titleMedium,
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Navigasyon linkleri (yatay)
// ────────────────────────────────────────────────────────────────────────────

class _NavLinks extends StatelessWidget {
  const _NavLinks({
    required this.destinations,
    required this.selectedId,
    required this.onSelected,
  });

  final List<AppDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final dest in destinations)
          _NavItem(
            destination: dest,
            selected: dest.id == selectedId,
            onTap: () => onSelected(dest.id),
          ),
      ],
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final cs       = Theme.of(context).colorScheme;
    final t        = Theme.of(context).textTheme;
    final selected = widget.selected;

    return Semantics(
      button: true,
      selected: selected,
      label: widget.destination.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hov = true),
        onExit:  (_) => setState(() => _hov = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 9),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: selected
                  ? cs.primary
                  : _hov
                      ? cs.primaryContainer
                      : Colors.transparent,
              borderRadius:
                  const BorderRadius.all(Radius.circular(AppRadius.pill)),
            ),
            child: Text(
              widget.destination.label,
              style: t.labelLarge?.copyWith(
                color: selected
                    ? cs.onPrimary
                    : _hov
                        ? cs.primary
                        : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Sağ aksiyonlar: dosya + hamburger (dar ekran)
// ────────────────────────────────────────────────────────────────────────────

class _RightActions extends ConsumerWidget {
  const _RightActions({
    required this.fileName,
    required this.compact,
    required this.destinations,
    required this.selectedId,
    required this.onSelected,
  });

  final String? fileName;
  final bool compact;
  final List<AppDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dosya adı — sadece geniş ekranda
        if (fileName != null && !compact) ...[
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius:
                  const BorderRadius.all(Radius.circular(AppRadius.sm)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage_outlined,
                    size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    fileName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],

        // Dosya aç ikonu
        _BarIconBtn(
          icon: Icons.folder_open_outlined,
          tooltip: 'Farklı Dosya Aç',
          onTap: () => _openFile(context, ref),
        ),

        // Yeni veritabanı ikonu
        _BarIconBtn(
          icon: Icons.add_circle_outline,
          tooltip: 'Yeni Veritabanı Oluştur',
          onTap: () => _newFile(context, ref),
        ),

        const SizedBox(width: AppSpacing.xs),
        const _VerticalDivider(),
        const SizedBox(width: AppSpacing.xs),

        // Hamburger (dar ekran)
        if (compact)
          _HamburgerBtn(
            destinations: destinations,
            selectedId: selectedId,
            onSelected: onSelected,
          ),
      ],
    );
  }

  Future<void> _openFile(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Okul veritabanı dosyasını seç',
      type: FileType.custom,
      allowedExtensions: ['rdb'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    await ref.read(sessionProvider.notifier).openFile(path);
  }

  void _newFile(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Veritabanı'),
        content: const Text(
          'Yeni bir okul veritabanı oluşturmak için kurulum sihirbazına '
          'gidilecek. Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Evet, devam et'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;
      await ref.read(sessionProvider.notifier).closeFile();
      if (context.mounted) context.go(AppRoutes.setup);
    });
  }
}

class _BarIconBtn extends StatefulWidget {
  const _BarIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_BarIconBtn> createState() => _BarIconBtnState();
}

class _BarIconBtnState extends State<_BarIconBtn> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hov = true),
        onExit:  (_) => setState(() => _hov = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 36,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _hov ? AppColors.hover : Colors.transparent,
              borderRadius:
                  const BorderRadius.all(Radius.circular(AppRadius.sm)),
            ),
            child: Icon(widget.icon,
                size: 19,
                color: _hov
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22,
      color: AppColors.border,
    );
  }
}

/// Dar ekran için hamburger → overlay menü.
class _HamburgerBtn extends StatelessWidget {
  const _HamburgerBtn({
    required this.destinations,
    required this.selectedId,
    required this.onSelected,
  });

  final List<AppDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return _BarIconBtn(
      icon: Icons.menu_rounded,
      tooltip: 'Menü',
      onTap: () => _showMenu(context),
    );
  }

  void _showMenu(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t  = Theme.of(context).textTheme;

    showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius:
                    const BorderRadius.all(Radius.circular(AppRadius.pill)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final dest in destinations)
              ListTile(
                leading: Icon(
                  dest.icon,
                  color: dest.id == selectedId ? cs.primary : AppColors.textSecondary,
                ),
                title: Text(
                  dest.label,
                  style: t.labelLarge?.copyWith(
                    color: dest.id == selectedId
                        ? cs.primary
                        : AppColors.textPrimary,
                  ),
                ),
                selected: dest.id == selectedId,
                selectedTileColor: cs.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onSelected(dest.id);
                },
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
