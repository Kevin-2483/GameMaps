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

  // 用于兼容性的ID映射缓存 - 现在映射到标题
  final Map<int, String> _legacyIdToTitle = {};
  final Map<String, int> _titleToLegacyId = {};
  int _nextLegacyId = 1;

  VfsMapDatabaseAdapter(this._vfsService) {
    _initializeMapping();
  }

  /// 初始化ID映射
  Future<void> _initializeMapping() async {
    try {
      final maps = await _vfsService.getAllMaps();
      for (final map in maps) {
        final title = map.title;
        if (!_titleToLegacyId.containsKey(title)) {
          final legacyId = _nextLegacyId++;
          _legacyIdToTitle[legacyId] = title;
          _titleToLegacyId[title] = legacyId;
        }
      }
    } catch (e) {
      debugPrint('初始化ID映射失败: $e');
    }
  }

  /// 获取数据库实例（适配器模式：VFS不使用传统数据库）
  /// 此getter用于兼容MapDatabaseService接口，实际返回一个placeholder Future
  @override
  Future<Database> get database async {
    throw UnsupportedError(
      'VFS adapter does not use traditional database. Use VFS methods instead.',
    );
  }

  // 辅助方法：生成或获取Legacy ID
  int _getOrCreateLegacyId(String title) {
    if (_titleToLegacyId.containsKey(title)) {
      return _titleToLegacyId[title]!;
    }

    final legacyId = _nextLegacyId++;
    _legacyIdToTitle[legacyId] = title;
    _titleToLegacyId[title] = legacyId;
    return legacyId;
  }

  // 辅助方法：获取标题
  String? _getTitle(int legacyId) {
    return _legacyIdToTitle[legacyId];
  }

  // 辅助方法：为MapItem添加Legacy ID
  MapItem _addLegacyId(MapItem map, String title) {
    final legacyId = _getOrCreateLegacyId(title);
    return map.copyWith(id: legacyId);
  }

  @override
  Future<List<MapItem>> getAllMaps() async {
    final vfsMaps = await _vfsService.getAllMaps();
    final result = <MapItem>[];

    for (final map in vfsMaps) {
      result.add(_addLegacyId(map, map.title));
    }

    return result;
  }

  @override
  Future<List<MapItemSummary>> getAllMapsSummary() async {
    final maps = await getAllMaps();
    return maps
        .map(
          (map) => MapItemSummary(
            id: map.id!,
            title: map.title,
            imageData: map.imageData,
            version: map.version,
            createdAt: map.createdAt,
            updatedAt: map.updatedAt,
          ),
        )
        .toList();
  }

  @override
  Future<MapItem?> getMapById(int id) async {
    final title = _getTitle(id);
    if (title == null) return null;

    final map = await _vfsService.getMapByTitle(title);
    if (map == null) return null;

    return _addLegacyId(map, title);
  }

  @override
  Future<MapItem?> getMapByTitle(String title) async {
    final map = await _vfsService.getMapByTitle(title);
    if (map == null) return null;

    return _addLegacyId(map, title);
  }

  @override
  Future<int> insertMap(MapItem map) async {
    // 检查是否已存在相同标题的地图
    final existing = await _vfsService.getMapByTitle(map.title);
    if (existing != null) {
      // 如果新地图版本更高，则更新现有地图
      if (map.version > existing.version) {
        await _vfsService.updateMapMeta(map.title, map);
        return _getOrCreateLegacyId(map.title);
      } else {
        // 否则不插入，返回现有地图的ID
        return _getOrCreateLegacyId(map.title);
      }
    }

    // 不存在重复标题，直接插入
    final title = await _vfsService.saveMap(map);
    return _getOrCreateLegacyId(title);
  }

  @override
  Future<int> forceInsertMap(MapItem map) async {
    final title = await _vfsService.saveMap(map);
    return _getOrCreateLegacyId(title);
  }

  @override
  Future<void> updateMap(MapItem map) async {
    if (map.id == null) {
      throw ArgumentError('Map ID cannot be null for update operation');
    }

    String? title = _getTitle(map.id!);

    // 如果ID映射失败，尝试使用地图标题直接查找
    if (title == null) {
      // 检查地图标题是否存在于VFS中
      final existingMap = await _vfsService.getMapByTitle(map.title);
      if (existingMap != null) {
        // 重新建立映射关系
        title = map.title;
        _legacyIdToTitle[map.id!] = title;
        _titleToLegacyId[title] = map.id!;
      } else {
        throw ArgumentError(
          'Map with ID ${map.id} and title "${map.title}" not found',
        );
      }
    }

    // 使用saveMap来保存完整的地图数据，而不仅仅是元数据
    await _vfsService.saveMap(map);
  }

  @override
  Future<void> deleteMap(int id) async {
    final title = _getTitle(id);
    if (title == null) {
      throw ArgumentError('Map with ID $id not found in mapping');
    }

    await _vfsService.deleteMap(title);

    // 清理映射
    _legacyIdToTitle.remove(id);
    _titleToLegacyId.remove(title);
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
      ); // 构建导出文件名 - VFS系统会处理文件命名
      debugPrint('开始导出VFS地图数据库...');

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
    _legacyIdToTitle.clear();
    _titleToLegacyId.clear();
    _nextLegacyId = 1;
  }
}
