import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../models/daily_activity_model.dart';
import 'stats_metric_card.dart';

class TodayActivityCard extends StatelessWidget {
  final DailyActivityModel todayActivity;
  final Function(int tabIndex)? onNavigateToTab;

  const TodayActivityCard({
    super.key,
    required this.todayActivity,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fb = FeedbackColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Bugünkü Aktiviteleriniz',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: fb.successContainer,
                borderRadius: BorderRadius.circular(AppPalette.radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.activity, size: 12, color: fb.success),
                  const SizedBox(width: 4),
                  Text(
                    'Canlı Takip',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: fb.success,
                    ),
                  ),
                ],
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
              icon: LucideIcons.repeat,
              color: fb.info,
              onTap: () => onNavigateToTab?.call(0),
            ),
            StatsMetricCard(
              title: 'Yeni Eklenen',
              value: '${todayActivity.cardsAdded}',
              icon: LucideIcons.bookPlus,
              color: fb.success,
              onTap: () => onNavigateToTab?.call(2),
            ),
            StatsMetricCard(
              title: 'Oyun Puanı',
              value: '${todayActivity.gameScore}',
              icon: LucideIcons.star,
              color: fb.warning,
              onTap: () => onNavigateToTab?.call(2),
            ),
            StatsMetricCard(
              title: 'Oyun Seansı',
              value: '${todayActivity.gamesPlayed}',
              icon: LucideIcons.gamepad2,
              color: fb.highlight,
              onTap: () => onNavigateToTab?.call(2),
            ),
          ],
        ),
      ],
    );
  }
}
