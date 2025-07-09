import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import '../models/map_localization.dart';
import 'database_path_service.dart';

/// 地图本地化服务
class MapLocalizationService {
  static final MapLocalizationService _instance =
      MapLocalizationService._internal();
  factory MapLocalizationService() => _instance;
  MapLocalizationService._internal();

  Database? _database;
  static const String _databaseName = 'map_localizations.db';
  static const String _tableName = 'map_localizations';
  static const String _metaTableName = 'localization_meta';
  static const int _currentDbVersion = 1;

  MapLocalizationDatabase? _cachedDatabase;

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
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  /// 创建数据表
  Future<void> _createTables(Database db, int version) async {
    // 本地化数据表
    await db.execute('''
      CREATE TABLE $_tableName (
        map_key TEXT NOT NULL,
        language_code TEXT NOT NULL,
        translation TEXT NOT NULL,
        PRIMARY KEY (map_key, language_code)
      )
    ''');

    // 元数据表
    await db.execute('''
      CREATE TABLE $_metaTableName (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // 设置初始版本
    await db.insert(_metaTableName, {'key': 'version', 'value': '0'});

    await db.insert(_metaTableName, {
      'key': 'updated_at',
      'value': DateTime.now().toIso8601String(),
    });
  }

  /// 获取当前本地化数据库版本
  Future<int> getCurrentVersion() async {
    final db = await database;
    final result = await db.query(
      _metaTableName,
      where: 'key = ?',
      whereArgs: ['version'],
    );

    if (result.isNotEmpty) {
      return int.tryParse(result.first['value'] as String) ?? 0;
    }
    return 0;
  }

  /// 更新版本信息
  Future<void> _updateVersion(int version) async {
    final db = await database;
    await db.update(
      _metaTableName,
      {'value': version.toString()},
      where: 'key = ?',
      whereArgs: ['version'],
    );

    await db.update(
      _metaTableName,
      {'value': DateTime.now().toIso8601String()},
      where: 'key = ?',
      whereArgs: ['updated_at'],
    );
  }

  /// 导入本地化文件
  Future<bool> importLocalizationFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null) {
        String jsonString;
        if (kIsWeb) {
          // Web平台使用bytes
          final bytes = result.files.single.bytes!;
          jsonString = utf8.decode(bytes);
        } else {
          // 桌面平台使用path
          final file = File(result.files.single.path!);
          jsonString = await file.readAsString();
        }
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

        final localizationDb = MapLocalizationDatabase.fromJson(jsonData);

        // 检查版本
        final currentVersion = await getCurrentVersion();
        if (localizationDb.version <= currentVersion) {
          debugPrint(
            '本地化文件版本 ${localizationDb.version} 不高于当前版本 $currentVersion，跳过导入',
          );
          return false;
        }

        // 导入数据
        await _importLocalizationDatabase(localizationDb);
        return true;
      }
    } catch (e) {
      debugPrint('导入本地化文件失败: $e');
      rethrow;
    }
    return false;
  }

  /// 导入本地化数据库
  Future<void> _importLocalizationDatabase(
    MapLocalizationDatabase localizationDb,
  ) async {
    final db = await database;

    await db.transaction((txn) async {
      // 清空现有数据
      await txn.delete(_tableName);

      // 插入新数据
      for (final mapLoc in localizationDb.maps.values) {
        for (final entry in mapLoc.translations.entries) {
          await txn.insert(_tableName, {
            'map_key': mapLoc.mapKey,
            'language_code': entry.key,
            'translation': entry.value,
          });
        }
      }

      // 更新版本信息
      await txn.update(
        _metaTableName,
        {'value': localizationDb.version.toString()},
        where: 'key = ?',
        whereArgs: ['version'],
      );

      await txn.update(
        _metaTableName,
        {'value': localizationDb.updatedAt.toIso8601String()},
        where: 'key = ?',
        whereArgs: ['updated_at'],
      );
    });

    // 清除缓存
    _cachedDatabase = null;
  }

  /// 获取地图翻译
  Future<String?> getMapTranslation(String mapKey, String languageCode) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: 'map_key = ? AND language_code = ?',
      whereArgs: [mapKey, languageCode],
    );

    if (result.isNotEmpty) {
      return result.first['translation'] as String;
    }
    return null;
  }

  /// 获取本地化的地图标题
  /// 如果找不到翻译，返回原始标题
  Future<String> getLocalizedMapTitle(
    String originalTitle,
    String languageCode,
  ) async {
    // 尝试获取翻译
    final translation = await getMapTranslation(originalTitle, languageCode);
    return translation ?? originalTitle;
  }

  /// 获取所有本地化数据
  Future<MapLocalizationDatabase> getAllLocalizations() async {
    if (_cachedDatabase != null) {
      return _cachedDatabase!;
    }

    final db = await database;

    // 获取版本信息
    final versionResult = await db.query(
      _metaTableName,
      where: 'key = ?',
      whereArgs: ['version'],
    );
    final version = versionResult.isNotEmpty
        ? int.tryParse(versionResult.first['value'] as String) ?? 0
        : 0;

    // 获取更新时间
    final updatedAtResult = await db.query(
      _metaTableName,
      where: 'key = ?',
      whereArgs: ['updated_at'],
    );
    final updatedAt = updatedAtResult.isNotEmpty
        ? DateTime.tryParse(updatedAtResult.first['value'] as String) ??
              DateTime.now()
        : DateTime.now();

    // 获取所有翻译数据
    final translations = await db.query(_tableName);

    final Map<String, MapLocalization> maps = {};

    for (final row in translations) {
      final mapKey = row['map_key'] as String;
      final languageCode = row['language_code'] as String;
      final translation = row['translation'] as String;

      if (!maps.containsKey(mapKey)) {
        maps[mapKey] = MapLocalization(mapKey: mapKey, translations: {});
      }

      maps[mapKey] = MapLocalization(
        mapKey: mapKey,
        translations: {
          ...maps[mapKey]!.translations,
          languageCode: translation,
        },
      );
    }

    _cachedDatabase = MapLocalizationDatabase(
      version: version,
      maps: maps,
      updatedAt: updatedAt,
    );

    return _cachedDatabase!;
  }

  /// 检查是否有本地化数据
  Future<bool> hasLocalizationData() async {
    final db = await database;
    final result = await db.query(_tableName, limit: 1);
    return result.isNotEmpty;
  }

  /// 获取支持的语言列表
  Future<List<String>> getSupportedLanguages() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT language_code FROM $_tableName ORDER BY language_code',
    );
    return result.map((row) => row['language_code'] as String).toList();
  }

  /// 获取特定地图支持的语言
  Future<List<String>> getMapSupportedLanguages(String mapKey) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      columns: ['language_code'],
      where: 'map_key = ?',
      whereArgs: [mapKey],
      orderBy: 'language_code',
    );
    return result.map((row) => row['language_code'] as String).toList();
  }

  /// 清空所有本地化数据
  Future<void> clearAllLocalizations() async {
    final db = await database;
    await db.delete(_tableName);
    await _updateVersion(0);
    _cachedDatabase = null;
  }

  /// 导出本地化数据库
  Future<String?> exportLocalizationDatabase() async {
    try {
      final localizationDb = await getAllLocalizations();
      final jsonString = jsonEncode(localizationDb.toJson());

      // 选择保存位置
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: '导出地图本地化文件',
        fileName: 'map_localizations_v${localizationDb.version}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
        return outputFile;
      }
    } catch (e) {
      debugPrint('导出本地化数据库失败: $e');
      rethrow;
    }
    return null;
  }

  /// 关闭数据库连接
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    _cachedDatabase = null;
  }
}
