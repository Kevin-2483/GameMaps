// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../page_registry.dart';
import '../../pages/websocket/websocket_connection_manager_page.dart';

import '../../services/localization_service.dart';

class WebSocketConnectionManagerPageModule extends PageModule {
  @override
  String get name => 'WebSocketConnectionManagerPage';

  @override
  String get path => '/websocket-manager';

  @override
  String get displayName =>
      LocalizationService.instance.current.webSocketConnectionManager_4821;

  @override
  IconData get icon => Icons.wifi;

  @override
  bool get isEnabled => true;

  @override
  bool get showInNavigation => false; // 从导航栏隐藏

  @override
  int get priority => 70; // 在其他页面之后

  @override
  Widget buildPage(BuildContext context) {
    return const WebSocketConnectionManagerPage();
  }
}
