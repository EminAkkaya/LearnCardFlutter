import 'package:flutter/material.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../models/flashcard_model.dart';

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

  static const Color emerald = Color(0xFF10B981);

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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            if (card.phonetic.isNotEmpty)
              Text(
                card.phonetic,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              card.trTranslation.isNotEmpty
                  ? card.trTranslation
                  : card.definition,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildStatusBadge(card.status),
                const SizedBox(width: 8),
                Text(
                  'Tekrar: ${card.repetitions} | Aralık: ${card.interval}g',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
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
                icon: const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.indigo,
                ),
                onPressed: () => AudioHelper.playAudio(card.audioUrl),
              ),
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') {
                  onEdit();
                } else if (val == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Düzenle'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sil',
                        style: TextStyle(color: Colors.red),
                      ),
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

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'new') color = Colors.blue;
    if (status == 'learning') color = Colors.orange;
    if (status == 'mastered') color = emerald;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
