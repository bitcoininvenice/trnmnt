import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/database_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize SQLCipher (encryption)
  try {
    await AppDatabase.initializeSqlCipher();
  } catch (e) {
    debugPrint('Error initializing SQLCipher: $e');
  }

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF16213E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: TrnmntApp(),
    ),
  );
}

class TrnmntApp extends ConsumerWidget {
  const TrnmntApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbAsync = ref.watch(databaseProvider);
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    ThemeData getTheme() {
      switch (themeMode) {
        case AppThemeMode.light:
          return AppTheme.lightTheme;
        case AppThemeMode.dark:
          return AppTheme.trueDarkTheme;
        case AppThemeMode.base:
        default:
          return AppTheme.baseTheme;
      }
    }

    return dbAsync.when(
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: getTheme(),
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 24),
                Text('Inizializzazione database...'),
              ],
            ),
          ),
        ),
      ),
      error: (error, stack) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: getTheme(),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Errore di inizializzazione',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
        data: (_) {
          final locale = ref.watch(localeProvider);
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'TRNMNT',
            theme: getTheme(),
            locale: locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('it', ''),
              Locale('en', ''),
            ],
            routerConfig: router,
          );
        },
    );
  }
}
