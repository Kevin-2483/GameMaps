import 'package:json_annotation/json_annotation.dart';

part 'map_localization.g.dart';

/// 地图本地化数据模型
@JsonSerializable()
class MapLocalization {
  final String mapKey; // 地图的唯一标识
  final Map<String, String> translations; // 语言代码 -> 翻译文本

  const MapLocalization({required this.mapKey, required this.translations});

  factory MapLocalization.fromJson(Map<String, dynamic> json) =>
      _$MapLocalizationFromJson(json);
  Map<String, dynamic> toJson() => _$MapLocalizationToJson(this);

  /// 获取指定语言的翻译，如果没有则返回null
  String? getTranslation(String languageCode) {
    return translations[languageCode];
  }

  /// 获取所有支持的语言代码
  List<String> get supportedLanguages => translations.keys.toList();
}

/// 地图本地化数据库
@JsonSerializable()
class MapLocalizationDatabase {
  final int version;
  final Map<String, MapLocalization> maps; // mapKey -> MapLocalization
  final DateTime updatedAt;

  const MapLocalizationDatabase({
    required this.version,
    required this.maps,
    required this.updatedAt,
  });

  factory MapLocalizationDatabase.fromJson(Map<String, dynamic> json) {
    // 处理特殊的JSON格式
    final mapsData = json['maps'] as Map<String, dynamic>;
    final Map<String, MapLocalization> parsedMaps = {};

    mapsData.forEach((mapKey, translations) {
      if (translations is List) {
        // 处理 [{"zh_cn": "地图A"}, {"en": "Map A"}] 格式
        final Map<String, String> translationMap = {};
        for (final item in translations) {
          if (item is Map<String, dynamic>) {
            item.forEach((lang, text) {
              translationMap[lang] = text.toString();
            });
          }
        }
        parsedMaps[mapKey] = MapLocalization(
          mapKey: mapKey,
          translations: translationMap,
        );
      } else if (translations is Map<String, dynamic>) {
        // 处理标准格式
        parsedMaps[mapKey] = MapLocalization(
          mapKey: mapKey,
          translations: Map<String, String>.from(translations),
        );
      }
    });

    return MapLocalizationDatabase(
      version: json['version'] as int,
      maps: parsedMaps,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => _$MapLocalizationDatabaseToJson(this);

  /// 获取指定地图和语言的翻译
  String? getMapTranslation(String mapKey, String languageCode) {
    return maps[mapKey]?.getTranslation(languageCode);
  }

  /// 获取所有地图键
  List<String> get mapKeys => maps.keys.toList();

  /// 检查是否包含指定地图的翻译
  bool hasMapTranslation(String mapKey) {
    return maps.containsKey(mapKey);
  }

  /// 获取所有支持的语言代码
  Set<String> get supportedLanguages {
    final languages = <String>{};
    for (final mapLoc in maps.values) {
      languages.addAll(mapLoc.supportedLanguages);
    }
    return languages;
  }

  /// 创建副本
  MapLocalizationDatabase copyWith({
    int? version,
    Map<String, MapLocalization>? maps,
    DateTime? updatedAt,
  }) {
    return MapLocalizationDatabase(
      version: version ?? this.version,
      maps: maps ?? this.maps,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
