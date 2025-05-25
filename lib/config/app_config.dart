import 'package:json_annotation/json_annotation.dart';

part 'app_config.g.dart';

@JsonSerializable()
class AppConfig {
  // 平台配置 - 每个平台包含页面和功能数组
  final Map<String, PlatformConfig> platform;
  
  // 构建配置
  final BuildConfig build;

  const AppConfig({
    required this.platform,
    required this.build,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigToJson(this);

  // 默认配置
  static final AppConfig defaultConfig = AppConfig(
    platform: {
      'Windows': PlatformConfig.defaultConfig,
      'MacOS': PlatformConfig.defaultConfig,
      'Linux': PlatformConfig.defaultConfig,
      'Android': PlatformConfig.defaultConfig,
      'iOS': PlatformConfig.defaultConfig,
      'Web': PlatformConfig.defaultConfig,
    },
    build: BuildConfig.defaultConfig,
  );
}

@JsonSerializable()
class PlatformConfig {
  final List<String> pages;
  final List<String> features;

  const PlatformConfig({
    required this.pages,
    required this.features,
  });

  factory PlatformConfig.fromJson(Map<String, dynamic> json) =>
      _$PlatformConfigFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformConfigToJson(this);

  static const PlatformConfig defaultConfig = PlatformConfig(
    pages: ['HomePage', 'SettingsPage'],
    features: ['DebugMode'],
  );

  // 检查是否启用某个页面
  bool hasPage(String pageId) => pages.contains(pageId);

  // 检查是否启用某个功能
  bool hasFeature(String featureId) => features.contains(featureId);
}

@JsonSerializable()
class BuildConfig {
  final String appName;
  final String version;
  final String buildNumber;
  final bool enableLogging;

  const BuildConfig({
    this.appName = 'R6Box',
    this.version = '1.0.0',
    this.buildNumber = '1',
    this.enableLogging = true,
  });

  factory BuildConfig.fromJson(Map<String, dynamic> json) =>
      _$BuildConfigFromJson(json);

  Map<String, dynamic> toJson() => _$BuildConfigToJson(this);

  static const BuildConfig defaultConfig = BuildConfig();
}
