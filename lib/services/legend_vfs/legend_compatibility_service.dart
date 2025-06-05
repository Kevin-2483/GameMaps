import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/legend_item.dart';
import 'legend_vfs_service.dart';

/// 图例存储兼容性服务
/// 提供与传统数据库服务相同的接口，但内部使用VFS存储
class LegendCompatibilityService {
  static final LegendCompatibilityService _instance = LegendCompatibilityService._internal();
  factory LegendCompatibilityService() => _instance;
  LegendCompatibilityService._internal();
  
  final LegendVfsService _vfsService = LegendVfsService();
  bool _initialized = false;
  
  /// 初始化服务
  // Future<void> initialize() async {
  //   if (!_initialized) {
  //     await _vfsService.initialize();
  //     _initialized = true;
  //   }
  // }

  /// 添加图例 (检查标题重复)
  Future<int> insertLegend(LegendItem legend) async {
    // await initialize();
    
    // 检查是否已存在相同标题的图例
    final existing = await getLegendByTitle(legend.title);
    if (existing != null) {
      // 如果新图例版本更高，则更新现有图例
      if (legend.version > existing.version) {
        await updateLegend(legend.copyWith(id: existing.id));
        return existing.id ?? 0;
      } else {
        // 否则不插入，返回现有图例的ID
        return existing.id ?? 0;
      }
    }

    // 不存在重复标题，直接插入
    await _vfsService.saveLegend(legend);
    
    // 生成一个虚拟ID（基于标题哈希）
    return legend.title.hashCode.abs();
  }

  /// 强制添加图例 (忽略标题重复检查)
  Future<int> forceInsertLegend(LegendItem legend) async {
    // await initialize();
    await _vfsService.saveLegend(legend);
    return legend.title.hashCode.abs();
  }

  /// 获取所有图例
  Future<List<LegendItem>> getAllLegends() async {
    // await initialize();
    final legends = await _vfsService.getAllLegends();
    
    // 为每个图例生成虚拟ID（基于标题哈希）
    return legends.map((legend) => legend.copyWith(
      id: legend.title.hashCode.abs(),
    )).toList();
  }

  /// 根据ID获取图例 (ID是基于标题的哈希值)
  Future<LegendItem?> getLegendById(int id) async {
    // await initialize();
    final legends = await getAllLegends();
    
    for (final legend in legends) {
      if (legend.id == id) {
        return legend;
      }
    }
    
    return null;
  }

  /// 更新图例
  Future<void> updateLegend(LegendItem legend) async {
    // await initialize();
    
    // 使用更新的时间戳
    final updatedLegend = legend.copyWith(updatedAt: DateTime.now());
    await _vfsService.saveLegend(updatedLegend);
  }

  /// 删除图例
  Future<void> deleteLegend(int id) async {
    // await initialize();
    
    // 根据ID找到对应的标题
    final legend = await getLegendById(id);
    if (legend != null) {
      await _vfsService.deleteLegend(legend.title);
    }
  }

  /// 根据标题查找图例
  Future<LegendItem?> getLegendByTitle(String title) async {
    // await initialize();
    final legend = await _vfsService.getLegend(title);
    
    if (legend != null) {
      return legend.copyWith(id: title.hashCode.abs());
    }
    
    return null;
  }

  /// 清空所有图例数据
  Future<void> clearAllLegends() async {
    // await initialize();
    await _vfsService.clearAllLegends();
  }

  /// 获取数据库版本
  Future<int> getDatabaseVersion() async {
    final info = await _vfsService.getStorageInfo();
    return info['version'] as int;
  }

  /// 设置数据库版本
  Future<void> setDatabaseVersion(int version) async {
    // VFS版本管理通过元数据实现，这里暂时不实现
    debugPrint('VFS版本管理暂未实现');
  }

  /// 导出数据库到文件
  Future<String?> exportDatabase({int? customVersion}) async {
    try {
      // await initialize();
      
      // 获取所有图例，确保包含图像数据
      final legends = await getAllLegends();
      final dbVersion = customVersion ?? await getDatabaseVersion();

      final legendDatabase = LegendDatabase(
        version: dbVersion,
        legends: legends,
        exportedAt: DateTime.now(),
      );

      // 转换为JSON字符串
      final jsonString = jsonEncode(legendDatabase.toJson());

      // 选择保存文件位置
      String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: '导出图例数据库',
        fileName:
            'legends_vfs_v${dbVersion}_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (filePath != null) {
        final file = File(filePath);
        await file.writeAsString(jsonString);
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('导出图例数据库失败: $e');
      rethrow;
    }
  }

  /// 从文件导入数据库
  Future<bool> importDatabase() async {
    try {
      // await initialize();
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();

        final Map<String, dynamic> jsonData = jsonDecode(jsonString);
        final legendDatabase = LegendDatabase.fromJson(jsonData);

        // 清空现有数据
        await clearAllLegends();

        // 导入新数据
        for (final legend in legendDatabase.legends) {
          await forceInsertLegend(legend);
        }

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('导入图例数据库失败: $e');
      rethrow;
    }
  }

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    // await initialize();
    
    final vfsInfo = await _vfsService.getStorageInfo();
    final legends = await getAllLegends();
    
    // 计算总存储大小
    int totalImageSize = 0;
    for (final legend in legends) {
      if (legend.imageData != null) {
        totalImageSize += legend.imageData!.length;
      }
    }
    
    return {
      ...vfsInfo,
      'totalImageSize': totalImageSize,
      'averageImageSize': legends.isNotEmpty ? totalImageSize / legends.length : 0,
      'legendsWithImages': legends.where((l) => l.hasImageData).length,
    };
  }

  /// 验证数据完整性
  Future<Map<String, dynamic>> verifyDataIntegrity() async {
    // await initialize();
    
    final legends = await getAllLegends();
    int validCount = 0;
    int invalidCount = 0;
    List<String> issues = [];
    
    for (final legend in legends) {
      bool isValid = true;
      
      // 检查必要字段
      if (legend.title.isEmpty) {
        issues.add('图例标题为空');
        isValid = false;
      }
      
      if (legend.centerX < 0 || legend.centerX > 1 || 
          legend.centerY < 0 || legend.centerY > 1) {
        issues.add('图例 "${legend.title}" 中心点坐标无效');
        isValid = false;
      }
      
      if (legend.version <= 0) {
        issues.add('图例 "${legend.title}" 版本号无效');
        isValid = false;
      }
      
      // 检查是否能重新加载
      try {
        final reloaded = await _vfsService.getLegend(legend.title);
        if (reloaded == null) {
          issues.add('图例 "${legend.title}" 无法重新加载');
          isValid = false;
        }
      } catch (e) {
        issues.add('图例 "${legend.title}" 加载错误: $e');
        isValid = false;
      }
      
      if (isValid) {
        validCount++;
      } else {
        invalidCount++;
      }
    }
    
    return {
      'total': legends.length,
      'valid': validCount,
      'invalid': invalidCount,
      'issues': issues,
      'isHealthy': invalidCount == 0,
    };
  }

  /// 关闭数据库连接（兼容性方法）
  Future<void> close() async {
    // VFS服务不需要显式关闭，这里提供兼容性
    debugPrint('VFS服务不需要显式关闭');
  }
}
