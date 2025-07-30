// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/map_atlas/map_atlas_page.dart';
import '../../config/build_config.dart';
import '../../config/config_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

/// 地图册页面模块
class MapAtlasPageModule extends PageModule {
  // 模块标识符
  static const String moduleId = 'MapAtlasPage';

  @override
  String get name => 'map-atlas';

  @override
  String get path => '/map-atlas';

  @override
  String get displayName => LocalizationService.instance.current.mapAtlas_4821;

  @override
  IconData get icon => Icons.map;

  @override
  int get priority => 2; // 优先级，放在设置页面之前

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
    return const MapAtlasPage();
  }
}
