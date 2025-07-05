import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:media_kit/media_kit.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/user_preferences_provider.dart';
import 'router/app_router.dart';
import 'config/config_manager.dart';
import 'services/web_database_importer.dart';
import 'services/virtual_file_system/vfs_database_initializer.dart';
import 'components/web/web_context_menu_handler.dart';
import 'services/legend_vfs/legend_compatibility_service.dart';
import 'services/window_manager_service.dart';

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
  // Initialize VFS system
  try {
    final vfsInitializer = VfsDatabaseInitializer();
    await vfsInitializer.initializeApplicationVfs();
    debugPrint('VFS系统初始化成功');

    // Initialize legend service to ensure proper mounting
    // final legendService = LegendCompatibilityService();
    // await legendService.initialize();
    // debugPrint('图例服务初始化成功');
  } catch (e) {
    debugPrint('VFS系统初始化失败: $e');
    // VFS初始化失败不应该阻止应用启动，只记录错误
  }

  // Initialize media_kit for video playback
  MediaKit.ensureInitialized();

  // Import data from assets for Web platform
  if (kIsWeb) {
    await WebDatabaseImporter.importFromAssets();
  }

  runApp(const R6BoxApp());
  
  // Initialize bitsdojo_window for desktop platforms
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    doWhenWindowReady(() {
      // 设置最小窗口大小
      appWindow.minSize = const Size(800, 600);
      // 不设置位置和对齐方式，完全让操作系统决定窗口位置
      appWindow.title = 'R6Box';
      appWindow.show();
      // 注意：不在这里设置窗口大小，让WindowManagerService在用户偏好加载后处理
    });
  }
}

class R6BoxApp extends StatelessWidget {
  const R6BoxApp({super.key});

  // Create the router instance once and make it static or store it
  // so it doesn't get recreated on widget rebuilds.
  // Assuming AppRouter.createRouter() returns a GoRouter instance or similar.
  static final _router = AppRouter.createRouter();
  
  // 标记窗口管理服务是否已初始化
  static bool _windowManagerInitialized = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..initLocale()),
        ChangeNotifierProvider(
          create: (_) => UserPreferencesProvider()..initialize(),
        ),
      ],
      child: Consumer3<ThemeProvider, LocaleProvider, UserPreferencesProvider>(
        builder: (context, themeProvider, localeProvider, userPrefsProvider, child) {
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

            // 只初始化一次窗口管理服务
            if (!_windowManagerInitialized) {
              WindowManagerService().initialize(userPrefsProvider);
              
              // 应用保存的窗口大小（仅在桌面平台）
              if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
                Future.microtask(() {
                  WindowManagerService().applyWindowSize();
                });
              }
              
              _windowManagerInitialized = true;
            }
          } // Use the pre-created router instance
          return WebContextMenuHandler(
            child: MaterialApp.router(
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
            ),
          );
        },
      ),
    );
  }
}
