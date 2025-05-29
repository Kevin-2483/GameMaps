import 'package:flutter/material.dart';
import '../../config/build_config.dart';
import '../../config/config_manager.dart';
import '../navigation/tray_navigation.dart';

/// 应用程序外壳 - 包含托盘导航和页面内容区域
/// 托盘导航保持静止，只有页面内容区域会有动画切换
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 检查编译时和运行时是否都启用了托盘导航
    if (!BuildTimeConfig.isFeatureEnabled('TrayNavigation') ||
        !ConfigManager.instance.isCurrentPlatformFeatureEnabled('TrayNavigation')) {
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
                Expanded(child: AnimatedPageContent(child: child)),
              ],
            );
          } else {
            // 窄屏：导航栏在底部
            return Column(
              children: [
                Expanded(child: AnimatedPageContent(child: child)),
                const TrayNavigation(),
              ],
            );
          }
        },
      ),
    );
  }
}

/// 动画页面内容容器
/// 这个组件负责页面之间的切换动画，而托盘导航保持静止
class AnimatedPageContent extends StatelessWidget {
  final Widget child;

  const AnimatedPageContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
