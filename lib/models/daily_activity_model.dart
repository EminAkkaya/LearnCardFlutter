class DailyActivityModel {
  final String date; // YYYY-MM-DD
  final int cardsReviewed;
  final int cardsAdded;
  final int gameScore;
  final int gamesPlayed;

  const DailyActivityModel({
    required this.date,
    this.cardsReviewed = 0,
    this.cardsAdded = 0,
    this.gameScore = 0,
    this.gamesPlayed = 0,
  });

  DailyActivityModel copyWith({
    String? date,
    int? cardsReviewed,
    int? cardsAdded,
    int? gameScore,
    int? gamesPlayed,
  }) {
    return DailyActivityModel(
      date: date ?? this.date,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      cardsAdded: cardsAdded ?? this.cardsAdded,
      gameScore: gameScore ?? this.gameScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'cardsReviewed': cardsReviewed,
      'cardsAdded': cardsAdded,
      'gameScore': gameScore,
      'gamesPlayed': gamesPlayed,
    };
  }

  factory DailyActivityModel.fromMap(Map<String, dynamic> map) {
    return DailyActivityModel(
      date: map['date'] as String? ?? '',
      cardsReviewed: (map['cardsReviewed'] as num?)?.toInt() ?? 0,
      cardsAdded: (map['cardsAdded'] as num?)?.toInt() ?? 0,
      gameScore: (map['gameScore'] as num?)?.toInt() ?? 0,
      gamesPlayed: (map['gamesPlayed'] as num?)?.toInt() ?? 0,
    );
  }
}
