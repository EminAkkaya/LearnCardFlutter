import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_palette.dart';
import '../../providers/onboarding_provider.dart';
import 'widgets/onboarding_page.dart';

/// İlk açılışta bir kez gösterilen üç sayfalık tanıtım.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const pages = [
    OnboardingPage(
      icon: LucideIcons.bookOpen,
      title: 'Okurken öğren',
      body: 'İngilizce bir metin yapıştır, bilmediğin kelimeye dokun: anlamı, okunuşu ve '
          'sesi anında açılır. Tek dokunuşla cümlesiyle birlikte destene ekle.',
    ),
    OnboardingPage(
      icon: LucideIcons.layers,
      title: 'Unutmadan tekrar et',
      body: 'Aralıklı tekrar, her kartı tam unutmak üzereyken karşına çıkarır. '
          'Günde birkaç dakika yeter.',
    ),
    OnboardingPage(
      icon: LucideIcons.gamepad2,
      title: 'Oyunlarla pekiştir',
      body: 'Eşleştirme, harf dizme, hızlı test ve boşluk doldurma. Yanlış bildiklerin '
          'otomatik olarak tekrar listene gider.',
    ),
  ];

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _page == OnboardingScreen.pages.length - 1;

  void _next() {
    if (_isLast) {
      ref.read(onboardingProvider.notifier).complete();
      return;
    }
    _controller.nextPage(duration: AppPalette.motionSlow, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => ref.read(onboardingProvider.notifier).complete(),
                style: TextButton.styleFrom(foregroundColor: palette.textSecondary),
                child: const Text('Atla'),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: OnboardingScreen.pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < OnboardingScreen.pages.length; i++)
                  AnimatedContainer(
                    duration: AppPalette.motionBase,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? scheme.primary : palette.border,
                      borderRadius: BorderRadius.circular(AppPalette.radiusPill),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_isLast ? 'Başla' : 'Devam'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
