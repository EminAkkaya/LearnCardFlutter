import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../models/flashcard_model.dart';

class ScrambleClueCard extends StatelessWidget {
  final FlashcardModel card;

  const ScrambleClueCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: p.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.languages, color: p.accentGraphic, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'TÜRKÇE ANLAMI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: p.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            card.trTranslation.isNotEmpty ? card.trTranslation : card.definition,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: p.textPrimary,
            ),
          ),
          if (card.definition.isNotEmpty && card.trTranslation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              card.definition,
              style: TextStyle(fontSize: 14, height: 1.5, color: p.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
