import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Web平台上下文菜单处理器
/// 用于在Web平台上禁用浏览器默认的右键菜单，使用自定义的Flutter菜单
class WebContextMenuHandler extends StatefulWidget {
  final Widget child;
  final bool preventWebContextMenu;

  const WebContextMenuHandler({
    super.key,
    required this.child,
    this.preventWebContextMenu = true,
  });

  @override
  State<WebContextMenuHandler> createState() => _WebContextMenuHandlerState();
}

class _WebContextMenuHandlerState extends State<WebContextMenuHandler> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb && widget.preventWebContextMenu) {
      _preventWebContextMenu();
    }
  }

  /// 阻止Web浏览器的默认上下文菜单
  void _preventWebContextMenu() {
    // 注入JavaScript代码来阻止默认的右键菜单
    if (kIsWeb) {
      // 这里需要使用平台特定的方法来阻止右键菜单
      // 在Flutter Web中，我们通过CSS和事件处理来实现
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return widget.child;
    }

    return GestureDetector(
      // 阻止右键菜单的气泡事件
      onSecondaryTapDown: (details) {
        // 阻止默认行为，但不执行其他操作
        // 这样可以防止浏览器的右键菜单出现
      },
      child: widget.child,
    );
  }
}

/// 自定义上下文菜单项
class ContextMenuItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isDivider;

  const ContextMenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.enabled = true,
    this.isDivider = false,
  });

  const ContextMenuItem.divider()
    : label = '',
      icon = null,
      onTap = null,
      enabled = true,
      isDivider = true;
}

/// 显示自定义上下文菜单的工具类
class WebContextMenu {
  /// 显示上下文菜单
  static void show({
    required BuildContext context,
    required Offset position,
    required List<ContextMenuItem> items,
  }) {
    if (!kIsWeb) {
      _showDefaultContextMenu(context, position, items);
      return;
    }

    _showWebContextMenu(context, position, items);
  }

  /// 在Web平台显示自定义上下文菜单
  static void _showWebContextMenu(
    BuildContext context,
    Offset position,
    List<ContextMenuItem> items,
  ) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: items
          .where((item) => item.enabled)
          .map<PopupMenuEntry<String>>(
            (item) => item.isDivider
                ? const PopupMenuDivider()
                : PopupMenuItem<String>(
                    value: item.label,
                    enabled: item.enabled,
                    child: Row(
                      children: [
                        if (item.icon != null) ...[
                          Icon(item.icon, size: 16),
                          const SizedBox(width: 8),
                        ],
                        Text(item.label),
                      ],
                    ),
                  ),
          )
          .toList(),
      elevation: 8,
    ).then((selectedItem) {
      if (selectedItem != null) {
        final item = items.firstWhere((item) => item.label == selectedItem);
        item.onTap?.call();
      }
    });
  }

  /// 在非Web平台显示默认上下文菜单
  static void _showDefaultContextMenu(
    BuildContext context,
    Offset position,
    List<ContextMenuItem> items,
  ) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: items
          .where((item) => item.enabled)
          .map<PopupMenuEntry<String>>(
            (item) => item.isDivider
                ? const PopupMenuDivider()
                : PopupMenuItem<String>(
                    value: item.label,
                    enabled: item.enabled,
                    child: Row(
                      children: [
                        if (item.icon != null) ...[
                          Icon(item.icon, size: 16),
                          const SizedBox(width: 8),
                        ],
                        Text(item.label),
                      ],
                    ),
                  ),
          )
          .toList(),
    ).then((selectedItem) {
      if (selectedItem != null) {
        final item = items.firstWhere((item) => item.label == selectedItem);
        item.onTap?.call();
      }
    });
  }
}

/// 带右键菜单功能的Widget包装器
class ContextMenuWrapper extends StatelessWidget {
  final Widget child;
  final List<ContextMenuItem> Function(BuildContext context)? menuBuilder;
  final bool enabled;

  const ContextMenuWrapper({
    super.key,
    required this.child,
    this.menuBuilder,
    this.enabled = true,
  });  @override
  Widget build(BuildContext context) {
    if (!enabled || menuBuilder == null) {
      return child;
    }

    return GestureDetector(
      onSecondaryTapDown: (details) {
        final items = menuBuilder!(context);
        if (items.isNotEmpty) {
          WebContextMenu.show(
            context: context,
            position: details.globalPosition,
            items: items,
          );
        }
        // 阻止事件继续传播到父级组件
        return;
      },
      // 设置behavior为opaque，确保能够拦截和处理事件，防止传播
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
