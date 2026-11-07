import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'providers/sync_status_provider.dart';
import 'providers/theme_provider.dart';
import 'views/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with the exact project URL & Key
  var cloudAvailable = true;
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    cloudAvailable = false;
    debugPrint('Supabase initialization error: $e');
  }

  runApp(ProviderScope(
    overrides: [cloudAvailableProvider.overrideWithValue(cloudAvailable)],
    child: const LearnCardApp(),
  ));
}

class LearnCardApp extends ConsumerWidget {
  const LearnCardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'LearnCard',
      debugShowCheckedModeBanner: false,
      // Arayüz yalnız Türkçe; sistem metinleri (kopyala/yapıştır, geri vb.) de Türkçe olsun.
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.getLightTheme(themeState.primaryColor),
      darkTheme: AppTheme.getDarkTheme(themeState.primaryColor),
      themeMode: themeState.themeMode,
      home: const AuthGate(),
    );
  }
}
