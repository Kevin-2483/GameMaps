import 'package:json_annotation/json_annotation.dart';

part 'websocket_client_config.g.dart';

/// WebSocket 客户端配置模型
@JsonSerializable()
class WebSocketClientConfig {
  /// 客户端唯一标识符
  final String clientId;
  
  /// 显示名称
  final String displayName;
  
  /// 服务器配置
  final ServerConfig server;
  
  /// WebSocket 配置
  final WebSocketConfig webSocket;
  
  /// 客户端密钥信息
  final ClientKeyConfig keys;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 最后更新时间
  final DateTime updatedAt;
  
  /// 最后连接时间
  final DateTime? lastConnectedAt;
  
  /// 是否为当前活跃配置
  final bool isActive;

  const WebSocketClientConfig({
    required this.clientId,
    required this.displayName,
    required this.server,
    required this.webSocket,
    required this.keys,
    required this.createdAt,
    required this.updatedAt,
    this.lastConnectedAt,
    this.isActive = false,
  });

  /// 创建副本并更新指定字段
  WebSocketClientConfig copyWith({
    String? clientId,
    String? displayName,
    ServerConfig? server,
    WebSocketConfig? webSocket,
    ClientKeyConfig? keys,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastConnectedAt,
    bool? isActive,
  }) {
    return WebSocketClientConfig(
      clientId: clientId ?? this.clientId,
      displayName: displayName ?? this.displayName,
      server: server ?? this.server,
      webSocket: webSocket ?? this.webSocket,
      keys: keys ?? this.keys,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  factory WebSocketClientConfig.fromJson(Map<String, dynamic> json) =>
      _$WebSocketClientConfigFromJson(json);

  Map<String, dynamic> toJson() => _$WebSocketClientConfigToJson(this);
}

/// 服务器配置
@JsonSerializable()
class ServerConfig {
  /// 服务器主机名或IP地址
  final String host;
  
  /// 服务器端口号
  final int port;

  const ServerConfig({
    required this.host,
    required this.port,
  });

  factory ServerConfig.fromJson(Map<String, dynamic> json) =>
      _$ServerConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ServerConfigToJson(this);

  ServerConfig copyWith({
    String? host,
    int? port,
  }) {
    return ServerConfig(
      host: host ?? this.host,
      port: port ?? this.port,
    );
  }
}

/// WebSocket 配置
@JsonSerializable()
class WebSocketConfig {
  /// WebSocket 连接路径
  final String path;
  
  /// 心跳检测间隔（秒）
  final double pingInterval;
  
  /// 重连延迟（秒）
  final int reconnectDelay;

  const WebSocketConfig({
    required this.path,
    required this.pingInterval,
    required this.reconnectDelay,
  });

  factory WebSocketConfig.fromJson(Map<String, dynamic> json) =>
      _$WebSocketConfigFromJson(json);

  Map<String, dynamic> toJson() => _$WebSocketConfigToJson(this);

  WebSocketConfig copyWith({
    String? path,
    double? pingInterval,
    int? reconnectDelay,
  }) {
    return WebSocketConfig(
      path: path ?? this.path,
      pingInterval: pingInterval ?? this.pingInterval,
      reconnectDelay: reconnectDelay ?? this.reconnectDelay,
    );
  }
}

/// 客户端密钥配置
@JsonSerializable()
class ClientKeyConfig {
  /// 公钥（PEM 格式）
  final String publicKey;
  
  /// 私钥存储标识符（用于从安全存储中获取）
  final String privateKeyId;

  const ClientKeyConfig({
    required this.publicKey,
    required this.privateKeyId,
  });

  factory ClientKeyConfig.fromJson(Map<String, dynamic> json) =>
      _$ClientKeyConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ClientKeyConfigToJson(this);

  ClientKeyConfig copyWith({
    String? publicKey,
    String? privateKeyId,
  }) {
    return ClientKeyConfig(
      publicKey: publicKey ?? this.publicKey,
      privateKeyId: privateKeyId ?? this.privateKeyId,
    );
  }
}

/// Web API Key 响应模型
@JsonSerializable()
class WebApiKeyResponse {
  final String status;
  final WebApiKeyData data;

  const WebApiKeyResponse({
    required this.status,
    required this.data,
  });

  factory WebApiKeyResponse.fromJson(Map<String, dynamic> json) =>
      _$WebApiKeyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WebApiKeyResponseToJson(this);
}

/// Web API Key 数据
@JsonSerializable()
class WebApiKeyData {
  final ServerConfig server;
  final WebSocketConfig webSocket;
  final String clientId;

  const WebApiKeyData({
    required this.server,
    required this.webSocket,
    required this.clientId,
  });

  factory WebApiKeyData.fromJson(Map<String, dynamic> json) =>
      _$WebApiKeyDataFromJson(json);

  Map<String, dynamic> toJson() => _$WebApiKeyDataToJson(this);
}