import 'package:flutter/material.dart';
import '../../../models/flashcard_model.dart';
import '../../../providers/flashcard_provider.dart';
import '../flashcard_review_screen.dart';

void showCustomStudyBottomSheet(
  BuildContext context,
  FlashcardState cardState, {
  String initialStatus = 'all',
}) {
  const Color emerald = Color(0xFF10B981);
  String selectedStatus = initialStatus;
  int countOption = 10;
  bool shuffle = true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          List<FlashcardModel> matching;
          if (selectedStatus == 'due') {
            matching = cardState.dueCards;
          } else if (selectedStatus == 'new') {
            matching = cardState.newCards;
          } else if (selectedStatus == 'learning') {
            matching = cardState.learningCards;
          } else if (selectedStatus == 'mastered') {
            matching = cardState.masteredCards;
          } else {
            matching = cardState.cards;
          }

          final int availableCount = matching.length;
          final int actualCount =
              (countOption == 0 || countOption > availableCount)
                  ? availableCount
                  : countOption;

          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      color: emerald,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Özel Çalışma Ayarları',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Algoritmayı etkilemeden serbest çalışma yapın.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                ),
                const Divider(height: 24),

                const Text(
                  'Kart Kategorisi / Durumu',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildChipOption(
                      'all',
                      'Tümü (${cardState.cards.length})',
                      selectedStatus,
                      (val) => setSheetState(() => selectedStatus = val),
                    ),
                    _buildChipOption(
                      'due',
                      'Bugün Tekrar (${cardState.dueCards.length})',
                      selectedStatus,
                      (val) => setSheetState(() => selectedStatus = val),
                    ),
                    _buildChipOption(
                      'new',
                      'Yeni (${cardState.newCards.length})',
                      selectedStatus,
                      (val) => setSheetState(() => selectedStatus = val),
                    ),
                    _buildChipOption(
                      'learning',
                      'Öğrenilmekte (${cardState.learningCards.length})',
                      selectedStatus,
                      (val) => setSheetState(() => selectedStatus = val),
                    ),
                    _buildChipOption(
                      'mastered',
                      'Öğrenildi (${cardState.masteredCards.length})',
                      selectedStatus,
                      (val) => setSheetState(() => selectedStatus = val),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text(
                  'Çalışılacak Kart Sayısı',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [5, 10, 20, 50, 0].map((count) {
                    final label = count == 0 ? 'Tümü' : '$count Kart';
                    final isSelected = countOption == count;
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) {
                        setSheetState(() => countOption = count);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Kartları Karıştır',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Soruların sırasını rastgele değiştirir',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: shuffle,
                  onChanged: (val) => setSheetState(() => shuffle = val),
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          availableCount == 0
                              ? 'Seçilen kategoride kullanılabilir kart yok.'
                              : 'Toplam $availableCount kart arasından $actualCount kelime çalışılacak.',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: availableCount == 0
                        ? null
                        : () {
                            List<FlashcardModel> sessionList = List.from(
                              matching,
                            );
                            if (shuffle) {
                              sessionList.shuffle();
                            }
                            if (actualCount < sessionList.length) {
                              sessionList = sessionList.sublist(
                                0,
                                actualCount,
                              );
                            }

                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FlashcardReviewScreen(
                                  customCards: sessionList,
                                  isCustomStudy: true,
                                ),
                              ),
                            );
                          },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(
                      'Çalışmayı Başlat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: emerald,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildChipOption(
  String key,
  String label,
  String currentSelected,
  Function(String) onSelect,
) {
  final isSelected = currentSelected == key;
  return ChoiceChip(
    label: Text(label),
    selected: isSelected,
    onSelected: (_) => onSelect(key),
  );
}
