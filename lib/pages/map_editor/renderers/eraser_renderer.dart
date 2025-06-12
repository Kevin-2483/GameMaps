import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
import '../../../models/map_layer.dart';
import '../utils/drawing_utils.dart';
import 'element_renderer.dart';

/// 橡皮擦渲染器 - 负责处理橡皮擦遮挡效果的渲染逻辑
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
        .toList();

    if (affectingErasers.isEmpty) {
      // 没有橡皮擦影响，直接绘制
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

  /// 检查橡皮擦是否影响元素
  static bool _doesEraserAffectElement(
    MapDrawingElement element,
    MapDrawingElement eraser,
    Size size,
  ) {
    // 基础检查
    if (element.points.isEmpty || eraser.points.length < 2) return false;

    // 获取橡皮擦的基础信息
    final eraserStart = Offset(
      eraser.points[0].dx * size.width,
      eraser.points[0].dy * size.height,
    );
    final eraserEnd = Offset(
      eraser.points[1].dx * size.width,
      eraser.points[1].dy * size.height,
    );
    final Rect eraserRect = Rect.fromPoints(eraserStart, eraserEnd);
    final double eraserCurvature = eraser.curvature;
    final TriangleCutType eraserTriangleCut = eraser.triangleCut; // 获取橡皮擦的切割类型
    // print(eraserTriangleCut);

    // 根据元素类型进行判断
    switch (element.type) {
      case DrawingElementType.text:
        if (element.points.isNotEmpty) {
          final textPosition = Offset(
            element.points[0].dx * size.width,
            element.points[0].dy * size.height,
          );
          return isPointInFinalEraserShape(
            textPosition,
            eraserRect,
            eraserCurvature,
            eraserTriangleCut,
          );
        }
        return false;

      case DrawingElementType.freeDrawing:
        for (final pointModel in element.points) {
          // 假设 element.points 是 Offset 列表
          final screenPoint = Offset(
            pointModel.dx * size.width,
            pointModel.dy * size.height,
          );
          if (isPointInFinalEraserShape(
            screenPoint,
            eraserRect,
            eraserCurvature,
            eraserTriangleCut,
          )) {
            return true;
          }
        }
        return false;

      default: // 其他被视为矩形的元素类型
        if (element.points.length < 2) return false;

        final elementStart = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );
        final elementEnd = Offset(
          element.points[1].dx * size.width,
          element.points[1].dy * size.height,
        );
        final Rect elementRect = Rect.fromPoints(elementStart, elementEnd);

        // 检查两个矩形区域是否重叠
        if (!eraserRect.overlaps(elementRect)) {
          return false;
        }

        // 如果有三角形切割或曲率，需要更精确的检测
        if (eraserCurvature > 0.0 || eraserTriangleCut != TriangleCutType.none) {
          // 检查元素矩形的四个角点是否有任何一个在橡皮擦的最终形状内
          final corners = [
            elementRect.topLeft,
            elementRect.topRight,
            elementRect.bottomLeft,
            elementRect.bottomRight,
          ];

          for (final corner in corners) {
            if (isPointInFinalEraserShape(
              corner,
              eraserRect,
              eraserCurvature,
              eraserTriangleCut,
            )) {
              return true;
            }
          }

          // 如果角点都不在内部，还需要检查是否橡皮擦完全包含在元素内部
          // 这里可以进一步优化...
          return false;
        }

        // 普通矩形橡皮擦，直接使用矩形重叠检测
        return true;
    }
  }
}
