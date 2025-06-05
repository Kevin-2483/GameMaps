import '../virtual_file_system/vfs_storage_service.dart';
import '../map_database_service.dart';
import 'vfs_map_service.dart';
import 'vfs_map_service_impl.dart';
import 'vfs_map_database_adapter.dart';

/// VFS地图服务工厂
/// 提供服务实例的创建和配置
/// 注意：迁移功能已禁用，直接使用VFS存储，无需从传统存储迁移
class VfsMapServiceFactory {
  static const bool _useVfsStorage = true; // 配置开关

  /// 创建地图数据库服务
  /// 根据配置返回VFS实现或传统实现
  static MapDatabaseService createMapDatabaseService() {
    if (_useVfsStorage) {
      final vfsStorageService = VfsStorageService();
      final vfsMapService = VfsMapServiceImpl(
        storageService: vfsStorageService,
        databaseName: 'r6box',
        mapsCollection: 'maps',
      );
      return VfsMapDatabaseAdapter(vfsMapService);
    } else {
      return MapDatabaseService();
    }
  }

  /// 创建VFS地图服务实例（直接访问VFS功能）
  static VfsMapService createVfsMapService({
    VfsStorageService? storageService,
    String databaseName = 'r6box',
    String mapsCollection = 'maps',
  }) {
    return VfsMapServiceImpl(
      storageService: storageService ?? VfsStorageService(),
      databaseName: databaseName,
      mapsCollection: mapsCollection,
    );
  }

  /// 获取当前是否使用VFS存储
  static bool get isUsingVfsStorage => _useVfsStorage;
}
