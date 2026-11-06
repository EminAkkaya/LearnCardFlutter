import 'package:flutter/material.dart';

class ThemeSliderControl extends StatelessWidget {
  final String title;
  final String badgeText;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color activeColor;
  final Color textColor;
  final Widget startIcon;
  final Widget endIcon;
  final ValueChanged<double> onChanged;

  const ThemeSliderControl({
    super.key,
    required this.title,
    required this.badgeText,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.activeColor,
    required this.textColor,
    required this.startIcon,
    required this.endIcon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            startIcon,
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                activeColor: activeColor,
                inactiveColor: textColor.withValues(alpha: 0.2),
                onChanged: onChanged,
              ),
            ),
            endIcon,
          ],
        ),
      ],
    );
  }
}
