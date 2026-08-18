import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/utils/audio_helper.dart';
import '../../models/flashcard_model.dart';

class _QuizQuestion {
  final FlashcardModel card;
  final String targetWord;
  final String correctAnswer;
  final List<String> options;

  _QuizQuestion({
    required this.card,
    required this.targetWord,
    required this.correctAnswer,
    required this.options,
  });
}

class SpeedQuizGameScreen extends StatefulWidget {
  final List<FlashcardModel> cards;

  const SpeedQuizGameScreen({super.key, required this.cards});

  @override
  State<SpeedQuizGameScreen> createState() => _SpeedQuizGameScreenState();
}

class _SpeedQuizGameScreenState extends State<SpeedQuizGameScreen> {
  static const int questionTimeLimit = 10;
  List<_QuizQuestion> _questions = [];
  int _currentIndex = 0;

  int _score = 0;
  int _streak = 0;
  int _maxStreak = 0;
  int _correctCount = 0;

  Timer? _timer;
  int _secondsLeft = questionTimeLimit;
  String? _selectedOption;
  bool _isAnswered = false;

  final List<FlashcardModel> _missedCards = [];

  @override
  void initState() {
    super.initState();
    _generateQuestions();
    _startQuestionTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateQuestions() {
    final List<FlashcardModel> pool = List.from(widget.cards)..shuffle();
    final int count = min(10, pool.length);
    final selectedCards = pool.sublist(0, count);

    final List<_QuizQuestion> questions = [];
    final List<String> allMeanings = widget.cards
        .map((c) => c.trTranslation.isNotEmpty ? c.trTranslation : c.definition)
        .where((m) => m.isNotEmpty)
        .toSet()
        .toList();

    // Fallback distractor pool if user has few cards
    const fallbackDistractors = [
      'önemli, dikkate değer',
      'hızlı bir şekilde',
      'şaşırtıcı ve etkileyici',
      'sürekli devam eden',
      'zorlayıcı durum',
      'başarılı sonuç',
      'ortak payda',
      'yeni keşfedilen',
    ];

    for (final card in selectedCards) {
      final correctMeaning = card.trTranslation.isNotEmpty ? card.trTranslation : card.definition;

      // Pick 3 distractors
      final distractors = allMeanings.where((m) => m != correctMeaning).toList()..shuffle();
      final List<String> options = [correctMeaning];

      for (final d in distractors) {
        if (options.length < 4 && !options.contains(d)) {
          options.add(d);
        }
      }

      int fbIdx = 0;
      while (options.length < 4 && fbIdx < fallbackDistractors.length) {
        final fb = fallbackDistractors[fbIdx++];
        if (!options.contains(fb)) {
          options.add(fb);
        }
      }

      options.shuffle();

      questions.add(_QuizQuestion(
        card: card,
        targetWord: card.word,
        correctAnswer: correctMeaning,
        options: options,
      ));
    }

    setState(() {
      _questions = questions;
      _currentIndex = 0;
    });
  }

  void _startQuestionTimer() {
    _timer?.cancel();
    _secondsLeft = questionTimeLimit;
    _selectedOption = null;
    _isAnswered = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();
        _onTimeOut();
      }
    });
  }

  void _onTimeOut() {
    if (_isAnswered) return;
    final currentQ = _questions[_currentIndex];
    if (!_missedCards.contains(currentQ.card)) {
      _missedCards.add(currentQ.card);
    }
    setState(() {
      _isAnswered = true;
      _streak = 0;
    });
    _scheduleNextQuestion();
  }

  void _onOptionSelected(String option) {
    if (_isAnswered) return;
    _timer?.cancel();

    final currentQ = _questions[_currentIndex];
    final bool isCorrect = (option == currentQ.correctAnswer);

    if (isCorrect) {
      final earned = 100 + (_secondsLeft * 15) + (_streak * 20);
      if (currentQ.card.audioUrl.isNotEmpty) {
        AudioHelper.playAudio(currentQ.card.audioUrl);
      }
      setState(() {
        _selectedOption = option;
        _isAnswered = true;
        _correctCount++;
        _streak++;
        if (_streak > _maxStreak) _maxStreak = _streak;
        _score += earned;
      });
    } else {
      if (!_missedCards.contains(currentQ.card)) {
        _missedCards.add(currentQ.card);
      }
      setState(() {
        _selectedOption = option;
        _isAnswered = true;
        _streak = 0;
      });
    }

    _scheduleNextQuestion();
  }

  void _scheduleNextQuestion() {
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_currentIndex + 1 < _questions.length) {
        setState(() {
          _currentIndex++;
        });
        _startQuestionTimer();
      } else {
        setState(() {
          _currentIndex++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hızlı Karar Testi')),
        body: const Center(child: Text('Yeterli kelime bulunamadı.')),
      );
    }

    if (_currentIndex >= _questions.length) {
      return _buildSummaryView(context);
    }

    final question = _questions[_currentIndex];
    final double timerRatio = _secondsLeft / questionTimeLimit;
    const emerald = Color(0xFF10B981);

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
            // Top HUD Bar: Streak & Score & Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: Row(
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
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: Colors.deepOrangeAccent, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Seri: ${_streak}x',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrangeAccent,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Timer Progress Indicator
            LinearProgressIndicator(
              value: timerRatio,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: _secondsLeft <= 3 ? Colors.redAccent : const Color(0xFFF59E0B),
              minHeight: 5,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    const Spacer(),

                    // Target English Word Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.surface,
                              theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  question.targetWord,
                                  style: theme.textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                if (question.card.audioUrl.isNotEmpty) ...[
                                  const SizedBox(width: 10),
                                  IconButton.filledTonal(
                                    iconSize: 20,
                                    onPressed: () => AudioHelper.playAudio(question.card.audioUrl),
                                    icon: const Icon(Icons.volume_up_rounded),
                                  ),
                                ],
                              ],
                            ),
                            if (question.card.phonetic.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                question.card.phonetic,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                            if (question.card.partOfSpeech.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '(${question.card.partOfSpeech})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // 4 Multiple Choice Options
                    ...question.options.map((option) {
                      Color btnColor = theme.colorScheme.surface;
                      Color borderColor = theme.dividerColor.withValues(alpha: 0.5);
                      Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

                      if (_isAnswered) {
                        if (option == question.correctAnswer) {
                          btnColor = emerald.withValues(alpha: 0.2);
                          borderColor = emerald;
                          textColor = emerald;
                        } else if (option == _selectedOption) {
                          btnColor = Colors.redAccent.withValues(alpha: 0.2);
                          borderColor = Colors.redAccent;
                          textColor = Colors.redAccent;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isAnswered ? null : () => _onOptionSelected(option),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: btnColor,
                              foregroundColor: textColor,
                              elevation: 1,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: borderColor,
                                  width: (_isAnswered && (option == question.correctAnswer || option == _selectedOption)) ? 2 : 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                if (_isAnswered && option == question.correctAnswer)
                                  const Icon(Icons.check_circle_rounded, color: emerald, size: 20)
                                else if (_isAnswered && option == _selectedOption)
                                  const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryView(BuildContext context) {
    final theme = Theme.of(context);
    const emerald = Color(0xFF10B981);
    final double accuracy = _questions.isNotEmpty ? (_correctCount / _questions.length) * 100 : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Test Sonucu')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  size: 72,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Test Tamamlandı!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toplam ${_questions.length} sorudan $_correctCount tanesini doğru yanıtladınız.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Metric Cards
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      _buildSummaryRow('Toplam Puan', '$_score', Colors.amber),
                      const Divider(height: 16),
                      _buildSummaryRow('Başarı Oranı', '%${accuracy.toStringAsFixed(0)}', emerald),
                      const Divider(height: 16),
                      _buildSummaryRow('En Yüksek Seri', '$_maxStreak Kombo', Colors.deepOrangeAccent),
                    ],
                  ),
                ),
              ),

              if (_missedCards.isNotEmpty) ...[
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tekrar Edilmesi Önerilen Kelimeler (${_missedCards.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _missedCards.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final c = _missedCards[idx];
                      return ListTile(
                        dense: true,
                        title: Text(c.word, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(c.trTranslation.isNotEmpty ? c.trTranslation : c.definition),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _score = 0;
                      _streak = 0;
                      _maxStreak = 0;
                      _correctCount = 0;
                      _missedCards.clear();
                      _generateQuestions();
                      _startQuestionTimer();
                    });
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Yeni Test Başlat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
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

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
