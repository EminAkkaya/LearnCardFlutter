import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../models/games/word_match_tile_model.dart';

class WordMatchTile extends StatelessWidget {
  final WordMatchTileModel tile;
  final VoidCallback onTap;

  const WordMatchTile({super.key, required this.tile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = AppPalette.of(context);
    final fb = FeedbackColors.of(context);

    Color bgColor = p.card;
    Color borderColor = p.controlBorder;
    Color textColor = p.textPrimary;
    IconData? statusIcon;
    String? statusText;

    if (tile.isMatched) {
      bgColor = fb.successContainer;
      borderColor = fb.success;
      textColor = fb.success;
      statusIcon = LucideIcons.check;
      statusText = 'Eşleşti';
    } else if (tile.isError) {
      bgColor = fb.dangerContainer;
      borderColor = fb.danger;
      textColor = fb.danger;
      statusIcon = LucideIcons.x;
      statusText = 'Yanlış';
    } else if (tile.isSelected) {
      bgColor = scheme.primaryContainer;
      borderColor = scheme.primary;
      textColor = p.textPrimary;
    }

    final status = tile.isMatched
        ? 'eşleşti'
        : tile.isError
        ? 'yanlış eşleşme'
        : tile.isSelected
        ? 'seçili'
        : '';
    final radius = BorderRadius.circular(AppPalette.radiusControl);
    final emphasized = tile.isSelected || tile.isError || tile.isMatched;

    return Semantics(
      button: true,
      selected: tile.isSelected,
      enabled: !(tile.isMatched || tile.isError),
      label: '${tile.label}: ${tile.text}${status.isEmpty ? '' : ', $status'}',
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: AppPalette.motionSlow,
        opacity: tile.isMatched ? 0.45 : 1.0,
        child: Material(
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: borderColor, width: emphasized ? 1.5 : 1),
          ),
          child: InkWell(
            onTap: (tile.isMatched || tile.isError) ? null : onTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              // Izgara hücresi sabit oranlı; büyük yazıda içerik ölçeklenerek sığar.
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (statusIcon != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, color: textColor, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              statusText!,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textColor),
                            ),
                          ],
                        )
                      else
                        Text(
                          tile.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                            color: p.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        tile.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: tile.isEnglish ? 15 : 14,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
