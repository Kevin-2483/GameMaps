import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';

part 'map_layer.g.dart';

/// 地图图层数据模型
@JsonSerializable()
class MapLayer {
  final String id;
  final String name;
  final int order; // 图层顺序，数字越大越在上层
  final bool isVisible;
  final double opacity; // 透明度 0.0-1.0
  final List<MapDrawingElement> elements; // 绘制元素
  final List<String> legendGroupIds; // 关联的图例组ID列表
  final DateTime createdAt;
  final DateTime updatedAt;

  const MapLayer({
    required this.id,
    required this.name,
    required this.order,
    this.isVisible = true,
    this.opacity = 1.0,
    this.elements = const [],
    this.legendGroupIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory MapLayer.fromJson(Map<String, dynamic> json) => _$MapLayerFromJson(json);
  Map<String, dynamic> toJson() => _$MapLayerToJson(this);

  MapLayer copyWith({
    String? id,
    String? name,
    int? order,
    bool? isVisible,
    double? opacity,
    List<MapDrawingElement>? elements,
    List<String>? legendGroupIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MapLayer(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
      opacity: opacity ?? this.opacity,
      elements: elements ?? this.elements,
      legendGroupIds: legendGroupIds ?? this.legendGroupIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 绘制元素类型
enum DrawingElementType {
  line,        // 实线
  dashedLine,  // 虚线
  arrow,       // 箭头
  rectangle,   // 实心矩形
  hollowRectangle, // 空心矩形
  diagonalLines,   // 单斜线区域
  crossLines,      // 交叉线区域
  dotGrid,         // 十字点阵区域
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
  final double rotation; // 旋转角度
  final DateTime createdAt;

  const MapDrawingElement({
    required this.id,
    required this.type,
    required this.points,
    this.color = const Color(0xFF000000),
    this.strokeWidth = 2.0,
    this.rotation = 0.0,
    required this.createdAt,
  });

  factory MapDrawingElement.fromJson(Map<String, dynamic> json) => _$MapDrawingElementFromJson(json);
  Map<String, dynamic> toJson() => _$MapDrawingElementToJson(this);

  MapDrawingElement copyWith({
    String? id,
    DrawingElementType? type,
    List<Offset>? points,
    Color? color,
    double? strokeWidth,
    double? rotation,
    DateTime? createdAt,
  }) {
    return MapDrawingElement(
      id: id ?? this.id,
      type: type ?? this.type,
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      rotation: rotation ?? this.rotation,
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

  factory LegendGroup.fromJson(Map<String, dynamic> json) => _$LegendGroupFromJson(json);
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
  final bool isVisible;
  final DateTime createdAt;

  const LegendItem({
    required this.id,
    required this.legendId,
    required this.position,
    this.size = 1.0,
    this.rotation = 0.0,
    this.isVisible = true,
    required this.createdAt,
  });

  factory LegendItem.fromJson(Map<String, dynamic> json) => _$LegendItemFromJson(json);
  Map<String, dynamic> toJson() => _$LegendItemToJson(this);

  LegendItem copyWith({
    String? id,
    String? legendId,
    Offset? position,
    double? size,
    double? rotation,
    bool? isVisible,
    DateTime? createdAt,
  }) {
    return LegendItem(
      id: id ?? this.id,
      legendId: legendId ?? this.legendId,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
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
    return {
      'dx': object.dx,
      'dy': object.dy,
    };
  }
}

/// JSON转换器用于处理 Offset 列表
class OffsetListConverter implements JsonConverter<List<Offset>, List<Map<String, dynamic>>> {
  const OffsetListConverter();

  @override
  List<Offset> fromJson(List<Map<String, dynamic>> json) {
    return json.map((item) => const OffsetConverter().fromJson(item)).toList();
  }

  @override
  List<Map<String, dynamic>> toJson(List<Offset> object) {
    return object.map((offset) => const OffsetConverter().toJson(offset)).toList();
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
    return object.value;
  }
}
