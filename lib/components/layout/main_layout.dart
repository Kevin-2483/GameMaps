import 'package:flutter/material.dart';
import '../../config/build_config.dart';
import '../navigation/tray_navigation.dart';

/// 主布局组件 - 包含托盘导航的通用布局
class MainLayout extends StatelessWidget {
  final Widget child;
  final bool showTrayNavigation;

  const MainLayout({
    super.key,
    required this.child,
    this.showTrayNavigation = true,
  });
  @override
  Widget build(BuildContext context) {
    // 如果编译时禁用了托盘导航，直接返回子组件
    if (!BuildTimeConfig.isFeatureEnabled('TrayNavigation') || !showTrayNavigation) {
      return child;
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 根据屏幕比例决定导航位置
          final isWideScreen = constraints.maxWidth > constraints.maxHeight;
          
          if (isWideScreen) {
            // 宽屏：导航栏在左侧
            return Row(
              children: [
                const TrayNavigation(),
                Expanded(child: child),
              ],
            );
          } else {
            // 窄屏：导航栏在底部
            return Column(
              children: [
                Expanded(child: child),
                const TrayNavigation(),
              ],
            );
          }
        },
      ),
    );
  }
}

/// 页面基础类 - 所有页面都应该继承这个类
/// 现在页面内容直接返回，托盘导航由应用程序外壳管理
abstract class BasePage extends StatelessWidget {
  const BasePage({super.key});

  /// 页面内容构建方法，子类必须实现
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return buildContent(context);
  }
}

/// 无导航页面基础类 - 用于不需要导航的页面（如启动页、错误页等）
abstract class NoNavigationPage extends StatelessWidget {
  const NoNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return buildContent(context);
  }

  Widget buildContent(BuildContext context);
}
