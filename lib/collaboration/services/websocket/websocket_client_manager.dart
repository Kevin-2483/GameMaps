// This file has been processed by AI for internationalization
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../models/websocket_client_config.dart';
import 'websocket_client_init_service.dart';
import 'websocket_client_service.dart';
import 'websocket_client_database_service.dart';
import 'websocket_secure_storage_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/localization_service.dart';

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
  Stream<List<WebSocketClientConfig>> get configsStream =>
      _configsController.stream;
  Stream<WebSocketClientConfig?> get activeConfigStream =>
      _activeConfigController.stream;
  Stream<WebSocketConnectionState> get connectionStateStream =>
      _clientService.stateStream;
  Stream<WebSocketMessage> get messageStream => _clientService.messageStream;
  Stream<String> get errorStream => _clientService.errorStream;
  Stream<int> get pingDelayStream => _clientService.pingDelayStream;
  WebSocketConnectionState get connectionState =>
      _clientService.connectionState;
  bool get isConnected => _clientService.isConnected;
  int get currentPingDelay => _clientService.currentPingDelay;

  /// 初始化管理器
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService
              .instance
              .current
              .initializeWebSocketClientManager_4821,
        );
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
        debugPrint(
          LocalizationService.instance.current.websocketManagerInitialized_7281,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(LocalizationService.instance.current.webSocketInitFailed(e));
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
        debugPrint(
          LocalizationService.instance.current.createClientWithWebApiKey(
            displayName,
          ),
        );
      }

      final config = await _initService.initializeWithWebApiKey(
        webApiKey,
        displayName,
      );

      await _refreshConfigs();

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.clientCreatedSuccessfully(
            config.clientId,
          ),
        );
      }

      return config;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.clientCreationFailed_5421(e),
        );
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
    double pingInterval = 0.5,
    int reconnectDelay = 5,
  }) async {
    _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.createDefaultClient_7281(
            displayName,
          ),
        );
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
        debugPrint(
          LocalizationService.instance.current.clientCreatedSuccessfully(
            config.clientId,
          ),
        );
      }

      return config;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.clientCreationFailed_7285(e),
        );
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
        debugPrint(
          LocalizationService.instance.current.setActiveClient_7421(clientId),
        );
      }

      await _dbService.setActiveClientConfig(clientId);
      await _refreshActiveConfig();

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.clientSetSuccessfully_4821(
            clientId,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.setActiveClientFailed_7285(e),
        );
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
        throw Exception(
          LocalizationService.instance.current.clientConfigNotFound_7285(
            clientId,
          ),
        );
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
        debugPrint(
          LocalizationService.instance.current
              .clientConfigUpdatedSuccessfully_7284(clientId),
        );
      }

      return updatedConfig;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.clientConfigUpdateFailed(e),
        );
      }
      rethrow;
    }
  }

  /// 删除客户端配置
  Future<void> deleteConfig(String clientId) async {
    _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.deleteClientConfig(clientId),
        );
      }

      // 如果正在连接此客户端，先断开连接
      if (_clientService.currentConfig?.clientId == clientId) {
        await disconnect();
      }

      await _initService.deleteClientConfig(clientId);
      await _refreshConfigs();
      await _refreshActiveConfig();

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current
              .clientConfigDeletedSuccessfully_7421(clientId),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.deleteClientConfigFailed(e),
        );
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
        debugPrint(
          LocalizationService.instance.current
              .clientConfigValidationFailed_4821(e),
        );
      }
      return false;
    }
  }

  /// 连接到 WebSocket 服务器
  Future<bool> connect([String? clientId]) async {
    _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.startWebSocketConnection_7281(
            clientId ?? LocalizationService.instance.current.activeClient_7281,
          ),
        );
      }

      final success = await _clientService.connect(clientId);

      if (success && _clientService.currentConfig != null) {
        await _refreshActiveConfig();
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.websocketConnectionFailed(e),
        );
      }
      return false;
    }
  }

  /// 断开 WebSocket 连接
  Future<void> disconnect() async {
    _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.disconnectWebSocket_7421,
        );
      }

      await _clientService.disconnect();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.websocketDisconnectFailed(e),
        );
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

  /// 发送用户状态更新
  Future<bool> sendUserStatusUpdate({
    required String onlineStatus,
    required String activityStatus,
  }) async {
    _ensureInitialized();
    return await _clientService.sendUserStatusUpdate(
      onlineStatus: onlineStatus,
      activityStatus: activityStatus,
    );
  }

  /// 发送包含地图信息的用户状态更新
  Future<bool> sendUserStatusUpdateWithData(
    Map<String, dynamic> statusData,
  ) async {
    _ensureInitialized();
    return await _clientService.sendUserStatusUpdateWithData(statusData);
  }

  /// 请求在线状态列表
  Future<bool> requestOnlineStatusList() async {
    _ensureInitialized();
    return await _clientService.requestOnlineStatusList();
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
        throw Exception(
          LocalizationService.instance.current.clientConfigNotFound_7285(
            clientId,
          ),
        );
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
        debugPrint(
          LocalizationService.instance.current.exportClientConfigFailed(e),
        );
      }
      rethrow;
    }
  }

  /// 清理过期的配置和密钥
  Future<void> cleanupExpiredData() async {
    _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.startCleaningExpiredData_1234,
        );
      }

      // 获取所有配置
      final configs = await _dbService.getAllClientConfigs();

      // 检查每个配置的有效性
      for (final config in configs) {
        final isValid = await _initService.validateConfig(config);
        if (!isValid) {
          if (kDebugMode) {
            debugPrint(
              LocalizationService.instance.current.invalidConfigCleanup(
                config.clientId,
              ),
            );
          }
          await deleteConfig(config.clientId);
        }
      }

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.expiredDataCleaned_7281,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(LocalizationService.instance.current.cleanupFailed_7285(e));
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
        debugPrint(
          LocalizationService.instance.current.refreshConfigFailed_7284(e),
        );
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
        debugPrint(
          LocalizationService.instance.current.refreshConfigFailed_5421(e),
        );
      }
    }
  }

  /// 确保管理器已初始化
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        LocalizationService.instance.current.websocketNotInitializedError_7281,
      );
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
