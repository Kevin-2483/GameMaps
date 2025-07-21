import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../models/websocket_client_config.dart';
import 'websocket_secure_storage_service.dart';
import 'websocket_client_service.dart';

/// WebSocket 客户端认证服务
/// 实现挑战-响应认证机制
class WebSocketClientAuthService {
  final WebSocketSecureStorageService _secureStorage =
      WebSocketSecureStorageService();

  /// 执行 WebSocket 认证流程
  /// 返回认证是否成功
  Future<bool> authenticate(
    WebSocketChannel channel,
    WebSocketClientConfig config,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('开始 WebSocket 认证流程: ${config.clientId}');
      }

      // 1. 发送认证消息
      await _sendAuthMessage(channel, config);

      // 2. 使用单一监听器处理整个认证流程
      final authResult = await _handleAuthenticationFlow(channel, config);
      
      if (kDebugMode) {
        debugPrint('认证结果: ${authResult ? "成功" : "失败"}');
      }

      return authResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('认证过程中发生错误: $e');
      }
      return false;
    }
  }

  /// 使用外部消息流执行认证流程
  Future<bool> authenticateWithController(
    Stream<WebSocketMessage> messageStream,
    WebSocketClientConfig config,
    Future<bool> Function(WebSocketMessage) sendMessage,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('开始 WebSocket 认证流程 (使用外部流): ${config.clientId}');
      }

      // 处理认证流程
      final authResult = await _handleAuthenticationFlowWithStream(messageStream, config, sendMessage);
      
      if (kDebugMode) {
        debugPrint('认证结果: ${authResult ? "成功" : "失败"}');
      }

      return authResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('认证过程中发生错误: $e');
      }
      return false;
    }
  }

  /// 发送认证消息
  Future<void> _sendAuthMessage(
    WebSocketChannel channel,
    WebSocketClientConfig config,
  ) async {
    final authMessage = {
      'type': 'auth',
      'data': config.clientId,  // 服务器期望的格式
    };

    final messageJson = jsonEncode(authMessage);
    channel.sink.add(messageJson);

    if (kDebugMode) {
      debugPrint('已发送认证消息: ${config.clientId}');
    }
  }

  /// 处理完整的认证流程（单一监听器）
  Future<bool> _handleAuthenticationFlow(
    WebSocketChannel channel,
    WebSocketClientConfig config,
  ) async {
    try {
      // 发送认证请求
      await _sendAuthMessage(channel, config);
      
      // 处理认证流程
      return await _handleAuthenticationFlowInternal(channel.stream, config, channel);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('认证流程处理错误: $e');
      }
      return false;
    }
  }

  /// 使用外部消息流处理认证流程
  Future<bool> _handleAuthenticationFlowWithStream(
    Stream<WebSocketMessage> messageStream,
    WebSocketClientConfig config,
    Future<bool> Function(WebSocketMessage) sendMessage,
  ) async {
    try {
      // 处理认证流程
      return await _handleAuthenticationFlowFromMessages(messageStream, config, sendMessage);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('认证流程处理错误: $e');
      }
      return false;
    }
  }

  /// 内部认证流程处理（原始 stream）
  Future<bool> _handleAuthenticationFlowInternal(
    Stream stream,
    WebSocketClientConfig config,
    WebSocketChannel channel,
  ) async {
    // 将原始 stream 转换为 WebSocketMessage 流
    final messageStream = stream.map((message) {
      final messageData = jsonDecode(message as String) as Map<String, dynamic>;
      return WebSocketMessage.fromJson(messageData);
    });
    
    // 复用 WebSocketMessage 流处理逻辑
    return await _handleAuthenticationFlowFromMessages(
      messageStream,
      config,
      (message) async {
        final messageJson = jsonEncode(message.toJson());
        channel.sink.add(messageJson);
        if (kDebugMode) {
          debugPrint('已发送认证消息: ${message.type}');
        }
        return true;
      },
    );
  }

  /// 处理来自 WebSocketMessage 流的认证流程
  Future<bool> _handleAuthenticationFlowFromMessages(
    Stream<WebSocketMessage> messageStream,
    WebSocketClientConfig config,
    Future<bool> Function(WebSocketMessage) sendMessage,
  ) async {
    try {
      // 设置超时时间为 30 秒
      final stream = messageStream.timeout(
        const Duration(seconds: 30),
        onTimeout: (sink) {
          if (kDebugMode) {
            debugPrint('认证流程超时');
          }
          sink.close();
        },
      );

      // 使用 StreamSubscription 来控制监听
      late StreamSubscription subscription;
      final completer = Completer<bool>();
      
      subscription = stream.listen(
        (message) async {
          try {
            switch (message.type) {
              case 'challenge':
                final challenge = message.data is Map<String, dynamic> 
                    ? message.data['data'] as String?
                    : message.data as String?;
                if (challenge != null) {
                  if (kDebugMode) {
                    debugPrint('收到服务器挑战');
                  }
                  
                  // 解密挑战
                  final decryptedChallenge = await _decryptChallenge(
                    challenge,
                    config.keys.privateKeyId,
                  );
                  
                  if (decryptedChallenge == null) {
                    if (kDebugMode) {
                      debugPrint('认证失败: 挑战解密失败');
                    }
                    await subscription.cancel();
                    if (!completer.isCompleted) completer.complete(false);
                    return;
                  }
                  
                  // 发送挑战响应 - 需要通过回调发送
                   final responseMessage = WebSocketMessage(
                     type: 'challenge_response',
                     data: decryptedChallenge,
                   );
                   
                   final sendResult = await sendMessage(responseMessage);
                   
                   if (kDebugMode) {
                     debugPrint('已发送挑战响应，结果: $sendResult');
                   }
                }
                break;
                
              case 'auth_success':
                if (kDebugMode) {
                  debugPrint('认证成功');
                }
                await subscription.cancel();
                if (!completer.isCompleted) completer.complete(true);
                return;
                
              case 'auth_failed':
                final reason = message.data is Map<String, dynamic>
                    ? message.data['reason'] as String? ?? '未知原因'
                    : message.data as String? ?? '未知原因';
                if (kDebugMode) {
                  debugPrint('认证失败: $reason');
                }
                await subscription.cancel();
                if (!completer.isCompleted) completer.complete(false);
                return;
                
              case 'error':
                final error = message.data is Map<String, dynamic>
                    ? message.data['message'] as String? ?? '未知错误'
                    : message.data as String? ?? '未知错误';
                if (kDebugMode) {
                  debugPrint('服务器返回错误: $error');
                }
                await subscription.cancel();
                if (!completer.isCompleted) completer.complete(false);
                return;
                
              default:
                // 忽略其他类型的消息
                if (kDebugMode) {
                  debugPrint('忽略消息类型: ${message.type}');
                }
                break;
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('解析消息失败: $e');
            }
          }
        },
        onError: (error) async {
          if (kDebugMode) {
            debugPrint('Stream 错误: $error');
          }
          await subscription.cancel();
          if (!completer.isCompleted) completer.complete(false);
        },
        onDone: () async {
          if (kDebugMode) {
            debugPrint('Stream 已关闭');
          }
          if (!completer.isCompleted) completer.complete(false);
        },
      );
      
      return await completer.future;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('认证流程处理错误: $e');
      }
    }

    return false;
  }

  /// 解密挑战
  Future<String?> _decryptChallenge(
    String encryptedChallenge,
    String privateKeyId,
  ) async {
    try {
      final decrypted = await _secureStorage.decryptWithPrivateKey(
        privateKeyId,
        encryptedChallenge,
      );
      
      if (kDebugMode) {
        debugPrint('挑战解密成功');
      }
      
      return decrypted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('挑战解密失败: $e');
      }
      return null;
    }
  }





  /// 验证消息签名（可选功能）
  Future<bool> verifyMessageSignature(
    String message,
    String signature,
    String publicKey,
  ) async {
    try {
      final isValid = await _secureStorage.verifySignature(
        message,
        signature,
        publicKey,
      );
      
      if (kDebugMode) {
        debugPrint('消息签名验证结果: ${isValid ? "有效" : "无效"}');
      }
      
      return isValid;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('验证消息签名失败: $e');
      }
      return false;
    }
  }

  /// 对消息进行签名（可选功能）
  Future<String?> signMessage(
    String message,
    String privateKeyId,
  ) async {
    try {
      final signature = await _secureStorage.signWithPrivateKey(
        privateKeyId,
        message,
      );
      
      if (kDebugMode) {
        debugPrint('消息签名成功');
      }
      
      return signature;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('消息签名失败: $e');
      }
      return null;
    }
  }

  /// 生成认证令牌（可选功能）
  String generateAuthToken(String clientId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tokenData = {
      'client_id': clientId,
      'timestamp': timestamp,
      'nonce': _generateNonce(),
    };
    
    final tokenJson = jsonEncode(tokenData);
    final tokenBytes = utf8.encode(tokenJson);
    final token = base64Encode(tokenBytes);
    
    if (kDebugMode) {
      debugPrint('生成认证令牌: $clientId');
    }
    
    return token;
  }

  /// 验证认证令牌（可选功能）
  bool validateAuthToken(String token, String expectedClientId) {
    try {
      final tokenBytes = base64Decode(token);
      final tokenJson = utf8.decode(tokenBytes);
      final tokenData = jsonDecode(tokenJson) as Map<String, dynamic>;
      
      final clientId = tokenData['client_id'] as String?;
      final timestamp = tokenData['timestamp'] as int?;
      
      if (clientId != expectedClientId) {
        if (kDebugMode) {
          debugPrint('令牌验证失败: 客户端ID不匹配');
        }
        return false;
      }
      
      if (timestamp == null) {
        if (kDebugMode) {
          debugPrint('令牌验证失败: 时间戳缺失');
        }
        return false;
      }
      
      // 检查令牌是否过期（5分钟有效期）
      final now = DateTime.now().millisecondsSinceEpoch;
      final tokenAge = now - timestamp;
      const maxAge = 5 * 60 * 1000; // 5分钟
      
      if (tokenAge > maxAge) {
        if (kDebugMode) {
          debugPrint('令牌验证失败: 令牌已过期');
        }
        return false;
      }
      
      if (kDebugMode) {
        debugPrint('令牌验证成功: $clientId');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('令牌验证失败: $e');
      }
      return false;
    }
  }

  /// 生成随机数
  String _generateNonce() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return base64Encode(utf8.encode(random));
  }
}