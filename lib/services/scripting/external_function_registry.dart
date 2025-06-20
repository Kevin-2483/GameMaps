import 'dart:async';
import 'dart:math' as math;

/// 外部函数注册管理器
/// 统一管理所有脚本执行器的外部函数定义，避免重复代码
class ExternalFunctionRegistry {
  static final ExternalFunctionRegistry _instance =
      ExternalFunctionRegistry._internal();
  factory ExternalFunctionRegistry() => _instance;
  ExternalFunctionRegistry._internal();

  /// 为隔离环境注册外部函数（通过消息传递）
  static Map<String, Function> createFunctionsForIsolate(
    Future<dynamic> Function(String functionName, List<dynamic> arguments)
    callExternalFunction,
  ) {
    final functions = <String, Function>{};

    // 基础函数
    _registerBasicFunctions(functions, callExternalFunction);

    // 地图数据访问函数
    _registerMapDataFunctions(functions, callExternalFunction);

    // 文本和UI函数
    _registerTextAndUIFunctions(functions, callExternalFunction);

    // 文件操作函数
    _registerFileOperationFunctions(functions, callExternalFunction);

    // 便签相关函数
    _registerStickyNoteFunctions(functions, callExternalFunction);

    // 图例相关函数
    _registerLegendFunctions(functions, callExternalFunction);

    return functions;
  }

  /// 获取所有外部函数名称列表
  static List<String> getAllFunctionNames() {
    return [
      // 基础函数
      'log', 'print',

      // 数学函数 (已移至Worker内部实现)
      // 'sin', 'cos', 'tan', 'sqrt', 'pow', 'abs', 'random',

      // 地图数据访问函数
      'getLayers', 'getLayerById', 'getElementsInLayer', 'getAllElements',
      'countElements', 'calculateTotalArea',

      // 元素修改函数
      'updateElementProperty', 'moveElement',

      // 文本元素函数
      'createTextElement', 'updateTextContent', 'updateTextSize',
      'getTextElements', 'findTextElementsByContent', 'say',

      // 文件操作函数
      'readjson', 'writetext',

      // 便签相关函数
      'getStickyNotes', 'getStickyNoteById', 'getElementsInStickyNote',
      'filterStickyNotesByTags', 'filterStickyNoteElementsByTags',

      // 图例相关函数
      'getLegendGroups', 'getLegendGroupById', 'updateLegendGroup',
      'updateLegendGroupVisibility', 'updateLegendGroupOpacity',
      'getLegendItems', 'getLegendItemById', 'updateLegendItem',
      'filterLegendGroupsByTags', 'filterLegendItemsByTags',
    ];
  }

  /// 获取所有函数名称列表（包括Worker内部函数）
  static List<String> getAllFunctionNamesWithInternal() {
    final externalFunctions = getAllFunctionNames();
    final internalFunctions = getInternalFunctionNames();

    // 合并并去重
    final allFunctions = <String>{};
    allFunctions.addAll(externalFunctions);
    allFunctions.addAll(internalFunctions);

    return allFunctions.toList();
  }

  /// 获取Worker内部函数名称列表
  static List<String> getInternalFunctionNames() {
    return [
      'sin',
      'cos',
      'tan',
      'sqrt',
      'pow',
      'abs',
      'random',
      'min',
      'max',
      'floor',
      'ceil',
      'round',
      // Worker内部实现的延迟函数
      'delay', 'delayThen', 'now',
    ];
  }

  /// 注册基础函数
  static void _registerBasicFunctions(
    Map<String, Function> functions,
    Future<dynamic> Function(String, List<dynamic>) callExternalFunction,
  ) {
    functions['log'] = (dynamic message) async {
      return await callExternalFunction('log', [message]);
    };

    functions['print'] = (dynamic message) async {
      return await callExternalFunction('print', [message]);
    };
  }

  /// 注册地图数据访问函数
  static void _registerMapDataFunctions(
    Map<String, Function> functions,
    Future<dynamic> Function(String, List<dynamic>) callExternalFunction,
  ) {
    // 图层相关
    functions['getLayers'] = () async {
      return await callExternalFunction('getLayers', []);
    };

    functions['getLayerById'] = (String id) async {
      return await callExternalFunction('getLayerById', [id]);
    };

    functions['getElementsInLayer'] = (String layerId) async {
      return await callExternalFunction('getElementsInLayer', [layerId]);
    };

    functions['getAllElements'] = () async {
      return await callExternalFunction('getAllElements', []);
    };

    functions['countElements'] = ([String? type]) async {
      return await callExternalFunction('countElements', [type]);
    };

    functions['calculateTotalArea'] = () async {
      return await callExternalFunction('calculateTotalArea', []);
    };

    // 元素修改函数
    functions['updateElementProperty'] =
        (String elementId, String property, dynamic value) async {
          return await callExternalFunction('updateElementProperty', [
            elementId,
            property,
            value,
          ]);
        };

    functions['moveElement'] =
        (String elementId, Map<String, dynamic> newPosition) async {
          return await callExternalFunction('moveElement', [
            elementId,
            newPosition,
          ]);
        };
  }

  /// 注册文本和UI函数
  static void _registerTextAndUIFunctions(
    Map<String, Function> functions,
    Future<dynamic> Function(String, List<dynamic>) callExternalFunction,
  ) {
    functions['createTextElement'] = (Map<String, dynamic> params) async {
      return await callExternalFunction('createTextElement', [params]);
    };

    functions['updateTextContent'] = (String elementId, String content) async {
      return await callExternalFunction('updateTextContent', [
        elementId,
        content,
      ]);
    };

    functions['updateTextSize'] = (String elementId, double size) async {
      return await callExternalFunction('updateTextSize', [elementId, size]);
    };

    functions['getTextElements'] = () async {
      return await callExternalFunction('getTextElements', []);
    };

    functions['findTextElementsByContent'] = (String content) async {
      return await callExternalFunction('findTextElementsByContent', [content]);
    };

    functions['say'] =
        (dynamic tagFilter, String filterType, String text) async {
          return await callExternalFunction('say', [
            tagFilter,
            filterType,
            text,
          ]);
        };
  }

  /// 注册文件操作函数
  static void _registerFileOperationFunctions(
    Map<String, Function> functions,
    Future<dynamic> Function(String, List<dynamic>) callExternalFunction,
  ) {
    functions['readjson'] = (String filename) async {
      return await callExternalFunction('readjson', [filename]);
    };

    functions['writetext'] = (String filename, String content) async {
      return await callExternalFunction('writetext', [filename, content]);
    };
  }

  /// 注册便签相关函数
  static void _registerStickyNoteFunctions(
    Map<String, Function> functions,
    Future<dynamic> Function(String, List<dynamic>) callExternalFunction,
  ) {
    functions['getStickyNotes'] = () async {
      return await callExternalFunction('getStickyNotes', []);
    };

    functions['getStickyNoteById'] = (String id) async {
      return await callExternalFunction('getStickyNoteById', [id]);
    };

    functions['getElementsInStickyNote'] = (String id) async {
      return await callExternalFunction('getElementsInStickyNote', [id]);
    };

    functions['filterStickyNotesByTags'] = (List<String> tags) async {
      return await callExternalFunction('filterStickyNotesByTags', [tags]);
    };

    functions['filterStickyNoteElementsByTags'] = (List<String> tags) async {
      return await callExternalFunction('filterStickyNoteElementsByTags', [
        tags,
      ]);
    };
  }

  /// 注册图例相关函数
  static void _registerLegendFunctions(
    Map<String, Function> functions,
    Future<dynamic> Function(String, List<dynamic>) callExternalFunction,
  ) {
    functions['getLegendGroups'] = () async {
      return await callExternalFunction('getLegendGroups', []);
    };

    functions['getLegendGroupById'] = (String id) async {
      return await callExternalFunction('getLegendGroupById', [id]);
    };

    functions['updateLegendGroup'] =
        (String id, Map<String, dynamic> params) async {
          return await callExternalFunction('updateLegendGroup', [id, params]);
        };

    functions['updateLegendGroupVisibility'] = (String id, bool visible) async {
      return await callExternalFunction('updateLegendGroupVisibility', [
        id,
        visible,
      ]);
    };

    functions['updateLegendGroupOpacity'] = (String id, double opacity) async {
      return await callExternalFunction('updateLegendGroupOpacity', [
        id,
        opacity,
      ]);
    };

    functions['getLegendItems'] = () async {
      return await callExternalFunction('getLegendItems', []);
    };

    functions['getLegendItemById'] = (String id) async {
      return await callExternalFunction('getLegendItemById', [id]);
    };

    functions['updateLegendItem'] =
        (String id, Map<String, dynamic> params) async {
          return await callExternalFunction('updateLegendItem', [id, params]);
        };

    functions['filterLegendGroupsByTags'] = (List<String> tags) async {
      return await callExternalFunction('filterLegendGroupsByTags', [tags]);
    };

    functions['filterLegendItemsByTags'] = (List<String> tags) async {
      return await callExternalFunction('filterLegendItemsByTags', [tags]);
    };
  }

  /// 生成唯一的调用ID
  static String generateCallId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        math.Random().nextInt(1000).toString();
  }
}
