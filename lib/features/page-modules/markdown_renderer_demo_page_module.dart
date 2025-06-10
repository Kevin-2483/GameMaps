import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/demo/markdown_renderer_demo_page.dart';

/// Markdown 渲染器演示页面模块
class MarkdownRendererDemoPageModule extends PageModule {
  @override
  String get name => 'markdown-renderer-demo';

  @override
  String get path => '/demo/markdown';

  @override
  String get displayName => 'Markdown 渲染器演示';

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
