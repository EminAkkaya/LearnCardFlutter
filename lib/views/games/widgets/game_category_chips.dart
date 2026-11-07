import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
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
    final p = AppPalette.of(context);
    final scheme = Theme.of(context).colorScheme;

    final categories = [
      {'key': 'all', 'label': 'Tümü (${cardState.cards.length})'},
      {'key': 'due', 'label': 'Bugün Tekrar (${cardState.dueCards.length})'},
      {'key': 'learning', 'label': 'Öğrenilmekte (${cardState.learningCards.length})'},
      {'key': 'new', 'label': 'Yeni (${cardState.newCards.length})'},
      {'key': 'mastered', 'label': 'Ustalaşılan (${cardState.masteredCards.length})'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kelime Havuzu Seçimi',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: p.textSecondary),
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
                  shape: const StadiumBorder(),
                  side: BorderSide(color: isSelected ? scheme.primary : p.border),
                  backgroundColor: p.card,
                  selectedColor: scheme.primaryContainer,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? p.textPrimary : p.textSecondary,
                  ),
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
