import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../models/flashcard_model.dart';
import 'deck_card_status_badge.dart';

class FlashcardFrontView extends StatelessWidget {
  final FlashcardModel card;

  const FlashcardFrontView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(flex: 0, child: DeckCardStatusBadge(status: card.status)),
        const Spacer(),
        Text(
          card.word,
          softWrap: true,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            height: 1.15,
            color: palette.textPrimary,
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
              color: palette.textSecondary,
            ),
          ),
        ],
        if (card.partOfSpeech.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '(${card.partOfSpeech})',
            style: TextStyle(fontSize: 13, color: palette.textMuted),
          ),
        ],
        if (card.exampleSentence.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.subtle,
              borderRadius: BorderRadius.circular(AppPalette.radiusControl),
              border: Border.all(color: palette.border),
            ),
            child: Text(
              '"${card.exampleSentence}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                fontStyle: FontStyle.italic,
                color: palette.textSecondary,
              ),
            ),
          ),
        ],
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.pointer, size: 16, color: palette.textMuted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Cevap için karta dokunun',
                style: TextStyle(fontSize: 13, color: palette.textMuted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
