import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import '../models/map_item.dart';
import '../models/map_item_summary.dart';
import 'database_path_service.dart';

/// 地图数据库服务
class MapDatabaseService {
  static final MapDatabaseService _instance = MapDatabaseService._internal();
  factory MapDatabaseService() => _instance;
  MapDatabaseService._internal();

  Database? _database;
  static const String _databaseName = 'maps.db';
  static const String _tableName = 'maps';
  static const String _metaTableName = 'database_meta';
  static const int _currentDbVersion = 1;

  /// 获取数据库实例
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final String path = await DatabasePathService().getDatabasePath(
      _databaseName,
    );
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 创建地图表（只存储图片数据，不存储路径）
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        image_data BLOB NOT NULL,
        version INTEGER NOT NULL DEFAULT 1,
        layers TEXT DEFAULT '[]',
        legend_groups TEXT DEFAULT '[]',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建元数据表
    await db.execute('''
      CREATE TABLE $_metaTableName (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // 设置初始数据库版本
    await db.insert(_metaTableName, {
      'key': 'db_version',
      'value': _currentDbVersion.toString(),
    });
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 暂时不需要升级逻辑
  }

  /// 获取数据库版本
  Future<int> getDatabaseVersion() async {
    final db = await database;
    final result = await db.query(
      _metaTableName,
      where: 'key = ?',
      whereArgs: ['db_version'],
    );

    if (result.isNotEmpty) {
      return int.parse(result.first['value'] as String);
    }
    return _currentDbVersion;
  }

  /// 设置数据库版本
  Future<void> setDatabaseVersion(int version) async {
    final db = await database;
    await db.insert(_metaTableName, {
      'key': 'db_version',
      'value': version.toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 添加地图 (检查标题重复)
  Future<int> insertMap(MapItem map) async {
    final db = await database;

    // 检查是否已存在相同标题的地图
    final existing = await getMapByTitle(map.title);
    if (existing != null) {
      // 如果新地图版本更高，则更新现有地图
      if (map.version > existing.version) {
        await updateMap(map.copyWith(id: existing.id));
        return existing.id!;
      } else {
        // 否则不插入，返回现有地图的ID
        return existing.id!;
      }
    }

    // 不存在重复标题，直接插入
    return await db.insert(_tableName, map.toDatabase());
  }

  /// 强制添加地图 (忽略标题重复检查)
  Future<int> forceInsertMap(MapItem map) async {
    final db = await database;
    return await db.insert(_tableName, map.toDatabase());
  }

  /// 获取所有地图
  Future<List<MapItem>> getAllMaps() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return maps.map((map) => MapItem.fromDatabase(map)).toList();
  }

  /// 获取所有地图摘要（轻量级加载，不包含图层和图例组数据）
  /// 用于地图册页面的快速加载
  Future<List<MapItemSummary>> getAllMapsSummary() async {
    final db = await database;
    // 只查询基本字段，不包含 layers 和 legend_groups 等重量级数据
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      columns: [
        'id',
        'title',
        'image_data',
        'version',
        'created_at',
        'updated_at',
      ],
    );
    return maps.map((map) => MapItemSummary.fromDatabase(map)).toList();
  }

  /// 根据ID获取地图
  Future<MapItem?> getMapById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MapItem.fromDatabase(maps.first);
    }
    return null;
  }

  /// 更新地图
  Future<void> updateMap(MapItem map) async {
    try {
      debugPrint('MapDatabaseService.updateMap 开始执行');
      debugPrint('- 地图ID: ${map.id}');
      debugPrint('- 地图标题: ${map.title}');

      final db = await database;
      debugPrint('数据库连接成功');

      final databaseData = map.toDatabase();
      debugPrint('数据序列化完成，字段: ${databaseData.keys.toList()}');

      // 检查图层数据序列化
      if (map.layers.isNotEmpty) {
        try {
          final layersJson = json.encode(
            map.layers.map((e) => e.toJson()).toList(),
          );
          debugPrint('图层数据序列化成功，长度: ${layersJson.length}');
        } catch (e) {
          debugPrint('图层数据序列化失败: $e');
          throw Exception('图层数据序列化失败: $e');
        }
      }

      // 检查图例组数据序列化
      if (map.legendGroups.isNotEmpty) {
        try {
          final legendGroupsJson = json.encode(
            map.legendGroups.map((e) => e.toJson()).toList(),
          );
          debugPrint('图例组数据序列化成功，长度: ${legendGroupsJson.length}');
        } catch (e) {
          debugPrint('图例组数据序列化失败: $e');
          throw Exception('图例组数据序列化失败: $e');
        }
      }

      final updateResult = await db.update(
        _tableName,
        databaseData,
        where: 'id = ?',
        whereArgs: [map.id],
      );

      debugPrint('数据库更新完成，影响行数: $updateResult');

      if (updateResult == 0) {
        throw Exception('没有找到要更新的地图记录，ID: ${map.id}');
      }
    } catch (e, stackTrace) {
      debugPrint('MapDatabaseService.updateMap 错误:');
      debugPrint('错误: $e');
      debugPrint('堆栈: $stackTrace');
      rethrow;
    }
  }

  /// 删除地图
  Future<void> deleteMap(int id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// 根据标题查找地图
  Future<MapItem?> getMapByTitle(String title) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'title = ?',
      whereArgs: [title],
    );

    if (maps.isNotEmpty) {
      return MapItem.fromDatabase(maps.first);
    }
    return null;
  }

  /// 清空所有地图数据
  Future<void> clearAllMaps() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// 导出数据库到文件 (包含完整图像数据)
  Future<String?> exportDatabase({int? customVersion}) async {
    try {
      // 获取所有地图，确保包含图像数据
      final maps = await getAllMaps();
      final dbVersion = customVersion ?? await getDatabaseVersion();

      final mapDatabase = MapDatabase(
        version: dbVersion,
        maps: maps,
        exportedAt: DateTime.now(),
      );

      // 选择保存位置
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: '保存地图数据库',
        fileName:
            'maps_v${dbVersion}_${DateTime.now().millisecondsSinceEpoch}.db',
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        final jsonData = jsonEncode(mapDatabase.toJson());
        await file.writeAsString(jsonData);

        debugPrint(
          '数据库导出成功: $outputFile (版本: $dbVersion, 地图数量: ${maps.length})',
        );
        return outputFile;
      }
    } catch (e) {
      debugPrint('导出数据库失败: $e');
    }
    return null;
  }

  /// 导入数据库文件 (调试模式)
  Future<bool> importDatabaseDebug() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonData = await file.readAsString();
        final mapDatabase = MapDatabase.fromJson(jsonDecode(jsonData));

        // 调试模式：合并数据，标题唯一，高版本覆盖
        for (final importedMap in mapDatabase.maps) {
          final existingMap = await getMapByTitle(importedMap.title);

          if (existingMap != null) {
            // 如果导入的版本更高，则覆盖
            if (importedMap.version > existingMap.version) {
              await updateMap(importedMap.copyWith(id: existingMap.id));
              debugPrint(
                '更新地图: ${importedMap.title} (版本 ${existingMap.version} -> ${importedMap.version})',
              );
            } else {
              debugPrint(
                '跳过地图: ${importedMap.title} (当前版本 ${existingMap.version} >= 导入版本 ${importedMap.version})',
              );
            }
          } else {
            // 不存在则直接添加
            await forceInsertMap(importedMap.copyWith(id: null));
            debugPrint(
              '添加新地图: ${importedMap.title} (版本 ${importedMap.version})',
            );
          }
        }

        return true;
      }
    } catch (e) {
      debugPrint('导入数据库失败: $e');
    }
    return false;
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
