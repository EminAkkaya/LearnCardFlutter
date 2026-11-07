import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../models/reader_theme.dart';
import '../../../providers/reader_settings_provider.dart';
import 'theme_option_tile.dart';
import 'theme_slider_control.dart';

class ThemeSelectorSheet extends ConsumerWidget {
  final ReaderThemeColors currentColors;

  const ThemeSelectorSheet({super.key, required this.currentColors});

  static void show(BuildContext context, ReaderThemeColors currentColors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: currentColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppPalette.radiusCard)),
      ),
      builder: (_) => ThemeSelectorSheet(currentColors: currentColors),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(readerSettingsProvider);
    final notifier = ref.read(readerSettingsProvider.notifier);

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
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: currentColors.defaultText,
                  ),
                ),
                IconButton(
                  tooltip: 'Kapat',
                  icon: Icon(LucideIcons.x, size: 20, color: currentColors.defaultText),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'TEMA SEÇİMİ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: currentColors.defaultText.withValues(alpha: 0.75),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            ...ReaderThemeMode.values.map((mode) {
              return ThemeOptionTile(
                mode: mode,
                isSelected: settings.themeMode == mode,
                onSelect: notifier.setThemeMode,
              );
            }),
            const SizedBox(height: 12),
            Divider(color: currentColors.defaultText.withValues(alpha: 0.12)),
            const SizedBox(height: 8),
            ThemeSliderControl(
              title: 'Yazı Boyutu',
              badgeText: '${settings.fontSize.toInt()} pt',
              value: settings.fontSize,
              min: 14.0,
              max: 28.0,
              divisions: 14,
              activeColor: currentColors.defaultText,
              textColor: currentColors.defaultText,
              startIcon: Text('A', style: TextStyle(fontSize: 12, color: currentColors.defaultText, fontWeight: FontWeight.w600)),
              endIcon: Text('A', style: TextStyle(fontSize: 20, color: currentColors.defaultText, fontWeight: FontWeight.w600)),
              onChanged: notifier.setFontSize,
            ),
            const SizedBox(height: 12),
            ThemeSliderControl(
              title: 'Satır Aralığı',
              badgeText: '${settings.lineHeight.toStringAsFixed(1)}x',
              value: settings.lineHeight,
              min: 1.2,
              max: 2.4,
              divisions: 12,
              activeColor: currentColors.defaultText,
              textColor: currentColors.defaultText,
              startIcon: Icon(LucideIcons.lineHeight, size: 16, color: currentColors.defaultText),
              endIcon: Icon(LucideIcons.lineHeight, size: 22, color: currentColors.defaultText),
              onChanged: notifier.setLineHeight,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
