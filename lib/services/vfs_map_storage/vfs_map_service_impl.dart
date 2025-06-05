import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../virtual_file_system/vfs_storage_service.dart';
import '../virtual_file_system/vfs_protocol.dart';
import 'vfs_map_service.dart';
import '../../models/map_item.dart';
import '../../models/map_layer.dart';

/// VFS地图服务具体实现
/// 基于VFS虚拟文件系统存储地图数据
class VfsMapServiceImpl implements VfsMapService {
  final VfsStorageService _storageService;
  final String _databaseName;
  final String _mapsCollection;
  
  // 缓存管理
  final Map<String, MapItem> _mapCache = {};
  final Map<String, List<MapLayer>> _layerCache = {};
  final Map<String, String> _assetHashIndex = {};
  
  VfsMapServiceImpl({
    required VfsStorageService storageService,
    String databaseName = 'r6box',
    String mapsCollection = 'maps',
  })  : _storageService = storageService,
        _databaseName = databaseName,
        _mapsCollection = mapsCollection;

  // 路径构建方法
  String _getMapPath(String mapId) => '$mapId.mapdata';
  String _getMapMetaPath(String mapId) => '${_getMapPath(mapId)}/meta.json';
  String _getMapLocalizationPath(String mapId) => '${_getMapPath(mapId)}/localization.json';
  String _getMapCoverPath(String mapId) => '${_getMapPath(mapId)}/cover.png';
  String _getLayersPath(String mapId) => '${_getMapPath(mapId)}/data/default/layers';
  String _getLayerPath(String mapId, String layerId) => '${_getLayersPath(mapId)}/$layerId';
  String _getLayerConfigPath(String mapId, String layerId) => '${_getLayerPath(mapId, layerId)}/config.json';
  String _getElementsPath(String mapId, String layerId) => '${_getLayerPath(mapId, layerId)}/elements';
  String _getElementPath(String mapId, String layerId, String elementId) => '${_getElementsPath(mapId, layerId)}/$elementId.json';
  String _getLegendsPath(String mapId) => '${_getMapPath(mapId)}/data/default/legends';
  String _getLegendGroupPath(String mapId, String groupId) => '${_getLegendsPath(mapId)}/$groupId';
  String _getLegendGroupConfigPath(String mapId, String groupId) => '${_getLegendGroupPath(mapId, groupId)}/config.json';
  String _getLegendItemsPath(String mapId, String groupId) => '${_getLegendGroupPath(mapId, groupId)}/items';
  String _getLegendItemPath(String mapId, String groupId, String itemId) => '${_getLegendItemsPath(mapId, groupId)}/$itemId.json';

  // VFS路径构建
  String _buildVfsPath(String path) => VfsProtocol.buildPath(_databaseName, _mapsCollection, path);
  @override
  Future<List<MapItem>> getAllMaps() async {
    try {
      final files = await _storageService.listDirectory(_buildVfsPath(''));
      final maps = <MapItem>[];
      
      for (final file in files) {
        if (file.isDirectory && file.name.endsWith('.mapdata')) {
          final mapId = file.name.replaceAll('.mapdata', '');
          final map = await getMapById(mapId);
          if (map != null) {
            maps.add(map);
          }
        }
      }
      
      return maps;
    } catch (e) {
      debugPrint('获取所有地图失败: $e');
      return [];
    }
  }

  @override
  Future<MapItem?> getMapById(String id) async {
    try {
      // 检查缓存
      if (_mapCache.containsKey(id)) {
        return _mapCache[id];
      }

      final metaPath = _buildVfsPath(_getMapMetaPath(id));
      final metaData = await _storageService.readFile(metaPath);
      
      if (metaData == null) {
        return null;
      }

      final metaJson = jsonDecode(utf8.decode(metaData.data)) as Map<String, dynamic>;
      
      // 加载图层数据
      final layers = await getMapLayers(id);
      
      // 加载图例组数据
      final legendGroups = await getMapLegendGroups(id);
        // 加载封面图片
      VfsFileContent? coverData;
      try {
        final coverPath = _buildVfsPath(_getMapCoverPath(id));        coverData = await _storageService.readFile(coverPath);
      } catch (e) {
        debugPrint('加载地图封面失败: $e');
      }

      final map = MapItem(
        id: int.tryParse(id),
        title: metaJson['title'] as String,
        imageData: coverData?.data ?? Uint8List(0),
        version: metaJson['version'] as int,
        layers: layers,
        legendGroups: legendGroups,
        createdAt: DateTime.parse(metaJson['createdAt'] as String),
        updatedAt: DateTime.parse(metaJson['updatedAt'] as String),
      );

      // 缓存结果
      _mapCache[id] = map;
      return map;
    } catch (e) {
      debugPrint('加载地图失败 [$id]: $e');
      return null;
    }
  }
  @override
  Future<MapItem?> getMapByTitle(String title) async {
    final maps = await getAllMaps();
    try {
      return maps.firstWhere((map) => map.title == title);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> saveMap(MapItem map) async {
    final mapId = map.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    try {
      // 保存元数据
      await _saveMapMeta(mapId, map);
      
      // 保存封面图片      
      if (map.imageData != null && map.imageData!.isNotEmpty) {
        await _saveMapCover(mapId, map.imageData!);
      }
      
      // 保存图层数据
      for (final layer in map.layers) {
        await saveLayer(mapId, layer);
      }
      
      // 保存图例组数据
      for (final group in map.legendGroups) {
        await saveLegendGroup(mapId, group);
      }
      
      // 清除缓存
      _mapCache.remove(mapId);
      _layerCache.remove(mapId);
      
      return mapId;
    } catch (e) {
      debugPrint('保存地图失败 [$mapId]: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteMap(String id) async {
    try {
      final mapPath = _buildVfsPath(_getMapPath(id));
      await _storageService.delete(mapPath);
      
      // 清除缓存
      _mapCache.remove(id);
      _layerCache.remove(id);
    } catch (e) {
      debugPrint('删除地图失败 [$id]: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateMapMeta(String id, MapItem map) async {
    await _saveMapMeta(id, map);
    _mapCache.remove(id); // 清除缓存
  }
  // 私有方法：保存地图元数据
  Future<void> _saveMapMeta(String mapId, MapItem map) async {
    final metaData = {
      'id': mapId,
      'title': map.title,
      'version': map.version,
      'createdAt': map.createdAt.toIso8601String(),
      'updatedAt': map.updatedAt.toIso8601String(),
      'layerCount': map.layers.length,
      'legendGroupCount': map.legendGroups.length,
      'hasImage': map.imageData != null && map.imageData!.isNotEmpty,
    };

    final metaPath = _buildVfsPath(_getMapMetaPath(mapId));
    final metaJson = jsonEncode(metaData);
    await _storageService.writeFile(metaPath, utf8.encode(metaJson));
  }

  // 私有方法：保存地图封面
  Future<void> _saveMapCover(String mapId, Uint8List imageData) async {
    final coverPath = _buildVfsPath(_getMapCoverPath(mapId));
    await _storageService.writeFile(coverPath, imageData);
  }

  @override
  Future<List<MapLayer>> getMapLayers(String mapId) async {
    try {
      // 检查缓存
      if (_layerCache.containsKey(mapId)) {
        return _layerCache[mapId]!;
      }      final layersPath = _buildVfsPath(_getLayersPath(mapId));
      final files = await _storageService.listDirectory(layersPath);
      final layers = <MapLayer>[];

      for (final file in files) {
        if (file.isDirectory) {
          final layer = await getLayerById(mapId, file.name);
          if (layer != null) {
            layers.add(layer);
          }
        }
      }

      // 按order排序
      layers.sort((a, b) => a.order.compareTo(b.order));
      
      // 缓存结果
      _layerCache[mapId] = layers;
      return layers;
    } catch (e) {
      debugPrint('加载图层列表失败 [$mapId]: $e');
      return [];
    }
  }

  @override
  Future<MapLayer?> getLayerById(String mapId, String layerId) async {
    try {
      final configPath = _buildVfsPath(_getLayerConfigPath(mapId, layerId));
      final configData = await _storageService.readFile(configPath);
        if (configData == null) {
        return null;
      }

      final configJson = jsonDecode(utf8.decode(configData.data)) as Map<String, dynamic>;
      
      // 加载图层的绘制元素
      final elements = await getLayerElements(mapId, layerId);
        return MapLayer(
        id: configJson['id'] as String,
        name: configJson['name'] as String,
        order: configJson['order'] as int,
        opacity: (configJson['opacity'] as num).toDouble(),
        isVisible: configJson['isVisible'] as bool,
        legendGroupIds: List<String>.from(configJson['legendGroupIds'] ?? []),
        elements: elements,
        createdAt: DateTime.parse(configJson['createdAt'] as String),
        updatedAt: DateTime.parse(configJson['updatedAt'] as String),
      );
    } catch (e) {
      debugPrint('加载图层失败 [$mapId/$layerId]: $e');
      return null;
    }
  }

  @override
  Future<void> saveLayer(String mapId, MapLayer layer) async {
    try {
      // 保存图层配置      
      final configData = {
        'id': layer.id,
        'name': layer.name,
        'order': layer.order,
        'opacity': layer.opacity,
        'isVisible': layer.isVisible,
        'legendGroupIds': layer.legendGroupIds,
        'createdAt': layer.createdAt.toIso8601String(),
        'updatedAt': layer.updatedAt.toIso8601String(),
      };

      final configPath = _buildVfsPath(_getLayerConfigPath(mapId, layer.id));
      final configJson = jsonEncode(configData);
      await _storageService.writeFile(configPath, utf8.encode(configJson));

      // 保存绘制元素
      for (final element in layer.elements) {
        await saveElement(mapId, layer.id, element);
      }

      // 清除缓存
      _layerCache.remove(mapId);
    } catch (e) {
      debugPrint('保存图层失败 [$mapId/${layer.id}]: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteLayer(String mapId, String layerId) async {
    try {
      final layerPath = _buildVfsPath(_getLayerPath(mapId, layerId));
      await _storageService.delete(layerPath);
      
      // 清除缓存
      _layerCache.remove(mapId);
    } catch (e) {
      debugPrint('删除图层失败 [$mapId/$layerId]: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateLayerOrder(String mapId, List<String> layerIds) async {
    // 重新排序图层
    for (int i = 0; i < layerIds.length; i++) {
      final layer = await getLayerById(mapId, layerIds[i]);
      if (layer != null) {
        final updatedLayer = layer.copyWith(order: i);
        await saveLayer(mapId, updatedLayer);
      }
    }
  }

  @override
  Future<List<MapDrawingElement>> getLayerElements(String mapId, String layerId) async {
    try {      final elementsPath = _buildVfsPath(_getElementsPath(mapId, layerId));
      final files = await _storageService.listDirectory(elementsPath);
      final elements = <MapDrawingElement>[];

      for (final file in files) {
        if (file.name.endsWith('.json')) {
          final elementId = file.name.replaceAll('.json', '');
          final element = await getElementById(mapId, layerId, elementId);
          if (element != null) {
            elements.add(element);
          }
        }
      }

      return elements;
    } catch (e) {
      debugPrint('加载绘制元素失败 [$mapId/$layerId]: $e');
      return [];
    }
  }

  @override
  Future<MapDrawingElement?> getElementById(String mapId, String layerId, String elementId) async {
    try {
      final elementPath = _buildVfsPath(_getElementPath(mapId, layerId, elementId));
      final elementData = await _storageService.readFile(elementPath);
        if (elementData == null) {
        return null;
      }

      final elementJson = jsonDecode(utf8.decode(elementData.data)) as Map<String, dynamic>;
      return MapDrawingElement.fromJson(elementJson);
    } catch (e) {
      debugPrint('加载绘制元素失败 [$mapId/$layerId/$elementId]: $e');
      return null;
    }
  }

  @override
  Future<void> saveElement(String mapId, String layerId, MapDrawingElement element) async {
    try {
      final elementPath = _buildVfsPath(_getElementPath(mapId, layerId, element.id));
      final elementJson = jsonEncode(element.toJson());
      await _storageService.writeFile(elementPath, utf8.encode(elementJson));
    } catch (e) {
      debugPrint('保存绘制元素失败 [$mapId/$layerId/${element.id}]: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteElement(String mapId, String layerId, String elementId) async {
    try {
      final elementPath = _buildVfsPath(_getElementPath(mapId, layerId, elementId));
      await _storageService.delete(elementPath);
    } catch (e) {
      debugPrint('删除绘制元素失败 [$mapId/$layerId/$elementId]: $e');
      rethrow;
    }
  }
  @override
  Future<void> updateElementsOrder(String mapId, String layerId, List<String> elementIds) async {
    // 重新排序绘制元素
    for (int i = 0; i < elementIds.length; i++) {
      final element = await getElementById(mapId, layerId, elementIds[i]);
      if (element != null) {
        // MapDrawingElement copyWith 方法中没有 order 参数，这里直接保存
        await saveElement(mapId, layerId, element);
      }
    }
  }

  @override
  Future<List<LegendGroup>> getMapLegendGroups(String mapId) async {
    try {      final legendsPath = _buildVfsPath(_getLegendsPath(mapId));
      final files = await _storageService.listDirectory(legendsPath);
      final groups = <LegendGroup>[];

      for (final file in files) {
        if (file.isDirectory) {
          final group = await getLegendGroupById(mapId, file.name);
          if (group != null) {
            groups.add(group);
          }
        }
      }

      return groups;
    } catch (e) {
      debugPrint('加载图例组失败 [$mapId]: $e');
      return [];
    }
  }

  @override
  Future<LegendGroup?> getLegendGroupById(String mapId, String groupId) async {
    try {
      final configPath = _buildVfsPath(_getLegendGroupConfigPath(mapId, groupId));
      final configData = await _storageService.readFile(configPath);
      
      if (configData == null) {
        return null;
      }

      final configJson = jsonDecode(utf8.decode(configData.data)) as Map<String, dynamic>;
      
      // 加载图例项
      final items = await getLegendGroupItems(mapId, groupId);
        return LegendGroup(
        id: configJson['id'] as String,
        name: configJson['name'] as String,
        isVisible: configJson['isVisible'] as bool? ?? true,
        opacity: (configJson['opacity'] as num?)?.toDouble() ?? 1.0,
        legendItems: items,
        createdAt: DateTime.parse(configJson['createdAt'] as String),
        updatedAt: DateTime.parse(configJson['updatedAt'] as String),
      );
    } catch (e) {
      debugPrint('加载图例组失败 [$mapId/$groupId]: $e');
      return null;
    }
  }
  @override
  Future<void> saveLegendGroup(String mapId, LegendGroup group) async {
    try {
      // 保存图例组配置
      final configData = {
        'id': group.id,
        'name': group.name,
        'isVisible': group.isVisible,
        'opacity': group.opacity,
        'createdAt': group.createdAt.toIso8601String(),
        'updatedAt': group.updatedAt.toIso8601String(),
      };

      final configPath = _buildVfsPath(_getLegendGroupConfigPath(mapId, group.id));
      final configJson = jsonEncode(configData);
      await _storageService.writeFile(configPath, utf8.encode(configJson));

      // 保存图例项
      for (final item in group.legendItems) {
        await saveLegendItem(mapId, group.id, item);
      }
    } catch (e) {
      debugPrint('保存图例组失败 [$mapId/${group.id}]: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteLegendGroup(String mapId, String groupId) async {
    try {
      final groupPath = _buildVfsPath(_getLegendGroupPath(mapId, groupId));
      await _storageService.delete(groupPath);
    } catch (e) {
      debugPrint('删除图例组失败 [$mapId/$groupId]: $e');
      rethrow;
    }
  }

  @override
  Future<List<LegendItem>> getLegendGroupItems(String mapId, String groupId) async {
    try {      final itemsPath = _buildVfsPath(_getLegendItemsPath(mapId, groupId));
      final files = await _storageService.listDirectory(itemsPath);
      final items = <LegendItem>[];

      for (final file in files) {
        if (file.name.endsWith('.json')) {
          final itemId = file.name.replaceAll('.json', '');
          final item = await getLegendItemById(mapId, groupId, itemId);
          if (item != null) {
            items.add(item);
          }
        }
      }

      return items;
    } catch (e) {
      debugPrint('加载图例项失败 [$mapId/$groupId]: $e');
      return [];
    }
  }

  @override
  Future<LegendItem?> getLegendItemById(String mapId, String groupId, String itemId) async {
    try {
      final itemPath = _buildVfsPath(_getLegendItemPath(mapId, groupId, itemId));
      final itemData = await _storageService.readFile(itemPath);
      
      if (itemData == null) {
        return null;
      }

      final itemJson = jsonDecode(utf8.decode(itemData.data)) as Map<String, dynamic>;
      return LegendItem.fromJson(itemJson);
    } catch (e) {
      debugPrint('加载图例项失败 [$mapId/$groupId/$itemId]: $e');
      return null;
    }
  }

  @override
  Future<void> saveLegendItem(String mapId, String groupId, LegendItem item) async {
    try {
      final itemPath = _buildVfsPath(_getLegendItemPath(mapId, groupId, item.id.toString()));
      final itemJson = jsonEncode(item.toJson());
      await _storageService.writeFile(itemPath, utf8.encode(itemJson));
    } catch (e) {
      debugPrint('保存图例项失败 [$mapId/$groupId/${item.id}]: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteLegendItem(String mapId, String groupId, String itemId) async {
    try {
      final itemPath = _buildVfsPath(_getLegendItemPath(mapId, groupId, itemId));
      await _storageService.delete(itemPath);
    } catch (e) {
      debugPrint('删除图例项失败 [$mapId/$groupId/$itemId]: $e');
      rethrow;
    }
  }

  @override
  Future<String> saveAsset(Uint8List data, String? mimeType) async {
    try {
      // 计算SHA-256哈希
      final hash = sha256.convert(data).toString();
      
      // 确定文件扩展名
      String extension = '';
      if (mimeType != null) {
        switch (mimeType) {
          case 'image/png':
            extension = '.png';
            break;
          case 'image/jpeg':
            extension = '.jpg';
            break;
          case 'image/svg+xml':
            extension = '.svg';
            break;
          default:
            extension = '';
        }
      }
      
      final filename = '$hash$extension';
      
      // 建立全局资产索引（跨地图共享）
      final globalAssetPath = VfsProtocol.buildPath(_databaseName, 'assets', filename);
      
      // 检查资产是否已存在
      final existingData = await _storageService.readFile(globalAssetPath);
      if (existingData == null) {
        // 保存新资产
        await _storageService.writeFile(globalAssetPath, data);
      }
      
      // 更新哈希索引
      _assetHashIndex[hash] = filename;
      
      return hash;
    } catch (e) {
      debugPrint('保存资产失败: $e');
      rethrow;
    }
  }
  @override
  Future<Uint8List?> getAsset(String hash) async {
    try {
      // 优先从全局资产库查找
      final globalAssetPath = VfsProtocol.buildPath(_databaseName, 'assets', '$hash.png');
      VfsFileContent? fileContent = await _storageService.readFile(globalAssetPath);
      
      if (fileContent == null) {
        // 尝试其他扩展名
        for (final ext in ['.jpg', '.svg', '']) {
          final path = VfsProtocol.buildPath(_databaseName, 'assets', '$hash$ext');
          fileContent = await _storageService.readFile(path);
          if (fileContent != null) break;
        }
      }
      
      return fileContent?.data;
    } catch (e) {
      debugPrint('获取资产失败 [$hash]: $e');
      return null;
    }
  }

  @override
  Future<void> deleteAsset(String hash) async {
    try {
      // 从全局资产库删除
      for (final ext in ['.png', '.jpg', '.svg', '']) {
        try {
          final path = VfsProtocol.buildPath(_databaseName, 'assets', '$hash$ext');
          await _storageService.delete(path);
        } catch (e) {
          // 忽略文件不存在的错误
        }
      }
      
      _assetHashIndex.remove(hash);
    } catch (e) {
      debugPrint('删除资产失败 [$hash]: $e');
      rethrow;
    }
  }

  @override
  Future<void> cleanupUnusedAssets(String mapId) async {
    // TODO: 实现未使用资产清理逻辑
    // 需要扫描地图中所有引用的资产哈希，删除未被引用的资产
  }

  @override
  Future<Map<String, int>> getAssetUsageStats(String mapId) async {
    // TODO: 实现资产使用统计
    return {};
  }

  @override
  Future<Map<String, String>> getMapLocalizations(String mapId) async {
    try {
      final localizationPath = _buildVfsPath(_getMapLocalizationPath(mapId));
      final localizationData = await _storageService.readFile(localizationPath);
      
      if (localizationData == null) {
        return {};
      }

      final localizationJson = jsonDecode(utf8.decode(localizationData.data)) as Map<String, dynamic>;
      return Map<String, String>.from(localizationJson);
    } catch (e) {
      debugPrint('获取地图本地化失败 [$mapId]: $e');
      return {};
    }
  }

  @override
  Future<void> saveMapLocalizations(String mapId, Map<String, String> localizations) async {
    try {
      final localizationPath = _buildVfsPath(_getMapLocalizationPath(mapId));
      final localizationJson = jsonEncode(localizations);
      await _storageService.writeFile(localizationPath, utf8.encode(localizationJson));
    } catch (e) {
      debugPrint('保存地图本地化失败 [$mapId]: $e');
      rethrow;
    }
  }

  @override
  Future<bool> mapExists(String id) async {
    try {
      final metaPath = _buildVfsPath(_getMapMetaPath(id));
      final metaData = await _storageService.readFile(metaPath);
      return metaData != null;
    } catch (e) {
      return false;
    }
  }
  @override
  Future<Map<String, dynamic>> getMapStats(String id) async {
    final map = await getMapById(id);
    if (map == null) {
      return {};
    }

    int totalElements = 0;
    int totalLegendItems = 0;
    
    for (final layer in map.layers) {
      totalElements += layer.elements.length;
    }
    
    for (final group in map.legendGroups) {
      totalLegendItems += group.legendItems.length;
    }

    return {
      'layerCount': map.layers.length,
      'elementCount': totalElements,
      'legendGroupCount': map.legendGroups.length,
      'legendItemCount': totalLegendItems,
      'hasImage': map.imageData?.isNotEmpty ?? false,
      'version': map.version,
      'createdAt': map.createdAt.toIso8601String(),
      'updatedAt': map.updatedAt.toIso8601String(),
    };
  }

  @override
  Future<void> validateMapIntegrity(String id) async {
    // TODO: 实现地图完整性验证
    // 检查文件结构完整性、引用完整性等
  }

  @override
  Future<void> duplicateMap(String sourceId, String newTitle) async {
    // TODO: 实现地图复制功能
  }

  @override
  Future<void> exportMap(String id, String exportPath) async {
    // TODO: 实现地图导出功能
  }

  @override
  Future<String> importMap(String importPath, {bool overwrite = false}) async {
    // TODO: 实现地图导入功能
    throw UnimplementedError();
  }
}
