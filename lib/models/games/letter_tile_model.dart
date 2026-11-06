class LetterTileModel {
  final int id;
  final String char;
  final bool isPlaced;

  const LetterTileModel({
    required this.id,
    required this.char,
    this.isPlaced = false,
  });

  LetterTileModel copyWith({bool? isPlaced}) {
    return LetterTileModel(
      id: id,
      char: char,
      isPlaced: isPlaced ?? this.isPlaced,
    );
  }
}
