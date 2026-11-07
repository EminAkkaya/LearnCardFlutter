import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';

/// Tek tanıtım sayfası: başlığı tanıtan küçük ikon kutusu, başlık ve açıklama.
class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const OnboardingPage({super.key, required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 48),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: palette.subtle,
              borderRadius: BorderRadius.circular(AppPalette.radiusCard),
              border: Border.all(color: palette.border),
            ),
            child: Icon(icon, size: 24, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5, color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
