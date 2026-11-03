import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../../app/app_router.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';

/// İlk açılış / dosya seçim ekranı.
///
/// - Son açılan dosyalar listesi
/// - Yeni veritabanı oluştur
/// - Mevcut dosya aç
class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recentFiles = ref.watch(lastFileStoreProvider).getRecentFiles();
    final sessionAsync = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo / Başlık
                Icon(
                  Icons.school_outlined,
                  size: 56,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Rehberlik',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Okul rehberlik iş takip uygulaması',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Hata mesajı
                if (sessionAsync.hasError)
                  _ErrorBanner(message: sessionAsync.error.toString()),

                // Yükleniyor
                if (sessionAsync.isLoading)
                  const Center(child: CircularProgressIndicator()),

                // Aksiyonlar
                if (!sessionAsync.isLoading) ...[
                  FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.setup),
                    icon: const Icon(Icons.add),
                    label: const Text('Yeni Okul Veritabanı Oluştur'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => _openExistingFile(context, ref),
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('Mevcut Dosyayı Aç'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),
                ],

                // Son açılan dosyalar
                if (recentFiles.isNotEmpty && !sessionAsync.isLoading) ...[
                  const SizedBox(height: AppSpacing.xxxl),
                  Text(
                    'Son Açılan Dosyalar',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _RecentFilesList(files: recentFiles),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openExistingFile(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Okul veritabanı dosyasını seç',
      type: FileType.custom,
      allowedExtensions: ['rdb'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    if (!context.mounted) return;
    await ref.read(sessionProvider.notifier).openFile(path);
  }
}

class _RecentFilesList extends ConsumerWidget {
  const _RecentFilesList({required this.files});

  final List<String> files;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < files.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
              ),
            _RecentFileItem(path: files[i]),
          ],
        ],
      ),
    );
  }
}

class _RecentFileItem extends ConsumerWidget {
  const _RecentFileItem({required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final exists = File(path).existsSync();
    final name = p.basenameWithoutExtension(path);
    final dir = p.dirname(path);

    return ListTile(
      dense: true,
      leading: Icon(
        Icons.storage_outlined,
        color: exists
            ? Theme.of(context).colorScheme.primary
            : AppColors.textMuted,
        size: 20,
      ),
      title: Text(
        name,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: exists ? AppColors.textPrimary : AppColors.textMuted,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        dir,
        style: theme.textTheme.bodySmall,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: exists
          ? null
          : Tooltip(
              message: 'Dosya bulunamadı',
              child: const Icon(
                Icons.warning_amber_outlined,
                color: AppColors.warning,
                size: 16,
              ),
            ),
      onTap: exists
          ? () => ref.read(sessionProvider.notifier).openFile(path)
          : null,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
