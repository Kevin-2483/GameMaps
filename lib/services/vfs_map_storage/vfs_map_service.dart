import 'dart:typed_data';
import '../../models/map_item.dart';
import '../../models/map_layer.dart';

/// VFS地图数据服务抽象接口
/// 定义VFS兼容的地图数据操作方法
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
  Future<MapLayer?> getLayerById(String mapId, String layerId);
  Future<void> saveLayer(String mapId, MapLayer layer);
  Future<void> deleteLayer(String mapId, String layerId);
  Future<void> updateLayerOrder(String mapId, List<String> layerIds);
  
  // 绘制元素操作
  Future<List<MapDrawingElement>> getLayerElements(String mapId, String layerId);
  Future<MapDrawingElement?> getElementById(String mapId, String layerId, String elementId);
  Future<void> saveElement(String mapId, String layerId, MapDrawingElement element);
  Future<void> deleteElement(String mapId, String layerId, String elementId);
  Future<void> updateElementsOrder(String mapId, String layerId, List<String> elementIds);
  
  // 图例组操作
  Future<List<LegendGroup>> getMapLegendGroups(String mapId);
  Future<LegendGroup?> getLegendGroupById(String mapId, String groupId);
  Future<void> saveLegendGroup(String mapId, LegendGroup group);
  Future<void> deleteLegendGroup(String mapId, String groupId);
  
  // 图例项操作
  Future<List<LegendItem>> getLegendGroupItems(String mapId, String groupId);
  Future<LegendItem?> getLegendItemById(String mapId, String groupId, String itemId);
  Future<void> saveLegendItem(String mapId, String groupId, LegendItem item);
  Future<void> deleteLegendItem(String mapId, String groupId, String itemId);
  
  // 资产管理
  Future<String> saveAsset(Uint8List data, String? mimeType);
  Future<Uint8List?> getAsset(String hash);
  Future<void> deleteAsset(String hash);
  Future<void> cleanupUnusedAssets(String mapId);
  Future<Map<String, int>> getAssetUsageStats(String mapId);
  
  // 本地化支持
  Future<Map<String, String>> getMapLocalizations(String mapId);
  Future<void> saveMapLocalizations(String mapId, Map<String, String> localizations);
  
  // 工具方法
  Future<bool> mapExists(String id);
  Future<Map<String, dynamic>> getMapStats(String id);
  Future<void> validateMapIntegrity(String id);
  
  // 批量操作
  Future<void> duplicateMap(String sourceId, String newTitle);
  Future<void> exportMap(String id, String exportPath);
  Future<String> importMap(String importPath, {bool overwrite = false});
}
