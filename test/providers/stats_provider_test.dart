import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/core/database/app_database.dart';
import 'package:learncard_flutter/models/daily_activity_model.dart';
import 'package:learncard_flutter/models/user_stats_model.dart';
import 'package:learncard_flutter/providers/stats_provider.dart';
import 'package:learncard_flutter/services/stats_service.dart';
import 'package:sqlite3/open.dart';

/// Yüklemeyi dışarıdan bırakılana kadar bekleten servis.
class _GatedStatsService extends StatsService {
  final Completer<void> gate = Completer<void>();
  _GatedStatsService(super.db);

  @override
  Future<UserStatsModel> loadStats(String userId) async {
    await gate.future;
    return super.loadStats(userId);
  }
}

String _day(int daysAgo) =>
    DateTime.now().subtract(Duration(days: daysAgo)).toIso8601String().split('T')[0];

UserStatsModel _history() {
  final yesterday = _day(1);
  return UserStatsModel(
    currentStreak: 5,
    longestStreak: 9,
    lastActiveDate: yesterday,
    dailyActivities: {
      yesterday: DailyActivityModel(date: yesterday, cardsReviewed: 12),
    },
  );
}

void main() {
  setUpAll(() {
    if (Platform.isLinux) {
      open.overrideFor(OperatingSystem.linux, () {
        try {
          return DynamicLibrary.open('libsqlite3.so');
        } catch (_) {
          return DynamicLibrary.open('libsqlite3.so.0');
        }
      });
    }
  });

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('record before the initial load finishes keeps loaded streak and history', () async {
    await StatsService(db).saveStats('u1', _history());

    final service = _GatedStatsService(db);
    final notifier = StatsNotifier(service: service, userId: 'u1');
    final recording = notifier.recordCardReviewed();

    service.gate.complete();
    await recording;

    expect(notifier.state.currentStreak, 6);
    expect(notifier.state.longestStreak, 9);
    expect(notifier.state.dailyActivities[_day(1)]?.cardsReviewed, 12);
    expect(notifier.state.todayActivity.cardsReviewed, 1);

    final stored = await StatsService(db).loadStats('u1');
    expect(stored.currentStreak, 6);
    expect(stored.dailyActivities[_day(1)]?.cardsReviewed, 12);
    notifier.dispose();
  });

  test('stats are stored per user and switching users reloads', () async {
    final service = StatsService(db);
    await service.saveStats('u1', _history());

    final notifier = StatsNotifier(service: service, userId: 'guest');
    await notifier.loadStats();
    expect(notifier.state.currentStreak, 0);

    await notifier.recordCardAdded(3);
    expect(notifier.state.todayActivity.cardsAdded, 3);

    await notifier.switchUser('u1');
    expect(notifier.state.currentStreak, 5);
    expect(notifier.state.todayActivity.cardsAdded, 0);

    await notifier.switchUser('guest');
    expect(notifier.state.todayActivity.cardsAdded, 3);
    expect(notifier.state.currentStreak, 1);

    expect((await service.loadStats('u2')).dailyActivities, isEmpty);
    notifier.dispose();
  });

  test('a record queued before a user switch is saved to the original user', () async {
    final service = StatsService(db);
    final notifier = StatsNotifier(service: service, userId: 'u1');

    final recording = notifier.recordCardReviewed(4);
    final switching = notifier.switchUser('u2');
    await Future.wait([recording, switching]);

    expect(notifier.userId, 'u2');
    expect(notifier.state.todayActivity.cardsReviewed, 0);
    expect((await service.loadStats('u1')).todayActivity.cardsReviewed, 4);
    notifier.dispose();
  });

  test('legacy shared stats are claimed once by the first loader', () async {
    await db.setString(StatsService.legacyStatsKey, '{"currentStreak": 2, "longestStreak": 4}');
    final service = StatsService(db);

    expect((await service.loadStats('u1')).longestStreak, 4);
    expect((await service.loadStats('u2')).longestStreak, 0);
    expect((await service.loadStats('u1')).longestStreak, 4);
  });
}
