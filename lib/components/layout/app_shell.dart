import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/build_config.dart';
import '../../config/config_manager.dart';
import '../navigation/tray_navigation.dart';
import '../navigation/merged_window_controls.dart';
import 'page_configuration.dart';
import '../../services/notification/notification_service.dart';
import '../../providers/user_preferences_provider.dart';

/// 应用程序外壳 - 包含托盘导航和页面内容区域
/// 托盘导航保持静止，只有页面内容区域会有动画切换
class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _showTrayNavigation = true;
  bool _overlayStateSet = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _trySetOverlayState();
  }

  void _trySetOverlayState() {
    if (_overlayStateSet) return;

    try {
      final overlayState = Overlay.of(context, rootOverlay: false);
      NotificationService.instance.setOverlayState(overlayState);
      _overlayStateSet = true;
    } catch (e) {
      // 延迟重试
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && !_overlayStateSet) {
          _trySetOverlayState();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 检查编译时和运行时是否都启用了托盘导航
    if (!BuildTimeConfig.isFeatureEnabled('TrayNavigation') ||
        !ConfigManager.instance.isCurrentPlatformFeatureEnabled(
          'TrayNavigation',
        ) ||
        !_showTrayNavigation) {
      return _PageConfigDetector(
        onConfigChanged: _updateTrayNavigationVisibility,
        child: widget.child,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Consumer<UserPreferencesProvider>(
            builder: (context, userPrefsProvider, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  // 根据屏幕比例决定导航位置
                  final isWideScreen =
                      constraints.maxWidth > constraints.maxHeight;
                  final enableRightSideVertical =
                      userPrefsProvider.isInitialized &&
                      userPrefsProvider
                          .layout
                          .enableRightSideVerticalNavigation;

                  if (isWideScreen) {
                    // 宽屏：根据用户设置决定导航栏位置
                    final pageContent = Expanded(
                      child: _PageConfigDetector(
                        onConfigChanged: _updateTrayNavigationVisibility,
                        child: AnimatedPageContent(child: widget.child),
                      ),
                    );

                    if (enableRightSideVertical) {
                      // 右侧垂直导航
                      return Row(
                        children: [pageContent, const TrayNavigation()],
                      );
                    } else {
                      // 左侧垂直导航（默认）
                      return Row(
                        children: [const TrayNavigation(), pageContent],
                      );
                    }
                  } else {
                    // 窄屏：导航栏在底部（不受右侧设置影响）
                    return Column(
                      children: [
                        Expanded(
                          child: _PageConfigDetector(
                            onConfigChanged: _updateTrayNavigationVisibility,
                            child: AnimatedPageContent(child: widget.child),
                          ),
                        ),
                        const TrayNavigation(),
                      ],
                    );
                  }
                },
              );
            },
          ),
          // 合并窗口控件（最上层）
          const MergedWindowControls(),
        ],
      ),
    );
  }

  void _updateTrayNavigationVisibility(bool show) {
    if (_showTrayNavigation != show) {
      setState(() {
        _showTrayNavigation = show;
      });
    }
  }
}

/// 页面配置检测器 - 检测子组件中的 PageConfigurationProvider 并通知父组件
class _PageConfigDetector extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool> onConfigChanged;

  const _PageConfigDetector({
    required this.child,
    required this.onConfigChanged,
  });

  @override
  State<_PageConfigDetector> createState() => _PageConfigDetectorState();
}

class _PageConfigDetectorState extends State<_PageConfigDetector>
    with RouteAware {
  @override
  void initState() {
    super.initState();
    // 在下一帧检查页面配置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkPageConfiguration();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在依赖变化时重新检查配置（包括路由变化）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkPageConfiguration();
      }
    });
  }

  @override
  void didUpdateWidget(_PageConfigDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当widget更新时重新检查配置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkPageConfiguration();
      }
    });
  }

  void _checkPageConfiguration() {
    final config = PageConfigurationProvider.of(context);
    if (config != null) {
      widget.onConfigChanged(config.showTrayNavigation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<Notification>(
      onNotification: (notification) {
        if (notification is PageConfigurationNotification) {
          widget.onConfigChanged(notification.showTrayNavigation);
          return true;
        }
        return false;
      },
      child: widget.child,
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
