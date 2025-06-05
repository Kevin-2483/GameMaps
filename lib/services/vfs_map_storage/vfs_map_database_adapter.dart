import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../map_database_service.dart';
import 'vfs_map_service.dart';
import '../../models/map_item.dart';
import '../../models/map_item_summary.dart';

/// VFS地图数据库服务适配器
/// 实现与现有MapDatabaseService完全兼容的接口
/// 内部使用VFS存储系统，对外保持原有API
class VfsMapDatabaseAdapter implements MapDatabaseService {
  final VfsMapService _vfsService;
  
  // 用于兼容性的ID映射缓存
  final Map<int, String> _legacyIdToVfsId = {};
  final Map<String, int> _vfsIdToLegacyId = {};
  int _nextLegacyId = 1;

  VfsMapDatabaseAdapter(this._vfsService);

  /// 获取数据库实例（适配器模式：VFS不使用传统数据库）
  /// 此getter用于兼容MapDatabaseService接口，实际返回一个placeholder Future
  @override
  Future<Database> get database async {
    throw UnsupportedError(
      'VFS adapter does not use traditional database. Use VFS methods instead.',
    );
  }

  // 辅助方法：生成或获取Legacy ID
  int _getOrCreateLegacyId(String vfsId) {
    if (_vfsIdToLegacyId.containsKey(vfsId)) {
      return _vfsIdToLegacyId[vfsId]!;
    }
    
    final legacyId = _nextLegacyId++;
    _legacyIdToVfsId[legacyId] = vfsId;
    _vfsIdToLegacyId[vfsId] = legacyId;
    return legacyId;
  }

  // 辅助方法：获取VFS ID
  String? _getVfsId(int legacyId) {
    return _legacyIdToVfsId[legacyId];
  }

  // 辅助方法：为MapItem添加Legacy ID
  MapItem _addLegacyId(MapItem map, String vfsId) {
    final legacyId = _getOrCreateLegacyId(vfsId);
    return map.copyWith(id: legacyId);
  }

  @override
  Future<List<MapItem>> getAllMaps() async {
    final vfsMaps = await _vfsService.getAllMaps();
    final result = <MapItem>[];
    
    for (int i = 0; i < vfsMaps.length; i++) {
      final map = vfsMaps[i];
      final vfsId = map.id?.toString() ?? i.toString();
      result.add(_addLegacyId(map, vfsId));
    }
    
    return result;
  }

  @override
  Future<List<MapItemSummary>> getAllMapsSummary() async {
    final maps = await getAllMaps();
    return maps.map((map) => MapItemSummary(
      id: map.id!,
      title: map.title,
      imageData: map.imageData,
      version: map.version,
      createdAt: map.createdAt,
      updatedAt: map.updatedAt,
    )).toList();
  }

  @override
  Future<MapItem?> getMapById(int id) async {
    final vfsId = _getVfsId(id);
    if (vfsId == null) return null;
    
    final map = await _vfsService.getMapById(vfsId);
    if (map == null) return null;
    
    return _addLegacyId(map, vfsId);
  }

  @override
  Future<MapItem?> getMapByTitle(String title) async {
    final map = await _vfsService.getMapByTitle(title);
    if (map == null) return null;
    
    final vfsId = map.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    return _addLegacyId(map, vfsId);
  }

  @override
  Future<int> insertMap(MapItem map) async {
    // 检查是否已存在相同标题的地图
    final existing = await _vfsService.getMapByTitle(map.title);
    if (existing != null) {
      // 如果新地图版本更高，则更新现有地图
      if (map.version > existing.version) {
        final vfsId = existing.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
        await _vfsService.updateMapMeta(vfsId, map);
        return _getOrCreateLegacyId(vfsId);
      } else {
        // 否则不插入，返回现有地图的ID
        final vfsId = existing.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
        return _getOrCreateLegacyId(vfsId);
      }
    }

    // 不存在重复标题，直接插入
    final vfsId = await _vfsService.saveMap(map);
    return _getOrCreateLegacyId(vfsId);
  }

  @override
  Future<int> forceInsertMap(MapItem map) async {
    final vfsId = await _vfsService.saveMap(map);
    return _getOrCreateLegacyId(vfsId);
  }

  @override
  Future<void> updateMap(MapItem map) async {
    if (map.id == null) {
      throw ArgumentError('Map ID cannot be null for update operation');
    }
    
    final vfsId = _getVfsId(map.id!);
    if (vfsId == null) {
      throw ArgumentError('Map with ID ${map.id} not found in VFS mapping');
    }
    
    await _vfsService.updateMapMeta(vfsId, map);
  }

  @override
  Future<void> deleteMap(int id) async {
    final vfsId = _getVfsId(id);
    if (vfsId == null) {
      throw ArgumentError('Map with ID $id not found in VFS mapping');
    }
    
    await _vfsService.deleteMap(vfsId);
    
    // 清理映射
    _legacyIdToVfsId.remove(id);
    _vfsIdToLegacyId.remove(vfsId);
  }

  @override
  Future<void> clearAllMaps() async {
    // 获取所有地图并逐个删除
    final maps = await getAllMaps();
    for (final map in maps) {
      await deleteMap(map.id!);
    }
  }

  @override
  Future<int> getDatabaseVersion() async {
    // VFS使用语义版本，这里返回简单的整数版本
    return 1;
  }

  @override
  Future<void> setDatabaseVersion(int version) async {
    // VFS版本管理由VFS系统自己处理
    // 这里可以添加版本元数据的存储逻辑
  }

  @override
  Future<String?> exportDatabase({int? customVersion}) async {
    try {
      final maps = await getAllMaps();
      final dbVersion = customVersion ?? await getDatabaseVersion();

      final mapDatabase = MapDatabase(
        version: dbVersion,
        maps: maps,
        exportedAt: DateTime.now(),
      );

      // 构建导出文件名
      final fileName = 'maps_vfs_v${dbVersion}_${DateTime.now().millisecondsSinceEpoch}.json';
      
      // 在Web平台上，直接返回JSON数据
      if (kIsWeb) {
        return jsonEncode(mapDatabase.toJson());
      }

      // 在桌面平台上，保存到文件
      final jsonData = jsonEncode(mapDatabase.toJson());
      
      // 这里应该调用文件选择器，简化为返回JSON字符串
      debugPrint('VFS地图数据库导出成功 (版本: $dbVersion, 地图数量: ${maps.length})');
      return jsonData;
    } catch (e) {
      debugPrint('VFS地图数据库导出失败: $e');
      return null;
    }
  }

  @override
  Future<bool> importDatabaseDebug() async {
    try {
      // 在真实实现中，这里应该调用文件选择器
      // 目前返回false表示未实现
      debugPrint('VFS地图数据库导入功能暂未实现');
      return false;
    } catch (e) {
      debugPrint('VFS地图数据库导入失败: $e');
      return false;
    }
  }

  @override
  Future<void> close() async {
    // 清理资源
    _legacyIdToVfsId.clear();
    _vfsIdToLegacyId.clear();
    _nextLegacyId = 1;
  }
}
