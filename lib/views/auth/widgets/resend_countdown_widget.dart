import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Kod gelmedi mi?',
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 4),
        canResend
            ? TextButton(
                onPressed: isLoading ? null : onResend,
                child: const Text(
                  'Kodu Tekrar Gönder',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Tekrar gönder (${secondsRemaining.toString().padLeft(2, '0')}s)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
      ],
    );
  }
}
