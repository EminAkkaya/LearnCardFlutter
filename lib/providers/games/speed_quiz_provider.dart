import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../models/games/speed_quiz_question_model.dart';
import 'game_callbacks.dart';

const int speedQuizQuestionSeconds = 10;
const int speedQuizMaxQuestions = 10;
const int speedQuizMaxStreakBonus = 100;

const int speedQuizMaxOptions = 4;
const int speedQuizMinOptions = 3;

bool _hasTr(FlashcardModel c) => c.trTranslation.trim().isNotEmpty;

String _meaningOf(FlashcardModel c) =>
    (_hasTr(c) ? c.trTranslation : c.definition).trim();

/// Kartlardan en fazla [speedQuizMaxQuestions] soru üretir.
///
/// Çeldiriciler yalnız kullanıcının kendi destesinden ve doğru cevapla aynı
/// türden (Türkçe karşılık ↔ Türkçe karşılık, tanım ↔ tanım) seçilir; böylece
/// dil farkından doğru cevap anlaşılmaz. En az [speedQuizMinOptions] şık
/// kurulamayan kart soru olarak kullanılmaz.
List<SpeedQuizQuestionModel> buildSpeedQuizQuestions(List<FlashcardModel> cards) {
  final pool = List<FlashcardModel>.from(cards)..shuffle();
  final questions = <SpeedQuizQuestionModel>[];

  for (final card in pool) {
    if (questions.length >= speedQuizMaxQuestions) break;
    final correct = _meaningOf(card);
    if (correct.isEmpty) continue;

    final distractors = cards
        .where((c) => _hasTr(c) == _hasTr(card))
        .map(_meaningOf)
        .where((m) => m.isNotEmpty && m.toLowerCase() != correct.toLowerCase())
        .toSet()
        .toList()
      ..shuffle();
    if (distractors.length < speedQuizMinOptions - 1) continue;

    final options = [correct, ...distractors.take(speedQuizMaxOptions - 1)]..shuffle();

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
  bool _recorded = false;

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
    _recorded = false;
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
      _recordIfLast();
    }
  }

  /// Son soru cevaplandığı anda skoru bir kez kaydeder; kullanıcı özet
  /// ekranına geçmeden çıksa bile oyun sayılır.
  void _recordIfLast() {
    if (_recorded || state.hasNext) return;
    _recorded = true;
    _recordScore(state.score);
  }

  void selectOption(String option) {
    if (state.isAnswered || state.isFinished) return;
    _timer?.cancel();
    final q = state.currentQuestion;

    if (option != q.correctAnswer) {
      state = state.copyWith(selectedOption: () => option, isAnswered: true, streak: 0);
      _recordIfLast();
      return;
    }

    _playAudio(q.card.audioUrl);
    final points = 100 + (state.secondsRemaining * 10) + (state.streak * 20).clamp(0, speedQuizMaxStreakBonus);
    final streak = state.streak + 1;
    state = state.copyWith(
      selectedOption: () => option,
      isAnswered: true,
      correctCount: state.correctCount + 1,
      streak: streak,
      maxStreak: streak > state.maxStreak ? streak : state.maxStreak,
      score: state.score + points,
    );
    _recordIfLast();
  }

  void next() {
    if (state.isFinished || !state.isAnswered) return;
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
