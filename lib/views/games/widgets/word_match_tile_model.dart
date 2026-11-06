import '../../../models/flashcard_model.dart';

class WordMatchTileModel {
  final String id;
  final String cardId;
  final String text;
  final bool isEnglish;
  final FlashcardModel card;
  bool isMatched = false;
  bool isSelected = false;
  bool isError = false;

  WordMatchTileModel({
    required this.id,
    required this.cardId,
    required this.text,
    required this.isEnglish,
    required this.card,
  });
}
