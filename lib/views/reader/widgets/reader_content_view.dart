import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/text_parser.dart';
import '../../../providers/flashcard_provider.dart';
import '../../../providers/reading_provider.dart';
import '../word_detail_sheet.dart';
import 'reader_paragraph.dart';

class ReaderContentView extends ConsumerStatefulWidget {
  final TextEditingController textController;
  final ScrollController scrollController;
  final ReaderThemeColors colors;
  final bool isFocusMode;
  final ReadingState readingState;

  const ReaderContentView({
    super.key,
    required this.textController,
    required this.scrollController,
    required this.colors,
    required this.isFocusMode,
    required this.readingState,
  });

  @override
  ConsumerState<ReaderContentView> createState() => _ReaderContentViewState();
}

class _ReaderContentViewState extends ConsumerState<ReaderContentView> {
  final GlobalKey _scrollKey = GlobalKey();
  List<String> _paragraphs = [];
  List<GlobalKey> _paragraphKeys = [];

  @override
  void initState() {
    super.initState();
    _updateParagraphs(widget.textController.text);
    _restoreScrollPosition();
  }

  @override
  void didUpdateWidget(covariant ReaderContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textController.text != widget.textController.text) {
      _updateParagraphs(widget.textController.text);
      _restoreScrollPosition();
    }
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
    if (!widget.scrollController.hasClients || _paragraphKeys.isEmpty) return 0;
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
          if (pTop <= 40 && pBottom > 0) return i;
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
    if (!widget.scrollController.hasClients) return;
    final topIndex = _findTopVisibleParagraphIndex();
    final offset = widget.scrollController.offset;
    ref.read(readingProvider.notifier).savePosition(topIndex, offset);
  }

  void _restoreScrollPosition() async {
    final pos = await ref.read(readingProvider.notifier).loadPosition();
    final int paraIndex = pos['paragraphIndex'] ?? 0;
    final double offset = pos['offset'] ?? 0.0;

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.scrollController.hasClients) return;
      if (paraIndex > 0 && paraIndex < _paragraphKeys.length) {
        final ctx = _paragraphKeys[paraIndex].currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(ctx, alignment: 0.0, duration: Duration.zero);
          return;
        }
      }
      if (offset > 0 && offset <= widget.scrollController.position.maxScrollExtent) {
        widget.scrollController.jumpTo(offset);
      }
    });
  }

  void _openWordSheet(String word) {
    final String contextStr = TextParser.extractSentence(
      widget.textController.text,
      word,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WordDetailSheet(word: word, sentenceContext: contextStr),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flashcardCards = ref.watch(
      flashcardProvider.select((state) => state.cards),
    );
    final cardMap = {
      for (final card in flashcardCards) card.word.toLowerCase(): card.status,
    };

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification) {
          _saveCurrentPosition();
        }
        return false;
      },
      child: ListView.builder(
        key: _scrollKey,
        controller: widget.scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: widget.isFocusMode ? 24 : 16,
          vertical: widget.isFocusMode ? 20 : 16,
        ),
        itemCount: _paragraphs.length,
        itemBuilder: (context, index) {
          return ReaderParagraph(
            key: _paragraphKeys.length > index ? _paragraphKeys[index] : null,
            text: _paragraphs[index],
            isFocusMode: widget.isFocusMode,
            cardMap: cardMap,
            colors: widget.colors,
            onWordTap: _openWordSheet,
            fontSize: widget.readingState.fontSize,
            lineHeight: widget.readingState.lineHeight,
          );
        },
      ),
    );
  }
}
