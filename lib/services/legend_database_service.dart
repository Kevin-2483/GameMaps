import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/legend_item.dart';

class LegendDatabaseService {
  static Database? _database;
  static const String _databaseName = 'legends.db';
  static const String _tableName = 'legends';
  static const String _metaTableName = 'legend_meta';
  static const int _databaseVersion = 1;
  static const int _currentDbVersion = 1;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  /// 数据库打开时的检查和修复
  Future<void> _onOpen(Database db) async {
    // 检查元数据表是否存在，如果不存在则创建
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$_metaTableName'",
    );

    if (result.isEmpty) {
      debugPrint('元数据表不存在，正在创建...');
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
      debugPrint('元数据表创建完成');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        image_data BLOB,
        center_x REAL NOT NULL,
        center_y REAL NOT NULL,
        version INTEGER NOT NULL DEFAULT 1,
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 未来版本升级逻辑
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

  /// 添加图例 (检查标题重复)
  Future<int> insertLegend(LegendItem legend) async {
    final db = await database;

    // 检查是否已存在相同标题的图例
    final existing = await getLegendByTitle(legend.title);
    if (existing != null) {
      // 如果新图例版本更高，则更新现有图例
      if (legend.version > existing.version) {
        await updateLegend(legend.copyWith(id: existing.id));
        return existing.id!;
      } else {
        // 否则不插入，返回现有图例的ID
        return existing.id!;
      }
    }

    // 不存在重复标题，直接插入
    return await db.insert(_tableName, legend.toDatabase());
  }

  /// 强制添加图例 (忽略标题重复检查)
  Future<int> forceInsertLegend(LegendItem legend) async {
    final db = await database;
    return await db.insert(_tableName, legend.toDatabase());
  }

  /// 获取所有图例
  Future<List<LegendItem>> getAllLegends() async {
    final db = await database;
    final List<Map<String, dynamic>> legends = await db.query(_tableName);
    return legends.map((legend) => LegendItem.fromDatabase(legend)).toList();
  }

  /// 根据ID获取图例
  Future<LegendItem?> getLegendById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> legends = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (legends.isNotEmpty) {
      return LegendItem.fromDatabase(legends.first);
    }
    return null;
  }

  /// 更新图例
  Future<void> updateLegend(LegendItem legend) async {
    final db = await database;
    await db.update(
      _tableName,
      legend.toDatabase(),
      where: 'id = ?',
      whereArgs: [legend.id],
    );
  }

  /// 删除图例
  Future<void> deleteLegend(int id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// 根据标题查找图例
  Future<LegendItem?> getLegendByTitle(String title) async {
    final db = await database;
    final List<Map<String, dynamic>> legends = await db.query(
      _tableName,
      where: 'title = ?',
      whereArgs: [title],
    );

    if (legends.isNotEmpty) {
      return LegendItem.fromDatabase(legends.first);
    }
    return null;
  }

  /// 清空所有图例数据
  Future<void> clearAllLegends() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// 导出数据库到文件 (包含完整图像数据)
  Future<String?> exportDatabase({int? customVersion}) async {
    try {
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
            'legends_v${dbVersion}_${DateTime.now().millisecondsSinceEpoch}.json',
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

  /// 关闭数据库连接
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
