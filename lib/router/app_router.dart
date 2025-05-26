import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../features/page_registry.dart';
import '../features/page-modules/home_page_module.dart';
import '../features/page-modules/settings_page_module.dart';
import '../components/layout/app_shell.dart';
import '../features/page-modules/config_editor_module.dart';

class AppRouter {  static GoRouter createRouter() {
    // 初始化页面注册
    _initializePages();
    
    // 从PageRegistry生成路由
    final pageRegistry = PageRegistry();
    final routes = pageRegistry.generateRoutes();
    
    return GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: routes,
        ),
      ],      errorBuilder: (context, state) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(l10n?.error ?? 'Error')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(l10n?.pageNotFound(state.uri.toString()) ?? 'Page not found: ${state.uri}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: Text(l10n?.goHome ?? 'Go Home'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// 初始化页面模块
  static void _initializePages() {
    final registry = PageRegistry();
    
    // 注册核心页面模块
    registry.register(HomePageModule());
    registry.register(SettingsPageModule());
    registry.register(ConfigEditorModule());
  }
}
