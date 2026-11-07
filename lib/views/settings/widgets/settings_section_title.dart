import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';

/// Ayarlar bölüm başlığı: solda küçük Lucide ikon, 16px yarı kalın başlık.
class SettingsSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const SettingsSectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: palette.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
        ),
      ],
    );
  }
}
