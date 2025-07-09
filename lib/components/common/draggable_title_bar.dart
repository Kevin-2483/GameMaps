import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io';

/// 可拖动标题栏组件
/// 统一各页面的标题栏格式，添加拖动区域和一致的高度
class DraggableTitleBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final IconData? icon;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final EdgeInsets padding;

  const DraggableTitleBar({
    super.key,
    this.title,
    this.titleWidget,
    this.icon,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 64.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  }) : assert(
         title != null || titleWidget != null,
         'Either title or titleWidget must be provided',
       );

  @override
  Widget build(BuildContext context) {
    // 只在桌面平台添加拖拽功能
    final isDraggable =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    final titleBar = Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color:
            backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outline.withAlpha((0.2 * 255).toInt()),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 左侧图标和标题
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ] else if (icon != null) ...[
            Icon(
              icon,
              color: foregroundColor ?? Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
          ],

          // 标题 - 可拖动区域
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: isDraggable
                  ? (details) {
                      appWindow.startDragging();
                    }
                  : null,
              child: Align(
                alignment: Alignment.centerLeft,
                child:
                    titleWidget ??
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color:
                                foregroundColor ??
                                Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
              ),
            ),
          ),

          // 右侧操作按钮
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(width: 16),
            Row(mainAxisSize: MainAxisSize.min, children: actions!),
          ],
        ],
      ),
    );

    return titleBar;
  }
}

/// 带有更多内容的可拖动标题栏组件
/// 支持在标题行下方添加额外的内容，如下拉菜单等
class DraggableTitleBarWithContent extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? content;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double titleHeight;
  final EdgeInsets titlePadding;
  final EdgeInsets? contentPadding;

  const DraggableTitleBarWithContent({
    super.key,
    required this.title,
    this.icon,
    this.actions,
    this.leading,
    this.content,
    this.backgroundColor,
    this.foregroundColor,
    this.titleHeight = 64.0,
    this.titlePadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    ),
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    // 只在桌面平台添加拖拽功能
    final isDraggable =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    return Container(
      decoration: BoxDecoration(
        color:
            backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outline.withAlpha((0.2 * 255).toInt()),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Container(
            height: titleHeight,
            padding: titlePadding,
            child: Row(
              children: [
                // 左侧图标和标题
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    color:
                        foregroundColor ??
                        Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                ],

                // 标题 - 可拖动区域
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanStart: isDraggable
                        ? (details) {
                            appWindow.startDragging();
                          }
                        : null,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color:
                                  foregroundColor ??
                                  Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),

                // 右侧操作按钮
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Row(mainAxisSize: MainAxisSize.min, children: actions!),
                ],
              ],
            ),
          ),

          // 额外内容
          if (content != null)
            Padding(
              padding: contentPadding ?? const EdgeInsets.all(16.0),
              child: content!,
            ),
        ],
      ),
    );
  }
}
