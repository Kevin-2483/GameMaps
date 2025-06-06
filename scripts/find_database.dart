import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() async {
  // 初始化 sqflite FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  try {
    // 获取数据库路径
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, 'maps.db');

    print('数据库路径: $dbPath');

    // 检查文件是否存在
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      print('数据库文件存在');
      final stat = await dbFile.stat();
      print('文件大小: ${stat.size} 字节');
      print('创建时间: ${stat.changed}');
    } else {
      print('数据库文件不存在');
    }
  } catch (e) {
    print('错误: $e');
  }
}
