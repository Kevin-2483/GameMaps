import 'dart:convert';
import 'dart:io';

/// 配置文件验证器
class ConfigValidator {
  static const List<String> _validPlatforms = [
    'Windows', 'MacOS', 'Linux', 'Android', 'iOS', 'Web'
  ];

  static const List<String> _validPages = [
    'HomePage', 'SettingsPage'
  ];

  static const List<String> _validFeatures = [
   'DebugMode', 'ExperimentalFeatures', 'TrayNavigation'
  ];

  static Future<ValidationResult> validateConfigFile(String filePath) async {
    final result = ValidationResult();
    
    try {
      // 检查文件是否存在
      final file = File(filePath);
      if (!file.existsSync()) {
        result.addError('配置文件不存在: $filePath');
        return result;
      }

      // 读取和解析 JSON
      final content = await file.readAsString();
      late Map<String, dynamic> config;
      
      try {
        config = json.decode(content) as Map<String, dynamic>;
      } catch (e) {
        result.addError('JSON 格式错误: $e');
        return result;
      }

      // 验证顶级结构
      if (!config.containsKey('platform')) {
        result.addError('缺少必需的 "platform" 字段');
      }

      if (!config.containsKey('build')) {
        result.addError('缺少必需的 "build" 字段');
      }

      // 验证平台配置
      if (config.containsKey('platform')) {
        _validatePlatformConfig(config['platform'], result);
      }

      // 验证构建配置
      if (config.containsKey('build')) {
        _validateBuildConfig(config['build'], result);
      }

      // 验证完整性
      _validateConsistency(config, result);

    } catch (e) {
      result.addError('验证过程中发生错误: $e');
    }

    return result;
  }

  static void _validatePlatformConfig(dynamic platformConfig, ValidationResult result) {
    if (platformConfig is! Map<String, dynamic>) {
      result.addError('platform 必须是一个对象');
      return;
    }

    final platforms = platformConfig as Map<String, dynamic>;

    // 检查是否至少有一个平台
    if (platforms.isEmpty) {
      result.addError('至少需要配置一个平台');
    }

    // 验证每个平台
    for (final entry in platforms.entries) {
      final platformName = entry.key;
      final platformData = entry.value;

      // 检查平台名称是否有效
      if (!_validPlatforms.contains(platformName)) {
        result.addWarning('未知的平台: $platformName');
      }

      // 验证平台数据结构
      if (platformData is! Map<String, dynamic>) {
        result.addError('平台 $platformName 的配置必须是一个对象');
        continue;
      }

      final platform = platformData as Map<String, dynamic>;

      // 验证 pages 字段
      if (!platform.containsKey('pages')) {
        result.addError('平台 $platformName 缺少 "pages" 字段');
      } else {
        _validateStringArray(platform['pages'], 'pages', platformName, _validPages, result);
      }

      // 验证 features 字段
      if (!platform.containsKey('features')) {
        result.addError('平台 $platformName 缺少 "features" 字段');
      } else {
        _validateStringArray(platform['features'], 'features', platformName, _validFeatures, result);
      }
    }
  }

  static void _validateStringArray(
    dynamic array, 
    String fieldName, 
    String platformName, 
    List<String> validValues, 
    ValidationResult result
  ) {
    if (array is! List) {
      result.addError('平台 $platformName 的 $fieldName 必须是一个数组');
      return;
    }

    final list = array as List;
    for (final item in list) {
      if (item is! String) {
        result.addError('平台 $platformName 的 $fieldName 数组中包含非字符串值: $item');
        continue;
      }

      if (!validValues.contains(item)) {
        result.addWarning('平台 $platformName 的 $fieldName 包含未知值: $item');
      }
    }

    // 检查重复项
    final uniqueItems = list.toSet();
    if (uniqueItems.length != list.length) {
      result.addWarning('平台 $platformName 的 $fieldName 包含重复项');
    }
  }

  static void _validateBuildConfig(dynamic buildConfig, ValidationResult result) {
    if (buildConfig is! Map<String, dynamic>) {
      result.addError('build 必须是一个对象');
      return;
    }

    final build = buildConfig as Map<String, dynamic>;

    // 验证必需字段
    final requiredFields = ['appName', 'version', 'buildNumber'];
    for (final field in requiredFields) {
      if (!build.containsKey(field)) {
        result.addWarning('build 配置缺少推荐字段: $field');
      }
    }

    // 验证版本格式
    if (build.containsKey('version')) {
      final version = build['version'];
      if (version is String) {
        final versionRegex = RegExp(r'^\d+\.\d+\.\d+$');
        if (!versionRegex.hasMatch(version)) {
          result.addWarning('版本号格式不标准，推荐使用 x.y.z 格式: $version');
        }
      }
    }
  }

  static void _validateConsistency(Map<String, dynamic> config, ValidationResult result) {
    // 检查是否所有平台都有基本页面
    if (config.containsKey('platform')) {
      final platforms = config['platform'] as Map<String, dynamic>;
      
      for (final entry in platforms.entries) {
        final platformName = entry.key;
        final platformData = entry.value as Map<String, dynamic>;
        
        if (platformData.containsKey('pages')) {
          final pages = platformData['pages'] as List;
          
          // 检查是否有主页
          if (!pages.contains('HomePage')) {
            result.addWarning('平台 $platformName 没有配置主页 (HomePage)');
          }
          
          // 检查是否有设置页
          if (!pages.contains('SettingsPage')) {
            result.addInfo('平台 $platformName 没有配置设置页 (SettingsPage)');
          }
        }
      }
    }
  }
}

/// 验证结果
class ValidationResult {
  final List<String> errors = [];
  final List<String> warnings = [];
  final List<String> infos = [];

  bool get isValid => errors.isEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasInfos => infos.isNotEmpty;

  void addError(String message) => errors.add(message);
  void addWarning(String message) => warnings.add(message);
  void addInfo(String message) => infos.add(message);

  void printResults() {
    if (errors.isNotEmpty) {
      print('❌ 错误:');
      for (final error in errors) {
        print('  • $error');
      }
    }

    if (warnings.isNotEmpty) {
      print('⚠️  警告:');
      for (final warning in warnings) {
        print('  • $warning');
      }
    }

    if (infos.isNotEmpty) {
      print('ℹ️  信息:');
      for (final info in infos) {
        print('  • $info');
      }
    }

    if (isValid && !hasWarnings && !hasInfos) {
      print('✅ 配置文件验证通过');
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    
    if (errors.isNotEmpty) {
      buffer.writeln('错误 (${errors.length}):');
      for (final error in errors) {
        buffer.writeln('  • $error');
      }
    }

    if (warnings.isNotEmpty) {
      buffer.writeln('警告 (${warnings.length}):');
      for (final warning in warnings) {
        buffer.writeln('  • $warning');
      }
    }

    if (infos.isNotEmpty) {
      buffer.writeln('信息 (${infos.length}):');
      for (final info in infos) {
        buffer.writeln('  • $info');
      }
    }

    return buffer.toString();
  }
}
