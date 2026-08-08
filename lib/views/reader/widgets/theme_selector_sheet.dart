import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/reading_provider.dart';

class ThemeSelectorSheet extends ConsumerWidget {
  final ReaderThemeColors currentColors;

  const ThemeSelectorSheet({super.key, required this.currentColors});

  static void show(BuildContext context, ReaderThemeColors currentColors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: currentColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ThemeSelectorSheet(currentColors: currentColors),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingState = ref.watch(readingProvider);
    final currentThemeMode = readingState.themeMode;
    final fontSize = readingState.fontSize;
    final lineHeight = readingState.lineHeight;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Okuma Teması ve Görünüm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: currentColors.defaultText,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: currentColors.defaultText,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'TEMA SEÇİMİ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: currentColors.defaultText.withValues(alpha: 0.6),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            ...ReaderThemeMode.values.map((mode) {
              final themeColors = ReaderThemeColors.fromMode(mode);
              final bool isSelected = currentThemeMode == mode;
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
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
                        style: TextStyle(
                          color: themeColors.defaultText,
                          fontSize: 12,
                        ),
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
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: themeColors.newWordColor,
                        )
                      : null,
                  onTap: () {
                    ref.read(readingProvider.notifier).setThemeMode(mode);
                  },
                ),
              );
            }),
            const SizedBox(height: 12),
            Divider(
              color: currentColors.defaultText.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Yazı Boyutu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: currentColors.defaultText,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: currentColors.defaultText.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${fontSize.toInt()} pt',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: currentColors.defaultText,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'A',
                  style: TextStyle(
                    fontSize: 12,
                    color: currentColors.defaultText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: fontSize,
                    min: 14.0,
                    max: 28.0,
                    divisions: 14,
                    activeColor: currentColors.newWordColor,
                    inactiveColor: currentColors.defaultText.withValues(
                      alpha: 0.2,
                    ),
                    onChanged: (val) {
                      ref.read(readingProvider.notifier).setFontSize(val);
                    },
                  ),
                ),
                Text(
                  'A',
                  style: TextStyle(
                    fontSize: 22,
                    color: currentColors.defaultText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Satır Aralığı',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: currentColors.defaultText,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: currentColors.defaultText.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${lineHeight.toStringAsFixed(1)}x',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: currentColors.defaultText,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.format_line_spacing,
                  size: 16,
                  color: currentColors.defaultText,
                ),
                Expanded(
                  child: Slider(
                    value: lineHeight,
                    min: 1.2,
                    max: 2.4,
                    divisions: 12,
                    activeColor: currentColors.newWordColor,
                    inactiveColor: currentColors.defaultText.withValues(
                      alpha: 0.2,
                    ),
                    onChanged: (val) {
                      ref.read(readingProvider.notifier).setLineHeight(val);
                    },
                  ),
                ),
                Icon(
                  Icons.format_line_spacing,
                  size: 24,
                  color: currentColors.defaultText,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
