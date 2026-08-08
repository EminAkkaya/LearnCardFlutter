import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/audio_helper.dart';
import '../../models/flashcard_model.dart';
import '../../providers/flashcard_provider.dart';
import '../../services/srs_service.dart';

class FlashcardReviewScreen extends ConsumerStatefulWidget {
  final List<FlashcardModel>? customCards;
  final bool isCustomStudy;

  const FlashcardReviewScreen({
    super.key,
    this.customCards,
    this.isCustomStudy = false,
  });

  @override
  ConsumerState<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends ConsumerState<FlashcardReviewScreen> {
  int _currentIndex = 0;
  List<FlashcardModel>? _sessionCards;

  static const Color emerald = Color(0xFF10B981);

  void _handleRating(FlashcardModel card, ReviewRating rating) {
    if (!widget.isCustomStudy) {
      ref.read(flashcardProvider.notifier).reviewCard(card.id, rating);
    }
    setState(() {
      _currentIndex += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardState = ref.watch(flashcardProvider);

    if (cardState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    _sessionCards ??= widget.customCards ?? cardState.dueCards;
    final dueCards = _sessionCards!;

    if (dueCards.isEmpty || _currentIndex >= dueCards.length) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: emerald.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 80,
                    color: emerald,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tebrikler! 🎉',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.isCustomStudy
                      ? 'Özel çalışma seansı tamamlandı!'
                      : 'Bugün gözden geçirilecek tüm kartları başarıyla tamamladın.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (widget.isCustomStudy) {
                      setState(() {
                        _currentIndex = 0;
                      });
                    } else {
                      await ref.read(flashcardProvider.notifier).loadCards();
                      setState(() {
                        _sessionCards = ref.read(flashcardProvider).dueCards;
                        _currentIndex = 0;
                      });
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(widget.isCustomStudy ? 'Aynı Seansı Tekrar Et' : 'Kartları Yeniden Yükle'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                if (widget.isCustomStudy) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Deste Yönetimine Dön'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    final card = dueCards[_currentIndex];
    final previews = SRSService.getNextIntervalPreviews(card);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCustomStudy ? 'Özel Çalışma Modu' : 'Kart Tekrarı (SRS)'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${dueCards.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
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
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: theme.colorScheme.primary,
              minHeight: 6,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: _FlashcardItemView(
                    key: ValueKey<String>('${card.id}_$_currentIndex'),
                    card: card,
                    previews: previews,
                    onRating: (rating) => _handleRating(card, rating),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashcardItemView extends ConsumerStatefulWidget {
  final FlashcardModel card;
  final Map<ReviewRating, String> previews;
  final void Function(ReviewRating rating) onRating;

  const _FlashcardItemView({
    super.key,
    required this.card,
    required this.previews,
    required this.onRating,
  });

  @override
  ConsumerState<_FlashcardItemView> createState() => _FlashcardItemViewState();
}

class _FlashcardItemViewState extends ConsumerState<_FlashcardItemView>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;

  static const Color emerald = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = widget.card;

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final double angle = _flipAnimation.value * pi;
          final isBackVisible = angle >= pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: isBackVisible
                        ? [
                            theme.colorScheme.secondaryContainer,
                            theme.colorScheme.surface,
                          ]
                        : [
                            theme.colorScheme.surface,
                            theme.colorScheme.primaryContainer.withOpacity(0.3),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: isBackVisible
                    ? Transform(
                        transform: Matrix4.identity()..rotateY(pi),
                        alignment: Alignment.center,
                        child: _buildCardBack(card, theme, widget.previews),
                      )
                    : _buildCardFront(card, theme),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardFront(FlashcardModel card, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                card.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          card.word,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        if (card.phonetic.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            card.phonetic,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
        if (card.partOfSpeech.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '(${card.partOfSpeech})',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
        if (card.exampleSentence.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"${card.exampleSentence}"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
        ],
        const Spacer(),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app_rounded, size: 18, color: Colors.grey),
            SizedBox(width: 6),
            Text(
              'Cevap için karta dokunun',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardBack(
    FlashcardModel card,
    ThemeData theme,
    Map<ReviewRating, String> previews,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              card.word,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            if (card.audioUrl.isNotEmpty)
              IconButton.filledTonal(
                onPressed: () => AudioHelper.playAudio(card.audioUrl),
                icon: const Icon(Icons.volume_up_rounded),
              ),
          ],
        ),
        const Divider(height: 24),
        const Spacer(),
        Text(
          'TÜRKÇE ÇEVİRİ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          card.trTranslation.isNotEmpty ? card.trTranslation : 'Çeviri bulunamadı',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (card.definition.isNotEmpty) ...[
          Text(
            'İNGİLİZCE TANIM',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.definition,
            style: const TextStyle(fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
        const Spacer(),
        Text(
          'Hatırlama Kalitesini Seçin',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildRatingBtn(
              label: 'Tekrar',
              days: previews[ReviewRating.again] ?? '',
              color: Colors.red,
              onPressed: () => widget.onRating(ReviewRating.again),
            ),
            const SizedBox(width: 8),
            _buildRatingBtn(
              label: 'Zor',
              days: previews[ReviewRating.hard] ?? '',
              color: Colors.orange,
              onPressed: () => widget.onRating(ReviewRating.hard),
            ),
            const SizedBox(width: 8),
            _buildRatingBtn(
              label: 'İyi',
              days: previews[ReviewRating.good] ?? '',
              color: Colors.blue,
              onPressed: () => widget.onRating(ReviewRating.good),
            ),
            const SizedBox(width: 8),
            _buildRatingBtn(
              label: 'Kolay',
              days: previews[ReviewRating.easy] ?? '',
              color: emerald,
              onPressed: () => widget.onRating(ReviewRating.easy),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingBtn({
    required String label,
    required String days,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                days,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
