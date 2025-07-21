import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// WebDAV安全存储服务
/// 使用flutter_secure_storage安全存储WebDAV认证凭据
class WebDavSecureStorageService {
  static final WebDavSecureStorageService _instance =
      WebDavSecureStorageService._internal();
  factory WebDavSecureStorageService() => _instance;
  WebDavSecureStorageService._internal();

  /// 安全存储实例
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(
      useBackwardCompatibility: false,
    ),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// 密码存储前缀
  static const String _passwordPrefix = 'webdav_password_';

  /// 初始化安全存储服务
  Future<void> initialize() async {
    // 安全存储服务不需要特殊初始化，_secureStorage 已在构造时初始化
    if (kDebugMode) {
      debugPrint('WebDAV安全存储服务初始化完成');
    }
  }

  /// 存储密码到安全存储
  Future<void> storePassword(String authAccountId, String password) async {
    try {
      final storageKey = '$_passwordPrefix$authAccountId';
      
      // macOS 平台使用 SharedPreferences 作为回退方案
      if (Platform.isMacOS) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(storageKey, password);
        if (kDebugMode) {
          debugPrint('WebDAV密码已存储到 SharedPreferences (macOS): $authAccountId');
        }
      } else {
        // 其他平台使用安全存储
        await _secureStorage.write(
          key: storageKey,
          value: password,
        );
        if (kDebugMode) {
          debugPrint('WebDAV密码已安全存储: $authAccountId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('存储WebDAV密码失败: $e');
      }
      rethrow;
    }
  }

  /// 从安全存储获取密码
  Future<String?> getPassword(String authAccountId) async {
    try {
      final storageKey = '$_passwordPrefix$authAccountId';
      String? password;
      
      // macOS 平台使用 SharedPreferences 作为回退方案
      if (Platform.isMacOS) {
        final prefs = await SharedPreferences.getInstance();
        password = prefs.getString(storageKey);
        if (kDebugMode && password != null) {
          debugPrint('WebDAV密码从 SharedPreferences 获取成功 (macOS): $authAccountId');
        }
      } else {
        // 其他平台使用安全存储
        password = await _secureStorage.read(key: storageKey);
        if (kDebugMode && password != null) {
          debugPrint('WebDAV密码获取成功: $authAccountId');
        }
      }
      
      if (password == null) {
        if (kDebugMode) {
          debugPrint('WebDAV密码未找到: $authAccountId');
        }
      }
      
      return password;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('获取WebDAV密码失败: $e');
      }
      return null;
    }
  }

  /// 删除密码
  Future<void> deletePassword(String authAccountId) async {
    try {
      final storageKey = '$_passwordPrefix$authAccountId';
      
      // macOS 平台使用 SharedPreferences 作为回退方案
      if (Platform.isMacOS) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(storageKey);
        if (kDebugMode) {
          debugPrint('WebDAV密码已从 SharedPreferences 删除 (macOS): $authAccountId');
        }
      } else {
        // 其他平台使用安全存储
        await _secureStorage.delete(key: storageKey);
        if (kDebugMode) {
          debugPrint('WebDAV密码已删除: $authAccountId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('删除WebDAV密码失败: $e');
      }
      rethrow;
    }
  }

  /// 验证密码是否存在
  Future<bool> hasPassword(String authAccountId) async {
    try {
      final storageKey = '$_passwordPrefix$authAccountId';
      String? password;
      
      // macOS 平台使用 SharedPreferences 作为回退方案
      if (Platform.isMacOS) {
        final prefs = await SharedPreferences.getInstance();
        password = prefs.getString(storageKey);
      } else {
        // 其他平台使用安全存储
        password = await _secureStorage.read(key: storageKey);
      }
      
      return password != null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('检查WebDAV密码存在性失败: $e');
      }
      return false;
    }
  }

  /// 获取所有存储的认证账户ID
  Future<List<String>> getAllAuthAccountIds() async {
    try {
      final authAccountIds = <String>[];
      
      // macOS 平台使用 SharedPreferences 作为回退方案
      if (Platform.isMacOS) {
        final prefs = await SharedPreferences.getInstance();
        final allKeys = prefs.getKeys();
        
        for (final key in allKeys) {
          if (key.startsWith(_passwordPrefix)) {
            final authAccountId = key.substring(_passwordPrefix.length);
            authAccountIds.add(authAccountId);
          }
        }
      } else {
        // 其他平台使用安全存储
        final allKeys = await _secureStorage.readAll();
        
        for (final key in allKeys.keys) {
          if (key.startsWith(_passwordPrefix)) {
            final authAccountId = key.substring(_passwordPrefix.length);
            authAccountIds.add(authAccountId);
          }
        }
      }
      
      return authAccountIds;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('获取所有WebDAV认证账户ID失败: $e');
      }
      return [];
    }
  }

  /// 清理所有密码（谨慎使用）
  Future<void> clearAllPasswords() async {
    try {
      // macOS 平台使用 SharedPreferences 作为回退方案
      if (Platform.isMacOS) {
        final prefs = await SharedPreferences.getInstance();
        final allKeys = prefs.getKeys();
        
        for (final key in allKeys) {
          if (key.startsWith(_passwordPrefix)) {
            await prefs.remove(key);
          }
        }
        
        if (kDebugMode) {
          debugPrint('所有WebDAV密码已从 SharedPreferences 清理 (macOS)');
        }
      } else {
        // 其他平台使用安全存储
        final allKeys = await _secureStorage.readAll();
        
        for (final key in allKeys.keys) {
          if (key.startsWith(_passwordPrefix)) {
            await _secureStorage.delete(key: key);
          }
        }
        
        if (kDebugMode) {
          debugPrint('所有WebDAV密码已清理');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('清理所有WebDAV密码失败: $e');
      }
      rethrow;
    }
  }

  /// 更新密码
  Future<void> updatePassword(String authAccountId, String newPassword) async {
    await storePassword(authAccountId, newPassword);
  }

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final authAccountIds = await getAllAuthAccountIds();
      
      return {
        'password_count': authAccountIds.length,
        'auth_account_ids': authAccountIds,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('获取WebDAV存储统计信息失败: $e');
      }
      return {
        'password_count': 0,
        'auth_account_ids': <String>[],
        'error': e.toString(),
      };
    }
  }

  /// 验证认证凭据（测试连接时使用）
  Future<bool> validateCredentials(
    String authAccountId,
    String username,
    String? password,
  ) async {
    try {
      // 如果没有提供密码，从安全存储获取
      final actualPassword = password ?? await getPassword(authAccountId);
      
      if (actualPassword == null) {
        if (kDebugMode) {
          debugPrint('WebDAV认证凭据验证失败：密码未找到');
        }
        return false;
      }
      
      // 这里可以添加更多的验证逻辑
      // 比如检查用户名格式、密码强度等
      
      return username.isNotEmpty && actualPassword.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WebDAV认证凭据验证失败: $e');
      }
      return false;
    }
  }
}