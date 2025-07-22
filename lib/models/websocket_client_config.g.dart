// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'websocket_client_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebSocketClientConfig _$WebSocketClientConfigFromJson(
        Map<String, dynamic> json) =>
    WebSocketClientConfig(
      clientId: json['clientId'] as String,
      displayName: json['displayName'] as String,
      server: ServerConfig.fromJson(json['server'] as Map<String, dynamic>),
      webSocket:
          WebSocketConfig.fromJson(json['webSocket'] as Map<String, dynamic>),
      keys: ClientKeyConfig.fromJson(json['keys'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastConnectedAt: json['lastConnectedAt'] == null
          ? null
          : DateTime.parse(json['lastConnectedAt'] as String),
      isActive: json['isActive'] as bool? ?? false,
    );

Map<String, dynamic> _$WebSocketClientConfigToJson(
        WebSocketClientConfig instance) =>
    <String, dynamic>{
      'clientId': instance.clientId,
      'displayName': instance.displayName,
      'server': instance.server,
      'webSocket': instance.webSocket,
      'keys': instance.keys,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastConnectedAt': instance.lastConnectedAt?.toIso8601String(),
      'isActive': instance.isActive,
    };

ServerConfig _$ServerConfigFromJson(Map<String, dynamic> json) => ServerConfig(
      host: json['host'] as String,
      port: (json['port'] as num).toInt(),
    );

Map<String, dynamic> _$ServerConfigToJson(ServerConfig instance) =>
    <String, dynamic>{
      'host': instance.host,
      'port': instance.port,
    };

WebSocketConfig _$WebSocketConfigFromJson(Map<String, dynamic> json) =>
    WebSocketConfig(
      path: json['path'] as String,
      pingInterval: (json['pingInterval'] as num).toDouble(),
      reconnectDelay: (json['reconnectDelay'] as num).toInt(),
    );

Map<String, dynamic> _$WebSocketConfigToJson(WebSocketConfig instance) =>
    <String, dynamic>{
      'path': instance.path,
      'pingInterval': instance.pingInterval,
      'reconnectDelay': instance.reconnectDelay,
    };

ClientKeyConfig _$ClientKeyConfigFromJson(Map<String, dynamic> json) =>
    ClientKeyConfig(
      publicKey: json['publicKey'] as String,
      privateKeyId: json['privateKeyId'] as String,
    );

Map<String, dynamic> _$ClientKeyConfigToJson(ClientKeyConfig instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'privateKeyId': instance.privateKeyId,
    };

WebApiKeyResponse _$WebApiKeyResponseFromJson(Map<String, dynamic> json) =>
    WebApiKeyResponse(
      status: json['status'] as String,
      data: WebApiKeyData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WebApiKeyResponseToJson(WebApiKeyResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
    };

WebApiKeyData _$WebApiKeyDataFromJson(Map<String, dynamic> json) =>
    WebApiKeyData(
      server: ServerConfig.fromJson(json['server'] as Map<String, dynamic>),
      webSocket:
          WebSocketConfig.fromJson(json['webSocket'] as Map<String, dynamic>),
      clientId: json['clientId'] as String,
    );

Map<String, dynamic> _$WebApiKeyDataToJson(WebApiKeyData instance) =>
    <String, dynamic>{
      'server': instance.server,
      'webSocket': instance.webSocket,
      'clientId': instance.clientId,
    };
