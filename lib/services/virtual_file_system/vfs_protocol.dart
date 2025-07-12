import 'dart:typed_data';

/// 虚拟文件系统协议定义
/// 支持 indexeddb:// 协议的路径解析和处理
class VfsProtocol {
  static const String scheme = 'indexeddb';
  static const String schemePrefix = '$scheme://';

  /// 解析 indexeddb:// 路径
  ///
  /// 路径格式: indexeddb://database/collection/path/to/file
  /// 例如: indexeddb://r6box/maps/map1/data.json
  /// 支持包含空格的路径名
  static VfsPath? parsePath(String path) {
    if (!path.startsWith(schemePrefix)) {
      return null;
    }

    final pathPart = path.substring(schemePrefix.length);
    final segments = pathPart.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.length < 2) {
      return null;
    }

    // 确保路径段正确处理，包括空格
    final pathSegments = segments.skip(2).toList();
    final fullPath = pathSegments.join('/');

    return VfsPath(
      database: segments[0],
      collection: segments[1],
      path: fullPath,
      segments: pathSegments,
    );
  }

  /// 构建 indexeddb:// 路径
  static String buildPath(String database, String collection, String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$schemePrefix$database/$collection/$cleanPath';
  }

  /// 验证路径格式
  static bool isValidPath(String path) {
    return parsePath(path) != null;
  }

  /// 获取父路径
  static String? getParentPath(String path) {
    final vfsPath = parsePath(path);
    if (vfsPath == null || vfsPath.segments.isEmpty) {
      return null;
    }

    if (vfsPath.segments.length == 1) {
      return buildPath(vfsPath.database, vfsPath.collection, '');
    }

    final parentSegments = vfsPath.segments.sublist(
      0,
      vfsPath.segments.length - 1,
    );
    return buildPath(
      vfsPath.database,
      vfsPath.collection,
      parentSegments.join('/'),
    );
  }

  /// 获取文件名
  static String? getFileName(String path) {
    final vfsPath = parsePath(path);
    if (vfsPath == null || vfsPath.segments.isEmpty) {
      return null;
    }

    return vfsPath.segments.last;
  }

  /// 连接路径
  static String joinPath(String basePath, String relativePath) {
    final vfsPath = parsePath(basePath);
    if (vfsPath == null) {
      throw ArgumentError('Invalid base path: $basePath');
    }

    final newPath = vfsPath.path.isEmpty
        ? relativePath
        : '${vfsPath.path}/$relativePath';

    return buildPath(vfsPath.database, vfsPath.collection, newPath);
  }
}

/// 虚拟文件系统路径对象
class VfsPath {
  final String database;
  final String collection;
  final String path;
  final List<String> segments;

  const VfsPath({
    required this.database,
    required this.collection,
    required this.path,
    required this.segments,
  });

  /// 获取完整路径
  String get fullPath => VfsProtocol.buildPath(database, collection, path);

  /// 获取文件名
  String? get fileName => segments.isNotEmpty ? segments.last : null;

  /// 获取文件扩展名
  String? get extension {
    final name = fileName;
    if (name == null || !name.contains('.')) {
      return null;
    }
    return name.split('.').last.toLowerCase();
  }

  /// 是否为目录路径
  bool get isDirectory => path.isEmpty || path.endsWith('/');

  /// 是否为根路径
  bool get isRoot => path.isEmpty;

  /// 获取深度
  int get depth => segments.length;

  @override
  String toString() => fullPath;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VfsPath &&
        other.database == database &&
        other.collection == collection &&
        other.path == path;
  }

  @override
  int get hashCode => Object.hash(database, collection, path);
}

/// 虚拟文件系统错误类型
class VfsException implements Exception {
  final String message;
  final String? path;
  final String? code;

  const VfsException(this.message, {this.path, this.code});

  @override
  String toString() {
    final pathInfo = path != null ? ' (path: $path)' : '';
    final codeInfo = code != null ? ' [$code]' : '';
    return 'VfsException: $message$pathInfo$codeInfo';
  }
}

/// 文件/目录信息
class VfsFileInfo {
  final String path;
  final String name;
  final bool isDirectory;
  final int size;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String? mimeType;
  final Map<String, dynamic>? metadata;

  const VfsFileInfo({
    required this.path,
    required this.name,
    required this.isDirectory,
    required this.size,
    required this.createdAt,
    required this.modifiedAt,
    this.mimeType,
    this.metadata,
  });

  /// 从 JSON 创建
  factory VfsFileInfo.fromJson(Map<String, dynamic> json) {
    return VfsFileInfo(
      path: json['path'] as String,
      name: json['name'] as String,
      isDirectory: json['isDirectory'] as bool,
      size: json['size'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      mimeType: json['mimeType'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'isDirectory': isDirectory,
      'size': size,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'mimeType': mimeType,
      'metadata': metadata,
    };
  }
}

/// 文件内容包装器
class VfsFileContent {
  final Uint8List data;
  final String? mimeType;
  final Map<String, dynamic>? metadata;

  const VfsFileContent({required this.data, this.mimeType, this.metadata});

  /// 文件大小
  int get size => data.length;

  /// 是否为文本文件
  bool get isText => mimeType?.startsWith('text/') ?? false;

  /// 是否为图片文件
  bool get isImage => mimeType?.startsWith('image/') ?? false;

  /// 是否为 JSON 文件
  bool get isJson => mimeType == 'application/json';
}
