import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/core/theme/app_theme.dart';
import 'package:learncard_flutter/providers/theme_provider.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('her seçilebilir ana renkte buton yazısı en az 4:1 kontrastlı', () {
    for (final option in ThemeNotifier.colorOptions) {
      for (final theme in [AppTheme.getLightTheme(option.color), AppTheme.getDarkTheme(option.color)]) {
        final cs = theme.colorScheme;
        expect(_contrast(cs.primary, cs.onPrimary), greaterThanOrEqualTo(4.0), reason: option.name);
      }
    }
  });
}
