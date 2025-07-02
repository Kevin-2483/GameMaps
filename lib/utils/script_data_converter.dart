import '../models/map_layer.dart';
import '../models/sticky_note.dart';

/// 脚本数据转换工具类
/// 统一处理脚本执行器需要的数据格式转换
class ScriptDataConverter {
  /// 将图层转换为脚本可用的Map格式
  static Map<String, dynamic> layerToMap(MapLayer layer) {
    return {
      'id': layer.id,
      'name': layer.name,
      'isVisible': layer.isVisible,
      'opacity': layer.opacity,
      'elements': layer.elements.map((e) => elementToMap(e)).toList(),
      'tags': layer.tags ?? [],
    };
  }

  /// 将绘图元素转换为脚本可用的Map格式
  static Map<String, dynamic> elementToMap(MapDrawingElement element) {
    return {
      'id': element.id,
      'type': element.type.name,
      'points': element.points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'color': element.color.value,
      'strokeWidth': element.strokeWidth,
      'text': element.text,
      'fontSize': element.fontSize,
      'tags': element.tags ?? [],
    };
  }

  /// 将便签转换为脚本可用的Map格式
  static Map<String, dynamic> stickyNoteToMap(StickyNote note) {
    return {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'position': {'x': note.position.dx, 'y': note.position.dy},
      'size': {'width': note.size.width, 'height': note.size.height},
      'backgroundColor': note.backgroundColor.value,
      'isVisible': note.isVisible,
      'isCollapsed': note.isCollapsed,
      'tags': note.tags ?? [],
    };
  }

  /// 将图例组转换为脚本可用的Map格式
  static Map<String, dynamic> legendGroupToMap(LegendGroup group) {
    return {
      'id': group.id,
      'name': group.name,
      'isVisible': group.isVisible,
      'opacity': group.opacity,
      'legendItems': group.legendItems
          .map((item) => legendItemToMap(item))
          .toList(),
      'tags': group.tags ?? [],
    };
  }

  /// 将图例项转换为脚本可用的Map格式
  static Map<String, dynamic> legendItemToMap(LegendItem item) {
    return {
      'id': item.id,
      'legendPath': item.legendPath,
      'legendId': item.legendId, // 保留向后兼容
      'position': {'x': item.position.dx, 'y': item.position.dy},
      'size': item.size,
      'rotation': item.rotation,
      'opacity': item.opacity,
      'isVisible': item.isVisible,
      'url': item.url,
      'tags': item.tags ?? [],
    };
  }
}
