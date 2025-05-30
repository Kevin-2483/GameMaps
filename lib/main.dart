import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/user_preferences_provider.dart';
import 'router/app_router.dart';
import 'config/config_manager.dart';
import 'services/web_database_importer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory (based on platform)
  if (kIsWeb) {
    // Web platform uses ffi_web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Desktop platforms use native ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Mobile platforms (Android/iOS) use default sqflite

  // Initialize configuration manager
  await ConfigManager.instance.loadFromAssets();

  // Import data from assets for Web platform
  if (kIsWeb) {
    await WebDatabaseImporter.importFromAssets();
  }

  runApp(const R6BoxApp());
}

class R6BoxApp extends StatelessWidget {
  const R6BoxApp({super.key});

  // Create the router instance once and make it static or store it
  // so it doesn't get recreated on widget rebuilds.
  // Assuming AppRouter.createRouter() returns a GoRouter instance or similar.
  static final _router = AppRouter.createRouter();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..initLocale()),
        ChangeNotifierProvider(
            create: (_) => UserPreferencesProvider()..initialize()),
      ],
      child: Consumer3<ThemeProvider, LocaleProvider, UserPreferencesProvider>(
        builder: (context, themeProvider, localeProvider, userPrefsProvider,
            child) {
          // When user preferences are loaded, establish connection with ThemeProvider
          if (userPrefsProvider.isInitialized) {
            // It's generally good practice to ensure this connection setup
            // and the subsequent update don't cause unnecessary rebuild cycles.
            // The _isUpdatingFromUserPrefs flag in ThemeProvider helps,
            // and calling setThemeProvider ideally should be idempotent or guarded.
            userPrefsProvider.setThemeProvider(themeProvider);

            final theme = userPrefsProvider.theme;
            themeProvider.updateFromUserPreferences(
              themeMode: theme.themeMode,
              primaryColor: theme.primaryColor,
              useMaterialYou: theme.useMaterialYou,
              fontScale: theme.fontScale,
              highContrast: theme.highContrast,
            );
          }

          // Use the pre-created router instance
          return MaterialApp.router(
            title: 'R6Box',
            debugShowCheckedModeBanner: false,

            // Router configuration
            routerConfig: _router, // Use the stable router instance

            // Theme configuration
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.flutterThemeMode,

            // Internationalization configuration
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LocaleProvider.supportedLocales,
          );
        },
      ),
    );
  }
}