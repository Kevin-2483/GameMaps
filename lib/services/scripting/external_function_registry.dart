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
    callAwaitableFunction,
    void Function(String functionName, List<dynamic> arguments)
    callFireAndForgetFunction,
  ) {
    final functions = <String, Function>{};

    // 基础函数
    _registerBasicFunctions(
      functions,
      callAwaitableFunction,
      callFireAndForgetFunction,
    );

    // 地图数据访问函数
    _registerMapDataFunctions(
      functions,
      callAwaitableFunction,
      callFireAndForgetFunction,
    );

    // 文本和UI函数
    _registerTextAndUIFunctions(
      functions,
      callAwaitableFunction,
      callFireAndForgetFunction,
    );

    // 文件操作函数
    _registerFileOperationFunctions(
      functions,
      callAwaitableFunction,
      callFireAndForgetFunction,
    );

    // 便签相关函数
    _registerStickyNoteFunctions(
      functions,
      callAwaitableFunction,
      callFireAndForgetFunction,
    );

    // 图例相关函数
    _registerLegendFunctions(
      functions,
      callAwaitableFunction,
      callFireAndForgetFunction,
    );

    // TTS相关函数
    _registerTtsFunctions(
      functions,
      callAwaitableFunction,
      callFireAndForgetFunction,
    );

    return functions;
  }

  /// 获取需要等待结果的函数名称列表（读取、查找类函数）
  static List<String> getAwaitableFunctionNames() {
    return [
      // 地图数据访问函数（读取类）
      'getLayers', 'getLayerById', 'getElementsInLayer', 'getAllElements',
      'countElements', 'calculateTotalArea',

      // 文本元素查询函数（读取类）
      'getTextElements', 'findTextElementsByContent',

      // TTS查询函数（读取类）
      'ttsGetLanguages',
      'ttsGetVoices',
      'ttsIsLanguageAvailable',
      'ttsGetSpeechRateRange',

      // 文件操作函数（读取类）
      'readjson',

      // 便签相关函数（读取类）
      'getStickyNotes', 'getStickyNoteById', 'getElementsInStickyNote',
      'filterStickyNotesByTags', 'filterStickyNoteElementsByTags',

      // 图例相关函数（读取类）
      'getLegendGroups', 'getLegendGroupById', 'getLegendItems',
      'getLegendItemById',
      'filterLegendGroupsByTags',
      'filterLegendItemsByTags',
    ];
  }

  /// 获取不需要等待结果的函数名称列表（修改、更新、日志类函数）
  static List<String> getFireAndForgetFunctionNames() {
    return [
      // 基础函数（日志类）
      'log', 'print',

      // 元素修改函数（修改类）
      'updateElementProperty', 'moveElement',

      // 文本元素函数（修改类）
      'createTextElement',
      'updateTextContent',
      'updateTextSize',
      'say',
      'ttsStop',

      // 文件操作函数（写入类）
      'writetext',

      // 图例相关函数（修改类）
      'updateLegendGroup',
      'updateLegendGroupVisibility',
      'updateLegendGroupOpacity',
      'updateLegendItem',
    ];
  }

  /// 获取所有外部函数名称列表
  static List<String> getAllFunctionNames() {
    final awaitableFunctions = getAwaitableFunctionNames();
    final fireAndForgetFunctions = getFireAndForgetFunctionNames();

    // 合并并去重
    final allFunctions = <String>{};
    allFunctions.addAll(awaitableFunctions);
    allFunctions.addAll(fireAndForgetFunctions);

    return allFunctions.toList();
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
    Future<dynamic> Function(String, List<dynamic>) callAwaitableFunction,
    void Function(String, List<dynamic>) callFireAndForgetFunction,
  ) {
    // log 和 print 是不需要等待结果的函数
    functions['log'] = (dynamic message) {
      callFireAndForgetFunction('log', [message]);
      return null; // 立即返回，不等待结果
    };

    functions['print'] = (dynamic message) {
      callFireAndForgetFunction('print', [message]);
      return null; // 立即返回，不等待结果
    };
  }

  /// 注册地图数据访问函数
  static void _registerMapDataFunctions(
    Map<String, Function> functions,
    Future<dynamic> Function(String, List<dynamic>) callAwaitableFunction,
    void Function(String, List<dynamic>) callFireAndForgetFunction,
  ) {
    // 图层相关 - 这些都是读取类函数，需要等待结果
    functions['getLayers'] = () async {
      return await callAwaitableFunction('getLayers', []);
    };

    functions['getLayerById'] = (String id) async {
      return await callAwaitableFunction('getLayerById', [id]);
    };

    functions['getElementsInLayer'] = (String layerId) async {
      return await callAwaitableFunction('getElementsInLayer', [layerId]);
    };

    functions['getAllElements'] = () async {
      return await callAwaitableFunction('getAllElements', []);
    };

    functions['countElements'] = ([String? type]) async {
      return await callAwaitableFunction('countElements', [type]);
    };

    functions['calculateTotalArea'] = () async {
      return await callAwaitableFunction('calculateTotalArea', []);
    };

    // 元素修改函数 - 这些都是修改类函数，不需要等待结果
    functions['updateElementProperty'] =
        (String elementId, String property, dynamic value) {
          callFireAndForgetFunction('updateElementProperty', [
            elementId,
            property,
            value,
          ]);
          return null; // 立即返回，不等待结果
        };

    functions['moveElement'] =
        (String elementId, Map<String, dynamic> newPosition) {
          callFireAndForgetFunction('moveElement', [elementId, newPosition]);
          return null; // 立即返回，不等待结果
        };
  }

  /// 注册文本和UI函数
  static void _registerTextAndUIFunctions(
    Map<String, Function> functions,
    Future<dynamic> Function(String, List<dynamic>) callAwaitableFunction,
    void Function(String, List<dynamic>) callFireAndForgetFunction,
  ) {
    // 文本元素修改函数 - 不需要等待结果
    functions['createTextElement'] = (Map<String, dynamic> params) {
      callFireAndForgetFunction('createTextElement', [params]);
      return null; // 立即返回，不等待结果
    };

    functions['updateTextContent'] = (String elementId, String content) {
      callFireAndForgetFunction('updateTextContent', [elementId, content]);
      return null; // 立即返回，不等待结果
    };

    functions['updateTextSize'] = (String elementId, double size) {
      callFireAndForgetFunction('updateTextSize', [elementId, size]);
      return null; // 立即返回，不等待结果
    };

    // 文本元素查询函数 - 需要等待结果
    functions['getTextElements'] = () async {
      return await callAwaitableFunction('getTextElements', []);
    };

    functions['findTextElementsByContent'] = (String content) async {
      return await callAwaitableFunction('findTextElementsByContent', [
        content,
      ]);
    };

    // say 函数 - 语音合成，不需要等待结果
    // 支持可选参数：language, speechRate, volume, pitch, voice
    functions['say'] =
        (
          dynamic tagFilter,
          String filterType,
          String text, [
          Map<String, dynamic>? options,
        ]) {
          callFireAndForgetFunction('say', [
            tagFilter,
            filterType,
            text,
            options, // 传递可选参数映射
          ]);
          return null; // 立即返回，不等待结果
        };
  }

  /// 注册文件操作函数
  static void _registerFileOperationFunctions(
    Map<String, Function> functions,
    Future<dynamic> Function(String, List<dynamic>) callAwaitableFunction,
    void Function(String, List<dynamic>) callFireAndForgetFunction,
  ) {
    // readjson 是读取类函数，需要等待结果
    functions['readjson'] = (String filename) async {
      return await callAwaitableFunction('readjson', [filename]);
    };

    // writetext 是写入类函数，不需要等待结果
    functions['writetext'] = (String filename, String content) {
      callFireAndForgetFunction('writetext', [filename, content]);
      return null; // 立即返回，不等待结果
    };
  }

  /// 注册便签相关函数
  static void _registerStickyNoteFunctions(
    Map<String, Function> functions,
    Future<dynamic> Function(String, List<dynamic>) callAwaitableFunction,
    void Function(String, List<dynamic>) callFireAndForgetFunction,
  ) {
    // 便签相关函数都是读取类函数，需要等待结果
    functions['getStickyNotes'] = () async {
      return await callAwaitableFunction('getStickyNotes', []);
    };

    functions['getStickyNoteById'] = (String id) async {
      return await callAwaitableFunction('getStickyNoteById', [id]);
    };

    functions['getElementsInStickyNote'] = (String id) async {
      return await callAwaitableFunction('getElementsInStickyNote', [id]);
    };

    functions['filterStickyNotesByTags'] = (List<String> tags) async {
      return await callAwaitableFunction('filterStickyNotesByTags', [tags]);
    };

    functions['filterStickyNoteElementsByTags'] = (List<String> tags) async {
      return await callAwaitableFunction('filterStickyNoteElementsByTags', [
        tags,
      ]);
    };
  }

  /// 注册图例相关函数
  static void _registerLegendFunctions(
    Map<String, Function> functions,
    Future<dynamic> Function(String, List<dynamic>) callAwaitableFunction,
    void Function(String, List<dynamic>) callFireAndForgetFunction,
  ) {
    // 图例查询函数 - 需要等待结果
    functions['getLegendGroups'] = () async {
      return await callAwaitableFunction('getLegendGroups', []);
    };

    functions['getLegendGroupById'] = (String id) async {
      return await callAwaitableFunction('getLegendGroupById', [id]);
    };

    functions['getLegendItems'] = () async {
      return await callAwaitableFunction('getLegendItems', []);
    };

    functions['getLegendItemById'] = (String id) async {
      return await callAwaitableFunction('getLegendItemById', [id]);
    };

    functions['filterLegendGroupsByTags'] = (List<String> tags) async {
      return await callAwaitableFunction('filterLegendGroupsByTags', [tags]);
    };

    functions['filterLegendItemsByTags'] = (List<String> tags) async {
      return await callAwaitableFunction('filterLegendItemsByTags', [tags]);
    };

    // 图例修改函数 - 不需要等待结果
    functions['updateLegendGroup'] = (String id, Map<String, dynamic> params) {
      callFireAndForgetFunction('updateLegendGroup', [id, params]);
      return null; // 立即返回，不等待结果
    };

    functions['updateLegendGroupVisibility'] = (String id, bool visible) {
      callFireAndForgetFunction('updateLegendGroupVisibility', [id, visible]);
      return null; // 立即返回，不等待结果
    };

    functions['updateLegendGroupOpacity'] = (String id, double opacity) {
      callFireAndForgetFunction('updateLegendGroupOpacity', [id, opacity]);
      return null; // 立即返回，不等待结果
    };

    functions['updateLegendItem'] = (String id, Map<String, dynamic> params) {
      callFireAndForgetFunction('updateLegendItem', [id, params]);
      return null; // 立即返回，不等待结果
    };
  }

  /// 注册TTS相关函数
  static void _registerTtsFunctions(
    Map<String, Function> functions,
    Future<dynamic> Function(String, List<dynamic>) callAwaitableFunction,
    void Function(String, List<dynamic>) callFireAndForgetFunction,
  ) {
    // TTS停止函数 - 不需要等待结果
    functions['ttsStop'] = () {
      callFireAndForgetFunction('ttsStop', []);
      return null; // 立即返回，不等待结果
    };

    // TTS查询函数 - 需要等待结果
    functions['ttsGetLanguages'] = () async {
      return await callAwaitableFunction('ttsGetLanguages', []);
    };

    functions['ttsGetVoices'] = () async {
      return await callAwaitableFunction('ttsGetVoices', []);
    };

    functions['ttsIsLanguageAvailable'] = (String language) async {
      return await callAwaitableFunction('ttsIsLanguageAvailable', [language]);
    };

    functions['ttsGetSpeechRateRange'] = () async {
      return await callAwaitableFunction('ttsGetSpeechRateRange', []);
    };
  }

  /// 生成唯一的调用ID
  static String generateCallId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        math.Random().nextInt(1000).toString();
  }
}
