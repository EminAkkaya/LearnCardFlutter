import 'package:flutter/material.dart';
import '../../../models/flashcard_model.dart';

class FlashcardFrontView extends StatelessWidget {
  final FlashcardModel card;

  const FlashcardFrontView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              cardStatusLabel(card.status),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const Spacer(),
        Text(
          card.word,
          softWrap: true,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        if (card.phonetic.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            card.phonetic,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),
        ],
        if (card.partOfSpeech.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '(${card.partOfSpeech})',
            style: TextStyle(fontSize: 14, color: theme.colorScheme.secondary),
          ),
        ],
        if (card.exampleSentence.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"${card.exampleSentence}"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
        ],
        const Spacer(),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app_rounded, size: 18, color: Colors.grey),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'Cevap için karta dokunun',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
