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
  /// Varsayılan vurgu: adaçayı. Seçenekler açık tema tonlarıdır; koyu karşılıkları
  /// `AppTheme.darkAccentFor` içinde. Hepsi krem yazıyla ≥ 4.5:1 kontrast verir.
  static const Color defaultPrimary = Color(0xFF4D6B5C);

  static const List<AppColorOption> colorOptions = [
    AppColorOption(name: 'Adaçayı', color: Color(0xFF4D6B5C)),
    AppColorOption(name: 'Kiremit', color: Color(0xFF98432E)),
    AppColorOption(name: 'Okyanus', color: Color(0xFF3F5F7A)),
    AppColorOption(name: 'Erik', color: Color(0xFF6B4A6E)),
    AppColorOption(name: 'Hardal', color: Color(0xFF7D550A)),
    AppColorOption(name: 'Toprak', color: Color(0xFF6F5340)),
  ];

  final AppDatabase _db;

  ThemeNotifier([AppDatabase? database])
      : _db = database ?? appDatabase,
        super(const ThemeState(
          themeMode: ThemeMode.system,
          primaryColor: defaultPrimary,
        )) {
    _loadTheme();
  }

  static const String _prefThemeKey = 'app_theme_mode';
  static const String _prefColorKey = 'app_primary_color';

  Future<void> _loadTheme() async {
    final String? isDarkStr = await _db.getString(_prefThemeKey);
    final int? colorValue = await _db.getInt(_prefColorKey);

    ThemeMode mode = ThemeMode.system;
    if (isDarkStr == 'light') {
      mode = ThemeMode.light;
    } else if (isDarkStr == 'dark') {
      mode = ThemeMode.dark;
    }

    // Eski paletten (indigo vb.) kalan seçim yeni tasarımda yok: varsayılana dön.
    Color color = defaultPrimary;
    if (colorValue != null && colorOptions.any((o) => o.color.toARGB32() == colorValue)) {
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
