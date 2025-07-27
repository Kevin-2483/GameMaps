import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import '../../providers/user_preferences_provider.dart';
import '../../services/window_manager_service.dart';
import '../../services/cleanup_service.dart';
import '../../services/work_status_service.dart';
import '../dialogs/work_status_exit_dialog.dart';
import '../../models/user_preferences.dart';

/// 合并窗口控件 - 悬浮托盘形式的窗口控制按钮
class MergedWindowControls extends StatefulWidget {
  const MergedWindowControls({super.key});

  @override
  State<MergedWindowControls> createState() => _MergedWindowControlsState();
}

class _MergedWindowControlsState extends State<MergedWindowControls>
    with TickerProviderStateMixin, FullScreenListener {
  bool _isExpanded = false;
  bool _isFullScreen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isFullScreen = FullScreen.isFullScreen;
    FullScreen.addListener(this);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    FullScreen.removeListener(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void onFullScreenChanged(bool enabled, dynamic systemUiMode) {
    if (mounted) {
      setState(() {
        _isFullScreen = enabled;
      });
    }
  }

  void _onHover(bool isHovering) {
    setState(() {
      _isExpanded = isHovering;
    });

    if (isHovering) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  /// 检查是否应该默认展开（mergedExpanded模式）
  bool _shouldBeExpanded(WindowControlsMode mode) {
    return mode == WindowControlsMode.mergedExpanded || _isExpanded;
  }

  /// 如果启用了自动保存窗口大小，则保存当前窗口大小（仅在非最大化状态下）
  void _saveWindowSizeIfEnabled(BuildContext context) {
    try {
      final userPrefsProvider = context.read<UserPreferencesProvider>();
      if (userPrefsProvider.isInitialized &&
          userPrefsProvider.layout.autoSaveWindowSize &&
          !appWindow.isMaximized) {
        WindowManagerService().saveCurrentWindowSize();
        if (kDebugMode) {
          debugPrint('窗口大小保存请求已发送（非最大化状态）');
        }
      } else if (kDebugMode && appWindow.isMaximized) {
        debugPrint('跳过保存：当前处于最大化状态');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('保存窗口大小失败: $e');
      }
    }
  }

  /// 处理应用关闭逻辑
  Future<void> _handleAppClose(BuildContext context) async {
    final workStatusService = WorkStatusService();

    // 如果程序正在工作中，显示确认对话框
    if (workStatusService.isWorking) {
      final shouldExit = await WorkStatusExitDialog.show(
        context,
        onForceExit: () {
          // 强制停止所有工作状态
          workStatusService.forceStopAllWork();
        },
      );

      // 如果用户选择取消，直接返回
      if (shouldExit != true) {
        return;
      }
    }

    // 执行正常的关闭流程
    await _performAppClose();
  }

  /// 执行应用关闭的实际操作
  Future<void> _performAppClose() async {
    // 执行清理操作
    final cleanupService = CleanupService();
    await cleanupService.performCleanup();

    // 使用智能保存逻辑，根据用户设置决定是否保存最大化状态
    final windowManager = WindowManagerService();
    await windowManager.saveWindowStateOnExit();

    // 关闭应用
    appWindow.close();
  }

  @override
  Widget build(BuildContext context) {
    // 只在桌面平台显示
    if (kIsWeb ||
        !(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      return const SizedBox.shrink();
    }

    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefsProvider, child) {
        if (!userPrefsProvider.isInitialized ||
            userPrefsProvider.layout.windowControlsMode ==
                WindowControlsMode.separated) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // 根据屏幕比例决定布局模式
            final isWideScreen = constraints.maxWidth > constraints.maxHeight;
            final enableRightSideVertical =
                userPrefsProvider.layout.enableRightSideVerticalNavigation;

            // 宽屏时使用垂直导航布局，窄屏时使用水平导航布局
            final useVerticalLayout = isWideScreen;

            return Stack(
              children: [
                Positioned(
                  top: useVerticalLayout ? 8 : null,
                  bottom: useVerticalLayout ? null : 8,
                  right: useVerticalLayout
                      ? (enableRightSideVertical ? 8 : null)
                      : 8,
                  left: useVerticalLayout
                      ? (enableRightSideVertical ? null : 8)
                      : null,
                  child: MouseRegion(
                    onEnter: (_) => _onHover(true),
                    onExit: (_) => _onHover(false),
                    child: AnimatedBuilder(
                      animation: _expandAnimation,
                      builder: (context, child) {
                        return Material(
                          elevation: 16,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: useVerticalLayout
                                  ? (enableRightSideVertical
                                        ? [
                                            // 右侧垂直导航时：展开按钮在左，关闭按钮在右（固定位置）
                                            if (_shouldBeExpanded(
                                              userPrefsProvider
                                                  .layout
                                                  .windowControlsMode,
                                            ))
                                              ..._buildExpandedButtons(context),
                                            _buildWindowButton(
                                              context,
                                              icon: Icons.power_settings_new,
                                              onPressed: () =>
                                                  _handleAppClose(context),
                                              tooltip: '关闭',
                                              isCloseButton: true,
                                            ),
                                          ]
                                        : [
                                            // 左侧垂直导航时：关闭按钮在左（固定位置），展开按钮在右
                                            _buildWindowButton(
                                              context,
                                              icon: Icons.power_settings_new,
                                              onPressed: () =>
                                                  _handleAppClose(context),
                                              tooltip: '关闭',
                                              isCloseButton: true,
                                            ),
                                            if (_shouldBeExpanded(
                                              userPrefsProvider
                                                  .layout
                                                  .windowControlsMode,
                                            ))
                                              ..._buildExpandedButtons(context),
                                          ])
                                  : [
                                      // 水平导航时：关闭按钮在右（固定位置），展开按钮在左
                                      if (_shouldBeExpanded(
                                        userPrefsProvider
                                            .layout
                                            .windowControlsMode,
                                      ))
                                        ..._buildExpandedButtons(context),
                                      _buildWindowButton(
                                        context,
                                        icon: Icons.power_settings_new,
                                        onPressed: () =>
                                            _handleAppClose(context),
                                        tooltip: '关闭',
                                        isCloseButton: true,
                                      ),
                                    ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _buildExpandedButtons(BuildContext context) {
    final layout = Provider.of<UserPreferencesProvider>(context).layout;
    final isAlwaysExpanded =
        layout.windowControlsMode == WindowControlsMode.mergedExpanded;
    List<Widget> buttons = [];

    Widget wrapWithAnimation(Widget child) {
      if (isAlwaysExpanded) {
        return child;
      }
      return SizeTransition(
        sizeFactor: _expandAnimation,
        axis: Axis.horizontal,
        child: child,
      );
    }

    // 最小化按钮
    buttons.add(
      wrapWithAnimation(
        _buildWindowButton(
          context,
          icon: Icons.minimize,
          onPressed: () {
            _saveWindowSizeIfEnabled(context);
            appWindow.minimize();
          },
          tooltip: '最小化',
        ),
      ),
    );

    // 最大化按钮
    buttons.add(
      wrapWithAnimation(
        _buildWindowButton(
          context,
          icon: Icons.crop_square,
          onPressed: () {
            _saveWindowSizeIfEnabled(context);
            appWindow.maximizeOrRestore();
          },
          tooltip: '最大化/还原',
        ),
      ),
    );

    // 全屏按钮（macOS显示）
    if (Platform.isMacOS) {
      buttons.add(
        wrapWithAnimation(
          _buildWindowButton(
            context,
            icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
            onPressed: () async {
              if (!_isFullScreen) {
                _saveWindowSizeIfEnabled(context);
              }
              FullScreen.setFullScreen(!_isFullScreen);
            },
            tooltip: _isFullScreen ? '退出全屏' : '全屏',
          ),
        ),
      );
    }

    return buttons;
  }

  Widget _buildWindowButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isCloseButton = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4, // 左右各4像素
        vertical: 4, // 上下各8像素
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          hoverColor: isCloseButton
              ? Colors.red.withOpacity(0.1)
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          child: Tooltip(
            message: tooltip,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inverseSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 12,
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isCloseButton
                    ? Colors.red
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
