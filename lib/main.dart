import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'router/app_router.dart';
import 'config/config_manager.dart';
import 'features/page_registry.dart';
import 'features/page-modules/home_page_module.dart';
import 'features/page-modules/settings_page_module.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化配置管理器
  await ConfigManager.instance.loadFromAssets();
  
  // 初始化页面注册系统
  _initializePageRegistry();
  
  runApp(const R6BoxApp());
}

/// 初始化页面注册系统
void _initializePageRegistry() {
  final registry = PageRegistry();
  
  // 注册核心页面模块
  registry.register(HomePageModule());
  registry.register(SettingsPageModule());
  
  // 可以在这里添加更多页面模块
}

class R6BoxApp extends StatelessWidget {
  const R6BoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..initTheme(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider()..initLocale(),
        ),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
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