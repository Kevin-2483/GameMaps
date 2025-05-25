import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/page_registry.dart';
import '../../providers/theme_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    super.build(context); // 调用 AutomaticKeepAliveClientMixin 的 build 方法
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据屏幕比例决定导航位置
        final isWideScreen = constraints.maxWidth > constraints.maxHeight;
        final navigationItems = PageRegistry().getNavigationItems();

        // 直接返回导航托盘，始终显示
        return _buildNavigationTray(
          context,
          navigationItems,
          isWideScreen,
        );
      },
    );
  }
  Widget _buildNavigationTray(
    BuildContext context,
    List<NavigationItem> items,
    bool isVertical,
  ) {
    return Container(
      width: isVertical ? 80 : double.infinity, // 宽屏时固定宽度，窄屏时占满宽度
      height: isVertical ? double.infinity : 80, // 宽屏时占满高度，窄屏时固定高度
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: isVertical ? BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ) : BorderSide.none,
          top: !isVertical ? BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ) : BorderSide.none,
        ),
      ),
      child: isVertical
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildNavigationButtons(context, items, true),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildNavigationButtons(context, items, false),
            ),
    );
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

      // 在设置按钮前添加主题切换按钮
      if (item.name == 'settings' && i > 0) {
        buttons.add(_buildThemeToggleButton(context, isVertical));
        if (isVertical) {
          buttons.add(const SizedBox(height: 8));
        } else {
          buttons.add(const SizedBox(width: 8));
        }
      }

      buttons.add(_buildNavigationButton(
        context,
        item,
        isActive,
        isVertical,
      ));

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
      child: InkWell(
        onTap: () => context.go(item.path),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isVertical ? 64 : null,
          height: isVertical ? null : 64,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 24,
                color: isActive
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 4),
              Text(
                item.displayName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isActive
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildThemeToggleButton(BuildContext context, bool isVertical) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => themeProvider.toggleTheme(),
            child: Container(
              width: isVertical ? 64 : null,
              height: isVertical ? null : 64,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    themeProvider.themeMode == AppThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '主题',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );      },
    );
  }
}
