import 'dart:typed_data';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'map_item_summary.g.dart';

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

/// 地图项摘要数据模型（用于地图册页面的轻量级加载）
/// 只包含基本显示信息，不包含图层和图例组等重量级数据
@JsonSerializable()
class MapItemSummary {
  final int id;
  final String title;
  @Uint8ListConverter()
  final Uint8List? imageData; // 封面图片
  final int version; // 地图版本
  final DateTime createdAt;
  final DateTime updatedAt;

  const MapItemSummary({
    required this.id,
    required this.title,
    this.imageData,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 检查是否有图像数据
  bool get hasImageData => imageData != null && imageData!.isNotEmpty;

  /// 从 JSON 创建实例
  factory MapItemSummary.fromJson(Map<String, dynamic> json) => _$MapItemSummaryFromJson(json);
  
  /// 转换为 JSON
  Map<String, dynamic> toJson() => _$MapItemSummaryToJson(this);

  /// 从数据库记录创建 MapItemSummary（只读取基本字段）
  factory MapItemSummary.fromDatabase(Map<String, dynamic> map) {
    return MapItemSummary(
      id: map['id'] as int,
      title: map['title'] as String,
      imageData: map['image_data'] as Uint8List?,
      version: map['version'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// 创建副本
  MapItemSummary copyWith({
    int? id,
    String? title,
    Uint8List? imageData,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MapItemSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      imageData: imageData ?? this.imageData,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
