import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Text(
              card.word,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 8),
            if (card.phonetic.isNotEmpty)
              Text(
                card.phonetic,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
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
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                DeckCardStatusBadge(status: card.status),
                const SizedBox(width: 8),
                Text(
                  'Tekrar: ${card.repetitions} | Aralık: ${card.interval}g',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (card.audioUrl.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Colors.indigo),
                onPressed: () => AudioHelper.playAudio(card.audioUrl),
              ),
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') onEdit();
                if (val == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Düzenle'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Sil', style: TextStyle(color: Colors.red)),
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
