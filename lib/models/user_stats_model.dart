import 'daily_activity_model.dart';

class UserStatsModel {
  final int currentStreak;
  final int longestStreak;
  final String lastActiveDate; // YYYY-MM-DD
  final int dailyGoal; // e.g. 20 cards/day
  final int totalGameScore;
  final int totalGamesPlayed;
  final Map<String, DailyActivityModel> dailyActivities;

  const UserStatsModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate = '',
    this.dailyGoal = 20,
    this.totalGameScore = 0,
    this.totalGamesPlayed = 0,
    this.dailyActivities = const {},
  });

  DailyActivityModel get todayActivity {
    final todayKey = DateTime.now().toIso8601String().split('T')[0];
    return dailyActivities[todayKey] ?? DailyActivityModel(date: todayKey);
  }

  double get todayGoalProgress {
    if (dailyGoal <= 0) return 1.0;
    return (todayActivity.cardsReviewed / dailyGoal).clamp(0.0, 1.0);
  }

  List<DailyActivityModel> get last7DaysActivities {
    final now = DateTime.now();
    final List<DailyActivityModel> list = [];

    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final dateKey = d.toIso8601String().split('T')[0];
      list.add(
        dailyActivities[dateKey] ?? DailyActivityModel(date: dateKey),
      );
    }
    return list;
  }

  UserStatsModel copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastActiveDate,
    int? dailyGoal,
    int? totalGameScore,
    int? totalGamesPlayed,
    Map<String, DailyActivityModel>? dailyActivities,
  }) {
    return UserStatsModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      totalGameScore: totalGameScore ?? this.totalGameScore,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      dailyActivities: dailyActivities ?? this.dailyActivities,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate,
      'dailyGoal': dailyGoal,
      'totalGameScore': totalGameScore,
      'totalGamesPlayed': totalGamesPlayed,
      'dailyActivities': dailyActivities.map((k, v) => MapEntry(k, v.toMap())),
    };
  }

  factory UserStatsModel.fromMap(Map<String, dynamic> map) {
    final rawMap = map['dailyActivities'] as Map<String, dynamic>? ?? {};
    final activities = rawMap.map(
      (k, v) => MapEntry(k, DailyActivityModel.fromMap(Map<String, dynamic>.from(v as Map))),
    );

    return UserStatsModel(
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (map['longestStreak'] as num?)?.toInt() ?? 0,
      lastActiveDate: map['lastActiveDate'] as String? ?? '',
      dailyGoal: (map['dailyGoal'] as num?)?.toInt() ?? 20,
      totalGameScore: (map['totalGameScore'] as num?)?.toInt() ?? 0,
      totalGamesPlayed: (map['totalGamesPlayed'] as num?)?.toInt() ?? 0,
      dailyActivities: activities,
    );
  }
}
