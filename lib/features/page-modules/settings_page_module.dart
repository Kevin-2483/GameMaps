import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/settings/settings_page.dart';
import '../../config/build_config.dart';
import '../../config/config_manager.dart';

/// 设置页模块 - 始终优先级最低（999）
class SettingsPageModule extends PageModule {
  // 模块标识符
  static const String moduleId = 'SettingsPage';

  @override
  String get name => 'settings';

  @override
  String get path => '/settings';

  @override
  String get displayName => '设置';

  @override
  IconData get icon => Icons.settings;

  @override
  bool get isEnabled {
    // 编译时配置检查 - 检查是否在构建时启用页面列表中
    if (!BuildTimeConfig.isPageEnabled(moduleId)) {
      return false;
    }

    // 运行时配置检查 - 检查当前平台是否启用该页面
    return ConfigManager.instance.isCurrentPlatformPageEnabled(moduleId);
  }

  @override
  int get priority => 999; // 最低优先级，始终在最后

  @override
  Widget buildPage(BuildContext context) {
    return const SettingsPage();
  }
}
