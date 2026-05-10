import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  final sharedPrefs = await SharedPreferences.getInstance();
  final initialSkin = appThemeSkinFromStorageValue(
    sharedPrefs.getString(themeSkinPrefKey),
  );

  // Silent anonymous sign-in if no user is currently authenticated
  final supabase = Supabase.instance.client;
  if (supabase.auth.currentUser == null) {
    try {
      await supabase.auth.signInAnonymously();
    } catch (e) {
      debugPrint("Silent anonymous sign-in failed: $e");
    }
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('pl'),
        Locale('en', 'US'),
        Locale('en', 'GB'),
        Locale('de'),
        Locale('fr'),
        Locale('it'),
        Locale('es'),
        Locale('de', 'CH'),
        Locale('no'),
        Locale('is'),
        Locale('uk'),
        Locale('nl'),
        Locale('nl', 'BE'),
        Locale('de', 'AT'),
        Locale('cs'),
        Locale('sk'),
        Locale('sv'),
        Locale('da'),
        Locale('fi'),
        Locale('en', 'IE'),
        Locale('pt'),
        Locale('el'),
        Locale('hu'),
        Locale('ro'),
        Locale('bg'),
        Locale('hr'),
        Locale('lt'),
        Locale('lv'),
        Locale('et'),
        Locale('sl'),
        Locale('fr', 'LU'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      useFallbackTranslations: true,
      child: ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          initialThemeSkinProvider.overrideWithValue(initialSkin),
        ],
        child: const AuraCatchApp(),
      ),
    ),
  );
}

class AuraCatchApp extends ConsumerWidget {
  const AuraCatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider state to trigger rebuilds globally when it changes!
    ref.watch(themeProvider);
    final themeSkin = ref.read(themeProvider.notifier).currentThemeData;

    debugPrint("=== EasyLocalization resolved locale: ${context.locale} ===");
    debugPrint("=== Supported locales: ${context.supportedLocales} ===");

    return MaterialApp.router(
      title: 'Aura Catch',
      theme: themeSkin,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
