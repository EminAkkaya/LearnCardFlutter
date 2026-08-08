import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

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
            // Preview Card
            _buildLivePreviewCard(context, themeState),

            const SizedBox(height: 20),

            // Theme Mode Section
            _buildSectionTitle(context, 'Görünüm Modu', Icons.palette_outlined),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    _buildThemeModeTile(
                      context: context,
                      title: 'Karanlık Mod',
                      subtitle: 'Gözleri yormayan koyu renkler',
                      icon: Icons.dark_mode_rounded,
                      iconColor: Colors.indigoAccent,
                      isSelected: themeState.themeMode == ThemeMode.dark,
                      onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                    ),
                    const Divider(height: 1),
                    _buildThemeModeTile(
                      context: context,
                      title: 'Aydınlık Mod',
                      subtitle: 'Ferah ve açık renk paleti',
                      icon: Icons.light_mode_rounded,
                      iconColor: Colors.amber,
                      isSelected: themeState.themeMode == ThemeMode.light,
                      onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                    ),
                    const Divider(height: 1),
                    _buildThemeModeTile(
                      context: context,
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
            ),

            const SizedBox(height: 24),

            // Primary Theme Color Section
            _buildSectionTitle(
              context,
              'Ana Tema Rengi',
              Icons.color_lens_outlined,
            ),
            const SizedBox(height: 6),
            Text(
              'Uygulamanın vurgu ve buton renklerini kişiselleştirin',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 14,
                  children: ThemeNotifier.colorOptions.map((option) {
                    final isSelected =
                        themeState.primaryColor.value == option.color.value;
                    return InkWell(
                      onTap: () => themeNotifier.setPrimaryColor(option.color),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? option.color.withOpacity(0.15)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? option.color
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: option.color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: option.color.withOpacity(0.4),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              option.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? option.color
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Information Section
            _buildSectionTitle(
              context,
              'Uygulama Bilgisi',
              Icons.info_outline_rounded,
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: themeState.primaryColor.withOpacity(
                        0.15,
                      ),
                      child: Icon(
                        Icons.touch_app_rounded,
                        color: themeState.primaryColor,
                      ),
                    ),
                    title: const Text('Uygulama Adı'),
                    subtitle: const Text('LearnCard Mobile'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: themeState.primaryColor.withOpacity(
                        0.15,
                      ),
                      child: Icon(
                        Icons.vibration_rounded,
                        color: themeState.primaryColor,
                      ),
                    ),
                    title: const Text('Versiyon'),
                    subtitle: const Text('1.0.0+1'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: themeState.primaryColor.withOpacity(
                        0.15,
                      ),
                      child: Icon(
                        Icons.cloud_done_rounded,
                        color: themeState.primaryColor,
                      ),
                    ),
                    title: const Text('Veri Senkronizasyonu'),
                    subtitle: const Text('Supabase Cloud Aktif'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Reset Theme Button
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

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.15),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
    );
  }

  Widget _buildLivePreviewCard(BuildContext context, ThemeState themeState) {
    final primary = themeState.primaryColor;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Canlı Tema Önizleme',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  themeState.themeMode == ThemeMode.dark
                      ? 'Karanlık'
                      : themeState.themeMode == ThemeMode.light
                      ? 'Aydınlık'
                      : 'Sistem',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Seçilen ana renk tüm uygulama genelinde buton, vurgu ve kart rozetlerinde aktif olur.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check, size: 16, color: Colors.black87),
                label: const Text(
                  'Buton Örneği',
                  style: TextStyle(color: Colors.black87),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 8,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.7,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
