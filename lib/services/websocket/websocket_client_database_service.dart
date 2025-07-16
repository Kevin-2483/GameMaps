import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/websocket_client_config.dart';
import '../database_path_service.dart';

/// WebSocket 客户端配置数据库服务
/// 管理多个 WebSocket 客户端身份配置
class WebSocketClientDatabaseService {
  static final WebSocketClientDatabaseService _instance =
      WebSocketClientDatabaseService._internal();
  factory WebSocketClientDatabaseService() => _instance;
  WebSocketClientDatabaseService._internal();

  /// 初始化数据库服务
  Future<void> initialize() async {
    await _initDatabase();
    if (kDebugMode) {
      debugPrint('WebSocket 客户端数据库服务初始化完成');
    }
  }

  static const String _databaseName = 'websocket_clients.db';
  static const String _clientsTable = 'websocket_clients';
  static const String _metadataTable = 'clients_metadata';
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
    // WebSocket 客户端配置表
    await db.execute('''
      CREATE TABLE $_clientsTable (
        client_id TEXT PRIMARY KEY,
        display_name TEXT NOT NULL,
        server_host TEXT NOT NULL,
        server_port INTEGER NOT NULL,
        websocket_path TEXT NOT NULL,
        ping_interval INTEGER NOT NULL,
        reconnect_delay INTEGER NOT NULL,
        public_key TEXT NOT NULL,
        private_key_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        last_connected_at INTEGER,
        is_active INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 元数据表
    await db.execute('''
      CREATE TABLE $_metadataTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 插入默认元数据
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(_metadataTable, {
      'key': 'active_client_id',
      'value': '',
      'updated_at': now,
    });

    await db.insert(_metadataTable, {
      'key': 'db_version',
      'value': _databaseVersion.toString(),
      'updated_at': now,
    });

    if (kDebugMode) {
      debugPrint('WebSocket 客户端配置数据库表创建完成');
    }
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      debugPrint('WebSocket 客户端配置数据库从版本 $oldVersion 升级到 $newVersion');
    }
  }

  /// 保存客户端配置
  Future<void> saveClientConfig(WebSocketClientConfig config) async {
    final db = await database;

    final data = {
      'client_id': config.clientId,
      'display_name': config.displayName,
      'server_host': config.server.host,
      'server_port': config.server.port,
      'websocket_path': config.webSocket.path,
      'ping_interval': config.webSocket.pingInterval,
      'reconnect_delay': config.webSocket.reconnectDelay,
      'public_key': config.keys.publicKey,
      'private_key_id': config.keys.privateKeyId,
      'created_at': config.createdAt.millisecondsSinceEpoch,
      'updated_at': config.updatedAt.millisecondsSinceEpoch,
      'last_connected_at': config.lastConnectedAt?.millisecondsSinceEpoch,
      'is_active': config.isActive ? 1 : 0,
    };

    await db.insert(
      _clientsTable,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 如果这是活跃配置，更新元数据
    if (config.isActive) {
      await _setActiveClientId(config.clientId);
    }

    if (kDebugMode) {
      debugPrint('WebSocket 客户端配置已保存: ${config.displayName}');
    }
  }

  /// 获取客户端配置
  Future<WebSocketClientConfig?> getClientConfig(String clientId) async {
    final db = await database;
    final result = await db.query(
      _clientsTable,
      where: 'client_id = ?',
      whereArgs: [clientId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return _configFromDatabase(result.first);
  }

  /// 获取当前活跃的客户端配置
  Future<WebSocketClientConfig?> getActiveClientConfig() async {
    final activeClientId = await getActiveClientId();
    if (activeClientId == null || activeClientId.isEmpty) {
      return null;
    }
    return await getClientConfig(activeClientId);
  }

  /// 获取所有客户端配置
  Future<List<WebSocketClientConfig>> getAllClientConfigs() async {
    final db = await database;
    final result = await db.query(
      _clientsTable,
      orderBy: 'last_connected_at DESC, updated_at DESC',
    );

    return result.map(_configFromDatabase).toList();
  }

  /// 删除客户端配置
  Future<void> deleteClientConfig(String clientId) async {
    final db = await database;
    await db.delete(
      _clientsTable,
      where: 'client_id = ?',
      whereArgs: [clientId],
    );

    // 如果删除的是当前活跃配置，清除活跃配置ID
    final activeClientId = await getActiveClientId();
    if (activeClientId == clientId) {
      await _setActiveClientId('');
    }

    if (kDebugMode) {
      debugPrint('WebSocket 客户端配置已删除: $clientId');
    }
  }

  /// 设置活跃的客户端配置
  Future<void> setActiveClientConfig(String clientId) async {
    final db = await database;
    
    // 首先将所有配置设为非活跃
    await db.update(
      _clientsTable,
      {'is_active': 0},
    );
    
    // 设置指定配置为活跃
    await db.update(
      _clientsTable,
      {'is_active': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'client_id = ?',
      whereArgs: [clientId],
    );
    
    // 更新元数据
    await _setActiveClientId(clientId);
    
    if (kDebugMode) {
      debugPrint('活跃 WebSocket 客户端配置已设置: $clientId');
    }
  }

  /// 更新最后连接时间
  Future<void> updateLastConnectedTime(String clientId) async {
    final db = await database;
    await db.update(
      _clientsTable,
      {
        'last_connected_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'client_id = ?',
      whereArgs: [clientId],
    );
  }

  /// 获取活跃客户端ID
  Future<String?> getActiveClientId() async {
    final db = await database;
    final result = await db.query(
      _metadataTable,
      where: 'key = ?',
      whereArgs: ['active_client_id'],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first['value'] as String?;
  }

  /// 设置活跃客户端ID
  Future<void> _setActiveClientId(String clientId) async {
    final db = await database;
    await db.update(
      _metadataTable,
      {
        'value': clientId,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'key = ?',
      whereArgs: ['active_client_id'],
    );
  }

  /// 从数据库记录创建配置对象
  WebSocketClientConfig _configFromDatabase(Map<String, dynamic> data) {
    return WebSocketClientConfig(
      clientId: data['client_id'] as String,
      displayName: data['display_name'] as String,
      server: ServerConfig(
        host: data['server_host'] as String,
        port: data['server_port'] as int,
      ),
      webSocket: WebSocketConfig(
        path: data['websocket_path'] as String,
        pingInterval: data['ping_interval'] as int,
        reconnectDelay: data['reconnect_delay'] as int,
      ),
      keys: ClientKeyConfig(
        publicKey: data['public_key'] as String,
        privateKeyId: data['private_key_id'] as String,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updated_at'] as int),
      lastConnectedAt: data['last_connected_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['last_connected_at'] as int)
          : null,
      isActive: (data['is_active'] as int) == 1,
    );
  }

  /// 获取存储使用情况统计
  Future<Map<String, dynamic>> getStorageStats() async {
    final db = await database;
    final clientCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_clientsTable'),
    );

    return {
      'client_count': clientCount ?? 0,
      'database_path': db.path,
      'database_version': _databaseVersion,
    };
  }

  /// 关闭数据库连接
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}