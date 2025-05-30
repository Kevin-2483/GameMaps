import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/map_item.dart';
import '../models/legend_item.dart';
import '../models/map_localization.dart';
import 'map_database_service.dart';
import 'legend_database_service.dart';
import 'map_localization_service.dart';

/// 合并数据库导出服务
/// 用于将地图、图例和本地化数据导出为单个JSON文件，供Web平台使用
class CombinedDatabaseExporter {
  static final CombinedDatabaseExporter _instance =
      CombinedDatabaseExporter._internal();
  factory CombinedDatabaseExporter() => _instance;
  CombinedDatabaseExporter._internal();

  final MapDatabaseService _mapService = MapDatabaseService();
  final LegendDatabaseService _legendService = LegendDatabaseService();
  final MapLocalizationService _localizationService = MapLocalizationService();

  /// 导出所有数据库数据为单个JSON文件
  ///
  /// [customVersion] 自定义导出版本号
  /// [includeLocalizations] 是否包含本地化数据
  ///
  /// 返回导出文件路径，失败时返回null
  Future<String?> exportAllDatabases({
    int? customVersion,
    bool includeLocalizations = true,
  }) async {
    try {
      // 获取所有数据
      final maps = await _mapService.getAllMaps();
      final legends = await _legendService.getAllLegends();
      final mapVersion =
          customVersion ?? await _mapService.getDatabaseVersion();
      final legendVersion = await _legendService.getDatabaseVersion();

      // 构建导出数据结构
      final exportData = <String, dynamic>{
        'exportInfo': {
          'version': mapVersion,
          'exportedAt': DateTime.now().toIso8601String(),
          'exportedBy': 'R6Box Desktop Client',
          'description': 'Combined database export for Web platform',
        },
        'maps': {
          'version': mapVersion,
          'data': maps.map((map) => map.toJson()).toList(),
          'count': maps.length,
        },
        'legends': {
          'version': legendVersion,
          'data': legends.map((legend) => legend.toJson()).toList(),
          'count': legends.length,
        },
      };

      // 可选包含本地化数据
      if (includeLocalizations) {
        try {
          final localizationDb = await _localizationService
              .getAllLocalizations();
          exportData['localizations'] = {
            'version': localizationDb.version,
            'data': localizationDb.toJson(),
            'count': localizationDb.maps.length,
          };
        } catch (e) {
          debugPrint('获取本地化数据失败: $e');
          // 本地化数据失败不影响整体导出
        }
      }

      // 选择保存位置
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: '导出R6Box数据库 (Web平台专用)',
        fileName:
            'r6box_database_web_v${mapVersion}_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        final jsonString = const JsonEncoder.withIndent(
          '  ',
        ).convert(exportData);
        await file.writeAsString(jsonString);

        debugPrint('''
合并数据库导出成功:
- 文件路径: $outputFile
- 导出版本: $mapVersion
- 地图数量: ${maps.length}
- 图例数量: ${legends.length}
- 包含本地化: $includeLocalizations
        ''');

        return outputFile;
      }
    } catch (e) {
      debugPrint('合并数据库导出失败: $e');
      rethrow;
    }
    return null;
  }

  /// 验证导出文件的完整性
  static Future<bool> validateExportFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('导出文件不存在: $filePath');
        return false;
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // 检查必要字段
      if (!data.containsKey('exportInfo') ||
          !data.containsKey('maps') ||
          !data.containsKey('legends')) {
        debugPrint('导出文件格式不正确，缺少必要字段');
        return false;
      }

      // 检查地图数据
      final mapsData = data['maps'] as Map<String, dynamic>;
      if (!mapsData.containsKey('data') || mapsData['data'] is! List) {
        debugPrint('地图数据格式不正确');
        return false;
      }

      // 检查图例数据
      final legendsData = data['legends'] as Map<String, dynamic>;
      if (!legendsData.containsKey('data') || legendsData['data'] is! List) {
        debugPrint('图例数据格式不正确');
        return false;
      }

      debugPrint('导出文件验证通过: $filePath');
      return true;
    } catch (e) {
      debugPrint('验证导出文件失败: $e');
      return false;
    }
  }

  /// 获取导出文件信息
  static Future<Map<String, dynamic>?> getExportFileInfo(
    String filePath,
  ) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (!data.containsKey('exportInfo')) return null;

      final exportInfo = data['exportInfo'] as Map<String, dynamic>;
      final mapsData = data['maps'] as Map<String, dynamic>;
      final legendsData = data['legends'] as Map<String, dynamic>;

      return {
        'version': exportInfo['version'],
        'exportedAt': exportInfo['exportedAt'],
        'exportedBy': exportInfo['exportedBy'],
        'description': exportInfo['description'],
        'mapsCount': mapsData['count'],
        'legendsCount': legendsData['count'],
        'hasLocalizations': data.containsKey('localizations'),
        'fileSize': await file.length(),
      };
    } catch (e) {
      debugPrint('获取导出文件信息失败: $e');
      return null;
    }
  }
}
