import 'package:flutter/material.dart';

/// 通用弹窗菜单工具类
/// 提供可复用的弹窗样式和定位逻辑
class PopupMenuUtils {
  /// 显示定位弹窗
  /// 
  /// [context] - 上下文
  /// [anchorKey] - 锚点组件的GlobalKey
  /// [contentBuilder] - 弹窗内容构建器
  /// [popupWidth] - 弹窗固定宽度，默认200
  /// [popupHeight] - 弹窗固定高度，默认200
  /// [offsetX] - X轴偏移量，默认10
  /// [offsetY] - Y轴偏移量，默认0
  /// [preferredSide] - 首选显示位置，默认右侧
  static Future<void> showPositionedPopup({
    required BuildContext context,
    required GlobalKey anchorKey,
    required Widget Function(BuildContext dialogContext) contentBuilder,
    double popupWidth = 200.0,
    double popupHeight = 200.0,
    double offsetX = 10.0,
    double offsetY = 0.0,
    PopupSide preferredSide = PopupSide.right,
  }) async {
    // 获取锚点位置
    final RenderBox? renderBox = anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final Offset anchorPosition = renderBox.localToGlobal(Offset.zero);
    final Size anchorSize = renderBox.size;
    
    return showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return Stack(
          children: [
            // 透明背景，点击关闭菜单
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: Container(color: Colors.transparent),
              ),
            ),
            // 菜单内容
            _buildPositionedContent(
              context: context,
              dialogContext: dialogContext,
              anchorPosition: anchorPosition,
              anchorSize: anchorSize,
              contentBuilder: contentBuilder,
              popupWidth: popupWidth,
              popupHeight: popupHeight,
              offsetX: offsetX,
              offsetY: offsetY,
              preferredSide: preferredSide,
            ),
          ],
        );
      },
    );
  }

  /// 构建定位的弹窗内容
  static Widget _buildPositionedContent({
    required BuildContext context,
    required BuildContext dialogContext,
    required Offset anchorPosition,
    required Size anchorSize,
    required Widget Function(BuildContext dialogContext) contentBuilder,
    required double popupWidth,
    required double popupHeight,
    required double offsetX,
    required double offsetY,
    required PopupSide preferredSide,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 计算弹窗位置
    final position = _calculateFixedPopupPosition(
      screenSize: Size(screenWidth, screenHeight),
      anchorPosition: anchorPosition,
      anchorSize: anchorSize,
      popupWidth: popupWidth,
      popupHeight: popupHeight,
      offsetX: offsetX,
      offsetY: offsetY,
      preferredSide: preferredSide,
    );
    
    return Positioned(
      top: position.dy,
      left: position.dx,
      child: _buildFixedPopupContainer(
        context: context,
        width: popupWidth,
        height: popupHeight,
        child: contentBuilder(dialogContext),
      ),
    );
  }

  /// 计算固定尺寸弹窗位置
  static Offset _calculateFixedPopupPosition({
    required Size screenSize,
    required Offset anchorPosition,
    required Size anchorSize,
    required double popupWidth,
    required double popupHeight,
    required double offsetX,
    required double offsetY,
    required PopupSide preferredSide,
  }) {
    double left, top;
    
    // 根据首选位置计算初始位置
    switch (preferredSide) {
      case PopupSide.right:
        left = anchorPosition.dx + anchorSize.width + offsetX + 16; // 向右移动16px
        top = anchorPosition.dy + offsetY - (popupHeight / 2); // 向上移动弹窗高度的一半
        break;
      case PopupSide.left:
        left = anchorPosition.dx - popupWidth - offsetX + 16; // 向右移动16px
        top = anchorPosition.dy + offsetY - (popupHeight / 2); // 向上移动弹窗高度的一半
        break;
      case PopupSide.top:
        left = anchorPosition.dx + (anchorSize.width / 2) - (popupWidth / 2) + 16; // 向右移动16px
        top = anchorPosition.dy - popupHeight - offsetY - (popupHeight / 2); // 显示在上方并向上移动弹窗高度的一半
        break;
      case PopupSide.bottom:
        left = anchorPosition.dx + (anchorSize.width / 2) - (popupWidth / 2) + 16; // 向右移动16px
        top = anchorPosition.dy + anchorSize.height + offsetY - (popupHeight / 2); // 显示在下方并向上移动弹窗高度的一半
        break;
    }
    
    // 边界检查和调整
    if (left + popupWidth > screenSize.width) {
      if (preferredSide == PopupSide.right) {
        // 右侧空间不足，尝试左侧
        left = anchorPosition.dx - popupWidth - offsetX + 16; // 向右移动16px
      } else {
        // 其他情况贴右边界
        left = screenSize.width - popupWidth - 10;
      }
    }
    
    if (left < 10) {
      left = 10;
    }
    
    // 垂直位置边界检查
    if (top + popupHeight > screenSize.height) {
      if (preferredSide == PopupSide.bottom) {
        // 下方空间不足，尝试上方
        top = anchorPosition.dy - popupHeight - offsetY - (popupHeight / 2);
      } else {
        // 其他情况贴下边界
        top = screenSize.height - popupHeight - 10;
      }
    }
    
    if (top < 10) {
      top = 10;
    }
    
    return Offset(left, top);
  }

  /// 构建固定尺寸弹窗容器
  static Widget _buildFixedPopupContainer({
    required BuildContext context,
    required double width,
    required double height,
    required Widget child,
  }) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // 内容在弹窗中上下居中，宽度自适应
        child: Center(
          child: child,
        ),
      ),
    );
  }

  /// 构建弹窗菜单项
  static Widget buildPopupMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool isIndented = false,
    double iconSize = 16,
    double fontSize = 14,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // 缩进空间
            if (isIndented) const SizedBox(width: 12),
            // 选中背景容器
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      icon,
                      size: isIndented ? iconSize - 2 : iconSize,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : isIndented
                          ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : isIndented
                              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: isIndented ? fontSize - 1 : fontSize,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分隔线
  static Widget buildDivider(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 1,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
    );
  }
}

/// 弹窗显示位置枚举
enum PopupSide {
  left,
  right,
  top,
  bottom,
}