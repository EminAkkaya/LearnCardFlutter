import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/text_parser.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/reading_provider.dart';
import 'word_detail_sheet.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late final TextEditingController _textController;
  static const Color emerald = Color(0xFF10B981);
  
  List<String> _paragraphs = [];

  @override
  void initState() {
    super.initState();
    final initialText = ref.read(readingProvider).currentText;
    _textController = TextEditingController(text: initialText);
    _updateParagraphs(initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateParagraphs(String text) {
    if (text.trim().isEmpty) {
      _paragraphs = [];
    } else {
      _paragraphs = text.split('\n');
    }
  }

  void _openWordSheet(String word) {
    final String contextStr = TextParser.extractSentence(_textController.text, word);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WordDetailSheet(
        word: word,
        sentenceContext: contextStr,
      ),
    );
  }

  void _showThemeSelectorSheet(ReaderThemeColors currentColors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: currentColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final currentThemeMode = ref.watch(readingProvider).themeMode;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Okuma Teması ve Görünüm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: currentColors.defaultText,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: currentColors.defaultText),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...ReaderThemeMode.values.map((mode) {
                final themeColors = ReaderThemeColors.fromMode(mode);
                final bool isSelected = currentThemeMode == mode;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: themeColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? themeColors.newWordColor
                          : themeColors.defaultText.withValues(alpha: 0.2),
                      width: isSelected ? 2.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      themeColors.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themeColors.defaultText,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text('Örnek: ', style: TextStyle(color: themeColors.defaultText, fontSize: 12)),
                        Text('Yeni ', style: TextStyle(color: themeColors.newWordColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Öğrenilen ', style: TextStyle(color: themeColors.learningWordColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Öğrenildi', style: TextStyle(color: themeColors.masteredWordColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: themeColors.newWordColor)
                        : null,
                    onTap: () {
                      ref.read(readingProvider.notifier).setThemeMode(mode);
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSaveArticleDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Makaleyi Kaydet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Makale Başlığı',
                hintText: 'Örn: The Art of Learning',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_textController.text.trim().isNotEmpty) {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(ctx);

                await ref.read(readingProvider.notifier).saveArticle(
                      titleController.text,
                      _textController.text,
                    );

                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Makale Supabase veritabanına kaydedildi!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: emerald,
                  ),
                );
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showSavedArticlesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final readingState = ref.watch(readingProvider);
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kaydedilen Okuma Metinleri',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (readingState.articles.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('Henüz kaydedilmiş bir okuma metni yok.'),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: readingState.articles.length,
                        itemBuilder: (context, index) {
                          final article = readingState.articles[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(
                                article.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                article.text.length > 80
                                    ? '${article.text.substring(0, 80)}...'
                                    : article.text,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  ref.read(readingProvider.notifier).deleteArticle(article.id);
                                },
                              ),
                              onTap: () {
                                ref.read(readingProvider.notifier).selectArticle(article);
                                Navigator.pop(ctx);
                              },
                            ),
                          );
                        },
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

  void _showNewTextDialog() {
    final inputCtrl = TextEditingController(text: _textController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Okuma Metni Girin'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: inputCtrl,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Metninizi buraya yapıştırın...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(readingProvider.notifier).updateCurrentText(inputCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Metni Yükle'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBar(ReaderThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildLegendItem(colors.newWordColor, 'Öğrenilmemiş'),
            const SizedBox(width: 14),
            _buildLegendItem(colors.learningWordColor, 'Öğrenilmekte'),
            const SizedBox(width: 14),
            _buildLegendItem(colors.masteredWordColor, 'Öğrenildi'),
            const SizedBox(width: 14),
            _buildLegendItem(colors.unaddedWordColor, 'Destede Yok'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ReadingState>(readingProvider, (previous, next) {
      if (previous?.currentText != next.currentText) {
        if (_textController.text != next.currentText) {
          setState(() {
            _textController.text = next.currentText;
            _updateParagraphs(next.currentText);
          });
        }
      }
    });

    final readingState = ref.watch(readingProvider);
    // Optimization: Only rebuild when the cards list changes, not on every flashcard state change
    final flashcardCards = ref.watch(flashcardProvider.select((state) => state.cards));
    
    final isFocusMode = readingState.isFocusMode;
    final themeColors = ReaderThemeColors.fromMode(readingState.themeMode);

    final cardMap = {
      for (final card in flashcardCards) card.word.toLowerCase(): card.status
    };

    return Scaffold(
      backgroundColor: themeColors.background,
      appBar: isFocusMode
          ? null
          : AppBar(
              backgroundColor: themeColors.surface,
              foregroundColor: themeColors.defaultText,
              elevation: 0,
              title: Text(
                'İnteraktif Okuyucu',
                style: TextStyle(color: themeColors.defaultText),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.palette_outlined),
                  tooltip: 'Tema Seç',
                  color: themeColors.defaultText,
                  onPressed: () => _showThemeSelectorSheet(themeColors),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border_rounded),
                  tooltip: 'Kayıtlı Metinler',
                  color: themeColors.defaultText,
                  onPressed: _showSavedArticlesSheet,
                ),
                IconButton(
                  icon: const Icon(Icons.save_outlined),
                  tooltip: 'Metni Kaydet',
                  color: themeColors.defaultText,
                  onPressed: _showSaveArticleDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded),
                  tooltip: 'Metni Düzenle',
                  color: themeColors.defaultText,
                  onPressed: _showNewTextDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen_rounded),
                  tooltip: 'Odak Modu',
                  color: themeColors.defaultText,
                  onPressed: () => ref.read(readingProvider.notifier).toggleFocusMode(),
                ),
              ],
            ),
      body: SafeArea(
        child: Column(
          children: [
            if (isFocusMode)
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.palette_outlined, size: 24),
                      color: themeColors.defaultText.withValues(alpha: 0.7),
                      tooltip: 'Tema Seç',
                      onPressed: () => _showThemeSelectorSheet(themeColors),
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen_exit_rounded, size: 28),
                      color: themeColors.defaultText.withValues(alpha: 0.7),
                      tooltip: 'Odak Modundan Çık',
                      onPressed: () => ref.read(readingProvider.notifier).setFocusMode(false),
                    ),
                  ],
                ),
              ),

            if (!isFocusMode) _buildLegendBar(themeColors),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: isFocusMode ? 24 : 16,
                  vertical: isFocusMode ? 20 : 16,
                ),
                itemCount: _paragraphs.length,
                itemBuilder: (context, index) {
                  return ReaderParagraph(
                    text: _paragraphs[index],
                    isFocusMode: isFocusMode,
                    cardMap: cardMap,
                    colors: themeColors,
                    onWordTap: _openWordSheet,
                  );
                },
              ),
            ),

            if (!isFocusMode)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeColors.surface,
                  border: Border(top: BorderSide(color: themeColors.defaultText.withValues(alpha: 0.1))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: themeColors.defaultText,
                          side: BorderSide(color: themeColors.defaultText.withValues(alpha: 0.3)),
                        ),
                        onPressed: _showNewTextDialog,
                        icon: const Icon(Icons.paste_rounded, size: 18),
                        label: const Text('Yeni Metin Yapıştır'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColors.defaultText.withValues(alpha: 0.15),
                          foregroundColor: themeColors.defaultText,
                        ),
                        onPressed: _showSavedArticlesSheet,
                        icon: const Icon(Icons.folder_open_rounded, size: 18),
                        label: const Text('Kayıtlı Metinler'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ReaderParagraph extends StatefulWidget {
  final String text;
  final bool isFocusMode;
  final Map<String, String> cardMap;
  final ReaderThemeColors colors;
  final Function(String) onWordTap;

  const ReaderParagraph({
    super.key,
    required this.text,
    required this.isFocusMode,
    required this.cardMap,
    required this.colors,
    required this.onWordTap,
  });

  @override
  State<ReaderParagraph> createState() => _ReaderParagraphState();
}

class _ReaderParagraphState extends State<ReaderParagraph> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _clearRecognizers();
    super.dispose();
  }

  void _clearRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) {
      return const SizedBox(height: 16); 
    }

    _clearRecognizers();
    final tokens = TextParser.parseTextToTokens(widget.text);
    final List<InlineSpan> spans = [];
    final double fontSize = widget.isFocusMode ? 20 : 18;

    for (final token in tokens) {
      if (!token.isWord) {
        spans.add(
          TextSpan(
            text: token.text,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.6,
              color: widget.colors.defaultText,
            ),
          ),
        );
      } else {
        final recognizer = TapGestureRecognizer()
          ..onTap = () => widget.onWordTap(token.cleanWord);
        _recognizers.add(recognizer);

        final status = widget.cardMap[token.cleanWord];
        final Color wordColor;
        final Color underlineColor;
        final double decorationThickness;

        if (status == 'new') {
          wordColor = widget.colors.newWordColor;
          underlineColor = widget.colors.newWordColor.withValues(alpha: 0.8);
          decorationThickness = 2.0;
        } else if (status == 'learning') {
          wordColor = widget.colors.learningWordColor;
          underlineColor = widget.colors.learningWordColor.withValues(alpha: 0.8);
          decorationThickness = 2.0;
        } else if (status == 'mastered') {
          wordColor = widget.colors.masteredWordColor;
          underlineColor = widget.colors.masteredWordColor.withValues(alpha: 0.8);
          decorationThickness = 2.0;
        } else {
          wordColor = widget.colors.unaddedWordColor;
          underlineColor = widget.colors.defaultText.withValues(alpha: 0.25);
          decorationThickness = 1.0;
        }

        spans.add(
          TextSpan(
            text: token.text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: status != null ? FontWeight.bold : FontWeight.w500,
              color: wordColor,
              height: 1.6,
              decoration: TextDecoration.underline,
              decorationColor: underlineColor,
              decorationThickness: decorationThickness,
            ),
            recognizer: recognizer,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text.rich(TextSpan(children: spans)),
    );
  }
}
