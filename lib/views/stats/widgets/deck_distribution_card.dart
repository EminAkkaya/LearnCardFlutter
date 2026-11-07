import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../providers/flashcard_provider.dart';
import 'deck_distribution_legend_tile.dart';

/// Deste durum dağılımı: bölümlenmiş yatay şerit (§9) + lejant.
class DeckDistributionCard extends StatelessWidget {
  final FlashcardState cardState;
  final Function(int tabIndex)? onNavigateToTab;

  const DeckDistributionCard({
    super.key,
    required this.cardState,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final fb = FeedbackColors.of(context);
    final total = cardState.cards.length;
    final mastered = cardState.masteredCards.length;
    final learning = cardState.learningCards.length;
    final newCards = cardState.newCards.length;
    final due = cardState.dueCards.length;

    final double masteredPct = total > 0 ? (mastered / total) : 0;
    final double learningPct = total > 0 ? (learning / total) : 0;
    final double newPct = total > 0 ? (newCards / total) : 0;

    final segments = [
      (mastered, fb.success),
      (learning, fb.warning),
      (newCards, fb.info),
    ].where((s) => s.$1 > 0).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Deste Durum Dağılımı',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'Toplam $total Kelime',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: palette.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppPalette.radiusPill),
              child: SizedBox(
                height: 10,
                child: segments.isEmpty
                    ? Container(color: palette.border)
                    : Row(
                        children: [
                          for (var i = 0; i < segments.length; i++) ...[
                            if (i > 0) Container(width: 2, color: palette.card),
                            Expanded(
                              flex: segments[i].$1,
                              child: Container(color: segments[i].$2),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 20,
              runSpacing: 12,
              children: [
                DeckDistributionLegendTile(
                  label: 'Öğrenildi',
                  value: '$mastered (%${(masteredPct * 100).toInt()})',
                  color: fb.success,
                ),
                DeckDistributionLegendTile(
                  label: 'Öğrenilmekte',
                  value: '$learning (%${(learningPct * 100).toInt()})',
                  color: fb.warning,
                ),
                DeckDistributionLegendTile(
                  label: 'Yeni',
                  value: '$newCards (%${(newPct * 100).toInt()})',
                  color: fb.info,
                ),
                DeckDistributionLegendTile(
                  label: 'Bugün Tekrar',
                  value: '$due',
                  color: fb.highlight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
