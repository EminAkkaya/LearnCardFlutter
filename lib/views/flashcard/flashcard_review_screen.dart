import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_palette.dart';
import '../../models/flashcard_model.dart';
import '../../providers/flashcard_provider.dart';
import '../../services/srs_service.dart';
import 'dialogs/exit_review_dialog.dart';
import 'widgets/flashcard_item_view.dart';
import 'widgets/review_completion_view.dart';

class FlashcardReviewScreen extends ConsumerStatefulWidget {
  final List<FlashcardModel>? customCards;
  final bool isCustomStudy;

  const FlashcardReviewScreen({
    super.key,
    this.customCards,
    this.isCustomStudy = false,
  });

  @override
  ConsumerState<FlashcardReviewScreen> createState() =>
      _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends ConsumerState<FlashcardReviewScreen> {
  int _currentIndex = 0;
  List<FlashcardModel>? _sessionCards;

  void _handleRating(FlashcardModel card, ReviewRating rating) {
    if (!widget.isCustomStudy) {
      ref.read(flashcardProvider.notifier).reviewCard(card.id, rating);
    }
    setState(() => _currentIndex += 1);
  }

  Future<void> _handleUndo() async {
    if (!widget.isCustomStudy) {
      final undone = await ref
          .read(flashcardProvider.notifier)
          .undoLastReview();
      if (!undone) return;
    }
    if (mounted) setState(() => _currentIndex -= 1);
  }

  bool get _canUndo =>
      _currentIndex > 0 &&
      (widget.isCustomStudy ||
          ref.read(flashcardProvider.notifier).canUndoReview);

  void _handleRestart() async {
    if (widget.isCustomStudy) {
      setState(() => _currentIndex = 0);
    } else {
      await ref.read(flashcardProvider.notifier).loadCards();
      setState(() {
        _sessionCards = ref.read(flashcardProvider).dueCards;
        _currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final cardState = ref.watch(flashcardProvider);

    if (cardState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Oturum kartları bir kez sabitlenir. Yalnız oturum hiç başlamamışken ve
    // kartlar sonradan yüklendiyse yeniden alınır; bitişte otomatik başa sarılmaz
    // (yeni vadesi gelenler için tamamlama ekranındaki "tekrar başlat" kullanılır).
    final notStarted = _currentIndex == 0 && (_sessionCards?.isEmpty ?? true);
    if (notStarted) {
      _sessionCards = widget.customCards ?? cardState.dueCards;
    }
    final dueCards = _sessionCards ?? [];

    if (dueCards.isEmpty || _currentIndex >= dueCards.length) {
      return ReviewCompletionView(
        isCustomStudy: widget.isCustomStudy,
        onRestart: _handleRestart,
      );
    }

    final card = dueCards[_currentIndex];
    final previews = SRSService.getNextIntervalPreviews(card);

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await ExitReviewDialog.confirm(
          context,
          remaining: dueCards.length - _currentIndex,
        )) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isCustomStudy ? 'Özel Çalışma Modu' : 'Kart Tekrarı (SRS)',
          ),
          centerTitle: true,
          actions: [
            if (_canUndo)
              IconButton(
                tooltip: 'Son cevabı geri al',
                icon: const Icon(LucideIcons.undo2, size: 20),
                onPressed: _handleUndo,
              ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: palette.subtle,
                    borderRadius: BorderRadius.circular(AppPalette.radiusPill),
                    border: Border.all(color: palette.border),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${dueCards.length}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: palette.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / dueCards.length,
                backgroundColor: palette.border,
                color: theme.colorScheme.primary,
                minHeight: 4,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  // Altta boşluk: kart alt çubuğa yapışmaz, gözle biraz yukarıda durur.
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  child: FlashcardItemView(
                    key: ValueKey<String>('${card.id}_$_currentIndex'),
                    card: card,
                    previews: previews,
                    onRating: (rating) => _handleRating(card, rating),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
