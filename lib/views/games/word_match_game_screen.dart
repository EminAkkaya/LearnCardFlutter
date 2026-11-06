import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/audio_helper.dart';
import '../../models/flashcard_model.dart';
import '../../providers/stats_provider.dart';
import 'widgets/word_match_game_over_view.dart';
import 'widgets/word_match_hud_bar.dart';
import 'widgets/word_match_tile.dart';
import 'widgets/word_match_tile_model.dart';

class WordMatchGameScreen extends ConsumerStatefulWidget {
  final List<FlashcardModel> cards;

  const WordMatchGameScreen({super.key, required this.cards});

  @override
  ConsumerState<WordMatchGameScreen> createState() => _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends ConsumerState<WordMatchGameScreen> {
  List<WordMatchTileModel> _tiles = [];
  WordMatchTileModel? _firstSelected;
  bool _isLocked = false;

  int _score = 0;
  int _streak = 0;
  int _mistakes = 0;
  int _matchedPairs = 0;
  int _totalPairs = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    final List<FlashcardModel> pool = List.from(widget.cards)..shuffle();
    final List<FlashcardModel> selectedCards = pool.take(6).toList();
    _totalPairs = selectedCards.length;

    final List<WordMatchTileModel> tileList = [];
    for (final card in selectedCards) {
      tileList.add(WordMatchTileModel(
        id: '${card.id}_en',
        cardId: card.id,
        text: card.word,
        isEnglish: true,
        card: card,
      ));
      tileList.add(WordMatchTileModel(
        id: '${card.id}_tr',
        cardId: card.id,
        text: card.trTranslation.isNotEmpty ? card.trTranslation : card.definition,
        isEnglish: false,
        card: card,
      ));
    }

    tileList.shuffle();

    setState(() {
      _tiles = tileList;
      _firstSelected = null;
      _isLocked = false;
      _score = 0;
      _streak = 0;
      _mistakes = 0;
      _matchedPairs = 0;
      _isGameOver = false;
    });
  }

  void _onTileTap(WordMatchTileModel tile) {
    if (_isLocked || tile.isMatched || tile.isSelected) return;

    setState(() => tile.isSelected = true);

    if (_firstSelected == null) {
      _firstSelected = tile;
      return;
    }

    final first = _firstSelected!;
    if (first.cardId == tile.cardId && first.isEnglish != tile.isEnglish) {
      final audioCard = first.isEnglish ? first.card : tile.card;
      if (audioCard.audioUrl.isNotEmpty) AudioHelper.playAudio(audioCard.audioUrl);

      setState(() {
        first.isMatched = true;
        tile.isMatched = true;
        first.isSelected = false;
        tile.isSelected = false;
        _firstSelected = null;
        _matchedPairs++;
        _streak++;
        _score += 100 * _streak;
      });

      if (_matchedPairs == _totalPairs) {
        ref.read(statsProvider.notifier).recordGameScore(_score);
        Timer(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _isGameOver = true);
        });
      }
    } else {
      setState(() {
        _isLocked = true;
        first.isError = true;
        tile.isError = true;
        _mistakes++;
        _streak = 0;
      });

      Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            first.isSelected = false;
            tile.isSelected = false;
            first.isError = false;
            tile.isError = false;
            _firstSelected = null;
            _isLocked = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tiles.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kelime Eşleştirme')),
        body: const Center(child: Text('Eşleştirilecek kart bulunamadı.')),
      );
    }

    if (_isGameOver) {
      return WordMatchGameOverView(
        totalPairs: _totalPairs,
        score: _score,
        mistakes: _mistakes,
        onPlayAgain: _startNewGame,
      );
    }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              WordMatchHudBar(
                matchedPairs: _matchedPairs,
                totalPairs: _totalPairs,
                score: _score,
                mistakes: _mistakes,
                streak: _streak,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.1,
                  ),
                  itemCount: _tiles.length,
                  itemBuilder: (context, index) {
                    final tile = _tiles[index];
                    return WordMatchTile(
                      tile: tile,
                      onTap: () => _onTileTap(tile),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
