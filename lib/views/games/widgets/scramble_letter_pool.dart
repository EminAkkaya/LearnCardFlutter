import 'package:flutter/material.dart';
import 'letter_tile_model.dart';

class ScrambleLetterPool extends StatelessWidget {
  final List<LetterTileModel> pool;
  final bool isCompleted;
  final ValueChanged<LetterTileModel> onTileTapped;

  static const Color indigoColor = Color(0xFF6366F1);

  const ScrambleLetterPool({
    super.key,
    required this.pool,
    required this.isCompleted,
    required this.onTileTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: pool.map((tile) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: tile.isPlaced ? 0.0 : 1.0,
          child: InkWell(
            onTap: (tile.isPlaced || isCompleted) ? null : () => onTileTapped(tile),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 50,
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: indigoColor.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                tile.char.toUpperCase(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
