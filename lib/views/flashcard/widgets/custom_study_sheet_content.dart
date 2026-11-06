import 'package:flutter/material.dart';
import '../../../models/flashcard_model.dart';
import '../../../providers/flashcard_provider.dart';
import '../flashcard_review_screen.dart';

class CustomStudySheetContent extends StatefulWidget {
  final FlashcardState cardState;
  final String initialStatus;

  const CustomStudySheetContent({
    super.key,
    required this.cardState,
    this.initialStatus = 'all',
  });

  @override
  State<CustomStudySheetContent> createState() => _CustomStudySheetContentState();
}

class _CustomStudySheetContentState extends State<CustomStudySheetContent> {
  static const Color emerald = Color(0xFF10B981);
  late String _selectedStatus;
  int _countOption = 10;
  bool _shuffle = true;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
  }

  List<FlashcardModel> _getMatchingCards() {
    if (_selectedStatus == 'due') return widget.cardState.dueCards;
    if (_selectedStatus == 'new') return widget.cardState.newCards;
    if (_selectedStatus == 'learning') return widget.cardState.learningCards;
    if (_selectedStatus == 'mastered') return widget.cardState.masteredCards;
    return widget.cardState.cards;
  }

  void _startStudy(List<FlashcardModel> matching, int actualCount) {
    List<FlashcardModel> sessionList = List.from(matching);
    if (_shuffle) sessionList.shuffle();
    if (actualCount < sessionList.length) {
      sessionList = sessionList.sublist(0, actualCount);
    }

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardReviewScreen(
          customCards: sessionList,
          isCustomStudy: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matching = _getMatchingCards();
    final availableCount = matching.length;
    final actualCount = (_countOption == 0 || _countOption > availableCount)
        ? availableCount
        : _countOption;

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
              const Icon(Icons.school_rounded, color: emerald, size: 28),
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
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),
          const Divider(height: 24),
          const Text('Kart Kategorisi / Durumu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: Text('Tümü (${widget.cardState.cards.length})'),
                selected: _selectedStatus == 'all',
                onSelected: (_) => setState(() => _selectedStatus = 'all'),
              ),
              ChoiceChip(
                label: Text('Bugün Tekrar (${widget.cardState.dueCards.length})'),
                selected: _selectedStatus == 'due',
                onSelected: (_) => setState(() => _selectedStatus = 'due'),
              ),
              ChoiceChip(
                label: Text('Yeni (${widget.cardState.newCards.length})'),
                selected: _selectedStatus == 'new',
                onSelected: (_) => setState(() => _selectedStatus = 'new'),
              ),
              ChoiceChip(
                label: Text('Öğrenilmekte (${widget.cardState.learningCards.length})'),
                selected: _selectedStatus == 'learning',
                onSelected: (_) => setState(() => _selectedStatus = 'learning'),
              ),
              ChoiceChip(
                label: Text('Öğrenildi (${widget.cardState.masteredCards.length})'),
                selected: _selectedStatus == 'mastered',
                onSelected: (_) => setState(() => _selectedStatus = 'mastered'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Çalışılacak Kart Sayısı', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [5, 10, 20, 50, 0].map((count) {
              return ChoiceChip(
                label: Text(count == 0 ? 'Tümü' : '$count Kart'),
                selected: _countOption == count,
                onSelected: (_) => setState(() => _countOption = count),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Kartları Karıştır', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Soruların sırasını rastgele değiştirir', style: TextStyle(fontSize: 12)),
            value: _shuffle,
            onChanged: (val) => setState(() => _shuffle = val),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    availableCount == 0
                        ? 'Seçilen kategoride kullanılabilir kart yok.'
                        : 'Toplam $availableCount kart arasından $actualCount kelime çalışılacak.',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
              onPressed: availableCount == 0 ? null : () => _startStudy(matching, actualCount),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Çalışmayı Başlat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: emerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
