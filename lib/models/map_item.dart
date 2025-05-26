import 'dart:typed_data';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

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
  final String imagePath; // 数据库中存储的图片路径
  @Uint8ListConverter()
  final Uint8List? imageData; // 图片二进制数据，可以为空
  final int version; // 地图版本
  final DateTime createdAt;
  final DateTime updatedAt;

  const MapItem({
    this.id,
    required this.title,
    required this.imagePath,
    this.imageData,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 检查是否有图像数据
  bool get hasImageData => imageData != null && imageData!.isNotEmpty;

  factory MapItem.fromJson(Map<String, dynamic> json) => _$MapItemFromJson(json);
  Map<String, dynamic> toJson() => _$MapItemToJson(this);

  /// 从数据库记录创建 MapItem
  factory MapItem.fromDatabase(Map<String, dynamic> map) {
    return MapItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      imagePath: map['image_path'] as String,
      imageData: map['image_data'] as Uint8List?,
      version: map['version'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// 转换为数据库记录
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'image_path': imagePath,
      'image_data': imageData,
      'version': version,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// 创建副本
  MapItem copyWith({
    int? id,
    String? title,
    String? imagePath,
    Uint8List? imageData,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MapItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      imageData: imageData ?? this.imageData,
      version: version ?? this.version,
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

  factory MapDatabase.fromJson(Map<String, dynamic> json) => _$MapDatabaseFromJson(json);
  Map<String, dynamic> toJson() => _$MapDatabaseToJson(this);
}
