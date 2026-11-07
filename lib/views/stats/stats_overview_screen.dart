import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/stats_provider.dart';
import '../settings/settings_screen.dart';
import 'widgets/deck_distribution_card.dart';
import 'widgets/minigames_stats_card.dart';
import 'widgets/stats_quick_action_list.dart';
import 'widgets/streak_header_card.dart';
import 'widgets/today_activity_card.dart';
import 'widgets/weekly_activity_trend_card.dart';

class StatsOverviewScreen extends ConsumerWidget {
  final Function(int tabIndex)? onNavigateToTab;

  const StatsOverviewScreen({super.key, this.onNavigateToTab});

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardState = ref.watch(flashcardProvider);
    final userStats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelişim & İstatistikler'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, size: 20),
            tooltip: 'Ayarlar',
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(flashcardProvider.notifier).loadCards();
          await ref.read(statsProvider.notifier).loadStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreakHeaderCard(userStats: userStats),
              const SizedBox(height: 16),
              TodayActivityCard(todayActivity: userStats.todayActivity, onNavigateToTab: onNavigateToTab),
              const SizedBox(height: 16),
              WeeklyActivityTrendCard(activities: userStats.last7DaysActivities),
              const SizedBox(height: 16),
              DeckDistributionCard(cardState: cardState, onNavigateToTab: onNavigateToTab),
              const SizedBox(height: 16),
              MinigamesStatsCard(totalGameScore: userStats.totalGameScore, totalGamesPlayed: userStats.totalGamesPlayed),
              const SizedBox(height: 24),
              StatsQuickActionList(dueCount: cardState.dueCards.length, onNavigateToTab: onNavigateToTab),
            ],
          ),
        ),
      ),
    );
  }
}
