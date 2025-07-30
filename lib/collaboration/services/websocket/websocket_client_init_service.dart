// This file has been processed by AI for internationalization
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fast_rsa/fast_rsa.dart';
import '../../../models/websocket_client_config.dart';
import 'websocket_client_database_service.dart';
import 'websocket_secure_storage_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/localization_service.dart';

/// WebSocket 客户端初始化服务
/// 处理 Web API Key 初始化和配置创建
class WebSocketClientInitService {
  static final WebSocketClientInitService _instance =
      WebSocketClientInitService._internal();
  factory WebSocketClientInitService() => _instance;
  WebSocketClientInitService._internal();

  final WebSocketClientDatabaseService _dbService =
      WebSocketClientDatabaseService();
  final WebSocketSecureStorageService _secureStorage =
      WebSocketSecureStorageService();

  /// 使用 Web API Key 初始化客户端配置
  Future<WebSocketClientConfig> initializeWithWebApiKey(
    String webApiKey,
    String displayName,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.initializingClientWithKey(
            webApiKey,
          ),
        );
      }

      // 1. 生成服务器兼容的 RSA 密钥对（PUBLIC KEY 格式）
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.rsaKeyGenerationStep1_4821,
        );
      }
      final keyPair = await _secureStorage.generateServerCompatibleKeyPair();
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.rsaKeyPairGenerated_4821,
        );
      }
      final publicKeyPem = keyPair.publicKey;
      final privateKeyPem = keyPair.privateKey;

      // 2. 存储私钥到安全存储
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.step2StorePrivateKey_7281,
        );
      }
      final privateKeyId = await _secureStorage.storePrivateKey(privateKeyPem);
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.step2PrivateKeyStored(
            privateKeyId,
          ),
        );
      }

      // 3. 解析 Web API Key URL
      final uri = Uri.parse(webApiKey);

      // 4. 添加公钥作为查询参数
      final queryParams = Map<String, String>.from(uri.queryParameters);
      queryParams['publickey'] = publicKeyPem;

      final requestUri = uri.replace(queryParameters: queryParams);

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.requestUrl_4821(
            requestUri.toString(),
          ),
        );
      }

      // 5. 发送 HTTP 请求获取配置
      final response = await http.get(requestUri);

      if (response.statusCode != 200) {
        throw Exception(
          LocalizationService.instance.current.serverErrorWithDetails_7421(
            response.statusCode,
            response.body,
          ),
        );
      }

      // 6. 检查响应内容类型
      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception(
          LocalizationService.instance.current
              .unexpectedContentTypeWithResponse(
                contentType ?? 'null',
                response.body,
              ),
        );
      }

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.rawResponseContent(
            response.body,
          ),
        );
      }

      // 7. 解析响应
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['status'] != 'success') {
        throw Exception(
          LocalizationService.instance.current.apiResponseStatusError_7284(
            responseData['status'],
          ),
        );
      }

      final data = responseData['data'] as Map<String, dynamic>;
      final serverData = data['server'] as Map<String, dynamic>;
      final webSocketData = data['websocket'] as Map<String, dynamic>;
      final clientId = data['client_id'] as String;

      // 解析服务器主机名（去掉端口号）
      final serverHost = serverData['host'] as String;
      final hostOnly = serverHost.contains(':')
          ? serverHost.split(':')[0]
          : serverHost;
      final serverPort = serverData['port'] as int;

      // 8. 创建客户端配置
      final now = DateTime.now();
      final config = WebSocketClientConfig(
        clientId: clientId,
        displayName: displayName,
        server: ServerConfig(host: hostOnly, port: serverPort),
        webSocket: WebSocketConfig(
          path: webSocketData['path'] as String,
          pingInterval: (webSocketData['ping_interval'] as num).toDouble(),
          reconnectDelay: webSocketData['reconnect_delay'] as int,
        ),
        keys: ClientKeyConfig(
          publicKey: publicKeyPem,
          privateKeyId: privateKeyId,
        ),
        createdAt: now,
        updatedAt: now,
        isActive: false,
      );

      // 9. 保存配置到数据库
      await _dbService.saveClientConfig(config);

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.clientInitializationSuccess_7421(
            config.displayName,
          ),
        );
      }

      return config;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.clientInitializationFailed_7281(
            e,
          ),
        );
      }
      rethrow;
    }
  }

  /// 创建默认配置（不使用 Web API Key）
  Future<WebSocketClientConfig> createDefaultConfig(
    String displayName, {
    String host = 'localhost',
    int port = 8080,
    String path = '/ws/client',
    double pingInterval = 0.5,
    int reconnectDelay = 5,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.defaultClientConfigCreated(
            displayName,
          ),
        );
      }

      // 1. 生成服务器兼容的 RSA 密钥对（PUBLIC KEY 格式）
      final keyPair = await _secureStorage.generateServerCompatibleKeyPair();
      final publicKeyPem = keyPair.publicKey;
      final privateKeyPem = keyPair.privateKey;

      // 2. 存储私钥到安全存储
      final privateKeyId = await _secureStorage.storePrivateKey(privateKeyPem);

      // 3. 生成客户端ID
      final clientId = DateTime.now().millisecondsSinceEpoch.toString();

      // 4. 创建客户端配置
      final now = DateTime.now();
      final config = WebSocketClientConfig(
        clientId: clientId,
        displayName: displayName,
        server: ServerConfig(host: host, port: port),
        webSocket: WebSocketConfig(
          path: path,
          pingInterval: pingInterval,
          reconnectDelay: reconnectDelay,
        ),
        keys: ClientKeyConfig(
          publicKey: publicKeyPem,
          privateKeyId: privateKeyId,
        ),
        createdAt: now,
        updatedAt: now,
        isActive: false,
      );

      // 5. 保存配置到数据库
      await _dbService.saveClientConfig(config);

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.defaultClientConfigCreated(
            config.displayName,
          ),
        );
      }

      return config;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.clientConfigFailed_7285(e),
        );
      }
      rethrow;
    }
  }

  /// 更新客户端配置
  Future<WebSocketClientConfig> updateClientConfig(
    WebSocketClientConfig config, {
    String? displayName,
    ServerConfig? server,
    WebSocketConfig? webSocket,
  }) async {
    try {
      final updatedConfig = config.copyWith(
        displayName: displayName,
        server: server,
        webSocket: webSocket,
        updatedAt: DateTime.now(),
      );

      await _dbService.saveClientConfig(updatedConfig);

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.clientConfigUpdated_7281(
            updatedConfig.displayName,
          ),
        );
      }

      return updatedConfig;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.updateClientConfigFailed_7421(e),
        );
      }
      rethrow;
    }
  }

  /// 删除客户端配置
  Future<void> deleteClientConfig(String clientId) async {
    try {
      // 1. 获取配置以获取私钥ID
      final config = await _dbService.getClientConfig(clientId);
      if (config != null) {
        // 2. 删除私钥
        await _secureStorage.deletePrivateKey(config.keys.privateKeyId);
      }

      // 3. 删除数据库配置
      await _dbService.deleteClientConfig(clientId);

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.clientConfigDeleted(clientId),
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

  /// 验证配置完整性
  Future<bool> validateConfig(WebSocketClientConfig config) async {
    try {
      // 1. 检查私钥是否存在
      final hasPrivateKey = await _secureStorage.hasPrivateKey(
        config.keys.privateKeyId,
      );

      if (!hasPrivateKey) {
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current
                .configValidationFailedPrivateKeyMissing(
                  config.keys.privateKeyId,
                ),
          );
        }
        return false;
      }

      // 2. 验证公钥格式
      try {
        await RSA.convertPublicKeyToPKCS1(config.keys.publicKey);
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current
                .configValidationFailedWithError('$e'),
          );
        }
        return false;
      }

      // 3. 验证服务器配置
      if (config.server.host.isEmpty || config.server.port <= 0) {
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.configValidationFailed_7281(
              'Server configuration invalid',
            ),
          );
        }
        return false;
      }

      // 4. 验证 WebSocket 配置
      if (config.webSocket.path.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.configValidationFailed_7281(
              'WebSocket path empty',
            ),
          );
        }
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.configValidationFailed_7281(e),
        );
      }
      return false;
    }
  }

  /// 获取所有客户端配置
  Future<List<WebSocketClientConfig>> getAllConfigs() async {
    return await _dbService.getAllClientConfigs();
  }

  /// 获取活跃的客户端配置
  Future<WebSocketClientConfig?> getActiveConfig() async {
    return await _dbService.getActiveClientConfig();
  }

  /// 设置活跃的客户端配置
  Future<void> setActiveConfig(String clientId) async {
    await _dbService.setActiveClientConfig(clientId);
  }

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    final dbStats = await _dbService.getStorageStats();
    final secureStorageStats = await _secureStorage.getStorageStats();

    return {'database': dbStats, 'secure_storage': secureStorageStats};
  }
}
