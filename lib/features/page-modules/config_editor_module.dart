import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/config/config_editor_page.dart';
// import '../../config/build_config.dart';
// import '../../config/config_manager.dart';

/// 配置编辑器模块
class ConfigEditorModule extends PageModule {
  // 模块标识符
  static const String moduleId = 'ConfigEditor';

  @override
  String get name => 'config_editor';

  @override
  String get path => '/config';

  @override
  String get displayName => '配置编辑器';

  @override
  IconData get icon => Icons.settings_applications;

  @override
  bool get isEnabled {
    // 配置编辑器始终可用
    return true;
  }

  @override
  int get priority => 900; // 较低优先级，在调试相关功能中

  @override
  Widget buildPage(BuildContext context) {
    return const ConfigEditorPage();
  }
}
