import 'package:flutter/material.dart';
import '../../../models/daily_activity_model.dart';
import 'stats_metric_card.dart';

class TodayActivityCard extends StatelessWidget {
  final DailyActivityModel todayActivity;
  final Function(int tabIndex)? onNavigateToTab;

  static const Color emerald = Color(0xFF10B981);

  const TodayActivityCard({
    super.key,
    required this.todayActivity,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bugünkü Aktiviteleriniz',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: emerald.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Canlı Takip',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: emerald,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          children: [
            StatsMetricCard(
              title: 'Bugün Çalışılan',
              value: '${todayActivity.cardsReviewed}',
              icon: Icons.repeat_rounded,
              color: const Color(0xFF6366F1),
              onTap: () => onNavigateToTab?.call(0),
            ),
            StatsMetricCard(
              title: 'Yeni Eklenen',
              value: '${todayActivity.cardsAdded}',
              icon: Icons.library_add_rounded,
              color: emerald,
              onTap: () => onNavigateToTab?.call(2),
            ),
            StatsMetricCard(
              title: 'Oyun Puanı',
              value: '${todayActivity.gameScore}',
              icon: Icons.stars_rounded,
              color: const Color(0xFFF59E0B),
              onTap: () => onNavigateToTab?.call(2),
            ),
            StatsMetricCard(
              title: 'Oyun Seansı',
              value: '${todayActivity.gamesPlayed}',
              icon: Icons.sports_esports_rounded,
              color: const Color(0xFFEC4899),
              onTap: () => onNavigateToTab?.call(2),
            ),
          ],
        ),
      ],
    );
  }
}
