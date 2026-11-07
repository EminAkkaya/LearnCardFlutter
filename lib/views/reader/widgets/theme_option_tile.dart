import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../models/reader_theme.dart';
import 'reader_word_style.dart';

/// Tema seçeneği: temanın kendi zemininde, metindeki gerçek kelime görünümüyle
/// (renk + alt çizgi deseni) önizleme. Seçili tema kalın kenarlık + onay ikonu.
class ThemeOptionTile extends StatelessWidget {
  final ReaderThemeMode mode;
  final bool isSelected;
  final ValueChanged<ReaderThemeMode> onSelect;

  const ThemeOptionTile({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = ReaderThemeColors.fromMode(mode);

    TextStyle sample(String status) {
      final look = ReaderWordStyle.forStatus(status, themeColors);
      return TextStyle(
        color: look.color,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        decoration: TextDecoration.underline,
        decorationColor: look.underline,
        decorationStyle: look.pattern,
        decorationThickness: look.thickness,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: themeColors.background,
        borderRadius: BorderRadius.circular(AppPalette.radiusCard),
        border: Border.all(
          color: isSelected
              ? themeColors.defaultText.withValues(alpha: 0.85)
              : themeColors.defaultText.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppPalette.radiusCard),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        title: Text(
          themeColors.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: themeColors.defaultText,
            fontSize: 14,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              'Örnek: ',
              style: TextStyle(color: themeColors.defaultText, fontSize: 12),
            ),
            Text('Yeni ', style: sample('new')),
            Text('Öğrenilen ', style: sample('learning')),
            Text('Öğrenildi', style: sample('mastered')),
          ],
        ),
        trailing: isSelected
            ? Icon(LucideIcons.circleCheck, size: 20, color: themeColors.defaultText)
            : null,
        onTap: () => onSelect(mode),
      ),
    );
  }
}
