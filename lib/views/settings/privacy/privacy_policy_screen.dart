import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';

/// Uygulama içi gizlilik politikası. Metin docs/PRIVACY_POLICY.md ile aynı
/// tutulmalıdır; mağazalar ayrıca herkese açık bir URL ister (RELEASE.md §6).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = <(String, String)>[
    (
      'Misafir modu',
      'Hesap açmadan kullanabilirsin. Bu durumda kartların, metinlerin ve istatistiklerin '
          'yalnızca cihazında saklanır.',
    ),
    (
      'Hesap açarsan',
      'E-posta adresini giriş ve hesap doğrulama için; kelime kartlarını, tekrar geçmişini ve '
          'kaydettiğin metinleri cihazların arasında senkronize etmek için saklarız. Bu veriler '
          'Supabase altyapısında tutulur.',
    ),
    (
      'Üçüncü taraf servisler',
      'Türkçe karşılıklar uygulamanın içindeki sözlükten gelir. Bir kelimeye dokunduğunda İngilizce '
          'tanım ve telaffuz için yalnızca o kelime dictionaryapi.dev\'e gönderilir. Kelime sözlükte '
          'yoksa ya da sen istersen, çeviri için MyMemory ve Google çeviri servislerine de gönderilir. '
          'Bu servislere kimlik bilgin gönderilmez.',
    ),
    (
      'Yapmadıklarımız',
      'Reklam göstermiyoruz, analitik veya takip aracı kullanmıyoruz, verilerini satmıyor ya da '
          'paylaşmıyoruz.',
    ),
    (
      'Silme hakkın',
      'Hesabını ve tüm verilerini Ayarlar → Hesabı Sil ile istediğin zaman kalıcı olarak '
          'silebilirsin. Misafir verileri uygulamayı kaldırınca cihazdan silinir.',
    ),
    (
      'Çocuklar',
      'Uygulama 13 yaş altına yönelik değildir ve bilerek bu yaştaki çocuklardan veri toplamaz.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Gizlilik Politikası')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            for (final (title, body) in _sections) ...[
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: palette.textSecondary),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
