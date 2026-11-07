import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/word_lookup_provider.dart';
import 'widgets/word_detail_action_button.dart';
import 'widgets/word_detail_header.dart';
import 'widgets/word_meanings_section.dart';

class WordDetailSheet extends ConsumerStatefulWidget {
  final String word;
  final String sentenceContext;

  const WordDetailSheet({
    super.key,
    required this.word,
    required this.sentenceContext,
  });

  @override
  ConsumerState<WordDetailSheet> createState() => _WordDetailSheetState();
}

class _WordDetailSheetState extends ConsumerState<WordDetailSheet> {
  late final TextEditingController _trController;
  late final TextEditingController _defController;
  bool _isAdding = false;

  static const Color emerald = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _trController = TextEditingController();
    _defController = TextEditingController();
  }

  @override
  void dispose() {
    _trController.dispose();
    _defController.dispose();
    super.dispose();
  }

  /// Yükleme bitince alanları doldurur; kullanıcının yazdığını ezmez.
  void _onLookup(WordLookupState? prev, WordLookupState next) {
    if (prev?.isLoading == true && !next.isLoading) {
      if (_trController.text.isEmpty) _trController.text = next.suggestedTranslation;
      if (_defController.text.isEmpty) _defController.text = next.details?.definition ?? '';
    }
  }

  Future<void> _addCardToDeck() async {
    setState(() => _isAdding = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    final details = ref.read(wordLookupProvider(widget.word)).details;
    await ref.read(flashcardProvider.notifier).addCard(
          word: widget.word,
          trTranslation: _trController.text,
          definition: _defController.text,
          phonetic: details?.phonetic ?? '',
          partOfSpeech: details?.partOfSpeech ?? '',
          exampleSentence: widget.sentenceContext,
          audioUrl: details?.audioUrl ?? '',
        );

    nav.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('"${widget.word}" desteye eklendi!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: emerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardState = ref.watch(flashcardProvider);
    final lookup = ref.watch(wordLookupProvider(widget.word));
    ref.listen(wordLookupProvider(widget.word), _onLookup);
    final cleanWord = widget.word.trim().toLowerCase();

    final FlashcardModel? existingCard = cardState.cards.cast<FlashcardModel?>().firstWhere(
          (c) => c?.word.toLowerCase() == cleanWord,
          orElse: () => null,
        );

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
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
            WordDetailHeader(word: widget.word, dictResult: lookup.details),
            const Divider(height: 24),
            if (lookup.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (lookup.offline != null) ...[
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _trController,
                  builder: (context, value, _) => WordMeaningsSection(
                    entry: lookup.offline!,
                    selected: value.text,
                    online: lookup.online,
                    isOnlineLoading: lookup.isOnlineLoading,
                    onPick: (tr) => _trController.text = tr,
                    onFetchOnline: () => ref.read(wordLookupProvider(widget.word).notifier).fetchOnline(),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text('Türkçe Çeviri', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _trController,
                decoration: InputDecoration(
                  hintText: 'Çeviri girin...',
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              Text('İngilizce Tanım', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _defController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Definition...',
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              if (widget.sentenceContext.isNotEmpty) ...[
                Text('Cümle İçerisindeki Kullanımı', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(widget.sentenceContext, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: WordDetailActionButton(
                  existingCard: existingCard,
                  isAdding: _isAdding,
                  onAdd: _addCardToDeck,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
