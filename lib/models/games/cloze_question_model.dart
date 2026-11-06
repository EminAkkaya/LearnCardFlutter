import '../flashcard_model.dart';

class ClozeQuestionModel {
  final FlashcardModel card;
  final String sentenceBefore;
  final String sentenceAfter;
  final String correctWord;
  final List<String> options;

  ClozeQuestionModel({
    required this.card,
    required this.sentenceBefore,
    required this.sentenceAfter,
    required this.correctWord,
    required this.options,
  });
}
