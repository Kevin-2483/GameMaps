import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/websocket_client_config.dart';
import 'websocket_client_init_service.dart';
import 'websocket_client_service.dart';
import 'websocket_client_database_service.dart';
import 'websocket_secure_storage_service.dart';

/// WebSocket 客户端管理器
/// 提供统一的接口来管理多个客户端身份和连接
class WebSocketClientManager {
  static final WebSocketClientManager _instance =
      WebSocketClientManager._internal();
  factory WebSocketClientManager() => _instance;
  WebSocketClientManager._internal();

  final WebSocketClientInitService _initService = WebSocketClientInitService();
  final WebSocketClientService _clientService = WebSocketClientService();
  final WebSocketClientDatabaseService _dbService =
      WebSocketClientDatabaseService();
  final WebSocketSecureStorageService _secureStorage =
      WebSocketSecureStorageService();

  bool _isInitialized = false;

  // 流控制器
  final StreamController<List<WebSocketClientConfig>> _configsController =
      StreamController<List<WebSocketClientConfig>>.broadcast();
  final StreamController<WebSocketClientConfig?> _activeConfigController =
      StreamController<WebSocketClientConfig?>.broadcast();

  // Getters
  bool get isInitialized => _isInitialized;
  Stream<List<WebSocketClientConfig>> get configsStream => _configsController.stream;
  Stream<WebSocketClientConfig?> get activeConfigStream => _activeConfigController.stream;
  Stream<WebSocketConnectionState> get connectionStateStream => _clientService.stateStream;
  Stream<WebSocketMessage> get messageStream => _clientService.messageStream;
  Stream<String> get errorStream => _clientService.errorStream;
  Stream<int> get pingDelayStream => _clientService.pingDelayStream;
  WebSocketConnectionState get connectionState => _clientService.connectionState;
  bool get isConnected => _clientService.isConnected;
  int get currentPingDelay => _clientService.currentPingDelay;

  /// 初始化管理器
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kDebugMode) {
        debugPrint('初始化 WebSocket 客户端管理器');
      }

      // 初始化数据库服务
      await _dbService.initialize();
      
      // 初始化安全存储服务
      await _secureStorage.initialize();

      // 加载配置并通知监听者
      await _refreshConfigs();
      await _refreshActiveConfig();

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('WebSocket 客户端管理器初始化完成');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WebSocket 客户端管理器初始化失败: $e');
      }
      rethrow;
    }
  }

  /// 使用 Web API Key 创建新的客户端配置
  Future<WebSocketClientConfig> createClientWithWebApiKey(
    String webApiKey,
    String displayName,
  ) async {
    _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint('使用 Web API Key 创建客户端: $displayName');
      }

      final config = await _initService.initializeWithWebApiKey(
        webApiKey,
        displayName,
      );

      await _refreshConfigs();
      
      if (kDebugMode) {
        debugPrint('客户端创建成功: ${config.clientId}');
      }

      return config;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('创建客户端失败: $e');
      }
      rethrow;
    }
  }

  /// 创建默认客户端配置
  Future<WebSocketClientConfig> createDefaultClient(
    String displayName, {
    String host = 'localhost',
    int port = 8080,
    String path = '/ws/client',
    int pingInterval = 3,
    int reconnectDelay = 5,
  }) async {
    _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint('创建默认客户端: $displayName');
      }

      final config = await _initService.createDefaultConfig(
        displayName,
        host: host,
        port: port,
        path: path,
        pingInterval: pingInterval,
        reconnectDelay: reconnectDelay,
      );

      await _refreshConfigs();
      
      if (kDebugMode) {
        debugPrint('默认客户端创建成功: ${config.clientId}');
      }

      return config;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('创建默认客户端失败: $e');
      }
      rethrow;
    }
  }

  /// 获取所有客户端配置
  Future<List<WebSocketClientConfig>> getAllConfigs() async {
    _ensureInitialized();
    return await _dbService.getAllClientConfigs();
  }

  /// 获取指定客户端配置
  Future<WebSocketClientConfig?> getConfig(String clientId) async {
    _ensureInitialized();
    return await _dbService.getClientConfig(clientId);
  }

  /// 获取活跃的客户端配置
  Future<WebSocketClientConfig?> getActiveConfig() async {
    _ensureInitialized();
    return await _dbService.getActiveClientConfig();
  }

  /// 设置活跃的客户端配置
  Future<void> setActiveConfig(String clientId) async {
    _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint('设置活跃客户端: $clientId');
      }

      await _dbService.setActiveClientConfig(clientId);
      await _refreshActiveConfig();

      if (kDebugMode) {
        debugPrint('活跃客户端设置成功: $clientId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('设置活跃客户端失败: $e');
      }
      rethrow;
    }
  }

  /// 更新客户端配置
  Future<WebSocketClientConfig> updateConfig(
    String clientId, {
    String? displayName,
    ServerConfig? server,
    WebSocketConfig? webSocket,
  }) async {
    _ensureInitialized();

    try {
      final config = await _dbService.getClientConfig(clientId);
      if (config == null) {
        throw Exception('客户端配置不存在: $clientId');
      }

      final updatedConfig = await _initService.updateClientConfig(
        config,
        displayName: displayName,
        server: server,
        webSocket: webSocket,
      );

      await _refreshConfigs();
      await _refreshActiveConfig();

      if (kDebugMode) {
        debugPrint('客户端配置更新成功: $clientId');
      }

      return updatedConfig;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('更新客户端配置失败: $e');
      }
      rethrow;
    }
  }

  /// 删除客户端配置
  Future<void> deleteConfig(String clientId) async {
    _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint('删除客户端配置: $clientId');
      }

      // 如果正在连接此客户端，先断开连接
      if (_clientService.currentConfig?.clientId == clientId) {
        await disconnect();
      }

      await _initService.deleteClientConfig(clientId);
      await _refreshConfigs();
      await _refreshActiveConfig();

      if (kDebugMode) {
        debugPrint('客户端配置删除成功: $clientId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('删除客户端配置失败: $e');
      }
      rethrow;
    }
  }

  /// 验证客户端配置
  Future<bool> validateConfig(String clientId) async {
    _ensureInitialized();

    try {
      final config = await _dbService.getClientConfig(clientId);
      if (config == null) {
        return false;
      }

      return await _initService.validateConfig(config);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('验证客户端配置失败: $e');
      }
      return false;
    }
  }

  /// 连接到 WebSocket 服务器
  Future<bool> connect([String? clientId]) async {
    _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint('开始连接 WebSocket 服务器: ${clientId ?? "活跃客户端"}');
      }

      final success = await _clientService.connect(clientId);
      
      if (success && _clientService.currentConfig != null) {
        await _refreshActiveConfig();
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('连接 WebSocket 服务器失败: $e');
      }
      return false;
    }
  }

  /// 断开 WebSocket 连接
  Future<void> disconnect() async {
    _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint('断开 WebSocket 连接');
      }

      await _clientService.disconnect();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('断开 WebSocket 连接失败: $e');
      }
    }
  }

  /// 发送消息
  Future<bool> sendMessage(WebSocketMessage message) async {
    _ensureInitialized();
    return await _clientService.sendMessage(message);
  }

  /// 发送 JSON 消息
  Future<bool> sendJson(Map<String, dynamic> data) async {
    _ensureInitialized();
    return await _clientService.sendJson(data);
  }

  /// 获取连接统计信息
  Map<String, dynamic> getConnectionStats() {
    _ensureInitialized();
    return _clientService.getConnectionStats();
  }

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    _ensureInitialized();
    return await _initService.getStorageStats();
  }

  /// 重置重连计数器
  void resetReconnectAttempts() {
    _ensureInitialized();
    _clientService.resetReconnectAttempts();
  }

  /// 导出客户端配置（不包含私钥）
  Future<Map<String, dynamic>> exportConfig(String clientId) async {
    _ensureInitialized();

    try {
      final config = await _dbService.getClientConfig(clientId);
      if (config == null) {
        throw Exception('客户端配置不存在: $clientId');
      }

      // 创建导出数据（不包含私钥ID）
      final exportData = config.toJson();
      exportData['keys'] = {
        'public_key': config.keys.publicKey,
        // 不导出私钥ID
      };

      return exportData;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('导出客户端配置失败: $e');
      }
      rethrow;
    }
  }

  /// 清理过期的配置和密钥
  Future<void> cleanupExpiredData() async {
    _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint('开始清理过期数据');
      }

      // 获取所有配置
      final configs = await _dbService.getAllClientConfigs();
      
      // 检查每个配置的有效性
      for (final config in configs) {
        final isValid = await _initService.validateConfig(config);
        if (!isValid) {
          if (kDebugMode) {
            debugPrint('发现无效配置，准备清理: ${config.clientId}');
          }
          await deleteConfig(config.clientId);
        }
      }

      if (kDebugMode) {
        debugPrint('过期数据清理完成');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('清理过期数据失败: $e');
      }
    }
  }

  /// 刷新配置列表
  Future<void> _refreshConfigs() async {
    try {
      final configs = await _dbService.getAllClientConfigs();
      _configsController.add(configs);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('刷新配置列表失败: $e');
      }
    }
  }

  /// 刷新活跃配置
  Future<void> _refreshActiveConfig() async {
    try {
      final activeConfig = await _dbService.getActiveClientConfig();
      _activeConfigController.add(activeConfig);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('刷新活跃配置失败: $e');
      }
    }
  }

  /// 确保管理器已初始化
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('WebSocket 客户端管理器未初始化，请先调用 initialize()');
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    await _clientService.dispose();
    await _configsController.close();
    await _activeConfigController.close();
    _isInitialized = false;
  }
}