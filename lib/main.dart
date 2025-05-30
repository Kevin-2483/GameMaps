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

  // 初始化数据库工厂（根据平台）
  if (kIsWeb) {
    // Web 平台使用 ffi_web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // 桌面平台使用原生 ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // 移动平台（Android/iOS）使用默认的 sqflite
  // 初始化配置管理器
  await ConfigManager.instance.loadFromAssets();
  // Web平台从assets导入数据
  if (kIsWeb) {
    await WebDatabaseImporter.importFromAssets();
  }

  runApp(const R6BoxApp());
}

class R6BoxApp extends StatelessWidget {
  const R6BoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..initLocale()),
        ChangeNotifierProvider(create: (_) => UserPreferencesProvider()..initialize()),
      ],      child: Consumer3<ThemeProvider, LocaleProvider, UserPreferencesProvider>(
        builder: (context, themeProvider, localeProvider, userPrefsProvider, child) {
          // 当用户偏好设置加载完成后，建立与主题提供者的连接
          if (userPrefsProvider.isInitialized) {
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

          final router = AppRouter.createRouter();

          return MaterialApp.router(
            title: 'R6Box',
            debugShowCheckedModeBanner: false,

            // 路由配置
            routerConfig: router,
            // 主题配置
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.flutterThemeMode,
            // 国际化配置
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
