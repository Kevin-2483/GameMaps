import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';

class ConfigManager {
  static ConfigManager? _instance;
  static ConfigManager get instance => _instance ??= ConfigManager._();
  
  ConfigManager._();

  AppConfig? _config;
  
  AppConfig get config => _config ?? AppConfig.defaultConfig;

  // 从 assets 加载配置
  Future<void> loadFromAssets({String path = 'assets/config/app_config.json'}) async {
    try {
      final String configString = await rootBundle.loadString(path);
      final Map<String, dynamic> configJson = json.decode(configString);
      _config = AppConfig.fromJson(configJson);    } catch (e) {
      // Use debugPrint instead of print in production
      debugPrint('Failed to load config from assets: $e');
      _config = AppConfig.defaultConfig;
    }
  }

  // 从本地存储加载配置
  Future<void> loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? configString = prefs.getString('app_config');
      if (configString != null) {
        final Map<String, dynamic> configJson = json.decode(configString);
        _config = AppConfig.fromJson(configJson);
      } else {
        _config = AppConfig.defaultConfig;
      }    } catch (e) {
      debugPrint('Failed to load config from preferences: $e');
      _config = AppConfig.defaultConfig;
    }
  }

  // 保存配置到本地存储
  Future<void> saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String configString = json.encode(_config?.toJson());
      await prefs.setString('app_config', configString);    } catch (e) {
      debugPrint('Failed to save config to preferences: $e');
    }
  }

  // 更新配置
  void updateConfig(AppConfig newConfig) {
    _config = newConfig;
    saveToPreferences();
  }
  // 检查平台是否存在配置
  bool isPlatformConfigured(String platform) {
    return config.platform.containsKey(platform);
  }

  // 获取平台配置
  PlatformConfig? getPlatformConfig(String platform) {
    return config.platform[platform];
  }

  // 检查某个平台是否启用某个页面
  bool isPlatformPageEnabled(String platform, String pageId) {
    final platformConfig = getPlatformConfig(platform);
    return platformConfig?.hasPage(pageId) ?? false;
  }

  // 检查某个平台是否启用某个功能
  bool isPlatformFeatureEnabled(String platform, String featureId) {
    final platformConfig = getPlatformConfig(platform);
    return platformConfig?.hasFeature(featureId) ?? false;
  }

  // 获取当前平台名称
  String getCurrentPlatform() {
    if (kIsWeb) return 'Web';
    
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.macOS:
        return 'MacOS';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      default:
        return 'Unknown';
    }
  }

  // 检查当前平台是否启用某个页面
  bool isCurrentPlatformPageEnabled(String pageId) {
    return isPlatformPageEnabled(getCurrentPlatform(), pageId);
  }

  // 检查当前平台是否启用某个功能
  bool isCurrentPlatformFeatureEnabled(String featureId) {
    return isPlatformFeatureEnabled(getCurrentPlatform(), featureId);
  }
}
