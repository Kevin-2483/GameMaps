import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/test/fullscreen_test_page.dart';
import '../../config/build_config.dart';
import '../../config/config_manager.dart';

/// 全屏测试页面模块 - 用于演示 TrayNavigation 控制
class FullscreenTestPageModule extends PageModule {
  // 模块标识符
  static const String moduleId = 'FullscreenTestPage';

  @override
  String get name => 'fullscreen-test';

  @override
  String get path => '/fullscreen-test';

  @override
  String get displayName => '全屏测试';

  @override
  IconData get icon => Icons.fullscreen;

  @override
  int get priority => 10; // 低优先级，放在最后

  @override
  bool get isEnabled {
    // 编译时配置检查 - 检查是否在构建时启用页面列表中
    if (!BuildTimeConfig.isPageEnabled(moduleId)) {
      return false;
    }

    // 运行时配置检查 - 检查当前平台是否启用该页面
    // 只在调试模式下显示
    if (!ConfigManager.instance.isCurrentPlatformFeatureEnabled('DebugMode')) {
      return false;
    }

    return ConfigManager.instance.isCurrentPlatformPageEnabled(moduleId);
  }

  @override
  Widget buildPage(BuildContext context) {
    return const FullscreenTestPage();
  }
}
