import 'package:flutter/material.dart';

/// Çocuğu mevcut yüksekliği dolduracak şekilde yerleştirir (içindeki `Spacer`'lar
/// çalışmaya devam eder); içerik sığmazsa (küçük ekran / büyük yazı) kaydırılır.
class FillOrScroll extends StatelessWidget {
  final Widget child;

  const FillOrScroll({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}
