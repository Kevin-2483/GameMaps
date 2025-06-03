import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'vfs_protocol.dart';
import 'virtual_file_system.dart';
import 'vfs_database_initializer.dart';
import 'vfs_permission_system.dart';

/// 虚拟文件系统服务提供者
/// 为其他组件提供文件系统服务接口
class VfsServiceProvider {
  static final VfsServiceProvider _instance = VfsServiceProvider._internal();
  factory VfsServiceProvider() => _instance;
  VfsServiceProvider._internal();
  final VirtualFileSystem _vfs = VirtualFileSystem();
  final VfsDatabaseInitializer _initializer = VfsDatabaseInitializer();
    /// 初始化服务
  Future<void> initialize() async {
    // 首先初始化根文件系统
    await _initializer.initializeDefaultDatabase();
    
    // 初始化虚拟文件系统（包括权限系统）
    await _vfs.initialize();
    
    // 挂载根文件系统 - 这是默认的根目录，供用户文件管理使用
    _vfs.mount('r6box', 'fs');
    
    // 挂载默认的应用数据库
    _vfs.mount('r6box', 'app_data');
    _vfs.mount('r6box', 'user_data');
    _vfs.mount('r6box', 'maps');
    _vfs.mount('r6box', 'legends');
    _vfs.mount('r6box', 'cache');
    _vfs.mount('r6box', 'temp', mount: const VfsMount(
      database: 'r6box',
      collection: 'temp',
      isReadOnly: false,
      options: {'autoCleanup': true},
    ));

    debugPrint('VFS Service Provider initialized');
  }

  /// 为组件注册专用存储空间
  void registerComponent(String componentName, {bool readOnly = false}) {
    _vfs.mount('r6box', componentName, mount: VfsMount(
      database: 'r6box',
      collection: componentName,
      isReadOnly: readOnly,
    ));
    debugPrint('Registered component storage: $componentName');
  }

  /// 保存组件数据
  Future<void> saveComponentData(
    String componentName,
    String dataKey,
    Map<String, dynamic> data,
  ) async {
    final path = 'indexeddb://r6box/$componentName/$dataKey.json';
    await _vfs.writeJsonFile(path, data, prettyPrint: false);
  }

  /// 读取组件数据
  Future<Map<String, dynamic>?> loadComponentData(
    String componentName,
    String dataKey,
  ) async {
    final path = 'indexeddb://r6box/$componentName/$dataKey.json';
    return await _vfs.readJsonFile(path);
  }

  /// 保存用户文档
  Future<void> saveUserDocument(
    String userId,
    String documentId,
    Map<String, dynamic> document,
  ) async {
    final path = 'indexeddb://r6box/user_data/$userId/documents/$documentId.json';
    await _vfs.writeJsonFile(path, document, prettyPrint: true);
  }

  /// 读取用户文档
  Future<Map<String, dynamic>?> loadUserDocument(
    String userId,
    String documentId,
  ) async {
    final path = 'indexeddb://r6box/user_data/$userId/documents/$documentId.json';
    return await _vfs.readJsonFile(path);
  }

  /// 列出用户文档
  Future<List<String>> listUserDocuments(String userId) async {
    final path = 'indexeddb://r6box/user_data/$userId/documents';
    try {
      final files = await _vfs.listDirectory(path);
      return files
          .where((file) => !file.isDirectory && file.name.endsWith('.json'))
          .map((file) => file.name.replaceAll('.json', ''))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 保存图片资源
  Future<void> saveImageResource(
    String resourceId,
    Uint8List imageData,
    String mimeType,
  ) async {
    final extension = _getExtensionFromMimeType(mimeType);
    final path = 'indexeddb://r6box/app_data/images/$resourceId$extension';
    await _vfs.writeBinaryFile(path, imageData, mimeType: mimeType);
  }

  /// 读取图片资源
  Future<Uint8List?> loadImageResource(String resourceId) async {
    // 尝试多种可能的扩展名
    final extensions = ['.png', '.jpg', '.jpeg', '.gif', '.webp'];
    
    for (final ext in extensions) {
      final path = 'indexeddb://r6box/app_data/images/$resourceId$ext';
      if (await _vfs.exists(path)) {
        final content = await _vfs.readFile(path);
        return content?.data;
      }
    }
    
    return null;
  }

  /// 保存地图数据
  Future<void> saveMapData(
    String mapId,
    Map<String, dynamic> mapData,
  ) async {
    final path = 'indexeddb://r6box/maps/$mapId/data.json';
    await _vfs.writeJsonFile(path, mapData);
  }

  /// 读取地图数据
  Future<Map<String, dynamic>?> loadMapData(String mapId) async {
    final path = 'indexeddb://r6box/maps/$mapId/data.json';
    return await _vfs.readJsonFile(path);
  }

  /// 保存地图图片
  Future<void> saveMapImage(
    String mapId,
    Uint8List imageData,
    String mimeType,
  ) async {
    final extension = _getExtensionFromMimeType(mimeType);
    final path = 'indexeddb://r6box/maps/$mapId/image$extension';
    await _vfs.writeBinaryFile(path, imageData, mimeType: mimeType);
  }

  /// 读取地图图片
  Future<Uint8List?> loadMapImage(String mapId) async {
    final extensions = ['.png', '.jpg', '.jpeg'];
    
    for (final ext in extensions) {
      final path = 'indexeddb://r6box/maps/$mapId/image$ext';
      if (await _vfs.exists(path)) {
        final content = await _vfs.readFile(path);
        return content?.data;
      }
    }
    
    return null;
  }

  /// 缓存数据
  Future<void> cacheData(
    String cacheKey,
    Map<String, dynamic> data, {
    Duration? ttl,
  }) async {
    final cacheData = {
      'data': data,
      'cachedAt': DateTime.now().toIso8601String(),
      'ttl': ttl?.inMilliseconds,
    };
    
    final path = 'indexeddb://r6box/cache/$cacheKey.json';
    await _vfs.writeJsonFile(path, cacheData);
  }

  /// 读取缓存数据
  Future<Map<String, dynamic>?> getCachedData(String cacheKey) async {
    final path = 'indexeddb://r6box/cache/$cacheKey.json';
    final cacheData = await _vfs.readJsonFile(path);
    
    if (cacheData == null) return null;
    
    // 检查TTL
    final ttl = cacheData['ttl'] as int?;
    if (ttl != null) {
      final cachedAt = DateTime.parse(cacheData['cachedAt'] as String);
      final expiredAt = cachedAt.add(Duration(milliseconds: ttl));
      
      if (DateTime.now().isAfter(expiredAt)) {
        // 缓存已过期，删除并返回null
        await _vfs.delete(path);
        return null;
      }
    }
    
    return cacheData['data'] as Map<String, dynamic>?;
  }

  /// 清理过期缓存
  Future<void> cleanupExpiredCache() async {
    final path = 'indexeddb://r6box/cache';
    try {
      final files = await _vfs.listDirectory(path);
      final now = DateTime.now();
      
      for (final file in files) {
        if (file.isDirectory) continue;
        
        try {
          final cacheData = await _vfs.readJsonFile(file.path);
          if (cacheData == null) continue;
          
          final ttl = cacheData['ttl'] as int?;
          if (ttl != null) {
            final cachedAt = DateTime.parse(cacheData['cachedAt'] as String);
            final expiredAt = cachedAt.add(Duration(milliseconds: ttl));
            
            if (now.isAfter(expiredAt)) {
              await _vfs.delete(file.path);
              debugPrint('Cleaned up expired cache: ${file.name}');
            }
          }
        } catch (e) {
          debugPrint('Error cleaning cache file ${file.name}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error during cache cleanup: $e');
    }
  }

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    final collections = ['app_data', 'user_data', 'maps', 'legends', 'cache', 'temp'];
    final stats = <String, dynamic>{};
    int totalSize = 0;
    int totalFiles = 0;

    for (final collection in collections) {
      try {
        final collectionStats = await _vfs.getStorageStats('r6box', collection);
        stats[collection] = collectionStats;
        totalSize += collectionStats['totalSize'] as int;
        totalFiles += collectionStats['totalFiles'] as int;
      } catch (e) {
        stats[collection] = {
          'totalFiles': 0,
          'fileCount': 0,
          'directoryCount': 0,
          'totalSize': 0,
          'lastModified': null,
        };
      }
    }

    stats['summary'] = {
      'totalSize': totalSize,
      'totalFiles': totalFiles,
      'collections': collections.length,
    };

    return stats;
  }

  /// 搜索文件
  Future<List<VfsFileInfo>> searchFiles(
    String collection,
    String pattern, {
    bool caseSensitive = false,
    int? maxResults,
  }) async {
    return await _vfs.search(
      'r6box',
      collection,
      pattern,
      caseSensitive: caseSensitive,
      includeDirectories: false,
      maxResults: maxResults,
    );
  }

  /// 获取文件信息
  Future<VfsFileInfo?> getFileInfo(String collection, String filePath) async {
    final path = 'indexeddb://r6box/$collection/$filePath';
    return await _vfs.getFileInfo(path);
  }

  /// 删除文件或目录
  Future<bool> deleteFile(String collection, String filePath) async {
    final path = 'indexeddb://r6box/$collection/$filePath';
    return await _vfs.delete(path, recursive: true);
  }

  /// 列出目录内容
  Future<List<VfsFileInfo>> listFiles(String collection, [String? subPath]) async {
    final path = subPath != null 
        ? 'indexeddb://r6box/$collection/$subPath'
        : 'indexeddb://r6box/$collection';
    return await _vfs.listDirectory(path);
  }

  /// 创建目录
  Future<void> createDirectory(String collection, String dirPath) async {
    final path = 'indexeddb://r6box/$collection/$dirPath';
    await _vfs.createDirectory(path);
  }

  /// 检查文件是否存在
  Future<bool> fileExists(String collection, String filePath) async {
    final path = 'indexeddb://r6box/$collection/$filePath';
    return await _vfs.exists(path);
  }

  /// 复制文件
  Future<bool> copyFile(
    String fromCollection,
    String fromPath,
    String toCollection,
    String toPath,
  ) async {
    final fromFullPath = 'indexeddb://r6box/$fromCollection/$fromPath';
    final toFullPath = 'indexeddb://r6box/$toCollection/$toPath';
    return await _vfs.copy(fromFullPath, toFullPath);
  }

  /// 移动文件
  Future<bool> moveFile(
    String fromCollection,
    String fromPath,
    String toCollection,
    String toPath,
  ) async {
    final fromFullPath = 'indexeddb://r6box/$fromCollection/$fromPath';
    final toFullPath = 'indexeddb://r6box/$toCollection/$toPath';
    return await _vfs.move(fromFullPath, toFullPath);
  }

  /// 获取MIME类型
  String getMimeType(String filePath) {
    return _vfs.getMimeType('indexeddb://r6box/temp/$filePath') ?? 'application/octet-stream';
  }

  /// 从MIME类型获取文件扩展名
  String _getExtensionFromMimeType(String mimeType) {
    const mimeToExt = {
      'image/png': '.png',
      'image/jpeg': '.jpg',
      'image/jpg': '.jpg',
      'image/gif': '.gif',
      'image/webp': '.webp',
      'image/svg+xml': '.svg',
      'application/json': '.json',
      'text/plain': '.txt',
      'text/markdown': '.md',
      'application/pdf': '.pdf',
    };

    return mimeToExt[mimeType.toLowerCase()] ?? '.bin';
  }

  /// 获取虚拟文件系统实例（供高级用户使用）
  VirtualFileSystem get vfs => _vfs;

  /// 获取文件权限
  Future<VfsPermissionMask> getFilePermissions(String collection, String filePath) async {
    final path = 'indexeddb://r6box/$collection/$filePath';
    return await _vfs.getPermissions(path);
  }

  /// 设置文件权限
  Future<void> setFilePermissions(
    String collection,
    String filePath,
    VfsPermissionMask permissions,
  ) async {
    final path = 'indexeddb://r6box/$collection/$filePath';
    await _vfs.setPermissions(path, permissions);
  }

  /// 检查文件权限
  Future<bool> hasFilePermission(
    String collection,
    String filePath,
    int permission, {
    VfsPermissionType type = VfsPermissionType.user,
  }) async {
    final path = 'indexeddb://r6box/$collection/$filePath';
    return await _vfs.hasPermission(path, permission, type: type);
  }

  /// 创建文件时应用权限继承
  Future<void> createFileWithInheritance(
    String collection,
    String filePath,
    Uint8List data, {
    String? mimeType,
    VfsInheritancePolicy? inheritancePolicy,
  }) async {
    final path = 'indexeddb://r6box/$collection/$filePath';
    final content = VfsFileContent(
      data: data,
      mimeType: mimeType,
    );
    
    await _vfs.createFileWithInheritance(
      path,
      content,
      inheritancePolicy: inheritancePolicy,
    );
  }

  /// 创建目录时应用权限继承
  Future<void> createDirectoryWithInheritance(
    String collection,
    String dirPath, {
    VfsInheritancePolicy? inheritancePolicy,
  }) async {
    final path = 'indexeddb://r6box/$collection/$dirPath';
    await _vfs.createDirectory(path, inheritancePolicy: inheritancePolicy);
  }

  /// 列出目录内容（带权限过滤）
  Future<List<VfsFileInfo>> listFilesWithPermissions(String collection, [String? subPath]) async {
    final path = subPath != null 
        ? 'indexeddb://r6box/$collection/$subPath'
        : 'indexeddb://r6box/$collection';
    return await _vfs.listDirectoryWithPermissions(path);
  }

  /// 关闭服务
  Future<void> close() async {
    await _vfs.close();
  }
}
