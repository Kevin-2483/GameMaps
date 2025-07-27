import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 画布刻度尺组件
class CanvasRuler extends StatelessWidget {
  final double size; // 刻度尺的宽度或高度
  final bool isHorizontal; // 是否为水平刻度尺
  final double canvasSize; // 画布尺寸（宽度或高度）
  final double scale; // 当前缩放比例
  final double offset; // 当前偏移量
  final double padding; // 用户设置的边距

  const CanvasRuler({
    super.key,
    required this.size,
    required this.isHorizontal,
    required this.canvasSize,
    required this.scale,
    required this.offset,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isHorizontal ? null : size,
      height: isHorizontal ? size : null,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
      ),
      child: CustomPaint(
        size: isHorizontal ? Size.infinite : Size(size, double.infinity),
        painter: _RulerPainter(
          isHorizontal: isHorizontal,
          canvasSize: canvasSize,
          scale: scale,
          offset: offset,
          padding: padding,
          textStyle: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          lineColor: Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}

/// 刻度尺绘制器
class _RulerPainter extends CustomPainter {
  final bool isHorizontal;
  final double canvasSize;
  final double scale;
  final double offset;
  final double padding;
  final TextStyle textStyle;
  final Color lineColor;

  const _RulerPainter({
    required this.isHorizontal,
    required this.canvasSize,
    required this.scale,
    required this.offset,
    required this.padding,
    required this.textStyle,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    // 计算可见区域
    final viewportSize = isHorizontal ? size.width : size.height;
    final rulerSize = isHorizontal ? size.height : size.width;

    // 确定合适的刻度间隔（基于缩放级别和视口大小）
    double tickInterval = _getTickInterval(scale, viewportSize);

    // InteractiveViewer的boundaryMargin创建了视觉边距，但不影响画布坐标系
    // 画布坐标0应该对应到刻度尺中的offset位置（忽略padding）
    // 根据用户反馈，当padding=0时位置最接近正确
    final canvas0PositionInRuler = offset;

    // 计算整个刻度尺区域对应的画布坐标范围 - 让刻度填满整个刻度尺区域
    final rulerStartCanvasValue = -canvas0PositionInRuler / scale;
    final rulerEndCanvasValue = (viewportSize - canvas0PositionInRuler) / scale;

    // 计算第一个刻度值（向下取整到刻度间隔）
    final firstTickValue =
        (rulerStartCanvasValue / tickInterval).floor() * tickInterval;

    // 绘制刻度 - 填充整个刻度尺区域
    // 大刻度间隔
    double majorTickValue = firstTickValue;

    while (majorTickValue <= rulerEndCanvasValue + tickInterval) {
      // 计算大刻度在刻度尺中的位置
      final majorTickPosition =
          canvas0PositionInRuler + (majorTickValue * scale);

      // 绘制大刻度
      if (majorTickPosition >= 0 && majorTickPosition <= viewportSize) {
        _drawMajorTick(
          canvas,
          majorTickPosition,
          majorTickValue,
          rulerSize,
          tickInterval,
        );
      }

      // 绘制小刻度（在大刻度中间）
      final minorTickValue = majorTickValue + (tickInterval / 2);
      final minorTickPosition =
          canvas0PositionInRuler + (minorTickValue * scale);

      if (minorTickPosition >= 0 &&
          minorTickPosition <= viewportSize &&
          minorTickValue <= rulerEndCanvasValue) {
        _drawMinorTick(canvas, minorTickPosition, rulerSize);
      }

      majorTickValue += tickInterval;
    }
  }

  /// 根据缩放级别确定合适的刻度间隔
  /// 确保最小显示16个大刻度
  double _getTickInterval(double scale, double viewportSize) {
    // 计算需要的间隔以显示至少16个大刻度
    final minInterval = (viewportSize / scale) / 16;

    // 选择合适的间隔值（100的倍数）
    if (minInterval <= 50) return 50.0;
    if (minInterval <= 100) return 100.0;
    if (minInterval <= 200) return 200.0;
    if (minInterval <= 400) return 400.0;
    if (minInterval <= 800) return 800.0;
    return 1600.0;
  }

  /// 绘制大刻度
  void _drawMajorTick(
    Canvas canvas,
    double position,
    double value,
    double rulerSize,
    double tickInterval,
  ) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    final tickLength = rulerSize * 0.6;

    // 绘制大刻度线
    if (isHorizontal) {
      canvas.drawLine(
        Offset(position, rulerSize - tickLength),
        Offset(position, rulerSize),
        paint,
      );
    } else {
      canvas.drawLine(
        Offset(rulerSize - tickLength, position),
        Offset(rulerSize, position),
        paint,
      );
    }

    // 根据缩放级别动态调整数字标签间隔
    double labelInterval;
    if (scale >= 2.0) {
      labelInterval = 100.0; // 高缩放时每100px显示数字
    } else if (scale >= 1.0) {
      labelInterval = 200.0; // 中等缩放时每200px显示数字
    } else if (scale >= 0.5) {
      labelInterval = 400.0; // 低缩放时每400px显示数字
    } else {
      labelInterval = 800.0; // 很低缩放时每800px显示数字
    }

    final shouldShowLabel = (value % labelInterval) == 0;
    if (shouldShowLabel) {
      final valueText = value.toInt().toString();
      final textPainter = TextPainter(
        text: TextSpan(text: valueText, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      Offset textOffset;
      if (isHorizontal) {
        textOffset = Offset(position - textPainter.width / 2, 2);
      } else {
        textOffset = Offset(2, position - textPainter.height / 2);
      }

      textPainter.paint(canvas, textOffset);
    }
  }

  /// 绘制小刻度
  void _drawMinorTick(Canvas canvas, double position, double rulerSize) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    final tickLength = rulerSize * 0.3;

    // 绘制小刻度线
    if (isHorizontal) {
      canvas.drawLine(
        Offset(position, rulerSize - tickLength),
        Offset(position, rulerSize),
        paint,
      );
    } else {
      canvas.drawLine(
        Offset(rulerSize - tickLength, position),
        Offset(rulerSize, position),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.offset != offset ||
        oldDelegate.padding != padding;
  }
}
