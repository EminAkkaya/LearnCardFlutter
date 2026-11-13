import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_palette.dart';

/// Alt navigasyon kabuğu: opak kart yüzeyi, üstte 1px kenarlık, seçili sekmede
/// `primaryContainer` göstergesi (tema `navigationBarTheme`).
class HomeNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;

  const HomeNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  static const _destinations = [
    (LucideIcons.layers, 'Tekrar'),
    (LucideIcons.bookOpen, 'Okuyucu'),
    (LucideIcons.library, 'Deste'),
    (LucideIcons.gamepad2, 'Oyunlar'),
    (LucideIcons.chartColumn, 'İstatistik'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: palette.border))),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTabTapped,
        backgroundColor: palette.card,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppPalette.radiusPill),
        ),
        animationDuration: AppPalette.motionBase,
        destinations: [
          for (final (icon, label) in _destinations)
            NavigationDestination(
              icon: Icon(icon, size: 22, color: palette.textSecondary),
              selectedIcon: Icon(icon, size: 22, color: scheme.primary),
              label: label,
            ),
        ],
      ),
    );
  }
}
