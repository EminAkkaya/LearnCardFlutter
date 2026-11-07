import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';

/// Görünüm modu satırı: sade ikon kutusu, başlık, açıklama ve seçim işareti.
class ThemeModeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeModeTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    return ListTile(
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: scheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppPalette.radiusControl)),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: palette.subtle,
          borderRadius: BorderRadius.circular(AppPalette.radiusControl),
          border: Border.all(color: palette.border),
        ),
        child: Icon(icon, size: 18, color: isSelected ? scheme.primary : palette.textSecondary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: palette.textPrimary,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
      trailing: isSelected
          ? Icon(LucideIcons.circleCheck, size: 20, color: scheme.primary)
          : Icon(LucideIcons.circle, size: 20, color: palette.controlBorder),
    );
  }
}
