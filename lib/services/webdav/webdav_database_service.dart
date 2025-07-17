import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/webdav_config.dart';
import '../database_path_service.dart';

/// WebDAV数据库服务
/// 管理WebDAV配置和认证账户的数据库操作
class WebDavDatabaseService {
  static final WebDavDatabaseService _instance = WebDavDatabaseService._internal();
  factory WebDavDatabaseService() => _instance;
  WebDavDatabaseService._internal();

  /// 初始化数据库服务
  Future<void> initialize() async {
    await _initDatabase();
    if (kDebugMode) {
      debugPrint('WebDAV数据库服务初始化完成');
    }
  }

  static const String _databaseName = 'webdav.db';
  static const String _configsTable = 'webdav_configs';
  static const String _authAccountsTable = 'webdav_auth_accounts';
  static const int _databaseVersion = 1;

  Database? _database;

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
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // WebDAV配置表
    await db.execute('''
      CREATE TABLE $_configsTable (
        config_id TEXT PRIMARY KEY,
        display_name TEXT NOT NULL,
        server_url TEXT NOT NULL,
        storage_path TEXT NOT NULL,
        auth_account_id TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (auth_account_id) REFERENCES $_authAccountsTable (auth_account_id)
      )
    ''');

    // WebDAV认证账户表
    await db.execute('''
      CREATE TABLE $_authAccountsTable (
        auth_account_id TEXT PRIMARY KEY,
        display_name TEXT NOT NULL,
        username TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX idx_webdav_configs_auth_account ON $_configsTable (auth_account_id)');
    await db.execute('CREATE INDEX idx_webdav_configs_enabled ON $_configsTable (is_enabled)');
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 暂时不需要升级逻辑
  }

  // ==================== 认证账户管理 ====================

  /// 创建认证账户
  Future<void> createAuthAccount(WebDavAuthAccount account) async {
    final db = await database;
    await db.insert(
      _authAccountsTable,
      {
        'auth_account_id': account.authAccountId,
        'display_name': account.displayName,
        'username': account.username,
        'created_at': account.createdAt.millisecondsSinceEpoch,
        'updated_at': account.updatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (kDebugMode) {
      debugPrint('WebDAV认证账户已创建: ${account.authAccountId}');
    }
  }

  /// 获取所有认证账户
  Future<List<WebDavAuthAccount>> getAllAuthAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _authAccountsTable,
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _authAccountFromDatabase(map)).toList();
  }

  /// 根据ID获取认证账户
  Future<WebDavAuthAccount?> getAuthAccountById(String authAccountId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _authAccountsTable,
      where: 'auth_account_id = ?',
      whereArgs: [authAccountId],
    );

    if (maps.isNotEmpty) {
      return _authAccountFromDatabase(maps.first);
    }
    return null;
  }

  /// 更新认证账户
  Future<void> updateAuthAccount(WebDavAuthAccount account) async {
    final db = await database;
    await db.update(
      _authAccountsTable,
      {
        'display_name': account.displayName,
        'username': account.username,
        'updated_at': account.updatedAt.millisecondsSinceEpoch,
      },
      where: 'auth_account_id = ?',
      whereArgs: [account.authAccountId],
    );

    if (kDebugMode) {
      debugPrint('WebDAV认证账户已更新: ${account.authAccountId}');
    }
  }

  /// 删除认证账户
  Future<void> deleteAuthAccount(String authAccountId) async {
    final db = await database;
    
    // 检查是否有配置使用此认证账户
    final configs = await getConfigsByAuthAccount(authAccountId);
    if (configs.isNotEmpty) {
      throw Exception('无法删除认证账户，仍有 ${configs.length} 个配置在使用此账户');
    }

    await db.delete(
      _authAccountsTable,
      where: 'auth_account_id = ?',
      whereArgs: [authAccountId],
    );

    if (kDebugMode) {
      debugPrint('WebDAV认证账户已删除: $authAccountId');
    }
  }

  // ==================== 配置管理 ====================

  /// 创建WebDAV配置
  Future<void> createConfig(WebDavConfig config) async {
    final db = await database;
    await db.insert(
      _configsTable,
      {
        'config_id': config.configId,
        'display_name': config.displayName,
        'server_url': config.serverUrl,
        'storage_path': config.storagePath,
        'auth_account_id': config.authAccountId,
        'is_enabled': config.isEnabled ? 1 : 0,
        'created_at': config.createdAt.millisecondsSinceEpoch,
        'updated_at': config.updatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (kDebugMode) {
      debugPrint('WebDAV配置已创建: ${config.configId}');
    }
  }

  /// 获取所有配置
  Future<List<WebDavConfig>> getAllConfigs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _configsTable,
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _configFromDatabase(map)).toList();
  }

  /// 获取启用的配置
  Future<List<WebDavConfig>> getEnabledConfigs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _configsTable,
      where: 'is_enabled = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _configFromDatabase(map)).toList();
  }

  /// 根据ID获取配置
  Future<WebDavConfig?> getConfigById(String configId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _configsTable,
      where: 'config_id = ?',
      whereArgs: [configId],
    );

    if (maps.isNotEmpty) {
      return _configFromDatabase(maps.first);
    }
    return null;
  }

  /// 根据认证账户获取配置
  Future<List<WebDavConfig>> getConfigsByAuthAccount(String authAccountId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _configsTable,
      where: 'auth_account_id = ?',
      whereArgs: [authAccountId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _configFromDatabase(map)).toList();
  }

  /// 更新配置
  Future<void> updateConfig(WebDavConfig config) async {
    final db = await database;
    await db.update(
      _configsTable,
      {
        'display_name': config.displayName,
        'server_url': config.serverUrl,
        'storage_path': config.storagePath,
        'auth_account_id': config.authAccountId,
        'is_enabled': config.isEnabled ? 1 : 0,
        'updated_at': config.updatedAt.millisecondsSinceEpoch,
      },
      where: 'config_id = ?',
      whereArgs: [config.configId],
    );

    if (kDebugMode) {
      debugPrint('WebDAV配置已更新: ${config.configId}');
    }
  }

  /// 删除配置
  Future<void> deleteConfig(String configId) async {
    final db = await database;
    await db.delete(
      _configsTable,
      where: 'config_id = ?',
      whereArgs: [configId],
    );

    if (kDebugMode) {
      debugPrint('WebDAV配置已删除: $configId');
    }
  }

  /// 切换配置启用状态
  Future<void> toggleConfigEnabled(String configId) async {
    final config = await getConfigById(configId);
    if (config != null) {
      final updatedConfig = config.copyWith(
        isEnabled: !config.isEnabled,
        updatedAt: DateTime.now(),
      );
      await updateConfig(updatedConfig);
    }
  }

  // ==================== 统计信息 ====================

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    final db = await database;
    
    final configCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_configsTable'),
    ) ?? 0;
    
    final enabledConfigCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_configsTable WHERE is_enabled = 1'),
    ) ?? 0;
    
    final authAccountCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_authAccountsTable'),
    ) ?? 0;

    return {
      'total_configs': configCount,
      'enabled_configs': enabledConfigCount,
      'auth_accounts': authAccountCount,
    };
  }

  // ==================== 私有辅助方法 ====================

  /// 从数据库记录创建配置对象
  WebDavConfig _configFromDatabase(Map<String, dynamic> data) {
    return WebDavConfig(
      configId: data['config_id'] as String,
      displayName: data['display_name'] as String,
      serverUrl: data['server_url'] as String,
      storagePath: data['storage_path'] as String,
      authAccountId: data['auth_account_id'] as String,
      isEnabled: (data['is_enabled'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updated_at'] as int),
    );
  }

  /// 从数据库记录创建认证账户对象
  WebDavAuthAccount _authAccountFromDatabase(Map<String, dynamic> data) {
    return WebDavAuthAccount(
      authAccountId: data['auth_account_id'] as String,
      displayName: data['display_name'] as String,
      username: data['username'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updated_at'] as int),
    );
  }
}