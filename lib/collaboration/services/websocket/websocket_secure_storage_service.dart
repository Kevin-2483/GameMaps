// This file has been processed by AI for internationalization
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fast_rsa/fast_rsa.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/localization_service.dart';

/// RSA 密钥对
class KeyPair {
  final String publicKey;
  final String privateKey;

  KeyPair({required this.publicKey, required this.privateKey});
}

/// WebSocket 客户端安全存储服务
/// 使用 flutter_secure_storage 安全存储 RSA 私钥
class WebSocketSecureStorageService {
  static final WebSocketSecureStorageService _instance =
      WebSocketSecureStorageService._internal();
  factory WebSocketSecureStorageService() => _instance;
  WebSocketSecureStorageService._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(useBackwardCompatibility: false),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// 私钥存储前缀
  static const String _privateKeyPrefix = 'websocket_private_key_';

  /// 初始化安全存储服务
  Future<void> initialize() async {
    // 安全存储服务不需要特殊初始化，_secureStorage 已在构造时初始化
    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.webSocketInitComplete_4821,
      );
    }
  }

  /// 生成 RSA 密钥对
  Future<KeyPair> generateKeyPair() async {
    try {
      final keyPair = await RSA.generate(2048);
      return KeyPair(
        publicKey: keyPair.publicKey,
        privateKey: keyPair.privateKey,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.rsaKeyPairGenerationFailed(e),
        );
      }
      rethrow;
    }
  }

  /// 将 RSA PUBLIC KEY 格式转换为 PUBLIC KEY 格式 (PKCS1 → PKIX)
  Future<String> convertPublicKeyToPKIX(String rsaPublicKeyPem) async {
    try {
      final pkixKey = await RSA.convertPublicKeyToPKIX(rsaPublicKeyPem);
      if (kDebugMode) {
        debugPrint(
          LocalizationService
              .instance
              .current
              .publicKeyFormatConversionSuccess_7281,
        );
      }
      return pkixKey;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.publicKeyConversionFailed_7285(
            e,
          ),
        );
      }
      rethrow;
    }
  }

  /// 生成服务器兼容的密钥对（PUBLIC KEY 格式）
  Future<KeyPair> generateServerCompatibleKeyPair() async {
    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.generatingRsaKeyPair_7284,
        );
      }

      final keyPair = await RSA.generate(2048);
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.rsaKeyPairGenerated_7281,
        );
      }
      // 转换公钥为 PKIX 格式 (PUBLIC KEY)
      final pkixPublicKey = await convertPublicKeyToPKIX(keyPair.publicKey);
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.publicKeyConversionComplete_4821,
        );
      }

      return KeyPair(publicKey: pkixPublicKey, privateKey: keyPair.privateKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.keyGenerationFailed_7285(e),
        );
      }
      rethrow;
    }
  }

  /// 存储私钥到安全存储
  Future<String> storePrivateKey(String privateKeyPem) async {
    try {
      // 生成唯一的私钥ID
      final privateKeyId = DateTime.now().millisecondsSinceEpoch.toString();
      final storageKey = '$_privateKeyPrefix$privateKeyId';

      // Web平台或macOS平台使用 SharedPreferences 作为回退方案
      if (kIsWeb || (!kIsWeb && Platform.isMacOS)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(storageKey, privateKeyPem);
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.privateKeyStoredMessage(
              kIsWeb ? "(Web)" : "(macOS)",
              privateKeyId,
            ),
          );
        }
      } else {
        // 其他平台使用安全存储
        await _secureStorage.write(key: storageKey, value: privateKeyPem);
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.privateKeyStoredSafely_4821(
              privateKeyId,
            ),
          );
        }
      }

      return privateKeyId;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.storePrivateKeyFailed_7285(e),
        );
      }
      rethrow;
    }
  }

  /// 从安全存储获取私钥
  Future<String?> getPrivateKey(String privateKeyId) async {
    try {
      final storageKey = '$_privateKeyPrefix$privateKeyId';
      String? privateKeyPem;

      // Web平台或macOS平台使用 SharedPreferences 作为回退方案
      if (kIsWeb || (!kIsWeb && Platform.isMacOS)) {
        final prefs = await SharedPreferences.getInstance();
        privateKeyPem = prefs.getString(storageKey);
        if (kDebugMode && privateKeyPem != null) {
          debugPrint(
            LocalizationService.instance.current
                .privateKeyRetrievedSuccessfully_7281(
                  kIsWeb ? "(Web)" : "(macOS)",
                  privateKeyId,
                ),
          );
        }
      } else {
        // 其他平台使用安全存储
        privateKeyPem = await _secureStorage.read(key: storageKey);
        if (kDebugMode && privateKeyPem != null) {
          debugPrint(
            LocalizationService.instance.current.privateKeyObtainedSuccessfully(
              privateKeyId,
            ),
          );
        }
      }

      if (privateKeyPem == null) {
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.privateKeyNotFound_7281(
              privateKeyId,
            ),
          );
        }
      }

      return privateKeyPem;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.privateKeyFetchFailed(e),
        );
      }
      return null;
    }
  }

  /// 删除私钥
  Future<void> deletePrivateKey(String privateKeyId) async {
    try {
      final storageKey = '$_privateKeyPrefix$privateKeyId';

      // Web平台或macOS平台使用 SharedPreferences 作为回退方案
      if (kIsWeb || (!kIsWeb && Platform.isMacOS)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(storageKey);
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.privateKeyRemovedLog(
              kIsWeb ? "(Web)" : "(macOS)",
              privateKeyId,
            ),
          );
        }
      } else {
        // 其他平台使用安全存储
        await _secureStorage.delete(key: storageKey);
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.privateKeyDeleted_7281(
              privateKeyId,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.deletePrivateKeyFailed(e),
        );
      }
      rethrow;
    }
  }

  /// 使用私钥解密数据
  Future<String> decryptWithPrivateKey(
    String privateKeyId,
    String encryptedData,
  ) async {
    try {
      // 获取私钥
      final privateKeyPem = await getPrivateKey(privateKeyId);
      if (privateKeyPem == null) {
        throw Exception(
          LocalizationService.instance.current.privateKeyNotFound_7285(
            privateKeyId,
          ),
        );
      }

      // 解密数据
      final decryptedData = await RSA.decryptPKCS1v15(
        encryptedData,
        privateKeyPem,
      );

      return decryptedData;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.privateKeyDecryptionFailed_4821(
            e,
          ),
        );
      }
      rethrow;
    }
  }

  /// 使用私钥签名数据
  Future<String> signWithPrivateKey(String privateKeyId, String data) async {
    try {
      // 获取私钥
      final privateKeyPem = await getPrivateKey(privateKeyId);
      if (privateKeyPem == null) {
        throw Exception(
          LocalizationService.instance.current.privateKeyNotFound_7285(
            privateKeyId,
          ),
        );
      }

      // 签名数据
      final signature = await RSA.signPKCS1v15(
        data,
        Hash.SHA256,
        privateKeyPem,
      );

      return signature;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.privateKeySignFailed_7285(e),
        );
      }
      rethrow;
    }
  }

  /// 验证私钥是否存在
  Future<bool> hasPrivateKey(String privateKeyId) async {
    try {
      final storageKey = '$_privateKeyPrefix$privateKeyId';
      String? privateKeyPem;

      // Web平台或macOS平台使用 SharedPreferences 作为回退方案
      if (kIsWeb || (!kIsWeb && Platform.isMacOS)) {
        final prefs = await SharedPreferences.getInstance();
        privateKeyPem = prefs.getString(storageKey);
      } else {
        privateKeyPem = await _secureStorage.read(key: storageKey);
      }

      return privateKeyPem != null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.checkPrivateKeyFailed_4821(e),
        );
      }
      return false;
    }
  }

  /// 获取所有存储的私钥ID
  Future<List<String>> getAllPrivateKeyIds() async {
    try {
      final privateKeyIds = <String>[];

      // Web平台或macOS平台使用 SharedPreferences 作为回退方案
      if (kIsWeb || (!kIsWeb && Platform.isMacOS)) {
        final prefs = await SharedPreferences.getInstance();
        final allKeys = prefs.getKeys();

        for (final key in allKeys) {
          if (key.startsWith(_privateKeyPrefix)) {
            final privateKeyId = key.substring(_privateKeyPrefix.length);
            privateKeyIds.add(privateKeyId);
          }
        }
      } else {
        final allKeys = await _secureStorage.readAll();

        for (final key in allKeys.keys) {
          if (key.startsWith(_privateKeyPrefix)) {
            final privateKeyId = key.substring(_privateKeyPrefix.length);
            privateKeyIds.add(privateKeyId);
          }
        }
      }

      return privateKeyIds;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.fetchPrivateKeyIdsFailed_7285(e),
        );
      }
      return [];
    }
  }

  /// 清理所有私钥（谨慎使用）
  Future<void> clearAllPrivateKeys() async {
    try {
      List<String> privateKeyKeys = [];

      // Web平台或macOS平台使用 SharedPreferences 作为回退方案
      if (kIsWeb || (!kIsWeb && Platform.isMacOS)) {
        final prefs = await SharedPreferences.getInstance();
        final allKeys = prefs.getKeys();
        privateKeyKeys = allKeys
            .where((key) => key.startsWith(_privateKeyPrefix))
            .toList();

        for (final key in privateKeyKeys) {
          await prefs.remove(key);
        }

        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.cleanedPrivateKeysCount(
              '${privateKeyKeys.length} ${kIsWeb ? "(Web)" : "(macOS)"}',
            ),
          );
        }
      } else {
        // 其他平台使用安全存储
        final allKeys = await _secureStorage.readAll();
        privateKeyKeys = allKeys.keys
            .where((key) => key.startsWith(_privateKeyPrefix))
            .toList();

        for (final key in privateKeyKeys) {
          await _secureStorage.delete(key: key);
        }

        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.cleanedPrivateKeysCount(
              privateKeyKeys.length,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.clearPrivateKeysFailed_7421(e),
        );
      }
      rethrow;
    }
  }

  /// 验证签名（可选功能）
  Future<bool> verifySignature(
    String message,
    String signature,
    String publicKey,
  ) async {
    try {
      final isValid = await RSA.verifyPKCS1v15(
        message,
        signature,
        Hash.SHA256,
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
          LocalizationService.instance.current.signatureVerificationFailed_4829(
            e,
          ),
        );
      }
      return false;
    }
  }

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final privateKeyIds = await getAllPrivateKeyIds();

      return {
        'private_key_count': privateKeyIds.length,
        'private_key_ids': privateKeyIds,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.storageStatsError_4821(e),
        );
      }
      return {
        'private_key_count': 0,
        'private_key_ids': <String>[],
        'error': e.toString(),
      };
    }
  }
}
