// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/demo/markdown_renderer_demo_page.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

/// Markdown 渲染器演示页面模块
class MarkdownRendererDemoPageModule extends PageModule {
  @override
  String get name => 'markdown-renderer-demo';

  @override
  String get path => '/demo/markdown';

  @override
  String get displayName =>
      LocalizationService.instance.current.markdownRendererDemo_4821;

  @override
  IconData get icon => Icons.code;

  @override
  int get priority => 900; // 演示页面放在后面，与其他演示页面优先级相同

  @override
  bool get isEnabled => true; // 演示页面默认启用

  @override
  Widget buildPage(BuildContext context) {
    return const MarkdownRendererDemoPage();
  }
}
