// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScriptData _$ScriptDataFromJson(Map<String, dynamic> json) => ScriptData(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  type: $enumDecode(_$ScriptTypeEnumMap, json['type']),
  content: json['content'] as String,
  parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
  isEnabled: json['isEnabled'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  lastError: json['lastError'] as String?,
  lastRunAt: json['lastRunAt'] == null
      ? null
      : DateTime.parse(json['lastRunAt'] as String),
);

Map<String, dynamic> _$ScriptDataToJson(ScriptData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$ScriptTypeEnumMap[instance.type]!,
      'content': instance.content,
      'parameters': instance.parameters,
      'isEnabled': instance.isEnabled,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastError': instance.lastError,
      'lastRunAt': instance.lastRunAt?.toIso8601String(),
    };

const _$ScriptTypeEnumMap = {
  ScriptType.automation: 'automation',
  ScriptType.animation: 'animation',
  ScriptType.filter: 'filter',
  ScriptType.statistics: 'statistics',
};
