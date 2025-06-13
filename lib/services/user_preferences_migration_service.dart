import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';
import 'user_preferences_database_service.dart';

/// 用户偏好设置数据迁移服务
/// 用于将SharedPreferences中的数据迁移到SQLite数据库
class UserPreferencesMigrationService {
  static final UserPreferencesMigrationService _instance =
      UserPreferencesMigrationService._internal();
  factory UserPreferencesMigrationService() => _instance;
  UserPreferencesMigrationService._internal();

  final UserPreferencesDatabaseService _dbService =
      UserPreferencesDatabaseService();

  static const String _legacyPreferencesKey = 'user_preferences';
  static const String _legacyUserProfilesKey = 'user_profiles';
  static const String _legacyCurrentUserKey = 'current_user_id';
  static const String _migrationCompleteKey = 'preferences_migration_complete';

  /// 控制是否启用迁移功能（可以通过配置禁用）
  static const bool _migrationEnabled = true;

  /// 快速检查是否需要迁移（使用缓存标记）
  static bool? _migrationChecked;
  static bool _needsMigration = false;

  /// 静态方法快速检查是否已完成迁移
  static Future<bool> isMigrationComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_migrationCompleteKey) == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> needsMigration() async {
    // 如果迁移功能被禁用，直接返回false
    if (!_migrationEnabled) {
      return false;
    }

    // 如果已经检查过，直接返回缓存结果
    if (_migrationChecked != null) {
      return _needsMigration;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // 如果已经迁移过，标记为不需要迁移
      if (prefs.getBool(_migrationCompleteKey) == true) {
        _migrationChecked = true;
        _needsMigration = false;
        return false;
      }

      // 检查是否有旧数据
      final hasLegacyData =
          prefs.containsKey(_legacyPreferencesKey) ||
          prefs.containsKey(_legacyUserProfilesKey);

      _migrationChecked = true;
      _needsMigration = hasLegacyData;

      if (kDebugMode && hasLegacyData) {
        print('检测到需要迁移的旧数据');
      }

      return hasLegacyData;
    } catch (e) {
      if (kDebugMode) {
        print('检查迁移状态失败: $e');
      }
      _migrationChecked = true;
      _needsMigration = false;
      return false;
    }
  }

  /// 执行数据迁移
  Future<bool> performMigration() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 如果已经迁移过，跳过
      if (prefs.getBool(_migrationCompleteKey) == true) {
        if (kDebugMode) {
          print('数据已经迁移过，跳过迁移');
        }
        return true;
      }

      int migratedUsersCount = 0;

      // 迁移用户配置文件
      final userProfilesJson = prefs.getString(_legacyUserProfilesKey);
      if (userProfilesJson != null) {
        try {
          final profilesData =
              jsonDecode(userProfilesJson) as Map<String, dynamic>;

          for (final entry in profilesData.entries) {
            final preferencesData = entry.value as Map<String, dynamic>;
            final preferences = UserPreferences.fromJson(preferencesData);

            // 保存到数据库
            await _dbService.savePreferences(preferences);
            migratedUsersCount++;

            if (kDebugMode) {
              print('迁移用户配置: ${preferences.displayName}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('迁移用户配置文件失败: $e');
          }
        }
      }

      // 迁移单个用户偏好设置（旧格式）
      final legacyPreferencesJson = prefs.getString(_legacyPreferencesKey);
      if (legacyPreferencesJson != null && migratedUsersCount == 0) {
        try {
          final json =
              jsonDecode(legacyPreferencesJson) as Map<String, dynamic>;
          final preferences = UserPreferences.fromJson(json);

          // 如果没有用户ID，生成一个
          if (preferences.userId == null) {
            final updatedPreferences = preferences.copyWith(
              userId: DateTime.now().millisecondsSinceEpoch.toString(),
            );
            await _dbService.savePreferences(updatedPreferences);
          } else {
            await _dbService.savePreferences(preferences);
          }

          migratedUsersCount++;

          if (kDebugMode) {
            print('迁移传统用户偏好设置: ${preferences.displayName}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('迁移传统用户偏好设置失败: $e');
          }
        }
      }

      // 设置当前用户
      final currentUserId = prefs.getString(_legacyCurrentUserKey);
      if (currentUserId != null && currentUserId.isNotEmpty) {
        final userExists = await _dbService.userExists(currentUserId);
        if (userExists) {
          await _dbService.setCurrentUser(currentUserId);
          if (kDebugMode) {
            print('设置当前用户: $currentUserId');
          }
        }
      }

      // 标记迁移完成
      await prefs.setBool(_migrationCompleteKey, true);

      if (kDebugMode) {
        print('用户偏好设置迁移完成，迁移了 $migratedUsersCount 个用户');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('数据迁移失败: $e');
      }
      return false;
    }
  }

  /// 清理旧数据（可选，迁移完成后调用）
  Future<void> cleanupLegacyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 删除旧的数据
      await prefs.remove(_legacyPreferencesKey);
      await prefs.remove(_legacyUserProfilesKey);
      await prefs.remove(_legacyCurrentUserKey);

      if (kDebugMode) {
        print('旧数据清理完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('清理旧数据失败: $e');
      }
    }
  }

  /// 重置迁移状态（仅用于测试）
  Future<void> resetMigrationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_migrationCompleteKey);

      if (kDebugMode) {
        print('迁移状态已重置');
      }
    } catch (e) {
      if (kDebugMode) {
        print('重置迁移状态失败: $e');
      }
    }
  }

  /// 获取迁移统计信息
  Future<Map<String, dynamic>> getMigrationStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dbStats = await _dbService.getStorageStats();

      return {
        'migrationComplete': prefs.getBool(_migrationCompleteKey) ?? false,
        'hasLegacyPreferences': prefs.containsKey(_legacyPreferencesKey),
        'hasLegacyUserProfiles': prefs.containsKey(_legacyUserProfilesKey),
        'hasLegacyCurrentUser': prefs.containsKey(_legacyCurrentUserKey),
        'databaseStats': dbStats,
      };
    } catch (e) {
      if (kDebugMode) {
        print('获取迁移统计信息失败: $e');
      }
      return {'error': e.toString()};
    }
  }
}
