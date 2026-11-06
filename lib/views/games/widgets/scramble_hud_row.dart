import 'package:flutter/material.dart';
import '../../../core/theme/feedback_colors.dart';

class ScrambleHudRow extends StatelessWidget {
  final int score;
  final int wordLength;

  const ScrambleHudRow({super.key, required this.score, required this.wordLength});

  @override
  Widget build(BuildContext context) {
    final fb = FeedbackColors.of(context);
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stars_rounded, color: fb.warning, size: 20),
            const SizedBox(width: 6),
            Text(
              'Puan: $score',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        Text(
          'Kelime Uzunluğu: $wordLength Harf',
          style: TextStyle(fontSize: 12, color: mutedColor),
        ),
      ],
    );
  }
}
