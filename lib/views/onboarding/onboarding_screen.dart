import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'widgets/onboarding_page.dart';

/// İlk açılışta bir kez gösterilen üç sayfalık tanıtım.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const pages = [
    OnboardingPage(
      icon: Icons.menu_book_rounded,
      title: 'Okurken öğren',
      body: 'İngilizce bir metin yapıştır, bilmediğin kelimeye dokun: anlamı, okunuşu ve '
          'sesi anında açılır. Tek dokunuşla cümlesiyle birlikte destene ekle.',
    ),
    OnboardingPage(
      icon: Icons.style_rounded,
      title: 'Unutmadan tekrar et',
      body: 'Aralıklı tekrar, her kartı tam unutmak üzereyken karşına çıkarır. '
          'Günde birkaç dakika yeter.',
    ),
    OnboardingPage(
      icon: Icons.sports_esports_rounded,
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
    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => ref.read(onboardingProvider.notifier).complete(),
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
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? scheme.primary : scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
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
