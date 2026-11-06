import 'package:flutter/material.dart';
import '../../games/mini_games_hub_screen.dart';

class StatsQuickActionList extends StatelessWidget {
  final int dueCount;
  final Function(int tabIndex)? onNavigateToTab;

  const StatsQuickActionList({
    super.key,
    required this.dueCount,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Eylemler',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
              backgroundColor: Color(0xFF6366F1),
              child: Icon(Icons.sports_esports_rounded, color: Colors.white),
            ),
            title: const Text('Kelime Öğrenme Mini Oyunları'),
            subtitle: const Text(
              'Eşleştirme, Harf Dizici, Hızlı Test, Boşluk Doldurma',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MiniGamesHubScreen(),
                ),
              );
            },
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
    );
  }
}
