import 'dart:typed_data';
import '../../models/map_item.dart';
import '../../models/map_item_summary.dart';
import '../../models/map_layer.dart';
import '../../models/sticky_note.dart';

/// VFS地图数据服务抽象接口
/// 定义VFS兼容的地图数据操作方法
/// 注意：由于VFS系统使用基于标题的存储，大部分方法使用mapTitle作为地图标识符
abstract class VfsMapService {
  // 地图CRUD操作
  Future<List<MapItem>> getAllMaps([String? folderPath]);
  Future<List<MapItemSummary>> getAllMapsSummary([String? folderPath]);
  Future<int> getMapCount([String? folderPath]);
  Future<MapItem?> getMapById(String id); // 兼容性方法，内部转换为标题查找
  Future<MapItem?> getMapByTitle(String title, [String? folderPath]);
  Future<String> saveMap(MapItem map, [String? folderPath]); // 返回标题作为标识符
  Future<void> deleteMap(String mapTitle, [String? folderPath]);

  // 目录操作
  Future<List<String>> getFolders([String? parentPath]);
  Future<void> createFolder(String folderPath);
  Future<void> deleteFolder(String folderPath);
  Future<void> moveMap(String mapTitle, String? fromFolder, String? toFolder);

  Future<void> updateMapMeta(
    String mapTitle,
    MapItem map, [
    String? folderPath,
  ]);
  // 图层操作 - 使用mapTitle作为地图标识符
  Future<List<MapLayer>> getMapLayers(
    String mapTitle, [
    String version = 'default',
    String? folderPath,
  ]);
  Future<MapLayer?> getLayerById(
    String mapTitle,
    String layerId, [
    String version = 'default',
  ]);
  Future<void> saveLayer(
    String mapTitle,
    MapLayer layer, [
    String version = 'default',
    String? folderPath,
  ]);
  Future<void> deleteLayer(
    String mapTitle,
    String layerId, [
    String version = 'default',
    String? folderPath,
  ]);
  Future<void> updateLayerOrder(
    String mapTitle,
    List<String> layerIds, [
    String version = 'default',
  ]);

  // 绘制元素操作 - 使用mapTitle作为地图标识符
  Future<List<MapDrawingElement>> getLayerElements(
    String mapTitle,
    String layerId, [
    String version = 'default',
  ]);
  Future<MapDrawingElement?> getElementById(
    String mapTitle,
    String layerId,
    String elementId, [
    String version = 'default',
  ]);
  Future<void> saveElement(
    String mapTitle,
    String layerId,
    MapDrawingElement element, [
    String version = 'default',
  ]);
  Future<void> deleteElement(
    String mapTitle,
    String layerId,
    String elementId, [
    String version = 'default',
    String? folderPath,
  ]);
  Future<void> updateElementsOrder(
    String mapTitle,
    String layerId,
    List<String> elementIds, [
    String version = 'default',
  ]);

  // 图例组操作 - 使用mapTitle作为地图标识符
  Future<List<LegendGroup>> getMapLegendGroups(
    String mapTitle, [
    String version = 'default',
    String? folderPath,
  ]);
  Future<LegendGroup?> getLegendGroupById(
    String mapTitle,
    String groupId, [
    String version = 'default',
  ]);
  Future<void> saveLegendGroup(
    String mapTitle,
    LegendGroup group, [
    String version = 'default',
    String? folderPath,
  ]);
  Future<void> deleteLegendGroup(
    String mapTitle,
    String groupId, [
    String version = 'default',
    String? folderPath,
  ]);

  // 图例项操作 - 使用mapTitle作为地图标识符
  Future<List<LegendItem>> getLegendGroupItems(
    String mapTitle,
    String groupId, [
    String version = 'default',
  ]);
  Future<LegendItem?> getLegendItemById(
    String mapTitle,
    String groupId,
    String itemId, [
    String version = 'default',
  ]);
  Future<void> saveLegendItem(
    String mapTitle,
    String groupId,
    LegendItem item, [
    String version = 'default',
  ]);
  Future<void> deleteLegendItem(
    String mapTitle,
    String groupId,
    String itemId, [
    String version = 'default',
    String? folderPath,
  ]);

  // 便签数据操作 - 使用mapTitle作为地图标识符
  Future<List<StickyNote>> getMapStickyNotes(
    String mapTitle, [
    String version = 'default',
    String? folderPath,
  ]);
  Future<StickyNote?> getStickyNoteById(
    String mapTitle,
    String stickyNoteId, [
    String version = 'default',
    String? folderPath,
  ]);
  Future<void> saveStickyNote(
    String mapTitle,
    StickyNote stickyNote, [
    String version = 'default',
    String? folderPath,
  ]);
  Future<void> deleteStickyNote(
    String mapTitle,
    String stickyNoteId, [
    String version = 'default',
    String? folderPath,
  ]);

  // 版本管理
  Future<List<String>> getMapVersions(String mapTitle, [String? folderPath]);
  Future<void> createMapVersion(
    String mapTitle,
    String version, [
    String? sourceVersion,
    String? folderPath,
  ]);
  Future<void> deleteMapVersion(
    String mapTitle,
    String version, [
    String? folderPath,
  ]);
  Future<bool> mapVersionExists(
    String mapTitle,
    String version, [
    String? folderPath,
  ]);
  Future<void> copyVersionData(
    String mapTitle,
    String sourceVersion,
    String targetVersion, [
    String? folderPath,
  ]);

  // 版本元数据管理
  Future<void> saveVersionMetadata(
    String mapTitle,
    String versionId,
    String versionName, {
    DateTime? createdAt,
    DateTime? updatedAt,
    String? folderPath,
  });
  Future<String?> getVersionName(
    String mapTitle,
    String versionId, [
    String? folderPath,
  ]);
  Future<Map<String, String>> getAllVersionNames(
    String mapTitle, [
    String? folderPath,
  ]);
  Future<void> deleteVersionMetadata(
    String mapTitle,
    String versionId, [
    String? folderPath,
  ]);

  // 资产管理 - 每个地图独立的资产存储
  Future<String> saveAsset(
    String mapTitle,
    Uint8List data,
    String? mimeType, [
    String? folderPath,
  ]);
  Future<Uint8List?> getAsset(
    String mapTitle,
    String hash, [
    String? folderPath,
  ]);
  Future<void> deleteAsset(String mapTitle, String hash, [String? folderPath]);
  Future<void> cleanupUnusedAssets(String mapTitle, [String? folderPath]);
  Future<Map<String, int>> getAssetUsageStats(
    String mapTitle, [
    String? folderPath,
  ]);

  // 本地化支持 - 使用mapTitle作为地图标识符
  Future<Map<String, String>> getMapLocalizations(
    String mapTitle, [
    String? folderPath,
  ]);
  Future<void> saveMapLocalizations(
    String mapTitle,
    Map<String, String> localizations, [
    String? folderPath,
  ]);

  // 工具方法 - 兼容性方法，支持ID和标题查找
  Future<bool> mapExists(String idOrTitle, [String? folderPath]);
  Future<Map<String, dynamic>> getMapStats(String idOrTitle);
  Future<void> validateMapIntegrity(String idOrTitle);

  // 批量操作 - 使用标题作为标识符
  Future<void> duplicateMap(String sourceTitle, String newTitle);
  Future<void> exportMap(String mapTitle, String exportPath);
  Future<String> importMap(String importPath, {bool overwrite = false});
}
