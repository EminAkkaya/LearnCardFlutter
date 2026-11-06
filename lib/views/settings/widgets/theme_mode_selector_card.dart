import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/theme_provider.dart';
import 'theme_mode_tile.dart';

class ThemeModeSelectorCard extends ConsumerWidget {
  const ThemeModeSelectorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ThemeModeTile(
              title: 'Karanlık Mod',
              subtitle: 'Gözleri yormayan koyu renkler',
              icon: Icons.dark_mode_rounded,
              iconColor: Colors.indigoAccent,
              isSelected: themeState.themeMode == ThemeMode.dark,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
            ),
            const Divider(height: 1),
            ThemeModeTile(
              title: 'Aydınlık Mod',
              subtitle: 'Ferah ve açık renk paleti',
              icon: Icons.light_mode_rounded,
              iconColor: Colors.amber,
              isSelected: themeState.themeMode == ThemeMode.light,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
            ),
            const Divider(height: 1),
            ThemeModeTile(
              title: 'Sistem Teması',
              subtitle: 'Cihaz ayarlarını takip eder',
              icon: Icons.brightness_auto_rounded,
              iconColor: Colors.teal,
              isSelected: themeState.themeMode == ThemeMode.system,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
            ),
          ],
        ),
      ),
    );
  }
}
