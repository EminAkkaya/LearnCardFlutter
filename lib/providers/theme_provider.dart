import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';

class AppColorOption {
  final String name;
  final Color color;

  const AppColorOption({required this.name, required this.color});
}

class ThemeState {
  final ThemeMode themeMode;
  final Color primaryColor;

  const ThemeState({
    required this.themeMode,
    required this.primaryColor,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const Color defaultPrimary = Color(0xFF6366F1); // Indigo

  static const List<AppColorOption> colorOptions = [
    AppColorOption(name: 'İndigo', color: Color(0xFF6366F1)),
    AppColorOption(name: 'Okyanus', color: Color(0xFF2563EB)),
    AppColorOption(name: 'Zümrüt', color: Color(0xFF10B981)),
    AppColorOption(name: 'Turuncu', color: Color(0xFFF97316)),
    AppColorOption(name: 'Gül', color: Color(0xFFEC4899)),
    AppColorOption(name: 'Asil Mor', color: Color(0xFF8B5CF6)),
    AppColorOption(name: 'Camgöbeği', color: Color(0xFF06B6D4)),
    AppColorOption(name: 'Kırmızı', color: Color(0xFFEF4444)),
  ];

  final AppDatabase _db;

  ThemeNotifier([AppDatabase? database])
      : _db = database ?? appDatabase,
        super(const ThemeState(
          themeMode: ThemeMode.dark,
          primaryColor: defaultPrimary,
        )) {
    _loadTheme();
  }

  static const String _prefThemeKey = 'app_theme_mode';
  static const String _prefColorKey = 'app_primary_color';

  Future<void> _loadTheme() async {
    final String? isDarkStr = await _db.getString(_prefThemeKey);
    final int? colorValue = await _db.getInt(_prefColorKey);

    ThemeMode mode = ThemeMode.dark;
    if (isDarkStr == 'light') {
      mode = ThemeMode.light;
    } else if (isDarkStr == 'system') {
      mode = ThemeMode.system;
    } else {
      mode = ThemeMode.dark;
    }

    Color color = defaultPrimary;
    if (colorValue != null) {
      color = Color(colorValue);
    }

    state = ThemeState(themeMode: mode, primaryColor: color);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    String val = 'dark';
    if (mode == ThemeMode.light) val = 'light';
    if (mode == ThemeMode.system) val = 'system';
    await _db.setString(_prefThemeKey, val);
  }

  Future<void> setPrimaryColor(Color color) async {
    state = state.copyWith(primaryColor: color);
    await _db.setInt(_prefColorKey, color.toARGB32());
  }

  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ThemeNotifier(db);
});
