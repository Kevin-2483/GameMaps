import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/settings/user_preferences_page.dart';
import '../../config/build_config.dart';
import '../../config/config_manager.dart';

/// 用户偏好设置页面模块
class UserPreferencesPageModule extends PageModule {
  // 模块标识符
  static const String moduleId = 'UserPreferencesPage';

  @override
  String get name => 'user-preferences';

  @override
  String get path => '/user-preferences';

  @override
  String get displayName => '用户偏好设置';

  @override
  IconData get icon => Icons.person_outline;

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
  int get priority => 100; // 设置页面的子页面，优先级较低

  @override
  Widget buildPage(BuildContext context) {
    return const UserPreferencesPage();
  }
}
