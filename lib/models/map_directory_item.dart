import '../../models/map_item_summary.dart';

/// 地图目录项 - 可以是文件夹或地图
abstract class MapDirectoryItem {
  final String name;
  final String path;
  
  const MapDirectoryItem({required this.name, required this.path});
}

/// 文件夹项
class MapFolderItem extends MapDirectoryItem {
  final int mapCount; // 该文件夹内的地图数量（包括子文件夹）
  
  const MapFolderItem({
    required super.name,
    required super.path,
    required this.mapCount,
  });
}

/// 地图项（包装现有的MapItemSummary）
class MapFileItem extends MapDirectoryItem {
  final MapItemSummary mapSummary;
  
  const MapFileItem({
    required super.name,
    required super.path,
    required this.mapSummary,
  });
}

/// 面包屑导航项
class BreadcrumbItem {
  final String name;
  final String path;
  
  const BreadcrumbItem({required this.name, required this.path});
}
