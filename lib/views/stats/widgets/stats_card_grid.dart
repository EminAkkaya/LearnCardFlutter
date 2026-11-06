import 'package:flutter/material.dart';
import 'stats_metric_card.dart';

class StatsCardGrid extends StatelessWidget {
  final int dueCount;
  final int learningCount;
  final int masteredCount;
  final int newCount;
  final Function(int tabIndex)? onNavigateToTab;

  static const Color emerald = Color(0xFF10B981);

  const StatsCardGrid({
    super.key,
    required this.dueCount,
    required this.learningCount,
    required this.masteredCount,
    required this.newCount,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kart Durum Özeti',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
              title: 'Bugün Tekrar',
              value: '$dueCount',
              icon: Icons.timer_rounded,
              color: Colors.amber,
              onTap: () => onNavigateToTab?.call(0),
            ),
            StatsMetricCard(
              title: 'Öğrenilen',
              value: '$learningCount',
              icon: Icons.auto_stories_rounded,
              color: Colors.blue,
              onTap: () => onNavigateToTab?.call(2),
            ),
            StatsMetricCard(
              title: 'Öğrenildi',
              value: '$masteredCount',
              icon: Icons.verified_rounded,
              color: emerald,
              onTap: () => onNavigateToTab?.call(2),
            ),
            StatsMetricCard(
              title: 'Yeni Kartlar',
              value: '$newCount',
              icon: Icons.fiber_new_rounded,
              color: Colors.purple,
              onTap: () => onNavigateToTab?.call(2),
            ),
          ],
        ),
      ],
    );
  }
}
