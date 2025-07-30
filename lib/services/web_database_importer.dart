// This file has been processed by AI for internationalization
import 'dart:convert';
// import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/map_item.dart';
import '../models/legend_item.dart';
// import '../services/map_database_service.dart';
import '../services/vfs_map_storage/vfs_map_service_factory.dart';
import 'legend_vfs/legend_compatibility_service.dart';
import '../l10n/app_localizations.dart';
import 'localization_service.dart';

/// Web平台数据库导入工具
/// 用于将从客户端导出的JSON数据导入到Web平台数据库
class WebDatabaseImporter {
  static const String _assetPath = 'assets/data/exported_database.json';

  /// 从assets中导入预设的数据库数据
  static Future<void> importFromAssets() async {
    if (!kIsWeb) {
      debugPrint(
        LocalizationService.instance.current.webDatabaseImporterWebOnly_7281,
      );
      return;
    }

    try {
      // 检查是否存在导出的数据文件
      final jsonString = await rootBundle.loadString(_assetPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;

      await _importData(data);
      debugPrint(
        LocalizationService.instance.current.webDatabaseImportComplete_4821,
      );
    } catch (e) {
      debugPrint('WebDatabaseImporter: 导入失败 - $e');
      // 如果没有导出数据，使用示例数据
      await _createSampleData();
    }
  }

  /// 从JSON数据导入到数据库
  static Future<void> importFromJson(Map<String, dynamic> data) async {
    await _importData(data);
  }

  /// 导入数据到数据库
  static Future<void> _importData(Map<String, dynamic> data) async {
    final mapService = VfsMapServiceFactory.createMapDatabaseService();
    final legendService = LegendCompatibilityService();

    // 导入地图数据 - 处理新的嵌套格式
    if (data.containsKey('maps')) {
      final mapsData = data['maps'] as Map<String, dynamic>;
      if (mapsData.containsKey('data')) {
        final mapsList = mapsData['data'] as List<dynamic>;
        for (final mapData in mapsList) {
          try {
            final mapItem = MapItem.fromJson(mapData as Map<String, dynamic>);
            // 直接调用强制插入方法，绕过Web平台的只读限制
            await mapService.forceInsertMap(mapItem);
            debugPrint(
              'WebDatabaseImporter: ' +
                  LocalizationService.instance.current.mapImportSuccess(
                    mapItem.title,
                  ),
            );
          } catch (e) {
            debugPrint('WebDatabaseImporter: 导入地图失败 - $e');
          }
        }
      }
    }

    // 导入图例数据 - 处理新的嵌套格式
    if (data.containsKey('legends')) {
      final legendsData = data['legends'] as Map<String, dynamic>;
      if (legendsData.containsKey('data')) {
        final legendsList = legendsData['data'] as List<dynamic>;
        for (final legendData in legendsList) {
          try {
            // 将JSON数据转换为LegendItem对象
            final legendItem = LegendItem.fromJson(
              legendData as Map<String, dynamic>,
            );
            // 直接调用强制插入方法，绕过重复检查
            await legendService.forceInsertLegend(legendItem);
            debugPrint(
              'WebDatabaseImporter: ${LocalizationService.instance.current.legendImportSuccess_7421}: ${legendItem.title}',
            );
          } catch (e) {
            debugPrint(
              'WebDatabaseImporter: ${LocalizationService.instance.current.importLegendFailed_7281} - $e',
            );
          }
        }
      }
    }
  }

  /// 创建示例数据（当没有导出数据时使用）
  static Future<void> _createSampleData() async {
    debugPrint(LocalizationService.instance.current.createSampleData_7421);
    final mapService = VfsMapServiceFactory.createMapDatabaseService();

    // 创建示例地图
    final sampleMap = MapItem(
      title: LocalizationService.instance.current.sampleMapTitle_7281,
      imageData: _createSampleImageData(),
      version: 1,
      layers: [],
      legendGroups: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await mapService.forceInsertMap(sampleMap);
      debugPrint(LocalizationService.instance.current.sampleDataCreated_7421);
    } catch (e) {
      debugPrint(
        'WebDatabaseImporter: ${LocalizationService.instance.current.createSampleDataFailed_7281} - $e',
      );
    }
  }

  /// 创建示例图片数据
  static Uint8List _createSampleImageData() {
    // 创建一个简单的1x1像素的透明PNG图片
    const base64Data =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAGA8cMiPwAAAABJRU5ErkJggg==';
    return base64Decode(base64Data);
  }
}
