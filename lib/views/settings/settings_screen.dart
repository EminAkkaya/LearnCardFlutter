import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AccountSectionCard(),
            const SizedBox(height: 16),
            LivePreviewCard(themeState: themeState),
            const SizedBox(height: 20),
            const SettingsSectionTitle(title: 'Görünüm Modu', icon: Icons.palette_outlined),
            const SizedBox(height: 10),
            const ThemeModeSelectorCard(),
            const SizedBox(height: 24),
            const SettingsSectionTitle(title: 'Ana Tema Rengi', icon: Icons.color_lens_outlined),
            const SizedBox(height: 6),
            Text(
              'Uygulamanın vurgu ve buton renklerini kişiselleştirin',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 12),
            const PrimaryColorPickerCard(),
            const SizedBox(height: 24),
            const SettingsSectionTitle(title: 'Uygulama Bilgisi', icon: Icons.info_outline_rounded),
            const SizedBox(height: 10),
            AppInfoCard(primaryColor: themeState.primaryColor),
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
                icon: const Icon(Icons.restore_rounded, size: 18),
                label: const Text('Varsayılan Temaya Dön'),
                style: TextButton.styleFrom(foregroundColor: theme.hintColor),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
