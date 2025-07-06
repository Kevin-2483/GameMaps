import 'package:flutter/material.dart';
// import 'dart:ui' as ui;
// import 'dart:typed_data';
// import 'dart:math' as math;
import '../../../models/map_layer.dart';
import '../utils/drawing_utils.dart';

/// 预览渲染器 - 负责绘制正在绘制过程中的预览内容
class PreviewRenderer {
  /// 绘制正在绘制的预览内容
  static void drawCurrentDrawing(
    Canvas canvas,
    Size size, {
    required Offset start,
    required Offset end,
    required DrawingElementType elementType,
    required Color color,
    required double strokeWidth,
    required double density,
    required double curvature,
    required TriangleCutType triangleCut,
    List<Offset>? freeDrawingPath,
    String? selectedElementId,
  }) {
    // 橡皮擦特殊预览
    if (elementType == DrawingElementType.eraser) {
      final rect = Rect.fromPoints(start, end);
      final paint = Paint()
        ..color = Colors.red.withAlpha((0.3 * 255).toInt())
        ..style = PaintingStyle.fill;

      switch ((curvature > 0.0, triangleCut != TriangleCutType.none)) {
        case (true, true):
          drawCurvedTrianglePath(canvas, rect, paint, curvature, triangleCut);
          break;
        case (true, false):
          drawCurvedRectangle(canvas, rect, paint, curvature);
          break;
        case (false, true):
          drawCurvedTrianglePath(canvas, rect, paint, curvature, triangleCut);
          break;
        case (false, false):
          canvas.drawRect(rect, paint);
          break;
      }

      // 绘制边框
      final borderPaint = Paint()
        ..color = Colors.red.withAlpha((0.8 * 255).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      switch ((curvature > 0.0, triangleCut != TriangleCutType.none)) {
        case (true, true):
          drawCurvedTrianglePath(
            canvas,
            rect,
            borderPaint,
            curvature,
            triangleCut,
          );
          break;
        case (true, false):
          drawCurvedRectangle(canvas, rect, borderPaint, curvature);
          break;
        case (false, true):
          drawCurvedTrianglePath(
            canvas,
            rect,
            borderPaint,
            curvature,
            triangleCut,
          );
          break;
        case (false, false):
          canvas.drawRect(rect, borderPaint);
          break;
      }
      return;
    }

    // 自由绘制特殊预览
    if (elementType == DrawingElementType.freeDrawing &&
        freeDrawingPath != null &&
        freeDrawingPath.isNotEmpty) {
      final paint = Paint()
        ..color = color.withAlpha((0.7 * 255).toInt())
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(freeDrawingPath[0].dx, freeDrawingPath[0].dy);
      for (int i = 1; i < freeDrawingPath.length; i++) {
        path.lineTo(freeDrawingPath[i].dx, freeDrawingPath[i].dy);
      }
      canvas.drawPath(path, paint);
      return;
    }

    // 文本工具特殊预览 - 显示一个小方块指示放置位置
    if (elementType == DrawingElementType.text) {
      final paint = Paint()
        ..color = color.withAlpha((0.7 * 255).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // 在文本位置绘制一个小方块作为预览
      final rect = Rect.fromCenter(center: start, width: 20, height: 20);
      canvas.drawRect(rect, paint);
      // 绘制文本预览提示
      final textPainter = TextPainter(
        text: TextSpan(
          text: "点击添加文本",
          style: TextStyle(
            color: color.withAlpha((0.7 * 255).toInt()),
            fontSize: 12.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          start.dx - textPainter.width / 2,
          start.dy - textPainter.height / 2,
        ),
      );
      return;
    }

    // 使用固定的画布尺寸来确保坐标转换的一致性
    List<Offset> points;
    if (elementType == DrawingElementType.freeDrawing &&
        freeDrawingPath != null) {
      // 对于自由绘制，使用路径点
      points = freeDrawingPath
          .map((point) => Offset(point.dx / size.width, point.dy / size.height))
          .toList();
    } else {
      // 对于其他绘制类型，使用开始和结束点
      points = [
        Offset(start.dx / size.width, start.dy / size.height),
        Offset(end.dx / size.width, end.dy / size.height),
      ];
    }

    final element = MapDrawingElement(
      id: 'preview',
      type: elementType,
      points: points,
      color: color.withAlpha((0.7 * 255).toInt()),
      strokeWidth: strokeWidth,
      density: density,
      curvature: curvature, // 使用实际的曲率值进行预览
      triangleCut: triangleCut, // 使用实际的三角形切割值进行预览
      createdAt: DateTime.now(),
    );

    // 使用元素渲染器绘制预览
    _drawPreviewElement(canvas, element, size);
  }

  /// 绘制预览元素（复用元素渲染逻辑）
  static void _drawPreviewElement(
    Canvas canvas,
    MapDrawingElement element,
    Size size,
  ) {
    final paint = Paint()
      ..color = element.color
      ..strokeWidth = element.strokeWidth
      ..style = PaintingStyle.stroke;

    // Convert normalized coordinates to screen coordinates
    final points = element.points
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList();

    // 特殊处理：文本元素只需要一个点，自由绘制可能有多个点
    if (element.type == DrawingElementType.text) {
      if (points.isEmpty) return;
      drawText(canvas, element, size);
      return;
    }

    if (element.type == DrawingElementType.freeDrawing) {
      if (points.isEmpty) return;
      drawFreeDrawingPath(canvas, element, paint, size);
      return;
    }

    // 其他绘制类型需要至少两个点
    if (points.length < 2) return;

    final start = points[0];
    final end = points[1];
    final rect = Rect.fromPoints(start, end);

    // 检查是否需要应用三角形切割
    final needsTriangleClip =
        element.triangleCut != TriangleCutType.none &&
        isTriangleCutApplicable(element.type);

    if (needsTriangleClip) {
      // 保存画布状态并应用三角形裁剪
      canvas.save();
      final trianglePath = createTrianglePath(rect, element.triangleCut);
      canvas.clipPath(trianglePath);
    }

    switch (element.type) {
      case DrawingElementType.line:
        canvas.drawLine(start, end, paint);
        break;
      case DrawingElementType.dashedLine:
        drawDashedLine(canvas, start, end, paint, element.density);
        break;

      case DrawingElementType.imageArea:
        drawImageEmptyPlaceholder(canvas, rect, BoxFit.contain);
        break;

      case DrawingElementType.arrow:
        drawArrow(canvas, start, end, paint);
        break;
      case DrawingElementType.rectangle:
        paint.style = PaintingStyle.fill;
        if (element.curvature > 0.0) {
          drawCurvedRectangle(canvas, rect, paint, element.curvature);
        } else {
          canvas.drawRect(rect, paint);
        }
        break;

      case DrawingElementType.hollowRectangle:
        paint.style = PaintingStyle.stroke;
        if (element.curvature > 0.0) {
          drawCurvedRectangle(canvas, rect, paint, element.curvature);
        } else {
          canvas.drawRect(rect, paint);
        }
        break;
      case DrawingElementType.diagonalLines:
        if (element.curvature > 0.0) {
          drawCurvedDiagonalPattern(
            canvas,
            rect,
            paint,
            element.density,
            element.curvature,
          );
        } else {
          drawDiagonalPattern(canvas, start, end, paint, element.density);
        }
        break;

      case DrawingElementType.crossLines:
        if (element.curvature > 0.0) {
          drawCurvedCrossPattern(
            canvas,
            rect,
            paint,
            element.density,
            element.curvature,
          );
        } else {
          drawCrossPattern(canvas, start, end, paint, element.density);
        }
        break;

      case DrawingElementType.dotGrid:
        if (element.curvature > 0.0) {
          drawCurvedDotGrid(
            canvas,
            rect,
            paint,
            element.density,
            element.curvature,
          );
        } else {
          drawDotGrid(canvas, start, end, paint, element.density);
        }
        break;

      case DrawingElementType.freeDrawing:
        // 已在上面处理
        break;

      case DrawingElementType.text:
        // 已在上面处理
        break;

      case DrawingElementType.eraser:
        // 橡皮擦不需要绘制，它只是删除元素
        break;
    }

    if (needsTriangleClip) {
      // 恢复画布状态
      canvas.restore();
    }
  }
}
