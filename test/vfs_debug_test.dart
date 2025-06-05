import 'package:flutter_test/flutter_test.dart';
import 'package:r6box/services/vfs_map_storage/vfs_map_service_factory.dart';

void main() {
  group('VFS Map Storage Tests', () {
    test('should load maps correctly', () async {
      final mapService = VfsMapServiceFactory.createMapDatabaseService();
      
      try {
        final maps = await mapService.getAllMaps();
        print('成功加载 ${maps.length} 个地图');
        
        for (final map in maps) {
          print('地图: ID=${map.id}, 标题="${map.title}"');
          
          // 测试通过ID获取地图
          if (map.id != null) {
            final loadedMap = await mapService.getMapById(map.id!);
            if (loadedMap != null) {
              print('  ✓ 通过ID ${map.id} 成功加载地图 "${loadedMap.title}"');
            } else {
              print('  ✗ 通过ID ${map.id} 加载地图失败');
            }
          }
        }
      } catch (e) {
        print('VFS测试失败: $e');
        print('堆栈跟踪: ${StackTrace.current}');
      }
    });
  });
}
