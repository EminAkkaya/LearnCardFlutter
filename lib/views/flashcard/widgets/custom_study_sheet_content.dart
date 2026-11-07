import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
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
    final palette = AppPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    final sectionLabel = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: palette.textSecondary,
    );
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
                color: palette.border,
                borderRadius: BorderRadius.circular(AppPalette.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(LucideIcons.graduationCap, color: scheme.primary, size: 20),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Özel Çalışma Ayarları',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Algoritmayı etkilemeden serbest çalışma yapın.',
            style: TextStyle(
              fontSize: 13,
              color: palette.textSecondary,
            ),
          ),
          const Divider(height: 24),
          Text('Kart Kategorisi / Durumu', style: sectionLabel),
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
          Text('Çalışılacak Kart Sayısı', style: sectionLabel),
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
            title: Text(
              'Kartları Karıştır',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: palette.textPrimary),
            ),
            subtitle: Text(
              'Soruların sırasını rastgele değiştirir',
              style: TextStyle(fontSize: 12, color: palette.textMuted),
            ),
            value: _shuffle,
            onChanged: (val) => setState(() => _shuffle = val),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.subtle,
              borderRadius: BorderRadius.circular(AppPalette.radiusControl),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.info, color: scheme.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    availableCount == 0
                        ? 'Seçilen kategoride kullanılabilir kart yok.'
                        : 'Toplam $availableCount kart arasından $actualCount kelime çalışılacak.',
                    style: TextStyle(
                      fontSize: 13,
                      color: palette.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: availableCount == 0 ? null : () => _startStudy(matching, actualCount),
              icon: const Icon(LucideIcons.play, size: 18),
              label: const Text('Çalışmayı Başlat'),
            ),
          ),
        ],
      ),
    );
  }
}
