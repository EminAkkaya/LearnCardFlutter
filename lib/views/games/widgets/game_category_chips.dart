import 'package:flutter/material.dart';
import '../../../providers/flashcard_provider.dart';

class GameCategoryChips extends StatelessWidget {
  final FlashcardState cardState;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const GameCategoryChips({
    super.key,
    required this.cardState,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final categories = [
      {'key': 'all', 'label': 'Tümü (${cardState.cards.length})'},
      {'key': 'due', 'label': 'Bugün Tekrar (${cardState.dueCards.length})'},
      {'key': 'learning', 'label': 'Öğrenilen (${cardState.learningCards.length})'},
      {'key': 'new', 'label': 'Yeni (${cardState.newCards.length})'},
      {'key': 'mastered', 'label': 'Ustalaşılan (${cardState.masteredCards.length})'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kelime Havuzu Seçimi',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final key = cat['key']!;
              final label = cat['label']!;
              final isSelected = selectedCategory == key;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: theme.colorScheme.primaryContainer,
                  onSelected: (_) => onSelected(key),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
