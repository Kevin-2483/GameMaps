// This file has been processed by AI for internationalization
import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'services/websocket/websocket_client_manager.dart';
import 'services/websocket/websocket_client_service.dart';
import 'services/collaboration_state_manager.dart';
import 'blocs/presence/presence_bloc.dart';
import '../l10n/app_localizations.dart';
import '../services/localization_service.dart';

/// 全局协作服务
/// 管理WebSocket连接和PresenceBloc的全局实例
class GlobalCollaborationService {
  static final GlobalCollaborationService _instance =
      GlobalCollaborationService._internal();
  factory GlobalCollaborationService() => _instance;
  GlobalCollaborationService._internal();

  /// 获取单例实例
  static GlobalCollaborationService get instance => _instance;

  late final WebSocketClientManager _webSocketManager;
  late final PresenceBloc _presenceBloc;
  late final CollaborationStateManager _collaborationStateManager;
  bool _isInitialized = false;
  bool _userInfoSet = false;

  /// 获取WebSocket管理器实例
  WebSocketClientManager get webSocketManager {
    if (!_isInitialized) {
      throw Exception(
        LocalizationService.instance.current.serviceNotInitializedError_4821,
      );
    }
    return _webSocketManager;
  }

  /// 获取PresenceBloc实例
  PresenceBloc get presenceBloc {
    if (!_isInitialized) {
      throw Exception(
        LocalizationService.instance.current.serviceNotInitializedError_4821,
      );
    }
    return _presenceBloc;
  }

  /// 获取CollaborationStateManager实例
  CollaborationStateManager get collaborationStateManager {
    if (!_isInitialized) {
      throw Exception(
        LocalizationService.instance.current.serviceNotInitializedError_4821,
      );
    }
    return _collaborationStateManager;
  }

  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;

  /// 设置用户信息并初始化CollaborationStateManager
  void setUserInfo({
    required String userId,
    required String displayName,
    Color? userColor,
  }) {
    if (!_isInitialized) {
      throw Exception(
        LocalizationService.instance.current.serviceNotInitializedError_7281,
      );
    }

    if (_userInfoSet) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.userInfoSetSkipped_7281,
        );
      }
      return;
    }

    // 初始化CollaborationStateManager
    _collaborationStateManager.initialize(
      userId: userId,
      displayName: displayName,
      userColor: userColor,
    );

    _userInfoSet = true;

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.globalCollaborationUserInfoSet(
          userId,
          displayName,
        ),
      );
    }
  }

  /// 初始化全局协作服务
  /// 注意：此方法只初始化服务，不会自动连接WebSocket
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService
              .instance
              .current
              .globalCollaborationServiceInitialized_7281,
        );
      }
      return;
    }

    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService
              .instance
              .current
              .initializingGlobalCollaborationService_7281,
        );
      }

      // 初始化WebSocket管理器（不自动连接）
      _webSocketManager = WebSocketClientManager();
      await _webSocketManager.initialize();

      // 初始化CollaborationStateManager
      _collaborationStateManager = CollaborationStateManager();

      // 初始化PresenceBloc
      _presenceBloc = PresenceBloc(webSocketManager: _webSocketManager);

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint(
          LocalizationService
              .instance
              .current
              .globalCollaborationServiceInitialized_4821,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current
              .globalCollaborationServiceInitFailed(e),
        );
      }
      rethrow;
    }
  }

  /// 连接WebSocket
  /// 如果没有活跃配置，会自动创建默认配置
  Future<bool> connect([String? clientId]) async {
    if (!_isInitialized) {
      throw Exception(
        LocalizationService
            .instance
            .current
            .globalCollaborationNotInitialized_4821,
      );
    }

    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.webSocketConnectionStart_7281,
        );
      }

      // 检查是否有活跃的配置，如果没有则创建默认配置
      if (clientId == null) {
        var activeConfig = await _webSocketManager.getActiveConfig();
        if (activeConfig == null) {
          if (kDebugMode) {
            debugPrint(
              LocalizationService
                  .instance
                  .current
                  .noActiveWebSocketConfigFound_7281,
            );
          }
          final defaultConfig = await _webSocketManager.createDefaultClient(
            LocalizationService.instance.current.atlasClient_7421,
            host: 'localhost',
            port: 8080,
            path: '/ws/client',
          );
          await _webSocketManager.setActiveConfig(defaultConfig.clientId);
          clientId = defaultConfig.clientId;
        }
      }

      final success = await _webSocketManager.connect(clientId);

      if (success) {
        // WebSocket连接成功，PresenceBloc会自动处理连接状态

        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.websocketConnectedSuccess_4821,
          );
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.websocketConnectionFailed_4821,
          );
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current
              .globalCollaborationServiceConnectionFailed(e),
        );
      }
      return false;
    }
  }

  /// 断开WebSocket连接
  Future<void> disconnect() async {
    if (!_isInitialized) {
      return;
    }

    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.disconnectWebSocket_4821,
        );
      }

      // WebSocket断开连接，PresenceBloc会自动处理断开状态

      await _webSocketManager.disconnect();

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.websocketDisconnected_7281,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.connectionFailed_7285(e),
        );
      }
    }
  }

  /// 请求在线状态列表
  Future<bool> requestOnlineStatusList() async {
    if (!_isInitialized) {
      throw Exception(
        LocalizationService
            .instance
            .current
            .globalCollaborationNotInitialized_7281,
      );
    }

    // 确保WebSocket已连接
    if (!_webSocketManager.isConnected) {
      final connected = await _webSocketManager.connect();
      if (!connected) {
        return false;
      }
    }

    return await _webSocketManager.requestOnlineStatusList();
  }

  /// 获取WebSocket连接状态
  bool get isWebSocketConnected => _webSocketManager.isConnected;

  /// 获取WebSocket连接状态（别名）
  bool get isConnected => _webSocketManager.isConnected;

  /// 获取WebSocket连接状态流
  Stream<WebSocketConnectionState> get connectionStateStream =>
      _webSocketManager.connectionStateStream;

  /// 获取WebSocket消息流
  Stream<WebSocketMessage> get messageStream => _webSocketManager.messageStream;

  /// 获取WebSocket错误流
  Stream<String> get errorStream => _webSocketManager.errorStream;

  /// 获取WebSocket延迟流
  Stream<int> get pingDelayStream => _webSocketManager.pingDelayStream;

  /// 发送WebSocket消息
  Future<bool> sendMessage(WebSocketMessage message) async {
    if (!_isInitialized) {
      throw Exception(
        LocalizationService
            .instance
            .current
            .globalCollaborationNotInitialized_7281,
      );
    }

    return await _webSocketManager.sendMessage(message);
  }

  /// 发送JSON消息
  Future<bool> sendJson(Map<String, dynamic> data) async {
    if (!_isInitialized) {
      throw Exception(
        LocalizationService
            .instance
            .current
            .globalCollaborationNotInitialized_4821,
      );
    }

    return await _webSocketManager.sendJson(data);
  }

  /// 释放资源
  Future<void> dispose() async {
    if (!_isInitialized) {
      return;
    }

    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService
              .instance
              .current
              .globalCollaborationServiceReleaseResources_7421,
        );
      }

      await _presenceBloc.close();
      await _webSocketManager.dispose();

      _isInitialized = false;

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.resourceReleaseComplete_4821,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.resourceReleaseFailed_4821(e),
        );
      }
    }
  }
}
