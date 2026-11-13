import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../models/flashcard_model.dart';
import 'deck_card_status_badge.dart';

class DeckCardListItem extends StatelessWidget {
  final FlashcardModel card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DeckCardListItem({
    super.key,
    required this.card,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final fb = FeedbackColors.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Flexible(
              child: Text(
                card.word,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  letterSpacing: -0.2,
                  color: palette.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (card.phonetic.isNotEmpty)
              Flexible(
                child: Text(
                  card.phonetic,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: palette.textMuted,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              card.trTranslation.isNotEmpty ? card.trTranslation : card.definition,
              style: TextStyle(fontSize: 14, color: palette.textSecondary),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                DeckCardStatusBadge(status: card.status),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Tekrar: ${card.repetitions} | Aralık: ${card.interval}g',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(LucideIcons.volume2, size: 20, color: palette.textSecondary),
              tooltip: 'Telaffuzu dinle',
              onPressed: () => AudioHelper.speak(card.word),
            ),
            PopupMenuButton<String>(
              icon: Icon(LucideIcons.ellipsisVertical, size: 20, color: palette.textSecondary),
              onSelected: (val) {
                if (val == 'edit') onEdit();
                if (val == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(LucideIcons.pencil, size: 18),
                      SizedBox(width: 8),
                      Text('Düzenle'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(LucideIcons.trash2, color: fb.danger, size: 18),
                      const SizedBox(width: 8),
                      Text('Sil', style: TextStyle(color: fb.danger)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
