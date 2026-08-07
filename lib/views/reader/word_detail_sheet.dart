import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/audio_helper.dart';
import '../../models/flashcard_model.dart';
import '../../providers/flashcard_provider.dart';
import '../../services/dictionary_service.dart';

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
  bool _isLoading = true;
  WordDefinitionResult? _dictResult;
  late TextEditingController _trController;
  late TextEditingController _defController;
  late TextEditingController _sentenceController;
  bool _isAdding = false;

  static const Color emerald = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _trController = TextEditingController();
    _defController = TextEditingController();
    _sentenceController = TextEditingController(text: widget.sentenceContext);
    _fetchDetails();
  }

  @override
  void dispose() {
    _trController.dispose();
    _defController.dispose();
    _sentenceController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final res = await DictionaryService.fetchWordDefinition(widget.word);
      if (mounted) {
        setState(() {
          _dictResult = res;
          _trController.text = res.trTranslation;
          _defController.text = res.definition;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardState = ref.watch(flashcardProvider);
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
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.word,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_dictResult?.partOfSpeech.isNotEmpty == true)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _dictResult!.partOfSpeech,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (_dictResult?.phonetic.isNotEmpty == true)
                        Text(
                          _dictResult!.phonetic,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),

                if (_dictResult?.audioUrl.isNotEmpty == true)
                  IconButton.filledTonal(
                    onPressed: () => AudioHelper.playAudio(_dictResult!.audioUrl),
                    icon: const Icon(Icons.volume_up_rounded),
                    tooltip: 'Ses Dinle',
                  ),
              ],
            ),

            const Divider(height: 24),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              Text(
                'Türkçe Çeviri',
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _trController,
                decoration: InputDecoration(
                  hintText: 'Çeviri girin...',
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'İngilizce Tanım',
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _defController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Definition...',
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              if (widget.sentenceContext.isNotEmpty) ...[
                Text(
                  'Cümle İçerisindeki Kullanımı',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.sentenceContext,
                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              SizedBox(
                width: double.infinity,
                height: 48,
                child: existingCard != null
                    ? Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: emerald.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: emerald),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: emerald),
                            const SizedBox(width: 8),
                            Text(
                              'Destede Var (${existingCard.status.toUpperCase()})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: emerald,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _isAdding
                            ? null
                            : () async {
                                setState(() => _isAdding = true);
                                final messenger = ScaffoldMessenger.of(context);
                                final navigator = Navigator.of(context);

                                await ref.read(flashcardProvider.notifier).addCard(
                                      word: widget.word,
                                      trTranslation: _trController.text,
                                      definition: _defController.text,
                                      phonetic: _dictResult?.phonetic ?? '',
                                      partOfSpeech: _dictResult?.partOfSpeech ?? '',
                                      exampleSentence: widget.sentenceContext,
                                      audioUrl: _dictResult?.audioUrl ?? '',
                                    );

                                navigator.pop();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('"${widget.word}" desteye eklendi!'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: emerald,
                                  ),
                                );
                              },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Desteye Kart Olarak Ekle'),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
