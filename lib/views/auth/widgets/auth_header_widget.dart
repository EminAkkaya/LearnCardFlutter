import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';

/// Giriş ekranı başlığı: küçük opak logo kutusu, başlık ve açıklama.
class AuthHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AuthHeaderWidget({
    super.key,
    this.title = 'LearnCard',
    this.subtitle = 'Kelimelerinizi ve metinlerinizi güvenle senkronize edin',
    this.icon = LucideIcons.layers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(AppPalette.radiusCard),
          ),
          child: Icon(icon, size: 24, color: theme.colorScheme.onPrimary),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: palette.textSecondary, height: 1.5),
        ),
      ],
    );
  }
}
