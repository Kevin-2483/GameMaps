import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// 数据库路径配置服务
/// 将所有数据库文件存储在应用程序文档目录的r6box子目录中
class DatabasePathService {
  static final DatabasePathService _instance = DatabasePathService._internal();
  factory DatabasePathService() => _instance;
  DatabasePathService._internal();

  String? _customDatabasePath;

  /// 获取自定义数据库目录路径
  /// 返回: {应用程序文档目录}/r6box/databases
  Future<String> getDatabasesPath() async {
    if (_customDatabasePath != null) {
      return _customDatabasePath!;
    }

    // 获取应用程序文档目录
    final appDocDir = await getApplicationDocumentsDirectory();
    
    // 创建r6box/databases子目录
    final databasesDir = Directory(join(appDocDir.path, 'r6box', 'databases'));
    
    // 确保目录存在
    if (!await databasesDir.exists()) {
      await databasesDir.create(recursive: true);
    }
    
    _customDatabasePath = databasesDir.path;
    return _customDatabasePath!;
  }

  /// 获取指定数据库文件的完整路径
  Future<String> getDatabasePath(String databaseName) async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, databaseName);
  }

  /// 重置缓存的路径（用于测试或路径变更）
  void resetCache() {
    _customDatabasePath = null;
  }

  /// 检查数据库目录是否存在
  Future<bool> databaseDirectoryExists() async {
    try {
      final databasesPath = await getDatabasesPath();
      return await Directory(databasesPath).exists();
    } catch (e) {
      return false;
    }
  }

  /// 获取数据库目录的大小（字节）
  Future<int> getDatabaseDirectorySize() async {
    try {
      final databasesPath = await getDatabasesPath();
      final dir = Directory(databasesPath);
      
      if (!await dir.exists()) {
        return 0;
      }
      
      int totalSize = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// 列出所有数据库文件
  Future<List<String>> listDatabaseFiles() async {
    try {
      final databasesPath = await getDatabasesPath();
      final dir = Directory(databasesPath);
      
      if (!await dir.exists()) {
        return [];
      }
      
      final files = <String>[];
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.db')) {
          files.add(basename(entity.path));
        }
      }
      
      return files;
    } catch (e) {
      return [];
    }
  }
}