import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Sayfaların ortak başlık alanı.
///
/// Tüm sayfalar aynı başlık biçimini ve aynı boşluğu kullanır; böylece menüden
/// sayfa değiştirdiğinde arayüzün üst kısmı sabit kalır.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.headlineSmall),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
