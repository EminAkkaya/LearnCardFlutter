import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import 'game_status_line.dart';

/// Oyun merkezindeki tek oyun kartı: sakin ikon kutusu, başlık + rozet,
/// açıklama ve kart yetersizse durum satırı.
class GameCardItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final int minCardsRequired;
  final int currentCardsCount;
  final VoidCallback onPlay;

  const GameCardItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.minCardsRequired,
    required this.currentCardsCount,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    final bool canPlay = currentCardsCount >= minCardsRequired;
    final radius = BorderRadius.circular(AppPalette.radiusCard);

    return Container(
      decoration: p.cardDecoration(),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: canPlay ? onPlay : null,
          borderRadius: radius,
          hoverColor: p.hover,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: p.subtle,
                    borderRadius: BorderRadius.circular(AppPalette.radiusControl),
                    border: Border.all(color: p.border),
                  ),
                  child: Icon(icon, color: canPlay ? p.accentGraphic : p.textMuted, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(child: _texts(p, canPlay)),
                const SizedBox(width: 8),
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: canPlay ? scheme.primary : p.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _texts(AppPalette p, bool canPlay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wrap: dar ekran / büyük yazıda rozet başlığın altına iner.
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: p.textPrimary),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: p.subtle,
                borderRadius: BorderRadius.circular(AppPalette.radiusPill),
                border: Border.all(color: p.border),
              ),
              child: Text(
                badge,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: p.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: p.textSecondary, height: 1.4),
        ),
        if (!canPlay) ...[
          const SizedBox(height: 6),
          GameStatusLine(
            icon: LucideIcons.circleAlert,
            text: 'Bu kategoride oynamaya yetecek kart yok',
            color: p.textMuted,
          ),
        ],
      ],
    );
  }
}
