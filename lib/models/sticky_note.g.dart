// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticky_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StickyNote _$StickyNoteFromJson(Map<String, dynamic> json) => StickyNote(
  id: json['id'] as String,
  title: json['title'] as String,
  content: json['content'] as String? ?? '',
  position: const OffsetConverter().fromJson(
    json['position'] as Map<String, dynamic>,
  ),
  size:
      json['size'] == null
          ? const Size(0.2, 0.15)
          : const SizeConverter().fromJson(
            json['size'] as Map<String, dynamic>,
          ),
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
  isVisible: json['isVisible'] as bool? ?? true,
  isCollapsed: json['isCollapsed'] as bool? ?? false,
  isSelected: json['isSelected'] as bool? ?? false,
  zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
  backgroundColor:
      json['backgroundColor'] == null
          ? const Color(0xFFFFF9C4)
          : const ColorConverter().fromJson(
            (json['backgroundColor'] as num).toInt(),
          ),
  titleBarColor:
      json['titleBarColor'] == null
          ? const Color(0xFFF9A825)
          : const ColorConverter().fromJson(
            (json['titleBarColor'] as num).toInt(),
          ),
  textColor:
      json['textColor'] == null
          ? const Color(0xFF424242)
          : const ColorConverter().fromJson((json['textColor'] as num).toInt()),
  backgroundImageData: const Uint8ListConverter().fromJson(
    json['backgroundImageData'] as String?,
  ),
  backgroundImageHash: json['backgroundImageHash'] as String?,
  backgroundImageFit:
      $enumDecodeNullable(_$BoxFitEnumMap, json['backgroundImageFit']) ??
      BoxFit.cover,
  backgroundImageOpacity:
      (json['backgroundImageOpacity'] as num?)?.toDouble() ?? 0.3,
  elements:
      (json['elements'] as List<dynamic>?)
          ?.map((e) => MapDrawingElement.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$StickyNoteToJson(
  StickyNote instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'position': const OffsetConverter().toJson(instance.position),
  'size': const SizeConverter().toJson(instance.size),
  'opacity': instance.opacity,
  'isVisible': instance.isVisible,
  'isCollapsed': instance.isCollapsed,
  'isSelected': instance.isSelected,
  'zIndex': instance.zIndex,
  'backgroundColor': const ColorConverter().toJson(instance.backgroundColor),
  'titleBarColor': const ColorConverter().toJson(instance.titleBarColor),
  'textColor': const ColorConverter().toJson(instance.textColor),
  'backgroundImageData': const Uint8ListConverter().toJson(
    instance.backgroundImageData,
  ),
  'backgroundImageHash': instance.backgroundImageHash,
  'backgroundImageFit': _$BoxFitEnumMap[instance.backgroundImageFit]!,
  'backgroundImageOpacity': instance.backgroundImageOpacity,
  'elements': instance.elements,
  'tags': instance.tags,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$BoxFitEnumMap = {
  BoxFit.fill: 'fill',
  BoxFit.contain: 'contain',
  BoxFit.cover: 'cover',
  BoxFit.fitWidth: 'fitWidth',
  BoxFit.fitHeight: 'fitHeight',
  BoxFit.none: 'none',
  BoxFit.scaleDown: 'scaleDown',
};
