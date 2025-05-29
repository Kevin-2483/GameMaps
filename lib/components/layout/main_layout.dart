import 'package:flutter/material.dart';
import '../../config/build_config.dart';
import '../../config/config_manager.dart';
import '../navigation/tray_navigation.dart';
import 'page_configuration.dart';

/// 主布局组件 - 包含托盘导航的通用布局
class MainLayout extends StatelessWidget {
  final Widget child;
  final bool showTrayNavigation;

  const MainLayout({
    super.key,
    required this.child,
    this.showTrayNavigation = true,
  });  @override
  Widget build(BuildContext context) {
    // 检查编译时和运行时是否都启用了托盘导航
    if (!BuildTimeConfig.isFeatureEnabled('TrayNavigation') ||
        !ConfigManager.instance.isCurrentPlatformFeatureEnabled('TrayNavigation') ||
        !showTrayNavigation) {
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
/// 页面配置通过 PageConfigurationProvider 传递给 AppShell
abstract class BasePage extends StatelessWidget {
  const BasePage({super.key});

  /// 页面内容构建方法，子类必须实现
  Widget buildContent(BuildContext context);

  /// 控制此页面是否显示 TrayNavigation
  /// 默认值为 true，子类可以重写此方法来自定义行为
  bool get showTrayNavigation => true;
  @override
  Widget build(BuildContext context) {
    // 使用 PageConfigurationProvider 包装页面内容
    return PageConfigurationProvider(
      configuration: PageConfiguration(
        showTrayNavigation: showTrayNavigation,
      ),
      child: _PageNotifier(
        showTrayNavigation: showTrayNavigation,
        child: buildContent(context),
      ),
    );
  }
}

/// 页面通知器 - 负责发送页面配置通知
class _PageNotifier extends StatefulWidget {
  final bool showTrayNavigation;
  final Widget child;

  const _PageNotifier({
    required this.showTrayNavigation,
    required this.child,
  });

  @override
  State<_PageNotifier> createState() => _PageNotifierState();
}

class _PageNotifierState extends State<_PageNotifier> {
  @override
  void initState() {
    super.initState();
    _sendNotification();
  }

  @override
  void didUpdateWidget(_PageNotifier oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showTrayNavigation != widget.showTrayNavigation) {
      _sendNotification();
    }
  }

  void _sendNotification() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        PageConfigurationNotification(showTrayNavigation: widget.showTrayNavigation)
            .dispatch(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
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
