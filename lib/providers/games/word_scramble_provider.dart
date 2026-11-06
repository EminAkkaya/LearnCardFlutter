import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../models/games/letter_tile_model.dart';
import 'game_callbacks.dart';
import 'practice_order.dart';

const int scrambleMaxWords = 8;
const int scramblePointsPerWord = 100;
const int scrambleHintPenalty = 20;

/// Türkçe büyük 'İ' Dart'ta küçültülünce iki karaktere bölündüğü için önce
/// düzeltilir; harfler grapheme bazında ayrılır.
String normalizeScrambleWord(String word) =>
    word.trim().replaceAll('İ', 'i').toLowerCase();

/// Tek kelimelik kartlardan karışık oyun destesi seçer.
List<FlashcardModel> pickScrambleCards(List<FlashcardModel> cards) {
  final valid = cards.where((c) => c.word.trim().isNotEmpty && !c.word.contains(' ')).toList();
  return practiceOrder(valid).take(scrambleMaxWords).toList();
}

List<LetterTileModel> buildLetterPool(String word) {
  final chars = word.characters.toList();
  return [for (int i = 0; i < chars.length; i++) LetterTileModel(id: i, char: chars[i])]
    ..shuffle();
}

@immutable
class WordScrambleState {
  /// Yanlış bilinen / atlanan kartların id'leri (oyun sonu tekrar listesi).
  final List<String> missedIds;
  final List<FlashcardModel> cards;
  final int currentIndex;
  final List<LetterTileModel> pool;

  /// Yerleştirilen harflerin [pool] içindeki id'leri, sırasıyla.
  final List<int> placedIds;
  final bool isCompleted;
  final bool hasError;
  final int score;
  final int correctCount;
  final int skippedCount;

  /// Bu kelimede ipucu nedeniyle düşülecek puan; önceki kelimeleri etkilemez.
  final int wordPenalty;

  const WordScrambleState({
    this.cards = const [],
    this.currentIndex = 0,
    this.pool = const [],
    this.placedIds = const [],
    this.isCompleted = false,
    this.hasError = false,
    this.score = 0,
    this.correctCount = 0,
    this.skippedCount = 0,
    this.wordPenalty = 0,
    this.missedIds = const [],
  });


  bool get isFinished => currentIndex >= cards.length;
  bool get hasNext => currentIndex + 1 < cards.length;
  FlashcardModel get currentCard => cards[currentIndex];
  String get targetWord => isFinished ? '' : normalizeScrambleWord(currentCard.word);
  List<String> get targetLetters => targetWord.characters.toList();

  List<LetterTileModel> get placedLetters =>
      [for (final id in placedIds) pool.firstWhere((t) => t.id == id)];

  List<FlashcardModel> get missedCards => [
        for (final id in missedIds) cards.firstWhere((c) => c.id == id),
      ];

  WordScrambleState copyWith({
    int? currentIndex,
    List<LetterTileModel>? pool,
    List<int>? placedIds,
    bool? isCompleted,
    bool? hasError,
    int? score,
    int? correctCount,
    int? skippedCount,
    int? wordPenalty,
    List<String>? missedIds,
  }) {

    return WordScrambleState(
      cards: cards,
      currentIndex: currentIndex ?? this.currentIndex,
      pool: pool ?? this.pool,
      placedIds: placedIds ?? this.placedIds,
      isCompleted: isCompleted ?? this.isCompleted,
      hasError: hasError ?? this.hasError,
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
      skippedCount: skippedCount ?? this.skippedCount,
      wordPenalty: wordPenalty ?? this.wordPenalty,
      missedIds: missedIds ?? this.missedIds,
    );
  }
}

class WordScrambleNotifier extends StateNotifier<WordScrambleState> {
  final List<FlashcardModel> _cards;
  final PlayAudio _playAudio;
  final RecordScore _recordScore;
  bool _recorded = false;

  WordScrambleNotifier(
    this._cards, {
    PlayAudio playAudio = defaultPlayAudio,
    required RecordScore recordScore,
  })  : _playAudio = playAudio,
        _recordScore = recordScore,
        super(const WordScrambleState()) {
    restart();
  }

  void restart() {
    _recorded = false;
    final cards = pickScrambleCards(_cards);
    state = WordScrambleState(cards: cards);
    _setupWord(0);
  }

  void _setupWord(int index) {
    final base = state.copyWith(
      currentIndex: index,
      placedIds: const [],
      isCompleted: false,
      hasError: false,
      wordPenalty: 0,
    );
    state = base.isFinished ? base.copyWith(pool: const []) : base.copyWith(pool: buildLetterPool(base.targetWord));
  }

  List<LetterTileModel> _withPlaced(int id, bool placed) =>
      [for (final t in state.pool) t.id == id ? t.copyWith(isPlaced: placed) : t];

  void placeTile(LetterTileModel tile) {
    if (state.isCompleted || state.isFinished) return;
    final current = state.pool.firstWhere((t) => t.id == tile.id);
    if (current.isPlaced) return;

    state = state.copyWith(pool: _withPlaced(tile.id, true), placedIds: [...state.placedIds, tile.id]);
    if (state.placedIds.length == state.targetLetters.length) _checkAnswer();
  }

  void removeAt(int slotIndex) {
    if (state.isCompleted || slotIndex >= state.placedIds.length) return;
    final id = state.placedIds[slotIndex];
    state = state.copyWith(
      pool: _withPlaced(id, false),
      placedIds: [...state.placedIds]..removeAt(slotIndex),
      hasError: false,
    );
  }

  void clearSlots() {
    if (state.isCompleted) return;
    state = state.copyWith(
      pool: [for (final t in state.pool) t.copyWith(isPlaced: false)],
      placedIds: const [],
      hasError: false,
    );
  }

  void shufflePool() {
    state = state.copyWith(pool: [...state.pool]..shuffle());
  }

  /// Sıradaki doğru harfi yerleştirir. Bu kelimenin ödülünden
  /// [scrambleHintPenalty] düşer; önceki kelimelerin puanı korunur.
  void hint() {
    if (state.isCompleted || state.isFinished) return;
    final letters = state.targetLetters;
    final nextSlot = state.placedIds.length;
    if (nextSlot >= letters.length) return;

    final free = state.pool.where((t) => !t.isPlaced);
    final candidate = free.firstWhere((t) => t.char == letters[nextSlot], orElse: () => free.first);
    state = state.copyWith(
      wordPenalty: (state.wordPenalty + scrambleHintPenalty).clamp(0, scramblePointsPerWord),
      missedIds: _withMissed(state.currentCard.id),
    );
    placeTile(candidate);
  }

  /// Kelimeyi puansız geçer.
  void skip() {
    if (state.isFinished || state.isCompleted) return;
    state = state.copyWith(
      skippedCount: state.skippedCount + 1,
      missedIds: _withMissed(state.currentCard.id),
    );
    _recordIfLast();
    _setupWord(state.currentIndex + 1);
  }

  void _checkAnswer() {
    final attempt = state.placedLetters.map((l) => l.char).join();
    if (attempt != state.targetWord) {
      state = state.copyWith(hasError: true);
      return;
    }
    _playAudio(state.currentCard.audioUrl);
    state = state.copyWith(
      isCompleted: true,
      hasError: false,
      correctCount: state.correctCount + 1,
      score: state.score + scramblePointsPerWord - state.wordPenalty,
    );
    _recordIfLast();
  }

  List<String> _withMissed(String cardId) =>
      state.missedIds.contains(cardId) ? state.missedIds : [...state.missedIds, cardId];

  void _recordIfLast() {
    if (_recorded || state.hasNext) return;
    _recorded = true;
    _recordScore(state.score);
  }

  void next() {
    if (state.isFinished) return;
    _setupWord(state.currentIndex + 1);
  }
}

final wordScrambleProvider = StateNotifierProvider.autoDispose
    .family<WordScrambleNotifier, WordScrambleState, List<FlashcardModel>>((ref, cards) {
  return WordScrambleNotifier(cards, recordScore: statsRecorder(ref));
});
