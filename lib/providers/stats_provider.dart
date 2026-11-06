import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_activity_model.dart';
import '../models/user_stats_model.dart';
import '../services/stats_service.dart';

class StatsNotifier extends StateNotifier<UserStatsModel> {
  StatsNotifier() : super(const UserStatsModel()) {
    loadStats();
  }

  Future<void> loadStats() async {
    final loaded = await StatsService.loadStats();
    final verified = _checkStreakExpiry(loaded);
    state = verified;
    if (verified != loaded) {
      await StatsService.saveStats(verified);
    }
  }

  UserStatsModel _checkStreakExpiry(UserStatsModel current) {
    if (current.lastActiveDate.isEmpty) return current;

    final today = _todayDateString();
    final yesterday = _yesterdayDateString();

    // If last active was neither today nor yesterday, streak is broken
    if (current.lastActiveDate != today && current.lastActiveDate != yesterday) {
      return current.copyWith(currentStreak: 0);
    }
    return current;
  }

  String _todayDateString() => DateTime.now().toIso8601String().split('T')[0];

  String _yesterdayDateString() =>
      DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];

  Future<void> recordCardReviewed([int count = 1]) async {
    final today = _todayDateString();
    final activity = state.todayActivity;
    final updatedActivity = activity.copyWith(
      date: today,
      cardsReviewed: activity.cardsReviewed + count,
    );

    final updatedStats = _applyActivityAndStreak(today, updatedActivity);
    state = updatedStats;
    await StatsService.saveStats(updatedStats);
  }

  Future<void> recordCardAdded([int count = 1]) async {
    final today = _todayDateString();
    final activity = state.todayActivity;
    final updatedActivity = activity.copyWith(
      date: today,
      cardsAdded: activity.cardsAdded + count,
    );

    final updatedStats = _applyActivityAndStreak(today, updatedActivity);
    state = updatedStats;
    await StatsService.saveStats(updatedStats);
  }

  Future<void> recordGameScore(int score, {int gamesCount = 1}) async {
    final today = _todayDateString();
    final activity = state.todayActivity;
    final updatedActivity = activity.copyWith(
      date: today,
      gameScore: activity.gameScore + score,
      gamesPlayed: activity.gamesPlayed + gamesCount,
    );

    final updatedStats = _applyActivityAndStreak(
      today,
      updatedActivity,
      addedTotalScore: score,
      addedTotalGames: gamesCount,
    );
    state = updatedStats;
    await StatsService.saveStats(updatedStats);
  }

  Future<void> setDailyGoal(int goal) async {
    final updated = state.copyWith(dailyGoal: goal);
    state = updated;
    await StatsService.saveStats(updated);
  }

  UserStatsModel _applyActivityAndStreak(
    String today,
    DailyActivityModel updatedActivity, {
    int addedTotalScore = 0,
    int addedTotalGames = 0,
  }) {
    int streak = state.currentStreak;
    final yesterday = _yesterdayDateString();

    if (state.lastActiveDate == yesterday) {
      streak += 1;
    } else if (state.lastActiveDate != today) {
      streak = 1;
    }

    final longest = max(state.longestStreak, streak);
    final map = Map<String, DailyActivityModel>.from(state.dailyActivities);
    map[today] = updatedActivity;

    return state.copyWith(
      currentStreak: streak,
      longestStreak: longest,
      lastActiveDate: today,
      totalGameScore: state.totalGameScore + addedTotalScore,
      totalGamesPlayed: state.totalGamesPlayed + addedTotalGames,
      dailyActivities: map,
    );
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, UserStatsModel>((ref) {
  return StatsNotifier();
});
