import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/theme_provider.dart';

/// Altı sıcak vurgu rengi arasından seçim. Seçili seçenek renk dolgusu, check
/// ikonu ve kalın etiketle belirtilir (renge tek başına güvenilmez).
class PrimaryColorPickerCard extends ConsumerWidget {
  const PrimaryColorPickerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDark = AppPalette.of(context).isDark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in ThemeNotifier.colorOptions)
              _ColorOptionChip(
                option: option,
                // Koyu temada uygulamanın kullandığı açık tonu göster.
                swatch: isDark ? AppTheme.darkAccentFor(option.color) : option.color,
                isSelected: themeState.primaryColor.toARGB32() == option.color.toARGB32(),
                onTap: () => themeNotifier.setPrimaryColor(option.color),
              ),
          ],
        ),
      ),
    );
  }
}

class _ColorOptionChip extends StatelessWidget {
  final AppColorOption option;
  final Color swatch;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOptionChip({
    required this.option,
    required this.swatch,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final radius = BorderRadius.circular(AppPalette.radiusControl);
    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected ? palette.subtle : palette.card,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: isSelected ? swatch : palette.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(color: swatch, shape: BoxShape.circle),
                  child: isSelected
                      ? Icon(LucideIcons.check, size: 13, color: AppTheme.onColorFor(swatch))
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  option.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? palette.textPrimary : palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
