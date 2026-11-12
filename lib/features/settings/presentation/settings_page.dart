import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/page_header.dart';
import 'widgets/theme_color_picker.dart';

/// Ayarlar sayfası.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).valueOrNull;
    final profile = session?.schoolProfile;
    final filePath = session?.filePath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(title: 'Ayarlar'),
        Expanded(
          child: ListView(
            children: [
              // Okul bilgileri (salt okunur)
              if (profile != null) ...[
                _SectionTitle('Okul Bilgileri'),
                _InfoCard(
                  children: [
                    _InfoRow('Okul Adı', profile.name),
                    _InfoRow('Okul Türü', profile.schoolType.label),
                    if (profile.schoolType.name == 'lise')
                      _InfoRow(
                        'Hazırlık Sınıfı',
                        profile.hasPrep ? 'Var' : 'Yok',
                      ),
                    if (profile.fields.isNotEmpty)
                      _InfoRow('Alanlar', profile.fields.join(', ')),
                    _InfoRow('Oluşturulma', _formatDate(profile.createdAt)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Dosya bilgisi
              if (filePath != null) ...[
                _SectionTitle('Veritabanı Dosyası'),
                _InfoCard(children: [_InfoRow('Konum', filePath)]),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Tema rengi
              _SectionTitle('Görünüm'),
              const SizedBox(height: AppSpacing.sm),
              const ThemeColorPicker(),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
