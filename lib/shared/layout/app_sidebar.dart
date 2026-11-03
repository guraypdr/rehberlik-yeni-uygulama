import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../app/app_router.dart';
import '../../core/providers/session_provider.dart';
import '../../core/theme/app_theme.dart';
import '../navigation/app_navigation.dart';
import 'sidebar_item.dart';

/// Sol navigasyon alanı.
class AppSidebar extends ConsumerWidget {
  const AppSidebar({
    super.key,
    required this.destinations,
    required this.selectedId,
    required this.onSelected,
    required this.collapsed,
    this.schoolName = 'Rehberlik',
  });

  final List<AppDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final String schoolName;
  final bool collapsed;

  static const double expandedWidth = 236;
  static const double collapsedWidth = 68;

  double get width => collapsed ? collapsedWidth : expandedWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).valueOrNull;
    final filePath = session?.filePath;

    return Container(
      key: const Key('sidebar'),
      width: width,
      color: AppColors.sidebarBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Marka / okul adı
            _Brand(collapsed: collapsed, schoolName: schoolName),
            SizedBox(height: collapsed ? AppSpacing.xl : AppSpacing.xxl),

            // Navigasyon öğeleri
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

            // Dosya bölümü (alt)
            const Divider(height: AppSpacing.xl),
            _FileSection(collapsed: collapsed, filePath: filePath),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Marka
// ---------------------------------------------------------------------------

class _Brand extends StatelessWidget {
  const _Brand({required this.collapsed, required this.schoolName});

  final bool collapsed;
  final String schoolName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mark = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        Icons.psychology_alt_outlined,
        color: colorScheme.onPrimary,
        size: 21,
      ),
    );

    if (collapsed) return Center(child: mark);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          mark,
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              schoolName,
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

// ---------------------------------------------------------------------------
// Dosya bölümü
// ---------------------------------------------------------------------------

/// Sidebar altında: aktif dosya adı + aç/yeni butonları.
class _FileSection extends ConsumerWidget {
  const _FileSection({required this.collapsed, required this.filePath});

  final bool collapsed;
  final String? filePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (collapsed) {
      // Daraltılmış modda yalnızca ikon butonları.
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconBtn(
            context,
            icon: Icons.folder_open_outlined,
            tooltip: 'Farklı Dosya Aç',
            onTap: () => _openFile(context, ref),
          ),
          const SizedBox(height: AppSpacing.xs),
          _iconBtn(
            context,
            icon: Icons.add_circle_outline,
            tooltip: 'Yeni Veritabanı Oluştur',
            onTap: () => _newFile(context, ref),
          ),
        ],
      );
    }

    // Genişletilmiş mod.
    final fileName = filePath != null
        ? p.basenameWithoutExtension(filePath!)
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Aktif dosya göstergesi
        if (fileName != null) ...[
          Row(
            children: [
              const Icon(
                Icons.storage_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Butonlar
        _textBtn(
          context,
          icon: Icons.folder_open_outlined,
          label: 'Farklı Dosya Aç',
          onTap: () => _openFile(context, ref),
        ),
        const SizedBox(height: AppSpacing.xs),
        _textBtn(
          context,
          icon: Icons.add_circle_outline,
          label: 'Yeni Veritabanı',
          onTap: () => _newFile(context, ref),
        ),
      ],
    );
  }

  // ── Aksiyon ──────────────────────────────────────────────────────────────

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
    // Kurulum sihirbazına git — mevcut oturumu kapatmadan önce soralım.
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

  // ── Yardımcı widget'lar ──────────────────────────────────────────────────

  Widget _iconBtn(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          height: 36,
          child: Center(
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _textBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs + 2,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
