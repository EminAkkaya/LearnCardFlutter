import 'package:flutter/material.dart';
import '../../../models/flashcard_model.dart';

class ScrambleClueCard extends StatelessWidget {
  final FlashcardModel card;

  const ScrambleClueCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const indigoColor = Color(0xFF6366F1);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.translate_rounded, color: indigoColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'TÜRKÇE ANLAMI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              card.trTranslation.isNotEmpty ? card.trTranslation : card.definition,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (card.definition.isNotEmpty && card.trTranslation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                card.definition,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
