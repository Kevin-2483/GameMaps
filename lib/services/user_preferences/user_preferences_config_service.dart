// This file has been processed by AI for internationalization
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../virtual_file_system/vfs_service_provider.dart';
import '../../models/user_preferences.dart';

import '../localization_service.dart';

/// 用户偏好设置多配置管理服务
/// 使用VFS在fs集合中存储配置JSON文件
class UserPreferencesConfigService {
  static final UserPreferencesConfigService _instance =
      UserPreferencesConfigService._internal();
  factory UserPreferencesConfigService() => _instance;
  UserPreferencesConfigService._internal();

  final VfsServiceProvider _vfsProvider = VfsServiceProvider();
  static const String _collection = 'fs';
  static const String _configDir = 'config';
  static const String _configListFile = 'config_list.json';

  bool _isInitialized = false;

  /// 初始化服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 确保配置目录存在
      await _ensureConfigDirectory();

      _isInitialized = true;
      debugPrint(
        LocalizationService.instance.current.userPreferencesInitComplete_4821,
      );
    } catch (e) {
      debugPrint(LocalizationService.instance.current.configInitFailed_7285(e));
      rethrow;
    }
  }

  /// 确保配置目录存在
  Future<void> _ensureConfigDirectory() async {
    try {
      await _vfsProvider.createDirectory(_collection, _configDir);
      debugPrint(
        LocalizationService.instance.current.configDirCreatedOrExists_7281,
      );
    } catch (e) {
      // 目录可能已存在，这是正常的
      debugPrint(
        LocalizationService.instance.current.configDirCreationError_4821(e),
      );
    }
  }

  /// 清理文件名，移除不安全字符
  String _sanitizeFileName(String fileName) {
    if (fileName.isEmpty) {
      return 'config_${DateTime.now().millisecondsSinceEpoch}';
    }

    // 移除或替换不安全的文件名字符
    String cleaned = fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_') // Windows不安全字符
        .replaceAll(RegExp(r'\s+'), '_') // 空格替换为下划线
        .replaceAll(RegExp(r'_+'), '_') // 多个下划线合并为一个
        .replaceAll(RegExp(r'^_|_$'), ''); // 移除开头和结尾的下划线

    // 如果清理后为空，使用默认名称
    if (cleaned.isEmpty) {
      return 'config_${DateTime.now().millisecondsSinceEpoch}';
    }

    return cleaned;
  }

  /// 生成唯一文件名，避免重复
  Future<String> _generateUniqueFileName(String baseName) async {
    String fileName = '$baseName.json';
    int counter = 1;

    // 检查文件是否已存在
    while (await _fileExists(fileName)) {
      fileName = '${baseName}_$counter.json';
      counter++;
    }

    return fileName;
  }

  /// 检查文件是否存在
  Future<bool> _fileExists(String fileName) async {
    try {
      final filePath = 'indexeddb://r6box/$_collection/$_configDir/$fileName';
      final content = await _vfsProvider.vfs.readTextFile(filePath);
      return content != null && content.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 获取所有配置列表
  Future<List<ConfigInfo>> getAllConfigs() async {
    await initialize();

    try {
      // 直接扫描配置目录，不依赖索引文件
      final files = await _vfsProvider.listFiles(_collection, _configDir);
      final configFiles = files
          .where(
            (file) =>
                !file.isDirectory &&
                file.name.endsWith('.json') &&
                file.name != _configListFile,
          )
          .toList();

      final configs = <ConfigInfo>[];

      for (final file in configFiles) {
        try {
          final configId = file.name.replaceAll('.json', '');
          final configInfo = await getConfigInfo(configId);
          if (configInfo != null) {
            configs.add(configInfo);
          }
        } catch (e) {
          debugPrint('读取配置文件失败: ${file.name}, 错误: $e');
          // 继续处理其他文件
        }
      }

      // 按创建时间排序
      configs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return configs;
    } catch (e) {
      debugPrint('获取配置列表失败: $e');
      return [];
    }
  }

  /// 保存配置
  Future<String> saveConfig({
    required String name,
    required String description,
    required UserPreferences preferences,
    String? configId,
  }) async {
    await initialize();

    // 如果提供了configId，使用它；否则使用name作为基础文件名
    String baseFileName = configId ?? name;

    // 清理文件名，移除不安全字符
    baseFileName = _sanitizeFileName(baseFileName);

    // 检查重复性并生成唯一文件名
    String fileName = await _generateUniqueFileName(baseFileName);

    final filePath = '$_configDir/$fileName';

    // 保存配置文件
    final configData = {
      'id': fileName.replaceAll('.json', ''), // 使用文件名（不含扩展名）作为ID
      'name': name,
      'description': description,
      'createdAt': DateTime.now().toIso8601String(),
      'preferences': preferences.toJson(),
    };

    final fullPath = 'indexeddb://r6box/$_collection/$filePath';

    await _vfsProvider.vfs.writeTextFile(fullPath, jsonEncode(configData));

    final resultId = fileName.replaceAll('.json', '');
    return resultId;
  }

  /// 读取配置
  Future<UserPreferences?> loadConfig(String configId) async {
    await initialize();

    try {
      final fileName = '$configId.json';
      final filePath = '$_configDir/$fileName';

      final content = await _vfsProvider.vfs.readTextFile(
        'indexeddb://r6box/$_collection/$filePath',
      );

      if (content == null) {
        return null;
      }

      final data = jsonDecode(content) as Map<String, dynamic>;

      final preferencesData = data['preferences'] as Map<String, dynamic>;
      return UserPreferences.fromJson(preferencesData);
    } catch (e) {
      debugPrint('读取配置失败: $e');
      return null;
    }
  }

  /// 删除配置
  Future<bool> deleteConfig(String configId) async {
    await initialize();

    try {
      final fileName = '$configId.json';
      final filePath = 'indexeddb://r6box/$_collection/$_configDir/$fileName';

      // 删除配置文件
      await _vfsProvider.vfs.delete(filePath);

      // 注意：不再需要从索引文件中移除，getAllConfigs会直接扫描目录

      debugPrint(
        LocalizationService.instance.current.configDeletedSuccessfully(
          configId,
        ),
      );
      return true;
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.deleteConfigFailed_7281(e),
      );
      return false;
    }
  }

  /// 检查配置是否存在
  Future<bool> configExists(String configId) async {
    await initialize();

    try {
      final fileName = '$configId.json';
      final filePath = 'indexeddb://r6box/$_collection/$_configDir/$fileName';

      await _vfsProvider.vfs.readTextFile(filePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取配置信息（不包含完整偏好设置数据）
  Future<ConfigInfo?> getConfigInfo(String configId) async {
    await initialize();

    try {
      final fileName = '$configId.json';
      final filePath = '$_configDir/$fileName';

      final content = await _vfsProvider.vfs.readTextFile(
        'indexeddb://r6box/$_collection/$filePath',
      );

      if (content == null) {
        return null;
      }

      final data = jsonDecode(content) as Map<String, dynamic>;

      return ConfigInfo(
        id: data['id'] as String,
        name: data['name'] as String,
        description: data['description'] as String,
        fileName: fileName,
        createdAt: DateTime.parse(data['createdAt'] as String),
      );
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.fetchConfigFailed_7284(e),
      );
      return null;
    }
  }
}

/// 配置信息模型
class ConfigInfo {
  final String id;
  final String name;
  final String description;
  final String fileName;
  final DateTime createdAt;

  ConfigInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.fileName,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ConfigInfo.fromJson(Map<String, dynamic> json) {
    return ConfigInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      fileName: json['fileName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'ConfigInfo(id: $id, name: $name, description: $description)';
  }
}
