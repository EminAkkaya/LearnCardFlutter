import 'package:flutter/material.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../models/flashcard_model.dart';
import '../../../services/srs_service.dart';
import 'srs_rating_action_bar.dart';

class FlashcardBackView extends StatelessWidget {
  final FlashcardModel card;
  final Map<ReviewRating, String> previews;
  final ValueChanged<ReviewRating> onRating;

  const FlashcardBackView({
    super.key,
    required this.card,
    required this.previews,
    required this.onRating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                card.word,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            if (card.audioUrl.isNotEmpty)
              IconButton.filledTonal(
                onPressed: () => AudioHelper.playAudio(card.audioUrl),
                icon: const Icon(Icons.volume_up_rounded),
              ),
          ],
        ),
        const Divider(height: 24),
        const Spacer(),
        Text(
          'TÜRKÇE ÇEVİRİ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          card.trTranslation.isNotEmpty ? card.trTranslation : 'Çeviri bulunamadı',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (card.definition.isNotEmpty) ...[
          Text(
            'İNGİLİZCE TANIM',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.definition,
            style: const TextStyle(fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
        const Spacer(),
        SRSRatingActionBar(previews: previews, onRating: onRating),
      ],
    );
  }
}
