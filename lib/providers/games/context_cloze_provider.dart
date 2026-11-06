import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../models/games/cloze_question_model.dart';
import 'game_callbacks.dart';

const int clozeMaxQuestions = 10;
const int clozePointsNoHint = 100;
const int clozePointsWithHint = 60;

const _fallbackWords = [
  'resilient',
  'ephemeral',
  'serendipity',
  'ubiquitous',
  'pragmatic',
  'meticulous',
  'authentic',
  'innovative',
];

String _sentenceFor(FlashcardModel card, String target) {
  final s = card.exampleSentence.trim();
  if (s.isNotEmpty) return s;
  if (card.definition.isNotEmpty) {
    return 'It means: ${card.definition}. The key word is $target.';
  }
  return 'Understanding the word $target is essential for communication.';
}

/// Kartların örnek cümlelerinden boşluk doldurma soruları üretir.
List<ClozeQuestionModel> buildClozeQuestions(List<FlashcardModel> cards) {
  final pool = List<FlashcardModel>.from(cards)..shuffle();
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

    final match = RegExp(
      r'\b' + RegExp.escape(target) + r'(s|ed|ing|ly)?\b',
      caseSensitive: false,
    ).firstMatch(sentence);
    final before = match != null ? sentence.substring(0, match.start) : 'In modern contexts, ';
    final after = match != null ? sentence.substring(match.end) : ' plays a vital and noteworthy role.';

    final options = <String>[target];
    final distractors = allWords.where((w) => w != target.toLowerCase()).toList()..shuffle();
    for (final d in [...distractors, ..._fallbackWords]) {
      if (options.length >= 4) break;
      if (!options.any((o) => o.toLowerCase() == d.toLowerCase())) options.add(d);
    }
    options.shuffle();

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
  });

  bool get isFinished => currentIndex >= questions.length;
  bool get hasNext => currentIndex + 1 < questions.length;
  ClozeQuestionModel get currentQuestion => questions[currentIndex];

  ContextClozeState copyWith({
    int? currentIndex,
    String? Function()? selectedOption,
    bool? isAnswered,
    bool? showHint,
    int? score,
    int? correctCount,
  }) {
    return ContextClozeState(
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOption: selectedOption != null ? selectedOption() : this.selectedOption,
      isAnswered: isAnswered ?? this.isAnswered,
      showHint: showHint ?? this.showHint,
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
    );
  }
}

class ContextClozeNotifier extends StateNotifier<ContextClozeState> {
  final List<FlashcardModel> _cards;
  final PlayAudio _playAudio;
  final RecordScore _recordScore;

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
      state = state.copyWith(selectedOption: () => option, isAnswered: true);
      return;
    }

    _playAudio(q.card.audioUrl);
    state = state.copyWith(
      selectedOption: () => option,
      isAnswered: true,
      correctCount: state.correctCount + 1,
      score: state.score + (state.showHint ? clozePointsWithHint : clozePointsNoHint),
    );
  }

  void next() {
    if (state.isFinished) return;
    if (!state.hasNext) _recordScore(state.score);
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
