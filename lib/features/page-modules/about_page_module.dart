import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/about/about_page.dart';

/// 关于页模块
class AboutPageModule extends PageModule {
  // 模块标识符
  static const String moduleId = 'AboutPage';

  @override
  String get name => 'about';

  @override
  String get path => '/about';

  @override
  String get displayName => '关于';

  @override
  IconData get icon => Icons.info_outline;

  @override
  bool get isEnabled => true;

  @override
  int get priority => 800; // 优先级较低，在设置页之前

  @override
  bool get showInNavigation => false; // 不在托盘导航中显示，但可以通过设置页面访问

  @override
  Widget buildPage(BuildContext context) => const AboutPage();
}
