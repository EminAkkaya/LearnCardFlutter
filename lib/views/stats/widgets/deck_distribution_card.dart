import 'package:flutter/material.dart';
import '../../../providers/flashcard_provider.dart';
import 'deck_distribution_legend_tile.dart';

class DeckDistributionCard extends StatelessWidget {
  final FlashcardState cardState;
  final Function(int tabIndex)? onNavigateToTab;

  static const Color emerald = Color(0xFF10B981);

  const DeckDistributionCard({
    super.key,
    required this.cardState,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = cardState.cards.length;
    final mastered = cardState.masteredCards.length;
    final learning = cardState.learningCards.length;
    final newCards = cardState.newCards.length;
    final due = cardState.dueCards.length;

    final double masteredPct = total > 0 ? (mastered / total) : 0;
    final double learningPct = total > 0 ? (learning / total) : 0;
    final double newPct = total > 0 ? (newCards / total) : 0;

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
                  'Deste Durum Dağılımı',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Toplam $total Kelime',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 12,
                child: total == 0
                    ? Container(color: theme.dividerColor.withValues(alpha: 0.2))
                    : Row(
                        children: [
                          if (masteredPct > 0)
                            Expanded(
                              flex: (masteredPct * 100).toInt(),
                              child: Container(color: emerald),
                            ),
                          if (learningPct > 0)
                            Expanded(
                              flex: (learningPct * 100).toInt(),
                              child: Container(color: Colors.blue),
                            ),
                          if (newPct > 0)
                            Expanded(
                              flex: (newPct * 100).toInt(),
                              child: Container(color: Colors.purple),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DeckDistributionLegendTile(
                  label: 'Öğrenildi',
                  value: '$mastered (%${(masteredPct * 100).toInt()})',
                  color: emerald,
                ),
                DeckDistributionLegendTile(
                  label: 'Öğrenilen',
                  value: '$learning (%${(learningPct * 100).toInt()})',
                  color: Colors.blue,
                ),
                DeckDistributionLegendTile(
                  label: 'Yeni',
                  value: '$newCards (%${(newPct * 100).toInt()})',
                  color: Colors.purple,
                ),
                DeckDistributionLegendTile(
                  label: 'Bugün Tekrar',
                  value: '$due',
                  color: Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
