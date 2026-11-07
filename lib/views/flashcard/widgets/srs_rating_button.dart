import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';

/// Tek bir SRS derecelendirme butonu: renkli kenar + metin + sonraki aralık.
class SRSRatingButton extends StatelessWidget {
  final String label;
  final String days;
  final Color color;
  final VoidCallback onPressed;

  const SRSRatingButton({
    super.key,
    required this.label,
    required this.days,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final radius = BorderRadius.circular(AppPalette.radiusControl);

    return Expanded(
      child: Material(
        color: Color.alphaBlend(color.withValues(alpha: 0.10), palette.card),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: color.withValues(alpha: 0.55)),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      days,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: palette.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
