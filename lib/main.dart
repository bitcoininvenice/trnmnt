import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'core/database/app_database.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/database_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/core/services/analytics_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/env/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Environment variables are now handled by Envied (obfuscated)

  // Initialize Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supaKey,
  );
  
  
  // Setup Anonymous Auth (Device-as-Account)
  try {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      await Supabase.instance.client.auth.signInAnonymously();
    }
  } catch (e) {
  }

  // Initialize Analytics AFTER Auth
  await AnalyticsService.init();
  
  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
      child: AppLifecycleObserver(
        child: TrnmntApp(),
      ),
    ),
  );
}

class AppLifecycleObserver extends StatefulWidget {
  final Widget child;
  const AppLifecycleObserver({super.key, required this.child});

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      AnalyticsService.endSession();
    } else if (state == AppLifecycleState.resumed) {
      AnalyticsService.startSession();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
        home: const _ModernDatabaseLoading(),
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
              Locale('es', ''),
              Locale('fr', ''),
            ],
            routerConfig: router,
          );
        },
    );
  }
}

class _ModernDatabaseLoading extends StatelessWidget {
  const _ModernDatabaseLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withValues(alpha: 0.8),
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background ball
            Positioned(
              left: -50,
              bottom: -50,
              child: Icon(
                Icons.sports_basketball,
                size: 250,
                color: colorScheme.primary.withValues(alpha: 0.05),
              ),
            ),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The Spinning Basketball
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.sports_basketball,
                      size: 100,
                      color: colorScheme.primary,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 2.seconds)
                  .shimmer(delay: 1.seconds, duration: 1.5.seconds, color: Colors.white24)
                  .scale(duration: 600.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), curve: Curves.elasticOut),
                  
                  const SizedBox(height: 48),
                  
                  // Text elements
                  Text(
                    'TRNMNT',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                  ).animate().fadeIn(delay: 300.ms).moveY(begin: 10, end: 0),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    height: 2,
                    width: 40,
                    color: colorScheme.primary,
                  ).animate().fadeIn(delay: 500.ms).scaleX(begin: 0, end: 1),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                   'PREPARAZIONE CAMPO...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w300,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .fadeIn(duration: 1.seconds)
                   .blur(begin: const Offset(0, 0), end: const Offset(1, 1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
