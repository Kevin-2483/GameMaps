import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/home/home_page.dart';
import '../../config/build_config.dart';
import '../../config/config_manager.dart';

/// 主页模块 - 始终优先级最高（0）
class HomePageModule extends PageModule {
  // 模块标识符
  static const String moduleId = 'HomePage';

  @override
  String get name => 'home';

  @override
  String get path => '/';

  @override
  String get displayName => '首页';

  @override
  IconData get icon => Icons.home;
  
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
  int get priority => 0; // 最高优先级，始终在第一位

  @override
  Widget buildPage(BuildContext context) {
    return const HomePage();
  }
}
