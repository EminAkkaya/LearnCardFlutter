import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/feedback_colors.dart';
import 'stats_metric_card.dart';

class StatsCardGrid extends StatelessWidget {
  final int dueCount;
  final int learningCount;
  final int masteredCount;
  final int newCount;
  final Function(int tabIndex)? onNavigateToTab;

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
    final fb = FeedbackColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kart Durum Özeti',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
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
              icon: LucideIcons.clock,
              color: fb.highlight,
              onTap: () => onNavigateToTab?.call(0),
            ),
            StatsMetricCard(
              title: 'Öğrenilmekte',
              value: '$learningCount',
              icon: LucideIcons.repeat,
              color: fb.warning,
              onTap: () => onNavigateToTab?.call(2),
            ),
            StatsMetricCard(
              title: 'Öğrenildi',
              value: '$masteredCount',
              icon: LucideIcons.badgeCheck,
              color: fb.success,
              onTap: () => onNavigateToTab?.call(2),
            ),
            StatsMetricCard(
              title: 'Yeni Kartlar',
              value: '$newCount',
              icon: LucideIcons.sparkles,
              color: fb.info,
              onTap: () => onNavigateToTab?.call(2),
            ),
          ],
        ),
      ],
    );
  }
}
