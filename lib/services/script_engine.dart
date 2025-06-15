import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:hetu_script/hetu_script.dart';
import 'package:flutter/material.dart';
import '../models/script_data.dart';
import '../models/map_layer.dart';

/// 脚本引擎管理器
class ScriptEngine {  static final ScriptEngine _instance = ScriptEngine._internal();
  factory ScriptEngine() => _instance;
  ScriptEngine._internal();
  Hetu? _hetu;
  final Map<String, Timer> _runningTimers = {};
  final Map<String, StreamController> _animationControllers = {};
  bool _isInitialized = false;
  
  /// 脚本执行日志
  final List<String> _executionLogs = [];

  /// 当前地图图层数据的访问器
  List<MapLayer>? _currentLayers;
  Function(List<MapLayer>)? _onLayersChanged;  /// 初始化脚本引擎
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _hetu = Hetu();
    // 在 hetu_script 0.4.2 中，外部函数需要在 init 方法中提供
    _hetu!.init(externalFunctions: _buildExternalFunctions());
    
    // 预定义外部函数声明，避免用户重复声明
    await _predefineExternalFunctions();
    
    _isInitialized = true;
  }
  /// 重置脚本引擎（用于测试）
  Future<void> reset() async {
    _isInitialized = false;
    _runningTimers.clear();
    _animationControllers.clear();
    _currentLayers = null;
    _onLayersChanged = null;
    _hetu = null;
    
    // 重新初始化以确保外部函数被正确预定义
    await initialize();
  }

  /// 重新初始化脚本引擎（用于地图编辑器重新进入）
  Future<void> reinitialize() async {
    // 保存当前的地图数据访问器
    final currentLayers = _currentLayers;
    final currentOnLayersChanged = _onLayersChanged;
    
    // 停止所有运行中的任务
    for (final timer in _runningTimers.values) {
      timer.cancel();
    }
    _runningTimers.clear();
    
    for (final controller in _animationControllers.values) {
      controller.close();
    }
    _animationControllers.clear();
    
    // 重置初始化状态
    _isInitialized = false;
    _hetu = null;
    
    // 重新初始化
    await initialize();
    
    // 恢复地图数据访问器
    if (currentLayers != null && currentOnLayersChanged != null) {
      setMapDataAccessor(currentLayers, currentOnLayersChanged);
    }
  }

  /// 设置地图数据访问器
  void setMapDataAccessor(
    List<MapLayer> layers,
    Function(List<MapLayer>) onLayersChanged,
  ) {
    _currentLayers = layers;
    _onLayersChanged = onLayersChanged;
  }  /// 构建外部函数映射
  Map<String, Function> _buildExternalFunctions() {
    return {      // 基础函数
      'print': ([dynamic message = '']) {
        final msg = message?.toString() ?? '';
        _executionLogs.add('[print] $msg');
        debugPrint(msg);
        return msg;
      },

      'log': ([dynamic message = '']) {
        final msg = message?.toString() ?? '';
        final logMsg = '[Script] $msg';
        _executionLogs.add(logMsg);
        debugPrint(logMsg);
        return msg;
      },

      // 数学函数
      'sin': (num x) => sin(x),
      'cos': (num x) => cos(x),
      'tan': (num x) => tan(x),
      'sqrt': (num x) => sqrt(x),
      'pow': (num x, num y) => pow(x, y),
      'abs': (num x) => x.abs(),
      'random': () => Random().nextDouble(),

      // 绘图元素访问函数
      'getLayers': () {
        return _currentLayers?.map((layer) => _layerToMap(layer)).toList() ?? [];
      },

      'getLayerById': (String id) {
        final layer = _currentLayers?.firstWhere(
          (l) => l.id == id,
          orElse: () => throw Exception('Layer not found: $id'),
        );
        return layer != null ? _layerToMap(layer) : null;
      },

      'getElementsInLayer': (String layerId) {
        final layer = _currentLayers?.firstWhere(
          (l) => l.id == layerId,
          orElse: () => throw Exception('Layer not found: $layerId'),
        );
        return layer?.elements.map((element) => _elementToMap(element)).toList() ?? [];
      },

      'getAllElements': () {
        final elements = <Map<String, dynamic>>[];
        if (_currentLayers != null) {
          for (final layer in _currentLayers!) {
            for (final element in layer.elements) {
              final elementMap = _elementToMap(element);
              elementMap['layerId'] = layer.id;
              elements.add(elementMap);
            }
          }
        }
        return elements;
      },      // 过滤函数
      'filterElements': (dynamic filterFunc) {
        final elements = <Map<String, dynamic>>[];
        if (_currentLayers != null) {
          for (final layer in _currentLayers!) {
            for (final element in layer.elements) {
              final elementMap = _elementToMap(element);
              elementMap['layerId'] = layer.id;
              try {
                // 在 hetu_script 0.4.2 中，使用正确的调用方式
                final result = filterFunc.call(positionalArgs: [elementMap]);
                if (result == true) {
                  elements.add(elementMap);
                }
              } catch (e) {
                debugPrint('Filter function error: $e');
              }
            }
          }
        }
        return elements;
      },

      // 统计函数
      'countElements': ([String? typeFilter]) {
        int count = 0;
        
        if (_currentLayers != null) {
          for (final layer in _currentLayers!) {
            for (final element in layer.elements) {
              if (typeFilter == null || element.type.name == typeFilter) {
                count++;
              }
            }
          }
        }
        return count;
      },

      'calculateTotalArea': () {
        double totalArea = 0.0;
        
        if (_currentLayers != null) {
          for (final layer in _currentLayers!) {
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
        }
        return totalArea;
      },

      // 元素修改函数
      'updateElementProperty': (String elementId, String property, dynamic value) {
        return _updateElementProperty(elementId, property, value);
      },

      'moveElement': (String elementId, num deltaX, num deltaY) {
        return _moveElement(elementId, deltaX.toDouble(), deltaY.toDouble());
      },      // 动画函数
      'animate': (String elementId, String property, dynamic targetValue, num duration) {
        return _animateElement(elementId, property, targetValue, duration.toInt());
      },

      'delay': (num milliseconds) async {
        await Future.delayed(Duration(milliseconds: milliseconds.toInt()));
      },

      // 文本专用函数
      'createTextElement': (String text, num fontSize, num x, num y) {
        return _createTextElement(text, fontSize.toDouble(), x.toDouble(), y.toDouble());
      },

      'updateTextContent': (String elementId, String newText) {
        return _updateElementProperty(elementId, 'text', newText);
      },

      'updateTextSize': (String elementId, num fontSize) {
        return _updateElementProperty(elementId, 'fontSize', fontSize.toDouble());
      },

      'getTextElements': () {
        final textElements = <Map<String, dynamic>>[];
        if (_currentLayers != null) {
          for (final layer in _currentLayers!) {
            for (final element in layer.elements) {
              if (element.type == DrawingElementType.text) {
                final elementMap = _elementToMap(element);
                elementMap['layerId'] = layer.id;
                textElements.add(elementMap);
              }
            }
          }
        }
        return textElements;
      },

      'findTextElementsByContent': (String searchText) {
        final matchingElements = <Map<String, dynamic>>[];
        if (_currentLayers != null) {
          for (final layer in _currentLayers!) {
            for (final element in layer.elements) {
              if (element.type == DrawingElementType.text && 
                  element.text != null && 
                  element.text!.contains(searchText)) {
                final elementMap = _elementToMap(element);
                elementMap['layerId'] = layer.id;
                matchingElements.add(elementMap);
              }
            }
          }
        }
        return matchingElements;
      },
    };
  }  /// 执行脚本
  Future<ScriptExecutionResult> executeScript(ScriptData script) async {
    // 清空执行日志
    _executionLogs.clear();
    
    final stopwatch = Stopwatch()..start();
    
    try {
      if (_hetu == null) {
        throw Exception('Script engine not initialized');
      }
      
      // 设置脚本参数
      for (final entry in script.parameters.entries) {
        _hetu!.define(entry.key, entry.value);
      }

      // 执行脚本
      final result = _hetu!.eval(script.content);
      
      stopwatch.stop();
      
      // 在结果中包含执行日志
      final executionResult = ScriptExecutionResult(
        success: true,
        result: result,
        executionTime: stopwatch.elapsed,
      );
      
      // 打印执行日志到控制台
      if (_executionLogs.isNotEmpty) {
        debugPrint('=== 脚本执行日志 ===');
        for (final log in _executionLogs) {
          debugPrint(log);
        }
        debugPrint('=== 执行完成 ===');
      }
      
      return executionResult;
    } catch (e) {
      stopwatch.stop();
      
      // 错误时也打印日志
      if (_executionLogs.isNotEmpty) {
        debugPrint('=== 脚本执行日志（错误前）===');
        for (final log in _executionLogs) {
          debugPrint(log);
        }
        debugPrint('=== 执行错误 ===');
      }
      debugPrint('脚本执行错误: $e');
      
      return ScriptExecutionResult(
        success: false,
        error: e.toString(),
        executionTime: stopwatch.elapsed,
      );
    }
  }
  
  /// 获取最近的执行日志
  List<String> getExecutionLogs() {
    return List.from(_executionLogs);
  }

  /// 停止脚本执行
  void stopScript(String scriptId) {
    // 停止定时器
    _runningTimers[scriptId]?.cancel();
    _runningTimers.remove(scriptId);
    
    // 停止动画
    _animationControllers[scriptId]?.close();
    _animationControllers.remove(scriptId);
  }

  /// 将图层转换为脚本可用的Map
  Map<String, dynamic> _layerToMap(MapLayer layer) {
    return {
      'id': layer.id,
      'name': layer.name,
      'order': layer.order,
      'isVisible': layer.isVisible,
      'opacity': layer.opacity,
      'elementCount': layer.elements.length,
      'elements': layer.elements.map((e) => _elementToMap(e)).toList(),
    };
  }

  /// 将绘图元素转换为脚本可用的Map
  Map<String, dynamic> _elementToMap(MapDrawingElement element) {
    return {
      'id': element.id,
      'type': element.type.name,
      'color': element.color.value,
      'strokeWidth': element.strokeWidth,
      'density': element.density,
      'rotation': element.rotation,
      'curvature': element.curvature,
      'zIndex': element.zIndex,
      'text': element.text,
      'fontSize': element.fontSize,
      'points': element.points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
    };
  }

  /// 更新元素属性
  bool _updateElementProperty(String elementId, String property, dynamic value) {
    if (_currentLayers == null || _onLayersChanged == null) return false;

    final updatedLayers = <MapLayer>[];
    bool updated = false;

    for (final layer in _currentLayers!) {
      final updatedElements = <MapDrawingElement>[];
      
      for (final element in layer.elements) {
        if (element.id == elementId) {
          updatedElements.add(_updateElement(element, property, value));
          updated = true;
        } else {
          updatedElements.add(element);
        }
      }
      
      updatedLayers.add(layer.copyWith(elements: updatedElements));
    }

    if (updated) {
      _currentLayers = updatedLayers;
      _onLayersChanged!(updatedLayers);
    }

    return updated;
  }

  /// 移动元素
  bool _moveElement(String elementId, double deltaX, double deltaY) {
    if (_currentLayers == null || _onLayersChanged == null) return false;

    final updatedLayers = <MapLayer>[];
    bool updated = false;

    for (final layer in _currentLayers!) {
      final updatedElements = <MapDrawingElement>[];
      
      for (final element in layer.elements) {
        if (element.id == elementId) {
          final newPoints = element.points
              .map((p) => Offset(p.dx + deltaX, p.dy + deltaY))
              .toList();
          updatedElements.add(element.copyWith(points: newPoints));
          updated = true;
        } else {
          updatedElements.add(element);
        }
      }
      
      updatedLayers.add(layer.copyWith(elements: updatedElements));
    }

    if (updated) {
      _currentLayers = updatedLayers;
      _onLayersChanged!(updatedLayers);
    }

    return updated;
  }  /// 更新单个元素的属性
  MapDrawingElement _updateElement(MapDrawingElement element, String property, dynamic value) {
    switch (property) {
      case 'color':
        return element.copyWith(color: Color(value as int));
      case 'strokeWidth':
        return element.copyWith(strokeWidth: (value as num).toDouble());
      case 'density':
        return element.copyWith(density: (value as num).toDouble());
      case 'rotation':
        return element.copyWith(rotation: (value as num).toDouble());
      case 'curvature':
        return element.copyWith(curvature: (value as num).toDouble());
      case 'zIndex':
        return element.copyWith(zIndex: value as int);
      case 'opacity':
        final color = element.color;
        final newColor = color.withOpacity((value as num).toDouble());
        return element.copyWith(color: newColor);
      case 'text':
        return element.copyWith(text: value?.toString());
      case 'fontSize':
        return element.copyWith(fontSize: (value as num).toDouble());
      default:
        return element;
    }
  }

  /// 创建文本元素
  bool _createTextElement(String text, double fontSize, double x, double y) {
    if (_currentLayers == null || _onLayersChanged == null) return false;

    // 找到第一个可用的图层来添加文本元素
    if (_currentLayers!.isEmpty) return false;

    final targetLayer = _currentLayers!.first;
    
    // 计算新元素的 z 值
    final maxZIndex = targetLayer.elements.isEmpty
        ? 0
        : targetLayer.elements
              .map((e) => e.zIndex)
              .reduce((a, b) => a > b ? a : b);

    // 创建文本元素
    final textElement = MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: DrawingElementType.text,
      points: [Offset(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0))], // 确保坐标在有效范围内
      color: Colors.black, // 默认黑色
      strokeWidth: 1.0,
      density: 1.0,
      zIndex: maxZIndex + 1,
      text: text,
      fontSize: fontSize,
      createdAt: DateTime.now(),
    );

    // 更新图层
    final updatedLayers = _currentLayers!.map((layer) {
      if (layer.id == targetLayer.id) {
        return layer.copyWith(
          elements: [...layer.elements, textElement],
          updatedAt: DateTime.now(),
        );
      }
      return layer;
    }).toList();

    _currentLayers = updatedLayers;
    _onLayersChanged!(updatedLayers);
    
    return true;
  }

  /// 动画化元素属性
  Future<void> _animateElement(String elementId, String property, dynamic targetValue, int durationMs) async {
    // 这里实现基础的动画逻辑
    final steps = (durationMs / 16).round(); // 60fps
    final stepDelay = Duration(milliseconds: 16);
    
    for (int i = 0; i <= steps; i++) {
      // 根据progress计算当前值并更新元素
      await Future.delayed(stepDelay);
      // TODO: 实现具体的动画逻辑
    }
  }

  /// 释放资源
  void dispose() {
    for (final timer in _runningTimers.values) {
      timer.cancel();
    }
    _runningTimers.clear();
    
    for (final controller in _animationControllers.values) {
      controller.close();
    }
    _animationControllers.clear();
  }

  /// 预定义外部函数声明，避免用户重复声明
  Future<void> _predefineExternalFunctions() async {
    final externalDeclarations = '''
// 基础函数
external fun log(message);
external fun print(message);

// 数学函数
external fun sin(x);
external fun cos(x);
external fun tan(x);
external fun sqrt(x);
external fun pow(x, y);
external fun abs(x);
external fun random();

// 绘图元素访问函数
external fun getLayers();
external fun getLayerById(id);
external fun getElementsInLayer(layerId);
external fun getAllElements();

// 过滤和查找函数
external fun filterElements(filterFunc);
external fun countElements(typeFilter);
external fun calculateTotalArea();

// 元素修改函数
external fun updateElementProperty(elementId, property, value);
external fun moveElement(elementId, deltaX, deltaY);

// 动画函数
external fun animate(elementId, property, targetValue, duration);
external fun delay(milliseconds);

// 文本专用函数
external fun createTextElement(text, fontSize, x, y);
external fun updateTextContent(elementId, newText);
external fun updateTextSize(elementId, fontSize);
external fun getTextElements();
external fun findTextElementsByContent(searchText);
''';

    try {
      // 执行外部函数声明
      _hetu!.eval(externalDeclarations);
    } catch (e) {
      debugPrint('预定义外部函数时出错: $e');
    }
  }
}
