# VFS地图存储系统

## 概述

VFS地图存储系统是R6Box的新一代地图数据存储解决方案，采用虚拟文件系统(VFS)架构，提供更灵活、可扩展的地图数据管理能力。

## 主要特性

### 🏗️ VFS架构
- 基于虚拟文件系统的层次化存储结构
- 支持复杂的地图数据组织和管理
- 与现有SQLite存储完全兼容

### 📁 文件系统式组织
```
indexeddb://r6box/maps/
├── {map_id}.mapdata/
│   ├── meta.json              # 地图元数据
│   ├── localization.json      # 国际化文本
│   ├── cover.png              # 地图封面
│   ├── data/default/          # 数据目录
│   │   ├── layers/            # 图层数据
│   │   └── legends/           # 图例数据
│   └── assets/                # 统一资产管理
```

### 🔄 资产去重
- SHA-256哈希算法确保资产唯一性
- 自动去重，节省存储空间
- 跨地图资产共享

### 🔌 适配器模式
- 与现有`MapDatabaseService`接口100%兼容
- 自动启用VFS存储系统
- 无需修改现有代码

## 快速开始

### 1. 基本使用

```dart
import 'package:r6box/services/vfs_map_storage/vfs_map_service_factory.dart';

// 创建地图服务（自动使用VFS存储）
final mapService = VfsMapServiceFactory.createMapDatabaseService();

// 使用方式与原有MapDatabaseService完全相同
final maps = await mapService.getAllMaps();
final mapId = await mapService.insertMap(myMap);
```

### 2. 直接使用VFS API

```dart
import 'package:r6box/services/vfs_map_storage/vfs_map_service_factory.dart';

// 创建VFS地图服务
final vfsMapService = VfsMapServiceFactory.createVfsMapService();

// 使用VFS特有功能
final mapStats = await vfsMapService.getMapStats(mapId);
final localizations = await vfsMapService.getMapLocalizations(mapId);
await vfsMapService.saveAsset(imageData, 'image/png');
```

## 系统集成

VFS地图存储系统已自动集成到以下页面：

### 地图册页面 (`MapAtlasPage`)
- 自动使用VFS存储加载地图列表
- 地图创建、删除操作基于VFS
- 支持地图本地化显示

### 地图编辑器 (`MapEditorPage`)  
- 地图数据的读取和保存使用VFS
- 图层、绘制元素管理基于VFS存储
- 图例系统集成VFS

### 数据导入导出服务
- Web平台数据预加载使用VFS
- 数据库导入导出工具集成VFS
- 组合数据库导出器使用VFS

> **注意**: 系统已完全采用VFS存储架构，所有新数据将自动保存到VFS格式中。

## API参考

### VfsMapService接口

#### 地图操作
- `getAllMaps()` - 获取所有地图
- `getMapById(String id)` - 根据ID获取地图
- `getMapByTitle(String title)` - 根据标题获取地图
- `saveMap(MapItem map)` - 保存地图
- `deleteMap(String id)` - 删除地图
- `updateMapMeta(String id, MapItem map)` - 更新地图元数据

#### 图层操作
- `getMapLayers(String mapId)` - 获取地图的所有图层
- `getLayerById(String mapId, String layerId)` - 获取指定图层
- `saveLayer(String mapId, MapLayer layer)` - 保存图层
- `deleteLayer(String mapId, String layerId)` - 删除图层
- `updateLayerOrder(String mapId, List<String> layerIds)` - 更新图层顺序

#### 绘制元素操作
- `getLayerElements(String mapId, String layerId)` - 获取图层的绘制元素
- `getElementById(String mapId, String layerId, String elementId)` - 获取指定绘制元素
- `saveElement(String mapId, String layerId, MapDrawingElement element)` - 保存绘制元素
- `deleteElement(String mapId, String layerId, String elementId)` - 删除绘制元素

#### 图例操作
- `getMapLegendGroups(String mapId)` - 获取地图的图例组
- `getLegendGroupById(String mapId, String groupId)` - 获取指定图例组
- `saveLegendGroup(String mapId, LegendGroup group)` - 保存图例组
- `deleteLegendGroup(String mapId, String groupId)` - 删除图例组

#### 资产管理
- `saveAsset(Uint8List data, String? mimeType)` - 保存资产，返回SHA-256哈希
- `getAsset(String hash)` - 根据哈希获取资产
- `deleteAsset(String hash)` - 删除资产
- `cleanupUnusedAssets(String mapId)` - 清理未使用的资产

#### 本地化支持
- `getMapLocalizations(String mapId)` - 获取地图本地化数据
- `saveMapLocalizations(String mapId, Map<String, String> localizations)` - 保存本地化数据

#### 工具方法
- `mapExists(String id)` - 检查地图是否存在
- `getMapStats(String id)` - 获取地图统计信息
- `validateMapIntegrity(String id)` - 验证地图完整性

### VfsMapDatabaseAdapter

适配器类，实现与现有`MapDatabaseService`的完全兼容：

```dart
// 所有现有API都可以直接使用
final adapter = VfsMapDatabaseAdapter(vfsMapService);
final maps = await adapter.getAllMaps();
final summaries = await adapter.getAllMapsSummary();
final mapId = await adapter.insertMap(map);
await adapter.updateMap(map);
await adapter.deleteMap(mapId);
```

## 配置选项

### VFS存储配置

VFS存储系统默认启用，可以在`VfsMapServiceFactory`中进行配置：

```dart
class VfsMapServiceFactory {
  static const bool _useVfsStorage = true; // VFS存储已默认启用
  
  static MapDatabaseService createMapDatabaseService() {
    // 自动返回VFS适配器实现
    final vfsStorageService = VfsStorageService();
    final vfsMapService = VfsMapServiceImpl(
      storageService: vfsStorageService,
      databaseName: 'r6box',
      mapsCollection: 'maps',
    );
    return VfsMapDatabaseAdapter(vfsMapService);
  }
}
```

### 自定义存储路径

```dart
final vfsMapService = VfsMapServiceFactory.createVfsMapService(
  databaseName: 'r6box',        // 数据库名称
  mapsCollection: 'maps',       // 地图集合名称
);
```

## 存储结构详解

### 目录结构

每个地图在VFS中都有独立的目录结构：

```
{map_id}.mapdata/
├── meta.json              # 地图基本信息
├── localization.json      # 多语言支持
├── cover.png              # 封面图片（可选）
├── data/default/          # 默认数据集
│   ├── layers/            # 图层目录
│   │   ├── {layer_id}/
│   │   │   ├── config.json    # 图层配置
│   │   │   └── elements/      # 绘制元素
│   │   │       ├── {element_id}.json
│   │   │       └── ...
│   │   └── ...
│   └── legends/           # 图例目录
│       ├── {group_id}/
│       │   ├── config.json    # 图例组配置
│       │   └── items/         # 图例项
│       │       ├── {item_id}.json
│       │       └── ...
│       └── ...
└── assets/                # 资产目录
    ├── {sha256_hash1}.png
    ├── {sha256_hash2}.jpg
    └── ...
```

### 元数据格式

#### meta.json
```json
{
  "id": "map_123",
  "title": "地图标题",
  "version": 1,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z",
  "layerCount": 3,
  "legendGroupCount": 2,
  "hasImage": true
}
```

#### localization.json
```json
{
  "en": "Map Title",
  "zh": "地图标题",
  "ja": "マップタイトル"
}
```

#### 图层配置 (layers/{layer_id}/config.json)
```json
{
  "id": "layer_1",
  "name": "图层名称",
  "order": 0,
  "opacity": 1.0,
  "isVisible": true,
  "backgroundImageHash": "sha256_hash",
  "legendGroupIds": ["legend_group_1"],
  "linkedLayerIds": ["layer_2"],
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

## 性能特性

### 缓存机制
- 地图元数据缓存
- 图层列表缓存
- 资产哈希索引缓存
- 可配置的缓存过期时间

### 懒加载
- 按需加载图层数据
- 按需加载绘制元素
- 按需加载图例数据

### 批量操作
- 批量保存图层
- 批量更新元素顺序
- 批量资产操作

## 测试

运行VFS存储系统的测试：

```bash
flutter test test/vfs_map_storage_test.dart
```

测试覆盖：
- 基本CRUD操作
- 图层和元素管理
- 资产管理和去重
- 适配器兼容性
- VFS存储功能

## 最佳实践

### 1. 资产管理
```dart
// 保存图像资产时指定MIME类型
final hash = await vfsMapService.saveAsset(imageData, 'image/png');

// 在图层或元素中引用资产哈希
final layer = MapLayer(
  backgroundImageHash: hash,  // 使用哈希引用
  // ... 其他属性
);
```

### 2. 图层组织
```dart
// 为图层设置合理的顺序
final layers = [
  MapLayer(id: 'background', order: 0),
  MapLayer(id: 'main', order: 1),
  MapLayer(id: 'overlay', order: 2),
];
```

### 3. 本地化支持
```dart
// 保存多语言标题
await vfsMapService.saveMapLocalizations(mapId, {
  'en': 'English Title',
  'zh': '中文标题',
  'ja': '日本語タイトル',
});
```

### 4. 错误处理
```dart
try {
  await vfsMapService.saveMap(map);
} catch (e) {
  debugPrint('保存地图失败: $e');
  // 处理错误...
}
```

## 故障排除

### 常见问题

#### Q: VFS存储模式下地图加载缓慢
A: 检查缓存配置，考虑启用预加载机制

#### Q: 资产重复存储
A: 确保使用相同的MIME类型，VFS会自动去重

#### Q: 适配器ID映射问题
A: 适配器会自动处理ID映射，如有问题请检查缓存

#### Q: 从传统SQLite切换到VFS后数据访问异常
A: VFS系统会自动处理数据格式转换，确保使用VfsMapServiceFactory创建服务

### 调试选项

启用调试日志：
```dart
// 在main.dart中设置
debugPrint('VFS存储调试模式启用');
```

## 未来计划

- [ ] 实现地图包导入/导出功能
- [ ] 添加数据压缩支持
- [ ] 实现增量备份机制
- [ ] 添加数据同步功能
- [ ] 优化大型地图的性能
- [ ] 完善资产管理和清理功能

## 贡献

欢迎提交Issues和Pull Requests来改进VFS地图存储系统。

## 许可证

与R6Box项目保持一致的许可证。
