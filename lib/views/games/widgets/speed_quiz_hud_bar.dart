import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';
import 'game_score_label.dart';

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
    final p = AppPalette.of(context);
    final fb = FeedbackColors.of(context);
    final onStreak = streak > 1;
    final streakColor = onStreak ? fb.warning : p.textMuted;
    final timeLow = secondsRemaining <= 3;
    final timeColor = timeLow ? fb.danger : p.textSecondary;
    const tabular = [FontFeature.tabularFigures()];

    // Wrap: dar ekran / büyük yazıda göstergeler alt satıra iner.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        GameScoreLabel(score: score),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.flame, color: streakColor, size: 18),
            const SizedBox(width: 4),
            Text(
              'Seri: x$streak',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: streakColor,
                fontFeatures: tabular,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: timeLow ? fb.dangerContainer : p.subtle,
            borderRadius: BorderRadius.circular(AppPalette.radiusPill),
            border: Border.all(color: timeLow ? fb.danger : p.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.timer, size: 16, color: timeColor),
              const SizedBox(width: 4),
              Text(
                '${secondsRemaining}s',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: timeColor,
                  fontFeatures: tabular,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
