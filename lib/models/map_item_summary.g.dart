// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_item_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapItemSummary _$MapItemSummaryFromJson(Map<String, dynamic> json) =>
    MapItemSummary(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      imageData: const Uint8ListConverter().fromJson(
        json['imageData'] as String?,
      ),
      version: (json['version'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MapItemSummaryToJson(MapItemSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'imageData': const Uint8ListConverter().toJson(instance.imageData),
      'version': instance.version,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
