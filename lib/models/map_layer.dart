import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/painting.dart';
import 'package:json_annotation/json_annotation.dart';
import 'map_item.dart'; // 导入Uint8ListConverter

part 'map_layer.g.dart';

/// 地图图层数据模型
@JsonSerializable()
class MapLayer {
  final String id;
  final String name;
  final int order; // 图层顺序，数字越大越在上层
  final bool isVisible;
  final double opacity; // 透明度 0.0-1.0
  @Uint8ListConverter()
  final Uint8List? imageData; // 图片二进制数据，null表示透明图层
  final List<MapDrawingElement> elements; // 绘制元素
  final List<String> legendGroupIds; // 关联的图例组ID列表
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLinkedToNext; //是否链接到下一个图层
  const MapLayer({
    required this.id,
    required this.name,
    required this.order,
    this.isVisible = true,
    this.opacity = 1.0,
    this.imageData,
    this.elements = const [],
    this.legendGroupIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isLinkedToNext = false, // 默认不链接
  });

  factory MapLayer.fromJson(Map<String, dynamic> json) =>
      _$MapLayerFromJson(json);
  Map<String, dynamic> toJson() => _$MapLayerToJson(this);
  MapLayer copyWith({
    String? id,
    String? name,
    int? order,
    bool? isVisible,
    double? opacity,
    Uint8List? imageData,
    List<MapDrawingElement>? elements,
    List<String>? legendGroupIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearImageData = false, //参数用于明确清除图片数据
    bool? isLinkedToNext, //参数用于链接到下一个图层
  }) {
    return MapLayer(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
      opacity: opacity ?? this.opacity,
      imageData: clearImageData ? null : (imageData ?? this.imageData),
      elements: elements ?? this.elements,
      legendGroupIds: legendGroupIds ?? this.legendGroupIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLinkedToNext: isLinkedToNext ?? this.isLinkedToNext,
    );
  }
}

/// 绘制元素类型
enum DrawingElementType {
  line, // 实线
  dashedLine, // 虚线
  arrow, // 箭头
  rectangle, // 实心矩形
  hollowRectangle, // 空心矩形
  diagonalLines, // 单斜线区域
  crossLines, // 交叉线区域
  dotGrid, // 十字点阵区域
  eraser, // 橡皮擦
  freeDrawing, // 像素笔（自由绘制）
  text, // 文本框
  imageArea, // 图片选区
}

/// 三角形切割类型
enum TriangleCutType {
  none, // 无切割（完整矩形）
  topLeft, // 左上三角
  topRight, // 右上三角
  bottomRight, // 右下三角
  bottomLeft, // 左下三角
}

/// 地图绘制元素
@JsonSerializable()
class MapDrawingElement {
  final String id;
  final DrawingElementType type;
  @OffsetListConverter()
  final List<Offset> points; // 坐标点列表 (相对坐标 0.0-1.0)
  @ColorConverter()
  final Color color;
  final double strokeWidth;
  final double density; // 图案密度系数，用于计算图案间距 (strokeWidth * density)
  final double rotation; // 旋转角度
  final double curvature; // 弧度值，0.0=矩形，~0.5=椭圆，~1.0=凹角形状
  final TriangleCutType triangleCut; // 三角形切割类型
  final int zIndex; // 绘制顺序，数值越大越在上层
  final String? text; // 文本内容（用于文本框）
  final double? fontSize; // 字体大小（用于文本框）
  @Uint8ListConverter()
  final Uint8List? imageData; // 图片二进制数据（用于图片选区）
  @BoxFitConverter()
  final BoxFit? imageFit; // 图片适应方式（用于图片选区）
  final DateTime createdAt;
  const MapDrawingElement({
    required this.id,
    required this.type,
    required this.points,
    this.color = const Color(0xFF000000),
    this.strokeWidth = 2.0,
    this.density = 3.0, // 默认密度系数
    this.rotation = 0.0,
    this.curvature = 0.0, // 默认无弧度
    this.triangleCut = TriangleCutType.none, // 默认无三角形切割
    this.zIndex = 0,
    this.text,
    this.fontSize,
    this.imageData, // 图片二进制数据
    this.imageFit = BoxFit.contain, // 默认图片适应方式
    required this.createdAt,
  });
  factory MapDrawingElement.fromJson(Map<String, dynamic> json) =>
      _$MapDrawingElementFromJson(json);
  Map<String, dynamic> toJson() => _$MapDrawingElementToJson(this);

  MapDrawingElement copyWith({
    String? id,
    DrawingElementType? type,
    List<Offset>? points,
    Color? color,
    double? strokeWidth,
    double? density,
    double? rotation,
    double? curvature,
    TriangleCutType? triangleCut,
    int? zIndex,
    String? text,
    double? fontSize,
    Uint8List? imageData,
    BoxFit? imageFit,
    DateTime? createdAt,
    bool clearImageData = false, // 用于明确清除图片数据
  }) {
    return MapDrawingElement(
      id: id ?? this.id,
      type: type ?? this.type,
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      density: density ?? this.density,
      rotation: rotation ?? this.rotation,
      curvature: curvature ?? this.curvature,
      triangleCut: triangleCut ?? this.triangleCut,
      zIndex: zIndex ?? this.zIndex,
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      imageData: clearImageData ? null : (imageData ?? this.imageData),
      imageFit: imageFit ?? this.imageFit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 图例组
@JsonSerializable()
class LegendGroup {
  final String id;
  final String name;
  final bool isVisible;
  final double opacity; // 透明度 0.0-1.0
  final List<LegendItem> legendItems; // 图例项列表
  final DateTime createdAt;
  final DateTime updatedAt;

  const LegendGroup({
    required this.id,
    required this.name,
    this.isVisible = true,
    this.opacity = 1.0,
    this.legendItems = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory LegendGroup.fromJson(Map<String, dynamic> json) =>
      _$LegendGroupFromJson(json);
  Map<String, dynamic> toJson() => _$LegendGroupToJson(this);

  LegendGroup copyWith({
    String? id,
    String? name,
    bool? isVisible,
    double? opacity,
    List<LegendItem>? legendItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LegendGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      isVisible: isVisible ?? this.isVisible,
      opacity: opacity ?? this.opacity,
      legendItems: legendItems ?? this.legendItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 图例项（地图上的标记）
@JsonSerializable()
class LegendItem {
  final String id;
  final String legendId; // 关联的图例数据库中的图例ID
  @OffsetConverter()
  final Offset position; // 在地图上的位置 (相对坐标 0.0-1.0)
  final double size; // 大小缩放比例
  final double rotation; // 旋转角度
  final double opacity; // 透明度 0.0-1.0
  final bool isVisible;
  final DateTime createdAt;
  const LegendItem({
    required this.id,
    required this.legendId,
    required this.position,
    this.size = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.isVisible = true,
    required this.createdAt,
  });

  factory LegendItem.fromJson(Map<String, dynamic> json) =>
      _$LegendItemFromJson(json);
  Map<String, dynamic> toJson() => _$LegendItemToJson(this);
  LegendItem copyWith({
    String? id,
    String? legendId,
    Offset? position,
    double? size,
    double? rotation,
    double? opacity,
    bool? isVisible,
    DateTime? createdAt,
  }) {
    return LegendItem(
      id: id ?? this.id,
      legendId: legendId ?? this.legendId,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// JSON转换器用于处理 Offset 类型
class OffsetConverter implements JsonConverter<Offset, Map<String, dynamic>> {
  const OffsetConverter();

  @override
  Offset fromJson(Map<String, dynamic> json) {
    return Offset(
      (json['dx'] as num).toDouble(),
      (json['dy'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(Offset object) {
    return {'dx': object.dx, 'dy': object.dy};
  }
}

/// JSON转换器用于处理 Offset 列表
class OffsetListConverter
    implements JsonConverter<List<Offset>, List<dynamic>> {
  const OffsetListConverter();

  @override
  List<Offset> fromJson(List<dynamic> json) {
    return json.map((item) {
      if (item is Map<String, dynamic>) {
        return const OffsetConverter().fromJson(item);
      } else if (item is Map) {
        // 处理 Map<dynamic, dynamic> 的情况
        return const OffsetConverter().fromJson(
          Map<String, dynamic>.from(item),
        );
      } else {
        throw FormatException('Invalid offset data: $item');
      }
    }).toList();
  }

  @override
  List<Map<String, dynamic>> toJson(List<Offset> object) {
    return object
        .map((offset) => const OffsetConverter().toJson(offset))
        .toList();
  }
}

/// JSON转换器用于处理 Color 类型
class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) {
    return Color(json);
  }

  @override
  int toJson(Color object) {
    return object.toARGB32();
  }
}

/// JSON转换器用于处理 BoxFit 类型
class BoxFitConverter implements JsonConverter<BoxFit?, String?> {
  const BoxFitConverter();

  @override
  BoxFit? fromJson(String? json) {
    if (json == null) return null;
    switch (json) {
      case 'fill':
        return BoxFit.fill;
      case 'contain':
        return BoxFit.contain;
      case 'cover':
        return BoxFit.cover;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'fitHeight':
        return BoxFit.fitHeight;
      case 'none':
        return BoxFit.none;
      case 'scaleDown':
        return BoxFit.scaleDown;
      default:
        return BoxFit.contain;
    }
  }

  @override
  String? toJson(BoxFit? object) {
    if (object == null) return null;
    switch (object) {
      case BoxFit.fill:
        return 'fill';
      case BoxFit.contain:
        return 'contain';
      case BoxFit.cover:
        return 'cover';
      case BoxFit.fitWidth:
        return 'fitWidth';
      case BoxFit.fitHeight:
        return 'fitHeight';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scaleDown';
    }
  }
}
