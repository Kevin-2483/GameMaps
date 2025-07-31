// This file has been processed by AI for internationalization
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../models/websocket_client_config.dart';
import 'websocket_secure_storage_service.dart';
import 'websocket_client_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/localization_service.dart';

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
        debugPrint(
          LocalizationService.instance.current.startWebSocketAuthProcess(
            config.clientId,
          ),
        );
      }

      // 1. 发送认证消息
      await _sendAuthMessage(channel, config);

      // 2. 使用单一监听器处理整个认证流程
      final authResult = await _handleAuthenticationFlow(channel, config);

      if (kDebugMode) {
        debugPrint(
          '${LocalizationService.instance.current.authenticationResult_7425}: ${authResult ? LocalizationService.instance.current.success_8421 : LocalizationService.instance.current.failure_9352}',
        );
      }

      return authResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(LocalizationService.instance.current.authenticationError(e));
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
        debugPrint(
          LocalizationService.instance.current.startWebSocketAuthFlow(
            config.clientId,
          ),
        );
      }

      // 处理认证流程
      final authResult = await _handleAuthenticationFlowWithStream(
        messageStream,
        config,
        sendMessage,
      );

      if (kDebugMode) {
        debugPrint(
          '${LocalizationService.instance.current.authenticationResult_7425}: ${authResult ? LocalizationService.instance.current.success_8421 : LocalizationService.instance.current.failure_9352}',
        );
      }

      return authResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.authenticationError_7425(e),
        );
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
      'data': config.clientId, // 服务器期望的格式
    };

    final messageJson = jsonEncode(authMessage);
    channel.sink.add(messageJson);

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.authMessageSent(config.clientId),
      );
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
      return await _handleAuthenticationFlowInternal(
        channel.stream,
        config,
        channel,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.authProcessError_4821(e),
        );
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
      return await _handleAuthenticationFlowFromMessages(
        messageStream,
        config,
        sendMessage,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.authProcessError_4821(e),
        );
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
    return await _handleAuthenticationFlowFromMessages(messageStream, config, (
      message,
    ) async {
      final messageJson = jsonEncode(message.toJson());
      channel.sink.add(messageJson);
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.authMessageSent(message.type),
        );
      }
      return true;
    });
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
            debugPrint(
              LocalizationService.instance.current.authenticationTimeout_7281,
            );
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
                    debugPrint(
                      LocalizationService
                          .instance
                          .current
                          .serverChallengeReceived_4289,
                    );
                  }

                  // 解密挑战
                  final decryptedChallenge = await _decryptChallenge(
                    challenge,
                    config.keys.privateKeyId,
                  );

                  if (decryptedChallenge == null) {
                    if (kDebugMode) {
                      debugPrint(
                        LocalizationService
                            .instance
                            .current
                            .authFailedChallengeDecrypt_7281,
                      );
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
                    debugPrint(
                      LocalizationService.instance.current
                          .challengeResponseSentResult(sendResult),
                    );
                  }
                }
                break;

              case 'auth_success':
                if (kDebugMode) {
                  debugPrint(
                    LocalizationService
                        .instance
                        .current
                        .authenticationSuccess_7421,
                  );
                }
                await subscription.cancel();
                if (!completer.isCompleted) completer.complete(true);
                return;

              case 'auth_failed':
                final reason = message.data is Map<String, dynamic>
                    ? message.data['reason'] as String? ??
                          LocalizationService
                              .instance
                              .current
                              .unknownReason_7421
                    : message.data as String? ??
                          LocalizationService
                              .instance
                              .current
                              .unknownReason_7421;
                if (kDebugMode) {
                  debugPrint(
                    LocalizationService.instance.current.authenticationFailed(
                      reason,
                    ),
                  );
                }
                await subscription.cancel();
                if (!completer.isCompleted) completer.complete(false);
                return;

              case 'error':
                final error = message.data is Map<String, dynamic>
                    ? message.data['message'] as String? ??
                          LocalizationService.instance.current.unknownError_7421
                    : message.data as String? ??
                          LocalizationService
                              .instance
                              .current
                              .unknownError_7421;
                if (kDebugMode) {
                  debugPrint(
                    LocalizationService.instance.current.serverErrorResponse(
                      error,
                    ),
                  );
                }
                await subscription.cancel();
                if (!completer.isCompleted) completer.complete(false);
                return;

              default:
                // 忽略其他类型的消息
                if (kDebugMode) {
                  debugPrint(
                    LocalizationService.instance.current
                        .ignoredMessageType_7281(message.type),
                  );
                }
                break;
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint(
                LocalizationService.instance.current.parseMessageFailed_7285(e),
              );
            }
          }
        },
        onError: (error) async {
          if (kDebugMode) {
            debugPrint(
              LocalizationService.instance.current.streamError_7284(error),
            );
          }
          await subscription.cancel();
          if (!completer.isCompleted) completer.complete(false);
        },
        onDone: () async {
          if (kDebugMode) {
            debugPrint(LocalizationService.instance.current.streamClosed_8251);
          }
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      return await completer.future;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.authProcessError_4821(e),
        );
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
        debugPrint(
          LocalizationService.instance.current.challengeDecryptedSuccess_7281,
        );
      }

      return decrypted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.challengeDecryptionFailed_7421(
            e,
          ),
        );
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
        debugPrint(
          '${LocalizationService.instance.current.signatureVerificationResult_7425(isValid ? LocalizationService.instance.current.valid_8421 : LocalizationService.instance.current.invalid_9352)}',
        );
      }

      return isValid;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.signatureVerificationFailed(e),
        );
      }
      return false;
    }
  }

  /// 对消息进行签名（可选功能）
  Future<String?> signMessage(String message, String privateKeyId) async {
    try {
      final signature = await _secureStorage.signWithPrivateKey(
        privateKeyId,
        message,
      );

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.messageSignedSuccessfully_7281,
        );
      }

      return signature;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.signatureFailed_7285(e),
        );
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
      debugPrint(
        LocalizationService.instance.current.generateAuthToken(clientId),
      );
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
          debugPrint(
            LocalizationService.instance.current.tokenVerificationFailed_7421(
              'Client ID mismatch',
            ),
          );
        }
        return false;
      }

      if (timestamp == null) {
        if (kDebugMode) {
          debugPrint(
            LocalizationService
                .instance
                .current
                .tokenValidationFailedTimestampMissing_4821,
          );
        }
        return false;
      }

      // 检查令牌是否过期（5分钟有效期）
      final now = DateTime.now().millisecondsSinceEpoch;
      final tokenAge = now - timestamp;
      const maxAge = 5 * 60 * 1000; // 5分钟

      if (tokenAge > maxAge) {
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.tokenValidationFailed_7281,
          );
        }
        return false;
      }

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.tokenValidationSuccess(
            clientId ?? 'unknown',
          ),
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.tokenVerificationFailed_7421(e),
        );
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
