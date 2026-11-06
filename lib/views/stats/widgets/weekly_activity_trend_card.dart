import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/daily_activity_model.dart';

class WeeklyActivityTrendCard extends StatelessWidget {
  final List<DailyActivityModel> activities;

  static const Color emerald = Color(0xFF10B981);

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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son 7 Günlük İlerleme',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Haftalık: $totalWeekReviewed Kelime / $totalWeekScore Puan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: activities.map((act) {
                final total = act.cardsReviewed + act.cardsAdded;
                final double factor = (total / maxActivity).clamp(0.08, 1.0);
                final bool isToday = act.date == DateTime.now().toIso8601String().split('T')[0];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isToday ? emerald : theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 22,
                      height: 90 * factor,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isToday
                              ? [emerald, const Color(0xFF34D399)]
                              : total > 0
                                  ? [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withValues(alpha: 0.7),
                                    ]
                                  : [
                                      theme.dividerColor.withValues(alpha: 0.2),
                                      theme.dividerColor.withValues(alpha: 0.1),
                                    ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDayLabel(act.date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: isToday
                            ? emerald
                            : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
