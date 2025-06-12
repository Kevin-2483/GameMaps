import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/map_item.dart';
import '../models/map_item_summary.dart';
import '../models/legend_item.dart';
import 'map_database_service.dart';
import 'vfs_map_storage/vfs_map_service_factory.dart';
import 'legend_vfs/legend_compatibility_service.dart';
import 'map_localization_service.dart';

/// 合并数据库导出服务
/// 用于将地图、图例和本地化数据导出为单个JSON文件，供Web平台使用
class CombinedDatabaseExporter {
  static final CombinedDatabaseExporter _instance =
      CombinedDatabaseExporter._internal();
  factory CombinedDatabaseExporter() => _instance;
  CombinedDatabaseExporter._internal();

  final MapDatabaseService _mapService =
      VfsMapServiceFactory.createMapDatabaseService();
  final LegendCompatibilityService _legendService =
      LegendCompatibilityService();
  final MapLocalizationService _localizationService = MapLocalizationService();

  /// 导出数据库数据为单个JSON文件
  ///
  /// [customVersion] 自定义导出版本号
  /// [includeMaps] 是否包含地图数据
  /// [includeLegends] 是否包含图例数据
  /// [includeLocalizations] 是否包含本地化数据
  /// [selectedMapIds] 要导出的特定地图ID列表（为空时导出所有地图）
  /// [selectedLegendIds] 要导出的特定图例ID列表（为空时导出所有图例）
  ///
  /// 返回导出文件路径，失败时返回null
  Future<String?> exportAllDatabases({
    int? customVersion,
    bool includeMaps = true,
    bool includeLegends = true,
    bool includeLocalizations = true,
    List<int>? selectedMapIds,
    List<int>? selectedLegendIds,
  }) async {
    try {
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
      };

      int totalItems = 0;

      // 获取并导出地图数据
      if (includeMaps) {
        List<MapItem> maps;
        if (selectedMapIds != null && selectedMapIds.isNotEmpty) {
          // 导出指定的地图
          maps = [];
          for (final id in selectedMapIds) {
            final map = await _mapService.getMapById(id);
            if (map != null) {
              maps.add(map);
            }
          }
        } else {
          // 导出所有地图
          maps = await _mapService.getAllMaps();
        }

        exportData['maps'] = {
          'version': mapVersion,
          'data': maps.map((map) => map.toJson()).toList(),
          'count': maps.length,
        };
        totalItems += maps.length;
      }

      // 获取并导出图例数据
      if (includeLegends) {
        List<LegendItem> legends;
        if (selectedLegendIds != null && selectedLegendIds.isNotEmpty) {
          // 导出指定的图例
          legends = [];
          for (final id in selectedLegendIds) {
            final legend = await _legendService.getLegendById(id);
            if (legend != null) {
              legends.add(legend);
            }
          }
        } else {
          // 导出所有图例
          legends = await _legendService.getAllLegends();
        }

        exportData['legends'] = {
          'version': legendVersion,
          'data': legends.map((legend) => legend.toJson()).toList(),
          'count': legends.length,
        };
        totalItems += legends.length;
      }

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
- 总项目数量: $totalItems
- 包含地图: $includeMaps
- 包含图例: $includeLegends
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

  /// 获取所有可用的地图摘要（用于选择性导出）
  Future<List<MapItemSummary>> getAvailableMaps() async {
    try {
      return await _mapService.getAllMapsSummary();
    } catch (e) {
      debugPrint('获取地图列表失败: $e');
      return [];
    }
  }

  /// 获取所有可用的图例（用于选择性导出）
  Future<List<LegendItem>> getAvailableLegends() async {
    try {
      return await _legendService.getAllLegends();
    } catch (e) {
      debugPrint('获取图例列表失败: $e');
      return [];
    }
  }

  /// 获取数据库统计信息
  Future<Map<String, int>> getDatabaseStats() async {
    try {
      final maps = await _mapService.getAllMapsSummary();
      final legends = await _legendService.getAllLegends();

      return {'mapsCount': maps.length, 'legendsCount': legends.length};
    } catch (e) {
      debugPrint('获取数据库统计信息失败: $e');
      return {'mapsCount': 0, 'legendsCount': 0};
    }
  }
}
