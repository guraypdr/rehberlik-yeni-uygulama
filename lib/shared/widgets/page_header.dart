import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Sayfaların ortak başlık alanı.
///
/// Tüm sayfalar aynı başlık biçimini ve aynı boşluğu kullanır; böylece menüden
/// sayfa değiştirdiğinde arayüzün üst kısmı sabit kalır. [actions] ile sağ
/// tarafa sayfa aksiyonları yerleştirilebilir.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: theme.textTheme.headlineSmall),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle!, style: theme.textTheme.bodyMedium),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: actions == null
          ? titleBlock
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: titleBlock),
                const SizedBox(width: AppSpacing.md),
                actions!,
              ],
            ),
    );
  }
}
