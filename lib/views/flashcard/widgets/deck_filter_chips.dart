import 'package:flutter/material.dart';
import '../../../providers/flashcard_provider.dart';

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
          _buildFilterChip('all', 'Tümü (${cardState.cards.length})'),
          const SizedBox(width: 8),
          _buildFilterChip('due', 'Bugün Tekrar (${cardState.dueCards.length})'),
          const SizedBox(width: 8),
          _buildFilterChip('new', 'Yeni (${cardState.newCards.length})'),
          const SizedBox(width: 8),
          _buildFilterChip('learning', 'Öğrenilen (${cardState.learningCards.length})'),
          const SizedBox(width: 8),
          _buildFilterChip('mastered', 'Öğrenildi (${cardState.masteredCards.length})'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final bool isSelected = cardState.filterStatus == key;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => onSelected(key),
    );
  }
}
