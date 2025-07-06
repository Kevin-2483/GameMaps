import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../features/page_registry.dart';
import '../features/page-modules/home_page_module.dart';
import '../features/page-modules/settings_page_module.dart';
import '../features/page-modules/user_preferences_page_module.dart';
import '../features/page-modules/map_atlas_page_module.dart';
import '../features/page-modules/legend_manager_page_module.dart';
import '../features/page-modules/config_editor_module.dart';
import '../features/page-modules/about_page_module.dart';
// import '../features/page-modules/fullscreen_test_page_module.dart';
// import '../features/page-modules/web_context_menu_demo_page_module.dart';
import '../features/page-modules/vfs_file_manager_page_module.dart';
import '../features/page-modules/markdown_renderer_demo_page_module.dart';
import '../features/page-modules/svg_test_page_module.dart';
import '../features/page-modules/external_resources_page_module.dart';
import '../components/layout/app_shell.dart';

class AppRouter {
  static GoRouter createRouter() {
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
      ],
      errorBuilder: (context, state) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(l10n?.error ?? 'Error')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  l10n?.pageNotFound(state.uri.toString()) ??
                      'Page not found: ${state.uri}',
                ),
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
    registry.register(UserPreferencesPageModule());
    registry.register(MapAtlasPageModule());
    registry.register(LegendManagerPageModule());
    registry.register(AboutPageModule());
    registry.register(ExternalResourcesPageModule());
    // registry.register(ConfigEditorModule());
    // registry.register(FullscreenTestPageModule());
    registry.register(VfsFileManagerPageModule());
    // registry.register(SvgTestPageModule());

    // // 注册演示页面模块
    // registry.register(MarkdownRendererDemoPageModule());
    // WebContextMenuDemoPageModule.register();
  }
}
