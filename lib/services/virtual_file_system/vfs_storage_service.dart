import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'vfs_protocol.dart';

/// 虚拟文件系统存储服务
/// 基于 SQLite/IndexedDB 实现底层数据存储
class VfsStorageService {
  static final VfsStorageService _instance = VfsStorageService._internal();
  factory VfsStorageService() => _instance;
  VfsStorageService._internal();

  Database? _database;
  static const String _databaseName = 'vfs_storage.db';
  static const String _filesTableName = 'vfs_files';
  static const String _metadataTableName = 'vfs_metadata';
  static const int _databaseVersion = 1;

  /// 获取数据库实例
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 文件存储表
    await db.execute('''
      CREATE TABLE $_filesTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        database_name TEXT NOT NULL,
        collection_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        is_directory INTEGER NOT NULL DEFAULT 0,
        content_data BLOB,
        mime_type TEXT,
        file_size INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        modified_at INTEGER NOT NULL,
        metadata_json TEXT,
        UNIQUE(database_name, collection_name, file_path)
      )
    ''');

    // 元数据表
    await db.execute('''
      CREATE TABLE $_metadataTableName (
        database_name TEXT NOT NULL,
        collection_name TEXT NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (database_name, collection_name, key)
      )
    ''');

    // 创建索引
    await db.execute('''
      CREATE INDEX idx_files_path ON $_filesTableName(database_name, collection_name, file_path)
    ''');

    await db.execute('''
      CREATE INDEX idx_files_directory ON $_filesTableName(database_name, collection_name, is_directory)
    ''');

    await db.execute('''
      CREATE INDEX idx_files_modified ON $_filesTableName(modified_at)
    ''');
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 未来版本升级逻辑
  }

  /// 检查文件是否存在
  Future<bool> exists(String path) async {
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) {
      throw VfsException('Invalid path format', path: path);
    }

    final db = await database;
    final result = await db.query(
      _filesTableName,
      where: 'database_name = ? AND collection_name = ? AND file_path = ?',
      whereArgs: [vfsPath.database, vfsPath.collection, vfsPath.path],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// 读取文件内容
  Future<VfsFileContent?> readFile(String path) async {
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) {
      throw VfsException('Invalid path format', path: path);
    }

    final db = await database;
    final result = await db.query(
      _filesTableName,
      where: 'database_name = ? AND collection_name = ? AND file_path = ? AND is_directory = 0',
      whereArgs: [vfsPath.database, vfsPath.collection, vfsPath.path],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;
    final contentData = row['content_data'] as Uint8List?;
    
    if (contentData == null) {
      throw VfsException('File content is null', path: path);
    }

    Map<String, dynamic>? metadata;
    final metadataJson = row['metadata_json'] as String?;
    if (metadataJson != null) {
      try {
        metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Failed to parse metadata for $path: $e');
      }
    }

    return VfsFileContent(
      data: contentData,
      mimeType: row['mime_type'] as String?,
      metadata: metadata,
    );
  }

  /// 创建目录
  Future<void> createDirectory(String path) async {
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) {
      throw VfsException('Invalid path format', path: path);
    }

    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      _filesTableName,
      {
        'database_name': vfsPath.database,
        'collection_name': vfsPath.collection,
        'file_path': vfsPath.path,
        'file_name': vfsPath.fileName ?? '',
        'is_directory': 1,
        'content_data': null,
        'mime_type': null,
        'file_size': 0,
        'created_at': now,
        'modified_at': now,
        'metadata_json': null,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// 删除文件或目录
  Future<bool> delete(String path, {bool recursive = false}) async {
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) {
      throw VfsException('Invalid path format', path: path);
    }

    final db = await database;
    
    if (recursive) {
      // 递归删除：删除所有以该路径开头的文件和目录
      final pathPrefix = vfsPath.path.isEmpty ? '' : '${vfsPath.path}/';
      final result = await db.delete(
        _filesTableName,
        where: '''
          database_name = ? AND collection_name = ? AND 
          (file_path = ? OR file_path LIKE ?)
        ''',
        whereArgs: [
          vfsPath.database, 
          vfsPath.collection, 
          vfsPath.path,
          '$pathPrefix%'
        ],
      );
      return result > 0;
    } else {
      // 非递归删除：只删除指定路径
      final result = await db.delete(
        _filesTableName,
        where: 'database_name = ? AND collection_name = ? AND file_path = ?',
        whereArgs: [vfsPath.database, vfsPath.collection, vfsPath.path],
      );
      return result > 0;
    }
  }
  /// 列出目录内容
  Future<List<VfsFileInfo>> listDirectory(String path) async {
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) {
      throw VfsException('Invalid path format', path: path);
    }

    final db = await database;
    final pathPrefix = vfsPath.path.isEmpty ? '' : '${vfsPath.path}/';
    
    debugPrint('🗄️ Storage: listDirectory called with path: $path');
    debugPrint('🗄️ Storage: parsed - database: ${vfsPath.database}, collection: ${vfsPath.collection}, path: ${vfsPath.path}');
    debugPrint('🗄️ Storage: pathPrefix: "$pathPrefix"');
    
    // 查找直接子项（不包含深层嵌套）
    // 计算期望的斜杠数量：路径前缀的斜杠数
    final expectedSlashCount = pathPrefix.split('/').length - 1;
    
    final result = await db.rawQuery('''
      SELECT * FROM $_filesTableName 
      WHERE database_name = ? AND collection_name = ? 
      AND file_path LIKE ? 
      AND file_path != ?
      AND (LENGTH(file_path) - LENGTH(REPLACE(file_path, '/', ''))) = ?
      ORDER BY is_directory DESC, file_name ASC
    ''', [
      vfsPath.database,
      vfsPath.collection,
      '$pathPrefix%',
      vfsPath.path,      expectedSlashCount,
    ]);

    debugPrint('🗄️ Storage: SQL query returned ${result.length} rows');
    for (final row in result) {
      debugPrint('🗄️ Storage: - ${row['file_name']} (${row['is_directory'] == 1 ? 'DIR' : 'FILE'}) at path: ${row['file_path']}');
    }
    debugPrint('🗄️ Storage: converted to ${result.length} VfsFileInfo objects');

    return result.map((row) => _rowToFileInfo(row)).toList();
  }

  /// 获取文件信息
  Future<VfsFileInfo?> getFileInfo(String path) async {
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) {
      throw VfsException('Invalid path format', path: path);
    }

    final db = await database;
    final result = await db.query(
      _filesTableName,
      where: 'database_name = ? AND collection_name = ? AND file_path = ?',
      whereArgs: [vfsPath.database, vfsPath.collection, vfsPath.path],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return _rowToFileInfo(result.first);
  }

  /// 移动/重命名文件或目录
  Future<bool> move(String fromPath, String toPath) async {
    final fromVfsPath = VfsProtocol.parsePath(fromPath);
    final toVfsPath = VfsProtocol.parsePath(toPath);
    
    if (fromVfsPath == null || toVfsPath == null) {
      throw VfsException('Invalid path format');
    }

    if (fromVfsPath.database != toVfsPath.database ||
        fromVfsPath.collection != toVfsPath.collection) {
      throw VfsException('Cannot move between different databases or collections');
    }

    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    return await db.transaction((txn) async {
      // 检查源路径是否存在
      final sourceExists = await txn.query(
        _filesTableName,
        where: 'database_name = ? AND collection_name = ? AND file_path = ?',
        whereArgs: [fromVfsPath.database, fromVfsPath.collection, fromVfsPath.path],
        limit: 1,
      );

      if (sourceExists.isEmpty) {
        return false;
      }

      final isDirectory = sourceExists.first['is_directory'] as int == 1;

      if (isDirectory) {
        // 移动目录：更新所有子项的路径
        final fromPrefix = fromVfsPath.path.isEmpty ? '' : '${fromVfsPath.path}/';
        final toPrefix = toVfsPath.path.isEmpty ? '' : '${toVfsPath.path}/';

        await txn.rawUpdate('''
          UPDATE $_filesTableName 
          SET file_path = REPLACE(file_path, ?, ?),
              file_name = CASE 
                WHEN file_path = ? THEN ?
                ELSE file_name
              END,
              modified_at = ?
          WHERE database_name = ? AND collection_name = ? 
          AND (file_path = ? OR file_path LIKE ?)
        ''', [
          fromPrefix,
          toPrefix,
          fromVfsPath.path,
          toVfsPath.fileName ?? '',
          now,
          fromVfsPath.database,
          fromVfsPath.collection,
          fromVfsPath.path,
          '$fromPrefix%',
        ]);
      } else {
        // 移动文件
        await txn.update(
          _filesTableName,
          {
            'file_path': toVfsPath.path,
            'file_name': toVfsPath.fileName ?? '',
            'modified_at': now,
          },
          where: 'database_name = ? AND collection_name = ? AND file_path = ?',
          whereArgs: [fromVfsPath.database, fromVfsPath.collection, fromVfsPath.path],
        );
      }

      return true;
    });
  }

  /// 复制文件或目录
  Future<bool> copy(String fromPath, String toPath) async {
    final fromVfsPath = VfsProtocol.parsePath(fromPath);
    final toVfsPath = VfsProtocol.parsePath(toPath);
    
    if (fromVfsPath == null || toVfsPath == null) {
      throw VfsException('Invalid path format');
    }

    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    return await db.transaction((txn) async {
      // 检查源路径是否存在
      final sourceItems = await txn.query(
        _filesTableName,
        where: '''
          database_name = ? AND collection_name = ? AND 
          (file_path = ? OR file_path LIKE ?)
        ''',
        whereArgs: [
          fromVfsPath.database, 
          fromVfsPath.collection, 
          fromVfsPath.path,
          '${fromVfsPath.path}/%'
        ],
      );

      if (sourceItems.isEmpty) {
        return false;
      }

      for (final item in sourceItems) {
        final oldPath = item['file_path'] as String;
        final newPath = oldPath == fromVfsPath.path 
            ? toVfsPath.path 
            : oldPath.replaceFirst(fromVfsPath.path, toVfsPath.path);

        final newFileName = newPath.split('/').last;

        await txn.insert(
          _filesTableName,
          {
            'database_name': toVfsPath.database,
            'collection_name': toVfsPath.collection,
            'file_path': newPath,
            'file_name': newFileName,
            'is_directory': item['is_directory'],
            'content_data': item['content_data'],
            'mime_type': item['mime_type'],
            'file_size': item['file_size'],
            'created_at': now,
            'modified_at': now,
            'metadata_json': item['metadata_json'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return true;
    });
  }

  /// 获取数据库统计信息
  Future<Map<String, dynamic>> getStorageStats(String database, String collection) async {
    final db = await this.database;
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_files,
        SUM(CASE WHEN is_directory = 0 THEN 1 ELSE 0 END) as file_count,
        SUM(CASE WHEN is_directory = 1 THEN 1 ELSE 0 END) as directory_count,
        SUM(file_size) as total_size,
        MAX(modified_at) as last_modified
      FROM $_filesTableName 
      WHERE database_name = ? AND collection_name = ?
    ''', [database, collection]);

    final row = result.first;
    return {
      'totalFiles': row['total_files'] as int,
      'fileCount': row['file_count'] as int,
      'directoryCount': row['directory_count'] as int,
      'totalSize': row['total_size'] as int? ?? 0,
      'lastModified': row['last_modified'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(row['last_modified'] as int)
          : null,
    };
  }
  /// 清空指定数据库和集合的所有数据
  Future<void> clearCollection(String database, String collection) async {
    final db = await this.database;
    // 删除文件数据
    await db.delete(
      _filesTableName,
      where: 'database_name = ? AND collection_name = ?',
      whereArgs: [database, collection],
    );
    // 删除元数据（包括权限信息）
    await db.delete(
      _metadataTableName,
      where: 'database_name = ? AND collection_name = ?',
      whereArgs: [database, collection],
    );
  }

  /// 创建路径所需的父目录
  Future<void> _createDirectoriesForPath(VfsPath vfsPath) async {
    if (vfsPath.segments.isEmpty) return;

    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 创建所有父目录
    for (int i = 0; i < vfsPath.segments.length - 1; i++) {
      final dirSegments = vfsPath.segments.sublist(0, i + 1);
      final dirPath = dirSegments.join('/');

      await db.insert(
        _filesTableName,
        {
          'database_name': vfsPath.database,
          'collection_name': vfsPath.collection,
          'file_path': dirPath,
          'file_name': dirSegments.last,
          'is_directory': 1,
          'content_data': null,
          'mime_type': null,
          'file_size': 0,
          'created_at': now,
          'modified_at': now,
          'metadata_json': null,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  /// 将数据库行转换为文件信息对象
  VfsFileInfo _rowToFileInfo(Map<String, dynamic> row) {
    Map<String, dynamic>? metadata;
    final metadataJson = row['metadata_json'] as String?;
    if (metadataJson != null) {
      try {
        metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Failed to parse metadata: $e');
      }
    }

    final database = row['database_name'] as String;
    final collection = row['collection_name'] as String;
    final path = row['file_path'] as String;

    return VfsFileInfo(
      path: VfsProtocol.buildPath(database, collection, path),
      name: row['file_name'] as String,
      isDirectory: (row['is_directory'] as int) == 1,
      size: row['file_size'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(row['modified_at'] as int),
      mimeType: row['mime_type'] as String?,
      metadata: metadata,
    );
  }

  /// 关闭数据库连接
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// 获取所有数据库列表
  Future<List<String>> getAllDatabases() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT DISTINCT database_name FROM $_filesTableName
      ORDER BY database_name
    ''');
    return result.map((row) => row['database_name'] as String).toList();
  }

  /// 获取指定数据库中的所有集合
  Future<List<String>> getCollections(String databaseName) async {
    final db = await database;
    final result = await db.query(
      _filesTableName,
      columns: ['DISTINCT collection_name'],
      where: 'database_name = ?',
      whereArgs: [databaseName],
      orderBy: 'collection_name',
    );
    return result.map((row) => row['collection_name'] as String).toList();
  }

  /// 获取所有元数据
  Future<Map<String, String>> getAllMetadata(String databaseName) async {
    final db = await database;
    final result = await db.query(
      _metadataTableName,
      where: 'database_name = ?',
      whereArgs: [databaseName],
    );
    
    final metadata = <String, String>{};
    for (final row in result) {
      metadata[row['key'] as String] = row['value'] as String;
    }
    return metadata;
  }

  /// 获取集合元数据
  Future<Map<String, String>> getCollectionMetadata(String databaseName, String collectionName) async {
    final db = await database;
    final result = await db.query(
      _metadataTableName,
      where: 'database_name = ? AND collection_name = ?',
      whereArgs: [databaseName, collectionName],
    );
    
    final metadata = <String, String>{};
    for (final row in result) {
      metadata[row['key'] as String] = row['value'] as String;
    }
    return metadata;
  }

  /// 设置元数据
  Future<void> setMetadata(String databaseName, String key, String value, {String? collectionName}) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.insert(
      _metadataTableName,
      {
        'database_name': databaseName,
        'collection_name': collectionName ?? '',
        'key': key,
        'value': value,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 设置集合元数据
  Future<void> setCollectionMetadata(String databaseName, String collectionName, String key, String value) async {
    await setMetadata(databaseName, key, value, collectionName: collectionName);
  }

  /// 更新文件信息
  Future<void> updateFileInfo(String path, VfsFileInfo fileInfo) async {
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) {
      throw VfsException('Invalid path format', path: path);
    }

    final db = await database;
    String? metadataJson;
    if (fileInfo.metadata != null) {
      try {
        metadataJson = jsonEncode(fileInfo.metadata);
      } catch (e) {
        debugPrint('Failed to encode metadata: $e');
      }
    }

    await db.update(
      _filesTableName,
      {
        'file_name': fileInfo.name,
        'file_size': fileInfo.size,
        'mime_type': fileInfo.mimeType,
        'created_at': fileInfo.createdAt.millisecondsSinceEpoch,
        'modified_at': fileInfo.modifiedAt.millisecondsSinceEpoch,
        'metadata_json': metadataJson,
      },
      where: 'database_name = ? AND collection_name = ? AND file_path = ?',
      whereArgs: [vfsPath.database, vfsPath.collection, vfsPath.path],
    );
  }

  /// 重载写入文件方法以支持Uint8List
  Future<void> writeFile(
    String path, 
    dynamic content, {
    bool createDirectories = true,
    Map<String, dynamic>? metadata,
  }) async {
    final vfsPath = VfsProtocol.parsePath(path);
    if (vfsPath == null) {
      throw VfsException('Invalid path format', path: path);
    }

    if (createDirectories) {
      await _createDirectoriesForPath(vfsPath);
    }

    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    Uint8List? data;
    String? mimeType;
    int size = 0;

    if (content is VfsFileContent) {
      data = content.data;
      mimeType = content.mimeType;
      size = content.size;
    } else if (content is Uint8List) {
      data = content;
      size = content.length;
    } else if (content is String) {
      data = Uint8List.fromList(utf8.encode(content));
      size = data.length;
    }

    String? metadataJson;
    if (metadata != null) {
      try {
        metadataJson = jsonEncode(metadata);
      } catch (e) {
        debugPrint('Failed to encode metadata for $path: $e');
      }
    }

    await db.insert(
      _filesTableName,
      {
        'database_name': vfsPath.database,
        'collection_name': vfsPath.collection,
        'file_path': vfsPath.path,
        'file_name': vfsPath.fileName ?? '',
        'is_directory': 0,
        'content_data': data,
        'mime_type': mimeType,
        'file_size': size,
        'created_at': now,
        'modified_at': now,
        'metadata_json': metadataJson,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
