import 'package:flutter/material.dart';

/// 页面配置 - 包含页面级别的设置
class PageConfiguration {
  final bool showTrayNavigation;

  const PageConfiguration({this.showTrayNavigation = true});
}

/// InheritedWidget 用于在 Widget 树中传递页面配置
class PageConfigurationProvider extends InheritedWidget {
  final PageConfiguration configuration;

  const PageConfigurationProvider({
    super.key,
    required this.configuration,
    required super.child,
  });

  static PageConfiguration? of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<PageConfigurationProvider>();
    return provider?.configuration;
  }

  @override
  bool updateShouldNotify(PageConfigurationProvider oldWidget) {
    return configuration.showTrayNavigation !=
        oldWidget.configuration.showTrayNavigation;
  }
}

/// 自定义通知 - 用于从页面向上传递配置信息
class PageConfigurationNotification extends Notification {
  final bool showTrayNavigation;

  const PageConfigurationNotification({required this.showTrayNavigation});
}
