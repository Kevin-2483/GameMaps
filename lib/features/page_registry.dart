import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 页面模块接口 - 用于注册页面到导航系统
abstract class PageModule {
  String get name;
  String get path;
  String get displayName;
  IconData get icon;
  bool get isEnabled;
  int get priority; // 用于排序，越小越靠前

  /// 是否在导航栏中显示，默认为 true
  /// 如果为 false，页面仍然可以通过直接访问路由使用，但不会在导航栏中显示
  bool get showInNavigation => true;

  Widget buildPage(BuildContext context);

  /// 创建路由配置
  GoRoute createRoute() {
    return GoRoute(
      path: path,
      name: name,
      builder: (context, state) => buildPage(context),
    );
  }
}

/// 页面注册管理器
class PageRegistry {
  static final PageRegistry _instance = PageRegistry._internal();
  factory PageRegistry() => _instance;
  PageRegistry._internal();

  final Map<String, PageModule> _pages = {};

  /// 注册页面模块
  void register(PageModule page) {
    _pages[page.name] = page;
  }

  /// 获取所有启用的页面
  List<PageModule> getEnabledPages() {
    final enabledPages = _pages.values.where((page) => page.isEnabled).toList();

    // 按优先级排序
    enabledPages.sort((a, b) => a.priority.compareTo(b.priority));
    return enabledPages;
  }

  /// 获取所有页面
  List<PageModule> getAllPages() {
    return _pages.values.toList();
  }

  /// 根据名称获取页面
  PageModule? getPage(String name) {
    return _pages[name];
  }

  /// 生成路由配置
  List<GoRoute> generateRoutes() {
    return getEnabledPages().map((page) => page.createRoute()).toList();
  }

  /// 获取导航项
  List<NavigationItem> getNavigationItems() {
    final pages = getEnabledPages();
    return pages
        .where((page) => page.showInNavigation) // 只返回需要在导航栏中显示的页面
        .map(
          (page) => NavigationItem(
            name: page.name,
            path: page.path,
            displayName: page.displayName,
            icon: page.icon,
          ),
        )
        .toList();
  }

  /// 清空注册
  void clear() {
    _pages.clear();
  }
}

/// 导航项数据结构
class NavigationItem {
  final String name;
  final String path;
  final String displayName;
  final IconData icon;

  const NavigationItem({
    required this.name,
    required this.path,
    required this.displayName,
    required this.icon,
  });
}
