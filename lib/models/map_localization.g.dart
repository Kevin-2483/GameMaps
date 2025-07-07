// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_localization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapLocalization _$MapLocalizationFromJson(Map<String, dynamic> json) =>
    MapLocalization(
      mapKey: json['mapKey'] as String,
      translations: Map<String, String>.from(json['translations'] as Map),
    );

Map<String, dynamic> _$MapLocalizationToJson(MapLocalization instance) =>
    <String, dynamic>{
      'mapKey': instance.mapKey,
      'translations': instance.translations,
    };

MapLocalizationDatabase _$MapLocalizationDatabaseFromJson(
        Map<String, dynamic> json) =>
    MapLocalizationDatabase(
      version: (json['version'] as num).toInt(),
      maps: (json['maps'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, MapLocalization.fromJson(e as Map<String, dynamic>)),
      ),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MapLocalizationDatabaseToJson(
        MapLocalizationDatabase instance) =>
    <String, dynamic>{
      'version': instance.version,
      'maps': instance.maps,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
