import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../privacy/privacy_policy_screen.dart';

/// Uygulama adı, sürüm, veri kaynakları ve gizlilik politikası bağlantısı.
class AppInfoCard extends StatelessWidget {
  const AppInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const _InfoTile(icon: LucideIcons.layers, title: 'Uygulama Adı', subtitle: 'LearnCard'),
          const Divider(height: 1),
          const _InfoTile(icon: LucideIcons.tag, title: 'Versiyon', subtitle: '1.0.0+1'),
          const Divider(height: 1),
          const _InfoTile(
            icon: LucideIcons.cloudCheck,
            title: 'Veri Senkronizasyonu',
            subtitle: 'Supabase Cloud + Drift SQLite',
          ),
          const Divider(height: 1),
          const _InfoTile(
            icon: LucideIcons.bookA,
            title: 'Sözlük Verisi',
            subtitle: 'Wiktionary katkıcıları · CC BY-SA 4.0',
          ),
          const Divider(height: 1),
          _InfoTile(
            icon: LucideIcons.shieldCheck,
            title: 'Gizlilik Politikası',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _InfoTile({required this.icon, required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return ListTile(
      leading: Icon(icon, size: 20, color: palette.textSecondary),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: palette.textPrimary),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: TextStyle(fontSize: 13, color: palette.textSecondary)),
      trailing: onTap == null
          ? null
          : Icon(LucideIcons.chevronRight, size: 18, color: palette.textSecondary),
      onTap: onTap,
    );
  }
}
