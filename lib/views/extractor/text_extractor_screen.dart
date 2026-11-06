import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/text_parser.dart';
import '../../providers/flashcard_provider.dart';
import '../../services/dictionary_service.dart';
import 'widgets/extracted_word_item_card.dart';
import 'widgets/extracted_words_header.dart';
import 'widgets/extractor_filters_row.dart';
import 'widgets/extractor_input_card.dart';

class TextExtractorScreen extends ConsumerStatefulWidget {
  const TextExtractorScreen({super.key});

  @override
  ConsumerState<TextExtractorScreen> createState() =>
      _TextExtractorScreenState();
}

class _TextExtractorScreenState extends ConsumerState<TextExtractorScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _filterStopWords = true;
  int _minWordLength = 3;
  List<ExtractedWordItem> _extractedWords = [];
  final Set<String> _selectedWords = {};
  bool _isProcessing = false;

  static const Color emerald = Color(0xFF10B981);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _extractWords() {
    FocusScope.of(context).unfocus();
    final items = TextParser.extractUniqueWords(
      _textController.text,
      filterStopWords: _filterStopWords,
      minWordLength: _minWordLength,
    );
    setState(() {
      _extractedWords = items;
      _selectedWords.clear();
      _selectedWords.addAll(items.map((e) => e.word));
    });
  }

  Future<void> _bulkAddToDeck() async {
    if (_selectedWords.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isProcessing = true);

    final List<Map<String, String>> newCardsData = [];
    final targetItems = _extractedWords
        .where((item) => _selectedWords.contains(item.word))
        .toList();

    for (final item in targetItems) {
      try {
        final res = await DictionaryService.fetchWordDefinition(item.word);
        newCardsData.add({
          'word': item.word,
          'trTranslation': res.trTranslation,
          'definition': res.definition,
          'phonetic': res.phonetic,
          'partOfSpeech': res.partOfSpeech,
          'audioUrl': res.audioUrl,
          'sentence': item.sentence,
        });
      } catch (_) {
        newCardsData.add({'word': item.word, 'sentence': item.sentence});
      }
    }

    final addedCount =
        await ref.read(flashcardProvider.notifier).bulkAddCards(newCardsData);

    if (mounted) {
      setState(() => _isProcessing = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('$addedCount yeni kelime destenize başarıyla eklendi!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: emerald,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toplu Kelime Çıkarıcı')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExtractorInputCard(controller: _textController),
            const SizedBox(height: 14),
            ExtractorFiltersRow(
              filterStopWords: _filterStopWords,
              minWordLength: _minWordLength,
              onFilterStopWordsChanged: (v) =>
                  setState(() => _filterStopWords = v),
              onMinWordLengthChanged: (v) => setState(() => _minWordLength = v),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _extractWords,
                icon: const Icon(Icons.bolt_rounded),
                label: const Text('Kelimeleri Çıkar'),
              ),
            ),
            if (_extractedWords.isNotEmpty) ...[
              const Divider(height: 32),
              ExtractedWordsHeader(
                selectedCount: _selectedWords.length,
                totalCount: _extractedWords.length,
                onToggleAll: () {
                  setState(() {
                    if (_selectedWords.length == _extractedWords.length) {
                      _selectedWords.clear();
                    } else {
                      _selectedWords.addAll(_extractedWords.map((e) => e.word));
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _extractedWords.length,
                itemBuilder: (_, idx) {
                  final item = _extractedWords[idx];
                  return ExtractedWordItemCard(
                    item: item,
                    isSelected: _selectedWords.contains(item.word),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedWords.add(item.word);
                        } else {
                          _selectedWords.remove(item.word);
                        }
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _bulkAddToDeck,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.library_add_rounded),
                  label: Text(_isProcessing
                      ? 'Sözlükten Çeviriler Getiriliyor...'
                      : 'Seçilenleri Desteye Ekle (${_selectedWords.length})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emerald,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
