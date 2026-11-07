import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/providers/theme_provider.dart';

void main() {
  group('ThemeState & ThemeNotifier Options Tests', () {
    test('1. ThemeNotifier provides valid color palette options', () {
      final options = ThemeNotifier.colorOptions;

      expect(options, isNotEmpty);
      expect(options.length, greaterThanOrEqualTo(6));

      final names = options.map((o) => o.name).toList();
      expect(names, containsAll(['Adaçayı', 'Kiremit', 'Okyanus', 'Erik', 'Hardal', 'Toprak']));
      expect(options.first.color, ThemeNotifier.defaultPrimary);

      // Every option must have an opaque distinct color
      for (final option in options) {
        expect(option.name, isNotEmpty);
        expect(option.color, isNotNull);
      }
    });

    test('2. ThemeState immutability and copyWith work correctly', () {
      const state = ThemeState(
        themeMode: ThemeMode.dark,
        primaryColor: Color(0xFF6366F1),
      );

      final next = state.copyWith(
        themeMode: ThemeMode.light,
        primaryColor: const Color(0xFF10B981),
      );

      expect(next.themeMode, equals(ThemeMode.light));
      expect(next.primaryColor, equals(const Color(0xFF10B981)));

      expect(state.themeMode, equals(ThemeMode.dark));
      expect(state.primaryColor, equals(const Color(0xFF6366F1)));
    });
  });
}
