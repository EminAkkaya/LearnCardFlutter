import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import '../../../models/games/letter_tile_model.dart';

class ScrambleLetterPool extends StatelessWidget {
  final List<LetterTileModel> pool;
  final bool isCompleted;
  final ValueChanged<LetterTileModel> onTileTapped;

  const ScrambleLetterPool({
    super.key,
    required this.pool,
    required this.isCompleted,
    required this.onTileTapped,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final radius = BorderRadius.circular(AppPalette.radiusControl);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: pool.map((tile) {
        return Semantics(
          button: true,
          enabled: !(tile.isPlaced || isCompleted),
          label: 'Harf ${tile.char.toUpperCase()}',
          excludeSemantics: true,
          child: AnimatedOpacity(
            duration: AppPalette.motionBase,
            opacity: tile.isPlaced ? 0.0 : 1.0,
            child: Material(
              color: p.card,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(color: p.controlBorder),
              ),
              child: InkWell(
                onTap: (tile.isPlaced || isCompleted) ? null : () => onTileTapped(tile),
                borderRadius: radius,
                child: SizedBox(
                  width: 50,
                  height: 52,
                  child: Center(
                    child: Text(
                      tile.char.toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: p.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
