import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';

/// Kelime detay sayfasındaki alan etiketi: 13px, 500, ikincil metin.
class WordDetailFieldLabel extends StatelessWidget {
  final String text;

  const WordDetailFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: AppPalette.of(context).textSecondary,
      ),
    );
  }
}
