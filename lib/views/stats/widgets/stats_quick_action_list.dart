import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';

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
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _QuickActionTile(
          icon: LucideIcons.layers,
          title: 'Gözden Geçirmeye Başla (SRS)',
          subtitle: 'Bugün tekrar edilmesi gereken $dueCount kart var',
          onTap: () => onNavigateToTab?.call(0),
        ),
        const SizedBox(height: 8),
        _QuickActionTile(
          icon: LucideIcons.bookOpen,
          title: 'İnteraktif Okuyucuya Git',
          subtitle: 'Metin oku ve dokunarak çevirileri gör',
          onTap: () => onNavigateToTab?.call(1),
        ),
        const SizedBox(height: 8),
        _QuickActionTile(
          icon: LucideIcons.gamepad2,
          title: 'Kelime Öğrenme Mini Oyunları',
          subtitle: 'Eşleştirme, Harf Dizici, Hızlı Test, Boşluk Doldurma',
          onTap: () => onNavigateToTab?.call(3),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: palette.subtle,
            borderRadius: BorderRadius.circular(AppPalette.radiusControl),
            border: Border.all(color: palette.border),
          ),
          child: Icon(icon, size: 20, color: scheme.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: palette.textSecondary),
        ),
        trailing: Icon(LucideIcons.chevronRight, size: 18, color: palette.textMuted),
        onTap: onTap,
      ),
    );
  }
}
