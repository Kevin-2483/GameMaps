import 'dart:io';
import 'dart:convert';

/// 构建配置生成器
/// 根据目标平台和 app_config.json 生成构建时配置参数
class BuildConfigGenerator {
  static Future<void> main(List<String> args) async {
    if (args.isEmpty) {
      print('Usage: dart build_config_generator.dart <target_platform>');
      print('Available platforms: Windows, MacOS, Linux, Android, iOS, Web');
      exit(1);
    }

    final targetPlatform = args[0];
    final configPath = 'assets/config/app_config.json';

    try {
      // 读取配置文件
      final configFile = File(configPath);
      if (!configFile.existsSync()) {
        print('Error: Configuration file not found at $configPath');
        exit(1);
      }

      final configContent = await configFile.readAsString();
      final config = json.decode(configContent) as Map<String, dynamic>;

      // 提取平台配置
      final platformConfigs = config['platform'] as Map<String, dynamic>?;
      if (platformConfigs == null ||
          !platformConfigs.containsKey(targetPlatform)) {
        print('Error: Platform $targetPlatform not found in configuration');
        exit(1);
      }

      final platformConfig =
          platformConfigs[targetPlatform] as Map<String, dynamic>;
      final pages = platformConfig['pages'] as List<dynamic>? ?? [];
      final features = platformConfig['features'] as List<dynamic>? ?? [];

      // 生成构建参数
      final buildParams = <String>[];

      // 添加平台参数
      buildParams.add(
        '--dart-define=TARGET_PLATFORM=$targetPlatform',
      ); // 添加页面配置
      buildParams.add(
        '--dart-define=ENABLE_HOME_PAGE=${pages.contains('HomePage')}',
      );
      buildParams.add(
        '--dart-define=ENABLE_SETTINGS_PAGE=${pages.contains('SettingsPage')}',
      );
      buildParams.add(
        '--dart-define=ENABLE_USER_PREFERENCES_PAGE=${pages.contains('UserPreferencesPage')}',
      );
      buildParams.add(
        '--dart-define=ENABLE_MAP_ATLAS_PAGE=${pages.contains('MapAtlasPage')}',
      );
      buildParams.add(
        '--dart-define=ENABLE_LEGEND_MANAGER_PAGE=${pages.contains('LegendManagerPage')}',
      );
      buildParams.add(
        '--dart-define=ENABLE_EXTERNAL_RESOURCES_PAGE=${pages.contains('ExternalResourcesPage')}',
      );
      buildParams.add(
        '--dart-define=ENABLE_VFS_FILE_MANAGER_PAGE=${pages.contains('VfsFileManagerPage')}',
      );
      buildParams.add(
        '--dart-define=ENABLE_FULLSCREEN_TEST_PAGE=${pages.contains('FullscreenTestPage')}',
      );

      // 添加功能配置
      buildParams.add(
        '--dart-define=ENABLE_DEBUG_MODE=${features.contains('DebugMode')}',
      );
      buildParams.add(
        '--dart-define=ENABLE_EXPERIMENTAL_FEATURES=${features.contains('ExperimentalFeatures')}',
      );
      buildParams.add(
        '--dart-define=ENABLE_TRAY_NAVIGATION=${features.contains('TrayNavigation')}',
      );

      // 添加构建信息
      final buildConfig = config['build'] as Map<String, dynamic>? ?? {};
      buildParams.add(
        '--dart-define=APP_NAME=${buildConfig['appName'] ?? 'R6Box'}',
      );
      buildParams.add(
        '--dart-define=APP_VERSION=${buildConfig['version'] ?? '1.0.0'}',
      );
      buildParams.add(
        '--dart-define=BUILD_NUMBER=${buildConfig['buildNumber'] ?? '1'}',
      );

      // 输出构建参数
      print('Build parameters for $targetPlatform:');
      for (final param in buildParams) {
        print(param);
      }
      // 写入到文件供构建脚本使用
      final outputFile = File('scripts/build_params_$targetPlatform.txt');
      await outputFile.writeAsString(buildParams.join('\n'));
      print('\nBuild parameters saved to: [32m${outputFile.path}[0m');

      // 额外输出.env文件（仅包含KEY=VALUE，不带--dart-define）
      final envLines = buildParams
          .map((e) => e.replaceFirst('--dart-define=', ''))
          .map((e) {
            final idx = e.indexOf('=');
            if (idx > 0) {
              final key = e.substring(0, idx);
              final value = e.substring(idx + 1);
              return '$key=$value';
            }
            return e;
          })
          .toList();
      final envFile = File('build/.env');
      await envFile.writeAsString(envLines.join('\n'));
      print('Env file saved to: [32m${envFile.path}[0m');

      // 明确退出成功
      exit(0);
    } catch (e) {
      print('Error generating build configuration: $e');
      exit(1);
    }
  }
}

void main(List<String> args) async {
  await BuildConfigGenerator.main(args);
}
