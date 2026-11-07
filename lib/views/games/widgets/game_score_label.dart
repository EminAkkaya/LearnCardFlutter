import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';

/// HUD'lardaki "Puan: N" göstergesi (sakin ikon + tabular rakam).
class GameScoreLabel extends StatelessWidget {
  final int score;

  const GameScoreLabel({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.star, color: p.textSecondary, size: 18),
        const SizedBox(width: 6),
        Text(
          'Puan: $score',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: p.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
