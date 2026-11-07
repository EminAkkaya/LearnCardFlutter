import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';

class LearningProgressCard extends StatelessWidget {
  final double masteryRatio;
  final int masteredCount;
  final int totalCount;

  const LearningProgressCard({
    super.key,
    required this.masteryRatio,
    required this.masteredCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final fb = FeedbackColors.of(context);
    const tabular = [FontFeature.tabularFigures()];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.trendingUp, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Öğrenme İlerlemesi',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '%${(masteryRatio * 100).toStringAsFixed(0)} Ustalaşıldı',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                      fontFeatures: tabular,
                    ),
                  ),
                ),
                Text(
                  '$masteredCount / $totalCount Kelime',
                  style: TextStyle(
                    fontSize: 13,
                    color: palette.textSecondary,
                    fontFeatures: tabular,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppPalette.radiusPill),
              child: LinearProgressIndicator(
                value: masteryRatio,
                minHeight: 6,
                backgroundColor: palette.border,
                color: fb.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
