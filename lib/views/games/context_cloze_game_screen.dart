import 'package:flutter/material.dart';
import '../../core/utils/audio_helper.dart';
import '../../models/flashcard_model.dart';

class _ClozeQuestion {
  final FlashcardModel card;
  final String sentenceBefore;
  final String sentenceAfter;
  final String correctWord;
  final List<String> options;

  _ClozeQuestion({
    required this.card,
    required this.sentenceBefore,
    required this.sentenceAfter,
    required this.correctWord,
    required this.options,
  });
}

class ContextClozeGameScreen extends StatefulWidget {
  final List<FlashcardModel> cards;

  const ContextClozeGameScreen({super.key, required this.cards});

  @override
  State<ContextClozeGameScreen> createState() => _ContextClozeGameScreenState();
}

class _ContextClozeGameScreenState extends State<ContextClozeGameScreen> {
  List<_ClozeQuestion> _questions = [];
  int _currentIndex = 0;

  String? _selectedOption;
  bool _isAnswered = false;
  bool _showHint = false;

  int _score = 0;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _prepareQuestions();
  }

  void _prepareQuestions() {
    final List<FlashcardModel> pool = List.from(widget.cards)..shuffle();
    final List<_ClozeQuestion> list = [];

    final List<String> allWords = widget.cards
        .map((c) => c.word.trim().toLowerCase())
        .where((w) => w.isNotEmpty)
        .toSet()
        .toList();

    const fallbackDistractorWords = [
      'resilient',
      'ephemeral',
      'serendipity',
      'ubiquitous',
      'pragmatic',
      'meticulous',
      'authentic',
      'innovative',
    ];

    for (final card in pool) {
      if (list.length >= 10) break;

      final targetWord = card.word.trim();
      String sentence = card.exampleSentence.trim();

      // If card doesn't have an example sentence, create a context sentence
      if (sentence.isEmpty) {
        if (card.definition.isNotEmpty) {
          sentence = 'It means: ${card.definition}. The key word is $targetWord.';
        } else {
          sentence = 'Understanding the word $targetWord is essential for communication.';
        }
      }

      // Find target word case-insensitively in sentence
      final RegExp regExp = RegExp(r'\b' + RegExp.escape(targetWord) + r'(s|ed|ing|ly)?\b', caseSensitive: false);
      final match = regExp.firstMatch(sentence);

      String before;
      String after;

      if (match != null) {
        before = sentence.substring(0, match.start);
        after = sentence.substring(match.end);
      } else {
        // Fallback split
        before = 'In modern contexts, ';
        after = ' plays a vital and noteworthy role.';
      }

      // Pick 3 distractors
      final distractors = allWords.where((w) => w != targetWord.toLowerCase()).toList()..shuffle();
      final List<String> options = [targetWord];

      for (final d in distractors) {
        if (options.length < 4 && !options.map((e) => e.toLowerCase()).contains(d.toLowerCase())) {
          options.add(d);
        }
      }

      int fbIdx = 0;
      while (options.length < 4 && fbIdx < fallbackDistractorWords.length) {
        final fb = fallbackDistractorWords[fbIdx++];
        if (!options.map((e) => e.toLowerCase()).contains(fb.toLowerCase())) {
          options.add(fb);
        }
      }

      options.shuffle();

      list.add(_ClozeQuestion(
        card: card,
        sentenceBefore: before,
        sentenceAfter: after,
        correctWord: targetWord,
        options: options,
      ));
    }

    setState(() {
      _questions = list;
      _currentIndex = 0;
      _isAnswered = false;
      _selectedOption = null;
      _showHint = false;
    });
  }

  void _onOptionSelected(String option) {
    if (_isAnswered) return;

    final currentQ = _questions[_currentIndex];
    final bool isCorrect = (option.toLowerCase() == currentQ.correctWord.toLowerCase());

    if (isCorrect) {
      if (currentQ.card.audioUrl.isNotEmpty) {
        AudioHelper.playAudio(currentQ.card.audioUrl);
      }
      setState(() {
        _selectedOption = option;
        _isAnswered = true;
        _correctCount++;
        _score += _showHint ? 60 : 100;
      });
    } else {
      setState(() {
        _selectedOption = option;
        _isAnswered = true;
      });
    }
  }

  void _nextQuestion() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _selectedOption = null;
        _showHint = false;
      });
    } else {
      setState(() {
        _currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cümle Tamamlama')),
        body: const Center(child: Text('Çalışılacak soru oluşturulamadı.')),
      );
    }

    if (_currentIndex >= _questions.length) {
      return _buildSummaryScreen(context);
    }

    final q = _questions[_currentIndex];
    const emerald = Color(0xFF10B981);
    const pinkAccent = Color(0xFFEC4899);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cümle İçi Boşluk Doldurma'),
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
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              color: pinkAccent,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              minHeight: 4,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Score & Streak HUD
                    Row(
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
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showHint = !_showHint;
                            });
                          },
                          icon: Icon(
                            _showHint ? Icons.visibility_off_outlined : Icons.lightbulb_outline_rounded,
                            size: 18,
                            color: Colors.amber,
                          ),
                          label: Text(
                            _showHint ? 'İpucunu Gizle' : 'İpucu Gör',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),

                    if (_showHint) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'Türkçe Anlamı: ${q.card.trTranslation.isNotEmpty ? q.card.trTranslation : q.card.definition}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Context Sentence Card with Interactive Blank
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.surface,
                              theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'CÜMLE BAĞLAMI',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: pinkAccent,
                                  ),
                                ),
                                if (_isAnswered && q.card.audioUrl.isNotEmpty)
                                  IconButton.filledTonal(
                                    onPressed: () => AudioHelper.playAudio(q.card.audioUrl),
                                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Formatted Sentence with Blank
                            RichText(
                              text: TextSpan(
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 18,
                                  height: 1.6,
                                ),
                                children: [
                                  TextSpan(text: q.sentenceBefore),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _isAnswered
                                            ? (_selectedOption?.toLowerCase() == q.correctWord.toLowerCase()
                                                ? emerald.withValues(alpha: 0.25)
                                                : Colors.redAccent.withValues(alpha: 0.25))
                                            : pinkAccent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _isAnswered
                                              ? (_selectedOption?.toLowerCase() == q.correctWord.toLowerCase()
                                                  ? emerald
                                                  : Colors.redAccent)
                                              : pinkAccent,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        _isAnswered ? q.correctWord : ' _____ ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: _isAnswered
                                              ? (_selectedOption?.toLowerCase() == q.correctWord.toLowerCase()
                                                  ? emerald
                                                  : Colors.redAccent)
                                              : pinkAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(text: q.sentenceAfter),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Options Grid
                    ...q.options.map((option) {
                      Color btnColor = theme.colorScheme.surface;
                      Color borderColor = theme.dividerColor.withValues(alpha: 0.5);
                      Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

                      if (_isAnswered) {
                        if (option.toLowerCase() == q.correctWord.toLowerCase()) {
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
                                  width: (_isAnswered && (option.toLowerCase() == q.correctWord.toLowerCase() || option == _selectedOption)) ? 2 : 1,
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                if (_isAnswered && option.toLowerCase() == q.correctWord.toLowerCase())
                                  const Icon(Icons.check_circle_rounded, color: emerald, size: 20)
                                else if (_isAnswered && option == _selectedOption)
                                  const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    if (_isAnswered) ...[
                      const SizedBox(height: 16),
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
                            backgroundColor: pinkAccent,
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
    const pinkAccent = Color(0xFFEC4899);
    const emerald = Color(0xFF10B981);
    final double accuracy = _questions.isNotEmpty ? (_correctCount / _questions.length) * 100 : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Alıştırma Tamamlandı')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: pinkAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: 72,
                  color: pinkAccent,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Bağlamsal Pratik Tamamlandı!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toplam ${_questions.length} cümleden $_correctCount tanesini başarıyla tamamladınız.',
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
                          const Text('Toplam Puan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            '$_score',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Başarı Oranı', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            '%${accuracy.toStringAsFixed(0)}',
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
                      _score = 0;
                      _correctCount = 0;
                      _prepareQuestions();
                    });
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Yeni Cümlelerle Tekrar Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pinkAccent,
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
