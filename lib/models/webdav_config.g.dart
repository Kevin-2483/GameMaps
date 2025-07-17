// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webdav_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebDavConfig _$WebDavConfigFromJson(Map<String, dynamic> json) => WebDavConfig(
      configId: json['configId'] as String,
      displayName: json['displayName'] as String,
      serverUrl: json['serverUrl'] as String,
      storagePath: json['storagePath'] as String,
      authAccountId: json['authAccountId'] as String,
      isEnabled: json['isEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WebDavConfigToJson(WebDavConfig instance) =>
    <String, dynamic>{
      'configId': instance.configId,
      'displayName': instance.displayName,
      'serverUrl': instance.serverUrl,
      'storagePath': instance.storagePath,
      'authAccountId': instance.authAccountId,
      'isEnabled': instance.isEnabled,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

WebDavAuthAccount _$WebDavAuthAccountFromJson(Map<String, dynamic> json) =>
    WebDavAuthAccount(
      authAccountId: json['authAccountId'] as String,
      displayName: json['displayName'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WebDavAuthAccountToJson(WebDavAuthAccount instance) =>
    <String, dynamic>{
      'authAccountId': instance.authAccountId,
      'displayName': instance.displayName,
      'username': instance.username,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
