import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/external_resources/external_resources_page.dart';

/// 外部资源页模块
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
  int get priority => 800;

  @override
  bool get isEnabled => true;

  @override
  bool get showInNavigation => false; // 隐藏在导航中，但可通过设置访问

  @override
  Widget buildPage(BuildContext context) {
    return const ExternalResourcesPage();
  }
}