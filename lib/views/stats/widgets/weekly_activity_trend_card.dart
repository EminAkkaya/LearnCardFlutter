import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import '../../../models/daily_activity_model.dart';

/// Son 7 günün sade dikey çubukları: düz renk, eksen/ızgara yok, bugün vurgulu.
class WeeklyActivityTrendCard extends StatelessWidget {
  final List<DailyActivityModel> activities;

  const WeeklyActivityTrendCard({super.key, required this.activities});

  String _formatDayLabel(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
      return days[date.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    const tabular = [FontFeature.tabularFigures()];
    final maxActivity = activities.fold<int>(
      10,
      (prev, a) => max(prev, a.cardsReviewed + a.cardsAdded),
    );

    final totalWeekReviewed = activities.fold<int>(
      0,
      (prev, a) => prev + a.cardsReviewed,
    );
    final totalWeekScore = activities.fold<int>(
      0,
      (prev, a) => prev + a.gameScore,
    );
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son 7 Günlük İlerleme',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Haftalık: $totalWeekReviewed Kelime / $totalWeekScore Puan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: palette.textSecondary,
                fontFeatures: tabular,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: activities.map((act) {
                final total = act.cardsReviewed + act.cardsAdded;
                final double factor = (total / maxActivity).clamp(0.08, 1.0);
                final bool isToday = act.date == todayStr;
                final Color barColor = isToday
                    ? theme.colorScheme.primary
                    : total > 0
                        ? palette.accentGraphic.withValues(alpha: 0.45)
                        : palette.border;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday ? palette.textPrimary : palette.textMuted,
                        fontFeatures: tabular,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 20,
                      height: 90 * factor,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDayLabel(act.date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday ? palette.textPrimary : palette.textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
