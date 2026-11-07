import 'package:flutter/material.dart';
import '../../../providers/flashcard_provider.dart';
import 'deck_filter_chip_item.dart';

class DeckFilterChips extends StatelessWidget {
  final FlashcardState cardState;
  final ValueChanged<String> onSelected;

  const DeckFilterChips({
    super.key,
    required this.cardState,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          DeckFilterChipItem(
            statusKey: 'all',
            label: 'Tümü (${cardState.cards.length})',
            isSelected: cardState.filterStatus == 'all',
            onSelected: onSelected,
          ),
          const SizedBox(width: 8),
          DeckFilterChipItem(
            statusKey: 'due',
            label: 'Bugün Tekrar (${cardState.dueCards.length})',
            isSelected: cardState.filterStatus == 'due',
            onSelected: onSelected,
          ),
          const SizedBox(width: 8),
          DeckFilterChipItem(
            statusKey: 'new',
            label: 'Yeni (${cardState.newCards.length})',
            isSelected: cardState.filterStatus == 'new',
            onSelected: onSelected,
          ),
          const SizedBox(width: 8),
          DeckFilterChipItem(
            statusKey: 'learning',
            label: 'Öğrenilmekte (${cardState.learningCards.length})',
            isSelected: cardState.filterStatus == 'learning',
            onSelected: onSelected,
          ),
          const SizedBox(width: 8),
          DeckFilterChipItem(
            statusKey: 'mastered',
            label: 'Öğrenildi (${cardState.masteredCards.length})',
            isSelected: cardState.filterStatus == 'mastered',
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}
