import '../flashcard_model.dart';

class WordMatchTileModel {
  final String id;
  final String cardId;
  final String text;
  final bool isEnglish;
  final FlashcardModel card;
  final bool isMatched;
  final bool isSelected;
  final bool isError;

  const WordMatchTileModel({
    required this.id,
    required this.cardId,
    required this.text,
    required this.isEnglish,
    required this.card,
    this.isMatched = false,
    this.isSelected = false,
    this.isError = false,
  });

  WordMatchTileModel copyWith({bool? isMatched, bool? isSelected, bool? isError}) {
    return WordMatchTileModel(
      id: id,
      cardId: cardId,
      text: text,
      isEnglish: isEnglish,
      card: card,
      isMatched: isMatched ?? this.isMatched,
      isSelected: isSelected ?? this.isSelected,
      isError: isError ?? this.isError,
    );
  }
}
