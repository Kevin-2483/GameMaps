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

  /// 当前地图图层数据的访问器
  List<MapLayer>? _currentLayers;
  Function(List<MapLayer>)? _onLayersChanged;  /// 初始化脚本引擎
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _hetu = Hetu();
    // 在 hetu_script 0.4.2 中，外部函数需要在 init 方法中提供
    _hetu!.init(externalFunctions: _buildExternalFunctions());
    _isInitialized = true;
  }

  /// 重置脚本引擎（用于测试）
  void reset() {
    _isInitialized = false;
    _runningTimers.clear();
    _animationControllers.clear();
    _currentLayers = null;
    _onLayersChanged = null;
    _hetu = null;
  }

  /// 设置地图数据访问器
  void setMapDataAccessor(
    List<MapLayer> layers,
    Function(List<MapLayer>) onLayersChanged,
  ) {
    _currentLayers = layers;
    _onLayersChanged = onLayersChanged;
  }
  /// 构建外部函数映射
  Map<String, Function> _buildExternalFunctions() {
    return {      // 基础函数
      'print': ([dynamic message = '']) => debugPrint(message?.toString() ?? ''),

      'log': ([dynamic message = '']) => debugPrint('[Script] ${message?.toString() ?? ''}'),

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
      },

      // 动画函数
      'animate': (String elementId, String property, dynamic targetValue, num duration) {
        return _animateElement(elementId, property, targetValue, duration.toInt());
      },

      'delay': (num milliseconds) async {
        await Future.delayed(Duration(milliseconds: milliseconds.toInt()));
      },
    };
  }
  /// 执行脚本
  Future<ScriptExecutionResult> executeScript(ScriptData script) async {
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
      return ScriptExecutionResult(
        success: true,
        result: result,
        executionTime: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return ScriptExecutionResult(
        success: false,
        error: e.toString(),
        executionTime: stopwatch.elapsed,
      );
    }
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
  }

  /// 更新单个元素的属性
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
      default:
        return element;
    }
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
}
