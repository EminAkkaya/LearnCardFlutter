import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';

class ReviewCompletionView extends StatelessWidget {
  final bool isCustomStudy;
  final VoidCallback onRestart;

  const ReviewCompletionView({
    super.key,
    required this.isCustomStudy,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final fb = FeedbackColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: palette.cardDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: fb.successContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.circleCheckBig, size: 28, color: fb.success),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tebrikler!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCustomStudy
                          ? 'Özel çalışma seansı tamamlandı!'
                          : 'Bugün gözden geçirilecek tüm kartları başarıyla tamamladın.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: onRestart,
                      icon: const Icon(LucideIcons.rotateCcw, size: 18),
                      label: Text(
                        isCustomStudy
                            ? 'Aynı Seansı Tekrar Et'
                            : 'Kartları Yeniden Yükle',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    if (isCustomStudy) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.arrowLeft, size: 18),
                        label: const Text('Deste Yönetimine Dön'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
