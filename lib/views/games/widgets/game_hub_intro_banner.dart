import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';

/// Oyun merkezinin üstündeki sade giriş: başlık, kısa açıklama ve gerekçe.
class GameHubIntroBanner extends StatelessWidget {
  const GameHubIntroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bilişsel Öğrenme Oyunları',
          style: TextStyle(
            color: p.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'SRS algoritmasını etkilemeyen serbest pratik',
          style: TextStyle(color: p.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          'İkinci dil ediniminde aktif geri çağırma (Active Retrieval), çift kodlama ve bağlam içi pratik kelime kalıcılığını %80\'e kadar artırır.',
          style: TextStyle(color: p.textSecondary, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}
