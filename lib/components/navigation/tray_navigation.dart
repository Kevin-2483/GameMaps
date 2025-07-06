import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../features/page_registry.dart';
import '../../services/window_manager_service.dart';
import '../../providers/user_preferences_provider.dart';
import '../../services/cleanup_service.dart';

/// 托盘导航组件 - 悬浮在页面上层的导航栏
class TrayNavigation extends StatefulWidget {
  const TrayNavigation({super.key});

  @override
  State<TrayNavigation> createState() => _TrayNavigationState();
}

class _TrayNavigationState extends State<TrayNavigation>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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

  @override
  Widget build(BuildContext context) {
    super.build(context); // 调用 AutomaticKeepAliveClientMixin 的 build 方法

    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据屏幕比例决定导航位置
        final isWideScreen = constraints.maxWidth > constraints.maxHeight;
        final navigationItems = PageRegistry().getNavigationItems();

        // 直接返回导航托盘，始终显示
        return _buildNavigationTray(context, navigationItems, isWideScreen);
      },
    );
  }

  Widget _buildNavigationTray(
    BuildContext context,
    List<NavigationItem> items,
    bool isVertical,
  ) {
    // 只在桌面平台添加拖拽功能
    final isDraggable =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    Widget navigationContent = Container(
      width: isVertical ? 80 : double.infinity, // 宽屏时固定宽度，窄屏时占满宽度
      height: isVertical ? double.infinity : 80, // 宽屏时占满高度，窄屏时固定高度
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: isVertical
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  // 顶部：关闭按钮（仅在桌面平台显示）
                  if (isDraggable) ...[
                    _buildWindowButton(
                      context,
                      icon: Icons.power_settings_new,
                      onPressed: () async {
                        // 执行清理操作
                        final cleanupService = CleanupService();
                        await cleanupService.performCleanup();
                        
                        // 使用智能保存逻辑，根据用户设置决定是否保存最大化状态
                        final windowManager = WindowManagerService();
                        await windowManager.saveWindowStateOnExit();
                        
                        // 关闭应用
                        appWindow.close();
                      },
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
                      children: _buildNavigationButtons(context, items, true),
                    ),
                  ),
                  // 底部：窗口控制按钮（仅在桌面平台显示）
                  if (isDraggable) ...[
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
                      icon: Icons.fullscreen,
                      onPressed: () {
                        _saveWindowSizeIfEnabled(context);
                        appWindow.maximizeOrRestore();
                      },
                      tooltip: '最大化/还原',
                      useNavigationStyle: true,
                    ),
                  ],
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // 左侧：导航按钮
                  Row(children: _buildNavigationButtons(context, items, false)),
                  // 中间：拖拽区域（占用剩余空间）
                  const Expanded(child: SizedBox()),
                  // 右侧：窗口控制按钮
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
    }

    return navigationContent;
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

      // // 在设置按钮前添加主题切换按钮
      // if (item.name == 'settings' && i > 0) {
      //   buttons.add(_buildThemeToggleButton(context, isVertical));
      //   if (isVertical) {
      //     buttons.add(const SizedBox(height: 8));
      //   } else {
      //     buttons.add(const SizedBox(width: 8));
      //   }
      // }

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
            width: isVertical ? 64 : 64, // 水平和垂直都使用相同宽度
            height: isVertical ? 64 : 64, // 水平和垂直都使用相同高度
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
          icon: Icons.fullscreen,
          onPressed: () {
            _saveWindowSizeIfEnabled(context);
            appWindow.maximizeOrRestore();
          },
          tooltip: '最大化/还原',
          useNavigationStyle: true,
        ),
        const SizedBox(width: 8),
        _buildWindowButton(
          context,
          icon: Icons.power_settings_new,
          onPressed: () async {
            // 执行清理操作
            final cleanupService = CleanupService();
            await cleanupService.performCleanup();
            
            // 使用智能保存逻辑，根据用户设置决定是否保存最大化状态
            final windowManager = WindowManagerService();
            await windowManager.saveWindowStateOnExit();
            
            // 关闭应用
            appWindow.close();
          },
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
              width: 64,
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
