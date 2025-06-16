import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/user_preferences.dart';

/// 用户偏好设置数据库服务
/// 使用SQLite数据库替代SharedPreferences以提升性能
class UserPreferencesDatabaseService {
  static final UserPreferencesDatabaseService _instance =
      UserPreferencesDatabaseService._internal();
  factory UserPreferencesDatabaseService() => _instance;
  UserPreferencesDatabaseService._internal();

  static const String _databaseName = 'user_preferences.db';
  static const String _preferencesTable = 'user_preferences';
  static const String _metadataTable = 'preferences_metadata';
  static const int _databaseVersion = 1;

  Database? _database;

  /// 获取数据库实例
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 用户偏好设置表
    await db.execute('''
      CREATE TABLE $_preferencesTable (
        user_id TEXT PRIMARY KEY,
        display_name TEXT NOT NULL,
        avatar_path TEXT,
        avatar_data BLOB,
        theme_data TEXT NOT NULL,
        map_editor_data TEXT NOT NULL,
        layout_data TEXT NOT NULL,
        tools_data TEXT NOT NULL,
        locale TEXT NOT NULL DEFAULT 'zh_CN',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        last_login_at INTEGER
      )
    ''');

    // 元数据表
    await db.execute('''
      CREATE TABLE $_metadataTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    '''); // 插入默认元数据
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(_metadataTable, {
      'key': 'current_user_id',
      'value': '',
      'updated_at': now,
    });

    await db.insert(_metadataTable, {
      'key': 'db_version',
      'value': _databaseVersion.toString(),
      'updated_at': now,
    });

    if (kDebugMode) {
      print('用户偏好设置数据库表创建完成');
    }
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 未来版本升级逻辑
    if (kDebugMode) {
      print('用户偏好设置数据库从版本 $oldVersion 升级到 $newVersion');
    }
  }

  /// 保存用户偏好设置
  Future<void> savePreferences(UserPreferences preferences) async {
    final db = await database;

    // 确保用户ID存在
    final userId =
        preferences.userId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final updatedPreferences = preferences.copyWith(
      userId: userId,
      updatedAt: DateTime.now(),
    );

    final data = {
      'user_id': userId,
      'display_name': updatedPreferences.displayName,
      'avatar_path': updatedPreferences.avatarPath,
      'avatar_data': updatedPreferences.avatarData,
      'theme_data': jsonEncode(updatedPreferences.theme.toJson()),
      'map_editor_data': jsonEncode(updatedPreferences.mapEditor.toJson()),
      'layout_data': jsonEncode(updatedPreferences.layout.toJson()),
      'tools_data': jsonEncode(updatedPreferences.tools.toJson()),
      'locale': updatedPreferences.locale,
      'created_at': updatedPreferences.createdAt.millisecondsSinceEpoch,
      'updated_at': updatedPreferences.updatedAt.millisecondsSinceEpoch,
      'last_login_at': updatedPreferences.lastLoginAt?.millisecondsSinceEpoch,
    };

    await db.insert(
      _preferencesTable,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 更新当前用户ID
    await _setCurrentUserId(userId);

    if (kDebugMode) {
      print('用户偏好设置已保存到数据库: ${updatedPreferences.displayName}');
    }
  }

  /// 获取用户偏好设置
  Future<UserPreferences?> getPreferences(String userId) async {
    final db = await database;
    final result = await db.query(
      _preferencesTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return _preferencesFromDatabase(result.first);
  }

  /// 获取当前用户偏好设置
  Future<UserPreferences?> getCurrentPreferences() async {
    final currentUserId = await getCurrentUserId();
    if (currentUserId == null || currentUserId.isEmpty) {
      return null;
    }
    return await getPreferences(currentUserId);
  }

  /// 获取所有用户配置文件
  Future<List<UserPreferences>> getAllUsers() async {
    final db = await database;
    final result = await db.query(
      _preferencesTable,
      orderBy: 'last_login_at DESC, updated_at DESC',
    );

    return result.map(_preferencesFromDatabase).toList();
  }

  /// 删除用户配置
  Future<void> deleteUser(String userId) async {
    final db = await database;
    await db.delete(
      _preferencesTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // 如果删除的是当前用户，清除当前用户ID
    final currentUserId = await getCurrentUserId();
    if (currentUserId == userId) {
      await _setCurrentUserId('');
    }

    if (kDebugMode) {
      print('用户配置已删除: $userId');
    }
  }

  /// 设置当前用户ID
  Future<void> _setCurrentUserId(String userId) async {
    final db = await database;
    await db.update(
      _metadataTable,
      {'value': userId, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'key = ?',
      whereArgs: ['current_user_id'],
    );
  }

  /// 获取当前用户ID
  Future<String?> getCurrentUserId() async {
    final db = await database;
    final result = await db.query(
      _metadataTable,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['current_user_id'],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    final value = result.first['value'] as String;
    return value.isEmpty ? null : value;
  }

  /// 设置当前用户
  Future<void> setCurrentUser(String userId) async {
    await _setCurrentUserId(userId);

    // 更新最后登录时间
    final db = await database;
    await db.update(
      _preferencesTable,
      {'last_login_at': DateTime.now().millisecondsSinceEpoch},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// 检查用户是否存在
  Future<bool> userExists(String userId) async {
    final db = await database;
    final result = await db.query(
      _preferencesTable,
      columns: ['user_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// 清除所有数据
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_preferencesTable);
    await _setCurrentUserId('');

    if (kDebugMode) {
      print('所有用户偏好设置数据已清除');
    }
  }

  /// 获取数据库统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    final db = await database;

    // 获取用户数量
    final userCountResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_preferencesTable',
    );
    final userCount = userCountResult.first['count'] as int;

    // 获取数据库文件大小（近似）
    final sizeResult = await db.rawQuery(
      'SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()',
    );
    final dbSize = sizeResult.first['size'] as int;

    // 获取当前用户ID
    final currentUserId = await getCurrentUserId();

    return {
      'userCount': userCount,
      'databaseSize': dbSize,
      'currentUserId': currentUserId,
      'platform': kIsWeb ? 'web' : 'native',
      'databasePath': join(await getDatabasesPath(), _databaseName),
    };
  }

  /// 从数据库记录转换为UserPreferences对象
  UserPreferences _preferencesFromDatabase(Map<String, dynamic> row) {
    return UserPreferences(
      userId: row['user_id'] as String,
      displayName: row['display_name'] as String,
      avatarPath: row['avatar_path'] as String?,
      avatarData: row['avatar_data'] as Uint8List?,
      theme: ThemePreferences.fromJson(
        jsonDecode(row['theme_data'] as String) as Map<String, dynamic>,
      ),
      mapEditor: MapEditorPreferences.fromJson(
        jsonDecode(row['map_editor_data'] as String) as Map<String, dynamic>,
      ),
      layout: LayoutPreferences.fromJson(
        jsonDecode(row['layout_data'] as String) as Map<String, dynamic>,
      ),
      tools: ToolPreferences.fromJson(
        jsonDecode(row['tools_data'] as String) as Map<String, dynamic>,
      ),
      locale: row['locale'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
      lastLoginAt: row['last_login_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['last_login_at'] as int)
          : null,
    );
  }

  /// 关闭数据库连接
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
