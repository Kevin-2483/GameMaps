// import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';
// import '../services/map_database_service.dart';
import '../services/vfs_map_storage/vfs_map_service_factory.dart';
import '../models/map_item.dart';
import '../models/map_layer.dart';
import '../config/config_manager.dart';

/// Web平台数据库预填充工具
/// 为Web版本提供示例地图数据
class WebDatabasePreloader {
  static const String _sampleMapTitle = 'R6 地图示例';

  /// 初始化示例数据（基于配置决定是否启用）
  static Future<void> initializeSampleData() async {
    // 检查是否启用了预填充示例数据功能
    final shouldPreloadData = await ConfigManager.instance.isFeatureEnabled(
      'PreloadSampleData',
    );
    if (!shouldPreloadData) return;

    try {
      final mapService = VfsMapServiceFactory.createMapDatabaseService();

      // 检查是否已有示例数据
      final existingMaps = await mapService.getAllMapsSummary();
      if (existingMaps.isNotEmpty) {
        debugPrint('已有地图数据，跳过示例数据初始化');
        return;
      }

      // 创建示例地图数据
      final sampleMap = _createSampleMap();

      // 插入示例数据（这里我们直接调用底层数据库方法）
      await _insertSampleMapDirectly(sampleMap);

      debugPrint('示例数据初始化完成');
    } catch (e) {
      debugPrint('示例数据初始化失败: $e');
    }
  }

  /// 创建示例地图
  static MapItem _createSampleMap() {
    // 创建默认图层
    final defaultLayer = MapLayer(
      id: 'sample_layer_1',
      name: '示例图层',
      order: 0,
      opacity: 1.0,
      isVisible: true,
      elements: [], // 空的绘制元素
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return MapItem(
      title: _sampleMapTitle,
      imageData: _getSampleImageData(), // 简单的占位图片
      layers: [defaultLayer],
      legendGroups: [], // 空的图例组
      version: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 获取示例图片数据（简单的Base64编码图片）
  static Uint8List _getSampleImageData() {
    // 这是一个1x1像素的透明PNG图片的Base64编码
    // 在实际应用中，可以提供更有意义的示例图片
    const base64String =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==';
    return base64Decode(base64String);
  }

  /// 直接插入示例地图（绕过Web只读限制）
  static Future<void> _insertSampleMapDirectly(MapItem mapItem) async {
    try {
      final database =
          await VfsMapServiceFactory.createMapDatabaseService().database;
      final data = mapItem.toDatabase();

      await database.insert(
        'maps',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('直接插入示例地图失败: $e');
    }
  }

  /// 清理示例数据（仅用于开发调试）
  static Future<void> clearSampleData() async {
    try {
      final database =
          await VfsMapServiceFactory.createMapDatabaseService().database;
      await database.delete(
        'maps',
        where: 'title = ?',
        whereArgs: [_sampleMapTitle],
      );
      debugPrint('示例数据清理完成');
    } catch (e) {
      debugPrint('示例数据清理失败: $e');
    }
  }
}
