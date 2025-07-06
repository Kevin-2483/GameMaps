// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => AppConfig(
  platform: (json['platform'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, PlatformConfig.fromJson(e as Map<String, dynamic>)),
  ),
  build: BuildConfig.fromJson(json['build'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
  'platform': instance.platform,
  'build': instance.build,
};

PlatformConfig _$PlatformConfigFromJson(Map<String, dynamic> json) =>
    PlatformConfig(
      pages: (json['pages'] as List<dynamic>).map((e) => e as String).toList(),
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PlatformConfigToJson(PlatformConfig instance) =>
    <String, dynamic>{'pages': instance.pages, 'features': instance.features};

BuildConfig _$BuildConfigFromJson(Map<String, dynamic> json) => BuildConfig(
  appName: json['appName'] as String? ?? 'R6Box',
  version: json['version'] as String? ?? '1.0.0',
  buildNumber: json['buildNumber'] as String? ?? '1',
  enableLogging: json['enableLogging'] as bool? ?? true,
);

Map<String, dynamic> _$BuildConfigToJson(BuildConfig instance) =>
    <String, dynamic>{
      'appName': instance.appName,
      'version': instance.version,
      'buildNumber': instance.buildNumber,
      'enableLogging': instance.enableLogging,
    };
