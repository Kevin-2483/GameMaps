import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'vfs_protocol.dart';
import 'vfs_storage_service.dart';

/// 导出VFS数据结构
class VfsExportData {
  final String version;
  final DateTime exportedAt;
  final Map<String, VfsDatabaseExport> databases;
  final VfsMetadataExport metadata;

  VfsExportData({
    required this.version,
    required this.exportedAt,
    required this.databases,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'exportedAt': exportedAt.toIso8601String(),
    'databases': databases.map((k, v) => MapEntry(k, v.toJson())),
    'metadata': metadata.toJson(),
  };

  factory VfsExportData.fromJson(Map<String, dynamic> json) {
    return VfsExportData(
      version: json['version'] as String,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      databases: (json['databases'] as Map<String, dynamic>).map(
        (k, v) =>
            MapEntry(k, VfsDatabaseExport.fromJson(v as Map<String, dynamic>)),
      ),
      metadata: VfsMetadataExport.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
    );
  }
}

/// 集合导出数据
class VfsCollectionExport {
  final String collectionName;
  final List<VfsFileExport> files;
  final Map<String, String> metadata;

  VfsCollectionExport({
    required this.collectionName,
    required this.files,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'collectionName': collectionName,
    'files': files.map((f) => f.toJson()).toList(),
    'metadata': metadata,
  };

  factory VfsCollectionExport.fromJson(Map<String, dynamic> json) {
    return VfsCollectionExport(
      collectionName: json['collectionName'] as String,
      files: (json['files'] as List)
          .map((f) => VfsFileExport.fromJson(f as Map<String, dynamic>))
          .toList(),
      metadata: Map<String, String>.from(json['metadata'] as Map),
    );
  }
}

/// 数据库导出数据
class VfsDatabaseExport {
  final String databaseName;
  final Map<String, VfsCollectionExport> collections;
  final Map<String, String> metadata;

  VfsDatabaseExport({
    required this.databaseName,
    required this.collections,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'databaseName': databaseName,
    'collections': collections.map((k, v) => MapEntry(k, v.toJson())),
    'metadata': metadata,
  };

  factory VfsDatabaseExport.fromJson(Map<String, dynamic> json) {
    return VfsDatabaseExport(
      databaseName: json['databaseName'] as String,
      collections: (json['collections'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          k,
          VfsCollectionExport.fromJson(v as Map<String, dynamic>),
        ),
      ),
      metadata: Map<String, String>.from(json['metadata'] as Map),
    );
  }
}

/// 文件导出数据
class VfsFileExport {
  final String fileName;
  final String filePath;
  final bool isDirectory;
  final String? contentBase64;
  final String? mimeType;
  final int fileSize;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final Map<String, dynamic>? metadata;

  VfsFileExport({
    required this.fileName,
    required this.filePath,
    required this.isDirectory,
    this.contentBase64,
    this.mimeType,
    required this.fileSize,
    required this.createdAt,
    required this.modifiedAt,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'filePath': filePath,
    'isDirectory': isDirectory,
    if (contentBase64 != null) 'contentBase64': contentBase64,
    if (mimeType != null) 'mimeType': mimeType,
    'fileSize': fileSize,
    'createdAt': createdAt.toIso8601String(),
    'modifiedAt': modifiedAt.toIso8601String(),
    if (metadata != null) 'metadata': metadata,
  };

  factory VfsFileExport.fromJson(Map<String, dynamic> json) {
    return VfsFileExport(
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      isDirectory: json['isDirectory'] as bool,
      contentBase64: json['contentBase64'] as String?,
      mimeType: json['mimeType'] as String?,
      fileSize: json['fileSize'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// 元数据导出
class VfsMetadataExport {
  final Map<String, String> systemMetadata;
  final Map<String, Map<String, String>> databaseMetadata;

  VfsMetadataExport({
    required this.systemMetadata,
    required this.databaseMetadata,
  });

  Map<String, dynamic> toJson() => {
    'systemMetadata': systemMetadata,
    'databaseMetadata': databaseMetadata,
  };

  factory VfsMetadataExport.fromJson(Map<String, dynamic> json) {
    return VfsMetadataExport(
      systemMetadata: Map<String, String>.from(json['systemMetadata'] as Map),
      databaseMetadata: (json['databaseMetadata'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, Map<String, String>.from(v as Map)),
      ),
    );
  }
}

/// 导出选项
class VfsExportOptions {
  final Set<String>? includeDatabases;
  final Set<String>? includeCollections;
  final bool includeMetadata;
  final bool includeFileContent;
  final bool compressOutput;

  const VfsExportOptions({
    this.includeDatabases,
    this.includeCollections,
    this.includeMetadata = true,
    this.includeFileContent = true,
    this.compressOutput = false,
  });
}

/// 导入选项
class VfsImportOptions {
  final bool overwriteExisting;
  final bool mergeMetadata;
  final bool skipErrors;
  final Map<String, String>? databaseMapping;
  final Map<String, String>? collectionMapping;

  const VfsImportOptions({
    this.overwriteExisting = false,
    this.mergeMetadata = true,
    this.skipErrors = false,
    this.databaseMapping,
    this.collectionMapping,
  });
}

/// VFS导入导出服务
/// 与external_resources系统集成，提供虚拟文件系统数据的备份、恢复和迁移功能
class VfsImportExportService {
  static final VfsImportExportService _instance =
      VfsImportExportService._internal();
  factory VfsImportExportService() => _instance;
  VfsImportExportService._internal();
  final VfsStorageService _storageService = VfsStorageService();

  /// 导出数据格式版本
  static const String _exportVersion = '1.2.0';

  /// 导出所有VFS数据到JSON文件
  Future<String?> exportToFile({
    required String outputPath,
    VfsExportOptions? options,
  }) async {
    try {
      final vfsExportData = await exportData(options: options);
      final json = jsonEncode(vfsExportData.toJson());

      final file = File(outputPath);
      await file.writeAsString(json);

      return file.path;
    } catch (e) {
      debugPrint('VFS export failed: $e');
      rethrow;
    }
  }

  /// 导出VFS数据
  Future<VfsExportData> exportData({VfsExportOptions? options}) async {
    options ??= const VfsExportOptions();

    try {
      // 获取所有数据库
      final allDatabases = await _storageService.getAllDatabases();
      final exportDatabases = <String, VfsDatabaseExport>{};

      for (final dbName in allDatabases) {
        // 检查是否包含此数据库
        if (options.includeDatabases != null &&
            !options.includeDatabases!.contains(dbName)) {
          continue;
        }

        final dbExport = await _exportDatabase(dbName, options);
        exportDatabases[dbName] = dbExport;
      }

      // 导出系统元数据
      final metadata = options.includeMetadata
          ? await _exportMetadata()
          : VfsMetadataExport(systemMetadata: {}, databaseMetadata: {});

      return VfsExportData(
        version: _exportVersion,
        exportedAt: DateTime.now(),
        databases: exportDatabases,
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('Failed to export VFS data: $e');
      rethrow;
    }
  }

  /// 导出单个数据库
  Future<VfsDatabaseExport> _exportDatabase(
    String databaseName,
    VfsExportOptions options,
  ) async {
    final collections = await _storageService.getCollections(databaseName);
    final exportCollections = <String, VfsCollectionExport>{};

    for (final collectionName in collections) {
      // 检查是否包含此集合
      if (options.includeCollections != null &&
          !options.includeCollections!.contains(collectionName)) {
        continue;
      }

      final collectionExport = await _exportCollection(
        databaseName,
        collectionName,
        options,
      );
      exportCollections[collectionName] = collectionExport;
    }

    // 导出数据库元数据
    final metadata = await _storageService.getAllMetadata(databaseName);

    return VfsDatabaseExport(
      databaseName: databaseName,
      collections: exportCollections,
      metadata: metadata,
    );
  }

  /// 导出单个集合
  Future<VfsCollectionExport> _exportCollection(
    String databaseName,
    String collectionName,
    VfsExportOptions options,
  ) async {
    final files = await _storageService.listDirectory(
      'indexeddb://$databaseName/$collectionName',
    );
    final exportFiles = <VfsFileExport>[];

    for (final fileInfo in files) {
      final filePath =
          'indexeddb://$databaseName/$collectionName${fileInfo.path}';

      String? contentBase64;
      if (options.includeFileContent && !fileInfo.isDirectory) {
        try {
          final content = await _storageService.readFile(filePath);
          if (content != null) {
            contentBase64 = base64Encode(content.data);
          }
        } catch (e) {
          debugPrint('Failed to read file content for $filePath: $e');
          if (!options.includeFileContent) continue;
        }
      }

      exportFiles.add(
        VfsFileExport(
          fileName: fileInfo.name,
          filePath: fileInfo.path,
          isDirectory: fileInfo.isDirectory,
          contentBase64: contentBase64,
          mimeType: fileInfo.mimeType,
          fileSize: fileInfo.size,
          createdAt: fileInfo.createdAt,
          modifiedAt: fileInfo.modifiedAt,
          metadata: fileInfo.metadata,
        ),
      );
    }

    // 导出集合元数据
    final metadata = await _storageService.getCollectionMetadata(
      databaseName,
      collectionName,
    );

    return VfsCollectionExport(
      collectionName: collectionName,
      files: exportFiles,
      metadata: metadata,
    );
  }

  /// 导出系统元数据
  Future<VfsMetadataExport> _exportMetadata() async {
    // 获取系统级元数据
    final systemMetadata = <String, String>{
      'vfs_version': _exportVersion,
      'export_time': DateTime.now().toIso8601String(),
    };

    // 获取所有数据库的元数据
    final allDatabases = await _storageService.getAllDatabases();
    final databaseMetadata = <String, Map<String, String>>{};

    for (final dbName in allDatabases) {
      databaseMetadata[dbName] = await _storageService.getAllMetadata(dbName);
    }

    return VfsMetadataExport(
      systemMetadata: systemMetadata,
      databaseMetadata: databaseMetadata,
    );
  }

  /// 从文件导入VFS数据
  Future<void> importFromFile({
    required String filePath,
    VfsImportOptions? options,
  }) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      final exportData = VfsExportData.fromJson(json);
      await importData(exportData, options: options);
    } catch (e) {
      debugPrint('VFS import failed: $e');
      rethrow;
    }
  }

  /// 导入VFS数据
  Future<void> importData(
    VfsExportData exportData, {
    VfsImportOptions? options,
  }) async {
    options ??= const VfsImportOptions();

    try {
      // 导入数据库
      for (final entry in exportData.databases.entries) {
        final originalDbName = entry.key;
        final dbExport = entry.value;

        // 检查数据库名映射
        final actualDbName =
            options.databaseMapping?[originalDbName] ?? originalDbName;

        await _importDatabase(actualDbName, dbExport, options);
      }

      // 导入元数据
      if (options.mergeMetadata) {
        await _importMetadata(exportData.metadata, options);
      }
    } catch (e) {
      debugPrint('Failed to import VFS data: $e');
      if (!options.skipErrors) rethrow;
    }
  }

  /// 导入单个数据库
  Future<void> _importDatabase(
    String databaseName,
    VfsDatabaseExport dbExport,
    VfsImportOptions options,
  ) async {
    try {
      // 导入集合
      for (final entry in dbExport.collections.entries) {
        final originalCollectionName = entry.key;
        final collectionExport = entry.value;

        // 检查集合名映射
        final actualCollectionName =
            options.collectionMapping?[originalCollectionName] ??
            originalCollectionName;

        await _importCollection(
          databaseName,
          actualCollectionName,
          collectionExport,
          options,
        );
      }

      // 导入数据库元数据
      if (options.mergeMetadata) {
        for (final entry in dbExport.metadata.entries) {
          await _storageService.setMetadata(
            databaseName,
            entry.key,
            entry.value,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to import database $databaseName: $e');
      if (!options.skipErrors) rethrow;
    }
  }

  /// 导入单个集合
  Future<void> _importCollection(
    String databaseName,
    String collectionName,
    VfsCollectionExport collectionExport,
    VfsImportOptions options,
  ) async {
    try {
      // 导入文件
      for (final fileExport in collectionExport.files) {
        await _importFile(databaseName, collectionName, fileExport, options);
      }

      // 导入集合元数据
      if (options.mergeMetadata) {
        for (final entry in collectionExport.metadata.entries) {
          await _storageService.setCollectionMetadata(
            databaseName,
            collectionName,
            entry.key,
            entry.value,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to import collection $collectionName: $e');
      if (!options.skipErrors) rethrow;
    }
  }

  /// 导入单个文件
  Future<void> _importFile(
    String databaseName,
    String collectionName,
    VfsFileExport fileExport,
    VfsImportOptions options,
  ) async {
    try {
      final filePath =
          'indexeddb://$databaseName/$collectionName${fileExport.filePath}';

      // 检查文件是否已存在
      final exists = await _storageService.exists(filePath);
      if (exists && !options.overwriteExisting) {
        debugPrint('File already exists, skipping: $filePath');
        return;
      }

      if (fileExport.isDirectory) {
        // 创建目录
        await _storageService.createDirectory(filePath);
      } else {
        // 创建文件
        Uint8List? content;
        if (fileExport.contentBase64 != null) {
          content = base64Decode(fileExport.contentBase64!);
        }
        await _storageService.writeFile(
          filePath,
          content ?? Uint8List(0),
          metadata: fileExport.metadata,
        );

        // 设置文件时间戳
        final fileInfo = VfsFileInfo(
          name: fileExport.fileName,
          path: fileExport.filePath,
          isDirectory: false,
          size: fileExport.fileSize,
          mimeType: fileExport.mimeType,
          createdAt: fileExport.createdAt,
          modifiedAt: fileExport.modifiedAt,
          metadata: fileExport.metadata,
        );

        await _storageService.updateFileInfo(filePath, fileInfo);
      }
    } catch (e) {
      debugPrint('Failed to import file ${fileExport.filePath}: $e');
      if (!options.skipErrors) rethrow;
    }
  }

  /// 导入元数据
  Future<void> _importMetadata(
    VfsMetadataExport metadata,
    VfsImportOptions options,
  ) async {
    try {
      // 导入数据库元数据
      for (final entry in metadata.databaseMetadata.entries) {
        final databaseName = entry.key;
        final dbMetadata = entry.value;

        for (final metaEntry in dbMetadata.entries) {
          await _storageService.setMetadata(
            databaseName,
            metaEntry.key,
            metaEntry.value,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to import metadata: $e');
      if (!options.skipErrors) rethrow;
    }
  }

  /// 获取导出数据预览
  Future<VfsExportPreview> getExportPreview({VfsExportOptions? options}) async {
    options ??= const VfsExportOptions();

    final allDatabases = await _storageService.getAllDatabases();
    final databasePreviews = <String, VfsDatabasePreview>{};

    int totalFiles = 0;
    int totalSize = 0;

    for (final dbName in allDatabases) {
      if (options.includeDatabases != null &&
          !options.includeDatabases!.contains(dbName)) {
        continue;
      }

      final dbPreview = await _getDatabasePreview(dbName, options);
      databasePreviews[dbName] = dbPreview;
      totalFiles += dbPreview.totalFiles;
      totalSize += dbPreview.totalSize;
    }

    return VfsExportPreview(
      databases: databasePreviews,
      totalFiles: totalFiles,
      totalSize: totalSize,
    );
  }

  /// 获取数据库预览
  Future<VfsDatabasePreview> _getDatabasePreview(
    String databaseName,
    VfsExportOptions options,
  ) async {
    final collections = await _storageService.getCollections(databaseName);
    final collectionPreviews = <String, VfsCollectionPreview>{};

    int totalFiles = 0;
    int totalSize = 0;

    for (final collectionName in collections) {
      if (options.includeCollections != null &&
          !options.includeCollections!.contains(collectionName)) {
        continue;
      } // 获取集合中的所有文件
      final files = await _getAllFilesInCollection(
        databaseName,
        collectionName,
      );
      final fileCount = files.length;
      final collectionSize = files.fold<int>(
        0,
        (sum, file) => sum + file.size.round(),
      );

      final preview = VfsCollectionPreview(
        collectionName: collectionName,
        fileCount: fileCount,
        totalSize: collectionSize,
      );

      collectionPreviews[collectionName] = preview;
      totalFiles += fileCount;
      totalSize += collectionSize;
    }

    return VfsDatabasePreview(
      databaseName: databaseName,
      collections: collectionPreviews,
      totalFiles: totalFiles,
      totalSize: totalSize,
    );
  }

  /// 获取集合中的所有文件
  Future<List<VfsFileInfo>> _getAllFilesInCollection(
    String databaseName,
    String collectionName,
  ) async {
    final collectionPath = 'indexeddb://$databaseName/$collectionName/';
    try {
      return await _storageService.listDirectory(collectionPath);
    } catch (e) {
      // 如果集合不存在或为空，返回空列表
      return [];
    }
  }

  /// 获取所有数据库列表（用于UI）
  Future<List<String>> getAllDatabases() async {
    return await _storageService.getAllDatabases();
  }

  /// 获取指定数据库的集合列表（用于UI）
  Future<List<String>> getCollections(String databaseName) async {
    return await _storageService.getCollections(databaseName);
  }
}

/// 导出预览
class VfsExportPreview {
  final Map<String, VfsDatabasePreview> databases;
  final int totalFiles;
  final int totalSize;

  VfsExportPreview({
    required this.databases,
    required this.totalFiles,
    required this.totalSize,
  });
}

/// 数据库预览
class VfsDatabasePreview {
  final String databaseName;
  final Map<String, VfsCollectionPreview> collections;
  final int totalFiles;
  final int totalSize;

  VfsDatabasePreview({
    required this.databaseName,
    required this.collections,
    required this.totalFiles,
    required this.totalSize,
  });
}

/// 集合预览
class VfsCollectionPreview {
  final String collectionName;
  final int fileCount;
  final int totalSize;

  VfsCollectionPreview({
    required this.collectionName,
    required this.fileCount,
    required this.totalSize,
  });
}
