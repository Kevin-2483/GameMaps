import 'dart:typed_data';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'map_layer.dart';

part 'map_item.g.dart';

/// Uint8List 转换器，用于 JSON 序列化
class Uint8ListConverter implements JsonConverter<Uint8List?, String?> {
  const Uint8ListConverter();

  @override
  Uint8List? fromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    return base64Decode(json);
  }

  @override
  String? toJson(Uint8List? object) {
    if (object == null || object.isEmpty) return null;
    return base64Encode(object);
  }
}

/// 地图项数据模型
@JsonSerializable()
class MapItem {
  final int? id;
  final String title;
  @Uint8ListConverter()
  final Uint8List? imageData; // 图片二进制数据
  final int version; // 地图版本
  final List<MapLayer> layers; // 图层列表
  final List<LegendGroup> legendGroups; // 图例组列表
  final DateTime createdAt;
  final DateTime updatedAt;

  const MapItem({
    this.id,
    required this.title,
    this.imageData,
    required this.version,
    this.layers = const [],
    this.legendGroups = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// 检查是否有图像数据
  bool get hasImageData => imageData != null && imageData!.isNotEmpty;

  factory MapItem.fromJson(Map<String, dynamic> json) =>
      _$MapItemFromJson(json);
  Map<String, dynamic> toJson() => _$MapItemToJson(this);

  /// 从数据库记录创建 MapItem
  factory MapItem.fromDatabase(Map<String, dynamic> map) {
    // 解析图层和图例组数据
    List<MapLayer> layers = [];
    List<LegendGroup> legendGroups = [];

    if (map['layers'] != null) {
      try {
        final layersJson = json.decode(map['layers'] as String);
        if (layersJson is List) {
          layers = layersJson
              .map((e) => MapLayer.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        print('解析图层数据失败: $e');
        // 如果解析失败，继续使用空列表
      }
    }

    if (map['legend_groups'] != null) {
      try {
        final legendGroupsJson = json.decode(map['legend_groups'] as String);
        if (legendGroupsJson is List) {
          legendGroups = legendGroupsJson
              .map((e) => LegendGroup.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        print('解析图例组数据失败: $e');
        // 如果解析失败，继续使用空列表
      }
    }

    return MapItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      imageData: map['image_data'] as Uint8List?,
      version: map['version'] as int,
      layers: layers,
      legendGroups: legendGroups,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// 转换为数据库记录
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'image_data': imageData,
      'version': version,
      'layers': json.encode(layers.map((e) => e.toJson()).toList()),
      'legend_groups': json.encode(
        legendGroups.map((e) => e.toJson()).toList(),
      ),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// 创建副本
  MapItem copyWith({
    int? id,
    String? title,
    Uint8List? imageData,
    int? version,
    List<MapLayer>? layers,
    List<LegendGroup>? legendGroups,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MapItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageData: imageData ?? this.imageData,
      version: version ?? this.version,
      layers: layers ?? this.layers,
      legendGroups: legendGroups ?? this.legendGroups,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 数据库版本信息
@JsonSerializable()
class MapDatabase {
  final int version; // 整个数据库版本
  final List<MapItem> maps;
  final DateTime exportedAt;

  const MapDatabase({
    required this.version,
    required this.maps,
    required this.exportedAt,
  });

  factory MapDatabase.fromJson(Map<String, dynamic> json) =>
      _$MapDatabaseFromJson(json);
  Map<String, dynamic> toJson() => _$MapDatabaseToJson(this);
}
