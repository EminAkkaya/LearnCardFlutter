import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../models/games/cloze_question_model.dart';
import 'game_callbacks.dart';
import 'practice_order.dart';

const int clozeMaxQuestions = 10;
const int clozePointsNoHint = 100;
const int clozePointsWithHint = 60;

const int clozeMaxOptions = 4;
const int clozeMinOptions = 3;

/// Kelimenin çekimli hâllerini yakalar; ek boşluğun dışında kalır ("walk|ed").
RegExp _wordPattern(String target) => RegExp(
      r'\b(' + RegExp.escape(target) + r')(s|es|ed|d|ing|ly|er|est)?\b',
      caseSensitive: false,
    );

String _sentenceFor(FlashcardModel card, String target) {
  final s = card.exampleSentence.trim();
  if (s.isNotEmpty) return s;
  if (card.definition.isNotEmpty) {
    return 'It means: ${card.definition}. The key word is $target.';
  }
  return 'Understanding the word $target is essential for communication.';
}

/// Kartların örnek cümlelerinden boşluk doldurma soruları üretir.
///
/// Cümlede kelimesi bulunamayan veya desteden en az [clozeMinOptions] - 1
/// çeldirici çıkarılamayan kart atlanır; sahte cümle/kelime üretilmez.
List<ClozeQuestionModel> buildClozeQuestions(List<FlashcardModel> cards) {
  final pool = practiceOrder(cards);
  final allWords = cards
      .map((c) => c.word.trim().toLowerCase())
      .where((w) => w.isNotEmpty)
      .toSet()
      .toList();
  final questions = <ClozeQuestionModel>[];

  for (final card in pool) {
    if (questions.length >= clozeMaxQuestions) break;
    final target = card.word.trim();
    final sentence = _sentenceFor(card, target);

    if (target.isEmpty) continue;
    final match = _wordPattern(target).firstMatch(sentence);
    if (match == null) continue;
    final before = sentence.substring(0, match.start);
    final after = (match.group(2) ?? '') + sentence.substring(match.end);

    final distractors = allWords.where((w) => w != target.toLowerCase()).toList()..shuffle();
    if (distractors.length < clozeMinOptions - 1) continue;
    final options = [target, ...distractors.take(clozeMaxOptions - 1)]..shuffle();

    questions.add(ClozeQuestionModel(
      card: card,
      sentenceBefore: before,
      sentenceAfter: after,
      correctWord: target,
      options: options,
    ));
  }
  return questions;
}

@immutable
class ContextClozeState {
  /// Yanlış bilinen / atlanan kartların id'leri (oyun sonu tekrar listesi).
  final List<String> missedIds;
  final List<ClozeQuestionModel> questions;
  final int currentIndex;
  final String? selectedOption;
  final bool isAnswered;
  final bool showHint;
  final int score;
  final int correctCount;

  const ContextClozeState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedOption,
    this.isAnswered = false,
    this.showHint = false,
    this.score = 0,
    this.correctCount = 0,
    this.missedIds = const [],
  });


  bool get isFinished => currentIndex >= questions.length;
  bool get hasNext => currentIndex + 1 < questions.length;
  ClozeQuestionModel get currentQuestion => questions[currentIndex];

  List<FlashcardModel> get missedCards => [
        for (final id in missedIds) questions.map((q) => q.card).firstWhere((c) => c.id == id),
      ];

  ContextClozeState copyWith({
    int? currentIndex,
    String? Function()? selectedOption,
    bool? isAnswered,
    bool? showHint,
    int? score,
    int? correctCount,
    List<String>? missedIds,
  }) {

    return ContextClozeState(
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOption: selectedOption != null ? selectedOption() : this.selectedOption,
      isAnswered: isAnswered ?? this.isAnswered,
      showHint: showHint ?? this.showHint,
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
      missedIds: missedIds ?? this.missedIds,
    );
  }
}

class ContextClozeNotifier extends StateNotifier<ContextClozeState> {
  final List<FlashcardModel> _cards;
  final PlayAudio _playAudio;
  final RecordScore _recordScore;
  bool _recorded = false;

  ContextClozeNotifier(
    this._cards, {
    PlayAudio playAudio = defaultPlayAudio,
    required RecordScore recordScore,
  })  : _playAudio = playAudio,
        _recordScore = recordScore,
        super(const ContextClozeState()) {
    restart();
  }

  void restart() {
    _recorded = false;
    state = ContextClozeState(questions: buildClozeQuestions(_cards));
  }

  void toggleHint() {
    if (state.isFinished) return;
    state = state.copyWith(showHint: !state.showHint);
  }

  void selectOption(String option) {
    if (state.isAnswered || state.isFinished) return;
    final q = state.currentQuestion;
    final isCorrect = option.toLowerCase() == q.correctWord.toLowerCase();

    if (!isCorrect) {
      state = state.copyWith(
        selectedOption: () => option,
        isAnswered: true,
        missedIds: _withMissed(q.card.id),
      );
      _recordIfLast();
      return;
    }

    _playAudio(q.card.word);
    state = state.copyWith(
      selectedOption: () => option,
      isAnswered: true,
      correctCount: state.correctCount + 1,
      score: state.score + (state.showHint ? clozePointsWithHint : clozePointsNoHint),
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
    if (state.isFinished || !state.isAnswered) return;
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      selectedOption: () => null,
      isAnswered: false,
      showHint: false,
    );
  }
}

final contextClozeProvider = StateNotifierProvider.autoDispose
    .family<ContextClozeNotifier, ContextClozeState, List<FlashcardModel>>((ref, cards) {
  return ContextClozeNotifier(cards, recordScore: statsRecorder(ref));
});
