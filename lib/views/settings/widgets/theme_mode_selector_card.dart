import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../providers/theme_provider.dart';
import 'theme_mode_tile.dart';

class ThemeModeSelectorCard extends ConsumerWidget {
  const ThemeModeSelectorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ThemeModeTile(
              title: 'Karanlık Mod',
              subtitle: 'Gözleri yormayan koyu renkler',
              icon: LucideIcons.moon,
              isSelected: themeState.themeMode == ThemeMode.dark,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
            ),
            const SizedBox(height: 4),
            ThemeModeTile(
              title: 'Aydınlık Mod',
              subtitle: 'Ferah ve açık renk paleti',
              icon: LucideIcons.sun,
              isSelected: themeState.themeMode == ThemeMode.light,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
            ),
            const SizedBox(height: 4),
            ThemeModeTile(
              title: 'Sistem Teması',
              subtitle: 'Cihaz ayarlarını takip eder',
              icon: LucideIcons.monitor,
              isSelected: themeState.themeMode == ThemeMode.system,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
            ),
          ],
        ),
      ),
    );
  }
}
