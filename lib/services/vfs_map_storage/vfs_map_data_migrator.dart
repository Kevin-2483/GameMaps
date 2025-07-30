// This file has been processed by AI for internationalization
// import 'dart:convert';
// import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../virtual_file_system/vfs_storage_service.dart';
import 'vfs_map_service.dart';
import '../../models/map_item.dart';
import '../../l10n/app_localizations.dart';
import '../localization_service.dart';

/// VFS地图数据迁移工具
/// 注意：此功能已禁用，不用于生产环境
/// 系统直接使用VFS存储，无需从传统SQLite迁移
@Deprecated('Migration functionality is disabled, using VFS storage directly')
class VfsMapDataMigrator {
  final VfsMapService _vfsService;
  final VfsStorageService _storageService;

  VfsMapDataMigrator(this._vfsService, this._storageService);

  /// 从MapItem迁移到VFS存储
  Future<void> migrateMapItem(MapItem mapItem) async {
    try {
      debugPrint(
        LocalizationService.instance.current.startMigrationMap_7421(
          mapItem.title,
        ),
      );

      // 保存地图数据到VFS
      final mapId = await _vfsService.saveMap(mapItem);

      debugPrint(
        LocalizationService.instance.current.mapMigrationComplete(
          mapItem.title,
          mapId,
        ),
      );
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.mapMigrationFailed(
          mapItem.title,
          e.toString(),
        ),
      );
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
        debugPrint(
          LocalizationService.instance.current.skipFailedMigrationMap(
            map.title,
          ),
        );
      }
    }

    return result;
  }

  /// 验证迁移结果
  Future<bool> verifyMigration(List<MapItem> originalMaps) async {
    try {
      final vfsMaps = await _vfsService.getAllMaps();

      if (vfsMaps.length != originalMaps.length) {
        debugPrint(
          LocalizationService.instance.current.migrationValidationFailed(
            originalMaps.length,
            vfsMaps.length,
          ),
        );
        return false;
      }

      for (final originalMap in originalMaps) {
        final vfsMap = vfsMaps.firstWhere(
          (map) => map.title == originalMap.title,
          orElse: () => throw StateError(
            LocalizationService.instance.current.mapNotFoundError(
              originalMap.title,
            ),
          ),
        );

        if (!_mapsEqual(originalMap, vfsMap)) {
          debugPrint(
            LocalizationService.instance.current.migrationValidationFailed(
              originalMaps.length,
              vfsMaps.length,
            ),
          );
          return false;
        }
      }

      debugPrint(
        LocalizationService.instance.current.migrationValidationSuccess_7281,
      );
      return true;
    } catch (e) {
      debugPrint(LocalizationService.instance.current.migrationError_7425(e.toString()));
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
        final mapId =
            map.id?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString();
        await _vfsService.deleteMap(mapId);
      }
      debugPrint(LocalizationService.instance.current.vfsCleanupComplete_7281);
    } catch (e) {
      debugPrint(LocalizationService.instance.current.vfsCleanupFailed_7281(e.toString()));
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
