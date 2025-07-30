// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/test/svg_test_page.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

class SvgTestPageModule extends PageModule {
  @override
  String get name => 'svg_test';

  @override
  String get path => '/svg-test';

  @override
  String get displayName =>
      LocalizationService.instance.current.svgTestPageTitle_4821;

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
