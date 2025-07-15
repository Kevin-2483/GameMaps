import 'package:flutter/material.dart';
// import 'dart:ui' as ui;
// import 'dart:typed_data';
import 'dart:math' as math;
import '../../../models/map_layer.dart';
import '../utils/drawing_utils.dart';

/// 选择和高亮渲染器 - 负责绘制选中元素的高亮效果和操作控制柄
class HighlightRenderer {
  /// 绘制选中元素的彩虹高亮效果
  static void drawRainbowHighlight(
    Canvas canvas,
    MapDrawingElement element,
    Size size,
  ) {
    // 首先获取元素的坐标
    if (element.points.isEmpty) return;

    // 彩虹色渐变效果（用于填充文本或形状）
    final rainbowColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    // 获取当前时间以创建动画效果
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    final animOffset = now % 1.0; // 0.0 - 1.0 之间循环变化

    // 根据元素类型绘制不同的内容
    switch (element.type) {
      case DrawingElementType.text:
        // 文本元素
        if (element.text == null || element.text!.isEmpty) return;

        final position = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );

        // 创建彩虹渐变文本
        final textPainter = TextPainter(
          text: TextSpan(
            text: element.text!,
            style: TextStyle(
              fontSize: element.fontSize ?? 16.0,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: rainbowColors,
                  transform: GradientRotation(animOffset * math.pi * 2),
                ).createShader(Rect.fromLTWH(0, 0, 300, 50)),
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(canvas, position);
        break;

      case DrawingElementType.freeDrawing:
        // 自由绘制路径
        if (element.points.length < 2) return;

        final path = Path();
        final screenPoints = element.points
            .map(
              (point) => Offset(point.dx * size.width, point.dy * size.height),
            )
            .toList();

        path.moveTo(screenPoints[0].dx, screenPoints[0].dy);
        for (int i = 1; i < screenPoints.length; i++) {
          path.lineTo(screenPoints[i].dx, screenPoints[i].dy);
        }

        // 彩虹渐变画笔
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = element.strokeWidth + 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..shader = LinearGradient(
            colors: rainbowColors,
            transform: GradientRotation(animOffset * math.pi * 2),
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

        canvas.drawPath(path, paint);
        break;

      default:
        // 其他基于两点的元素
        if (element.points.length < 2) return;

        final start = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );

        final end = Offset(
          element.points[1].dx * size.width,
          element.points[1].dy * size.height,
        );

        // 彩虹渐变画笔
        final paint = Paint()
          ..strokeWidth = element.strokeWidth + 2
          ..shader = LinearGradient(
            colors: rainbowColors,
            transform: GradientRotation(animOffset * math.pi * 2),
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

        // 根据不同的绘制类型绘制不同的形状
        switch (element.type) {
          case DrawingElementType.line:
            paint.style = PaintingStyle.stroke;
            canvas.drawLine(start, end, paint);
            break;
          case DrawingElementType.dashedLine:
            paint.style = PaintingStyle.stroke;
            drawDashedLine(canvas, start, end, paint, element.density);
            break;

          case DrawingElementType.arrow:
            paint.style = PaintingStyle.stroke;
            drawArrow(canvas, start, end, paint);
            break;
          case DrawingElementType.rectangle:
            paint.style = PaintingStyle.fill;
            final rect = Rect.fromPoints(start, end);
            canvas.drawRect(rect, paint);
            break;

          case DrawingElementType.hollowRectangle:
            paint.style = PaintingStyle.stroke;
            final rect = Rect.fromPoints(start, end);
            canvas.drawRect(rect, paint);
            break;
          case DrawingElementType.diagonalLines:
            paint.style = PaintingStyle.stroke;
            drawDiagonalPattern(canvas, start, end, paint, element.density);
            break;

          case DrawingElementType.crossLines:
            paint.style = PaintingStyle.stroke;
            drawCrossPattern(canvas, start, end, paint, element.density);
            break;

          case DrawingElementType.dotGrid:
            paint.style = PaintingStyle.fill;
            drawDotGrid(canvas, start, end, paint, element.density);
            break;

          default:
            // 默认绘制一个边框
            paint.style = PaintingStyle.stroke;
            final rect = Rect.fromPoints(start, end);
            canvas.drawRect(rect, paint);
            break;
        }
        break;
    }
  }

  /// 绘制调整大小的控制柄
  static void drawResizeHandles(
    Canvas canvas,
    MapDrawingElement element,
    Size size, {
    double? handleSize,
  }) {
    // 文本元素特殊处理
    if (element.type == DrawingElementType.text) {
      _drawTextElementBounds(canvas, element, size, handleSize: handleSize);
      return;
    }

    // 获取所有调整手柄的位置
    final handles = getResizeHandles(element, size, handleSize: handleSize);

    if (handles.isEmpty) return;

    // 外边框画笔（白色边框）
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // 内部填充画笔（蓝色）
    final fillPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // 使用动态大小计算圆形半径
    final effectiveHandleSize = handleSize ?? 8.0;
    final radius = effectiveHandleSize / 4.0; // 控制柄内圆半径为控制柄大小的1/4
    final borderRadius = radius + 0.5;

    // 绘制每个控制柄为圆形
    for (final handle in handles) {
      final center = handle.center;

      // 白色边框圆（稍大）
      canvas.drawCircle(center, borderRadius, borderPaint);

      // 蓝色填充圆（略小）
      canvas.drawCircle(center, radius, fillPaint);
    }
  }
  /// 绘制文本元素的边界框、中心十字线和调整柄
  static void _drawTextElementBounds(
    Canvas canvas,
    MapDrawingElement element,
    Size size, {
    double? handleSize,
  }) {
    if (element.points.isEmpty) return;

    final fontSize = element.fontSize ?? 16.0;
    final anchorPoint = Offset(
      element.points[0].dx * size.width,
      element.points[0].dy * size.height,
    );

    // 创建正方形边界框，调整位置使其包围文本
    // 与ElementInteractionManager中的计算保持一致
    final boundingRect = Rect.fromLTWH(
      anchorPoint.dx - fontSize / 2,
      anchorPoint.dy - fontSize / 2,
      fontSize,
      fontSize,
    );

    // 绘制边界框
    final boundsPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRect(boundingRect, boundsPaint);

    // --- 新增代码：绘制中心十字线 ---
    final crosshairPaint = Paint()
      ..color = Colors.blue
          .withOpacity(0.5) // 使用半透明蓝色
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5; // 绘制一条细线

    // 绘制水平线
    canvas.drawLine(
      Offset(boundingRect.left, boundingRect.center.dy),
      Offset(boundingRect.right, boundingRect.center.dy),
      crosshairPaint,
    );

    // 绘制垂直线
    canvas.drawLine(
      Offset(boundingRect.center.dx, boundingRect.top),
      Offset(boundingRect.center.dx, boundingRect.bottom),
      crosshairPaint,
    );
    // --- 新增代码结束 ---

    // 绘制调整柄
    final effectiveHandleSize = handleSize ?? 8.0;
    final radius = effectiveHandleSize / 4.0;
    final borderRadius = radius + 0.5;

    // 外边框画笔（白色边框）
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // 内部填充画笔（蓝色）
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // 按照ResizeHandle枚举顺序绘制8个调整柄
    final handlePositions = [
      boundingRect.topLeft, // topLeft
      boundingRect.topRight, // topRight
      boundingRect.bottomLeft, // bottomLeft
      boundingRect.bottomRight, // bottomRight
      Offset(boundingRect.center.dx, boundingRect.top), // topCenter
      Offset(boundingRect.center.dx, boundingRect.bottom), // bottomCenter
      Offset(boundingRect.left, boundingRect.center.dy), // centerLeft
      Offset(boundingRect.right, boundingRect.center.dy), // centerRight
    ];

    for (final position in handlePositions) {
      // 白色边框圆（稍大）
      canvas.drawCircle(position, borderRadius, borderPaint);
      // 蓝色填充圆（略小）
      canvas.drawCircle(position, radius, fillPaint);
    }
  }

  /// 获取调整大小控制柄的矩形区域
  static List<Rect> getResizeHandles(
    MapDrawingElement element,
    Size canvasSize, {
    double? handleSize,
  }) {
    if (element.points.length < 2) return [];

    final start = Offset(
      element.points[0].dx * canvasSize.width,
      element.points[0].dy * canvasSize.height,
    );
    final end = Offset(
      element.points[1].dx * canvasSize.width,
      element.points[1].dy * canvasSize.height,
    );
    final rect = Rect.fromPoints(start, end);

    final effectiveHandleSize = handleSize ?? 8.0;
    final handles = <Rect>[];

    // 四个角的控制柄
    handles.add(
      Rect.fromCenter(
        center: rect.topLeft,
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: rect.topRight,
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: rect.bottomLeft,
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: rect.bottomRight,
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );

    // 边中点的控制柄
    handles.add(
      Rect.fromCenter(
        center: Offset(rect.center.dx, rect.top),
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: Offset(rect.center.dx, rect.bottom),
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: Offset(rect.left, rect.center.dy),
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: Offset(rect.right, rect.center.dy),
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );

    return handles;
  }
}
