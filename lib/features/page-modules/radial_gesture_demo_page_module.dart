// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../components/examples/radial_gesture_menu_example.dart';
import '../../config/build_config.dart';
import '../../config/config_manager.dart';

import '../../services/localization_service.dart';

/// 径向手势菜单演示页面模块
class RadialGestureDemoPageModule extends PageModule {
  // 模块标识符
  static const String moduleId = 'RadialGestureDemo';

  @override
  String get name => 'radial_gesture_demo';

  @override
  String get path => '/radial-gesture-demo';

  @override
  String get displayName =>
      LocalizationService.instance.current.radialGestureDemoTitle_4721;

  @override
  IconData get icon => Icons.gesture;

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
  int get priority => 999; // 低优先级，放在最后

  @override
  bool get showInNavigation => true; // 在导航栏中显示

  @override
  Widget buildPage(BuildContext context) {
    return const RadialGestureMenuExample();
  }
}
