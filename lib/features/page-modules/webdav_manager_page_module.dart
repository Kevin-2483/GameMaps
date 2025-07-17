import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/webdav/webdav_manager_page.dart';

class WebDavManagerPageModule extends PageModule {
  @override
  String get name => 'WebDavManagerPage';

  @override
  String get path => '/webdav-manager';

  @override
  String get displayName => 'WebDAV 管理';

  @override
  IconData get icon => Icons.cloud;

  @override
  bool get isEnabled => !kIsWeb; // 仅在非web平台启用

  @override
  bool get showInNavigation => false;

  @override
  int get priority => 90;

  @override
  Widget buildPage(BuildContext context) {
    return const WebDavManagerPage();
  }
}