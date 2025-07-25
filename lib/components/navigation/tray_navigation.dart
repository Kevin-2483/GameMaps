import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import '../../features/page_registry.dart';
import '../../services/window_manager_service.dart';
import '../../providers/user_preferences_provider.dart';
import '../../services/cleanup_service.dart';
import '../../services/work_status_action.dart';
import '../../services/work_status_service.dart';
import '../dialogs/work_status_exit_dialog.dart';
import '../../models/user_preferences.dart';

/// 托盘导航组件 - 悬浮在页面上层的导航栏
class TrayNavigation extends StatefulWidget {
  const TrayNavigation({super.key});

  @override
  State<TrayNavigation> createState() => _TrayNavigationState();
}

class _TrayNavigationState extends State<TrayNavigation>
    with AutomaticKeepAliveClientMixin, FullScreenListener {
  @override
  bool get wantKeepAlive => true;

  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _isFullScreen = FullScreen.isFullScreen;
    FullScreen.addListener(this);
  }

  @override
  void dispose() {
    FullScreen.removeListener(this);
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
  /// 如果程序正在工作中，会显示确认对话框
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
    super.build(context); // 调用 AutomaticKeepAliveClientMixin 的 build 方法

    return ChangeNotifierProvider.value(
      value: WorkStatusService(),
      child: Consumer<UserPreferencesProvider>(
        builder: (context, userPrefsProvider, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              // 根据屏幕比例决定基本布局
              final isWideScreen = constraints.maxWidth > constraints.maxHeight;
              final enableRightSideVertical =
                  userPrefsProvider.isInitialized &&
                  userPrefsProvider.layout.enableRightSideVerticalNavigation;

              // 只有在宽屏且启用右侧垂直导航时才使用右侧垂直布局
              final useRightSideVertical =
                  isWideScreen && enableRightSideVertical;
              // 垂直布局：宽屏时使用垂直布局（左侧或右侧），窄屏时使用水平布局（底部）
              final useVerticalLayout = isWideScreen;
              final navigationItems = PageRegistry().getNavigationItems();

              // 构建导航托盘
              return _buildNavigationTray(
                context,
                navigationItems,
                useVerticalLayout,
                useRightSideVertical,
                userPrefsProvider,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNavigationTray(
    BuildContext context,
    List<NavigationItem> items,
    bool isVertical,
    bool isRightSide,
    UserPreferencesProvider userPrefsProvider,
  ) {
    // 只在桌面平台添加拖拽功能
    final isDraggable =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    Widget navigationContent = Container(
      width: isVertical ? 64 : double.infinity, // 宽屏时固定宽度，窄屏时占满宽度
      height: isVertical ? double.infinity : 64, // 宽屏时占满高度，窄屏时固定高度
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: isVertical && isRightSide
              ? BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withAlpha((0.2 * 255).toInt()),
                  width: 1,
                )
              : BorderSide.none,
          right: isVertical && !isRightSide
              ? BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withAlpha((0.2 * 255).toInt()),
                  width: 1,
                )
              : BorderSide.none,
          top: !isVertical
              ? BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withAlpha((0.2 * 255).toInt()),
                  width: 1,
                )
              : BorderSide.none,
        ),
      ),
      child: isVertical
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // 顶部：关闭按钮（仅在桌面平台且未启用合并控件时显示）
                  if (isDraggable &&
                      userPrefsProvider.layout.windowControlsMode == WindowControlsMode.separated) ...[
                    _buildWindowButton(
                      context,
                      icon: Icons.power_settings_new,
                      onPressed: () => _handleAppClose(context),
                      tooltip: '关闭',
                      isCloseButton: true,
                      useNavigationStyle: true,
                    ),
                    const SizedBox(height: 8),
                  ],
                  // 中间：导航按钮
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildNavigationOrWorkStatus(context, items, true),
                      ],
                    ),
                  ),
                  // 底部：窗口控制按钮（仅在桌面平台且未启用合并控件时显示）
                  if (isDraggable &&
                      userPrefsProvider.layout.windowControlsMode == WindowControlsMode.separated) ...[
                    const SizedBox(height: 8),
                    _buildWindowButton(
                      context,
                      icon: Icons.minimize,
                      onPressed: () {
                        _saveWindowSizeIfEnabled(context);
                        appWindow.minimize();
                      },
                      tooltip: '最小化',
                      useNavigationStyle: true,
                    ),
                    const SizedBox(height: 8),
                    _buildWindowButton(
                      context,
                      icon: Icons.crop_square,
                      onPressed: () {
                        _saveWindowSizeIfEnabled(context);
                        appWindow.maximizeOrRestore();
                      },
                      tooltip: '最大化/还原',
                      useNavigationStyle: true,
                    ),
                    // 在Windows平台上不显示全屏按钮
                    if (!Platform.isWindows) ...[
                      const SizedBox(height: 8),
                      _buildFullscreenButton(context, true),
                    ],
                  ],
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // 左侧：导航按钮
                  _buildNavigationOrWorkStatus(context, items, false),
                  // 中间：拖拽区域（占用剩余空间）
                  const Expanded(child: SizedBox()),
                  // 右侧：窗口控制按钮（仅在桌面平台且未启用合并控件时显示）
                  if (isDraggable &&
                      userPrefsProvider.layout.windowControlsMode == WindowControlsMode.separated)
                    _buildWindowControls(context),
                ],
              ),
            ),
    );

    // 如果是桌面平台，使用 GestureDetector 包装拖拽功能
    if (isDraggable) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          appWindow.startDragging();
        },
        child: navigationContent,
      );
    } else {
      return navigationContent;
    }
  }

  List<Widget> _buildNavigationButtons(
    BuildContext context,
    List<NavigationItem> items,
    bool isVertical,
  ) {
    final currentPath = GoRouterState.of(context).uri.path;
    List<Widget> buttons = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isActive = currentPath == item.path;

      buttons.add(_buildNavigationButton(context, item, isActive, isVertical));

      // 添加间距，除了最后一个
      if (i < items.length - 1) {
        if (isVertical) {
          buttons.add(const SizedBox(height: 8));
        } else {
          buttons.add(const SizedBox(width: 8));
        }
      }
    }

    return buttons;
  }

  Widget _buildNavigationOrWorkStatus(
    BuildContext context,
    List<NavigationItem> items,
    bool isVertical,
  ) {
    return Consumer<WorkStatusService>(
      builder: (context, workStatusService, child) {
        // 如果处于工作状态，显示工作状态指示器
        if (workStatusService.isWorking) {
          return _buildWorkStatusIndicator(
            context,
            isVertical,
            workStatusService.workDescription,
          );
        }

        // 否则显示正常的导航按钮
        final buttons = _buildNavigationButtons(context, items, isVertical);
        return isVertical
            ? Column(mainAxisSize: MainAxisSize.min, children: buttons)
            : Row(mainAxisSize: MainAxisSize.min, children: buttons);
      },
    );
  }

  Widget _buildWorkStatusIndicator(
    BuildContext context,
    bool isVertical,
    String workDescription,
  ) {
    return Consumer<WorkStatusService>(
      builder: (context, workStatusService, child) {
        final actions = workStatusService.actions;

        return isVertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 操作控件（垂直布局时显示在顶部）
                  if (actions.isNotEmpty)
                    ..._buildActionButtons(context, actions, true),
                  if (actions.isNotEmpty) const SizedBox(height: 8),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(child: _buildVerticalText(context, workDescription)),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 操作控件（水平布局时显示在左侧）
                  if (actions.isNotEmpty)
                    ..._buildActionButtons(context, actions, false),
                  if (actions.isNotEmpty) const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      workDescription,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
      },
    );
  }

  /// 构建操作控件按钮
  List<Widget> _buildActionButtons(
    BuildContext context,
    List<WorkStatusAction> actions,
    bool isVertical,
  ) {
    return actions
        .map((action) => _buildActionButton(context, action))
        .toList();
  }

  /// 构建单个操作控件按钮
  Widget _buildActionButton(BuildContext context, WorkStatusAction action) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: action.enabled ? action.onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Tooltip(
          message: action.tooltip,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontSize: 12,
          ),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: action.enabled
                  ? (action.isDangerous
                        ? Colors.red.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHighest)
                  : Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              action.icon,
              size: 16,
              color: action.enabled
                  ? (action.isDangerous
                        ? Colors.red
                        : Theme.of(context).colorScheme.onSurface)
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalText(BuildContext context, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: text.characters.map((char) {
        return Transform.rotate(
          angle: 1.5708, // 90度 = π/2 弧度
          child: Text(
            char,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    NavigationItem item,
    bool isActive,
    bool isVertical,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.go(item.path),
        borderRadius: BorderRadius.circular(12),
        child: Tooltip(
          message: item.displayName,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontSize: 12,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isVertical ? 48 : 48, // 水平和垂直都使用相同宽度
            height: isVertical ? 48 : 48, // 水平和垂直都使用相同高度
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              size: 24,
              color: isActive
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  // 构建窗口控制按钮
  Widget _buildWindowControls(BuildContext context) {
    // 只在桌面平台显示窗口控制按钮
    if (kIsWeb ||
        !(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      return const SizedBox.shrink();
    }

    // 水平布局：按钮水平排列（使用与导航按钮相同的样式）
    return Row(
      children: [
        _buildWindowButton(
          context,
          icon: Icons.minimize,
          onPressed: () {
            _saveWindowSizeIfEnabled(context);
            appWindow.minimize();
          },
          tooltip: '最小化',
          useNavigationStyle: true,
        ),
        const SizedBox(width: 8),
        _buildWindowButton(
          context,
          icon: Icons.crop_square,
          onPressed: () {
            _saveWindowSizeIfEnabled(context);
            appWindow.maximizeOrRestore();
          },
          tooltip: '最大化/还原',
          useNavigationStyle: true,
        ),
        // 在Windows平台上不显示全屏按钮
        if (!Platform.isWindows) ...[
          const SizedBox(width: 8),
          _buildFullscreenButton(context, false),
        ],
        const SizedBox(width: 8),
        _buildWindowButton(
          context,
          icon: Icons.power_settings_new,
          onPressed: () => _handleAppClose(context),
          tooltip: '关闭',
          isCloseButton: true,
          useNavigationStyle: true,
        ),
      ],
    );
  }

  // 构建单个窗口控制按钮
  Widget _buildWindowButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isCloseButton = false,
    bool useNavigationStyle = false,
  }) {
    if (useNavigationStyle) {
      // 使用与导航按钮相同的样式
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          hoverColor: isCloseButton
              ? Colors.red.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isCloseButton
                    ? Colors.red
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    } else {
      // 使用原有的小按钮样式
      return SizedBox(
        width: 46,
        height: 32,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            hoverColor: isCloseButton
                ? Colors.red.withValues(alpha: 0.1)
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.1),
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
              child: Icon(
                icon,
                size: 16,
                color: isCloseButton
                    ? Colors.red
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }
  }

  // 构建全屏按钮
  Widget _buildFullscreenButton(BuildContext context, bool isVertical) {
    return _buildWindowButton(
      context,
      icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
      onPressed: () async {
        if (!_isFullScreen) {
          // 进入全屏时保存窗口大小
          _saveWindowSizeIfEnabled(context);
        }
        // 切换全屏状态
        FullScreen.setFullScreen(!_isFullScreen);
      },
      tooltip: _isFullScreen ? '退出全屏' : '全屏',
      useNavigationStyle: true,
    );
  }

  // Widget _buildThemeToggleButton(BuildContext context, bool isVertical) {
  //   return Consumer<ThemeProvider>(
  //     builder: (context, themeProvider, _) {
  //       return Material(
  //         color: Colors.transparent,
  //         child: InkWell(
  //           onTap: () => themeProvider.toggleTheme(),
  //           child: Container(
  //             width: isVertical ? 64 : null,
  //             height: isVertical ? null : 64,
  //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Icon(
  //                   themeProvider.themeMode == AppThemeMode.dark
  //                       ? Icons.light_mode
  //                       : Icons.dark_mode,
  //                   size: 24,
  //                   color: Theme.of(context).colorScheme.onSurface,
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   '主题',
  //                   style: Theme.of(context).textTheme.labelSmall?.copyWith(
  //                     color: Theme.of(context).colorScheme.onSurface,
  //                     fontSize: 10,
  //                   ),
  //                   textAlign: TextAlign.center,
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
