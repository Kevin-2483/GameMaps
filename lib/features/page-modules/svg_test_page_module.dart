import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/test/svg_test_page.dart';

class SvgTestPageModule extends PageModule {
  @override
  String get name => 'svg_test';

  @override
  String get path => '/svg-test';

  @override
  String get displayName => 'SVG 测试';

  @override
  IconData get icon => Icons.image;

  @override
  bool get isEnabled => true;

  @override
  int get priority => 100; // 放在最后

  @override
  Widget buildPage(BuildContext context) {
    return const SvgTestPage();
  }
}
