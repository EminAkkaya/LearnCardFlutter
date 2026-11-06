import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/audio_helper.dart';
import '../../models/flashcard_model.dart';
import '../../providers/stats_provider.dart';
import 'widgets/speed_quiz_hud_bar.dart';
import 'widgets/speed_quiz_options_list.dart';
import 'widgets/speed_quiz_question_model.dart';
import 'widgets/speed_quiz_summary_view.dart';
import 'widgets/speed_quiz_target_card.dart';

class SpeedQuizGameScreen extends ConsumerStatefulWidget {
  final List<FlashcardModel> cards;

  const SpeedQuizGameScreen({super.key, required this.cards});

  @override
  ConsumerState<SpeedQuizGameScreen> createState() => _SpeedQuizGameScreenState();
}

class _SpeedQuizGameScreenState extends ConsumerState<SpeedQuizGameScreen> {
  List<SpeedQuizQuestionModel> _questions = [];
  int _currentIndex = 0;

  Timer? _countdownTimer;
  int _secondsRemaining = 10;
  String? _selectedOption;
  bool _isAnswered = false;

  int _score = 0;
  int _streak = 0;
  int _maxStreak = 0;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _prepareQuestions();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _prepareQuestions() {
    final List<FlashcardModel> pool = List.from(widget.cards)..shuffle();
    final List<SpeedQuizQuestionModel> qList = [];

    final List<String> allTrMeanings = widget.cards
        .map((c) => c.trTranslation.isNotEmpty ? c.trTranslation : c.definition)
        .where((t) => t.trim().isNotEmpty)
        .toSet()
        .toList();

    const fallbackMeanings = [
      'Gözlemlemek, dikkat etmek',
      'Geçici, kısa süreli',
      'Etkileyici, büyüleyici',
      'Temel, vazgeçilmez',
      'Öngörülemez, belirsiz',
    ];

    for (final card in pool) {
      if (qList.length >= 10) break;

      final targetWord = card.word.trim();
      final correctAnswer =
          card.trTranslation.isNotEmpty ? card.trTranslation : card.definition;
      if (correctAnswer.trim().isEmpty) continue;

      final distractors =
          allTrMeanings.where((m) => m != correctAnswer).toList()..shuffle();
      final List<String> options = [correctAnswer];

      for (final d in distractors) {
        if (options.length < 4 && !options.contains(d)) {
          options.add(d);
        }
      }

      int fbIdx = 0;
      while (options.length < 4 && fbIdx < fallbackMeanings.length) {
        final fb = fallbackMeanings[fbIdx++];
        if (!options.contains(fb)) {
          options.add(fb);
        }
      }

      options.shuffle();

      qList.add(SpeedQuizQuestionModel(
        card: card,
        targetWord: targetWord,
        correctAnswer: correctAnswer,
        options: options,
      ));
    }

    setState(() {
      _questions = qList;
      _currentIndex = 0;
      _score = 0;
      _streak = 0;
      _maxStreak = 0;
      _correctCount = 0;
    });

    if (qList.isNotEmpty) {
      _startQuestionTimer();
    }
  }

  void _startQuestionTimer() {
    _countdownTimer?.cancel();
    _secondsRemaining = 10;
    _isAnswered = false;
    _selectedOption = null;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _onTimeExpired();
      }
    });
  }

  void _onTimeExpired() {
    if (_isAnswered) return;
    setState(() {
      _isAnswered = true;
      _selectedOption = null;
      _streak = 0;
    });
  }

  void _onOptionSelected(String option) {
    if (_isAnswered) return;
    _countdownTimer?.cancel();

    final currentQ = _questions[_currentIndex];
    final bool isCorrect = (option == currentQ.correctAnswer);

    if (isCorrect) {
      if (currentQ.card.audioUrl.isNotEmpty) {
        AudioHelper.playAudio(currentQ.card.audioUrl);
      }
      final int points = 100 + (_secondsRemaining * 10) + (_streak * 20);
      setState(() {
        _selectedOption = option;
        _isAnswered = true;
        _correctCount++;
        _streak++;
        if (_streak > _maxStreak) _maxStreak = _streak;
        _score += points;
      });
    } else {
      setState(() {
        _selectedOption = option;
        _isAnswered = true;
        _streak = 0;
      });
    }
  }

  void _nextQuestion() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() => _currentIndex++);
      _startQuestionTimer();
    } else {
      ref.read(statsProvider.notifier).recordGameScore(_score);
      setState(() => _currentIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hızlı Karar Testi')),
        body: const Center(child: Text('Test edilecek kart bulunamadı.')),
      );
    }

    if (_currentIndex >= _questions.length) {
      return SpeedQuizSummaryView(
        totalQuestions: _questions.length,
        correctCount: _correctCount,
        score: _score,
        maxStreak: _maxStreak,
        onRestart: _prepareQuestions,
      );
    }

    final q = _questions[_currentIndex];
    const amberColor = Color(0xFFF59E0B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hızlı Karar Testi'),
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
                  '${_currentIndex + 1}/${_questions.length}',
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
            LinearProgressIndicator(
              value: _secondsRemaining / 10.0,
              color: _secondsRemaining <= 3 ? Colors.redAccent : amberColor,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              minHeight: 5,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    SpeedQuizHudBar(
                      score: _score,
                      streak: _streak,
                      secondsRemaining: _secondsRemaining,
                    ),
                    const SizedBox(height: 20),
                    SpeedQuizTargetCard(
                      question: q,
                      isAnswered: _isAnswered,
                    ),
                    const SizedBox(height: 24),
                    SpeedQuizOptionsList(
                      question: q,
                      selectedOption: _selectedOption,
                      isAnswered: _isAnswered,
                      onOptionSelected: _onOptionSelected,
                    ),
                    if (_isAnswered) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _nextQuestion,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: Text(
                            _currentIndex + 1 < _questions.length ? 'Sonraki Soru' : 'Sonuçları Gör',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: amberColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
}
