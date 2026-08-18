import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/utils/audio_helper.dart';
import '../../models/flashcard_model.dart';

class _LetterTile {
  final int originalIndex;
  final String char;
  bool isUsed = false;

  _LetterTile({
    required this.originalIndex,
    required this.char,
  });
}

class WordScrambleGameScreen extends StatefulWidget {
  final List<FlashcardModel> cards;

  const WordScrambleGameScreen({super.key, required this.cards});

  @override
  State<WordScrambleGameScreen> createState() => _WordScrambleGameScreenState();
}

class _WordScrambleGameScreenState extends State<WordScrambleGameScreen> {
  late List<FlashcardModel> _sessionCards;
  int _currentIndex = 0;

  List<_LetterTile> _letterPool = [];
  List<_LetterTile?> _placedLetters = [];

  bool _isSuccess = false;
  bool _showErrorFlash = false;
  int _score = 0;
  int _hintsUsed = 0;

  @override
  void initState() {
    super.initState();
    _sessionCards = List.from(widget.cards)..shuffle();
    if (_sessionCards.length > 10) {
      _sessionCards = _sessionCards.sublist(0, 10);
    }
    _setupCurrentWord();
  }

  void _setupCurrentWord() {
    if (_sessionCards.isEmpty || _currentIndex >= _sessionCards.length) return;

    final card = _sessionCards[_currentIndex];
    final cleanWord = card.word.trim().toUpperCase();

    final List<_LetterTile> pool = [];
    for (int i = 0; i < cleanWord.length; i++) {
      pool.add(_LetterTile(originalIndex: i, char: cleanWord[i]));
    }

    // Shuffle pool until it doesn't match original if length > 2
    int attempts = 0;
    while (attempts < 10 && cleanWord.length > 2) {
      pool.shuffle();
      final currentStr = pool.map((e) => e.char).join();
      if (currentStr != cleanWord) break;
      attempts++;
    }

    setState(() {
      _letterPool = pool;
      _placedLetters = List.filled(cleanWord.length, null);
      _isSuccess = false;
      _showErrorFlash = false;
    });
  }

  void _onLetterPoolTapped(_LetterTile tile) {
    if (tile.isUsed || _isSuccess) return;

    // Find first empty slot
    final emptyIndex = _placedLetters.indexOf(null);
    if (emptyIndex == -1) return;

    setState(() {
      tile.isUsed = true;
      _placedLetters[emptyIndex] = tile;
    });

    _checkWord();
  }

  void _onPlacedSlotTapped(int index) {
    if (_isSuccess) return;
    final tile = _placedLetters[index];
    if (tile == null) return;

    setState(() {
      tile.isUsed = false;
      _placedLetters[index] = null;
    });
  }

  void _checkWord() {
    final bool allFilled = !_placedLetters.contains(null);
    if (!allFilled) return;

    final currentWord = _placedLetters.map((e) => e!.char).join();
    final targetWord = _sessionCards[_currentIndex].word.trim().toUpperCase();

    if (currentWord == targetWord) {
      final card = _sessionCards[_currentIndex];
      if (card.audioUrl.isNotEmpty) {
        AudioHelper.playAudio(card.audioUrl);
      }
      setState(() {
        _isSuccess = true;
        _score += max(20, 100 - (_hintsUsed * 25));
        _hintsUsed = 0;
      });
    } else {
      // Wrong word feedback
      setState(() {
        _showErrorFlash = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showErrorFlash = false;
          });
        }
      });
    }
  }

  void _giveHint() {
    if (_isSuccess) return;
    final targetWord = _sessionCards[_currentIndex].word.trim().toUpperCase();

    // Find first slot where letter is missing or wrong
    int targetSlot = -1;
    for (int i = 0; i < targetWord.length; i++) {
      if (_placedLetters[i] == null || _placedLetters[i]!.char != targetWord[i]) {
        targetSlot = i;
        break;
      }
    }

    if (targetSlot == -1) return;

    // If something was already placed there, return it
    if (_placedLetters[targetSlot] != null) {
      _placedLetters[targetSlot]!.isUsed = false;
      _placedLetters[targetSlot] = null;
    }

    // Find an unplaced tile that matches targetWord[targetSlot]
    _LetterTile? matchingTile;
    for (final tile in _letterPool) {
      if (!tile.isUsed && tile.char == targetWord[targetSlot]) {
        matchingTile = tile;
        break;
      }
    }

    // If all matching tiles are already placed in other wrong positions, pull one
    if (matchingTile == null) {
      for (int i = 0; i < _placedLetters.length; i++) {
        if (_placedLetters[i] != null && _placedLetters[i]!.char == targetWord[targetSlot]) {
          matchingTile = _placedLetters[i];
          _placedLetters[i] = null;
          break;
        }
      }
    }

    if (matchingTile != null) {
      setState(() {
        matchingTile!.isUsed = true;
        _placedLetters[targetSlot] = matchingTile;
        _hintsUsed++;
      });
      _checkWord();
    }
  }

  void _clearAll() {
    if (_isSuccess) return;
    setState(() {
      for (final tile in _letterPool) {
        tile.isUsed = false;
      }
      _placedLetters = List.filled(_placedLetters.length, null);
    });
  }

  void _shufflePool() {
    if (_isSuccess) return;
    setState(() {
      final unplaced = _letterPool.where((e) => !e.isUsed).toList()..shuffle();
      int unplacedIdx = 0;
      for (int i = 0; i < _letterPool.length; i++) {
        if (!_letterPool[i].isUsed) {
          _letterPool[i] = unplaced[unplacedIdx++];
        }
      }
    });
  }

  void _nextWord() {
    if (_currentIndex + 1 < _sessionCards.length) {
      setState(() {
        _currentIndex++;
      });
      _setupCurrentWord();
    } else {
      // Finished all words
      setState(() {
        _currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_sessionCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Harf Sihirbazı')),
        body: const Center(child: Text('Çalışılacak kelime bulunamadı.')),
      );
    }

    if (_currentIndex >= _sessionCards.length) {
      return _buildSummaryScreen(context);
    }

    final card = _sessionCards[_currentIndex];
    const emerald = Color(0xFF10B981);

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
                  '${_currentIndex + 1}/${_sessionCards.length}',
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
        child: Column(
          children: [
            // Score & Progress Bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _sessionCards.length,
              color: const Color(0xFF6366F1),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              minHeight: 4,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Meaning Clue Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              'TÜRKÇE ANLAMI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              card.trTranslation.isNotEmpty
                                  ? card.trTranslation
                                  : card.definition,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (card.partOfSpeech.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '(${card.partOfSpeech})',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                            if (card.exampleSentence.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '"${card.exampleSentence}"',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Target Word Placement Slots
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(_placedLetters.length, (index) {
                        final tile = _placedLetters[index];
                        final isFilled = tile != null;

                        Color slotBg;
                        Color slotBorder;

                        if (_isSuccess) {
                          slotBg = emerald.withValues(alpha: 0.2);
                          slotBorder = emerald;
                        } else if (_showErrorFlash) {
                          slotBg = Colors.redAccent.withValues(alpha: 0.2);
                          slotBorder = Colors.redAccent;
                        } else if (isFilled) {
                          slotBg = theme.colorScheme.primaryContainer;
                          slotBorder = theme.colorScheme.primary;
                        } else {
                          slotBg = theme.colorScheme.surface;
                          slotBorder = theme.dividerColor;
                        }

                        return InkWell(
                          onTap: isFilled ? () => _onPlacedSlotTapped(index) : null,
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 52,
                            decoration: BoxDecoration(
                              color: slotBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: slotBorder, width: isFilled ? 2 : 1),
                              boxShadow: isFilled
                                  ? [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isFilled ? tile.char : '_',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _isSuccess
                                    ? emerald
                                    : (isFilled ? theme.colorScheme.primary : Colors.grey),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    // Scrambled Available Letters Pool
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: _letterPool.map((tile) {
                        return Opacity(
                          opacity: tile.isUsed ? 0.25 : 1.0,
                          child: InkWell(
                            onTap: tile.isUsed ? null : () => _onLetterPoolTapped(tile),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                                ),
                                boxShadow: [
                                  if (!tile.isUsed)
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                tile.char,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    // Control Buttons (Hint, Reset, Shuffle)
                    if (!_isSuccess)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _giveHint,
                            icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                            label: const Text('İpucu'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _shufflePool,
                            icon: const Icon(Icons.shuffle_rounded, size: 18),
                            label: const Text('Karıştır'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _clearAll,
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            label: const Text('Temizle'),
                          ),
                        ],
                      ),

                    // Success Next Button
                    if (_isSuccess) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: emerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: emerald.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: emerald),
                            const SizedBox(width: 8),
                            Text(
                              'Tebrikler! (${card.word.toUpperCase()})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: emerald,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _nextWord,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: Text(
                            _currentIndex + 1 < _sessionCards.length
                                ? 'Sonraki Kelime'
                                : 'Sonuçları Gör',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: emerald,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryScreen(BuildContext context) {
    final theme = Theme.of(context);
    const emerald = Color(0xFF10B981);

    return Scaffold(
      appBar: AppBar(title: const Text('Oyun Tamamlandı')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 72,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tüm Kelimeler Çözüldü!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toplam ${_sessionCards.length} kelimenin harf dizilimini başarıyla tamamladınız.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Kazanılan Puan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            '$_score',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Kelime Sayısı', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            '${_sessionCards.length}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: emerald),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                      _score = 0;
                      _sessionCards.shuffle();
                      _setupCurrentWord();
                    });
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Yeni Kelimelerle Tekrar Oyna'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
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
      ),
    );
  }
}
