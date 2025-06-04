import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

// 模拟VFS存储服务的关键部分进行测试
class VfsTestService {
  static const String _filesTableName = 'vfs_files';
  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // 初始化ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    // 使用内存数据库进行测试
    final db = await openDatabase(':memory:');
    
    // 创建测试表
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
    
    // 插入测试数据
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(_filesTableName, {
      'database_name': 'r6box',
      'collection_name': 'fs',
      'file_path': '2/ww',
      'file_name': 'ww',
      'is_directory': 0,
      'file_size': 0,
      'created_at': now,
      'modified_at': now,
    });
    
    return db;
  }

  Future<void> testListDirectory(String queryPath) async {
    final db = await database;
    final pathPrefix = queryPath.isEmpty ? '' : '$queryPath/';
    final expectedSlashCount = pathPrefix.split('/').length - 1;
    
    print('🗄️ Testing listDirectory with path: $queryPath');
    print('🗄️ pathPrefix: "$pathPrefix"');
    print('🗄️ expectedSlashCount: $expectedSlashCount');
    
    final result = await db.rawQuery('''
      SELECT * FROM $_filesTableName 
      WHERE database_name = ? AND collection_name = ? 
      AND file_path LIKE ? 
      AND file_path != ?
      AND (LENGTH(file_path) - LENGTH(REPLACE(file_path, '/', ''))) = ?
      ORDER BY is_directory DESC, file_name ASC
    ''', [
      'r6box',
      'fs',
      '$pathPrefix%',
      queryPath,
      expectedSlashCount,
    ]);
    
    print('🗄️ SQL query returned ${result.length} rows');
    for (final row in result) {
      print('🗄️ - ${row['file_name']} (${row['is_directory'] == 1 ? 'DIR' : 'FILE'}) at path: ${row['file_path']}');
    }
  }
}

void main() async {
  final service = VfsTestService();
  await service.testListDirectory('2');
}
