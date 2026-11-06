import '../../../models/flashcard_model.dart';

class SpeedQuizQuestionModel {
  final FlashcardModel card;
  final String targetWord;
  final String correctAnswer;
  final List<String> options;

  SpeedQuizQuestionModel({
    required this.card,
    required this.targetWord,
    required this.correctAnswer,
    required this.options,
  });
}
