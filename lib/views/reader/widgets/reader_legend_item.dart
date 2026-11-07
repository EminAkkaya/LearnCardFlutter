import 'package:flutter/material.dart';
import 'reader_word_style.dart';

/// Lejant öğesi: metindeki görünümün aynısı ("Aa" örneği: renk + alt çizgi
/// deseni) ve durum adı. Etiket renge değil temanın metin rengine yazılır.
class ReaderLegendItem extends StatelessWidget {
  final ReaderWordStyle look;
  final String label;
  final Color labelColor;

  const ReaderLegendItem({
    super.key,
    required this.look,
    required this.label,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Text(
            'Aa',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: look.color,
              decoration: TextDecoration.underline,
              decorationColor: look.underline,
              decorationStyle: look.pattern,
              decorationThickness: look.thickness,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
      ],
    );
  }
}
