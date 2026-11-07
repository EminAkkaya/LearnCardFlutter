import 'package:flutter/material.dart';

/// Durum satırı: renk + ikon + metin üçlüsü (renge tek başına güvenilmez).
class GameStatusLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final double fontSize;

  const GameStatusLine({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: fontSize + 2, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500, color: color),
          ),
        ),
      ],
    );
  }
}
