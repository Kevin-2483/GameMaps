// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/vfs/vfs_file_manager_page.dart';
import '../../config/build_config.dart';
import '../../config/config_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

/// VFS文件管理器页面模块
class VfsFileManagerPageModule extends PageModule {
  // 模块标识符
  static const String moduleId = 'VfsFileManagerPage';

  @override
  String get name => 'vfs-file-manager';

  @override
  String get path => '/vfs-file-manager';

  @override
  String get displayName =>
      LocalizationService.instance.current.vfsFileManager_4821;

  @override
  IconData get icon => Icons.folder;

  @override
  int get priority => 4;

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
    return const VfsFileManagerPage();
  }
}
