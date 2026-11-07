import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../models/flashcard_model.dart';
import '../../../providers/flashcard_provider.dart';
import '../../../services/srs_service.dart';

/// Oyun sonunda yanlış bilinen/atlanan kartları listeler ve kullanıcı isterse
/// hepsini tek dokunuşla SRS'te "Tekrar" olarak işaretler.
class GameMistakesCard extends ConsumerStatefulWidget {
  final List<FlashcardModel> cards;

  const GameMistakesCard({super.key, required this.cards});

  @override
  ConsumerState<GameMistakesCard> createState() => _GameMistakesCardState();
}

class _GameMistakesCardState extends ConsumerState<GameMistakesCard> {
  bool _queued = false;

  Future<void> _queueForReview() async {
    final notifier = ref.read(flashcardProvider.notifier);
    for (final card in widget.cards) {
      await notifier.reviewCard(card.id, ReviewRating.again);
    }
    if (mounted) setState(() => _queued = true);
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: p.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tekrar etmen gerekenler (${widget.cards.length})',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: p.textPrimary),
          ),
          const SizedBox(height: 8),
          for (final card in widget.cards)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                '${card.word} — ${card.trTranslation.isNotEmpty ? card.trTranslation : card.definition}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: p.textSecondary, height: 1.4),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _queued ? null : _queueForReview,
              icon: Icon(_queued ? LucideIcons.check : LucideIcons.rotateCcw, size: 18),
              label: Text(_queued ? 'Tekrar listesine eklendi' : 'Bunları kart tekrarına ekle'),
            ),
          ),
        ],
      ),
    );
  }
}
