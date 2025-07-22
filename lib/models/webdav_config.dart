import 'package:json_annotation/json_annotation.dart';

part 'webdav_config.g.dart';

/// WebDAV配置模型
@JsonSerializable()
class WebDavConfig {
  /// 配置ID
  final String configId;

  /// 显示名称
  final String displayName;

  /// 服务器URL
  final String serverUrl;

  /// 存储文件夹路径
  final String storagePath;

  /// 认证账户ID（关联到认证凭据）
  final String authAccountId;

  /// 是否启用
  final bool isEnabled;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const WebDavConfig({
    required this.configId,
    required this.displayName,
    required this.serverUrl,
    required this.storagePath,
    required this.authAccountId,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从JSON创建实例
  factory WebDavConfig.fromJson(Map<String, dynamic> json) =>
      _$WebDavConfigFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$WebDavConfigToJson(this);

  /// 复制并修改部分字段
  WebDavConfig copyWith({
    String? configId,
    String? displayName,
    String? serverUrl,
    String? storagePath,
    String? authAccountId,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WebDavConfig(
      configId: configId ?? this.configId,
      displayName: displayName ?? this.displayName,
      serverUrl: serverUrl ?? this.serverUrl,
      storagePath: storagePath ?? this.storagePath,
      authAccountId: authAccountId ?? this.authAccountId,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WebDavConfig(configId: $configId, displayName: $displayName, serverUrl: $serverUrl, storagePath: $storagePath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebDavConfig && other.configId == configId;
  }

  @override
  int get hashCode => configId.hashCode;
}

/// WebDAV认证账户模型
@JsonSerializable()
class WebDavAuthAccount {
  /// 认证账户ID
  final String authAccountId;

  /// 显示名称
  final String displayName;

  /// 用户名
  final String username;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const WebDavAuthAccount({
    required this.authAccountId,
    required this.displayName,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从JSON创建实例
  factory WebDavAuthAccount.fromJson(Map<String, dynamic> json) =>
      _$WebDavAuthAccountFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$WebDavAuthAccountToJson(this);

  /// 复制并修改部分字段
  WebDavAuthAccount copyWith({
    String? authAccountId,
    String? displayName,
    String? username,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WebDavAuthAccount(
      authAccountId: authAccountId ?? this.authAccountId,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WebDavAuthAccount(authAccountId: $authAccountId, displayName: $displayName, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebDavAuthAccount && other.authAccountId == authAccountId;
  }

  @override
  int get hashCode => authAccountId.hashCode;
}

/// WebDAV连接测试结果
class WebDavTestResult {
  /// 是否成功
  final bool success;

  /// 错误消息（如果失败）
  final String? errorMessage;

  /// 响应时间（毫秒）
  final int? responseTimeMs;

  /// 服务器信息
  final String? serverInfo;

  const WebDavTestResult({
    required this.success,
    this.errorMessage,
    this.responseTimeMs,
    this.serverInfo,
  });

  @override
  String toString() {
    if (success) {
      return 'WebDavTestResult(success: true, responseTime: ${responseTimeMs}ms, serverInfo: $serverInfo)';
    } else {
      return 'WebDavTestResult(success: false, error: $errorMessage)';
    }
  }
}
