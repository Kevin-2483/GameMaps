// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_layer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapLayer _$MapLayerFromJson(Map<String, dynamic> json) => MapLayer(
  id: json['id'] as String,
  name: json['name'] as String,
  order: (json['order'] as num).toInt(),
  isVisible: json['isVisible'] as bool? ?? true,
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
  imageData: const Uint8ListConverter().fromJson(json['imageData'] as String?),
  elements:
      (json['elements'] as List<dynamic>?)
          ?.map((e) => MapDrawingElement.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  legendGroupIds:
      (json['legendGroupIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isLinkedToNext: json['isLinkedToNext'] as bool? ?? false,
);

Map<String, dynamic> _$MapLayerToJson(MapLayer instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'order': instance.order,
  'isVisible': instance.isVisible,
  'opacity': instance.opacity,
  'imageData': const Uint8ListConverter().toJson(instance.imageData),
  'elements': instance.elements,
  'legendGroupIds': instance.legendGroupIds,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isLinkedToNext': instance.isLinkedToNext,
};

MapDrawingElement _$MapDrawingElementFromJson(Map<String, dynamic> json) =>
    MapDrawingElement(
      id: json['id'] as String,
      type: $enumDecode(_$DrawingElementTypeEnumMap, json['type']),
      points: const OffsetListConverter().fromJson(json['points'] as List),
      color: json['color'] == null
          ? const Color(0xFF000000)
          : const ColorConverter().fromJson((json['color'] as num).toInt()),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 2.0,
      density: (json['density'] as num?)?.toDouble() ?? 3.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      curvature: (json['curvature'] as num?)?.toDouble() ?? 0.0,
      triangleCut:
          $enumDecodeNullable(_$TriangleCutTypeEnumMap, json['triangleCut']) ??
          TriangleCutType.none,
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
      text: json['text'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MapDrawingElementToJson(MapDrawingElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$DrawingElementTypeEnumMap[instance.type]!,
      'points': const OffsetListConverter().toJson(instance.points),
      'color': const ColorConverter().toJson(instance.color),
      'strokeWidth': instance.strokeWidth,
      'density': instance.density,
      'rotation': instance.rotation,
      'curvature': instance.curvature,
      'triangleCut': _$TriangleCutTypeEnumMap[instance.triangleCut]!,
      'zIndex': instance.zIndex,
      'text': instance.text,
      'fontSize': instance.fontSize,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$DrawingElementTypeEnumMap = {
  DrawingElementType.line: 'line',
  DrawingElementType.dashedLine: 'dashedLine',
  DrawingElementType.arrow: 'arrow',
  DrawingElementType.rectangle: 'rectangle',
  DrawingElementType.hollowRectangle: 'hollowRectangle',
  DrawingElementType.diagonalLines: 'diagonalLines',
  DrawingElementType.crossLines: 'crossLines',
  DrawingElementType.dotGrid: 'dotGrid',
  DrawingElementType.eraser: 'eraser',
  DrawingElementType.freeDrawing: 'freeDrawing',
  DrawingElementType.text: 'text',
};

const _$TriangleCutTypeEnumMap = {
  TriangleCutType.none: 'none',
  TriangleCutType.topLeft: 'topLeft',
  TriangleCutType.topRight: 'topRight',
  TriangleCutType.bottomRight: 'bottomRight',
  TriangleCutType.bottomLeft: 'bottomLeft',
};

LegendGroup _$LegendGroupFromJson(Map<String, dynamic> json) => LegendGroup(
  id: json['id'] as String,
  name: json['name'] as String,
  isVisible: json['isVisible'] as bool? ?? true,
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
  legendItems:
      (json['legendItems'] as List<dynamic>?)
          ?.map((e) => LegendItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$LegendGroupToJson(LegendGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isVisible': instance.isVisible,
      'opacity': instance.opacity,
      'legendItems': instance.legendItems,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

LegendItem _$LegendItemFromJson(Map<String, dynamic> json) => LegendItem(
  id: json['id'] as String,
  legendId: json['legendId'] as String,
  position: const OffsetConverter().fromJson(
    json['position'] as Map<String, dynamic>,
  ),
  size: (json['size'] as num?)?.toDouble() ?? 1.0,
  rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
  isVisible: json['isVisible'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$LegendItemToJson(LegendItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'legendId': instance.legendId,
      'position': const OffsetConverter().toJson(instance.position),
      'size': instance.size,
      'rotation': instance.rotation,
      'opacity': instance.opacity,
      'isVisible': instance.isVisible,
      'createdAt': instance.createdAt.toIso8601String(),
    };
