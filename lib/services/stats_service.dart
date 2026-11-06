import 'dart:convert';
import '../core/database/app_database.dart';
import '../models/user_stats_model.dart';

class StatsService {
  static const String _statsKey = 'user_activity_stats_data';

  static Future<UserStatsModel> loadStats() async {
    try {
      final jsonStr = await appDatabase.getString(_statsKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        return const UserStatsModel();
      }
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserStatsModel.fromMap(map);
    } catch (_) {
      return const UserStatsModel();
    }
  }

  static Future<void> saveStats(UserStatsModel stats) async {
    try {
      final jsonStr = jsonEncode(stats.toMap());
      await appDatabase.setString(_statsKey, jsonStr);
    } catch (_) {}
  }
}
