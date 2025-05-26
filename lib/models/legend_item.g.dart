// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legend_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LegendItem _$LegendItemFromJson(Map<String, dynamic> json) => LegendItem(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String,
  imageData: const Uint8ListConverter().fromJson(json['imageData'] as String?),
  centerX: (json['centerX'] as num).toDouble(),
  centerY: (json['centerY'] as num).toDouble(),
  version: (json['version'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$LegendItemToJson(LegendItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'imageData': const Uint8ListConverter().toJson(instance.imageData),
      'centerX': instance.centerX,
      'centerY': instance.centerY,
      'version': instance.version,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

LegendDatabase _$LegendDatabaseFromJson(Map<String, dynamic> json) =>
    LegendDatabase(
      version: (json['version'] as num).toInt(),
      legends: (json['legends'] as List<dynamic>)
          .map((e) => LegendItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      exportedAt: DateTime.parse(json['exportedAt'] as String),
    );

Map<String, dynamic> _$LegendDatabaseToJson(LegendDatabase instance) =>
    <String, dynamic>{
      'version': instance.version,
      'legends': instance.legends,
      'exportedAt': instance.exportedAt.toIso8601String(),
    };
