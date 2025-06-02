import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/external_resources/external_resources_page.dart';
import '../../config/build_config.dart';
import '../../config/config_manager.dart';

/// 外部资源管理页面模块
class ExternalResourcesPageModule extends PageModule {
  // 模块标识符
  static const String moduleId = 'ExternalResourcesPage';

  @override
  String get name => 'external-resources';

  @override
  String get path => '/external-resources';

  @override
  String get displayName => '外部资源管理';

  @override
  IconData get icon => Icons.cloud_sync;

  @override
  int get priority => 4; // 优先级，放在图例管理之后

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
    return const ExternalResourcesPage();
  }
}
