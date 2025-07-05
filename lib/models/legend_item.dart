import 'dart:typed_data';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'legend_item.g.dart';

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

/// 图例文件类型枚举
enum LegendFileType {
  png,
  jpg,
  jpeg,
  svg,
}

/// 图例项数据模型
@JsonSerializable()
class LegendItem {
  final int? id;
  final String title;
  @Uint8ListConverter()
  final Uint8List? imageData; // 图片二进制数据
  final LegendFileType fileType; // 文件类型
  final double centerX; // 中心点X坐标 (0.0-1.0)
  final double centerY; // 中心点Y坐标 (0.0-1.0)
  final int version; // 图例版本
  final List<String>? tags; // 标签列表，用于分类和筛选
  final DateTime createdAt;
  final DateTime updatedAt;
  const LegendItem({
    this.id,
    required this.title,
    this.imageData,
    this.fileType = LegendFileType.png, // 默认为PNG
    required this.centerX,
    required this.centerY,
    required this.version,
    this.tags, // 标签列表，默认为null
    required this.createdAt,
    required this.updatedAt,
  });

  /// 检查是否有图像数据
  bool get hasImageData => imageData != null && imageData!.isNotEmpty;

  factory LegendItem.fromJson(Map<String, dynamic> json) =>
      _$LegendItemFromJson(json);
  Map<String, dynamic> toJson() => _$LegendItemToJson(this);

  /// 从数据库记录创建 LegendItem
  factory LegendItem.fromDatabase(Map<String, dynamic> map) {
    return LegendItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      imageData: map['image_data'] as Uint8List?,
      fileType: LegendFileType.values.firstWhere(
        (type) => type.name == (map['file_type'] as String? ?? 'png'),
        orElse: () => LegendFileType.png,
      ),
      centerX: map['center_x'] as double,
      centerY: map['center_y'] as double,
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
      'image_data': imageData,
      'file_type': fileType.name,
      'center_x': centerX,
      'center_y': centerY,
      'version': version,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// 创建副本
  LegendItem copyWith({
    int? id,
    String? title,
    Uint8List? imageData,
    LegendFileType? fileType,
    double? centerX,
    double? centerY,
    int? version,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LegendItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageData: imageData ?? this.imageData,
      fileType: fileType ?? this.fileType,
      centerX: centerX ?? this.centerX,
      centerY: centerY ?? this.centerY,
      version: version ?? this.version,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 图例数据库版本信息
@JsonSerializable()
class LegendDatabase {
  final int version; // 整个数据库版本
  final List<LegendItem> legends;
  final DateTime exportedAt;

  const LegendDatabase({
    required this.version,
    required this.legends,
    required this.exportedAt,
  });

  factory LegendDatabase.fromJson(Map<String, dynamic> json) =>
      _$LegendDatabaseFromJson(json);
  Map<String, dynamic> toJson() => _$LegendDatabaseToJson(this);
}
