import 'package:flutter/material.dart';
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
    final fb = FeedbackColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: fb.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 80,
                    color: fb.success,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tebrikler!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isCustomStudy
                      ? 'Özel çalışma seansı tamamlandı!'
                      : 'Bugün gözden geçirilecek tüm kartları başarıyla tamamladın.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    isCustomStudy
                        ? 'Aynı Seansı Tekrar Et'
                        : 'Kartları Yeniden Yükle',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                if (isCustomStudy) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Deste Yönetimine Dön'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
