import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/legend_manager/legend_manager_page.dart';
import '../../config/build_config.dart';
import '../../config/config_manager.dart';

/// 图例管理页面模块
class LegendManagerPageModule extends PageModule {
  // 模块标识符
  static const String moduleId = 'LegendManagerPage';

  @override
  String get name => 'legend-manager';

  @override
  String get path => '/legend-manager';

  @override
  String get displayName => '图例管理';

  @override
  IconData get icon => Icons.legend_toggle;

  @override
  int get priority => 3; // 优先级，放在地图册之后

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
  Widget buildPage(BuildContext context) {
    return const LegendManagerPage();
  }
}
