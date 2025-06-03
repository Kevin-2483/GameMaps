import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'vfs_protocol.dart';
import 'vfs_storage_service.dart';

/// VFS权限位定义
class VfsPermission {
  /// 读取权限
  static const int read = 0x4;
  /// 写入权限
  static const int write = 0x2;
  /// 执行权限（用于目录访问）
  static const int execute = 0x1;
  
  /// 完全权限（读写执行）
  static const int full = read | write | execute;
  /// 只读权限
  static const int readOnly = read | execute;
  /// 无权限
  static const int none = 0x0;
  
  /// 系统保护权限（禁止删除和修改）
  static const int systemProtected = 0x8;
}

/// 权限掩码类型
enum VfsPermissionType {
  /// 用户权限
  user,
  /// 组权限
  group,
  /// 其他权限
  other,
  /// 系统权限
  system,
}

/// 权限掩码对象
class VfsPermissionMask {
  final int userPermissions;
  final int groupPermissions;
  final int otherPermissions;
  final int systemFlags;
  
  const VfsPermissionMask({
    required this.userPermissions,
    required this.groupPermissions,
    required this.otherPermissions,
    this.systemFlags = 0,
  });
  
  /// 默认用户权限（完全读写）
  static const VfsPermissionMask defaultUser = VfsPermissionMask(
    userPermissions: VfsPermission.full,
    groupPermissions: VfsPermission.readOnly,
    otherPermissions: VfsPermission.readOnly,
  );
  
  /// 系统保护权限（/mnt/ 和 .initialized）
  static const VfsPermissionMask systemProtected = VfsPermissionMask(
    userPermissions: VfsPermission.readOnly,
    groupPermissions: VfsPermission.readOnly,
    otherPermissions: VfsPermission.readOnly,
    systemFlags: VfsPermission.systemProtected,
  );
  
  /// 挂载点权限
  static const VfsPermissionMask mountPoint = VfsPermissionMask(
    userPermissions: VfsPermission.read | VfsPermission.execute,
    groupPermissions: VfsPermission.read | VfsPermission.execute,
    otherPermissions: VfsPermission.read | VfsPermission.execute,
    systemFlags: VfsPermission.systemProtected,
  );
  
  /// 检查权限
  bool hasPermission(VfsPermissionType type, int permission) {
    switch (type) {
      case VfsPermissionType.user:
        return (userPermissions & permission) == permission;
      case VfsPermissionType.group:
        return (groupPermissions & permission) == permission;
      case VfsPermissionType.other:
        return (otherPermissions & permission) == permission;
      case VfsPermissionType.system:
        return (systemFlags & permission) == permission;
    }
  }
  
  /// 是否为系统保护文件
  bool get isSystemProtected => (systemFlags & VfsPermission.systemProtected) != 0;
  
  /// 创建新的权限掩码
  VfsPermissionMask copyWith({
    int? userPermissions,
    int? groupPermissions,
    int? otherPermissions,
    int? systemFlags,
  }) {
    return VfsPermissionMask(
      userPermissions: userPermissions ?? this.userPermissions,
      groupPermissions: groupPermissions ?? this.groupPermissions,
      otherPermissions: otherPermissions ?? this.otherPermissions,
      systemFlags: systemFlags ?? this.systemFlags,
    );
  }
  
  /// 从JSON创建
  factory VfsPermissionMask.fromJson(Map<String, dynamic> json) {
    return VfsPermissionMask(
      userPermissions: json['userPermissions'] as int? ?? VfsPermission.full,
      groupPermissions: json['groupPermissions'] as int? ?? VfsPermission.readOnly,
      otherPermissions: json['otherPermissions'] as int? ?? VfsPermission.readOnly,
      systemFlags: json['systemFlags'] as int? ?? 0,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'userPermissions': userPermissions,
      'groupPermissions': groupPermissions,
      'otherPermissions': otherPermissions,
      'systemFlags': systemFlags,
    };
  }
  
  /// 转换为可读字符串
  String toString() {
    String permissionToString(int perm) {
      String result = '';
      result += (perm & VfsPermission.read) != 0 ? 'r' : '-';
      result += (perm & VfsPermission.write) != 0 ? 'w' : '-';
      result += (perm & VfsPermission.execute) != 0 ? 'x' : '-';
      return result;
    }
    
    final user = permissionToString(userPermissions);
    final group = permissionToString(groupPermissions);
    final other = permissionToString(otherPermissions);
    final protected = isSystemProtected ? 'P' : '-';
    
    return '$user$group$other$protected';
  }
}

/// 权限继承策略
class VfsInheritancePolicy {
  /// 是否继承父目录权限
  final bool inheritFromParent;
  /// 默认权限掩码
  final VfsPermissionMask defaultMask;
  /// 是否强制继承
  final bool forceInheritance;
  
  const VfsInheritancePolicy({
    this.inheritFromParent = false,
    this.defaultMask = VfsPermissionMask.defaultUser,
    this.forceInheritance = false,
  });
  
  /// 默认策略（不继承）
  static const VfsInheritancePolicy defaultPolicy = VfsInheritancePolicy();
  
  /// 继承策略
  static const VfsInheritancePolicy inheritancePolicy = VfsInheritancePolicy(
    inheritFromParent: true,
    forceInheritance: true,
  );
}

/// VFS权限管理器
class VfsPermissionManager {
  static final VfsPermissionManager _instance = VfsPermissionManager._internal();
  factory VfsPermissionManager() => _instance;
  VfsPermissionManager._internal();
  
  final VfsStorageService _storage = VfsStorageService();
  final Map<String, VfsPermissionMask> _permissionCache = {};
  
  /// 受保护的路径模式
  static const List<String> _protectedPaths = [
    '.initialized',
    'mnt/',
    'mnt',
  ];
  
  /// 初始化权限系统
  Future<void> initialize() async {
    debugPrint('Initializing VFS Permission System...');
    
    // 设置系统保护路径的权限
    await _setupSystemProtectedPaths();
    
    debugPrint('VFS Permission System initialized');
  }
  
  /// 设置系统保护路径
  Future<void> _setupSystemProtectedPaths() async {
    for (final path in _protectedPaths) {
      final fullPath = 'indexeddb://r6box/fs/$path';
      await setPermissions(fullPath, VfsPermissionMask.systemProtected);
    }
  }
  
  /// 获取文件/目录权限
  Future<VfsPermissionMask> getPermissions(String path) async {
    // 检查缓存
    if (_permissionCache.containsKey(path)) {
      return _permissionCache[path]!;
    }
    
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) {
      throw VfsException('Invalid path format', path: path);
    }
    
    // 检查是否为系统保护路径
    if (_isProtectedPath(vfsPath)) {
      return VfsPermissionMask.systemProtected;
    }
      try {
      // 从元数据中读取权限信息
      final metadata = await _storage.getCollectionMetadata(
        vfsPath.database,
        vfsPath.collection,
      );
      
      final permissionKey = 'permissions:${vfsPath.path}';
      if (metadata.containsKey(permissionKey)) {
        final permissionData = jsonDecode(metadata[permissionKey]!) as Map<String, dynamic>;
        final mask = VfsPermissionMask.fromJson(permissionData);
        _permissionCache[path] = mask;
        return mask;
      }
    } catch (e) {
      debugPrint('Failed to load permissions for $path: $e');
    }
    
    // 获取父目录权限（用于继承）
    final parentPermissions = await _getParentPermissions(vfsPath);
    
    // 使用默认权限或继承权限
    final permissions = parentPermissions ?? VfsPermissionMask.defaultUser;
    _permissionCache[path] = permissions;
    return permissions;
  }
  
  /// 设置文件/目录权限
  Future<void> setPermissions(String path, VfsPermissionMask permissions) async {
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) {
      throw VfsException('Invalid path format', path: path);
    }
      try {
      // 保存到元数据
      await _storage.setCollectionMetadata(
        vfsPath.database,
        vfsPath.collection,
        'permissions:${vfsPath.path}',
        jsonEncode(permissions.toJson()),
      );
      
      // 更新缓存
      _permissionCache[path] = permissions;
      
      debugPrint('Set permissions for $path: ${permissions.toString()}');
    } catch (e) {
      debugPrint('Failed to set permissions for $path: $e');
      rethrow;
    }
  }
  
  /// 检查权限
  Future<bool> checkPermission(
    String path,
    int permission, {
    VfsPermissionType type = VfsPermissionType.user,
  }) async {
    final permissions = await getPermissions(path);
    return permissions.hasPermission(type, permission);
  }
  
  /// 检查是否可以删除
  Future<bool> canDelete(String path) async {
    final permissions = await getPermissions(path);
    
    // 系统保护文件不能删除
    if (permissions.isSystemProtected) {
      return false;
    }
    
    // 检查写入权限
    return permissions.hasPermission(VfsPermissionType.user, VfsPermission.write);
  }  /// 检查是否可以修改
  Future<bool> canWrite(String path) async {
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) {
      return false;
    }
    
    // 检查文件是否存在（通过尝试获取存储的权限）
    final hasStoredPermissions = await _hasStoredPermissions(path);
    
    if (hasStoredPermissions) {
      // 文件存在，检查文件自身的写入权限
      final permissions = await getPermissions(path);
      
      // 系统保护文件不能修改
      if (permissions.isSystemProtected) {
        return false;
      }
      
      return permissions.hasPermission(VfsPermissionType.user, VfsPermission.write);
    } else {
      // 文件不存在，检查父目录的写入权限（创建文件需要父目录的写入权限）
      if (vfsPath.segments.isEmpty) {
        return true; // 根目录默认允许
      }
      
      final parentSegments = vfsPath.segments.sublist(0, vfsPath.segments.length - 1);
      final parentPath = VfsProtocol.buildPath(
        vfsPath.database,
        vfsPath.collection,
        parentSegments.join('/'),
      );
      
      try {
        final parentPermissions = await getPermissions(parentPath);
        
        // 系统保护目录不能创建文件
        if (parentPermissions.isSystemProtected) {
          print('DEBUG canWrite: Parent is system protected, returning false');
          return false;
        }
        
        final canWrite = parentPermissions.hasPermission(VfsPermissionType.user, VfsPermission.write);
        print('DEBUG canWrite: Parent write permission = $canWrite');
        return canWrite;
      } catch (e) {
        // 如果父目录也不存在，使用默认权限（允许）
        print('DEBUG canWrite: Parent permissions failed: $e, returning true');
        return true;
      }
    }
  }
  
  /// 检查是否可以读取
  Future<bool> canRead(String path) async {
    final permissions = await getPermissions(path);
    return permissions.hasPermission(VfsPermissionType.user, VfsPermission.read);
  }
  
  /// 应用权限继承
  Future<VfsPermissionMask> applyInheritance(
    String path,
    VfsInheritancePolicy policy,
  ) async {
    if (!policy.inheritFromParent) {
      return policy.defaultMask;
    }
    
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) {
      return policy.defaultMask;
    }
    
    final parentPermissions = await _getParentPermissions(vfsPath);
    if (parentPermissions != null) {
      await setPermissions(path, parentPermissions);
      return parentPermissions;
    }
    
    return policy.defaultMask;
  }
  
  /// 获取父目录权限
  Future<VfsPermissionMask?> _getParentPermissions(VfsPath vfsPath) async {
    if (vfsPath.segments.isEmpty) {
      return null;
    }
    
    final parentSegments = vfsPath.segments.sublist(0, vfsPath.segments.length - 1);
    final parentPath = VfsProtocol.buildPath(
      vfsPath.database,
      vfsPath.collection,
      parentSegments.join('/'),
    );
    
    try {
      return await getPermissions(parentPath);
    } catch (e) {
      return null;
    }
  }
  
  /// 检查是否为保护路径
  bool _isProtectedPath(VfsPath vfsPath) {
    // 根文件系统的特殊路径
    if (vfsPath.database == 'r6box' && vfsPath.collection == 'fs') {
      for (final protectedPath in _protectedPaths) {
        if (vfsPath.path == protectedPath || vfsPath.path.startsWith('$protectedPath/')) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// 列出目录时过滤权限
  Future<List<VfsFileInfo>> filterByPermissions(
    List<VfsFileInfo> files, {
    int requiredPermission = VfsPermission.read,
    VfsPermissionType type = VfsPermissionType.user,
  }) async {
    final filteredFiles = <VfsFileInfo>[];
    
    for (final file in files) {
      try {
        final hasPermission = await checkPermission(
          file.path,
          requiredPermission,
          type: type,
        );
        if (hasPermission) {
          filteredFiles.add(file);
        }
      } catch (e) {
        debugPrint('Permission check failed for ${file.path}: $e');
      }
    }
    
    return filteredFiles;
  }
  
  /// 清除权限缓存
  void clearCache() {
    _permissionCache.clear();
  }
  
  /// 清除特定路径的权限缓存
  void clearCacheForPath(String path) {
    _permissionCache.remove(path);
  }
  
  /// 检查路径是否有存储的权限（用于判断文件是否存在）
  Future<bool> _hasStoredPermissions(String path) async {
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) {
      return false;
    }
    
    // 检查是否为系统保护路径
    if (_isProtectedPath(vfsPath)) {
      return true;
    }
    
    try {
      // 从元数据中读取权限信息
      final metadata = await _storage.getCollectionMetadata(
        vfsPath.database,
        vfsPath.collection,
      );
      
      final permissionKey = 'permissions:${vfsPath.path}';
      return metadata.containsKey(permissionKey);
    } catch (e) {
      return false;
    }
  }
}
