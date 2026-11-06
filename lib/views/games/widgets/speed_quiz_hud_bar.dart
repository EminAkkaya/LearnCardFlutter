import 'package:flutter/material.dart';
import '../../../core/theme/feedback_colors.dart';

class SpeedQuizHudBar extends StatelessWidget {
  final int score;
  final int streak;
  final int secondsRemaining;

  const SpeedQuizHudBar({
    super.key,
    required this.score,
    required this.streak,
    required this.secondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final fb = FeedbackColors.of(context);
    // Wrap: dar ekran / büyük yazıda göstergeler alt satıra iner.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stars_rounded, color: fb.warning, size: 22),
            const SizedBox(width: 6),
            Text(
              'Puan: $score',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: streak > 1 ? fb.warning : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 4),
            Text(
              'Seri: x$streak',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: streak > 1 ? fb.warning : Colors.grey,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (secondsRemaining <= 3 ? fb.danger : fb.warning).withValues(
              alpha: 0.15,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: secondsRemaining <= 3 ? fb.danger : fb.warning,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: secondsRemaining <= 3 ? fb.danger : fb.warning,
              ),
              const SizedBox(width: 4),
              Text(
                '${secondsRemaining}s',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: secondsRemaining <= 3 ? fb.danger : fb.warning,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
