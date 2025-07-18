import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import '../virtual_file_system/vfs_storage_service.dart';
import '../virtual_file_system/vfs_protocol.dart';
import 'vfs_map_service.dart';
import '../../models/map_item.dart';
import '../../models/map_item_summary.dart';
import '../../models/map_layer.dart';
import '../../models/sticky_note.dart';
import '../../utils/filename_sanitizer.dart';

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
  }) : _storageService = storageService,
       _databaseName = databaseName,
       _mapsCollection = mapsCollection;

  // 路径构建方法 - 支持子目录结构
  String _getMapPath(String mapTitle, [String? folderPath]) {
    final sanitizedTitle = FilenameSanitizer.sanitize(mapTitle);
    final mapDataName = '$sanitizedTitle.mapdata';

    if (folderPath == null || folderPath.isEmpty) {
      return mapDataName;
    }

    // 确保文件夹路径格式正确
    final cleanFolderPath = folderPath.replaceAll(RegExp(r'^/+|/+$'), '');
    return '$cleanFolderPath/$mapDataName';
  }

  String _getMapMetaPath(String mapTitle, [String? folderPath]) =>
      '${_getMapPath(mapTitle, folderPath)}/meta.json';
  String _getMapLocalizationPath(String mapTitle, [String? folderPath]) =>
      '${_getMapPath(mapTitle, folderPath)}/localization.json';
  String _getMapCoverPath(String mapTitle, [String? folderPath]) =>
      '${_getMapPath(mapTitle, folderPath)}/cover.png';
  String _getLayersPath(
    String mapTitle, [
    String version = 'default',
    String? folderPath,
  ]) => '${_getMapPath(mapTitle, folderPath)}/data/$version/layers';
  String _getLayerPath(
    String mapTitle,
    String layerId, [
    String version = 'default',
    String? folderPath,
  ]) => '${_getLayersPath(mapTitle, version, folderPath)}/$layerId';
  String _getLayerConfigPath(
    String mapTitle,
    String layerId, [
    String version = 'default',
    String? folderPath,
  ]) => '${_getLayerPath(mapTitle, layerId, version, folderPath)}/config.json';
  String _getElementsPath(
    String mapTitle,
    String layerId, [
    String version = 'default',
    String? folderPath,
  ]) => '${_getLayerPath(mapTitle, layerId, version, folderPath)}/elements';
  String _getElementPath(
    String mapTitle,
    String layerId,
    String elementId, [
    String version = 'default',
    String? folderPath,
  ]) =>
      '${_getLayersPath(mapTitle, version, folderPath)}/$layerId/elements/$elementId.json';
  String _getLegendsPath(
    String mapTitle, [
    String version = 'default',
    String? folderPath,
  ]) => '${_getMapPath(mapTitle, folderPath)}/data/$version/legends';
  String _getLegendGroupPath(
    String mapTitle,
    String groupId, [
    String version = 'default',
    String? folderPath,
  ]) => '${_getLegendsPath(mapTitle, version, folderPath)}/$groupId';
  String _getLegendGroupConfigPath(
    String mapTitle,
    String groupId, [
    String version = 'default',
    String? folderPath,
  ]) =>
      '${_getLegendGroupPath(mapTitle, groupId, version, folderPath)}/config.json';
  String _getLegendItemsPath(
    String mapTitle,
    String groupId, [
    String version = 'default',
    String? folderPath,
  ]) => '${_getLegendGroupPath(mapTitle, groupId, version, folderPath)}/items';
  String _getLegendItemPath(
    String mapTitle,
    String groupId,
    String itemId, [
    String version = 'default',
    String? folderPath,
  ]) =>
      '${_getLegendItemsPath(mapTitle, groupId, version, folderPath)}/$itemId.json';

  // 便签数据路径构建方法 - 在版本独立的文件夹下建立note文件夹
  String _getNotesPath(
    String mapTitle, [
    String version = 'default',
    String? folderPath,
  ]) => '${_getMapPath(mapTitle, folderPath)}/data/$version/notes';
  String _getStickyNotePath(
    String mapTitle,
    String noteId, [
    String version = 'default',
    String? folderPath,
  ]) => '${_getNotesPath(mapTitle, version, folderPath)}/$noteId.json';

  // 资产管理路径构建 - 需要动态查找地图所在的文件夹
  String _getAssetsPath(String mapTitle, [String? folderPath]) =>
      '${_getMapPath(mapTitle, folderPath)}/assets';
  String _getAssetPath(
    String mapTitle,
    String filename, [
    String? folderPath,
  ]) => '${_getAssetsPath(mapTitle, folderPath)}/$filename';

  // VFS路径构建
  String _buildVfsPath(String path) =>
      VfsProtocol.buildPath(_databaseName, _mapsCollection, path);

  @override
  Future<List<MapItem>> getAllMaps([String? folderPath]) async {
    try {
      final basePath = folderPath == null || folderPath.isEmpty
          ? ''
          : folderPath.replaceAll(RegExp(r'^/+|/+$'), '') + '/';

      final files = await _storageService.listDirectory(
        _buildVfsPath(basePath),
      );
      final maps = <MapItem>[];

      for (final file in files) {
        if (file.isDirectory && file.name.endsWith('.mapdata')) {
          // 从文件名提取标题
          final mapTitle = file.name.replaceAll('.mapdata', '');
          final map = await getMapByTitle(
            FilenameSanitizer.desanitize(mapTitle),
            folderPath,
          );
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
  Future<List<MapItemSummary>> getAllMapsSummary([String? folderPath]) async {
    try {
      final basePath = folderPath == null || folderPath.isEmpty
          ? ''
          : folderPath.replaceAll(RegExp(r'^/+|/+$'), '') + '/';

      final files = await _storageService.listDirectory(
        _buildVfsPath(basePath),
      );
      final summaries = <MapItemSummary>[];

      for (final file in files) {
        if (file.isDirectory && file.name.endsWith('.mapdata')) {
          // 从文件名提取标题
          final mapTitle = file.name.replaceAll('.mapdata', '');
          final desanitizedTitle = FilenameSanitizer.desanitize(mapTitle);
          
          try {
            // 读取元数据
            final metaPath = _buildVfsPath(_getMapMetaPath(desanitizedTitle, folderPath));
            final metaData = await _storageService.readFile(metaPath);
            
            if (metaData == null) continue;
            
            final metaJson = jsonDecode(utf8.decode(metaData.data)) as Map<String, dynamic>;
            
            // 检查标题是否与文件夹名称一致，如果不一致则更新
            final metaTitle = metaJson['title'] as String;
            if (metaTitle != desanitizedTitle) {
              metaJson['title'] = desanitizedTitle;
              metaJson['updatedAt'] = DateTime.now().toIso8601String();
              
              // 保存更新后的元数据
              final updatedMetaData = utf8.encode(jsonEncode(metaJson));
              await _storageService.writeFile(metaPath, updatedMetaData);
            }
            
            // 读取封面图片
            Uint8List? coverData;
            try {
              final coverPath = _buildVfsPath(_getMapCoverPath(desanitizedTitle, folderPath));
              final coverFile = await _storageService.readFile(coverPath);
              coverData = coverFile?.data;
            } catch (e) {
              debugPrint('加载地图封面失败: $e');
            }
            
            final summary = MapItemSummary(
              id: int.tryParse(metaJson['id'] as String? ?? '') ?? desanitizedTitle.hashCode,
              title: desanitizedTitle,
              imageData: coverData ?? Uint8List(0),
              version: metaJson['version'] as int,
              createdAt: DateTime.parse(metaJson['createdAt'] as String),
              updatedAt: DateTime.parse(metaJson['updatedAt'] as String),
            );
            
            summaries.add(summary);
          } catch (e) {
            debugPrint('加载地图摘要失败 [$desanitizedTitle]: $e');
          }
        }
      }

      return summaries;
    } catch (e) {
      debugPrint('获取所有地图摘要失败: $e');
      return [];
    }
  }

  @override
  Future<MapItemSummary?> getMapSummaryByPath(String mapPath) async {
    try {
      // mapPath 格式: "folder1/folder2/mapname.mapdata" 或 "mapname.mapdata"
      String mapTitle;
      String? folderPath;
      
      if (mapPath.contains('/')) {
        final pathParts = mapPath.split('/');
        final mapdataName = pathParts.last;
        mapTitle = mapdataName.replaceAll('.mapdata', '');
        folderPath = pathParts.sublist(0, pathParts.length - 1).join('/');
      } else {
        mapTitle = mapPath.replaceAll('.mapdata', '');
        folderPath = null;
      }
      
      final desanitizedTitle = FilenameSanitizer.desanitize(mapTitle);
      
      // 读取元数据
      final metaPath = _buildVfsPath(_getMapMetaPath(desanitizedTitle, folderPath));
      final metaData = await _storageService.readFile(metaPath);
      
      if (metaData == null) return null;
      
      final metaJson = jsonDecode(utf8.decode(metaData.data)) as Map<String, dynamic>;
      
      // 读取封面图片
      Uint8List? coverData;
      try {
        final coverPath = _buildVfsPath(_getMapCoverPath(desanitizedTitle, folderPath));
        final coverFile = await _storageService.readFile(coverPath);
        coverData = coverFile?.data;
      } catch (e) {
        debugPrint('加载地图封面失败: $e');
      }
      
      final summary = MapItemSummary(
        id: int.tryParse(metaJson['id'] as String? ?? '') ?? desanitizedTitle.hashCode,
        title: desanitizedTitle,
        imageData: coverData ?? Uint8List(0),
        version: metaJson['version'] as int,
        createdAt: DateTime.parse(metaJson['createdAt'] as String),
        updatedAt: DateTime.parse(metaJson['updatedAt'] as String),
      );
      
      return summary;
    } catch (e) {
      debugPrint('根据路径获取地图摘要失败 [$mapPath]: $e');
      return null;
    }
  }

  @override
  Future<int> getMapCount([String? folderPath]) async {
    try {
      final basePath = folderPath == null || folderPath.isEmpty
          ? ''
          : folderPath.replaceAll(RegExp(r'^/+|/+$'), '') + '/';

      final files = await _storageService.listDirectory(
        _buildVfsPath(basePath),
      );
      
      int count = 0;
      for (final file in files) {
        if (file.isDirectory && file.name.endsWith('.mapdata')) {
          count++;
        }
      }

      return count;
    } catch (e) {
      debugPrint('获取地图数量失败: $e');
      return 0;
    }
  }

  @override
  Future<MapItem?> getMapById(String id) async {
    try {
      // 为了兼容性，getMapById会尝试将ID作为标题查找
      // 首先尝试直接作为标题查找
      final map = await getMapByTitle(id);
      if (map != null) {
        return map;
      }

      // 如果找不到，可能是数字ID，在这种情况下我们无法处理
      debugPrint('无法通过ID查找地图，VFS系统使用基于标题的存储: $id');
      return null;
    } catch (e) {
      debugPrint('通过ID加载地图失败 [$id]: $e');
      return null;
    }
  }

  @override
  Future<MapItem?> getMapByTitle(String title, [String? folderPath]) async {
    try {
      // 检查缓存
      final cacheKey = folderPath == null ? title : '$folderPath/$title';
      if (_mapCache.containsKey(cacheKey)) {
        return _mapCache[cacheKey];
      }

      final metaPath = _buildVfsPath(_getMapMetaPath(title, folderPath));
      final metaData = await _storageService.readFile(metaPath);

      if (metaData == null) {
        return null;
      }

      final metaJson =
          jsonDecode(utf8.decode(metaData.data))
              as Map<String, dynamic>; // 加载图层数据
      final layers = await getMapLayers(title, 'default', folderPath);

      // 加载图例组数据
      final legendGroups = await getMapLegendGroups(
        title,
        'default',
        folderPath,
      );

      // 加载便签数据
      final stickyNotes = await getMapStickyNotes(title, 'default', folderPath);

      // 加载封面图片
      VfsFileContent? coverData;
      try {
        final coverPath = _buildVfsPath(_getMapCoverPath(title, folderPath));
        coverData = await _storageService.readFile(coverPath);
      } catch (e) {
        debugPrint('加载地图封面失败: $e');
      }

      final map = MapItem(
        id: int.tryParse(metaJson['id'] as String? ?? ''),
        title: metaJson['title'] as String,
        imageData: coverData?.data ?? Uint8List(0),
        version: metaJson['version'] as int,
        layers: layers,
        legendGroups: legendGroups,
        stickyNotes: stickyNotes,
        createdAt: DateTime.parse(metaJson['createdAt'] as String),
        updatedAt: DateTime.parse(metaJson['updatedAt'] as String),
      );

      // 缓存结果 - 使用包含文件夹路径的键
      _mapCache[cacheKey] = map;
      return map;
    } catch (e) {
      debugPrint('加载地图失败 [$title]: $e');
      return null;
    }
  }

  @override
  Future<String> saveMap(MapItem map, [String? folderPath]) async {
    try {
      // 删除旧的data和assets目录，为新数据腾出空间
      await _deleteOldDataAndAssets(map.title, folderPath);

      // 保存元数据
      await _saveMapMeta(map.title, map, folderPath);

      // 保存封面图片
      if (map.imageData != null && map.imageData!.isNotEmpty) {
        await _saveMapCover(map.title, map.imageData!, folderPath);
      } // 保存图层数据
      for (final layer in map.layers) {
        await saveLayer(map.title, layer, 'default', folderPath);
      }

      // 保存图例组数据
      for (final group in map.legendGroups) {
        await saveLegendGroup(map.title, group, 'default', folderPath);
      }

      // 保存便签数据
      for (final stickyNote in map.stickyNotes) {
        await saveStickyNote(map.title, stickyNote, 'default', folderPath);
      }

      // 清除缓存
      final cacheKey = folderPath == null
          ? map.title
          : '$folderPath/${map.title}';
      _mapCache.remove(cacheKey);
      final layerCacheKey = folderPath == null
          ? '${map.title}:default'
          : '$folderPath/${map.title}:default';
      _layerCache.remove(layerCacheKey);

      return map.title; // 返回标题作为标识符
    } catch (e) {
      debugPrint('保存地图失败 [${map.title}]: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteMap(String mapTitle, [String? folderPath]) async {
    try {
      final mapPath = _buildVfsPath(_getMapPath(mapTitle, folderPath));
      await _storageService.delete(mapPath);

      // 清除缓存
      final cacheKey = folderPath == null ? mapTitle : '$folderPath/$mapTitle';
      _mapCache.remove(cacheKey);
      final layerCacheKey = folderPath == null
          ? '$mapTitle:default'
          : '$folderPath/$mapTitle:default';
      _layerCache.remove(layerCacheKey);
    } catch (e) {
      debugPrint('删除地图失败 [$mapTitle]: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateMapMeta(
    String mapTitle,
    MapItem map, [
    String? folderPath,
  ]) async {
    await _saveMapMeta(mapTitle, map, folderPath);
    final cacheKey = folderPath == null ? mapTitle : '$folderPath/$mapTitle';
    _mapCache.remove(cacheKey); // 清除缓存
  }

  // 私有方法：保存地图元数据
  Future<void> _saveMapMeta(
    String mapTitle,
    MapItem map, [
    String? folderPath,
  ]) async {
    final metaData = {
      'id':
          map.id?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      'title': map.title,
      'version': map.version,
      'createdAt': map.createdAt.toIso8601String(),
      'updatedAt': map.updatedAt.toIso8601String(),
      'layerCount': map.layers.length,
      'legendGroupCount': map.legendGroups.length,
      'hasImage': map.imageData != null && map.imageData!.isNotEmpty,
    };

    final metaPath = _buildVfsPath(_getMapMetaPath(mapTitle, folderPath));
    final metaJson = jsonEncode(metaData);
    await _storageService.writeFile(metaPath, utf8.encode(metaJson));
  }

  // 私有方法：保存地图封面
  Future<void> _saveMapCover(
    String mapTitle,
    Uint8List imageData, [
    String? folderPath,
  ]) async {
    final coverPath = _buildVfsPath(_getMapCoverPath(mapTitle, folderPath));
    await _storageService.writeFile(coverPath, imageData);
  }

  // 私有方法：删除旧的data和assets目录
  Future<void> _deleteOldDataAndAssets(
    String mapTitle, [
    String? folderPath,
  ]) async {
    try {
      // 删除data目录（递归删除所有子文件和子目录）
      final dataPath = _buildVfsPath(
        '${_getMapPath(mapTitle, folderPath)}/data',
      );
      final dataExists = await _storageService.exists(dataPath);
      if (dataExists) {
        await _storageService.delete(dataPath, recursive: true);
        debugPrint('已递归删除旧的data目录及其所有内容: $dataPath');
      }

      // 删除assets目录（递归删除所有子文件和子目录）
      final assetsPath = _buildVfsPath(_getAssetsPath(mapTitle, folderPath));
      final assetsExists = await _storageService.exists(assetsPath);
      if (assetsExists) {
        await _storageService.delete(assetsPath, recursive: true);
        debugPrint('已递归删除旧的assets目录及其所有内容: $assetsPath');
      }
    } catch (e) {
      debugPrint('删除旧数据目录时出错 [$mapTitle]: $e');
      // 继续执行，不抛出异常，因为旧数据不存在是正常情况
    }
  }

  @override
  Future<List<MapLayer>> getMapLayers(
    String mapTitle, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      // 检查缓存
      final cacheKey = folderPath == null
          ? '$mapTitle:$version'
          : '$folderPath/$mapTitle:$version';
      if (_layerCache.containsKey(cacheKey)) {
        return _layerCache[cacheKey]!;
      }

      final layersPath = _buildVfsPath(
        _getLayersPath(mapTitle, version, folderPath),
      );
      final files = await _storageService.listDirectory(layersPath);
      final layers = <MapLayer>[];

      for (final file in files) {
        if (file.isDirectory) {
          final layer = await getLayerById(
            mapTitle,
            file.name,
            version,
            folderPath,
          );
          if (layer != null) {
            layers.add(layer);
          }
        }
      }

      // 按order排序
      layers.sort((a, b) => a.order.compareTo(b.order));

      // 缓存结果
      _layerCache[cacheKey] = layers;
      return layers;
    } catch (e) {
      debugPrint('加载图层列表失败 [$mapTitle:$version]: $e');
      return [];
    }
  }

  @override
  Future<MapLayer?> getLayerById(
    String mapTitle,
    String layerId, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      final configPath = _buildVfsPath(
        _getLayerConfigPath(mapTitle, layerId, version, folderPath),
      );
      final configData = await _storageService.readFile(configPath);

      if (configData == null) {
        return null;
      }

      final configJson =
          jsonDecode(utf8.decode(configData.data)) as Map<String, dynamic>;

      // 加载图层的绘制元素
      final elements = await getLayerElements(
        mapTitle,
        layerId,
        version,
        folderPath,
      );

      // 加载图层背景图片数据（如果存在）
      Uint8List? imageData;
      if (configJson['imageData'] != null) {
        final imageConfig = configJson['imageData'] as Map<String, dynamic>;
        final hash = imageConfig['hash'] as String;
        imageData = await getAsset(mapTitle, hash, folderPath);
        if (imageData != null) {
          debugPrint('图层背景图已从资产系统加载，哈希: $hash (${imageData.length} bytes)');
        } else {
          debugPrint('警告：无法从资产系统加载图层背景图，哈希: $hash');
        }
      }

      // 解析图片适应方式
      BoxFit? imageFit;
      if (configJson['imageFit'] != null) {
        final fitString = configJson['imageFit'] as String;
        try {
          imageFit = BoxFit.values.firstWhere((fit) => fit.name == fitString);
        } catch (e) {
          imageFit = BoxFit.contain; // 默认值
        }
      }

      return MapLayer(
        id: configJson['id'] as String,
        name: configJson['name'] as String,
        order: configJson['order'] as int,
        opacity: (configJson['opacity'] as num).toDouble(),
        isVisible: configJson['isVisible'] as bool,
        imageData: imageData, // 设置加载的背景图片数据
        imageFit: imageFit,
        xOffset: (configJson['xOffset'] as num?)?.toDouble() ?? 0.0,
        yOffset: (configJson['yOffset'] as num?)?.toDouble() ?? 0.0,
        imageScale: (configJson['imageScale'] as num?)?.toDouble() ?? 1.0,
        legendGroupIds: List<String>.from(configJson['legendGroupIds'] ?? []),
        tags: configJson['tags'] != null
            ? List<String>.from(configJson['tags'] as List)
            : null,
        elements: elements,
        createdAt: DateTime.parse(configJson['createdAt'] as String),
        updatedAt: DateTime.parse(configJson['updatedAt'] as String),
        isLinkedToNext: configJson['isLinkedToNext'] as bool? ?? false,
      );
    } catch (e) {
      debugPrint('加载图层失败 [$mapTitle/$layerId:$version]: $e');
      return null;
    }
  }

  @override
  Future<void> saveLayer(
    String mapTitle,
    MapLayer layer, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      // 保存图层配置，包括背景图片数据处理
      final Map<String, dynamic> configData = {
        'id': layer.id,
        'name': layer.name,
        'order': layer.order,
        'opacity': layer.opacity,
        'isVisible': layer.isVisible,
        'legendGroupIds': layer.legendGroupIds,
        'createdAt': layer.createdAt.toIso8601String(),
        'updatedAt': layer.updatedAt.toIso8601String(),
      };

      // 如果图层有背景图片数据，保存到资产目录并记录引用
      if (layer.imageData != null && layer.imageData!.isNotEmpty) {
        final hash = await saveAsset(
          mapTitle,
          layer.imageData!,
          'image/png',
          folderPath,
        );
        configData['imageData'] = {
          'path': 'assets/$hash.png',
          'hash': hash,
          'originalName': 'layer_background.png',
          'size': layer.imageData!.length,
          'mimeType': 'image/png',
        };
        debugPrint(
          '图层背景图已保存到资产系统，哈希: $hash (${layer.imageData!.length} bytes)',
        );
      }

      // 添加其他图层属性
      if (layer.imageFit != null) {
        configData['imageFit'] = layer.imageFit!.name;
      }
      configData['xOffset'] = layer.xOffset;
      configData['yOffset'] = layer.yOffset;
      configData['imageScale'] = layer.imageScale;
      configData['isLinkedToNext'] = layer.isLinkedToNext;
      if (layer.tags != null) {
        configData['tags'] = layer.tags;
      }

      final configPath = _buildVfsPath(
        _getLayerConfigPath(mapTitle, layer.id, version, folderPath),
      );
      final configJson = jsonEncode(configData);
      await _storageService.writeFile(configPath, utf8.encode(configJson));

      // 保存绘制元素
      for (final element in layer.elements) {
        await saveElement(mapTitle, layer.id, element, version, folderPath);
      }

      // 清除缓存
      final cacheKey = folderPath == null
          ? '$mapTitle:$version'
          : '$folderPath/$mapTitle:$version';
      _layerCache.remove(cacheKey);
    } catch (e) {
      debugPrint('保存图层失败 [$mapTitle/${layer.id}:$version]: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteLayer(
    String mapTitle,
    String layerId, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      final layerPath = _buildVfsPath(
        _getLayerPath(mapTitle, layerId, version, folderPath),
      );
      await _storageService.delete(layerPath);

      // 清除缓存
      final cacheKey = folderPath == null
          ? '$mapTitle:$version'
          : '$folderPath/$mapTitle:$version';
      _layerCache.remove(cacheKey);
    } catch (e) {
      debugPrint('删除图层失败 [$mapTitle/$layerId:$version]: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateLayerOrder(
    String mapTitle,
    List<String> layerIds, [
    String version = 'default',
    String? folderPath,
  ]) async {
    // 重新排序图层
    for (int i = 0; i < layerIds.length; i++) {
      final layer = await getLayerById(
        mapTitle,
        layerIds[i],
        version,
        folderPath,
      );
      if (layer != null) {
        final updatedLayer = layer.copyWith(order: i);
        await saveLayer(mapTitle, updatedLayer, version, folderPath);
      }
    }
  }

  @override
  Future<List<MapDrawingElement>> getLayerElements(
    String mapTitle,
    String layerId, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      final elementsPath = _buildVfsPath(
        _getElementsPath(mapTitle, layerId, version, folderPath),
      );
      final files = await _storageService.listDirectory(elementsPath);
      final elements = <MapDrawingElement>[];

      for (final file in files) {
        if (file.name.endsWith('.json')) {
          final elementId = file.name.replaceAll('.json', '');
          final element = await getElementById(
            mapTitle,
            layerId,
            elementId,
            version,
            folderPath,
          );
          if (element != null) {
            elements.add(element);
          }
        }
      }

      return elements;
    } catch (e) {
      debugPrint('加载绘制元素失败 [$mapTitle/$layerId:$version]: $e');
      return [];
    }
  }

  @override
  Future<MapDrawingElement?> getElementById(
    String mapTitle,
    String layerId,
    String elementId, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      final elementPath = _buildVfsPath(
        _getElementPath(mapTitle, layerId, elementId, version, folderPath),
      );
      final elementData = await _storageService.readFile(elementPath);

      if (elementData == null) {
        return null;
      }

      final elementJson =
          jsonDecode(utf8.decode(elementData.data)) as Map<String, dynamic>;

      // 从JSON加载元素
      MapDrawingElement element = MapDrawingElement.fromJson(elementJson);

      // 如果元素有图像哈希引用，从资产系统加载图片数据
      if (element.imageHash != null && element.imageHash!.isNotEmpty) {
        final imageData = await getAsset(
          mapTitle,
          element.imageHash!,
          folderPath,
        );
        if (imageData != null) {
          // 将资产数据恢复到元素的imageData字段
          element = element.copyWith(imageData: imageData);
          debugPrint(
            '已从资产系统加载图像数据，哈希: ${element.imageHash} (${imageData.length} bytes)',
          );
        } else {
          debugPrint('警告：无法从资产系统加载图像，哈希: ${element.imageHash}');
        }
      }

      return element;
    } catch (e) {
      debugPrint('加载绘制元素失败 [$mapTitle/$layerId/$elementId:$version]: $e');
      return null;
    }
  }

  @override
  Future<void> saveElement(
    String mapTitle,
    String layerId,
    MapDrawingElement element, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      // 创建用于保存的元素副本
      MapDrawingElement elementToSave = element;

      // 如果元素包含图像数据，保存到资产系统并使用哈希引用
      if (element.imageData != null && element.imageData!.isNotEmpty) {
        // 保存图像到资产系统并获取哈希
        final hash = await saveAsset(
          mapTitle,
          element.imageData!,
          'image/png',
          folderPath,
        );
        debugPrint(
          '图像已保存到地图资产系统，哈希: $hash (${element.imageData!.length} bytes)',
        );

        // 创建使用哈希引用而不是直接数据的元素
        elementToSave = element.copyWith(
          imageHash: hash,
          clearImageData: true, // 清除直接图像数据
        );
      }

      // 保存修改后的元素JSON（包含哈希引用而非直接数据）
      final elementPath = _buildVfsPath(
        _getElementPath(mapTitle, layerId, element.id, version, folderPath),
      );
      final elementJson = jsonEncode(elementToSave.toJson());
      await _storageService.writeFile(elementPath, utf8.encode(elementJson));
    } catch (e) {
      debugPrint('保存绘制元素失败 [$mapTitle/$layerId/${element.id}:$version]: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteElement(
    String mapTitle,
    String layerId,
    String elementId, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      final elementPath = _buildVfsPath(
        _getElementPath(mapTitle, layerId, elementId, version, folderPath),
      );
      await _storageService.delete(elementPath);
    } catch (e) {
      debugPrint('删除绘制元素失败 [$mapTitle/$layerId/$elementId:$version]: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateElementsOrder(
    String mapTitle,
    String layerId,
    List<String> elementIds, [
    String version = 'default',
    String? folderPath,
  ]) async {
    // 重新排序绘制元素
    for (int i = 0; i < elementIds.length; i++) {
      final element = await getElementById(
        mapTitle,
        layerId,
        elementIds[i],
        version,
        folderPath,
      );
      if (element != null) {
        // MapDrawingElement copyWith 方法中没有order 参数，这里直接保存
        await saveElement(mapTitle, layerId, element, version, folderPath);
      }
    }
  }

  @override
  Future<List<LegendGroup>> getMapLegendGroups(
    String mapTitle, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      final legendsPath = _buildVfsPath(
        _getLegendsPath(mapTitle, version, folderPath),
      );
      final files = await _storageService.listDirectory(legendsPath);
      final groups = <LegendGroup>[];

      for (final file in files) {
        if (file.isDirectory) {
          final group = await getLegendGroupById(
            mapTitle,
            file.name,
            version,
            folderPath,
          );
          if (group != null) {
            groups.add(group);
          }
        }
      }

      return groups;
    } catch (e) {
      debugPrint('加载图例组失败[$mapTitle:$version]: $e');
      return [];
    }
  }

  @override
  Future<LegendGroup?> getLegendGroupById(
    String mapTitle,
    String groupId, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      final configPath = _buildVfsPath(
        _getLegendGroupConfigPath(mapTitle, groupId, version, folderPath),
      );
      final configData = await _storageService.readFile(configPath);

      if (configData == null) {
        return null;
      }

      final configJson =
          jsonDecode(utf8.decode(configData.data)) as Map<String, dynamic>;

      // 加载图例项
      final items = await getLegendGroupItems(
        mapTitle,
        groupId,
        version,
        folderPath,
      );
      return LegendGroup(
        id: configJson['id'] as String,
        name: configJson['name'] as String,
        isVisible: configJson['isVisible'] as bool? ?? true,
        opacity: (configJson['opacity'] as num?)?.toDouble() ?? 1.0,
        legendItems: items,
        tags: configJson['tags'] != null
            ? List<String>.from(configJson['tags'] as List)
            : null,
        createdAt: DateTime.parse(configJson['createdAt'] as String),
        updatedAt: DateTime.parse(configJson['updatedAt'] as String),
      );
    } catch (e) {
      debugPrint('加载图例组失败[$mapTitle/$groupId:$version]: $e');
      return null;
    }
  }

  @override
  Future<void> saveLegendGroup(
    String mapTitle,
    LegendGroup group, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      // 保存图例组配置
      final Map<String, dynamic> configData = {
        'id': group.id,
        'name': group.name,
        'isVisible': group.isVisible,
        'opacity': group.opacity,
        'createdAt': group.createdAt.toIso8601String(),
        'updatedAt': group.updatedAt.toIso8601String(),
      };

      if (group.tags != null) {
        configData['tags'] = group.tags;
      }

      final configPath = _buildVfsPath(
        _getLegendGroupConfigPath(mapTitle, group.id, version, folderPath),
      );
      final configJson = jsonEncode(configData);
      await _storageService.writeFile(configPath, utf8.encode(configJson));

      // 保存图例项
      for (final item in group.legendItems) {
        await saveLegendItem(mapTitle, group.id, item, version, folderPath);
      }
    } catch (e) {
      debugPrint('保存图例组失败[$mapTitle/${group.id}:$version]: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteLegendGroup(
    String mapTitle,
    String groupId, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      final groupPath = _buildVfsPath(
        _getLegendGroupPath(mapTitle, groupId, version, folderPath),
      );
      await _storageService.delete(groupPath);
    } catch (e) {
      debugPrint('删除图例组失败[$mapTitle/$groupId:$version]: $e');
      rethrow;
    }
  }

  @override
  Future<List<LegendItem>> getLegendGroupItems(
    String mapTitle,
    String groupId, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      debugPrint(
        '开始加载图例组项: mapTitle=$mapTitle, groupId=$groupId, version=$version, folderPath=$folderPath',
      );

      final itemsPath = _buildVfsPath(
        _getLegendItemsPath(mapTitle, groupId, version, folderPath),
      );
      debugPrint('图例项路径: $itemsPath');

      final files = await _storageService.listDirectory(itemsPath);
      debugPrint(
        '找到 ${files.length} 个文件: ${files.map((f) => f.name).join(', ')}',
      );

      final items = <LegendItem>[];

      for (final file in files) {
        if (file.name.endsWith('.json')) {
          final itemId = file.name.replaceAll('.json', '');
          debugPrint('正在加载图例项: $itemId');

          try {
            final item = await getLegendItemById(
              mapTitle,
              groupId,
              itemId,
              version,
              folderPath,
            );
            if (item != null) {
              debugPrint(
                '成功加载图例项: $itemId, legendPath=${item.legendPath}, legendId=${item.legendId}',
              );
              items.add(item);
            } else {
              debugPrint('图例项加载失败: $itemId (返回null)');
            }
          } catch (itemError) {
            debugPrint(
              '加载图例项失败[$mapTitle/$groupId/$itemId:$version]: $itemError',
            );
          }
        } else {
          debugPrint('跳过非JSON文件: ${file.name}');
        }
      }

      debugPrint('图例组项加载完成: 共 ${items.length} 个项目');
      return items;
    } catch (e) {
      debugPrint('加载图例项失败[$mapTitle/$groupId:$version]: $e');
      return [];
    }
  }

  @override
  Future<LegendItem?> getLegendItemById(
    String mapTitle,
    String groupId,
    String itemId, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      debugPrint(
        '开始加载图例项: mapTitle=$mapTitle, groupId=$groupId, itemId=$itemId, version=$version, folderPath=$folderPath',
      );

      final itemPath = _buildVfsPath(
        _getLegendItemPath(mapTitle, groupId, itemId, version, folderPath),
      );
      debugPrint('图例项文件路径: $itemPath');

      final itemData = await _storageService.readFile(itemPath);

      if (itemData == null) {
        debugPrint('图例项文件不存在: $itemPath');
        return null;
      }

      debugPrint('图例项JSON数据大小: ${itemData.data.length} bytes');
      final itemJson =
          jsonDecode(utf8.decode(itemData.data)) as Map<String, dynamic>;
      debugPrint('图例项JSON内容: $itemJson');

      final item = LegendItem.fromJson(itemJson);
      debugPrint(
        '成功解析图例项: id=${item.id}, legendPath=${item.legendPath}, legendId=${item.legendId}',
      );

      return item;
    } catch (e) {
      debugPrint('加载图例项失败[$mapTitle/$groupId/$itemId:$version]: $e');
      return null;
    }
  }

  @override
  Future<void> saveLegendItem(
    String mapTitle,
    String groupId,
    LegendItem item, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      final itemPath = _buildVfsPath(
        _getLegendItemPath(
          mapTitle,
          groupId,
          item.id.toString(),
          version,
          folderPath,
        ),
      );
      final itemJson = jsonEncode(item.toJson());
      await _storageService.writeFile(itemPath, utf8.encode(itemJson));
    } catch (e) {
      debugPrint('保存图例项失败[$mapTitle/$groupId/${item.id}:$version]: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteLegendItem(
    String mapTitle,
    String groupId,
    String itemId, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      final itemPath = _buildVfsPath(
        _getLegendItemPath(mapTitle, groupId, itemId, version, folderPath),
      );
      await _storageService.delete(itemPath);
    } catch (e) {
      debugPrint('删除图例项失败[$mapTitle/$groupId/$itemId:$version]: $e');
      rethrow;
    }
  }

  /// 获取地图的所有便签数据
  Future<List<StickyNote>> getMapStickyNotes(
    String mapTitle, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      final notesPath = _buildVfsPath(
        _getNotesPath(mapTitle, version, folderPath),
      );
      final files = await _storageService.listDirectory(notesPath);

      final stickyNotes = <StickyNote>[];
      for (final file in files) {
        if (file.name.endsWith('.json') && !file.isDirectory) {
          final noteData = await _storageService.readFile(file.path);
          if (noteData != null) {
            try {
              final noteJson =
                  jsonDecode(utf8.decode(noteData.data))
                      as Map<String, dynamic>;
              StickyNote stickyNote = StickyNote.fromJson(noteJson);

              // 1. 处理便签背景图片的图片资产恢复
              if (stickyNote.backgroundImageHash != null &&
                  stickyNote.backgroundImageHash!.isNotEmpty) {
                final imageData = await getAsset(
                  mapTitle,
                  stickyNote.backgroundImageHash!,
                  folderPath,
                );
                if (imageData != null) {
                  // 将资产数据恢复到便签的backgroundImageData字段
                  stickyNote = stickyNote.copyWith(
                    backgroundImageData: imageData,
                  );
                  debugPrint(
                    '便签背景图片已从资产系统加载，哈希: ${stickyNote.backgroundImageHash} (${imageData.length} bytes)',
                  );
                } else {
                  debugPrint(
                    '警告：无法从资产系统加载便签背景图片，哈希: ${stickyNote.backgroundImageHash}',
                  );
                }
              }

              // 2. 处理便签中绘画元素的图片资产恢复
              if (stickyNote.elements.isNotEmpty) {
                final updatedElements = <MapDrawingElement>[];

                for (final element in stickyNote.elements) {
                  MapDrawingElement restoredElement = element;

                  // 如果元素有图像哈希引用，从资产系统加载图片数据
                  if (element.imageHash != null &&
                      element.imageHash!.isNotEmpty) {
                    final imageData = await getAsset(
                      mapTitle,
                      element.imageHash!,
                      folderPath,
                    );
                    if (imageData != null) {
                      // 将资产数据恢复到元素的imageData字段
                      restoredElement = element.copyWith(imageData: imageData);
                      debugPrint(
                        '便签绘画元素图像已从资产系统加载，哈希: ${element.imageHash} (${imageData.length} bytes)',
                      );
                    } else {
                      debugPrint(
                        '警告：无法从资产系统加载便签绘画元素图像，哈希: ${element.imageHash}',
                      );
                    }
                  }

                  updatedElements.add(restoredElement);
                }

                // 创建包含恢复后元素的便签副本
                stickyNote = stickyNote.copyWith(elements: updatedElements);
              }

              stickyNotes.add(stickyNote);
            } catch (e) {
              debugPrint('解析便签数据失败 [${file.path}]: $e');
            }
          }
        }
      }

      // 按创建时间排序
      stickyNotes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return stickyNotes;
    } catch (e) {
      debugPrint('加载便签数据失败 [$mapTitle:$version]: $e');
      return [];
    }
  }

  /// 保存便签数据
  Future<void> saveStickyNote(
    String mapTitle,
    StickyNote stickyNote, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      // 处理便签背景图片和绘画元素的图片资产
      StickyNote stickyNoteToSave = stickyNote;

      // 1. 处理便签背景图片 - 参考图层背景的保存方式
      if (stickyNote.backgroundImageData != null &&
          stickyNote.backgroundImageData!.isNotEmpty) {
        // 保存背景图片到资产系统并获取哈希（与图层背景保存方式一致）
        final hash = await saveAsset(
          mapTitle,
          stickyNote.backgroundImageData!,
          'image/png',
          folderPath,
        );
        debugPrint(
          '便签背景图片已保存到资产系统，哈希: $hash (${stickyNote.backgroundImageData!.length} bytes)',
        );

        // 创建用于磁盘存储的便签副本（使用哈希引用，清除直接数据以节省空间）
        stickyNoteToSave = stickyNote.copyWith(
          backgroundImageHash: hash,
          clearBackgroundImageData: true, // 磁盘存储时清除直接图像数据
        );
      }

      // 2. 处理便签中绘画元素的图片资产
      if (stickyNoteToSave.elements.isNotEmpty) {
        final updatedElements = <MapDrawingElement>[];

        for (final element in stickyNoteToSave.elements) {
          MapDrawingElement elementToSave = element;

          // 如果元素包含图像数据，保存到资产系统并使用哈希引用
          if (element.imageData != null && element.imageData!.isNotEmpty) {
            // 保存图像到资产系统并获取哈希
            final hash = await saveAsset(
              mapTitle,
              element.imageData!,
              'image/png',
              folderPath,
            );
            debugPrint(
              '便签绘画元素图像已保存到资产系统，哈希: $hash (${element.imageData!.length} bytes)',
            );

            // 创建使用哈希引用而不是直接数据的元素（用于磁盘存储）
            elementToSave = element.copyWith(
              imageHash: hash,
              clearImageData: true, // 磁盘存储时清除直接图像数据
            );
          }

          updatedElements.add(elementToSave);
        }

        // 创建包含处理后元素的便签副本
        stickyNoteToSave = stickyNoteToSave.copyWith(elements: updatedElements);
      }

      final stickyNotePath = _buildVfsPath(
        _getStickyNotePath(mapTitle, stickyNote.id, version, folderPath),
      );
      final stickyNoteJson = jsonEncode(stickyNoteToSave.toJson());
      await _storageService.writeFile(
        stickyNotePath,
        utf8.encode(stickyNoteJson),
      );
      debugPrint('便签数据已保存 [$mapTitle/${stickyNote.id}:$version]');
    } catch (e) {
      debugPrint('保存便签数据失败 [$mapTitle/${stickyNote.id}:$version]: $e');
      rethrow;
    }
  }

  /// 删除便签数据
  Future<void> deleteStickyNote(
    String mapTitle,
    String stickyNoteId, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      final stickyNotePath = _buildVfsPath(
        _getStickyNotePath(mapTitle, stickyNoteId, version, folderPath),
      );
      await _storageService.delete(stickyNotePath);
      debugPrint('便签数据已删除 [$mapTitle/$stickyNoteId:$version]');
    } catch (e) {
      debugPrint('删除便签数据失败 [$mapTitle/$stickyNoteId:$version]: $e');
      rethrow;
    }
  }

  /// 获取指定便签数据
  @override
  Future<StickyNote?> getStickyNoteById(
    String mapTitle,
    String stickyNoteId, [
    String version = 'default',
    String? folderPath,
  ]) async {
    try {
      final stickyNotePath = _buildVfsPath(
        _getStickyNotePath(mapTitle, stickyNoteId, version, folderPath),
      );
      final noteData = await _storageService.readFile(stickyNotePath);

      if (noteData == null) {
        return null;
      }
      final noteJson =
          jsonDecode(utf8.decode(noteData.data)) as Map<String, dynamic>;
      StickyNote stickyNote = StickyNote.fromJson(noteJson);

      // 1. 处理便签背景图片的图片资产恢复
      if (stickyNote.backgroundImageHash != null &&
          stickyNote.backgroundImageHash!.isNotEmpty) {
        final imageData = await getAsset(
          mapTitle,
          stickyNote.backgroundImageHash!,
          folderPath,
        );
        if (imageData != null) {
          // 将资产数据恢复到便签的backgroundImageData字段
          stickyNote = stickyNote.copyWith(backgroundImageData: imageData);
          debugPrint(
            '便签背景图片已从资产系统加载，哈希: ${stickyNote.backgroundImageHash} (${imageData.length} bytes)',
          );
        } else {
          debugPrint(
            '警告：无法从资产系统加载便签背景图片，哈希: ${stickyNote.backgroundImageHash}',
          );
        }
      }

      // 2. 处理便签中绘画元素的图片资产恢复
      if (stickyNote.elements.isNotEmpty) {
        final updatedElements = <MapDrawingElement>[];

        for (final element in stickyNote.elements) {
          MapDrawingElement restoredElement = element;

          // 如果元素有图像哈希引用，从资产系统加载图片数据
          if (element.imageHash != null && element.imageHash!.isNotEmpty) {
            final imageData = await getAsset(
              mapTitle,
              element.imageHash!,
              folderPath,
            );
            if (imageData != null) {
              // 将资产数据恢复到元素的imageData字段
              restoredElement = element.copyWith(imageData: imageData);
              debugPrint(
                '便签绘画元素图像已从资产系统加载，哈希: ${element.imageHash} (${imageData.length} bytes)',
              );
            } else {
              debugPrint('警告：无法从资产系统加载便签绘画元素图像，哈希: ${element.imageHash}');
            }
          }

          updatedElements.add(restoredElement);
        }

        // 创建包含恢复后元素的便签副本
        stickyNote = stickyNote.copyWith(elements: updatedElements);
      }

      return stickyNote;
    } catch (e) {
      debugPrint('加载便签数据失败 [$mapTitle/$stickyNoteId:$version]: $e');
      return null;
    }
  }

  // 版本管理方法
  @override
  Future<List<String>> getMapVersions(
    String mapTitle, [
    String? folderPath,
  ]) async {
    try {
      final dataPath = _buildVfsPath(
        '${_getMapPath(mapTitle, folderPath)}/data',
      );
      final files = await _storageService.listDirectory(dataPath);
      final versions = <String>[];

      for (final file in files) {
        if (file.isDirectory) {
          versions.add(file.name);
        }
      }

      return versions;
    } catch (e) {
      debugPrint('获取地图版本失败 [$mapTitle]: $e');
      return [];
    }
  }

  @override
  Future<void> createMapVersion(
    String mapTitle,
    String version, [
    String? sourceVersion,
    String? folderPath,
  ]) async {
    try {
      if (await mapVersionExists(mapTitle, version, folderPath)) {
        throw Exception('版本已存在: $version');
      }
      // 如果 sourceVersion 为 null，创建空的版本目录
      if (sourceVersion == null) {
        final versionPath = _buildVfsPath(
          '${_getMapPath(mapTitle, folderPath)}/data/$version',
        );
        await _storageService.createDirectory(versionPath);
        debugPrint('创建空版本目录: $version');
      } else {
        // 否则从指定源版本复制数据
        await copyVersionData(mapTitle, sourceVersion, version, folderPath);
        debugPrint('从版本 $sourceVersion 复制数据到版本 $version');
      }
    } catch (e) {
      debugPrint('创建地图版本失败 [$mapTitle:$version]: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteMapVersion(
    String mapTitle,
    String version, [
    String? folderPath,
  ]) async {
    try {
      if (version == 'default') {
        throw Exception('无法删除默认版本');
      }

      final versionPath = _buildVfsPath(
        '${_getMapPath(mapTitle, folderPath)}/data/$version',
      );
      await _storageService.delete(versionPath, recursive: true);
    } catch (e) {
      debugPrint('删除地图版本失败 [$mapTitle:$version]: $e');
      rethrow;
    }
  }

  @override
  Future<bool> mapVersionExists(
    String mapTitle,
    String version, [
    String? folderPath,
  ]) async {
    try {
      final versionPath = _buildVfsPath(
        '${_getMapPath(mapTitle, folderPath)}/data/$version',
      );
      return await _storageService.exists(versionPath);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> copyVersionData(
    String mapTitle,
    String sourceVersion,
    String targetVersion, [
    String? folderPath,
  ]) async {
    try {
      final sourcePath = _buildVfsPath(
        '${_getMapPath(mapTitle, folderPath)}/data/$sourceVersion',
      );
      final targetPath = _buildVfsPath(
        '${_getMapPath(mapTitle, folderPath)}/data/$targetVersion',
      );

      // 递归复制整个版本目录
      await _copyDirectory(sourcePath, targetPath);
    } catch (e) {
      debugPrint('复制版本数据失败 [$mapTitle:$sourceVersion->$targetVersion]: $e');
      rethrow;
    }
  }

  // 版本元数据管理实现
  @override
  Future<void> saveVersionMetadata(
    String mapTitle,
    String versionId,
    String versionName, {
    DateTime? createdAt,
    DateTime? updatedAt,
    String? folderPath,
  }) async {
    try {
      final metadataPath = _buildVfsPath(
        '${_getMapPath(mapTitle, folderPath)}/versions_metadata.json',
      );

      // 读取现有元数据
      Map<String, dynamic> metadata = {};
      try {
        final existingData = await _storageService.readFile(metadataPath);
        if (existingData != null) {
          metadata =
              jsonDecode(utf8.decode(existingData.data))
                  as Map<String, dynamic>;
        }
      } catch (e) {
        // 文件不存在或解析失败，使用空元数据
        debugPrint('读取版本元数据失败，将创建新文件: $e');
      }

      final now = DateTime.now();
      metadata[versionId] = {
        'name': versionName,
        'createdAt': (createdAt ?? now).toIso8601String(),
        'updatedAt': (updatedAt ?? now).toIso8601String(),
      };

      // 保存更新后的元数据
      final metadataJson = jsonEncode(metadata);
      await _storageService.writeFile(metadataPath, utf8.encode(metadataJson));

      debugPrint('保存版本元数据成功 [$mapTitle:$versionId -> $versionName]');
    } catch (e) {
      debugPrint('保存版本元数据失败 [$mapTitle:$versionId]: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getVersionName(
    String mapTitle,
    String versionId, [
    String? folderPath,
  ]) async {
    try {
      final metadataPath = _buildVfsPath(
        '${_getMapPath(mapTitle, folderPath)}/versions_metadata.json',
      );
      final data = await _storageService.readFile(metadataPath);

      if (data == null) return null;

      final metadata =
          jsonDecode(utf8.decode(data.data)) as Map<String, dynamic>;
      final versionInfo = metadata[versionId] as Map<String, dynamic>?;

      return versionInfo?['name'] as String?;
    } catch (e) {
      debugPrint('获取版本名称失败 [$mapTitle:$versionId]: $e');
      return null;
    }
  }

  @override
  Future<Map<String, String>> getAllVersionNames(
    String mapTitle, [
    String? folderPath,
  ]) async {
    try {
      final metadataPath = _buildVfsPath(
        '${_getMapPath(mapTitle, folderPath)}/versions_metadata.json',
      );
      final data = await _storageService.readFile(metadataPath);

      if (data == null) return {};

      final metadata =
          jsonDecode(utf8.decode(data.data)) as Map<String, dynamic>;
      final versionNames = <String, String>{};

      for (final entry in metadata.entries) {
        final versionInfo = entry.value as Map<String, dynamic>;
        versionNames[entry.key] = versionInfo['name'] as String;
      }

      return versionNames;
    } catch (e) {
      debugPrint('获取所有版本名称失败 [$mapTitle]: $e');
      return {};
    }
  }

  @override
  Future<void> deleteVersionMetadata(
    String mapTitle,
    String versionId, [
    String? folderPath,
  ]) async {
    try {
      final metadataPath = _buildVfsPath(
        '${_getMapPath(mapTitle, folderPath)}/versions_metadata.json',
      );
      final data = await _storageService.readFile(metadataPath);

      if (data == null) return;

      final metadata =
          jsonDecode(utf8.decode(data.data)) as Map<String, dynamic>;
      metadata.remove(versionId);

      // 保存更新后的元数据
      final metadataJson = jsonEncode(metadata);
      await _storageService.writeFile(metadataPath, utf8.encode(metadataJson));

      debugPrint('删除版本元数据成功 [$mapTitle:$versionId]');
    } catch (e) {
      debugPrint('删除版本元数据失败 [$mapTitle:$versionId]: $e');
      rethrow;
    }
  }

  @override
  Future<Uint8List?> getAsset(
    String mapTitle,
    String hash, [
    String? folderPath,
  ]) async {
    try {
      // 从指定地图的资产目录查找
      final assetPath = _buildVfsPath(
        _getAssetPath(mapTitle, '$hash.png', folderPath),
      );
      VfsFileContent? fileContent = await _storageService.readFile(assetPath);

      if (fileContent == null) {
        // 尝试其他扩展名
        for (final ext in ['.jpg', '.svg', '']) {
          final path = _buildVfsPath(
            _getAssetPath(mapTitle, '$hash$ext', folderPath),
          );
          fileContent = await _storageService.readFile(path);
          if (fileContent != null) break;
        }
      }

      return fileContent?.data;
    } catch (e) {
      debugPrint('获取资产失败 [$mapTitle/$hash]: $e');
      return null;
    }
  }

  @override
  Future<void> deleteAsset(
    String mapTitle,
    String hash, [
    String? folderPath,
  ]) async {
    try {
      // 从指定地图的资产目录删除
      for (final ext in ['.png', '.jpg', '.svg', '']) {
        try {
          final path = _buildVfsPath(
            _getAssetPath(mapTitle, '$hash$ext', folderPath),
          );
          await _storageService.delete(path);
        } catch (e) {
          // 忽略文件不存在的错误
        }
      }

      _assetHashIndex.remove(hash);
    } catch (e) {
      debugPrint('删除资产失败 [$mapTitle/$hash]: $e');
      rethrow;
    }
  }

  @override
  Future<void> cleanupUnusedAssets(
    String mapTitle, [
    String? folderPath,
  ]) async {
    // TODO: 实现未使用资产清理逻辑
    // 需要扫描地图中所有引用的资产哈希，删除未被引用的资产
  }

  @override
  Future<Map<String, int>> getAssetUsageStats(
    String mapTitle, [
    String? folderPath,
  ]) async {
    // TODO: 实现资产使用统计
    return {};
  }

  @override
  Future<Map<String, String>> getMapLocalizations(
    String mapTitle, [
    String? folderPath,
  ]) async {
    try {
      final localizationPath = _buildVfsPath(
        _getMapLocalizationPath(mapTitle, folderPath),
      );
      final localizationData = await _storageService.readFile(localizationPath);

      if (localizationData == null) {
        return {};
      }

      final localizationJson =
          jsonDecode(utf8.decode(localizationData.data))
              as Map<String, dynamic>;
      return Map<String, String>.from(localizationJson);
    } catch (e) {
      debugPrint('获取地图本地化失败[$mapTitle]: $e');
      return {};
    }
  }

  @override
  Future<void> saveMapLocalizations(
    String mapTitle,
    Map<String, String> localizations, [
    String? folderPath,
  ]) async {
    try {
      final localizationPath = _buildVfsPath(
        _getMapLocalizationPath(mapTitle, folderPath),
      );
      final localizationJson = jsonEncode(localizations);
      await _storageService.writeFile(
        localizationPath,
        utf8.encode(localizationJson),
      );
    } catch (e) {
      debugPrint('保存地图本地化失败[$mapTitle]: $e');
      rethrow;
    }
  }

  @override
  Future<bool> mapExists(String id, [String? folderPath]) async {
    try {
      final metaPath = _buildVfsPath(_getMapMetaPath(id, folderPath));
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

  /// 递归复制目录及其所有内容
  Future<void> _copyDirectory(String sourcePath, String targetPath) async {
    try {
      // 检查源目录是否存在
      final sourceExists = await _storageService.exists(sourcePath);
      if (!sourceExists) {
        debugPrint('源目录不存在: $sourcePath');
        return;
      }

      // 创建目标目录
      await _storageService.createDirectory(targetPath);

      // 列出源目录中的所有内容
      final items = await _storageService.listDirectory(sourcePath);

      for (final item in items) {
        final itemSourcePath = '$sourcePath/${item.name}';
        final itemTargetPath = '$targetPath/${item.name}';

        if (item.isDirectory) {
          // 递归复制子目录
          await _copyDirectory(itemSourcePath, itemTargetPath);
        } else {
          // 复制文件
          await _storageService.copy(itemSourcePath, itemTargetPath);
        }
      }

      debugPrint('目录复制完成: $sourcePath -> $targetPath');
    } catch (e) {
      debugPrint('复制目录失败 [$sourcePath -> $targetPath]: $e');
      rethrow;
    }
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

  // 目录操作方法
  @override
  Future<List<String>> getFolders([String? parentPath]) async {
    try {
      final basePath = parentPath == null || parentPath.isEmpty
          ? ''
          : parentPath.replaceAll(RegExp(r'^/+|/+$'), '') + '/';

      final files = await _storageService.listDirectory(
        _buildVfsPath(basePath),
      );
      final folders = <String>[];

      for (final file in files) {
        if (file.isDirectory && !file.name.endsWith('.mapdata')) {
          folders.add(file.name);
        }
      }

      return folders;
    } catch (e) {
      debugPrint('获取文件夹列表失败: $e');
      return [];
    }
  }

  @override
  Future<void> createFolder(String folderPath) async {
    try {
      final cleanPath = folderPath.replaceAll(RegExp(r'^/+|/+$'), '');
      final vfsPath = _buildVfsPath(cleanPath);

      // 确保文件夹存在（VFS会自动创建父目录）
      await _storageService.writeFile('$vfsPath/.keep', utf8.encode(''));
    } catch (e) {
      debugPrint('创建文件夹失败 [$folderPath]: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteFolder(String folderPath) async {
    try {
      final cleanPath = folderPath.replaceAll(RegExp(r'^/+|/+$'), '');
      final vfsPath = _buildVfsPath(cleanPath);

      await _storageService.delete(vfsPath, recursive: true);
    } catch (e) {
      debugPrint('删除文件夹失败 [$folderPath]: $e');
      rethrow;
    }
  }

  @override
  Future<void> renameFolder(String oldPath, String newPath) async {
    try {
      final oldCleanPath = oldPath.replaceAll(RegExp(r'^/+|/+$'), '');
      final newCleanPath = newPath.replaceAll(RegExp(r'^/+|/+$'), '');
      final oldVfsPath = _buildVfsPath(oldCleanPath);
      final newVfsPath = _buildVfsPath(newCleanPath);

      // 检查旧路径是否存在
      final oldExists = await _storageService.exists(oldVfsPath);
      if (!oldExists) {
        throw Exception('源文件夹不存在: $oldPath');
      }

      // 检查新路径是否已存在
      final newExists = await _storageService.exists(newVfsPath);
      if (newExists) {
        throw Exception('目标文件夹已存在: $newPath');
      }

      // 使用VFS的move方法重命名文件夹
      await _storageService.move(oldVfsPath, newVfsPath);
      
      debugPrint('文件夹重命名成功: $oldPath -> $newPath');
    } catch (e) {
      debugPrint('重命名文件夹失败 [$oldPath -> $newPath]: $e');
      rethrow;
    }
  }

  @override
  Future<void> moveMap(
    String mapTitle,
    String? fromFolder,
    String? toFolder,
  ) async {
    try {
      // 1. 从原位置加载地图
      final map = await getMapByTitle(mapTitle, fromFolder);
      if (map == null) {
        throw Exception('找不到地图: $mapTitle');
      }

      // 2. 保存到新位置
      await saveMap(map, toFolder);

      // 3. 删除原位置的地图
      await deleteMap(mapTitle, fromFolder);
    } catch (e) {
      debugPrint('移动地图失败 [$mapTitle]: $e');
      rethrow;
    }
  }

  @override
  Future<String> saveAsset(
    String mapTitle,
    Uint8List data,
    String? mimeType, [
    String? folderPath,
  ]) async {
    try {
      // 计算SHA-256哈希
      final hash = sha256.convert(data).toString();

      // 确定文件扩展名
      String extension = '';
      if (mimeType != null) {
        switch (mimeType.toLowerCase()) {
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
      final assetPath = _buildVfsPath(
        _getAssetPath(mapTitle, filename, folderPath),
      );

      // 检查相同哈希的文件是否已在此地图中存在，如果存在则无需重复保存
      final existingData = await _storageService.readFile(assetPath);
      if (existingData == null) {
        // 保存新资产文件
        await _storageService.writeFile(assetPath, data);
        debugPrint('保存新图像资产到地图 [$mapTitle]: $filename (${data.length} bytes)');
      } else {
        debugPrint('图像资产已在地图 [$mapTitle] 中存在，跳过保存: $filename');
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
  Future<void> renameMap(String oldTitle, String newTitle, [String? folderPath]) async {
    try {
      // 1. 检查新标题是否已存在
      final newMapDataPath = _buildVfsPath(_getMapPath(newTitle, folderPath));
      final newMapDataExists = await _storageService.exists(newMapDataPath);
      if (newMapDataExists) {
        throw Exception('地图标题 "$newTitle" 已存在');
      }

      // 2. 获取旧地图路径
      final oldMapDataPath = _buildVfsPath(_getMapPath(oldTitle, folderPath));
      final oldMapDataExists = await _storageService.exists(oldMapDataPath);
      if (!oldMapDataExists) {
        throw Exception('找不到地图: $oldTitle');
      }

      // 3. 读取并更新JSON元数据
      final metaPath = _buildVfsPath(_getMapMetaPath(oldTitle, folderPath));
      final metaData = await _storageService.readFile(metaPath);
      if (metaData != null) {
        final metaJson = jsonDecode(utf8.decode(metaData.data)) as Map<String, dynamic>;
        metaJson['title'] = newTitle;
        metaJson['updatedAt'] = DateTime.now().toIso8601String();
        
        // 保存更新后的元数据到旧路径
        await _storageService.writeFile(metaPath, utf8.encode(jsonEncode(metaJson)));
      }

      // 4. 重命名地图数据文件夹
      await _storageService.move(oldMapDataPath, newMapDataPath);

      // 5. 清除相关缓存
      final oldCacheKey = folderPath == null ? oldTitle : '$folderPath/$oldTitle';
      final newCacheKey = folderPath == null ? newTitle : '$folderPath/$newTitle';
      _mapCache.remove(oldCacheKey);
      _mapCache.remove(newCacheKey);
      
      final oldLayerCacheKey = folderPath == null
          ? '$oldTitle:default'
          : '$folderPath/$oldTitle:default';
      final newLayerCacheKey = folderPath == null
          ? '$newTitle:default'
          : '$folderPath/$newTitle:default';
      _layerCache.remove(oldLayerCacheKey);
      _layerCache.remove(newLayerCacheKey);

      debugPrint('地图重命名成功: $oldTitle -> $newTitle');
    } catch (e) {
      debugPrint('重命名地图失败 [$oldTitle -> $newTitle]: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateMapCover(String mapTitle, Uint8List imageData, [String? folderPath]) async {
    try {
      // 1. 检查地图是否存在
      final mapDataPath = _buildVfsPath(_getMapPath(mapTitle, folderPath));
      final mapDataExists = await _storageService.exists(mapDataPath);
      if (!mapDataExists) {
        throw Exception('找不到地图: $mapTitle');
      }

      // 2. 直接保存新的封面图片文件
      await _saveMapCover(mapTitle, imageData, folderPath);

      // 3. 读取并更新JSON元数据中的updatedAt时间
      final metaPath = _buildVfsPath(_getMapMetaPath(mapTitle, folderPath));
      final metaData = await _storageService.readFile(metaPath);
      if (metaData != null) {
        final metaJson = jsonDecode(utf8.decode(metaData.data)) as Map<String, dynamic>;
        metaJson['updatedAt'] = DateTime.now().toIso8601String();
        
        // 保存更新后的元数据
        await _storageService.writeFile(metaPath, utf8.encode(jsonEncode(metaJson)));
      }

      // 4. 清除缓存
      final cacheKey = folderPath == null ? mapTitle : '$folderPath/$mapTitle';
      _mapCache.remove(cacheKey);

      debugPrint('地图封面更新成功: $mapTitle');
    } catch (e) {
      debugPrint('更新地图封面失败 [$mapTitle]: $e');
      rethrow;
    }
  }
}
