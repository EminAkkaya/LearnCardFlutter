import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/theme_provider.dart';

/// Seçili görünüm modunu ve vurgu rengini opak bir kart üzerinde gösteren önizleme.
class LivePreviewCard extends StatelessWidget {
  final ThemeState themeState;

  const LivePreviewCard({super.key, required this.themeState});

  String get _modeLabel => switch (themeState.themeMode) {
        ThemeMode.dark => 'Karanlık',
        ThemeMode.light => 'Aydınlık',
        ThemeMode.system => 'Sistem',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = AppPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: palette.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Canlı Tema Önizleme',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppPalette.radiusPill),
                ),
                child: Text(
                  _modeLabel,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Seçilen ana renk tüm uygulama genelinde buton, vurgu ve kart rozetlerinde aktif olur.',
            style: TextStyle(color: palette.textSecondary, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.check, size: 16),
                label: const Text('Buton Örneği'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppPalette.radiusPill),
                  child: LinearProgressIndicator(
                    value: 0.7,
                    minHeight: 6,
                    color: scheme.primary,
                    backgroundColor: palette.border,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
