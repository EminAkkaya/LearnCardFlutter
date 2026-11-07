import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import 'game_score_label.dart';

class ScrambleHudRow extends StatelessWidget {
  final int score;
  final int wordLength;

  const ScrambleHudRow({super.key, required this.score, required this.wordLength});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        GameScoreLabel(score: score),
        Text(
          'Kelime Uzunluğu: $wordLength Harf',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: p.textSecondary),
        ),
      ],
    );
  }
}
