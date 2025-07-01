import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../data/map_data_bloc.dart';
import '../../data/map_data_state.dart';
import '../../data/map_data_event.dart';
import '../../models/map_layer.dart';
import '../../utils/script_data_converter.dart';
import '../tts_service.dart';

/// 外部函数处理器
/// 统一处理所有脚本执行器的外部函数调用实现
class ExternalFunctionHandler {
  final MapDataBloc _mapDataBloc;
  final List<String> _executionLogs = [];
  final String? _scriptId; // 脚本标识符

  // TTS 服务实例
  late final TtsService _ttsService;

  ExternalFunctionHandler({required MapDataBloc mapDataBloc, String? scriptId})
    : _mapDataBloc = mapDataBloc,
      _scriptId = scriptId {
    _ttsService = TtsService();
    // 初始化 TTS 服务
    _initializeTtsService();
  }

  /// 初始化 TTS 服务
  void _initializeTtsService() async {
    try {
      await _ttsService.initialize();
      debugPrint('TTS 服务初始化成功');
    } catch (e) {
      debugPrint('TTS 服务初始化失败: $e');
    }
  }

  /// 处理语音合成函数
  /// 参数: text, [可选参数映射]
  void handleSay(String text, [Map<String, dynamic>? options]) async {
    try {
      debugPrint('处理语音合成: text="$text"');

      if (text.isEmpty) {
        debugPrint('语音合成: 文本为空，跳过');
        return;
      }

      // 解析可选参数
      String? language;
      double? speechRate;
      double? volume;
      double? pitch;
      Map<String, String>? voice;

      if (options != null) {
        language = options['language'] as String?;
        speechRate = options['speechRate'] as double?;
        volume = options['volume'] as double?;
        pitch = options['pitch'] as double?;
        voice = options['voice'] as Map<String, String>?;
      } // 调用 TTS 服务进行语音合成
      await _ttsService.speak(
        text,
        language: language,
        speechRate: speechRate,
        volume: volume,
        pitch: pitch,
        voice: voice,
        sourceId: _scriptId ?? 'script-unknown',
      );

      // 记录执行日志
      String logMessage = '语音合成: "$text"';
      if (language != null) logMessage += ', language: $language';
      if (speechRate != null) logMessage += ', rate: $speechRate';
      if (volume != null) logMessage += ', volume: $volume';
      if (pitch != null) logMessage += ', pitch: $pitch';
      if (voice != null) logMessage += ', voice: $voice';

      addExecutionLog(logMessage);
    } catch (e) {
      debugPrint('语音合成失败: $e');
      addExecutionLog('语音合成失败: $e');
    }
  }

  /// 停止当前脚本的所有TTS播放
  Future<void> stopScriptTts() async {
    try {
      if (_scriptId != null) {
        await _ttsService.stopBySource(_scriptId);
        addExecutionLog('已停止脚本 $_scriptId 的所有TTS播放');
      }
    } catch (e) {
      debugPrint('停止脚本TTS失败: $e');
      addExecutionLog('停止脚本TTS失败: $e');
    }
  }

  /// 处理TTS停止函数
  void handleTtsStop() async {
    await stopScriptTts();
  }

  /// 处理TTS获取语言列表函数
  dynamic handleTtsGetLanguages() async {
    try {
      await _ttsService.initialize();
      final languages = _ttsService.availableLanguages;
      addExecutionLog('获取TTS语言列表: ${languages?.length ?? 0} 种语言');
      return languages;
    } catch (e) {
      debugPrint('获取TTS语言列表失败: $e');
      addExecutionLog('获取TTS语言列表失败: $e');
      return [];
    }
  }

  /// 处理TTS获取语音列表函数
  dynamic handleTtsGetVoices() async {
    try {
      await _ttsService.initialize();
      final voices = _ttsService.availableVoices;
      addExecutionLog('获取TTS语音列表: ${voices?.length ?? 0} 种语音');
      return voices;
    } catch (e) {
      debugPrint('获取TTS语音列表失败: $e');
      addExecutionLog('获取TTS语音列表失败: $e');
      return [];
    }
  }

  /// 处理TTS检查语言可用性函数
  dynamic handleTtsIsLanguageAvailable(String language) async {
    try {
      final isAvailable = await _ttsService.isLanguageAvailable(language);
      addExecutionLog('检查语言 $language 可用性: $isAvailable');
      return isAvailable;
    } catch (e) {
      debugPrint('检查语言可用性失败: $e');
      addExecutionLog('检查语言可用性失败: $e');
      return false;
    }
  }

  /// 处理TTS获取语音速度范围函数
  dynamic handleTtsGetSpeechRateRange() async {
    try {
      final range = await _ttsService.getSpeechRateRange();
      addExecutionLog('获取TTS语音速度范围: $range');
      return range;
    } catch (e) {
      debugPrint('获取语音速度范围失败: $e');
      addExecutionLog('获取语音速度范围失败: $e');
      return null;
    }
  }

  /// 处理日志函数
  dynamic handleLog(dynamic message) {
    final logMessage = message?.toString() ?? '';
    _executionLogs.add(logMessage);
    debugPrint('[Script Log] $logMessage');
    return logMessage;
  }

  /// 处理数学函数
  dynamic handleSin(num x) => math.sin(x.toDouble());
  dynamic handleCos(num x) => math.cos(x.toDouble());
  dynamic handleTan(num x) => math.tan(x.toDouble());
  dynamic handleSqrt(num x) => math.sqrt(x.toDouble());
  dynamic handlePow(num x, num y) => math.pow(x.toDouble(), y.toDouble());
  dynamic handleAbs(num x) => x.abs();
  dynamic handleRandom() => math.Random().nextDouble();

  /// 处理获取图层函数
  List<Map<String, dynamic>> handleGetLayers() {
    return _getCurrentLayers()
        .map((layer) => ScriptDataConverter.layerToMap(layer))
        .toList();
  }

  /// 处理根据ID获取图层
  Map<String, dynamic>? handleGetLayerById(String layerId) {
    final layer = _getLayerById(layerId);
    return layer != null ? ScriptDataConverter.layerToMap(layer) : null;
  }

  /// 处理获取图层中的元素
  List<Map<String, dynamic>> handleGetElementsInLayer(String layerId) {
    final layer = _getLayerById(layerId);
    if (layer == null) return [];

    return layer.elements
        .map((element) => ScriptDataConverter.elementToMap(element))
        .toList();
  }

  /// 处理获取便签中的元素
  List<Map<String, dynamic>> handleGetElementsInStickyNote(String noteId) {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      for (final note in state.mapItem.stickyNotes) {
        if (note.id == noteId) {
          return note.elements
              .map((element) => ScriptDataConverter.elementToMap(element))
              .toList();
        }
      }
    }
    return [];
  }

  /// 处理获取所有元素函数
  List<Map<String, dynamic>> handleGetAllElements() {
    final layers = _getCurrentLayers();
    final allElements = <Map<String, dynamic>>[];
  
    // 获取图层中的元素
    for (final layer in layers) {
      for (final element in layer.elements) {
        final elementMap = ScriptDataConverter.elementToMap(element);
        elementMap['layerId'] = layer.id; // 标记来源图层
        allElements.add(elementMap);
      }
    }
  
    // 获取便签中的元素
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      for (final note in state.mapItem.stickyNotes) {
        for (final element in note.elements) {
          final elementMap = ScriptDataConverter.elementToMap(element);
          elementMap['stickyNoteId'] = note.id; // 标记来源便签
          allElements.add(elementMap);
        }
      }
    }
  
    return allElements;
  }


  /// 处理获取便签
  List<Map<String, dynamic>> handleGetStickyNotes() {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      return state.mapItem.stickyNotes
          .map((note) => ScriptDataConverter.stickyNoteToMap(note))
          .toList();
    }
    return [];
  }

  /// 处理根据ID获取便签
  Map<String, dynamic>? handleGetStickyNoteById(String noteId) {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      for (final note in state.mapItem.stickyNotes) {
        if (note.id == noteId) {
          return ScriptDataConverter.stickyNoteToMap(note);
        }
      }
    }
    return null;
  }

  /// 处理获取图例组
  List<Map<String, dynamic>> handleGetLegendGroups() {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      return state.legendGroups
          .map((group) => ScriptDataConverter.legendGroupToMap(group))
          .toList();
    }
    return [];
  }

  /// 处理根据ID获取图例组
  Map<String, dynamic>? handleGetLegendGroupById(String groupId) {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      for (final group in state.legendGroups) {
        if (group.id == groupId) {
          return ScriptDataConverter.legendGroupToMap(group);
        }
      }
    }
    return null;
  }

  /// 处理读取JSON函数
  Future<Map<String, dynamic>?> handleReadJson(String path) async {
    debugPrint('读取JSON文件: $path');
    // TODO: 实现VFS文件读取
    return null;
  }

  /// 处理写入文本函数
  Future<void> handleWriteText(String path, String content) async {
    debugPrint('写入文本文件: $path, 内容长度: ${content.length}');
    // TODO: 实现VFS文件写入
  }

  // 辅助方法
  List<MapLayer> _getCurrentLayers() {
    if (_mapDataBloc.state is MapDataLoaded) {
      return (_mapDataBloc.state as MapDataLoaded).layers;
    }
    return [];
  }

  MapLayer? _getLayerById(String layerId) {
    if (_mapDataBloc.state is MapDataLoaded) {
      return (_mapDataBloc.state as MapDataLoaded).getLayerById(layerId);
    }
    return null;
  }

  /// 获取执行日志
  List<String> getExecutionLogs() => List.from(_executionLogs);

  /// 清空执行日志
  void clearExecutionLogs() => _executionLogs.clear();

  /// 添加执行日志
  void addExecutionLog(String message) {
    _executionLogs.add(message);
    debugPrint('[Script] $message');
  }

  /// 处理根据内容查找文本元素
  List<Map<String, dynamic>> handleFindTextElementsByContent(String content) {
    final layers = _getCurrentLayers();
    final textElements = <Map<String, dynamic>>[];

    // 搜索图层中的文本元素
    for (final layer in layers) {
      for (final element in layer.elements) {
        if (element.type == DrawingElementType.text &&
            element.text != null &&
            element.text!.contains(content)) {
          final elementMap = ScriptDataConverter.elementToMap(element);
          elementMap['layerId'] = layer.id; // 标记来源图层
          textElements.add(elementMap);
        }
      }
    }

    // 搜索便签中的文本元素
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      for (final note in state.mapItem.stickyNotes) {
        for (final element in note.elements) {
          if (element.type == DrawingElementType.text &&
              element.text != null &&
              element.text!.contains(content)) {
            final elementMap = ScriptDataConverter.elementToMap(element);
            elementMap['stickyNoteId'] = note.id; // 标记来源便签
            textElements.add(elementMap);
          }
        }
      }
    }

    return textElements;
  }

  /// 处理获取所有图例项
  List<Map<String, dynamic>> handleGetLegendItems() {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      final allItems = <Map<String, dynamic>>[];

      for (final group in state.legendGroups) {
        for (final item in group.legendItems) {
          final itemMap = ScriptDataConverter.legendItemToMap(item);
          itemMap['groupId'] = group.id; // 添加组ID信息
          allItems.add(itemMap);
        }
      }

      return allItems;
    }
    return [];
  }

  /// 处理根据ID获取图例项
  Map<String, dynamic>? handleGetLegendItemById(String itemId) {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;

      for (final group in state.legendGroups) {
        for (final item in group.legendItems) {
          if (item.id == itemId) {
            final itemMap = ScriptDataConverter.legendItemToMap(item);
            itemMap['groupId'] = group.id; // 添加组ID信息
            return itemMap;
          }
        }
      }
    }
    return null;
  }

  /// 处理根据标签筛选便签
  List<Map<String, dynamic>> handleFilterStickyNotesByTags(
    List<String> tags, [
    String mode = 'contains',
  ]) {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      return state.mapItem.stickyNotes
          .where((note) => _matchTags(note.tags, tags, mode))
          .map((note) => ScriptDataConverter.stickyNoteToMap(note))
          .toList();
    }
    return [];
  }

  /// 处理根据标签筛选便签中的元素
  List<Map<String, dynamic>> handleFilterStickyNoteElementsByTags(
    List<String> tags, [
    String mode = 'contains',
  ]) {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      final filteredElements = <Map<String, dynamic>>[];

      for (final note in state.mapItem.stickyNotes) {
        for (final element in note.elements) {
          if (_matchTags(element.tags, tags, mode)) {
            final elementMap = ScriptDataConverter.elementToMap(element);
            elementMap['stickyNoteId'] = note.id; // 标记来源便签
            filteredElements.add(elementMap);
          }
        }
      }

      return filteredElements;
    }
    return [];
  }

  /// 处理根据标签筛选图例组
  List<Map<String, dynamic>> handleFilterLegendGroupsByTags(
    List<String> tags, [
    String mode = 'contains',
  ]) {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      return state.legendGroups
          .where((group) => _matchTags(group.tags, tags, mode))
          .map((group) => ScriptDataConverter.legendGroupToMap(group))
          .toList();
    }
    return [];
  }

  /// 处理根据标签筛选图例项
  List<Map<String, dynamic>> handleFilterLegendItemsByTags(
    List<String> tags, [
    String mode = 'contains',
  ]) {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      final filteredItems = <Map<String, dynamic>>[];

      for (final group in state.legendGroups) {
        for (final item in group.legendItems) {
          if (_matchTags(item.tags, tags, mode)) {
            final itemMap = ScriptDataConverter.legendItemToMap(item);
            itemMap['groupId'] = group.id; // 添加组ID信息
            filteredItems.add(itemMap);
          }
        }
      }

      return filteredItems;
    }
    return [];
  }

  /// 处理根据标签筛选所有元素（包括画布中的和便签中的）
  List<Map<String, dynamic>> handleFilterElementsByTags(
    List<String> tags, [
    String mode = 'contains',
  ]) {
    final filteredElements = <Map<String, dynamic>>[];

    // 筛选画布图层中的元素
    final layers = _getCurrentLayers();
    for (final layer in layers) {
      for (final element in layer.elements) {
        if (_matchTags(element.tags, tags, mode)) {
          final elementMap = ScriptDataConverter.elementToMap(element);
          elementMap['layerId'] = layer.id; // 标记来源图层
          filteredElements.add(elementMap);
        }
      }
    }

    // 筛选便签中的元素
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      for (final note in state.mapItem.stickyNotes) {
        for (final element in note.elements) {
          if (_matchTags(element.tags, tags, mode)) {
            final elementMap = ScriptDataConverter.elementToMap(element);
            elementMap['stickyNoteId'] = note.id; // 标记来源便签
            filteredElements.add(elementMap);
          }
        }
      }
    }

    return filteredElements;
  }

  /// 处理根据标签筛选便签中的元素（独立函数）
  List<Map<String, dynamic>> handleFilterElementsInStickyNotesByTags(
    List<String> tags, [
    String mode = 'contains',
  ]) {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      final filteredElements = <Map<String, dynamic>>[];

      for (final note in state.mapItem.stickyNotes) {
        for (final element in note.elements) {
          if (_matchTags(element.tags, tags, mode)) {
            final elementMap = ScriptDataConverter.elementToMap(element);
            elementMap['stickyNoteId'] = note.id; // 标记来源便签
            filteredElements.add(elementMap);
          }
        }
      }

      return filteredElements;
    }
    return [];
  }

  /// 处理根据标签筛选指定图例组中的图例项
  List<Map<String, dynamic>> handleFilterLegendItemsInGroupByTags(
    String groupId,
    List<String> tags, [
    String mode = 'contains',
  ]) {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;

      for (final group in state.legendGroups) {
        if (group.id == groupId) {
          return group.legendItems
              .where((item) => _matchTags(item.tags, tags, mode))
              .map((item) {
                final itemMap = ScriptDataConverter.legendItemToMap(item);
                itemMap['groupId'] = group.id; // 添加组ID信息
                return itemMap;
              })
              .toList();
        }
      }
    }
    return [];
  }

  /// 标签匹配逻辑
  /// mode: 'contains' (包含), 'equals' (等于), 'excludes' (排除)
  bool _matchTags(
    List<String>? itemTags,
    List<String> filterTags,
    String mode,
  ) {
    if (itemTags == null || itemTags.isEmpty) {
      return mode == 'excludes'; // 如果没有标签，只有排除模式匹配
    }

    switch (mode) {
      case 'contains':
        // 包含模式：元素标签包含任何一个筛选标签
        return filterTags.any((tag) => itemTags.contains(tag));
      case 'equals':
        // 等于模式：元素标签完全匹配筛选标签
        if (itemTags.length != filterTags.length) return false;
        return filterTags.every((tag) => itemTags.contains(tag));
      case 'excludes':
        // 排除模式：元素标签不包含任何筛选标签
        return !filterTags.any((tag) => itemTags.contains(tag));
      default:
        return false;
    }
  }

  /// 处理获取文本元素
  List<Map<String, dynamic>> handleGetTextElements() {
    final layers = _getCurrentLayers();
    final textElements = <Map<String, dynamic>>[];

    for (final layer in layers) {
      for (final element in layer.elements) {
        if (element.type == DrawingElementType.text) {
          final elementMap = ScriptDataConverter.elementToMap(element);
          elementMap['layerId'] = layer.id; // 标记来源图层
          textElements.add(elementMap);
        }
      }
    }

    // 还要包括便签中的文本元素
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      for (final note in state.mapItem.stickyNotes) {
        for (final element in note.elements) {
          if (element.type == DrawingElementType.text) {
            final elementMap = ScriptDataConverter.elementToMap(element);
            elementMap['stickyNoteId'] = note.id; // 标记来源便签
            textElements.add(elementMap);
          }
        }
      }
    }

    return textElements;
  }

    /// 处理更新元素属性
  void handleUpdateElementProperty(String elementId, String property, dynamic value) {
    if (_mapDataBloc.state is! MapDataLoaded) return;
    
    final state = _mapDataBloc.state as MapDataLoaded;
    
    // 在图层中查找元素
    for (final layer in state.layers) {
      final elementIndex = layer.elements.indexWhere((e) => e.id == elementId);
      if (elementIndex != -1) {
        final updatedElement = _updateElementProperty(layer.elements[elementIndex], property, value);
        _mapDataBloc.add(UpdateLayer(layer: layer.copyWith(
          elements: List.from(layer.elements)..[elementIndex] = updatedElement,
        )));
        addExecutionLog('更新图层 ${layer.id} 中元素 $elementId 的属性 $property');
        return;
      }
    }
    
    // 在便签中查找元素
    for (final note in state.mapItem.stickyNotes) {
      final elementIndex = note.elements.indexWhere((e) => e.id == elementId);
      if (elementIndex != -1) {
        final updatedElement = _updateElementProperty(note.elements[elementIndex], property, value);
        final updatedNote = note.copyWith(
          elements: List.from(note.elements)..[elementIndex] = updatedElement,
        );
        _mapDataBloc.add(UpdateStickyNote(stickyNote: updatedNote));
        addExecutionLog('更新便签 ${note.id} 中元素 $elementId 的属性 $property');
        return;
      }
    }
    
    addExecutionLog('未找到元素 $elementId');
  }

  /// 处理移动元素
  void handleMoveElement(String elementId, double deltaX, double deltaY) {
    if (_mapDataBloc.state is! MapDataLoaded) return;
    
    final state = _mapDataBloc.state as MapDataLoaded;
    
    // 在图层中查找元素
    for (final layer in state.layers) {
      final elementIndex = layer.elements.indexWhere((e) => e.id == elementId);
      if (elementIndex != -1) {
        final element = layer.elements[elementIndex];
        // MapDrawingElement 使用 points 数组，需要移动所有点
        final newPoints = element.points.map((point) => 
          Offset(point.dx + deltaX, point.dy + deltaY)
        ).toList();
        final updatedElement = element.copyWith(points: newPoints);
        
        _mapDataBloc.add(UpdateLayer(layer: layer.copyWith(
          elements: List.from(layer.elements)..[elementIndex] = updatedElement,
        )));
        addExecutionLog('移动图层 ${layer.id} 中元素 $elementId 偏移 ($deltaX, $deltaY)');
        return;
      }
    }
    
    // 在便签中查找元素
    for (final note in state.mapItem.stickyNotes) {
      final elementIndex = note.elements.indexWhere((e) => e.id == elementId);
      if (elementIndex != -1) {
        final element = note.elements[elementIndex];
        // MapDrawingElement 使用 points 数组，需要移动所有点
        final newPoints = element.points.map((point) => 
          Offset(point.dx + deltaX, point.dy + deltaY)
        ).toList();
        final updatedElement = element.copyWith(points: newPoints);
        
        final updatedNote = note.copyWith(
          elements: List.from(note.elements)..[elementIndex] = updatedElement,
        );
        _mapDataBloc.add(UpdateStickyNote(stickyNote: updatedNote));
        addExecutionLog('移动便签 ${note.id} 中元素 $elementId 偏移 ($deltaX, $deltaY)');
        return;
      }
    }
    
    addExecutionLog('未找到元素 $elementId');
  }

  /// 处理创建文本元素
  void handleCreateTextElement(String text, double x, double y, [Map<String, dynamic>? options]) {
    final textElement = MapDrawingElement(
      id: 'text_${DateTime.now().millisecondsSinceEpoch}',
      type: DrawingElementType.text,
      points: [Offset(x, y)], // 文本元素只需要一个位置点
      text: text,
      fontSize: options?['fontSize']?.toDouble() ?? 16.0,
      color: options?['color'] != null 
          ? Color(options!['color'] as int)
          : Colors.black,
      tags: options?['tags']?.cast<String>(),
      createdAt: DateTime.now(),
    );
    
    // 默认添加到第一个图层
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      if (state.layers.isNotEmpty) {
        final firstLayer = state.layers.first;
        final updatedLayer = firstLayer.copyWith(
          elements: [...firstLayer.elements, textElement],
        );
        _mapDataBloc.add(UpdateLayer(layer: updatedLayer));
        addExecutionLog('创建文本元素: "$text" 在位置 ($x, $y)');
      }
    }
  }

  /// 处理更新文本内容
  void handleUpdateTextContent(String elementId, String newText) {
    handleUpdateElementProperty(elementId, 'text', newText);
    addExecutionLog('更新元素 $elementId 的文本内容为: "$newText"');
  }

  /// 处理更新文本大小
  void handleUpdateTextSize(String elementId, double newSize) {
    handleUpdateElementProperty(elementId, 'fontSize', newSize);
    addExecutionLog('更新元素 $elementId 的文本大小为: $newSize');
  }

  /// 处理更新图例组
  void handleUpdateLegendGroup(String groupId, Map<String, dynamic> updates) {
    if (_mapDataBloc.state is! MapDataLoaded) return;
    
    final state = _mapDataBloc.state as MapDataLoaded;
    final groupIndex = state.legendGroups.indexWhere((g) => g.id == groupId);
    
    if (groupIndex == -1) {
      addExecutionLog('未找到图例组 $groupId');
      return;
    }
    
    final group = state.legendGroups[groupIndex];
    final updatedGroup = group.copyWith(
      name: updates['name'] ?? group.name,
      isVisible: updates['isVisible'] ?? group.isVisible,
      opacity: updates['opacity']?.toDouble() ?? group.opacity,
      tags: updates['tags']?.cast<String>() ?? group.tags,
    );
    
    _mapDataBloc.add(UpdateLegendGroup(legendGroup: updatedGroup));
    addExecutionLog('更新图例组 $groupId');
  }

  /// 处理更新图例组可见性
  void handleUpdateLegendGroupVisibility(String groupId, bool isVisible) {
    handleUpdateLegendGroup(groupId, {'isVisible': isVisible});
    addExecutionLog('设置图例组 $groupId 可见性为: $isVisible');
  }

  /// 处理更新图例组透明度
  void handleUpdateLegendGroupOpacity(String groupId, double opacity) {
    handleUpdateLegendGroup(groupId, {'opacity': opacity});
    addExecutionLog('设置图例组 $groupId 透明度为: $opacity');
  }

  /// 处理更新图例项
  void handleUpdateLegendItem(String itemId, Map<String, dynamic> updates) {
    if (_mapDataBloc.state is! MapDataLoaded) return;
    
    final state = _mapDataBloc.state as MapDataLoaded;
    
    for (final group in state.legendGroups) {
      final itemIndex = group.legendItems.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final item = group.legendItems[itemIndex];
        final updatedItem = item.copyWith(
          legendId: updates['legendId'] ?? item.legendId,
          position: updates['position'] != null
              ? Offset(updates['position']['x']?.toDouble() ?? item.position.dx,
                       updates['position']['y']?.toDouble() ?? item.position.dy)
              : item.position,
          size: updates['size']?.toDouble() ?? item.size,
          rotation: updates['rotation']?.toDouble() ?? item.rotation,
          opacity: updates['opacity']?.toDouble() ?? item.opacity,
          isVisible: updates['isVisible'] ?? item.isVisible,
          url: updates['url'] ?? item.url,
          tags: updates['tags']?.cast<String>() ?? item.tags,
        );
        
        final updatedGroup = group.copyWith(
          legendItems: List.from(group.legendItems)..[itemIndex] = updatedItem,
        );
        
        _mapDataBloc.add(UpdateLegendGroup(legendGroup: updatedGroup));
        addExecutionLog('更新图例项 $itemId');
        return;
      }
    }
    
    addExecutionLog('未找到图例项 $itemId');
  }

  /// 辅助方法：更新元素属性
  MapDrawingElement _updateElementProperty(MapDrawingElement element, String property, dynamic value) {
    switch (property) {
      case 'text':
        return element.copyWith(text: value as String?);
      case 'fontSize':
        return element.copyWith(fontSize: (value as num).toDouble());
      case 'color':
        return element.copyWith(color: value is int ? Color(value) : value as Color);
      case 'strokeWidth':
        return element.copyWith(strokeWidth: (value as num).toDouble());
      case 'density':
        return element.copyWith(density: (value as num).toDouble());
      case 'rotation':
        return element.copyWith(rotation: (value as num).toDouble());
      case 'curvature':
        return element.copyWith(curvature: (value as num).toDouble());
      case 'zIndex':
        return element.copyWith(zIndex: (value as int));
      case 'tags':
        return element.copyWith(tags: (value as List).cast<String>());
      default:
        addExecutionLog('不支持的属性: $property');
        return element;
    }
  }
}