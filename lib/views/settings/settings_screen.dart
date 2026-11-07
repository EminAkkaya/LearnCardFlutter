import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_palette.dart';
import '../../providers/theme_provider.dart';
import 'widgets/account_section_card.dart';
import 'widgets/app_info_card.dart';
import 'widgets/live_preview_card.dart';
import 'widgets/primary_color_picker_card.dart';
import 'widgets/settings_section_title.dart';
import 'widgets/theme_mode_selector_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AccountSectionCard(),
            const SizedBox(height: 16),
            LivePreviewCard(themeState: themeState),
            const SizedBox(height: 20),
            const SettingsSectionTitle(title: 'Görünüm Modu', icon: LucideIcons.sunMoon),
            const SizedBox(height: 10),
            const ThemeModeSelectorCard(),
            const SizedBox(height: 24),
            const SettingsSectionTitle(title: 'Ana Tema Rengi', icon: LucideIcons.palette),
            const SizedBox(height: 6),
            Text(
              'Uygulamanın vurgu ve buton renklerini kişiselleştirin',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, color: palette.textSecondary),
            ),
            const SizedBox(height: 12),
            const PrimaryColorPickerCard(),
            const SizedBox(height: 24),
            const SettingsSectionTitle(title: 'Uygulama Bilgisi', icon: LucideIcons.info),
            const SizedBox(height: 10),
            const AppInfoCard(),
            const SizedBox(height: 24),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  themeNotifier.setThemeMode(ThemeMode.dark);
                  themeNotifier.setPrimaryColor(ThemeNotifier.defaultPrimary);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tema varsayılan ayarlara sıfırlandı.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(LucideIcons.rotateCcw, size: 18),
                label: const Text('Varsayılan Temaya Dön'),
                style: TextButton.styleFrom(foregroundColor: palette.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
