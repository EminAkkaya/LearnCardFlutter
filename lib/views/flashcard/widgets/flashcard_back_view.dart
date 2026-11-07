import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
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
    final palette = AppPalette.of(context);
    final sectionLabel = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.6,
      color: palette.textSecondary,
    );

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
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: palette.textPrimary,
                ),
              ),
            ),
            if (card.audioUrl.isNotEmpty)
              IconButton.outlined(
                onPressed: () => AudioHelper.playAudio(card.audioUrl),
                icon: const Icon(LucideIcons.volume2, size: 18),
              ),
          ],
        ),
        const Divider(height: 24),
        const Spacer(),
        Text('TÜRKÇE ÇEVİRİ', style: sectionLabel),
        const SizedBox(height: 8),
        Text(
          card.trTranslation.isNotEmpty ? card.trTranslation : 'Çeviri bulunamadı',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (card.definition.isNotEmpty) ...[
          Text('İNGİLİZCE TANIM', style: sectionLabel),
          const SizedBox(height: 6),
          Text(
            card.definition,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: palette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const Spacer(),
        SRSRatingActionBar(previews: previews, onRating: onRating),
      ],
    );
  }
}
