import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
import '../../../models/map_layer.dart';
import '../utils/drawing_utils.dart';

/// 元素渲染器 - 负责绘制地图元素的核心渲染逻辑
class ElementRenderer {
  /// 绘制单个元素
  static void drawElement(
    Canvas canvas,
    MapDrawingElement element,
    Size size, {
    Map<String, ui.Image>? imageCache,
    ui.Image? imageBufferCachedImage,
    Uint8List? currentImageBufferData,
    BoxFit imageBufferFit = BoxFit.contain,
  }) {
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
        _drawImageArea(
          canvas,
          element,
          size,
          imageCache: imageCache,
          imageBufferCachedImage: imageBufferCachedImage,
          currentImageBufferData: currentImageBufferData,
          imageBufferFit: imageBufferFit,
        );
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

  /// 绘制图片区域元素
  static void _drawImageArea(
    Canvas canvas,
    MapDrawingElement element,
    Size size, {
    Map<String, ui.Image>? imageCache,
    ui.Image? imageBufferCachedImage,
    Uint8List? currentImageBufferData,
    BoxFit imageBufferFit = BoxFit.contain,
  }) {
    if (element.points.length < 2) return;

    final start = Offset(
      element.points[0].dx * size.width,
      element.points[0].dy * size.height,
    );
    final end = Offset(
      element.points[1].dx * size.width,
      element.points[1].dy * size.height,
    );
    final rect = Rect.fromPoints(start, end);

    // 检查是否需要应用裁剪
    final needsTriangleClip = element.triangleCut != TriangleCutType.none;
    final needsCurvatureClip = element.curvature > 0.0;

    if (needsTriangleClip || needsCurvatureClip) {
      canvas.save();

      if (needsCurvatureClip && needsTriangleClip) {
        final Path finalPath = getFinalEraserPath(
          rect,
          element.curvature,
          element.triangleCut,
        );
        canvas.clipPath(finalPath);
      } else if (needsCurvatureClip) {
        final Path curvedPath = createSuperellipsePath(
          rect,
          element.curvature,
        );
        canvas.clipPath(curvedPath);
      } else if (needsTriangleClip) {
        final Path trianglePath = createTrianglePath(
          rect,
          element.triangleCut,
        );
        canvas.clipPath(trianglePath);
      }
    }

    // 绘制图片内容
    if (element.imageData != null) {
      // 1. 优先使用元素自己的图片数据
      final cachedImage = imageCache?[element.id];
      if (cachedImage != null) {        drawCachedImage(
          canvas,
          cachedImage,
          rect,
          element.imageFit ?? BoxFit.contain,
        );
      } else {
        // 如果没有缓存，显示占位符
        drawImageEmptyPlaceholder(
          canvas,
          rect,
          element.imageFit ?? BoxFit.contain,
        );
      }
    } else if (imageBufferCachedImage != null) {
      // 2. 使用图片缓冲区的缓存图片
      drawCachedImage(canvas, imageBufferCachedImage, rect, imageBufferFit);
    } else if (currentImageBufferData != null) {
      // 3. 显示图片缓冲区加载占位符
      drawImageBufferLoadingPlaceholder(canvas, rect);
    } else {
      // 4. 显示空图片占位符
      drawImageEmptyPlaceholder(canvas, rect, imageBufferFit);
    }

    if (needsTriangleClip || needsCurvatureClip) {
      canvas.restore();
    }
  }
  /// 绘制缓存的图片
  static void drawCachedImage(
    Canvas canvas,
    ui.Image image,
    Rect rect,
    BoxFit fit,
  ) {
    final Size sourceSize = Size(image.width.toDouble(), image.height.toDouble());
    final Size destinationSize = rect.size;

    // 计算图片在目标矩形中的实际绘制区域
    late Rect destinationRect;
    late Rect sourceRect;

    switch (fit) {
      case BoxFit.contain:
        final double scale = math.min(
          destinationSize.width / sourceSize.width,
          destinationSize.height / sourceSize.height,
        );
        final Size scaledSize = Size(
          sourceSize.width * scale,
          sourceSize.height * scale,
        );
        destinationRect = Rect.fromCenter(
          center: rect.center,
          width: scaledSize.width,
          height: scaledSize.height,
        );
        sourceRect = Rect.fromLTWH(0, 0, sourceSize.width, sourceSize.height);
        break;

      case BoxFit.cover:
        final double scale = math.max(
          destinationSize.width / sourceSize.width,
          destinationSize.height / sourceSize.height,
        );
        final Size scaledSize = Size(
          destinationSize.width / scale,
          destinationSize.height / scale,
        );
        sourceRect = Rect.fromCenter(
          center: Offset(sourceSize.width / 2, sourceSize.height / 2),
          width: scaledSize.width,
          height: scaledSize.height,
        );
        destinationRect = rect;
        break;

      case BoxFit.fill:
      default:
        sourceRect = Rect.fromLTWH(0, 0, sourceSize.width, sourceSize.height);
        destinationRect = rect;
        break;
    }

    // 绘制图片
    canvas.drawImageRect(image, sourceRect, destinationRect, Paint());
  }

  /// 绘制图片缓冲区加载占位符
  static void drawImageBufferLoadingPlaceholder(Canvas canvas, Rect rect) {
    // 半透明背景
    final backgroundPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, backgroundPaint);

    // 边框
    final borderPaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(rect, borderPaint);

    // 加载图标
    final iconSize = math.min(rect.width, rect.height) * 0.2;
    final center = rect.center;

    final iconPaint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // 简单的加载图标 (圆形)
    canvas.drawCircle(center, iconSize / 2, iconPaint);

    // 绘制提示文本
    final textPainter = TextPainter(
      text: TextSpan(
        text: '加载中...',
        style: TextStyle(
          color: Colors.blue.withOpacity(0.7),
          fontSize: 12.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + iconSize / 2 + 4,
      ),
    );
  }
}
