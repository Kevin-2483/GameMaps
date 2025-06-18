import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../data/map_data_bloc.dart';
import '../../data/map_data_state.dart';
import '../../models/map_layer.dart';
import '../../utils/script_data_converter.dart';

/// 外部函数处理器
/// 统一处理所有脚本执行器的外部函数调用实现
class ExternalFunctionHandler {
  final MapDataBloc _mapDataBloc;
  final List<String> _executionLogs = [];

  ExternalFunctionHandler({required MapDataBloc mapDataBloc})
    : _mapDataBloc = mapDataBloc;

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

  /// 处理获取所有元素函数
  List<Map<String, dynamic>> handleGetAllElements() {
    final layers = _getCurrentLayers();
    final allElements = <Map<String, dynamic>>[];

    for (final layer in layers) {
      for (final element in layer.elements) {
        allElements.add(ScriptDataConverter.elementToMap(element));
      }
    }

    return allElements;
  }

  /// 处理统计元素
  int handleCountElements([String? type]) {
    final layers = _getCurrentLayers();
    int count = 0;

    for (final layer in layers) {
      for (final element in layer.elements) {
        if (type == null || element.type.name == type) {
          count++;
        }
      }
    }

    return count;
  }

  /// 处理计算总面积
  double handleCalculateTotalArea() {
    final layers = _getCurrentLayers();
    double totalArea = 0.0;

    for (final layer in layers) {
      for (final element in layer.elements) {
        if (element.type == DrawingElementType.rectangle ||
            element.type == DrawingElementType.hollowRectangle) {
          if (element.points.length >= 2) {
            final width = (element.points[1].dx - element.points[0].dx).abs();
            final height = (element.points[1].dy - element.points[0].dy).abs();
            totalArea += width * height;
          }
        }
      }
    }

    return totalArea;
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
}
