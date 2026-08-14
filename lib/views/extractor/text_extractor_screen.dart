import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/text_parser.dart';
import '../../providers/flashcard_provider.dart';
import '../../services/dictionary_service.dart';

class TextExtractorScreen extends ConsumerStatefulWidget {
  const TextExtractorScreen({super.key});

  @override
  ConsumerState<TextExtractorScreen> createState() => _TextExtractorScreenState();
}

class _TextExtractorScreenState extends ConsumerState<TextExtractorScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _filterStopWords = true;
  int _minWordLength = 3;

  List<ExtractedWordItem> _extractedWords = [];
  final Set<String> _selectedWords = {};
  bool _isProcessing = false;

  static const Color emerald = Color(0xFF10B981);

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
    final targetItems = _extractedWords.where((item) => _selectedWords.contains(item.word)).toList();

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
        newCardsData.add({
          'word': item.word,
          'sentence': item.sentence,
        });
      }
    }

    final addedCount = await ref.read(flashcardProvider.notifier).bulkAddCards(newCardsData);

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toplu Kelime Çıkarıcı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İngilizce Metin Yapıştırın',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Makale, ders notu veya herhangi bir İngilizce metin yapıştırın...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: FilterChip(
                    selected: _filterStopWords,
                    label: const Text('Yaygın Kelimeleri Filtrele (the, a, is...)'),
                    onSelected: (val) => setState(() => _filterStopWords = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Text(
                  'Min. Kelime Uzunluğu: $_minWordLength harf',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Slider(
                    value: _minWordLength.toDouble(),
                    min: 2,
                    max: 6,
                    divisions: 4,
                    label: '$_minWordLength',
                    onChanged: (val) => setState(() => _minWordLength = val.toInt()),
                  ),
                ),
              ],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Çıkarılan Kelimeler (${_selectedWords.length}/${_extractedWords.length})',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedWords.length == _extractedWords.length) {
                          _selectedWords.clear();
                        } else {
                          _selectedWords.addAll(_extractedWords.map((e) => e.word));
                        }
                      });
                    },
                    child: Text(
                      _selectedWords.length == _extractedWords.length ? 'Tümünü Kaldır' : 'Tümünü Seç',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _extractedWords.length,
                itemBuilder: (context, index) {
                  final item = _extractedWords[index];
                  final isSelected = _selectedWords.contains(item.word);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedWords.add(item.word);
                          } else {
                            _selectedWords.remove(item.word);
                          }
                        });
                      },
                      title: Row(
                        children: [
                          Text(
                            item.word,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${item.count}x',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        item.sentence,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ),
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
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
