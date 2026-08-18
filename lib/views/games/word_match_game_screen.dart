import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/utils/audio_helper.dart';
import '../../models/flashcard_model.dart';

class _TileItem {
  final String id;
  final String cardId;
  final String text;
  final bool isEnglish;
  final FlashcardModel card;
  bool isMatched = false;
  bool isSelected = false;
  bool isError = false;

  _TileItem({
    required this.id,
    required this.cardId,
    required this.text,
    required this.isEnglish,
    required this.card,
  });
}

class WordMatchGameScreen extends StatefulWidget {
  final List<FlashcardModel> cards;

  const WordMatchGameScreen({super.key, required this.cards});

  @override
  State<WordMatchGameScreen> createState() => _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends State<WordMatchGameScreen> {
  static const int pairsCount = 6;
  List<_TileItem> _tiles = [];
  _TileItem? _firstSelected;
  bool _isChecking = false;

  int _score = 0;
  int _streak = 0;
  int _mistakes = 0;
  int _matchedPairs = 0;

  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    _timer?.cancel();
    _secondsElapsed = 0;
    _isGameOver = false;
    _firstSelected = null;
    _isChecking = false;
    _score = 0;
    _streak = 0;
    _mistakes = 0;
    _matchedPairs = 0;

    // Pick random subset of cards
    final List<FlashcardModel> shuffledCards = List.from(widget.cards)..shuffle();
    final count = min(pairsCount, shuffledCards.length);
    final selectedPool = shuffledCards.sublist(0, count);

    final List<_TileItem> tiles = [];
    for (final card in selectedPool) {
      tiles.add(_TileItem(
        id: '${card.id}_en',
        cardId: card.id,
        text: card.word,
        isEnglish: true,
        card: card,
      ));
      tiles.add(_TileItem(
        id: '${card.id}_tr',
        cardId: card.id,
        text: card.trTranslation.isNotEmpty ? card.trTranslation : card.definition,
        isEnglish: false,
        card: card,
      ));
    }
    tiles.shuffle();

    setState(() {
      _tiles = tiles;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isGameOver) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _onTileTapped(_TileItem tile) async {
    if (_isChecking || tile.isMatched || tile.isSelected) return;

    setState(() {
      tile.isSelected = true;
    });

    if (_firstSelected == null) {
      _firstSelected = tile;
    } else {
      _isChecking = true;
      final secondSelected = tile;

      // Check if match
      final bool isMatch = (_firstSelected!.cardId == secondSelected.cardId) &&
          (_firstSelected!.isEnglish != secondSelected.isEnglish);

      if (isMatch) {
        // Play audio if English card has audio
        final enCard = _firstSelected!.isEnglish ? _firstSelected!.card : secondSelected.card;
        if (enCard.audioUrl.isNotEmpty) {
          AudioHelper.playAudio(enCard.audioUrl);
        }

        setState(() {
          _firstSelected!.isMatched = true;
          secondSelected.isMatched = true;
          _firstSelected!.isSelected = false;
          secondSelected.isSelected = false;
          _matchedPairs++;
          _streak++;
          _score += 100 + (_streak * 20);
          _firstSelected = null;
          _isChecking = false;
        });

        // Check if game won
        if (_matchedPairs >= _tiles.length ~/ 2) {
          _timer?.cancel();
          setState(() {
            _isGameOver = true;
          });
        }
      } else {
        // Mismatch feedback
        setState(() {
          _firstSelected!.isError = true;
          secondSelected.isError = true;
          _streak = 0;
          _mistakes++;
        });

        await Future.delayed(const Duration(milliseconds: 650));
        if (mounted) {
          setState(() {
            _firstSelected?.isSelected = false;
            _firstSelected?.isError = false;
            secondSelected.isSelected = false;
            secondSelected.isError = false;
            _firstSelected = null;
            _isChecking = false;
          });
        }
      }
    }
  }

  String _formatTime(int totalSecs) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Eşleştirme'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yeniden Başlat',
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status HUD Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHudItem(
                    icon: Icons.timer_outlined,
                    label: 'Süre',
                    value: _formatTime(_secondsElapsed),
                    color: Colors.blueAccent,
                  ),
                  _buildHudItem(
                    icon: Icons.stars_rounded,
                    label: 'Puan',
                    value: '$_score',
                    color: Colors.amber,
                  ),
                  _buildHudItem(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Seri',
                    value: '${_streak}x',
                    color: Colors.deepOrangeAccent,
                  ),
                  _buildHudItem(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Eşleşen',
                    value: '$_matchedPairs/${_tiles.length ~/ 2}',
                    color: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Game Board Grid
            Expanded(
              child: _isGameOver
                  ? _buildGameOverView(context)
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: GridView.builder(
                        itemCount: _tiles.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.2,
                        ),
                        itemBuilder: (context, index) {
                          final tile = _tiles[index];
                          return _buildTileWidget(context, tile);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHudItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTileWidget(BuildContext context, _TileItem tile) {
    final theme = Theme.of(context);

    Color bg;
    Color border;
    Color textColor;

    if (tile.isMatched) {
      bg = const Color(0xFF10B981).withValues(alpha: 0.12);
      border = const Color(0xFF10B981).withValues(alpha: 0.3);
      textColor = Colors.grey;
    } else if (tile.isError) {
      bg = Colors.redAccent.withValues(alpha: 0.2);
      border = Colors.redAccent;
      textColor = Colors.redAccent;
    } else if (tile.isSelected) {
      bg = theme.colorScheme.primary.withValues(alpha: 0.25);
      border = theme.colorScheme.primary;
      textColor = theme.colorScheme.primary;
    } else {
      bg = theme.colorScheme.surface;
      border = theme.dividerColor.withValues(alpha: 0.4);
      textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: tile.isMatched ? null : () => _onTileTapped(tile),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: tile.isSelected ? 2 : 1),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (tile.isMatched) ...[
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    tile.text,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: tile.isEnglish ? FontWeight.bold : FontWeight.w500,
                      color: textColor,
                      decoration: tile.isMatched ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverView(BuildContext context) {
    final theme = Theme.of(context);
    const emerald = Color(0xFF10B981);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: emerald.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 72,
                color: emerald,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Harika İş!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tüm kelime eşleştirmelerini başarıyla tamamladınız.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Results Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    _buildResultRow('Toplam Puan', '$_score', Colors.amber),
                    const Divider(height: 16),
                    _buildResultRow('Tamamlanma Süresi', _formatTime(_secondsElapsed), Colors.blueAccent),
                    const Divider(height: 16),
                    _buildResultRow('Hata Sayısı', '$_mistakes', _mistakes == 0 ? emerald : Colors.orange),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _startNewGame,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Yeni Kelimelerle Oyna'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: emerald,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Oyun Merkezine Dön'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
