import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../models/user_stats_model.dart';

/// Seri ve günlük hedef özeti: opak kart, ikon + metin, sade ilerleme çubuğu.
class StreakHeaderCard extends StatelessWidget {
  final UserStatsModel userStats;

  const StreakHeaderCard({super.key, required this.userStats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final fb = FeedbackColors.of(context);
    final streak = userStats.currentStreak;
    final today = userStats.todayActivity;
    final goalProgress = userStats.todayGoalProgress;
    final isGoalDone = today.cardsReviewed >= userStats.dailyGoal;
    const tabular = [FontFeature.tabularFigures()];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: palette.subtle,
                    borderRadius: BorderRadius.circular(AppPalette.radiusControl),
                    border: Border.all(color: palette.border),
                  ),
                  child: Icon(
                    LucideIcons.flame,
                    size: 20,
                    color: streak > 0 ? fb.highlight : palette.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        streak > 0 ? '$streak Günlük Seri!' : 'Seriyi Başlat!',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                          fontFeatures: tabular,
                        ),
                      ),
                      Text(
                        'En uzun seri: ${userStats.longestStreak} gün',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 13,
                          fontFeatures: tabular,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _GoalBadge(isDone: isGoalDone, dailyGoal: userStats.dailyGoal),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Bugünkü Hedef: ${today.cardsReviewed} / ${userStats.dailyGoal} Kelime',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      fontFeatures: tabular,
                    ),
                  ),
                ),
                Text(
                  '%${(goalProgress * 100).toInt()}',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    fontFeatures: tabular,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppPalette.radiusPill),
              child: LinearProgressIndicator(
                value: goalProgress,
                minHeight: 6,
                backgroundColor: palette.border,
                color: isGoalDone ? fb.success : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Günlük hedef rozeti: renk + ikon + metin üçlüsü.
class _GoalBadge extends StatelessWidget {
  final bool isDone;
  final int dailyGoal;

  const _GoalBadge({required this.isDone, required this.dailyGoal});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final fb = FeedbackColors.of(context);
    final fg = isDone ? fb.success : palette.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? fb.successContainer : palette.subtle,
        borderRadius: BorderRadius.circular(AppPalette.radiusPill),
        border: isDone ? null : Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isDone ? LucideIcons.circleCheck : LucideIcons.target, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            isDone ? 'Hedef Tamam!' : 'Hedef: $dailyGoal',
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
