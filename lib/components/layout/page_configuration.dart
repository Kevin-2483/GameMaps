import 'package:flutter/material.dart';

/// 页面配置 - 包含页面级别的设置
class PageConfiguration {
  final bool showTrayNavigation;

  const PageConfiguration({
    this.showTrayNavigation = true,
  });
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
    final provider = context.dependOnInheritedWidgetOfExactType<PageConfigurationProvider>();
    return provider?.configuration;
  }

  @override
  bool updateShouldNotify(PageConfigurationProvider oldWidget) {
    return configuration != oldWidget.configuration;
  }
}
