import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/painting.dart';
import 'map_layer.dart';

/// 图片选区绘制元素的使用示例
class MapDrawingElementExample {
  /// 创建一个图片选区绘制元素
  static MapDrawingElement createImageArea({
    required String id,
    required List<Offset> points, // 选区的四个角点 (相对坐标 0.0-1.0)
    required Uint8List imageData, // 图片的二进制数据
    BoxFit imageFit = BoxFit.contain, // 图片适应方式
    double rotation = 0.0, // 旋转角度
    int zIndex = 0, // 绘制层级
  }) {
    return MapDrawingElement(
      id: id,
      type: DrawingElementType.imageArea, // 使用新的图片选区类型
      points: points, // 选区的边界点
      imageData: imageData, // 图片数据
      imageFit: imageFit, // 图片适应方式
      rotation: rotation, // 旋转角度
      zIndex: zIndex, // 绘制层级
      createdAt: DateTime.now(),
    );
  }

  /// 创建一个矩形选区的图片绘制元素
  static MapDrawingElement createRectangleImageArea({
    required String id,
    required Offset topLeft, // 左上角 (相对坐标 0.0-1.0)
    required Offset bottomRight, // 右下角 (相对坐标 0.0-1.0)
    required Uint8List imageData, // 图片的二进制数据
    BoxFit imageFit = BoxFit.contain, // 图片适应方式
    double rotation = 0.0, // 旋转角度
    int zIndex = 0, // 绘制层级
  }) {
    // 创建矩形的四个顶点
    final points = [
      topLeft, // 左上
      Offset(bottomRight.dx, topLeft.dy), // 右上
      bottomRight, // 右下
      Offset(topLeft.dx, bottomRight.dy), // 左下
    ];

    return createImageArea(
      id: id,
      points: points,
      imageData: imageData,
      imageFit: imageFit,
      rotation: rotation,
      zIndex: zIndex,
    );
  }

  /// 更新图片选区的图片数据
  static MapDrawingElement updateImageData(
    MapDrawingElement element,
    Uint8List newImageData, {
    BoxFit? newImageFit,
  }) {
    if (element.type != DrawingElementType.imageArea) {
      throw ArgumentError('元素类型必须是 imageArea');
    }

    return element.copyWith(imageData: newImageData, imageFit: newImageFit);
  }

  /// 清除图片选区的图片数据
  static MapDrawingElement clearImageData(MapDrawingElement element) {
    if (element.type != DrawingElementType.imageArea) {
      throw ArgumentError('元素类型必须是 imageArea');
    }

    return element.copyWith(clearImageData: true);
  }

  /// 检查元素是否为图片选区且有图片数据
  static bool hasImageData(MapDrawingElement element) {
    return element.type == DrawingElementType.imageArea &&
        element.imageData != null &&
        element.imageData!.isNotEmpty;
  }
}
