import 'package:flutter/material.dart';
import '../../../models/games/word_match_tile_model.dart';

class WordMatchTile extends StatelessWidget {
  final WordMatchTileModel tile;
  final VoidCallback onTap;

  static const Color emerald = Color(0xFF10B981);

  const WordMatchTile({
    super.key,
    required this.tile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor = theme.colorScheme.surface;
    Color borderColor = theme.dividerColor.withValues(alpha: 0.4);
    Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    if (tile.isMatched) {
      bgColor = emerald.withValues(alpha: 0.15);
      borderColor = emerald.withValues(alpha: 0.4);
      textColor = emerald;
    } else if (tile.isError) {
      bgColor = Colors.redAccent.withValues(alpha: 0.2);
      borderColor = Colors.redAccent;
      textColor = Colors.redAccent;
    } else if (tile.isSelected) {
      bgColor = theme.colorScheme.primary.withValues(alpha: 0.2);
      borderColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.primary;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: tile.isMatched ? 0.35 : 1.0,
      child: Card(
        elevation: tile.isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor, width: tile.isSelected ? 2 : 1),
        ),
        color: bgColor,
        child: InkWell(
          onTap: (tile.isMatched || tile.isError) ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (tile.isMatched)
                  const Icon(Icons.check_circle_rounded, color: emerald, size: 16)
                else
                  Text(
                    tile.isEnglish ? 'EN' : 'TR',
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
    );
  }
}
