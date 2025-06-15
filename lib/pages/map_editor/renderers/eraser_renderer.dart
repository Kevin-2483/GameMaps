import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
import '../../../models/map_layer.dart';
import '../utils/drawing_utils.dart';
import 'element_renderer.dart';

/// 橡皮擦渲染器 - 负责处理橡皮擦遮挡效果的渲染逻辑
///
/// 使用轴对齐矩形（AABB）重叠检测算法来简化重叠判断：
/// - 将所有形状（包括三角切割和曲率参数）都简化为边界矩形
/// - 使用统一的AABB算法进行重叠检测
/// - 虽然会有个别精度损失，但大大提升了性能和稳定性
class EraserRenderer {
  /// 绘制带有橡皮擦遮挡效果的元素
  static void drawElementWithEraserMask(
    Canvas canvas,
    MapDrawingElement element,
    List<MapDrawingElement> eraserElements,
    Size size, {
    Map<String, ui.Image>? imageCache,
    ui.Image? imageBufferCachedImage,
    Uint8List? currentImageBufferData,
    BoxFit imageBufferFit = BoxFit.contain,
  }) {
    // 找到影响当前元素的橡皮擦（z值更高的）
    final affectingErasers = eraserElements
        .where((eraser) => eraser.zIndex > element.zIndex)
        .toList();    if (affectingErasers.isEmpty) {
      // 没有橡皮擦影响，直接绘制
      // 调试信息：检查图片选区元素
      if (element.type == DrawingElementType.imageArea) {
        debugPrint('EraserRenderer: 绘制便签图片选区元素, imageData=${element.imageData != null ? '${element.imageData!.length} bytes' : 'null'}');
      }
      
      ElementRenderer.drawElement(
        canvas,
        element,
        size,
        imageCache: imageCache,
        imageBufferCachedImage: imageBufferCachedImage,
        currentImageBufferData: currentImageBufferData,
        imageBufferFit: imageBufferFit,
      );
      return;
    }

    // 保存canvas状态
    canvas.save();

    // 创建裁剪路径，初始为整个画布区域，然后从中排除所有相关橡皮擦区域
    Path clipPath = Path();
    clipPath.addRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
    ); // 添加整个画布区域作为基础

    // 减去所有影响当前元素的橡皮擦区域
    for (final eraser in affectingErasers) {
      // 确保橡皮擦元素有足够的点来定义一个矩形
      // 并且橡皮擦类型是 eraser (如果你的 MapDrawingElement 有 type 属性来区分普通元素和橡皮擦)
      if (eraser.points.length >=
          2 /* && eraser.type == DrawingElementType.eraser */ ) {
        // 转换橡皮擦坐标到屏幕坐标
        final eraserStart = Offset(
          eraser.points[0].dx * size.width,
          eraser.points[0].dy * size.height,
        );
        final eraserEnd = Offset(
          eraser.points[1].dx * size.width,
          eraser.points[1].dy * size.height,
        );
        final eraserRect = Rect.fromPoints(eraserStart, eraserEnd);

        // 检查橡皮擦是否与当前元素重叠 (这个函数对于性能很重要)
        // 确保 _doesEraserAffectElement 内部也使用了考虑 triangleCut 的碰撞检测逻辑
        final doesEraserAffectElement = _doesEraserAffectElement(
          element,
          eraser,
          size,
        );
        // print(doesEraserAffectElement);
        if (doesEraserAffectElement) {
          // *** 修改在这里：调用 getFinalEraserPath 并传入 triangleCut ***
          final Path singleEraserPath = getFinalEraserPath(
            eraserRect,
            eraser.curvature,
            eraser.triangleCut, // 使用橡皮擦元素的 triangleCut 属性
          );

          // 从允许绘制的区域中减去这个橡皮擦的路径
          clipPath = Path.combine(
            PathOperation.difference,
            clipPath,
            singleEraserPath,
          );
        }
      }
    }

    // 应用计算好的裁剪路径
    // 后续的绘制操作将只在 clipPath 定义的区域内可见
    canvas.clipPath(clipPath);

    // 在裁剪后的区域内绘制元素
    ElementRenderer.drawElement(
      canvas,
      element,
      size,
      imageCache: imageCache,
      imageBufferCachedImage: imageBufferCachedImage,
      currentImageBufferData: currentImageBufferData,
      imageBufferFit: imageBufferFit,
    );

    // 恢复canvas状态
    canvas.restore();
  }

  /// 检查橡皮擦是否影响元素 - 使用轴对齐矩形（AABB）重叠检测算法
  static bool _doesEraserAffectElement(
    MapDrawingElement element,
    MapDrawingElement eraser,
    Size size,
  ) {
    // 基础检查
    if (element.points.isEmpty || eraser.points.length < 2) return false;

    // 获取橡皮擦的边界矩形（AABB）
    final eraserStart = Offset(
      eraser.points[0].dx * size.width,
      eraser.points[0].dy * size.height,
    );
    final eraserEnd = Offset(
      eraser.points[1].dx * size.width,
      eraser.points[1].dy * size.height,
    );
    final Rect eraserRect = Rect.fromPoints(eraserStart, eraserEnd);

    // 根据元素类型获取元素的边界矩形（AABB）
    Rect elementRect;

    switch (element.type) {
      case DrawingElementType.text:
        if (element.points.isEmpty) return false;
        // 文本元素：创建一个小的边界矩形围绕文本位置
        final textPosition = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );
        const textBounds = 20.0; // 文本边界框大小
        elementRect = Rect.fromCenter(
          center: textPosition,
          width: textBounds,
          height: textBounds,
        );
        break;

      case DrawingElementType.freeDrawing:
        if (element.points.isEmpty) return false;
        // 自由绘制：计算包含所有点的最小边界矩形
        double minX = double.infinity;
        double minY = double.infinity;
        double maxX = double.negativeInfinity;
        double maxY = double.negativeInfinity;

        for (final point in element.points) {
          final screenPoint = Offset(
            point.dx * size.width,
            point.dy * size.height,
          );
          minX = math.min(minX, screenPoint.dx);
          minY = math.min(minY, screenPoint.dy);
          maxX = math.max(maxX, screenPoint.dx);
          maxY = math.max(maxY, screenPoint.dy);
        }

        // 添加一些边距以确保检测到边缘情况
        const margin = 5.0;
        elementRect = Rect.fromLTRB(
          minX - margin,
          minY - margin,
          maxX + margin,
          maxY + margin,
        );
        break;

      default: // 矩形类元素
        if (element.points.length < 2) return false;
        final elementStart = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );
        final elementEnd = Offset(
          element.points[1].dx * size.width,
          element.points[1].dy * size.height,
        );
        elementRect = Rect.fromPoints(elementStart, elementEnd);
        break;
    }

    // 使用轴对齐矩形（AABB）重叠检测算法
    // 两个矩形重叠的条件：
    // 1. 橡皮擦的左边 < 元素的右边
    // 2. 橡皮擦的右边 > 元素的左边
    // 3. 橡皮擦的上边 < 元素的下边
    // 4. 橡皮擦的下边 > 元素的上边
    return eraserRect.left < elementRect.right &&
        eraserRect.right > elementRect.left &&
        eraserRect.top < elementRect.bottom &&
        eraserRect.bottom > elementRect.top;
  }
}
