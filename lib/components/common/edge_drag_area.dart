import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// 边缘拖动区域组件 - 在页面边缘提供隐藏的窗口拖动功能
/// 保留用户习惯性操作，不显示任何视觉元素
class EdgeDragArea extends StatelessWidget {
  final Widget child;
  final double topDragHeight;
  final double leftDragWidth;
  final double rightDragWidth;
  final double bottomDragHeight;
  final bool enableTopDrag;
  final bool enableLeftDrag;
  final bool enableRightDrag;
  final bool enableBottomDrag;

  const EdgeDragArea({
    super.key,
    required this.child,
    this.topDragHeight = 20.0,
    this.leftDragWidth = 20.0,
    this.rightDragWidth = 20.0,
    this.bottomDragHeight = 20.0,
    this.enableTopDrag = true,
    this.enableLeftDrag = false,
    this.enableRightDrag = false,
    this.enableBottomDrag = false,
  });

  @override
  Widget build(BuildContext context) {
    // 只在桌面平台启用拖动功能
    final isDraggable =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    if (!isDraggable) {
      return child;
    }

    return Stack(
      children: [
        // 主要内容
        child,

        // 顶部拖动区域
        if (enableTopDrag)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topDragHeight,
            child: _buildDragArea(),
          ),

        // 左侧拖动区域
        if (enableLeftDrag)
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            width: leftDragWidth,
            child: _buildDragArea(),
          ),

        // 右侧拖动区域
        if (enableRightDrag)
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: rightDragWidth,
            child: _buildDragArea(),
          ),

        // 底部拖动区域
        if (enableBottomDrag)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: bottomDragHeight,
            child: _buildDragArea(),
          ),
      ],
    );
  }

  Widget _buildDragArea() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        appWindow.startDragging();
      },
      child: Container(
        // 完全透明，不显示任何视觉元素
        color: Colors.transparent,
        // 在调试模式下可以显示半透明边框以便调试
        // decoration: kDebugMode ? BoxDecoration(
        //   border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
        // ) : null,
      ),
    );
  }
}

/// 简化版边缘拖动区域 - 只提供顶部拖动
class TopEdgeDragArea extends StatelessWidget {
  final Widget child;
  final double dragHeight;

  const TopEdgeDragArea({
    super.key,
    required this.child,
    this.dragHeight = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return EdgeDragArea(
      topDragHeight: dragHeight,
      enableTopDrag: true,
      enableLeftDrag: false,
      enableRightDrag: false,
      enableBottomDrag: false,
      child: child,
    );
  }
}
