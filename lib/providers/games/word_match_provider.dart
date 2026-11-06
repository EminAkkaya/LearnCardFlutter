import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../models/games/word_match_tile_model.dart';
import 'game_callbacks.dart';

const int wordMatchMaxPairs = 6;
const int wordMatchPairPoints = 100;
const int wordMatchMaxMultiplier = 3;
const int wordMatchMistakePenalty = 25;

String _meaningOf(FlashcardModel c) =>
    (c.trTranslation.trim().isNotEmpty ? c.trTranslation : c.definition).trim();

/// Her kart için bir EN ve bir anlam kutucuğu üretip karıştırır.
///
/// Aynı kelimeye veya aynı anlama sahip ikinci kart oyuna alınmaz; aksi hâlde
/// ekranda birebir aynı iki kutucuk çıkar ve doğru eşleşme hata sayılır.
List<WordMatchTileModel> buildWordMatchTiles(List<FlashcardModel> cards) {
  final seenWords = <String>{};
  final seenMeanings = <String>{};
  final selected = <FlashcardModel>[];
  for (final card in List<FlashcardModel>.from(cards)..shuffle()) {
    if (selected.length >= wordMatchMaxPairs) break;
    final word = card.word.trim().toLowerCase();
    final meaning = _meaningOf(card).toLowerCase();
    if (word.isEmpty || meaning.isEmpty) continue;
    if (!seenWords.add(word) || !seenMeanings.add(meaning)) continue;
    selected.add(card);
  }

  return [
    for (final card in selected) ...[
      WordMatchTileModel(
        id: '${card.id}_en',
        cardId: card.id,
        text: card.word.trim(),
        isEnglish: true,
        label: 'EN',
        card: card,
      ),
      WordMatchTileModel(
        id: '${card.id}_tr',
        cardId: card.id,
        text: _meaningOf(card),
        isEnglish: false,
        label: card.trTranslation.trim().isNotEmpty ? 'TR' : 'TANIM',
        card: card,
      ),
    ],
  ]..shuffle();
}

@immutable
class WordMatchState {
  final List<WordMatchTileModel> tiles;
  final String? firstSelectedId;
  final bool isLocked;
  final int score;
  final int streak;
  final int mistakes;
  final int matchedPairs;
  final bool isGameOver;

  const WordMatchState({
    this.tiles = const [],
    this.firstSelectedId,
    this.isLocked = false,
    this.score = 0,
    this.streak = 0,
    this.mistakes = 0,
    this.matchedPairs = 0,
    this.isGameOver = false,
  });

  int get totalPairs => tiles.length ~/ 2;

  WordMatchState copyWith({
    List<WordMatchTileModel>? tiles,
    String? Function()? firstSelectedId,
    bool? isLocked,
    int? score,
    int? streak,
    int? mistakes,
    int? matchedPairs,
    bool? isGameOver,
  }) {
    return WordMatchState(
      tiles: tiles ?? this.tiles,
      firstSelectedId: firstSelectedId != null ? firstSelectedId() : this.firstSelectedId,
      isLocked: isLocked ?? this.isLocked,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      mistakes: mistakes ?? this.mistakes,
      matchedPairs: matchedPairs ?? this.matchedPairs,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}

class WordMatchNotifier extends StateNotifier<WordMatchState> {
  final List<FlashcardModel> _cards;
  final PlayAudio _playAudio;
  final RecordScore _recordScore;
  final Duration _mismatchDelay;
  final Duration _gameOverDelay;
  Timer? _pending;

  WordMatchNotifier(
    this._cards, {
    PlayAudio playAudio = defaultPlayAudio,
    required RecordScore recordScore,
    Duration mismatchDelay = const Duration(milliseconds: 800),
    Duration gameOverDelay = const Duration(milliseconds: 600),
  })  : _playAudio = playAudio,
        _recordScore = recordScore,
        _mismatchDelay = mismatchDelay,
        _gameOverDelay = gameOverDelay,
        super(const WordMatchState()) {
    restart();
  }

  void restart() {
    _pending?.cancel();
    state = WordMatchState(tiles: buildWordMatchTiles(_cards));
  }

  List<WordMatchTileModel> _update(
    Set<String> ids,
    WordMatchTileModel Function(WordMatchTileModel) change,
  ) =>
      [for (final t in state.tiles) ids.contains(t.id) ? change(t) : t];

  void tapTile(String tileId) {
    final tile = state.tiles.firstWhere((t) => t.id == tileId);
    if (state.isLocked || state.isGameOver || tile.isMatched || tile.isSelected) return;

    final firstId = state.firstSelectedId;
    if (firstId == null) {
      state = state.copyWith(
        tiles: _update({tileId}, (t) => t.copyWith(isSelected: true)),
        firstSelectedId: () => tileId,
      );
      return;
    }

    final first = state.tiles.firstWhere((t) => t.id == firstId);
    final ids = {firstId, tileId};
    final isMatch = first.cardId == tile.cardId && first.isEnglish != tile.isEnglish;
    isMatch ? _onMatch(first, tile, ids) : _onMismatch(ids);
  }

  void _onMatch(WordMatchTileModel first, WordMatchTileModel second, Set<String> ids) {
    _playAudio((first.isEnglish ? first.card : second.card).audioUrl);
    final streak = state.streak + 1;
    state = state.copyWith(
      tiles: _update(ids, (t) => t.copyWith(isMatched: true, isSelected: false)),
      firstSelectedId: () => null,
      matchedPairs: state.matchedPairs + 1,
      streak: streak,
      score: state.score + wordMatchPairPoints * streak.clamp(1, wordMatchMaxMultiplier),
    );

    if (state.matchedPairs == state.totalPairs) {
      _recordScore(state.score);
      _pending = Timer(_gameOverDelay, () {
        if (mounted) state = state.copyWith(isGameOver: true);
      });
    }
  }

  void _onMismatch(Set<String> ids) {
    state = state.copyWith(
      tiles: _update(ids, (t) => t.copyWith(isSelected: true, isError: true)),
      isLocked: true,
      mistakes: state.mistakes + 1,
      streak: 0,
      score: (state.score - wordMatchMistakePenalty).clamp(0, 1 << 30),
    );
    _pending = Timer(_mismatchDelay, () {
      if (!mounted) return;
      state = state.copyWith(
        tiles: _update(ids, (t) => t.copyWith(isSelected: false, isError: false)),
        firstSelectedId: () => null,
        isLocked: false,
      );
    });
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }
}

final wordMatchProvider = StateNotifierProvider.autoDispose
    .family<WordMatchNotifier, WordMatchState, List<FlashcardModel>>((ref, cards) {
  return WordMatchNotifier(cards, recordScore: statsRecorder(ref));
});
