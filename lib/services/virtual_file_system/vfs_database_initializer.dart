import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'vfs_storage_service.dart';
import 'vfs_protocol.dart';
import 'vfs_permission_system.dart';

/// VFS数据库初始化服务
/// 用于在应用启动时统一初始化VFS系统，包括根文件系统和应用数据库
class VfsDatabaseInitializer {
  static final VfsDatabaseInitializer _instance =
      VfsDatabaseInitializer._internal();
  factory VfsDatabaseInitializer() => _instance;
  VfsDatabaseInitializer._internal();

  final VfsStorageService _storage = VfsStorageService();
  final VfsPermissionManager _permissionManager = VfsPermissionManager();

  /// 在应用启动时初始化整个VFS系统
  /// 包括根文件系统、权限系统、挂载点以及应用数据库
  Future<void> initializeApplicationVfs() async {
    try {
      debugPrint('开始初始化应用VFS系统...');

      // 1. 初始化权限系统
      await _permissionManager.initialize();

      // 2. 初始化根文件系统
      await _initializeRootFileSystem();

      // 3. 初始化应用数据库和挂载点
      await _initializeApplicationDatabases();

      debugPrint('应用VFS系统初始化完成');
    } catch (e) {
      debugPrint('应用VFS系统初始化失败: $e');
      rethrow;
    }
  }

  /// 初始化根文件系统（保持向后兼容）
  Future<void> initializeDefaultDatabase() async {
    await _initializeRootFileSystem();
  }

  /// 初始化根文件系统
  Future<void> _initializeRootFileSystem() async {
    try {
      debugPrint('开始初始化VFS根文件系统...');

      // 检查是否已经初始化过
      if (await _isAlreadyInitialized()) {
        debugPrint('VFS根文件系统已存在，跳过初始化');
        return;
      }

      // 创建根文件系统
      await _createRootFileSystem();

      // 设置系统保护路径的权限
      await _setupSystemPermissions();

      // 标记为已初始化
      await _markAsInitialized();

      debugPrint('VFS根文件系统初始化完成');
    } catch (e) {
      debugPrint('VFS根文件系统初始化失败: $e');
      rethrow;
    }
  }

  /// 初始化应用数据库和挂载点
  Future<void> _initializeApplicationDatabases() async {
    try {
      debugPrint('开始初始化应用数据库...');

      // 创建应用数据库的集合目录
      const databaseName = 'r6box';
      final collections = [
        'legends',
      ];

      for (final collection in collections) {
        await _storage.createDirectory(
          'indexeddb://$databaseName/$collection/',
        );
        debugPrint('创建应用集合目录: /$collection/');
      }

      // 为legends集合创建挂载点到/mnt/
      await _storage.createDirectory(
        'indexeddb://$databaseName/fs/mnt/legends/',
      );
      debugPrint('创建legends挂载点: /mnt/legends/');

      debugPrint('应用数据库初始化完成');
    } catch (e) {
      debugPrint('应用数据库初始化失败: $e');
      rethrow;
    }
  }

  /// 检查是否已经初始化过
  Future<bool> _isAlreadyInitialized() async {
    try {
      return await _storage.exists('indexeddb://r6box/fs/.initialized');
    } catch (e) {
      return false;
    }
  }

  /// 创建根文件系统
  Future<void> _createRootFileSystem() async {
    // 创建根文件系统 - 使用 'r6box' 作为数据库名，'fs' 作为集合名
    const databaseName = 'r6box';
    const collectionName = 'fs';

    // 创建根目录（空目录）
    await _storage.createDirectory(
      'indexeddb://$databaseName/$collectionName/',
    );
    debugPrint('创建根目录: /');

    // 创建挂载点目录，供其他数据库挂载使用
    await _storage.createDirectory(
      'indexeddb://$databaseName/$collectionName/mnt/',
    );
    debugPrint('创建挂载点目录: /mnt/');
  }

  /// 标记为已初始化
  Future<void> _markAsInitialized() async {
    final content = VfsFileContent(
      data: utf8.encode(
        json.encode({
          'initialized_at': DateTime.now().toIso8601String(),
          'version': '1.0.0',
          'description': 'Clean root file system for user file management',
        }),
      ),
      mimeType: 'application/json',
    );
    await _storage.writeFile('indexeddb://r6box/fs/.initialized', content);
    debugPrint('VFS根文件系统标记为已初始化');
  }

  /// 设置系统权限
  Future<void> _setupSystemPermissions() async {
    // 设置根目录权限（用户可读写）
    await _permissionManager.setPermissions(
      'indexeddb://r6box/fs/',
      VfsPermissionMask.defaultUser,
    );

    // 设置挂载点权限（系统保护，用户可访问但不能删除）
    await _permissionManager.setPermissions(
      'indexeddb://r6box/fs/mnt/',
      VfsPermissionMask.mountPoint,
    );

    // 设置初始化标记文件权限（系统保护）
    await _permissionManager.setPermissions(
      'indexeddb://r6box/fs/.initialized',
      VfsPermissionMask.systemProtected,
    );

    debugPrint('系统权限设置完成');
  }

  /// 获取数据库统计信息
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final databases = await _storage.getAllDatabases();
      final stats = <String, dynamic>{
        'total_databases': databases.length,
        'databases': <String, dynamic>{},
      };

      for (final dbName in databases) {
        final collections = await _storage.getCollections(dbName);
        int totalFiles = 0;
        int totalSize = 0;

        for (final collection in collections) {
          try {
            final collectionStats = await _storage.getStorageStats(
              dbName,
              collection,
            );
            totalFiles += collectionStats['totalFiles'] as int;
            totalSize += collectionStats['totalSize'] as int;
          } catch (e) {
            debugPrint('获取集合统计失败: $dbName/$collection - $e');
          }
        }

        stats['databases'][dbName] = {
          'collections': collections.length,
          'total_files': totalFiles,
          'total_size': totalSize,
        };
      }

      return stats;
    } catch (e) {
      debugPrint('获取数据库统计信息失败: $e');
      return {'error': e.toString()};
    }
  }
}
