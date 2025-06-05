# VFS兼容地图数据存储设计

## 概述

本文档描述了R6Box地图数据的新存储结构设计，采用VFS（虚拟文件系统）兼容的方式，将地图数据组织为文件夹结构，便于管理和扩展。

基于对现有地图数据模型的深入分析，地图数据具有极高的复杂性，包含多层次的嵌套结构：
- MapItem 包含多个 MapLayer 和 LegendGroup
- MapLayer 包含多个 MapDrawingElement、图像数据、图例组绑定和图层链接
- MapDrawingElement 支持12种不同的绘制类型，每种都有复杂的属性
- LegendGroup 包含多个 LegendItem，支持图例在地图上的定位和渲染
- 复杂的资产管理：图层背景图、绘制元素中的图像、图例图标等

## 存储结构

### 整体结构

```
indexeddb://r6box/maps/
├── {map_id}.mapdata/
│   ├── meta.json              # 地图元数据
│   ├── localization.json      # 地图国际化文本
│   ├── cover.png              # 地图封面图（可选，便于预览）
│   ├── data/                  # 数据目录
│   │   └── default/           # 默认数据集
│   │       ├── layers/        # 图层数据目录
│   │       │   ├── {layer_id1}/    # 单个图层目录
│   │       │   │   ├── config.json # 图层配置
│   │       │   │   └── elements/   # 该图层的绘制元素
│   │       │   │       ├── {element_id1}.json
│   │       │   │       ├── {element_id2}.json
│   │       │   │       └── ...
│   │       │   ├── {layer_id2}/    # 另一个图层目录
│   │       │   │   ├── config.json
│   │       │   │   └── elements/
│   │       │   └── ...
│   │       └── legends/       # 图例组数据目录
│   │           ├── {group_id1}/    # 单个图例组目录
│   │           │   ├── config.json # 图例组配置
│   │           │   └── items/      # 该组的图例项
│   │           │       ├── {item_id1}.json
│   │           │       ├── {item_id2}.json
│   │           │       └── ...
│   │           ├── {group_id2}/    # 另一个图例组目录
│   │           │   ├── config.json
│   │           │   └── items/
│   │           └── ...
│   └── assets/                # 统一资产管理文件夹（所有资产共享）
│       ├── {sha256_hash1}.png # 图层背景图、绘制元素图像、图例图标等
│       ├── {sha256_hash2}.jpg # 所有图像资产统一存储，基于内容哈希去重
│       ├── {sha256_hash3}.svg
│       ├── {sha256_hash4}.png
│       └── ...
├── {map_id2}.mapdata/
└── ...
```

### 文件格式规范

#### meta.json
记录地图的完整元数据，移除不存在的地图基础背景图引用：

```json
{
  "id": "unique_map_id",
  "title": "地图标题",
  "version": 1,
  "mapVersion": 1,
  "layerRefs": [
    {
      "id": "layer_1",
      "name": "基础图层",
      "order": 0,
      "visible": true,
      "opacity": 1.0,
      "path": "data/default/layers/layer_1/config.json"
    },
    {
      "id": "layer_2", 
      "name": "标记图层",
      "order": 1,
      "visible": true,
      "opacity": 0.8,
      "path": "data/default/layers/layer_2/config.json"
    }
  ],
  "legendGroupRefs": [
    {
      "id": "group_1",
      "name": "建筑标记",
      "visible": true,
      "opacity": 1.0,
      "path": "data/default/legends/group_1/config.json"
    }
  ],
  "created_at": "2025-06-06T10:00:00Z",
  "updated_at": "2025-06-06T10:00:00Z",
  "author": "作者信息",
  "description": "地图描述"
}
```

#### 图层文件 (data/default/layers/{layer_id}/config.json)
每个图层的完整配置，图层背景图引用统一资产目录：

```json
{
  "id": "layer_1",
  "name": "基础图层",
  "order": 0,
  "isVisible": true,
  "opacity": 1.0,
  "imageData": {
    "path": "assets/abc123def456.png",
    "hash": "abc123def456789...",
    "originalName": "base_layer_bg.png",
    "size": 2048576,
    "mimeType": "image/png"
  },
  "imageFit": "contain",
  "xOffset": 0.0,
  "yOffset": 0.0,
  "imageScale": 1.0,
  "isLinkedToNext": false,
  "legendGroupIds": ["group_1", "group_2"],
  "elementRefs": [
    {
      "id": "element_1",
      "type": "line",
      "path": "elements/element_1.json"
    },
    {
      "id": "element_2",
      "type": "imageArea",
      "path": "elements/element_2.json"
    }
  ],
  "created_at": "2025-06-06T10:00:00Z",
  "updated_at": "2025-06-06T10:00:00Z"
}
```

#### 绘制元素文件 (data/default/layers/{layer_id}/elements/{element_id}.json)
详细的绘制元素配置，图像数据引用统一资产目录：

```json
{
  "id": "element_1",
  "type": "imageArea",
  "points": [
    {"dx": 0.1, "dy": 0.2},
    {"dx": 0.3, "dy": 0.4}
  ],
  "color": -16777216,
  "strokeWidth": 2.0,
  "density": 3.0,
  "rotation": 0.0,
  "curvature": 0.0,
  "triangleCut": "none",
  "zIndex": 0,
  "text": "示例文本",
  "fontSize": 16.0,
  "imageData": {
    "path": "assets/xyz789abc123.jpg",
    "hash": "xyz789abc123456...",
    "originalName": "element_image.jpg",
    "size": 512000,
    "mimeType": "image/jpeg"
  },
  "imageFit": "contain",
  "created_at": "2025-06-06T10:00:00Z"
}
```

#### 图例组文件 (data/default/legends/{group_id}/config.json)
图例组配置：

```json
{
  "id": "group_1",
  "name": "建筑标记",
  "isVisible": true,
  "opacity": 1.0,
  "legendItems": [
    {
      "id": "item_1",
      "legendId": "building_door",
      "position": {"dx": 0.5, "dy": 0.3},
      "size": 1.0,
      "rotation": 0.0,
      "opacity": 1.0,
      "isVisible": true,
      "created_at": "2025-06-06T10:00:00Z"
    }
  ],
  "created_at": "2025-06-06T10:00:00Z",
  "updated_at": "2025-06-06T10:00:00Z"
}
```

## 资产管理策略

### 统一资产存储
所有图像资产（图层背景图、绘制元素图像、图例图标等）统一存储在 `assets/` 目录中：
- **完全去重**：基于SHA-256哈希，相同内容的文件只存储一份
- **统一引用**：所有资产都通过相对路径 `assets/{hash}.{ext}` 引用
- **类型无关**：不区分资产用途，只要内容相同就共享
- **便于管理**：所有资产集中在一个目录，便于备份和清理

### 哈希计算和去重
- 使用SHA-256算法计算文件内容哈希
- 文件名格式：`{sha256_hash}.{extension}`
- 保存新资产时先检查哈希是否已存在
- 引用时记录原始文件名便于调试和管理

### 资产引用策略
所有资产引用都使用统一格式：
```json
{
  "imageData": {
    "path": "assets/abc123def456789...xyz.png",
    "hash": "abc123def456789...xyz",
    "originalName": "original_filename.png",
    "size": 1024576,
    "mimeType": "image/png"
  }
}
```

### 资产生命周期管理
```dart
class VfsAssetManager {
  // 保存资产并返回资产路径
  Future<String> saveAsset(String mapId, Uint8List data, String originalName) async {
    final hash = _calculateSHA256(data);
    final extension = _getFileExtension(originalName);
    final assetPath = 'assets/$hash.$extension';
    final fullPath = '${_getMapPath(mapId)}/$assetPath';
    
    // 检查是否已存在
    if (!await _storageService.exists(fullPath)) {
      await _storageService.writeFile(fullPath, data);
      await _updateAssetIndex(mapId, hash, assetPath, originalName, data.length);
    }
    
    return assetPath;
  }
  
  // 清理未使用的资产
  Future<void> cleanUnusedAssets(String mapId) async {
    final usedAssets = await _collectUsedAssets(mapId);
    final allAssets = await _listAllAssets(mapId);
    
    for (final asset in allAssets) {
      if (!usedAssets.contains(asset)) {
        await _storageService.deleteFile('${_getMapPath(mapId)}/$asset');
      }
    }
  }
  
  // 收集所有被引用的资产
  Future<Set<String>> _collectUsedAssets(String mapId) async {
    final usedAssets = <String>{};
    
    // 收集图层背景图
    final layers = await getAllLayers(mapId);
    for (final layer in layers) {
      if (layer.imageData != null) {
        usedAssets.add(layer.imageData!.path);
      }
      
      // 收集绘制元素图像
      for (final element in layer.elements) {
        if (element.imageData != null) {
          usedAssets.add(element.imageData!.path);
        }
      }
    }
    
    return usedAssets;
  }
}

## 复杂数据结构支持

### 绘制元素类型支持
支持以下12种绘制元素类型，每种都有特定的属性和配置：

1. **line** - 实线：基础线条绘制
2. **dashedLine** - 虚线：带有虚线模式的线条
3. **arrow** - 箭头：有方向性的箭头标记
4. **rectangle** - 实心矩形：填充的矩形区域
5. **hollowRectangle** - 空心矩形：只有边框的矩形
6. **diagonalLines** - 单斜线区域：带有斜线图案的区域填充
7. **crossLines** - 交叉线区域：带有交叉线图案的区域填充
8. **dotGrid** - 十字点阵区域：带有点阵图案的区域填充
9. **eraser** - 橡皮擦：用于擦除操作的工具
10. **freeDrawing** - 像素笔：自由绘制的路径
11. **text** - 文本框：可编辑的文本标注
12. **imageArea** - 图片选区：带有图像内容的区域

### 三角形切割支持
支持矩形区域的三角形切割：
- **none** - 无切割（完整矩形）
- **topLeft** - 左上三角
- **topRight** - 右上三角  
- **bottomRight** - 右下三角
- **bottomLeft** - 左下三角

### 图层链接系统
支持图层间的链接关系：
- `isLinkedToNext` 属性控制图层是否链接到下一层
- 链接的图层在编辑时会同步操作
- 支持复杂的图层分组和批量操作

### 图例组绑定
- 每个图层可以绑定多个图例组（`legendGroupIds`）
- 图例项包含在地图上的精确定位信息
- 支持图例的缩放、旋转、透明度控制

## VFS地图数据服务设计

### 核心服务接口

```dart
abstract class VfsMapService {
  // 地图CRUD操作
  Future<List<MapItem>> getAllMaps();
  Future<MapItem?> getMapById(String id);
  Future<MapItem?> getMapByTitle(String title);
  Future<String> saveMap(MapItem map);
  Future<void> deleteMap(String id);
  Future<void> updateMapMeta(String id, MapItem map);
  
  // 图层操作
  Future<List<MapLayer>> getMapLayers(String mapId);
  Future<MapLayer?> getMapLayer(String mapId, String layerId);
  Future<void> saveMapLayer(String mapId, MapLayer layer);
  Future<void> deleteMapLayer(String mapId, String layerId);
  Future<void> updateLayerOrder(String mapId, List<String> layerIds);
  
  // 绘制元素操作
  Future<List<MapDrawingElement>> getLayerElements(String mapId, String layerId);
  Future<MapDrawingElement?> getDrawingElement(String mapId, String layerId, String elementId);
  Future<void> saveDrawingElement(String mapId, String layerId, MapDrawingElement element);
  Future<void> deleteDrawingElement(String mapId, String layerId, String elementId);
  Future<void> updateElementZIndex(String mapId, String layerId, List<String> elementIds);
  
  // 图例操作
  Future<List<LegendGroup>> getMapLegends(String mapId);
  Future<LegendGroup?> getMapLegend(String mapId, String legendId);
  Future<void> saveMapLegend(String mapId, LegendGroup legend);
  Future<void> deleteMapLegend(String mapId, String legendId);
  
  // 图例项操作
  Future<List<LegendItem>> getLegendItems(String mapId, String legendGroupId);
  Future<void> saveLegendItem(String mapId, String legendGroupId, LegendItem item);
  Future<void> deleteLegendItem(String mapId, String legendGroupId, String itemId);
  
  // 资产操作
  Future<String> saveAsset(String mapId, Uint8List data, String originalName, {String? subPath});
  Future<Uint8List?> getAsset(String mapId, String assetPath);
  Future<void> deleteAsset(String mapId, String assetPath);
  Future<void> cleanUnusedAssets(String mapId);
  Future<String> moveAssetToShared(String mapId, String assetPath);
  
  // 批量操作
  Future<void> duplicateLayer(String mapId, String layerId, String newLayerId);
  Future<void> mergeDrawingElements(String mapId, String layerId, List<String> elementIds);
  Future<MapItem> duplicateMap(String mapId, String newTitle);
  
  // 导入导出
  Future<void> exportMapToFile(String mapId, String filePath);
  Future<String> importMapFromFile(String filePath);
  
  // 性能优化
  Future<void> rebuildAssetIndex(String mapId);
  Future<Map<String, dynamic>> getMapStatistics(String mapId);
}
```

### 实现类设计

```dart
class VfsMapServiceImpl implements VfsMapService {
  final VfsStorageService _storageService;
  final String _mapsRootPath;
  final Map<String, MapItem> _mapCache = {};
  final Map<String, String> _assetHashIndex = {};
  
  VfsMapServiceImpl(this._storageService, this._mapsRootPath);
    // 私有方法
  String _getMapPath(String mapId) => '$_mapsRootPath/$mapId.mapdata';
  String _getLayerPath(String mapId, String layerId) => '${_getMapPath(mapId)}/data/default/layers/$layerId/config.json';
  String _getElementPath(String mapId, String layerId, String elementId) => 
    '${_getMapPath(mapId)}/data/default/layers/$layerId/elements/$elementId.json';
  String _getLegendPath(String mapId, String legendId) => '${_getMapPath(mapId)}/data/default/legends/$legendId/config.json';
  
  Future<void> _saveMapMeta(String mapId, MapItem map) async {
    final metaPath = '${_getMapPath(mapId)}/meta.json';
    final metaData = _buildMetaJson(map);
    await _storageService.writeFile(metaPath, utf8.encode(json.encode(metaData)));
  }
  
  Future<MapItem> _loadMapFromMeta(String mapId) async {
    final metaPath = '${_getMapPath(mapId)}/meta.json';
    final metaBytes = await _storageService.readFile(metaPath);
    final metaJson = json.decode(utf8.decode(metaBytes));
    
    // 加载所有图层
    final layers = <MapLayer>[];
    for (final layerRef in metaJson['layerRefs']) {
      final layer = await _loadLayer(mapId, layerRef['id']);
      if (layer != null) layers.add(layer);
    }
    
    // 加载所有图例组
    final legendGroups = <LegendGroup>[];
    for (final legendRef in metaJson['legendGroupRefs']) {
      final legend = await _loadLegend(mapId, legendRef['id']);
      if (legend != null) legendGroups.add(legend);
    }
      // 加载地图背景图像
    Uint8List? imageData;
    if (metaJson['imageData'] != null) {
      final imagePath = '${_getMapPath(mapId)}/${metaJson['imageData']['path']}';
      imageData = await _storageService.readFile(imagePath);
    }
    
    return MapItem(
      id: mapId,
      title: metaJson['title'],
      imageData: imageData,
      version: metaJson['mapVersion'],
      layers: layers,
      legendGroups: legendGroups,
      createdAt: DateTime.parse(metaJson['created_at']),
      updatedAt: DateTime.parse(metaJson['updated_at']),
    );
  }
  
  Future<MapLayer?> _loadLayer(String mapId, String layerId) async {
    // 实现图层加载逻辑，包括加载所有绘制元素
  }
  
  Future<List<MapDrawingElement>> _loadLayerElements(String mapId, String layerId) async {
    // 实现绘制元素加载逻辑
  }
  
  Future<String> _saveAssetWithDeduplication(String mapId, Uint8List data, String originalName) async {
    // 实现资产去重逻辑
  }
  
  // 实现所有接口方法...
}
```

## 兼容性适配器设计

### 适配器模式实现

为了保持与现有 `MapDatabaseService` 的完全兼容性，设计适配器模式：

```dart
class VfsMapDatabaseAdapter implements MapDatabaseService {
  final VfsMapService _vfsService;
  final Map<int, String> _legacyIdMapping = {}; // 旧ID到新ID的映射
  
  VfsMapDatabaseAdapter(this._vfsService);
  
  @override
  Future<List<MapItem>> getAllMaps() async {
    final vfsMaps = await _vfsService.getAllMaps();
    return vfsMaps.map((map) => _addLegacyId(map)).toList();
  }
  
  @override
  Future<MapItem?> getMapById(int id) async {
    final stringId = _legacyIdMapping[id];
    if (stringId == null) return null;
    final map = await _vfsService.getMapById(stringId);
    return map != null ? _addLegacyId(map) : null;
  }
  
  @override
  Future<int> insertMap(MapItem map) async {
    final stringId = await _vfsService.saveMap(map);
    final legacyId = _generateLegacyId();
    _legacyIdMapping[legacyId] = stringId;
    return legacyId;
  }
  
  @override
  Future<void> updateMap(MapItem map) async {
    if (map.id == null) throw ArgumentError('Map ID cannot be null for update');
    final stringId = _legacyIdMapping[map.id!];
    if (stringId == null) throw ArgumentError('Map not found');
    
    // 转换为无ID的map，因为VFS使用字符串ID
    final vfsMap = map.copyWith(id: null);
    await _vfsService.saveMap(vfsMap);
  }
  
  @override
  Future<void> deleteMap(int id) async {
    final stringId = _legacyIdMapping[id];
    if (stringId != null) {
      await _vfsService.deleteMap(stringId);
      _legacyIdMapping.remove(id);
    }
  }
  
  // 数据转换方法
  MapItem _addLegacyId(MapItem map) {
    // 为VFS地图添加legacy ID
    final legacyId = _findOrCreateLegacyId(map.id.toString());
    return map.copyWith(id: legacyId);
  }
  
  int _findOrCreateLegacyId(String stringId) {
    // 查找现有映射或创建新的legacy ID
    for (final entry in _legacyIdMapping.entries) {
      if (entry.value == stringId) return entry.key;
    }
    final newId = _generateLegacyId();
    _legacyIdMapping[newId] = stringId;
    return newId;
  }
  
  int _generateLegacyId() {
    // 生成新的legacy ID（简单递增）
    return _legacyIdMapping.isEmpty ? 1 : _legacyIdMapping.keys.reduce(math.max) + 1;
  }
  
  // 实现其他MapDatabaseService方法...
}
```

### 渐进式迁移策略

```dart
class MapServiceFactory {
  static const bool _useVfsStorage = true; // 配置开关
  
  static MapDatabaseService createMapService() {
    if (_useVfsStorage) {
      final vfsStorageService = VfsStorageService();
      final vfsMapService = VfsMapServiceImpl(vfsStorageService, '/maps');
      return VfsMapDatabaseAdapter(vfsMapService);
    } else {
      return MapDatabaseService();
    }
  }
}
```

### 数据迁移工具

```dart
class MapDataMigrationTool {
  final MapDatabaseService _legacyService;
  final VfsMapService _vfsService;
  
  MapDataMigrationTool(this._legacyService, this._vfsService);
  
  Future<void> migrateAllMaps() async {
    final legacyMaps = await _legacyService.getAllMaps();
    
    for (final map in legacyMaps) {
      try {
        await _migrateSingleMap(map);
        print('Successfully migrated map: ${map.title}');
      } catch (e) {
        print('Failed to migrate map ${map.title}: $e');
      }
    }
  }
  
  Future<void> _migrateSingleMap(MapItem map) async {
    // 1. 保存地图基本信息
    final newMapId = await _vfsService.saveMap(map);
    
    // 2. 迁移图层数据
    for (final layer in map.layers) {
      await _vfsService.saveMapLayer(newMapId, layer);
      
      // 3. 迁移绘制元素
      for (final element in layer.elements) {
        await _vfsService.saveDrawingElement(newMapId, layer.id, element);
      }
    }
    
    // 4. 迁移图例组
    for (final legendGroup in map.legendGroups) {
      await _vfsService.saveMapLegend(newMapId, legendGroup);
      
      // 5. 迁移图例项
      for (final legendItem in legendGroup.legendItems) {
        await _vfsService.saveLegendItem(newMapId, legendGroup.id, legendItem);
      }
    }
    
    // 6. 清理未使用的资产
    await _vfsService.cleanUnusedAssets(newMapId);
  }
  
  Future<void> validateMigration() async {
    // 验证迁移完整性
    final legacyMaps = await _legacyService.getAllMaps();
    final vfsMaps = await _vfsService.getAllMaps();
    
    if (legacyMaps.length != vfsMaps.length) {
      throw Exception('Migration incomplete: map count mismatch');
    }
    
    for (final legacyMap in legacyMaps) {
      final vfsMap = vfsMaps.firstWhere(
        (m) => m.title == legacyMap.title,
        orElse: () => throw Exception('Missing map: ${legacyMap.title}'),
      );
      
      _validateMapData(legacyMap, vfsMap);
    }
  }
  
  void _validateMapData(MapItem legacy, MapItem vfs) {
    // 验证地图数据完整性
    assert(legacy.layers.length == vfs.layers.length, 'Layer count mismatch');
    assert(legacy.legendGroups.length == vfs.legendGroups.length, 'Legend group count mismatch');
    
    for (int i = 0; i < legacy.layers.length; i++) {
      final legacyLayer = legacy.layers[i];
      final vfsLayer = vfs.layers[i];
      assert(legacyLayer.elements.length == vfsLayer.elements.length, 'Element count mismatch in layer ${legacyLayer.name}');
    }
  }
}
```

## 优势与性能考虑

### 架构优势

1. **精确的数据分离**：每个组件（图层、元素、图例）都有独立的存储，便于细粒度操作
2. **避免重复存储**：通过SHA-256哈希去重，相同资产只存储一份
3. **结构清晰**：分层文件夹结构便于理解、调试和版本控制
4. **扩展性强**：易于添加新的绘制元素类型和图层功能
5. **向后兼容**：通过适配器完全保持现有API兼容性
6. **支持复杂操作**：原生支持图层链接、元素分组、批量操作等高级功能

### 性能优化策略

1. **懒加载**：按需加载图层和元素，减少内存占用
2. **缓存机制**：缓存常用的地图元数据和小文件
3. **异步处理**：所有文件I/O操作都是异步的，不阻塞UI
4. **批量操作**：支持批量保存、删除和更新操作
5. **资产索引**：维护资产使用索引，快速定位和清理未使用文件
6. **增量更新**：只更新变化的部分，避免重写整个地图文件

### 内存管理

```dart
class VfsMapCache {
  final Map<String, MapItem> _mapCache = {};
  final Map<String, MapLayer> _layerCache = {};
  final Map<String, Uint8List> _assetCache = {};
  final int _maxCacheSize = 50 * 1024 * 1024; // 50MB
  
  void _evictLeastRecentlyUsed() {
    // 实现LRU缓存清理策略
  }
  
  Future<void> preloadMap(String mapId) async {
    // 预加载地图数据到缓存
  }
}
```

## 实现注意事项

### 并发安全
- 使用文件锁确保并发写入安全
- 实现乐观锁机制检测冲突
- 提供事务性操作支持，确保数据一致性

### 错误处理
- 完善的异常处理和回滚机制
- 自动检测和修复损坏的文件
- 提供数据完整性验证工具

### 文件系统兼容性
- 支持不同操作系统的文件名限制
- 处理特殊字符和Unicode文件名
- 实现跨平台的路径处理

### 数据完整性
```dart
class MapDataValidator {
  static Future<List<String>> validateMap(String mapId, VfsStorageService storage) async {
    final errors = <String>[];
    
    // 验证元数据文件
    if (!await storage.exists('$mapId.mapdata/meta.json')) {
      errors.add('Missing meta.json file');
    }
    
    // 验证图层文件完整性
    // 验证资产引用完整性
    // 验证图例数据完整性
    
    return errors;
  }
}
```

### 备份和恢复
```dart
class MapBackupService {
  Future<void> createBackup(String mapId, String backupPath) async {
    // 创建完整的地图备份
  }
  
  Future<void> restoreFromBackup(String backupPath, String newMapId) async {
    // 从备份恢复地图
  }
  
  Future<void> exportMapBundle(String mapId, String exportPath) async {
    // 导出自包含的地图包
  }
}
```

## 测试策略

### 单元测试
- 测试每个服务方法的正确性
- 验证数据转换的准确性
- 测试资产去重逻辑

### 集成测试
- 测试完整的地图创建、编辑、保存流程
- 验证迁移工具的正确性
- 测试并发操作的安全性

### 性能测试
- 测试大型地图的加载性能
- 验证缓存机制的有效性
- 测试资产清理的效率

此设计文档准确反映了R6Box地图数据的真实复杂性，提供了完整的VFS兼容存储解决方案，确保能够处理所有现有功能并为未来扩展提供良好的基础。
