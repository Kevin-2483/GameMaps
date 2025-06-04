import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'vfs_protocol.dart';
import 'vfs_storage_service.dart';
import 'vfs_permission_system.dart';

/// 虚拟文件系统管理器
/// 提供高级文件系统操作接口
class VirtualFileSystem {
  static final VirtualFileSystem _instance = VirtualFileSystem._internal();
  factory VirtualFileSystem() => _instance;
  VirtualFileSystem._internal();

  final VfsStorageService _storage = VfsStorageService();
  final VfsPermissionManager _permissionManager = VfsPermissionManager();
  final Map<String, VfsMount> _mounts = {};

  /// 初始化虚拟文件系统
  Future<void> initialize() async {
    await _permissionManager.initialize();
  }

  /// 挂载虚拟文件系统
  void mount(String database, String collection, {VfsMount? mount}) {
    final key = '$database/$collection';
    _mounts[key] = mount ?? VfsMount(database: database, collection: collection);
  }

  /// 卸载虚拟文件系统
  void unmount(String database, String collection) {
    final key = '$database/$collection';
    _mounts.remove(key);
  }

  /// 检查是否已挂载
  bool isMounted(String database, String collection) {
    final key = '$database/$collection';
    return _mounts.containsKey(key);
  }

  /// 获取挂载信息
  VfsMount? getMount(String database, String collection) {
    final key = '$database/$collection';
    return _mounts[key];
  }

  /// 列出所有挂载点
  List<VfsMount> getMounts() {
    return _mounts.values.toList();
  }

  /// 检查文件是否存在
  Future<bool> exists(String path) async {
    _validatePath(path);
    return await _storage.exists(path);
  }
  /// 读取文件内容
  Future<VfsFileContent?> readFile(String path) async {
    _validatePath(path);
    await _validateReadPermission(path);
    return await _storage.readFile(path);
  }

  /// 读取文本文件
  Future<String?> readTextFile(String path, {String encoding = 'utf-8'}) async {
    final content = await readFile(path);
    if (content == null) return null;

    try {
      if (encoding.toLowerCase() == 'utf-8') {
        return utf8.decode(content.data);
      } else {
        // 其他编码支持
        return String.fromCharCodes(content.data);
      }
    } catch (e) {
      throw VfsException('Failed to decode text file: $e', path: path);
    }
  }

  /// 读取 JSON 文件
  Future<Map<String, dynamic>?> readJsonFile(String path) async {
    final textContent = await readTextFile(path);
    if (textContent == null) return null;

    try {
      return jsonDecode(textContent) as Map<String, dynamic>;
    } catch (e) {
      throw VfsException('Failed to parse JSON file: $e', path: path);
    }
  }
  /// 写入文件内容
  Future<void> writeFile(
    String path, 
    VfsFileContent content, {
    bool createDirectories = true,
  }) async {
    _validatePath(path);
    await _validateWritePermission(path);
    await _storage.writeFile(path, content, createDirectories: createDirectories);
  }

  /// 写入文本文件
  Future<void> writeTextFile(
    String path, 
    String content, {
    String encoding = 'utf-8',
    String? mimeType,
    Map<String, dynamic>? metadata,
    bool createDirectories = true,
  }) async {
    Uint8List data;
    try {
      if (encoding.toLowerCase() == 'utf-8') {
        data = Uint8List.fromList(utf8.encode(content));
      } else {
        data = Uint8List.fromList(content.codeUnits);
      }
    } catch (e) {
      throw VfsException('Failed to encode text content: $e', path: path);
    }

    final fileContent = VfsFileContent(
      data: data,
      mimeType: mimeType ?? 'text/plain; charset=$encoding',
      metadata: metadata,
    );

    await writeFile(path, fileContent, createDirectories: createDirectories);
  }

  /// 写入 JSON 文件
  Future<void> writeJsonFile(
    String path, 
    Map<String, dynamic> data, {
    bool prettyPrint = false,
    Map<String, dynamic>? metadata,
    bool createDirectories = true,
  }) async {
    String jsonString;
    try {
      if (prettyPrint) {
        const encoder = JsonEncoder.withIndent('  ');
        jsonString = encoder.convert(data);
      } else {
        jsonString = jsonEncode(data);
      }
    } catch (e) {
      throw VfsException('Failed to encode JSON data: $e', path: path);
    }

    await writeTextFile(
      path, 
      jsonString,
      mimeType: 'application/json',
      metadata: metadata,
      createDirectories: createDirectories,
    );
  }

  /// 写入二进制文件
  Future<void> writeBinaryFile(
    String path, 
    Uint8List data, {
    String? mimeType,
    Map<String, dynamic>? metadata,
    bool createDirectories = true,
  }) async {
    final fileContent = VfsFileContent(
      data: data,
      mimeType: mimeType ?? 'application/octet-stream',
      metadata: metadata,
    );

    await writeFile(path, fileContent, createDirectories: createDirectories);
  }
  /// 创建目录
  Future<void> createDirectory(String path, {VfsInheritancePolicy? inheritancePolicy}) async {
    _validatePath(path);
    await _validateWritePermission(path);
    await _storage.createDirectory(path);
    
    // 设置目录权限
    final policy = inheritancePolicy ?? VfsInheritancePolicy.defaultPolicy;
    final permissions = await _permissionManager.applyInheritance(path, policy);
    await _permissionManager.setPermissions(path, permissions);
  }

  /// 删除文件或目录
  Future<bool> delete(String path, {bool recursive = false}) async {
    _validatePath(path);
    await _validateDeletePermission(path);
    return await _storage.delete(path, recursive: recursive);
  }
  /// 移动/重命名文件或目录
  Future<bool> move(String fromPath, String toPath) async {
    _validatePath(fromPath);
    _validatePath(toPath);
    await _validateDeletePermission(fromPath);
    await _validateWritePermission(toPath);
    return await _storage.move(fromPath, toPath);
  }

  /// 复制文件或目录
  Future<bool> copy(String fromPath, String toPath) async {
    _validatePath(fromPath);
    _validatePath(toPath);
    await _validateReadPermission(fromPath);
    await _validateWritePermission(toPath);
    return await _storage.copy(fromPath, toPath);
  }

  /// 列出目录内容
  Future<List<VfsFileInfo>> listDirectory(String path) async {
    _validatePath(path);
    return await _storage.listDirectory(path);
  }

  /// 获取文件信息
  Future<VfsFileInfo?> getFileInfo(String path) async {
    _validatePath(path);
    return await _storage.getFileInfo(path);
  }
  /// 搜索文件
  Future<List<VfsFileInfo>> search(
    String database, 
    String collection, 
    String pattern, {
    bool caseSensitive = false,
    bool includeDirectories = true,
    int? maxResults,
  }) async {
    if (!isMounted(database, collection)) {
      throw VfsException('Database/collection not mounted: $database/$collection');
    }

    debugPrint('🔍 VFS: search called with pattern: "$pattern", caseSensitive: $caseSensitive, includeDirectories: $includeDirectories');

    // 简单的文件名匹配搜索
    final rootPath = VfsProtocol.buildPath(database, collection, '');
    final allFiles = await _getAllFilesRecursive(rootPath);
    
    final regexPattern = pattern.replaceAll('*', '.*').replaceAll('?', '.');
    final regex = RegExp(regexPattern, caseSensitive: caseSensitive);
    
    debugPrint('🔍 VFS: regex pattern: "$regexPattern"');
    debugPrint('🔍 VFS: found ${allFiles.length} total files');

    var results = allFiles.where((file) {
      if (!includeDirectories && file.isDirectory) {
        debugPrint('🔍 VFS: skipping directory: ${file.name}');
        return false;
      }
      final matches = regex.hasMatch(file.name);
      debugPrint('🔍 VFS: testing "${file.name}" against pattern - matches: $matches');
      return matches;    }).toList();

    debugPrint('🔍 VFS: search found ${results.length} matching files');
    for (final result in results) {
      debugPrint('🔍 VFS: result: ${result.name} (${result.isDirectory ? 'DIR' : 'FILE'})');
    }

    if (maxResults != null && results.length > maxResults) {
      results = results.take(maxResults).toList();
    }

    return results;
  }

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats(String database, String collection) async {
    if (!isMounted(database, collection)) {
      throw VfsException('Database/collection not mounted: $database/$collection');
    }

    return await _storage.getStorageStats(database, collection);
  }
  /// 清空集合
  Future<void> clearCollection(String database, String collection) async {
    if (!isMounted(database, collection)) {
      throw VfsException('Database/collection not mounted: $database/$collection');
    }

    _validateWritePermission(VfsProtocol.buildPath(database, collection, ''));
    await _storage.clearCollection(database, collection);
    
    // 清除权限缓存，确保下次访问时重新加载权限
    _permissionManager.clearCache();
  }

  /// 创建文件观察器
  VfsWatcher watch(String path, {bool recursive = false}) {
    _validatePath(path);
    return VfsWatcher(path, recursive: recursive);
  }

  /// 获取 MIME 类型
  String? getMimeType(String path) {
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) return null;

    final extension = vfsPath.extension;
    if (extension == null) return null;

    // 基本 MIME 类型映射
    const mimeTypes = {
      'json': 'application/json',
      'txt': 'text/plain',
      'md': 'text/markdown',
      'html': 'text/html',
      'css': 'text/css',
      'js': 'application/javascript',
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'gif': 'image/gif',
      'svg': 'image/svg+xml',
      'pdf': 'application/pdf',
      'zip': 'application/zip',
      'xml': 'application/xml',
    };

    return mimeTypes[extension] ?? 'application/octet-stream';
  }
  /// 递归获取所有文件
  Future<List<VfsFileInfo>> _getAllFilesRecursive(String path) async {
    debugPrint('🔍 VFS: _getAllFilesRecursive called with path: $path');
    
    try {
      // 直接使用存储服务的递归查询方法，不受深度限制
      final result = await _storage.getAllFilesRecursive(path);
      debugPrint('🔍 VFS: _getAllFilesRecursive found ${result.length} files');
      return result;
    } catch (e) {
      debugPrint('🔍 VFS: Failed to get files recursively from $path: $e');
      return [];
    }
  }

  /// 验证路径格式
  void _validatePath(String path) {
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) {
      throw VfsException('Invalid path format', path: path);
    }

    if (!isMounted(vfsPath.database, vfsPath.collection)) {
      throw VfsException(
        'Database/collection not mounted: ${vfsPath.database}/${vfsPath.collection}',
        path: path,
      );
    }
  }
  /// 验证写入权限
  Future<void> _validateWritePermission(String path) async {
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) return;

    final mount = getMount(vfsPath.database, vfsPath.collection);
    if (mount != null && mount.isReadOnly) {
      throw VfsException('Write operation not allowed on read-only mount', path: path);
    }

    // 检查文件权限
    final canWrite = await _permissionManager.canWrite(path);
    if (!canWrite) {
      throw VfsException('Write permission denied', path: path, code: 'PERMISSION_DENIED');
    }
  }

  /// 验证读取权限
  Future<void> _validateReadPermission(String path) async {
    final canRead = await _permissionManager.canRead(path);
    if (!canRead) {
      throw VfsException('Read permission denied', path: path, code: 'PERMISSION_DENIED');
    }
  }

  /// 验证删除权限
  Future<void> _validateDeletePermission(String path) async {
    final canDelete = await _permissionManager.canDelete(path);
    if (!canDelete) {
      throw VfsException('Delete permission denied', path: path, code: 'PERMISSION_DENIED');
    }
  }

  /// 获取文件权限
  Future<VfsPermissionMask> getPermissions(String path) async {
    return await _permissionManager.getPermissions(path);
  }

  /// 设置文件权限
  Future<void> setPermissions(String path, VfsPermissionMask permissions) async {
    _validatePath(path);
    await _permissionManager.setPermissions(path, permissions);
  }

  /// 检查权限
  Future<bool> hasPermission(
    String path,
    int permission, {
    VfsPermissionType type = VfsPermissionType.user,
  }) async {
    return await _permissionManager.checkPermission(path, permission, type: type);
  }

  /// 列出目录内容（带权限过滤）
  Future<List<VfsFileInfo>> listDirectoryWithPermissions(String path) async {
    _validatePath(path);
    await _validateReadPermission(path);
    
    final files = await _storage.listDirectory(path);
    return await _permissionManager.filterByPermissions(files);
  }
  /// 创建文件时应用权限继承
  Future<void> createFileWithInheritance(
    String path,
    VfsFileContent content, {
    VfsInheritancePolicy? inheritancePolicy,
    bool createDirectories = true,
  }) async {
    _validatePath(path);
    
    final policy = inheritancePolicy ?? VfsInheritancePolicy.defaultPolicy;
    
    // 对于权限继承，我们需要特殊处理：
    // 如果使用继承策略，先应用继承权限，再允许创建文件
    if (policy.inheritFromParent) {
      // 应用权限继承
      final permissions = await _permissionManager.applyInheritance(path, policy);
      
      // 对于继承策略，我们跳过普通的写权限检查，直接创建文件
      await _storage.writeFile(path, content, createDirectories: createDirectories);
      
      // 设置继承的权限
      await _permissionManager.setPermissions(path, permissions);
    } else {
      // 普通的文件创建，需要检查写权限
      await _validateWritePermission(path);
      await _storage.writeFile(path, content, createDirectories: createDirectories);
      
      // 设置默认权限
      await _permissionManager.setPermissions(path, policy.defaultMask);
    }
  }

  /// 关闭文件系统
  Future<void> close() async {
    _mounts.clear();
    await _storage.close();
  }
}

/// 虚拟文件系统挂载点
class VfsMount {
  final String database;
  final String collection;
  final bool isReadOnly;
  final Map<String, dynamic> options;

  const VfsMount({
    required this.database,
    required this.collection,
    this.isReadOnly = false,
    this.options = const {},
  });

  /// 获取挂载路径
  String get mountPath => VfsProtocol.buildPath(database, collection, '');

  @override
  String toString() => 'VfsMount($database/$collection)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VfsMount &&
           other.database == database &&
           other.collection == collection;
  }

  @override
  int get hashCode => Object.hash(database, collection);
}

/// 文件系统观察器（简单实现）
class VfsWatcher {
  final String path;
  final bool recursive;
  bool _isActive = false;

  VfsWatcher(this.path, {this.recursive = false});

  /// 开始观察
  void start() {
    _isActive = true;
    // 实际实现中可以添加文件变化监听
  }

  /// 停止观察
  void stop() {
    _isActive = false;
  }

  /// 是否处于活动状态
  bool get isActive => _isActive;
}
