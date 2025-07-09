/// Web平台的数据库路径服务实现
/// Web平台使用IndexedDB，不需要文件系统路径
class DatabasePathService {
  static final DatabasePathService _instance = DatabasePathService._internal();
  factory DatabasePathService() => _instance;
  DatabasePathService._internal();

  String? _customDatabasePath;

  /// Web平台返回虚拟路径
  /// 在Web平台，数据库存储在IndexedDB中，不需要实际的文件系统路径
  Future<String> getDatabasesPath() async {
    _customDatabasePath ??= '/web/indexeddb/r6box/databases';
    return _customDatabasePath!;
  }

  /// 获取指定数据库文件的完整路径
  /// Web平台返回虚拟路径，实际存储在IndexedDB中
  Future<String> getDatabasePath(String databaseName) async {
    final databasesPath = await getDatabasesPath();
    return '$databasesPath/$databaseName';
  }

  /// 重置缓存的路径
  void resetCache() {
    _customDatabasePath = null;
  }

  /// Web平台总是返回true，因为IndexedDB总是可用的
  Future<bool> databaseDirectoryExists() async {
    return true;
  }

  /// Web平台无法准确计算IndexedDB大小，返回0
  Future<int> getDatabaseDirectorySize() async {
    return 0;
  }

  /// Web平台无法列出IndexedDB中的文件，返回空列表
  Future<List<String>> listDatabaseFiles() async {
    return [];
  }
}
