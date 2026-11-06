import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/database/app_database.dart';
import '../models/user_stats_model.dart';

/// İstatistikleri kullanıcı başına yerel veritabanında saklar.
/// Misafir kullanıcı için [guestUserId] kullanılır.
class StatsService {
  static const String guestUserId = 'guest';

  /// Kullanıcı ayrımı öncesindeki tek ortak anahtar; ilk yükleyen hesaba taşınır.
  static const String legacyStatsKey = 'user_activity_stats_data';

  final AppDatabase? _database;

  const StatsService([this._database]);

  AppDatabase get _db => _database ?? appDatabase;

  static String keyFor(String userId) => '${legacyStatsKey}_$userId';

  Future<UserStatsModel> loadStats(String userId) async {
    try {
      var jsonStr = await _db.getString(keyFor(userId));
      if (jsonStr == null || jsonStr.isEmpty) {
        jsonStr = await _claimLegacyStats(userId);
      }
      if (jsonStr == null || jsonStr.isEmpty) {
        return const UserStatsModel();
      }
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserStatsModel.fromMap(map);
    } catch (e) {
      debugPrint('[stats] load failed for $userId: $e');
      return const UserStatsModel();
    }
  }

  /// Eski ortak kaydı bu kullanıcıya taşır ve ortak anahtarı kaldırır,
  /// böylece başka bir hesap aynı geçmişi devralmaz.
  Future<String?> _claimLegacyStats(String userId) async {
    final legacy = await _db.getString(legacyStatsKey);
    if (legacy == null || legacy.isEmpty) return null;
    await _db.setString(keyFor(userId), legacy);
    await _db.removeKey(legacyStatsKey);
    return legacy;
  }

  Future<void> saveStats(String userId, UserStatsModel stats) async {
    try {
      await _db.setString(keyFor(userId), jsonEncode(stats.toMap()));
    } catch (e) {
      debugPrint('[stats] save failed for $userId: $e');
    }
  }
}
