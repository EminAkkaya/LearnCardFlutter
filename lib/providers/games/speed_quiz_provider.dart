import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../models/games/speed_quiz_question_model.dart';
import 'game_callbacks.dart';
import 'practice_order.dart';

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
///
/// Türkçe karşılığı olan kartlarda sorular dönüşümlü olarak ters yönde
/// (TR → EN) sorulur; aktif hatırlama iki yönde de çalışır.
List<SpeedQuizQuestionModel> buildSpeedQuizQuestions(List<FlashcardModel> cards) {
  final pool = practiceOrder(cards);
  final questions = <SpeedQuizQuestionModel>[];

  for (final card in pool) {
    if (questions.length >= speedQuizMaxQuestions) break;
    if (_hasTr(card) && questions.length.isOdd) {
      final reverse = _reverseQuestion(card, cards);
      if (reverse != null) {
        questions.add(reverse);
        continue;
      }
    }
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

SpeedQuizQuestionModel? _reverseQuestion(FlashcardModel card, List<FlashcardModel> cards) {
  final word = card.word.trim();
  final distractors = cards
      .map((c) => c.word.trim())
      .where((w) => w.isNotEmpty && w.toLowerCase() != word.toLowerCase())
      .toSet()
      .toList()
    ..shuffle();
  if (word.isEmpty || distractors.length < speedQuizMinOptions - 1) return null;
  return SpeedQuizQuestionModel(
    card: card,
    targetWord: card.trTranslation.trim(),
    correctAnswer: word,
    options: [word, ...distractors.take(speedQuizMaxOptions - 1)]..shuffle(),
    isReverse: true,
  );
}

@immutable
class SpeedQuizState {
  /// Yanlış bilinen / atlanan kartların id'leri (oyun sonu tekrar listesi).
  final List<String> missedIds;
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
    this.missedIds = const [],
  });


  bool get isFinished => currentIndex >= questions.length;
  bool get hasNext => currentIndex + 1 < questions.length;
  SpeedQuizQuestionModel get currentQuestion => questions[currentIndex];

  List<FlashcardModel> get missedCards => [
        for (final id in missedIds) questions.map((q) => q.card).firstWhere((c) => c.id == id),
      ];

  SpeedQuizState copyWith({
    int? currentIndex,
    int? secondsRemaining,
    String? Function()? selectedOption,
    bool? isAnswered,
    int? score,
    int? streak,
    int? maxStreak,
    int? correctCount,
    List<String>? missedIds,
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
      missedIds: missedIds ?? this.missedIds,
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
        missedIds: _withMissed(state.currentQuestion.card.id),
      );
      _recordIfLast();
    }
  }

  List<String> _withMissed(String cardId) =>
      state.missedIds.contains(cardId) ? state.missedIds : [...state.missedIds, cardId];

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
      state = state.copyWith(
        selectedOption: () => option,
        isAnswered: true,
        streak: 0,
        missedIds: _withMissed(q.card.id),
      );
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
