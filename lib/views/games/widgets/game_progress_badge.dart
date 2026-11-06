import 'package:flutter/material.dart';

/// AppBar sağındaki "3/10" soru sayacı.
class GameProgressBadge extends StatelessWidget {
  final int current;
  final int total;

  const GameProgressBadge({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$current/$total',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimaryContainer,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
