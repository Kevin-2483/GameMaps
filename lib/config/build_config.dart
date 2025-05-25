import 'package:flutter/foundation.dart';

/// 构建时配置生成器
/// 根据目标平台和app_config.json生成编译时常量
class BuildTimeConfig {
  /// 当前构建目标平台
  static const String targetPlatform = String.fromEnvironment(
    'TARGET_PLATFORM',
    defaultValue: _defaultPlatform,
  );

  /// 默认平台检测
  static const String _defaultPlatform = kIsWeb 
    ? 'Web' 
    : 'Unknown';

  /// 从环境变量获取启用的页面列表
  static const List<String> enabledPages = [
    if (bool.fromEnvironment('ENABLE_HOME_PAGE', defaultValue: true)) 'HomePage',
    if (bool.fromEnvironment('ENABLE_SETTINGS_PAGE', defaultValue: true)) 'SettingsPage',
  ];

  /// 从环境变量获取启用的功能列表
  static const List<String> enabledFeatures = [
    if (bool.fromEnvironment('ENABLE_DEBUG_MODE', defaultValue: false)) 'DebugMode',
    if (bool.fromEnvironment('ENABLE_TRAY_NAVIGATION', defaultValue: false)) 'TrayNavigation',
    if (bool.fromEnvironment('ENABLE_EXPERIMENTAL_FEATURES', defaultValue: false)) 'ExperimentalFeatures',
  ];

  /// 应用程序配置
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'R6Box',
  );

  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  static const String buildNumber = String.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: '1',
  );

  /// 检查页面是否在构建时启用
  static bool isPageEnabled(String pageId) => enabledPages.contains(pageId);

  /// 检查功能是否在构建时启用
  static bool isFeatureEnabled(String featureId) => enabledFeatures.contains(featureId);

  /// 调试信息
  static String get buildInfo => '''
Build Configuration for $targetPlatform:
- Enabled Pages: ${enabledPages.join(', ')}
- Enabled Features: ${enabledFeatures.join(', ')}
- App Name: $appName
- App Version: $appVersion
- Build Number: $buildNumber
''';
}