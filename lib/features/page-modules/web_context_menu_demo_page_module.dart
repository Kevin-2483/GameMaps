// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/demo/web_context_menu_demo_page.dart';

import '../../services/localization_service.dart';

/// Web右键菜单演示页面模块
class WebContextMenuDemoPageModule extends PageModule {
  @override
  String get name => 'web-context-menu-demo';

  @override
  String get path => '/demo/web-context-menu';

  @override
  String get displayName =>
      LocalizationService.instance.current.webContextMenuDemoTitle_4721;

  @override
  IconData get icon => Icons.mouse;

  @override
  bool get isEnabled => true;

  @override
  int get priority => 900; // 演示页面放在后面

  @override
  Widget buildPage(BuildContext context) {
    return const WebContextMenuDemoPage();
  }

  static void register() {
    PageRegistry().register(WebContextMenuDemoPageModule());
  }
}
