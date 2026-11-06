import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/audio_helper.dart';
import '../../models/flashcard_model.dart';
import '../../providers/stats_provider.dart';
import 'widgets/letter_tile_model.dart';
import 'widgets/scramble_clue_card.dart';
import 'widgets/scramble_control_buttons.dart';
import 'widgets/scramble_letter_pool.dart';
import 'widgets/scramble_placement_slots.dart';
import 'widgets/scramble_success_banner.dart';
import 'widgets/scramble_summary_view.dart';

class WordScrambleGameScreen extends ConsumerStatefulWidget {
  final List<FlashcardModel> cards;

  const WordScrambleGameScreen({super.key, required this.cards});

  @override
  ConsumerState<WordScrambleGameScreen> createState() => _WordScrambleGameScreenState();
}

class _WordScrambleGameScreenState extends ConsumerState<WordScrambleGameScreen> {
  List<FlashcardModel> _gameCards = [];
  int _currentIndex = 0;

  String _targetWord = '';
  List<LetterTileModel> _letterPool = [];
  List<LetterTileModel> _placedLetters = [];

  bool _isCompleted = false;
  bool _hasError = false;
  int _score = 0;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _startNewSession();
  }

  void _startNewSession() {
    final validCards = widget.cards
        .where((c) => c.word.trim().isNotEmpty && !c.word.contains(' '))
        .toList()..shuffle();

    _gameCards = validCards.take(8).toList();
    _currentIndex = 0;
    _score = 0;
    _correctCount = 0;
    _setupCurrentWord();
  }

  void _setupCurrentWord() {
    if (_currentIndex >= _gameCards.length) return;

    final card = _gameCards[_currentIndex];
    _targetWord = card.word.trim().toLowerCase();

    final List<LetterTileModel> tiles = [];
    final chars = _targetWord.split('');
    for (int i = 0; i < chars.length; i++) {
      tiles.add(LetterTileModel(id: i, char: chars[i]));
    }
    tiles.shuffle();

    setState(() {
      _letterPool = tiles;
      _placedLetters = [];
      _isCompleted = false;
      _hasError = false;
    });
  }

  void _onTileTapped(LetterTileModel tile) {
    if (_isCompleted) return;

    setState(() {
      tile.isPlaced = true;
      _placedLetters.add(tile);
    });

    if (_placedLetters.length == _targetWord.length) {
      _checkAnswer();
    }
  }

  void _onSlotTapped(int index) {
    if (_isCompleted || index >= _placedLetters.length) return;

    final removed = _placedLetters.removeAt(index);
    setState(() {
      removed.isPlaced = false;
      _hasError = false;
    });
  }

  void _clearAllSlots() {
    setState(() {
      for (final l in _placedLetters) {
        l.isPlaced = false;
      }
      _placedLetters.clear();
      _hasError = false;
    });
  }

  void _shufflePool() {
    setState(() {
      _letterPool.shuffle();
    });
  }

  void _getHint() {
    if (_isCompleted) return;
    final int nextSlotIndex = _placedLetters.length;
    if (nextSlotIndex >= _targetWord.length) return;

    final expectedChar = _targetWord[nextSlotIndex];
    final candidate = _letterPool.firstWhere(
      (t) => !t.isPlaced && t.char == expectedChar,
      orElse: () => _letterPool.firstWhere((t) => !t.isPlaced),
    );

    _onTileTapped(candidate);
    _score = (_score - 20).clamp(0, 99999);
  }

  void _checkAnswer() {
    final currentAttempt = _placedLetters.map((l) => l.char).join();
    if (currentAttempt == _targetWord) {
      final card = _gameCards[_currentIndex];
      if (card.audioUrl.isNotEmpty) AudioHelper.playAudio(card.audioUrl);
      setState(() {
        _isCompleted = true;
        _hasError = false;
        _correctCount++;
        _score += 100;
      });
    } else {
      setState(() => _hasError = true);
    }
  }

  void _nextWord() {
    if (_currentIndex + 1 < _gameCards.length) {
      setState(() {
        _currentIndex++;
        _setupCurrentWord();
      });
    } else {
      ref.read(statsProvider.notifier).recordGameScore(_score);
      setState(() => _currentIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_gameCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Harf Sihirbazı')),
        body: const Center(child: Text('Çalışılacak uygun kelime bulunamadı.')),
      );
    }

    if (_currentIndex >= _gameCards.length) {
      return ScrambleSummaryView(
        totalQuestions: _gameCards.length,
        correctCount: _correctCount,
        score: _score,
        onRestart: _startNewSession,
      );
    }

    final card = _gameCards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Harf Sihirbazı'),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_currentIndex + 1}/${_gameCards.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Puan: $_score',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  Text(
                    'Kelime Uzunluğu: ${_targetWord.length} Harf',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ScrambleClueCard(card: card),
              const SizedBox(height: 28),
              ScramblePlacementSlots(
                targetLength: _targetWord.length,
                placedLetters: _placedLetters,
                isCompleted: _isCompleted,
                hasError: _hasError,
                onSlotTapped: _onSlotTapped,
              ),
              const SizedBox(height: 28),
              if (!_isCompleted) ...[
                ScrambleLetterPool(
                  pool: _letterPool,
                  isCompleted: _isCompleted,
                  onTileTapped: _onTileTapped,
                ),
                const SizedBox(height: 24),
                ScrambleControlButtons(
                  isCompleted: _isCompleted,
                  hasPlacedLetters: _placedLetters.isNotEmpty,
                  onClear: _clearAllSlots,
                  onHint: _getHint,
                  onShuffle: _shufflePool,
                ),
              ],
              if (_isCompleted) ...[
                const SizedBox(height: 16),
                ScrambleSuccessBanner(
                  card: card,
                  hasNext: _currentIndex + 1 < _gameCards.length,
                  onNext: _nextWord,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
