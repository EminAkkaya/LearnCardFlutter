import 'package:flutter/material.dart';
import '../../../providers/reading_provider.dart';

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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: themeColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? themeColors.newWordColor
              : themeColors.defaultText.withValues(alpha: 0.2),
          width: isSelected ? 2.5 : 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        title: Text(
          themeColors.label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
            Text(
              'Yeni ',
              style: TextStyle(
                color: themeColors.newWordColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              'Öğrenilen ',
              style: TextStyle(
                color: themeColors.learningWordColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              'Öğrenildi',
              style: TextStyle(
                color: themeColors.masteredWordColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: themeColors.newWordColor)
            : null,
        onTap: () => onSelect(mode),
      ),
    );
  }
}
