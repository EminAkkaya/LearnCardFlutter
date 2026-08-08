import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/flashcard_provider.dart';
import '../settings/settings_screen.dart';

class StatsOverviewScreen extends ConsumerWidget {
  final Function(int tabIndex)? onNavigateToTab;

  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldAccent = Color(0xFF34D399);

  const StatsOverviewScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cardState = ref.watch(flashcardProvider);

    final totalCount = cardState.cards.length;
    final dueCount = cardState.dueCards.length;
    final masteredCount = cardState.masteredCards.length;
    final learningCount = cardState.learningCards.length;
    final newCount = cardState.newCards.length;

    final double masteryRatio = totalCount > 0 ? (masteredCount / totalCount) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Genel İstatistikler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Ayarlar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Öğrenme İlerlemesi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Icon(Icons.insights_rounded, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '%${(masteryRatio * 100).toStringAsFixed(0)} Ustalaşıldı',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$masteredCount / $totalCount Kelime',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: masteryRatio,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        color: emeraldAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Kart Durum Özeti',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: [
                _buildMetricCard(
                  context: context,
                  title: 'Bugün Tekrar',
                  value: '$dueCount',
                  icon: Icons.timer_rounded,
                  color: Colors.amber,
                  onTap: () => onNavigateToTab?.call(0),
                ),
                _buildMetricCard(
                  context: context,
                  title: 'Öğrenilen',
                  value: '$learningCount',
                  icon: Icons.auto_stories_rounded,
                  color: Colors.blue,
                  onTap: () => onNavigateToTab?.call(2),
                ),
                _buildMetricCard(
                  context: context,
                  title: 'Öğrenildi',
                  value: '$masteredCount',
                  icon: Icons.verified_rounded,
                  color: emerald,
                  onTap: () => onNavigateToTab?.call(2),
                ),
                _buildMetricCard(
                  context: context,
                  title: 'Yeni Kartlar',
                  value: '$newCount',
                  icon: Icons.fiber_new_rounded,
                  color: Colors.purple,
                  onTap: () => onNavigateToTab?.call(2),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Hızlı Eylemler',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.style_rounded, color: Colors.white),
                ),
                title: const Text('Gözden Geçirmeye Başla (SRS)'),
                subtitle: Text('Bugün tekrar edilmesi gereken $dueCount kart var'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onNavigateToTab?.call(0),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.menu_book_rounded, color: Colors.white),
                ),
                title: const Text('İnteraktif Okuyucuya Git'),
                subtitle: const Text('Metin oku ve dokunarak çevirileri gör'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onNavigateToTab?.call(1),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.deepOrange,
                  child: Icon(Icons.manage_search_rounded, color: Colors.white),
                ),
                title: const Text('Toplu Kelime Çıkarıcı'),
                subtitle: const Text('Metinden otomatik frekanslı kelimeler çıkar'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onNavigateToTab?.call(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  Icon(icon, color: color, size: 22),
                ],
              ),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
