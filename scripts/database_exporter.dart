import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

/// 数据库导出工具
/// 将桌面版数据库数据导出为Web平台可用的JSON格式
class DatabaseExporter {
  static Future<void> exportToWebFormat() async {
    // 初始化FFI数据库
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final databasesPath = await getDatabasesPath();

    // 数据库文件路径
    final mapsDbPath = join(databasesPath, 'maps.db');
    final legendsDbPath = join(databasesPath, 'legends.db');
    final localizationDbPath = join(databasesPath, 'map_localizations.db');

    // 导出数据
    final exportData = <String, dynamic>{};

    // 导出地图数据
    if (await File(mapsDbPath).exists()) {
      exportData['maps'] = await _exportMapsData(mapsDbPath);
    }

    // 导出图例数据
    if (await File(legendsDbPath).exists()) {
      exportData['legends'] = await _exportLegendsData(legendsDbPath);
    }

    // 导出本地化数据
    if (await File(localizationDbPath).exists()) {
      exportData['localizations'] = await _exportLocalizationData(
        localizationDbPath,
      );
    }

    // 生成导出文件
    final exportJson = jsonEncode(exportData);
    final outputFile = File('web_database_export.json');
    await outputFile.writeAsString(exportJson);

    print('数据库导出完成！');
    print('输出文件: ${outputFile.absolute.path}');
    print('地图数量: ${(exportData['maps'] as List?)?.length ?? 0}');
    print('图例数量: ${(exportData['legends'] as List?)?.length ?? 0}');
    print('本地化条目数量: ${(exportData['localizations'] as List?)?.length ?? 0}');
  }

  static Future<List<Map<String, dynamic>>> _exportMapsData(
    String dbPath,
  ) async {
    final db = await openDatabase(dbPath);
    final List<Map<String, dynamic>> maps = await db.query('maps');
    await db.close();

    // 转换BLOB数据为Base64字符串
    return maps.map((map) {
      final mapData = Map<String, dynamic>.from(map);
      if (mapData['image_data'] != null) {
        final Uint8List imageBytes = mapData['image_data'];
        mapData['image_data'] = base64Encode(imageBytes);
      }
      return mapData;
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> _exportLegendsData(
    String dbPath,
  ) async {
    final db = await openDatabase(dbPath);
    final List<Map<String, dynamic>> legends = await db.query('legends');
    await db.close();

    // 转换BLOB数据为Base64字符串
    return legends.map((legend) {
      final legendData = Map<String, dynamic>.from(legend);
      if (legendData['image_data'] != null) {
        final Uint8List imageBytes = legendData['image_data'];
        legendData['image_data'] = base64Encode(imageBytes);
      }
      return legendData;
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> _exportLocalizationData(
    String dbPath,
  ) async {
    final db = await openDatabase(dbPath);
    final List<Map<String, dynamic>> localizations = await db.query(
      'map_localizations',
    );
    await db.close();
    return localizations;
  }
}

void main() async {
  try {
    await DatabaseExporter.exportToWebFormat();
  } catch (e) {
    print('导出失败: $e');
  }
}
