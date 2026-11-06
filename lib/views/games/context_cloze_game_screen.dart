import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/audio_helper.dart';
import '../../models/flashcard_model.dart';
import '../../providers/stats_provider.dart';
import 'widgets/cloze_hud_bar.dart';
import 'widgets/cloze_options_list.dart';
import 'widgets/cloze_question_model.dart';
import 'widgets/cloze_sentence_card.dart';
import 'widgets/cloze_summary_view.dart';

class ContextClozeGameScreen extends ConsumerStatefulWidget {
  final List<FlashcardModel> cards;

  const ContextClozeGameScreen({super.key, required this.cards});

  @override
  ConsumerState<ContextClozeGameScreen> createState() => _ContextClozeGameScreenState();
}

class _ContextClozeGameScreenState extends ConsumerState<ContextClozeGameScreen> {
  List<ClozeQuestionModel> _questions = [];
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
    final List<ClozeQuestionModel> list = [];

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

      if (sentence.isEmpty) {
        if (card.definition.isNotEmpty) {
          sentence = 'It means: ${card.definition}. The key word is $targetWord.';
        } else {
          sentence = 'Understanding the word $targetWord is essential for communication.';
        }
      }

      final RegExp regExp = RegExp(
        r'\b' + RegExp.escape(targetWord) + r'(s|ed|ing|ly)?\b',
        caseSensitive: false,
      );
      final match = regExp.firstMatch(sentence);

      String before;
      String after;

      if (match != null) {
        before = sentence.substring(0, match.start);
        after = sentence.substring(match.end);
      } else {
        before = 'In modern contexts, ';
        after = ' plays a vital and noteworthy role.';
      }

      final distractors =
          allWords.where((w) => w != targetWord.toLowerCase()).toList()..shuffle();
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

      list.add(ClozeQuestionModel(
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
      ref.read(statsProvider.notifier).recordGameScore(_score);
      setState(() => _currentIndex++);
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
      return ClozeSummaryView(
        totalQuestions: _questions.length,
        correctCount: _correctCount,
        score: _score,
        onRestart: () {
          setState(() {
            _score = 0;
            _correctCount = 0;
            _prepareQuestions();
          });
        },
      );
    }

    final q = _questions[_currentIndex];
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
                    ClozeHudBar(
                      score: _score,
                      showHint: _showHint,
                      hintText: q.card.trTranslation.isNotEmpty ? q.card.trTranslation : q.card.definition,
                      onToggleHint: () => setState(() => _showHint = !_showHint),
                    ),
                    const SizedBox(height: 20),
                    ClozeSentenceCard(
                      question: q,
                      isAnswered: _isAnswered,
                      selectedOption: _selectedOption,
                    ),
                    const SizedBox(height: 28),
                    ClozeOptionsList(
                      question: q,
                      selectedOption: _selectedOption,
                      isAnswered: _isAnswered,
                      onOptionSelected: _onOptionSelected,
                    ),
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
