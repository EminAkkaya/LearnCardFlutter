import '../flashcard_model.dart';

class SpeedQuizQuestionModel {
  final FlashcardModel card;
  final String targetWord;
  final String correctAnswer;
  final List<String> options;

  /// Ters yön: Türkçe karşılık sorulur, İngilizce kelime seçilir.
  final bool isReverse;

  SpeedQuizQuestionModel({
    required this.card,
    required this.targetWord,
    required this.correctAnswer,
    required this.options,
    this.isReverse = false,
  });
}
