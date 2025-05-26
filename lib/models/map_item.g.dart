// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapItem _$MapItemFromJson(Map<String, dynamic> json) => MapItem(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String,
  imageData: const Uint8ListConverter().fromJson(json['imageData'] as String?),
  version: (json['version'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MapItemToJson(MapItem instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'imageData': const Uint8ListConverter().toJson(instance.imageData),
  'version': instance.version,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

MapDatabase _$MapDatabaseFromJson(Map<String, dynamic> json) => MapDatabase(
  version: (json['version'] as num).toInt(),
  maps: (json['maps'] as List<dynamic>)
      .map((e) => MapItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  exportedAt: DateTime.parse(json['exportedAt'] as String),
);

Map<String, dynamic> _$MapDatabaseToJson(MapDatabase instance) =>
    <String, dynamic>{
      'version': instance.version,
      'maps': instance.maps,
      'exportedAt': instance.exportedAt.toIso8601String(),
    };
