import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../virtual_file_system/vfs_storage_service.dart';
import 'vfs_map_service.dart';
import '../../models/map_item.dart';

/// VFS地图数据迁移工具
/// 注意：此功能已禁用，不用于生产环境
/// 系统直接使用VFS存储，无需从传统SQLite迁移
@Deprecated('迁移功能已禁用，直接使用VFS存储')
class VfsMapDataMigrator {
  final VfsMapService _vfsService;
  final VfsStorageService _storageService;

  VfsMapDataMigrator(this._vfsService, this._storageService);

  /// 从MapItem迁移到VFS存储
  Future<void> migrateMapItem(MapItem mapItem) async {
    try {
      debugPrint('开始迁移地图: ${mapItem.title}');
      
      // 保存地图数据到VFS
      final mapId = await _vfsService.saveMap(mapItem);
      
      debugPrint('地图迁移完成: ${mapItem.title} -> $mapId');
    } catch (e) {
      debugPrint('地图迁移失败: ${mapItem.title} - $e');
      rethrow;
    }
  }

  /// 批量迁移地图列表
  Future<MigrationResult> migrateAllMaps(List<MapItem> maps) async {
    final result = MigrationResult();
    
    for (final map in maps) {
      try {
        await migrateMapItem(map);
        result.successCount++;
        result.successMaps.add(map.title);
      } catch (e) {
        result.failureCount++;
        result.failedMaps[map.title] = e.toString();
        debugPrint('跳过迁移失败的地图: ${map.title}');
      }
    }
    
    return result;
  }

  /// 验证迁移结果
  Future<bool> verifyMigration(List<MapItem> originalMaps) async {
    try {
      final vfsMaps = await _vfsService.getAllMaps();
      
      if (vfsMaps.length != originalMaps.length) {
        debugPrint('迁移验证失败: 地图数量不匹配 (原始: ${originalMaps.length}, VFS: ${vfsMaps.length})');
        return false;
      }
      
      for (final originalMap in originalMaps) {
        final vfsMap = vfsMaps.firstWhere(
          (map) => map.title == originalMap.title,
          orElse: () => throw StateError('找不到地图: ${originalMap.title}'),
        );
        
        if (!_mapsEqual(originalMap, vfsMap)) {
          debugPrint('迁移验证失败: 地图数据不匹配 - ${originalMap.title}');
          return false;
        }
      }
      
      debugPrint('迁移验证成功: 所有地图数据完整');
      return true;
    } catch (e) {
      debugPrint('迁移验证出错: $e');
      return false;
    }
  }

  /// 比较两个地图是否相等（忽略ID）
  bool _mapsEqual(MapItem map1, MapItem map2) {
    return map1.title == map2.title &&
           map1.version == map2.version &&
           map1.layers.length == map2.layers.length &&
           map1.legendGroups.length == map2.legendGroups.length;
    // 这里可以添加更详细的比较逻辑
  }

  /// 清理VFS中的所有地图数据（用于重新迁移）
  Future<void> cleanupVfsData() async {
    try {
      final maps = await _vfsService.getAllMaps();
      for (final map in maps) {
        final mapId = map.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
        await _vfsService.deleteMap(mapId);
      }
      debugPrint('VFS数据清理完成');
    } catch (e) {
      debugPrint('VFS数据清理失败: $e');
      rethrow;
    }
  }
}

/// 迁移结果统计
class MigrationResult {
  int successCount = 0;
  int failureCount = 0;
  List<String> successMaps = [];
  Map<String, String> failedMaps = {};

  bool get hasFailures => failureCount > 0;
  int get totalCount => successCount + failureCount;

  @override
  String toString() {
    return 'MigrationResult(total: $totalCount, success: $successCount, failure: $failureCount)';
  }
}
