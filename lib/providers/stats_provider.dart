import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_activity_model.dart';
import '../models/user_stats_model.dart';
import '../services/stats_service.dart';
import 'auth_provider.dart';

/// Kullanıcı başına çalışma istatistikleri. Yükleme ve kayıt işlemleri sıraya
/// alınır: ilk yükleme bitmeden gelen bir `record*` çağrısı yüklenen veriyi
/// bekler, varsayılan durumla geçmişi ezmez.
class StatsNotifier extends StateNotifier<UserStatsModel> {
  final StatsService _service;
  String _userId;
  Future<void> _queue = Future.value();

  StatsNotifier({
    StatsService service = const StatsService(),
    String userId = StatsService.guestUserId,
    bool autoLoad = true,
  })  : _service = service,
        _userId = userId,
        super(const UserStatsModel()) {
    if (autoLoad) loadStats();
  }

  String get userId => _userId;

  Future<void> _enqueue(Future<void> Function() op) {
    final result = _queue.then((_) => op());
    _queue = result.catchError((_) {});
    return result;
  }

  Future<void> loadStats() {
    final userId = _userId;
    return _enqueue(() async {
      final loaded = await _service.loadStats(userId);
      final verified = _checkStreakExpiry(loaded);
      if (mounted && userId == _userId) state = verified;
      if (verified != loaded) {
        await _service.saveStats(userId, verified);
      }
    });
  }

  /// Oturum değişince başka kullanıcının istatistiklerine geçer.
  Future<void> switchUser(String userId) {
    if (userId == _userId) return _queue;
    _userId = userId;
    state = const UserStatsModel();
    return loadStats();
  }

  /// [update] her zaman ait olduğu kullanıcının güncel verisine uygulanır.
  Future<void> _record(UserStatsModel Function(UserStatsModel base) update) {
    final userId = _userId;
    return _enqueue(() async {
      final isCurrent = userId == _userId;
      final base = isCurrent ? state : await _service.loadStats(userId);
      final updated = update(base);
      if (mounted && isCurrent && userId == _userId) state = updated;
      await _service.saveStats(userId, updated);
    });
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

  Future<void> recordCardReviewed([int count = 1]) {
    return _record((base) {
      final today = _todayDateString();
      final activity = base.todayActivity;
      final updatedActivity = activity.copyWith(
        date: today,
        cardsReviewed: activity.cardsReviewed + count,
      );
      return _applyActivityAndStreak(base, today, updatedActivity);
    });
  }

  Future<void> recordCardAdded([int count = 1]) {
    return _record((base) {
      final today = _todayDateString();
      final activity = base.todayActivity;
      final updatedActivity = activity.copyWith(
        date: today,
        cardsAdded: activity.cardsAdded + count,
      );
      return _applyActivityAndStreak(base, today, updatedActivity);
    });
  }

  Future<void> recordGameScore(int score, {int gamesCount = 1}) {
    return _record((base) {
      final today = _todayDateString();
      final activity = base.todayActivity;
      final updatedActivity = activity.copyWith(
        date: today,
        gameScore: activity.gameScore + score,
        gamesPlayed: activity.gamesPlayed + gamesCount,
      );
      return _applyActivityAndStreak(
        base,
        today,
        updatedActivity,
        addedTotalScore: score,
        addedTotalGames: gamesCount,
      );
    });
  }

  Future<void> setDailyGoal(int goal) {
    return _record((base) => base.copyWith(dailyGoal: goal));
  }

  UserStatsModel _applyActivityAndStreak(
    UserStatsModel base,
    String today,
    DailyActivityModel updatedActivity, {
    int addedTotalScore = 0,
    int addedTotalGames = 0,
  }) {
    int streak = base.currentStreak;
    final yesterday = _yesterdayDateString();

    if (base.lastActiveDate == yesterday) {
      streak += 1;
    } else if (base.lastActiveDate != today) {
      streak = 1;
    }

    final longest = max(base.longestStreak, streak);
    final map = Map<String, DailyActivityModel>.from(base.dailyActivities);
    map[today] = updatedActivity;

    return base.copyWith(
      currentStreak: streak,
      longestStreak: longest,
      lastActiveDate: today,
      totalGameScore: base.totalGameScore + addedTotalScore,
      totalGamesPlayed: base.totalGamesPlayed + addedTotalGames,
      dailyActivities: map,
    );
  }
}

/// Oturumdaki kullanıcının istatistik anahtarı; misafir veya oturumsuzsa 'guest'.
String statsUserIdFor(AppAuthState auth) =>
    auth.user?.id ?? StatsService.guestUserId;

final statsProvider = StateNotifierProvider<StatsNotifier, UserStatsModel>((ref) {
  final notifier = StatsNotifier(userId: statsUserIdFor(ref.read(authProvider)));
  ref.listen<AppAuthState>(authProvider, (previous, next) {
    notifier.switchUser(statsUserIdFor(next));
  });
  return notifier;
});
