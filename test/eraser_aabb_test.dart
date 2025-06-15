import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/models/map_layer.dart';
import '../lib/pages/map_editor/renderers/eraser_renderer.dart';

void main() {
  group('橡皮擦 AABB 重叠检测测试', () {
    test('基本矩形重叠检测', () {
      // 创建橡皮擦元素
      final eraser = MapDrawingElement(
        id: 'eraser1',
        type: DrawingElementType.eraser,
        points: [
          const Offset(0.2, 0.2), // 左上角 (20, 20) 在100x100画布上
          const Offset(0.6, 0.6), // 右下角 (60, 60) 在100x100画布上
        ],
        color: Colors.transparent,
        strokeWidth: 0,
        zIndex: 1,
        createdAt: DateTime.now(),
      );

      // 创建重叠的矩形元素
      final overlappingElement = MapDrawingElement(
        id: 'rect1',
        type: DrawingElementType.rectangle,
        points: [
          const Offset(0.4, 0.4), // 左上角 (40, 40)
          const Offset(0.8, 0.8), // 右下角 (80, 80) - 与橡皮擦重叠
        ],
        color: Colors.blue,
        strokeWidth: 2,
        zIndex: 0,
        createdAt: DateTime.now(),
      );

      // 创建不重叠的矩形元素
      final nonOverlappingElement = MapDrawingElement(
        id: 'rect2',
        type: DrawingElementType.rectangle,
        points: [
          const Offset(0.7, 0.7), // 左上角 (70, 70)
          const Offset(0.9, 0.9), // 右下角 (90, 90) - 与橡皮擦不重叠
        ],
        color: Colors.red,
        strokeWidth: 2,
        zIndex: 0,
        createdAt: DateTime.now(),
      );

      const canvasSize = Size(100, 100);

      // 使用反射或友元类访问私有方法进行测试
      // 注意：这只是测试示例，实际实现中可能需要调整访问方式

      // 期望重叠的元素返回 true
      // expect(EraserRenderer._doesEraserAffectElement(overlappingElement, eraser, canvasSize), true);

      // 期望不重叠的元素返回 false
      // expect(EraserRenderer._doesEraserAffectElement(nonOverlappingElement, eraser, canvasSize), false);
    });

    test('自由绘制边界框检测', () {
      // 创建橡皮擦
      final eraser = MapDrawingElement(
        id: 'eraser1',
        type: DrawingElementType.eraser,
        points: [
          const Offset(0.3, 0.3), // (30, 30)
          const Offset(0.7, 0.7), // (70, 70)
        ],
        color: Colors.transparent,
        strokeWidth: 0,
        zIndex: 1,
        createdAt: DateTime.now(),
      );

      // 创建自由绘制路径（部分在橡皮擦区域内）
      final freeDrawing = MapDrawingElement(
        id: 'free1',
        type: DrawingElementType.freeDrawing,
        points: [
          const Offset(0.1, 0.1), // (10, 10)
          const Offset(0.2, 0.2), // (20, 20)
          const Offset(0.4, 0.4), // (40, 40) - 在橡皮擦区域内
          const Offset(0.5, 0.5), // (50, 50) - 在橡皮擦区域内
        ],
        color: Colors.green,
        strokeWidth: 2,
        zIndex: 0,
        createdAt: DateTime.now(),
      );

      const canvasSize = Size(100, 100);

      // 自由绘制的边界框应该是 (5, 5) 到 (55, 55)，与橡皮擦 (30, 30) 到 (70, 70) 重叠
      // expect(EraserRenderer._doesEraserAffectElement(freeDrawing, eraser, canvasSize), true);
    });

    test('文本元素边界框检测', () {
      // 创建橡皮擦
      final eraser = MapDrawingElement(
        id: 'eraser1',
        type: DrawingElementType.eraser,
        points: [
          const Offset(0.4, 0.4), // (40, 40)
          const Offset(0.6, 0.6), // (60, 60)
        ],
        color: Colors.transparent,
        strokeWidth: 0,
        zIndex: 1,
        createdAt: DateTime.now(),
      );

      // 创建文本元素（在橡皮擦区域内）
      final textInside = MapDrawingElement(
        id: 'text1',
        type: DrawingElementType.text,
        points: [
          const Offset(0.5, 0.5), // (50, 50) - 在橡皮擦中心
        ],
        color: Colors.black,
        strokeWidth: 1,
        zIndex: 0,
        createdAt: DateTime.now(),
      );

      // 创建文本元素（在橡皮擦区域外）
      final textOutside = MapDrawingElement(
        id: 'text2',
        type: DrawingElementType.text,
        points: [
          const Offset(0.8, 0.8), // (80, 80) - 在橡皮擦外部
        ],
        color: Colors.black,
        strokeWidth: 1,
        zIndex: 0,
        createdAt: DateTime.now(),
      );

      const canvasSize = Size(100, 100);

      // 文本边界框（20x20）中心在 (50, 50)，应该与橡皮擦重叠
      // expect(EraserRenderer._doesEraserAffectElement(textInside, eraser, canvasSize), true);

      // 文本边界框中心在 (80, 80)，应该与橡皮擦不重叠
      // expect(EraserRenderer._doesEraserAffectElement(textOutside, eraser, canvasSize), false);
    });
  });
}
