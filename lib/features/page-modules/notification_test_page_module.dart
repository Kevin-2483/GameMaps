// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/test/notification_test_page.dart';
import '../../config/build_config.dart';
import '../../config/config_manager.dart';

import '../../services/localization_service.dart';

/// 通知测试页模块
class NotificationTestPageModule extends PageModule {
  // 模块标识符
  static const String moduleId = 'NotificationTestPage';

  @override
  String get name => 'notification-test';

  @override
  String get path => '/notification-test';

  @override
  String get displayName =>
      LocalizationService.instance.current.notificationTestPageTitle_4821;

  @override
  IconData get icon => Icons.notifications_active;

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
  int get priority => 800; // 较低优先级，在设置页面之前

  @override
  Widget buildPage(BuildContext context) {
    return const NotificationTestPage();
  }
}
