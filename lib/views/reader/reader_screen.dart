import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/text_parser.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/reading_provider.dart';
import 'word_detail_sheet.dart';
import 'widgets/reader_paragraph.dart';
import 'widgets/reader_legend_bar.dart';
import 'widgets/reader_bottom_bar.dart';
import 'widgets/theme_selector_sheet.dart';
import 'dialogs/reader_dialogs.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late final TextEditingController _textController;
  late final ScrollController _scrollController;
  final GlobalKey _scrollKey = GlobalKey();
  static const Color emerald = Color(0xFF10B981);

  List<String> _paragraphs = [];
  List<GlobalKey> _paragraphKeys = [];

  @override
  void initState() {
    super.initState();
    final initialText = ref.read(readingProvider).currentText;
    _textController = TextEditingController(text: initialText);
    _scrollController = ScrollController();
    _updateParagraphs(initialText);
    _restoreScrollPosition();
  }

  @override
  void dispose() {
    _saveCurrentPosition();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateParagraphs(String text) {
    if (text.trim().isEmpty) {
      _paragraphs = [];
      _paragraphKeys = [];
    } else {
      _paragraphs = text.split('\n');
      _paragraphKeys = List.generate(_paragraphs.length, (_) => GlobalKey());
    }
  }

  int _findTopVisibleParagraphIndex() {
    if (!_scrollController.hasClients || _paragraphKeys.isEmpty) return 0;
    final RenderBox? scrollBox =
        _scrollKey.currentContext?.findRenderObject() as RenderBox?;
    if (scrollBox == null) return 0;

    final double scrollBoxTop = scrollBox.localToGlobal(Offset.zero).dy;

    int bestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < _paragraphKeys.length; i++) {
      final ctx = _paragraphKeys[i].currentContext;
      if (ctx != null) {
        final RenderBox? box = ctx.findRenderObject() as RenderBox?;
        if (box != null && box.attached) {
          final double pTop = box.localToGlobal(Offset.zero).dy - scrollBoxTop;
          final double pBottom = pTop + box.size.height;

          if (pTop <= 40 && pBottom > 0) {
            return i;
          }
          final dist = pTop.abs();
          if (dist < minDistance) {
            minDistance = dist;
            bestIndex = i;
          }
        }
      }
    }
    return bestIndex;
  }

  void _saveCurrentPosition() {
    if (!_scrollController.hasClients) return;
    final topIndex = _findTopVisibleParagraphIndex();
    final offset = _scrollController.offset;
    ref.read(readingProvider.notifier).savePosition(topIndex, offset);
  }

  void _restoreScrollPosition() async {
    final pos = await ref.read(readingProvider.notifier).loadPosition();
    final int paraIndex = pos['paragraphIndex'] ?? 0;
    final double offset = pos['offset'] ?? 0.0;

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (paraIndex > 0 && paraIndex < _paragraphKeys.length) {
        final ctx = _paragraphKeys[paraIndex].currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.0,
            duration: Duration.zero,
          );
          return;
        }
      }
      if (offset > 0 && offset <= _scrollController.position.maxScrollExtent) {
        _scrollController.jumpTo(offset);
      }
    });
  }

  void _preservePositionAcrossFocusMode() {
    final targetIndex = _findTopVisibleParagraphIndex();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (targetIndex >= 0 && targetIndex < _paragraphKeys.length) {
        final ctx = _paragraphKeys[targetIndex].currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.0,
            duration: Duration.zero,
          );
        }
      }
    });
  }

  void _openWordSheet(String word) {
    final String contextStr = TextParser.extractSentence(
      _textController.text,
      word,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          WordDetailSheet(word: word, sentenceContext: contextStr),
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
          _restoreScrollPosition();
        }
      }
      if (previous?.isFocusMode != next.isFocusMode) {
        _preservePositionAcrossFocusMode();
      }
    });

    final readingState = ref.watch(readingProvider);
    // Optimization: Only rebuild when the cards list changes, not on every flashcard state change
    final flashcardCards = ref.watch(
      flashcardProvider.select((state) => state.cards),
    );

    final isFocusMode = readingState.isFocusMode;
    final themeColors = ReaderThemeColors.fromMode(readingState.themeMode);

    final cardMap = {
      for (final card in flashcardCards) card.word.toLowerCase(): card.status,
    };

    return Scaffold(
      backgroundColor: themeColors.background,
      appBar: isFocusMode
          ? null
          : AppBar(
              backgroundColor: themeColors.surface,
              foregroundColor: themeColors.defaultText,
              elevation: 0,
              centerTitle: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    readingState.selectedArticle?.title ?? 'İnteraktif Okuma',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: themeColors.defaultText,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (readingState.selectedArticle != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 12,
                          color: themeColors.defaultText.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          readingState.selectedArticle!.folder,
                          style: TextStyle(
                            color: themeColors.defaultText.withValues(
                              alpha: 0.65,
                            ),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
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
                      onPressed: () =>
                          ThemeSelectorSheet.show(context, themeColors),
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen_exit_rounded, size: 28),
                      color: themeColors.defaultText.withValues(alpha: 0.7),
                      tooltip: 'Odak Modundan Çık',
                      onPressed: () => ref
                          .read(readingProvider.notifier)
                          .setFocusMode(false),
                    ),
                  ],
                ),
              ),

            if (!isFocusMode) ReaderLegendBar(colors: themeColors),

            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollEndNotification) {
                    _saveCurrentPosition();
                  }
                  return false;
                },
                child: ListView.builder(
                  key: _scrollKey,
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: isFocusMode ? 24 : 16,
                    vertical: isFocusMode ? 20 : 16,
                  ),
                  itemCount: _paragraphs.length,
                  itemBuilder: (context, index) {
                    return ReaderParagraph(
                      key: _paragraphKeys.length > index
                          ? _paragraphKeys[index]
                          : null,
                      text: _paragraphs[index],
                      isFocusMode: isFocusMode,
                      cardMap: cardMap,
                      colors: themeColors,
                      onWordTap: _openWordSheet,
                      fontSize: readingState.fontSize,
                      lineHeight: readingState.lineHeight,
                    );
                  },
                ),
              ),
            ),

            if (!isFocusMode)
              ReaderBottomBar(
                colors: themeColors,
                onNewTextTap: () => ReaderDialogs.showNewTextDialog(
                  context,
                  ref,
                  _textController.text,
                ),
                onSavedTap: () =>
                    ReaderDialogs.showSavedArticlesSheet(context, ref),
                onThemeTap: () => ThemeSelectorSheet.show(context, themeColors),
                onSaveTap: () => ReaderDialogs.showSaveArticleDialog(
                  context,
                  ref,
                  _textController.text,
                ),
                onFocusTap: () =>
                    ref.read(readingProvider.notifier).toggleFocusMode(),
              ),
          ],
        ),
      ),
    );
  }
}
