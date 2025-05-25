import 'package:flutter_test/flutter_test.dart';
import 'package:r6box/config/app_config.dart';
import 'package:r6box/config/build_config.dart';
import 'package:r6box/config/config_manager.dart';

void main() {
  group('新配置系统测试', () {
    test('应该能够正确解析配置文件', () {
      const testConfig = {
        "platform": {
          "Windows": {
            "pages": ["HomePage", "SettingsPage"],
            "features": ["DarkTheme", "MultiLanguage"]
          },
          "Android": {
            "pages": ["HomePage"],
            "features": ["DarkTheme"]
          }
        },
        "build": {
          "appName": "R6Box",
          "version": "1.0.0",
          "buildNumber": "1",
          "enableLogging": true
        }
      };

      final config = AppConfig.fromJson(testConfig);
      
      // 测试平台配置
      expect(config.platform.containsKey('Windows'), isTrue);
      expect(config.platform.containsKey('Android'), isTrue);
      
      // 测试 Windows 平台配置
      final windowsConfig = config.platform['Windows']!;
      expect(windowsConfig.hasPage('HomePage'), isTrue);
      expect(windowsConfig.hasPage('SettingsPage'), isTrue);
      expect(windowsConfig.hasFeature('DarkTheme'), isTrue);
      expect(windowsConfig.hasFeature('MultiLanguage'), isTrue);
      
      // 测试 Android 平台配置
      final androidConfig = config.platform['Android']!;
      expect(androidConfig.hasPage('HomePage'), isTrue);
      expect(androidConfig.hasPage('SettingsPage'), isFalse);
      expect(androidConfig.hasFeature('DarkTheme'), isTrue);
      expect(androidConfig.hasFeature('MultiLanguage'), isFalse);
    });

    test('BuildTimeConfig 应该正确检查页面和功能', () {
      // 测试编译时配置检查
      expect(BuildTimeConfig.isPageEnabled('HomePage'), isTrue);
      expect(BuildTimeConfig.isFeatureEnabled('DarkTheme'), isTrue);
      
      // 测试构建信息
      expect(BuildTimeConfig.buildInfo, isNotEmpty);
      expect(BuildTimeConfig.appName, equals('R6Box'));
    });

    test('ConfigManager 应该正确处理平台检查', () {
      final configManager = ConfigManager.instance;
      
      // 测试平台检测
      final currentPlatform = configManager.getCurrentPlatform();
      expect(currentPlatform, isNotEmpty);
      
      // 这里可以添加更多平台相关的测试
    });
  });
}
