import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../models/games/speed_quiz_question_model.dart';
import 'game_callbacks.dart';

const int speedQuizQuestionSeconds = 10;
const int speedQuizMaxQuestions = 10;

const _fallbackMeanings = [
  'Gözlemlemek, dikkat etmek',
  'Geçici, kısa süreli',
  'Etkileyici, büyüleyici',
  'Temel, vazgeçilmez',
  'Öngörülemez, belirsiz',
];

String _meaningOf(FlashcardModel c) =>
    c.trTranslation.isNotEmpty ? c.trTranslation : c.definition;

/// Kartlardan en fazla [speedQuizMaxQuestions] adet 4 şıklı soru üretir.
List<SpeedQuizQuestionModel> buildSpeedQuizQuestions(List<FlashcardModel> cards) {
  final pool = List<FlashcardModel>.from(cards)..shuffle();
  final allMeanings =
      cards.map(_meaningOf).where((t) => t.trim().isNotEmpty).toSet().toList();
  final questions = <SpeedQuizQuestionModel>[];

  for (final card in pool) {
    if (questions.length >= speedQuizMaxQuestions) break;
    final correct = _meaningOf(card);
    if (correct.trim().isEmpty) continue;

    final options = <String>[correct];
    final distractors = allMeanings.where((m) => m != correct).toList()..shuffle();
    for (final d in [...distractors, ..._fallbackMeanings]) {
      if (options.length >= 4) break;
      if (!options.contains(d)) options.add(d);
    }
    options.shuffle();

    questions.add(SpeedQuizQuestionModel(
      card: card,
      targetWord: card.word.trim(),
      correctAnswer: correct,
      options: options,
    ));
  }
  return questions;
}

@immutable
class SpeedQuizState {
  final List<SpeedQuizQuestionModel> questions;
  final int currentIndex;
  final int secondsRemaining;
  final String? selectedOption;
  final bool isAnswered;
  final int score;
  final int streak;
  final int maxStreak;
  final int correctCount;

  const SpeedQuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.secondsRemaining = speedQuizQuestionSeconds,
    this.selectedOption,
    this.isAnswered = false,
    this.score = 0,
    this.streak = 0,
    this.maxStreak = 0,
    this.correctCount = 0,
  });

  bool get isFinished => currentIndex >= questions.length;
  bool get hasNext => currentIndex + 1 < questions.length;
  SpeedQuizQuestionModel get currentQuestion => questions[currentIndex];

  SpeedQuizState copyWith({
    int? currentIndex,
    int? secondsRemaining,
    String? Function()? selectedOption,
    bool? isAnswered,
    int? score,
    int? streak,
    int? maxStreak,
    int? correctCount,
  }) {
    return SpeedQuizState(
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      selectedOption: selectedOption != null ? selectedOption() : this.selectedOption,
      isAnswered: isAnswered ?? this.isAnswered,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      maxStreak: maxStreak ?? this.maxStreak,
      correctCount: correctCount ?? this.correctCount,
    );
  }
}

class SpeedQuizNotifier extends StateNotifier<SpeedQuizState> {
  final List<FlashcardModel> _cards;
  final PlayAudio _playAudio;
  final RecordScore _recordScore;
  final bool _useTimer;
  Timer? _timer;

  SpeedQuizNotifier(
    this._cards, {
    PlayAudio playAudio = defaultPlayAudio,
    required RecordScore recordScore,
    @visibleForTesting bool useTimer = true,
  })  : _playAudio = playAudio,
        _recordScore = recordScore,
        _useTimer = useTimer,
        super(const SpeedQuizState()) {
    restart();
  }

  void restart() {
    state = SpeedQuizState(questions: buildSpeedQuizQuestions(_cards));
    if (state.questions.isNotEmpty) _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!_useTimer) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  /// Saniyede bir çağrılır; süre biterse soru cevapsız kapanır.
  @visibleForTesting
  void tick() {
    if (state.isAnswered || state.isFinished) return;
    if (state.secondsRemaining > 1) {
      state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
    } else {
      _timer?.cancel();
      state = state.copyWith(
        secondsRemaining: 0,
        isAnswered: true,
        selectedOption: () => null,
        streak: 0,
      );
    }
  }

  void selectOption(String option) {
    if (state.isAnswered || state.isFinished) return;
    _timer?.cancel();
    final q = state.currentQuestion;

    if (option != q.correctAnswer) {
      state = state.copyWith(selectedOption: () => option, isAnswered: true, streak: 0);
      return;
    }

    _playAudio(q.card.audioUrl);
    final points = 100 + (state.secondsRemaining * 10) + (state.streak * 20);
    final streak = state.streak + 1;
    state = state.copyWith(
      selectedOption: () => option,
      isAnswered: true,
      correctCount: state.correctCount + 1,
      streak: streak,
      maxStreak: streak > state.maxStreak ? streak : state.maxStreak,
      score: state.score + points,
    );
  }

  void next() {
    if (state.isFinished) return;
    if (!state.hasNext) _recordScore(state.score);
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      secondsRemaining: speedQuizQuestionSeconds,
      selectedOption: () => null,
      isAnswered: false,
    );
    if (!state.isFinished) _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final speedQuizProvider = StateNotifierProvider.autoDispose
    .family<SpeedQuizNotifier, SpeedQuizState, List<FlashcardModel>>((ref, cards) {
  return SpeedQuizNotifier(cards, recordScore: statsRecorder(ref));
});
