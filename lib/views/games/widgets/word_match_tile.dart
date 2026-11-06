import 'package:flutter/material.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../models/games/word_match_tile_model.dart';

class WordMatchTile extends StatelessWidget {
  final WordMatchTileModel tile;
  final VoidCallback onTap;

  const WordMatchTile({super.key, required this.tile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fb = FeedbackColors.of(context);

    Color bgColor = theme.colorScheme.surface;
    Color borderColor = theme.dividerColor.withValues(alpha: 0.4);
    Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    if (tile.isMatched) {
      bgColor = fb.success.withValues(alpha: 0.15);
      borderColor = fb.success.withValues(alpha: 0.4);
      textColor = fb.success;
    } else if (tile.isError) {
      bgColor = fb.danger.withValues(alpha: 0.2);
      borderColor = fb.danger;
      textColor = fb.danger;
    } else if (tile.isSelected) {
      bgColor = theme.colorScheme.primary.withValues(alpha: 0.2);
      borderColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.primary;
    }

    final status = tile.isMatched
        ? 'eşleşti'
        : tile.isError
        ? 'yanlış eşleşme'
        : tile.isSelected
        ? 'seçili'
        : '';
    return Semantics(
      button: true,
      selected: tile.isSelected,
      enabled: !(tile.isMatched || tile.isError),
      label: '${tile.label}: ${tile.text}${status.isEmpty ? '' : ', $status'}',
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: tile.isMatched ? 0.35 : 1.0,
        child: Card(
          elevation: tile.isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: borderColor,
              width: tile.isSelected ? 2 : 1,
            ),
          ),
          color: bgColor,
          child: InkWell(
            onTap: (tile.isMatched || tile.isError) ? null : onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              // Izgara hücresi sabit oranlı; büyük yazıda içerik ölçeklenerek sığar.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tile.isMatched)
                      Icon(
                        Icons.check_circle_rounded,
                        color: fb.success,
                        size: 16,
                      )
                    else
                      Text(
                        tile.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        tile.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: tile.isEnglish ? 15 : 14,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
