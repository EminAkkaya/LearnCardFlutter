import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';

class ResendCountdownWidget extends StatelessWidget {
  final bool canResend;
  final int secondsRemaining;
  final bool isLoading;
  final VoidCallback onResend;

  const ResendCountdownWidget({
    super.key,
    required this.canResend,
    required this.secondsRemaining,
    required this.isLoading,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Kod gelmedi mi?',
          style: TextStyle(color: palette.textSecondary),
        ),
        const SizedBox(width: 4),
        canResend
            ? TextButton(
                onPressed: isLoading ? null : onResend,
                child: const Text(
                  'Kodu Tekrar Gönder',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Tekrar gönder (${secondsRemaining.toString().padLeft(2, '0')}s)',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: palette.textMuted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
      ],
    );
  }
}
