import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../../models/websocket_client_config.dart';
import 'websocket_client_auth_service.dart';
import 'websocket_client_database_service.dart';

/// WebSocket 连接状态
enum WebSocketConnectionState {
  disconnected,
  connecting,
  authenticating,
  connected,
  reconnecting,
  error,
}

/// WebSocket 消息类型
class WebSocketMessage {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  WebSocketMessage({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] as String,
      data: Map<String, dynamic>.from(json),
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      ...data,
    };
  }
}

/// WebSocket 客户端服务
/// 实现连接管理、消息处理和重连逻辑
class WebSocketClientService {
  static final WebSocketClientService _instance =
      WebSocketClientService._internal();
  factory WebSocketClientService() => _instance;
  WebSocketClientService._internal();

  final WebSocketClientAuthService _authService =
      WebSocketClientAuthService();
  final WebSocketClientDatabaseService _dbService =
      WebSocketClientDatabaseService();

  // 连接状态
  WebSocketConnectionState _connectionState = WebSocketConnectionState.disconnected;
  WebSocketChannel? _channel;
  WebSocketClientConfig? _currentConfig;
  StreamSubscription? _messageSubscription;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  
  // 心跳相关
  DateTime? _lastPingTime;
  int _lastPingDelay = 0; // 延迟毫秒数
  
  // 流控制器
  final StreamController<WebSocketConnectionState> _stateController =
      StreamController<WebSocketConnectionState>.broadcast();
  final StreamController<WebSocketMessage> _messageController =
      StreamController<WebSocketMessage>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<int> _pingDelayController =
      StreamController<int>.broadcast();
  StreamController<WebSocketMessage>? _authMessageController;

  // 重连配置
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  // Getters
  WebSocketConnectionState get connectionState => _connectionState;
  WebSocketClientConfig? get currentConfig => _currentConfig;
  Stream<WebSocketConnectionState> get stateStream => _stateController.stream;
  Stream<WebSocketMessage> get messageStream => _messageController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<int> get pingDelayStream => _pingDelayController.stream;
  bool get isConnected => _connectionState == WebSocketConnectionState.connected;
  int get currentPingDelay => _lastPingDelay;

  /// 连接到 WebSocket 服务器
  Future<bool> connect([String? clientId]) async {
    try {
      if (_connectionState == WebSocketConnectionState.connecting ||
          _connectionState == WebSocketConnectionState.authenticating) {
        if (kDebugMode) {
          debugPrint('连接正在进行中，忽略重复连接请求');
        }
        return false;
      }

      // 获取配置
      WebSocketClientConfig? config;
      if (clientId != null) {
        config = await _dbService.getClientConfig(clientId);
      } else {
        config = await _dbService.getActiveClientConfig();
      }

      if (config == null) {
        _handleError('未找到客户端配置');
        return false;
      }

      _currentConfig = config;
      _updateConnectionState(WebSocketConnectionState.connecting);

      if (kDebugMode) {
        debugPrint('开始连接到 WebSocket 服务器: ${config.server.host}:${config.server.port}');
      }

      // 构建 WebSocket URL
      final scheme = config.server.port == 443 ? 'wss' : 'ws';
      final url = '$scheme://${config.server.host}:${config.server.port}${config.webSocket.path}';
      
      if (kDebugMode) {
        debugPrint('WebSocket URL: $url');
      }

      // 创建 WebSocket 连接
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      // 等待连接建立
      await _channel!.ready;
      
      if (kDebugMode) {
        debugPrint('WebSocket 连接已建立');
      }

      // 先开始消息监听
      _startMessageListener();
      
      // 连接成功，进行认证
      _updateConnectionState(WebSocketConnectionState.authenticating);
      
      // 发送认证消息
      final authMessage = WebSocketMessage(
        type: 'auth',
        data: {
          'type': 'auth',
          'data': config.clientId,
        },
      );
      
      // 直接发送到 WebSocket，因为 sendMessage 需要连接状态为 connected
      final messageJson = jsonEncode({
        'type': 'auth',
        'data': config.clientId,
      });
      _channel!.sink.add(messageJson);
      
      if (kDebugMode) {
        debugPrint('已发送认证消息: ${config.clientId}');
      }
      
      // 创建认证消息控制器
      _authMessageController = StreamController<WebSocketMessage>.broadcast();
      
      final authSuccess = await _authService.authenticateWithController(
        _authMessageController!.stream, 
        config,
        (message) => _sendMessageDuringAuth(message),
      );
      
      // 清理认证消息控制器
      await _authMessageController?.close();
      _authMessageController = null;
      
      if (!authSuccess) {
        _handleError('认证失败');
        await _closeConnection();
        return false;
      }

      // 认证成功，设置连接状态
      _updateConnectionState(WebSocketConnectionState.connected);
      _reconnectAttempts = 0;

      // 更新数据库中的连接时间
      await _dbService.updateLastConnectedTime(config.clientId);

      // 开始心跳
      _startPingLoop();

      if (kDebugMode) {
        debugPrint('WebSocket 连接和认证成功');
      }

      return true;
    } catch (e) {
      _handleError('连接失败: $e');
      await _closeConnection();
      return false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    if (kDebugMode) {
      debugPrint('主动断开 WebSocket 连接');
    }

    _reconnectAttempts = _maxReconnectAttempts; // 防止自动重连
    await _closeConnection();
    _updateConnectionState(WebSocketConnectionState.disconnected);
  }

  /// 发送消息
  Future<bool> sendMessage(WebSocketMessage message) async {
    if (!isConnected || _channel == null) {
      _handleError('未连接到服务器，无法发送消息');
      return false;
    }

    try {
      final messageJson = jsonEncode(message.toJson());
      _channel!.sink.add(messageJson);
      
      if (kDebugMode) {
        debugPrint('已发送消息: ${message.type}');
      }
      
      return true;
    } catch (e) {
      _handleError('发送消息失败: $e');
      return false;
    }
  }

  /// 在认证期间发送消息
  Future<bool> _sendMessageDuringAuth(WebSocketMessage message) async {
    if (_channel == null) {
      if (kDebugMode) {
        debugPrint('WebSocket 连接不存在，无法发送消息');
      }
      return false;
    }

    try {
      final messageJson = jsonEncode(message.toJson());
      _channel!.sink.add(messageJson);
      
      if (kDebugMode) {
        debugPrint('已发送认证消息: ${message.type}');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('发送认证消息失败: $e');
      }
      return false;
    }
  }

  /// 发送 JSON 消息
  Future<bool> sendJson(Map<String, dynamic> data) async {
    final message = WebSocketMessage(
      type: data['type'] as String? ?? 'unknown',
      data: data,
    );
    return await sendMessage(message);
  }

  /// 开始消息监听
  void _startMessageListener() {
    _messageSubscription?.cancel();
    
    _messageSubscription = _channel!.stream.listen(
      (data) {
        try {
          final messageData = jsonDecode(data as String) as Map<String, dynamic>;
          final message = WebSocketMessage.fromJson(messageData);
          
          if (kDebugMode) {
            debugPrint('收到消息: ${message.type}');
          }
          
          _handleIncomingMessage(message);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('解析消息失败: $e');
          }
        }
      },
      onError: (error) {
        _handleError('WebSocket 错误: $error');
        _triggerReconnect();
      },
      onDone: () {
        if (kDebugMode) {
          debugPrint('WebSocket 连接已关闭');
        }
        _triggerReconnect();
      },
    );
  }

  /// 处理收到的消息
  void _handleIncomingMessage(WebSocketMessage message) {
    switch (message.type) {
      case 'pong':
        _handlePongMessage(message);
        break;
      case 'connect':
        _handleConnectMessage(message);
        break;
      case 'error':
        _handleServerError(message);
        break;
      case 'challenge':
      case 'auth_success':
      case 'auth_failed':
        // 将认证相关消息转发给认证服务
        if (_authMessageController != null) {
          _authMessageController!.add(message);
        }
        break;
      default:
        // 将消息转发给监听者
        _messageController.add(message);
        break;
    }
  }

  /// 处理 pong 消息
  void _handlePongMessage(WebSocketMessage message) {
    if (_lastPingTime != null) {
      final now = DateTime.now();
      _lastPingDelay = now.difference(_lastPingTime!).inMilliseconds;
      _pingDelayController.add(_lastPingDelay);
      
      if (kDebugMode) {
        debugPrint('收到 pong 消息，延迟: ${_lastPingDelay}ms');
      }
    }
    // 可以在这里处理服务器状态信息
  }

  /// 处理连接消息
  void _handleConnectMessage(WebSocketMessage message) {
    if (kDebugMode) {
      debugPrint('收到连接确认消息');
    }
    // 可以在这里处理连接确认逻辑
  }

  /// 处理服务器错误
  void _handleServerError(WebSocketMessage message) {
    final errorMsg = message.data['message'] as String? ?? '未知服务器错误';
    _handleError('服务器错误: $errorMsg');
  }

  /// 开始心跳循环
  void _startPingLoop() {
    _pingTimer?.cancel();
    
    if (_currentConfig == null) return;
    
    final pingInterval = Duration(seconds: _currentConfig!.webSocket.pingInterval);
    
    _pingTimer = Timer.periodic(pingInterval, (timer) {
      if (!isConnected) {
        timer.cancel();
        return;
      }
      
      _sendPing();
    });
  }

  /// 发送心跳消息
  void _sendPing() {
    _lastPingTime = DateTime.now();
    
    final pingMessage = WebSocketMessage(
      type: 'ping',
      data: {
        'type': 'ping',
        'timestamp': _lastPingTime!.millisecondsSinceEpoch,
        'client_id': _currentConfig?.clientId,
      },
    );
    
    sendMessage(pingMessage);
  }

  /// 触发重连
  void _triggerReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _handleError('达到最大重连次数，停止重连');
      _updateConnectionState(WebSocketConnectionState.error);
      return;
    }

    if (_connectionState == WebSocketConnectionState.reconnecting) {
      return; // 已在重连中
    }

    _updateConnectionState(WebSocketConnectionState.reconnecting);
    _reconnectAttempts++;

    final delay = _currentConfig?.webSocket.reconnectDelay ?? 5;
    final reconnectDelay = Duration(
      seconds: delay * _reconnectAttempts,
    );

    if (kDebugMode) {
      debugPrint('将在 ${reconnectDelay.inSeconds} 秒后进行第 $_reconnectAttempts 次重连');
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () {
      if (_currentConfig != null) {
        connect(_currentConfig!.clientId);
      }
    });
  }

  /// 关闭连接
  Future<void> _closeConnection() async {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _messageSubscription?.cancel();
    
    if (_channel != null) {
      await _channel!.sink.close(status.normalClosure);
      _channel = null;
    }
  }

  /// 更新连接状态
  void _updateConnectionState(WebSocketConnectionState newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      _stateController.add(newState);
      
      if (kDebugMode) {
        debugPrint('连接状态变更: ${newState.name}');
      }
    }
  }

  /// 处理错误
  void _handleError(String error) {
    if (kDebugMode) {
      debugPrint('WebSocket 错误: $error');
    }
    _errorController.add(error);
  }

  /// 获取连接统计信息
  Map<String, dynamic> getConnectionStats() {
    return {
      'state': _connectionState.name,
      'reconnect_attempts': _reconnectAttempts,
      'current_config': _currentConfig?.toJson(),
      'connected_at': _currentConfig?.lastConnectedAt?.toIso8601String(),
    };
  }

  /// 重置重连计数器
  void resetReconnectAttempts() {
    _reconnectAttempts = 0;
  }

  /// 释放资源
  Future<void> dispose() async {
    await _closeConnection();
    await _stateController.close();
    await _messageController.close();
    await _errorController.close();
    await _pingDelayController.close();
  }
}