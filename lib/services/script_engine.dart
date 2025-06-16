import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:hetu_script/hetu_script.dart';
import 'package:flutter/material.dart';
import '../models/script_data.dart';
import '../models/map_layer.dart';
import '../models/sticky_note.dart';
import '../services/virtual_file_system/virtual_file_system.dart';
import '../services/virtual_file_system/vfs_protocol.dart';

/// 脚本引擎管理器
class ScriptEngine {
  static final ScriptEngine _instance = ScriptEngine._internal();
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
  Function(List<MapLayer>)? _onLayersChanged;

  /// 当前便签数据的访问器
  List<StickyNote>? _currentStickyNotes;
  Function(List<StickyNote>)? _onStickyNotesChanged;
  /// 当前图例组数据的访问器
  List<LegendGroup>? _currentLegendGroups;
  Function(List<LegendGroup>)? _onLegendGroupsChanged;
  /// VFS 存储服务和地图信息
  VirtualFileSystem? _vfsStorageService;
  String? _currentMapTitle;

  /// 初始化脚本引擎
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
    _currentStickyNotes = null;
    _onStickyNotesChanged = null;
    _currentLegendGroups = null;
    _onLegendGroupsChanged = null;
    _vfsStorageService = null;
    _currentMapTitle = null;
    _hetu = null;

    // 重新初始化以确保外部函数被正确预定义
    await initialize();
  }

  /// 重新初始化脚本引擎（用于地图编辑器重新进入）
  Future<void> reinitialize() async {
    // 保存当前的地图数据访问器
    final currentLayers = _currentLayers;
    final currentOnLayersChanged = _onLayersChanged;
    final currentStickyNotes = _currentStickyNotes;
    final currentOnStickyNotesChanged = _onStickyNotesChanged;
    final currentLegendGroups = _currentLegendGroups;
    final currentOnLegendGroupsChanged = _onLegendGroupsChanged;

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
    if (currentLayers != null &&
        currentOnLayersChanged != null &&
        currentStickyNotes != null &&
        currentOnStickyNotesChanged != null &&
        currentLegendGroups != null &&
        currentOnLegendGroupsChanged != null) {
      setMapDataAccessor(
        currentLayers,
        currentOnLayersChanged,
        currentStickyNotes,
        currentOnStickyNotesChanged,
        currentLegendGroups,
        currentOnLegendGroupsChanged,
      );
    }
  }
  /// 设置地图数据访问器
  void setMapDataAccessor(
    List<MapLayer> layers,
    Function(List<MapLayer>) onLayersChanged,
    List<StickyNote> stickyNotes,
    Function(List<StickyNote>) onStickyNotesChanged,
    List<LegendGroup> legendGroups,
    Function(List<LegendGroup>) onLegendGroupsChanged,
  ) {
    _currentLayers = layers;
    _onLayersChanged = onLayersChanged;
    _currentStickyNotes = stickyNotes;
    _onStickyNotesChanged = onStickyNotesChanged;
    _currentLegendGroups = legendGroups;
    _onLegendGroupsChanged = onLegendGroupsChanged;
  }
  /// 设置 VFS 访问器
  void setVfsAccessor(VirtualFileSystem vfsService, String mapTitle) {
    _vfsStorageService = vfsService;
    _currentMapTitle = mapTitle;
  }

  /// 构建外部函数映射
  Map<String, Function> _buildExternalFunctions() {
    return {
      // 基础函数
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
        return _currentLayers?.map((layer) => _layerToMap(layer)).toList() ??
            [];
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
        return layer?.elements
                .map((element) => _elementToMap(element))
                .toList() ??
            [];
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
      }, // 过滤函数（支持图层和便签中的元素）
      'filterElements': (dynamic filterFunc) {
        final elements = <Map<String, dynamic>>[];

        // 过滤图层中的元素
        if (_currentLayers != null) {
          for (final layer in _currentLayers!) {
            for (final element in layer.elements) {
              final elementMap = _elementToMap(element);
              elementMap['layerId'] = layer.id;
              elementMap['sourceType'] = 'layer';
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

        // 过滤便签中的元素
        if (_currentStickyNotes != null) {
          for (final stickyNote in _currentStickyNotes!) {
            if (!stickyNote.isVisible) continue; // 跳过不可见的便签

            for (final element in stickyNote.elements) {
              final elementMap = _elementToMap(element);
              elementMap['stickyNoteId'] = stickyNote.id;
              elementMap['stickyNoteTitle'] = stickyNote.title;
              elementMap['stickyNoteTags'] = stickyNote.tags ?? [];
              elementMap['sourceType'] = 'stickyNote';
              try {
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
                  final width = (element.points[1].dx - element.points[0].dx)
                      .abs();
                  final height = (element.points[1].dy - element.points[0].dy)
                      .abs();
                  totalArea += width * height;
                }
              }
            }
          }
        }
        return totalArea;
      },

      // 元素修改函数
      'updateElementProperty':
          (String elementId, String property, dynamic value) {
            return _updateElementProperty(elementId, property, value);
          },

      'moveElement': (String elementId, num deltaX, num deltaY) {
        return _moveElement(elementId, deltaX.toDouble(), deltaY.toDouble());
      }, // 动画函数
      'animate':
          (
            String elementId,
            String property,
            dynamic targetValue,
            num duration,
          ) {
            return _animateElement(
              elementId,
              property,
              targetValue,
              duration.toInt(),
            );
          },

      'delay': (num milliseconds) async {
        await Future.delayed(Duration(milliseconds: milliseconds.toInt()));
      },

      // 文本专用函数
      'createTextElement': (String text, num fontSize, num x, num y) {
        return _createTextElement(
          text,
          fontSize.toDouble(),
          x.toDouble(),
          y.toDouble(),
        );
      },

      'updateTextContent': (String elementId, String newText) {
        return _updateElementProperty(elementId, 'text', newText);
      },

      'updateTextSize': (String elementId, num fontSize) {
        return _updateElementProperty(
          elementId,
          'fontSize',
          fontSize.toDouble(),
        );
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
      },      'findTextElementsByContent': (String searchText) {
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

      'say': (dynamic tagFilter, String filterType, String text) {
        if (_currentLayers == null || _onLayersChanged == null) {
          throw Exception('Layers not available');
        }

        var updatedCount = 0;
        final updatedLayers = <MapLayer>[];

        for (final layer in _currentLayers!) {
          final updatedElements = <MapDrawingElement>[];
          var layerModified = false;

          for (final element in layer.elements) {
            // 只处理文本元素
            if (element.type == DrawingElementType.text) {
              final elementTags = element.tags ?? [];
              bool matches = false;

              // 根据过滤类型检查标签匹配
              switch (filterType) {
                case 'contains':
                  // 包含任意指定标签
                  if (tagFilter is String) {
                    matches = elementTags.contains(tagFilter);
                  } else if (tagFilter is List) {
                    matches = tagFilter.any((tag) => elementTags.contains(tag));
                  }
                  break;
                case 'exact':
                  // 标签完全匹配
                  if (tagFilter is List) {
                    final Set<String> filterSet = Set.from(tagFilter);
                    final Set<String> elementSet = Set.from(elementTags);
                    matches = filterSet.length == elementSet.length && 
                             filterSet.every((tag) => elementSet.contains(tag));
                  } else if (tagFilter is String) {
                    matches = elementTags.length == 1 && elementTags[0] == tagFilter;
                  }
                  break;
                case 'excludes':
                  // 不包含任何指定标签
                  if (tagFilter is String) {
                    matches = !elementTags.contains(tagFilter);
                  } else if (tagFilter is List) {
                    matches = !tagFilter.any((tag) => elementTags.contains(tag));
                  }
                  break;
                default:
                  matches = false;
                  break;
              }

              // 如果匹配，更新文本内容
              if (matches) {
                final updatedElement = element.copyWith(text: text);
                updatedElements.add(updatedElement);
                layerModified = true;
                updatedCount = updatedCount + 1;
              } else {
                updatedElements.add(element);
              }
            } else {
              updatedElements.add(element);
            }
          }

          // 如果图层有修改，创建新的图层对象
          if (layerModified) {
            updatedLayers.add(layer.copyWith(elements: updatedElements));
          } else {
            updatedLayers.add(layer);
          }
        }

        // 如果有元素被更新，通知数据变更
        if (updatedCount > 0) {
          _onLayersChanged!(updatedLayers);
        }        return updatedCount;      },

      // 文件操作函数      
      'readjson': (String filePath) async {
        if (_vfsStorageService == null || _currentMapTitle == null) {
          throw Exception('VFS service not available');
        }

        try {
          // 处理类 Unix 路径，自动添加前缀
          String resolvedPath;
          
          // 确保路径是类 Unix 格式且不带协议前缀
          if (filePath.contains('://')) {
            throw Exception('Path should not contain protocol prefix. Use Unix-style path only.');
          }
          
          if (filePath.startsWith('/')) {
            // 绝对路径：拼接在 indexeddb://r6box/fs/ 后面
            resolvedPath = 'indexeddb://r6box/fs$filePath';
          } else {
            // 相对路径：相对于脚本路径 indexeddb://r6box/maps/maptitle.mapdata/scripts/
            resolvedPath = 'indexeddb://r6box/maps/$_currentMapTitle.mapdata/scripts/$filePath';
          }

          // 读取文件内容
          final fileContent = await _vfsStorageService!.readFile(resolvedPath);
          if (fileContent == null) {
            throw Exception('File not found: $resolvedPath');
          }

          // 解析 JSON
          final jsonString = String.fromCharCodes(fileContent.data);
          final jsonData = jsonDecode(jsonString);          return jsonData;
        } catch (e) {
          throw Exception('Failed to read JSON file: $e');
        }
      },      'writetext': (String filePath, String content) async {
        if (_vfsStorageService == null || _currentMapTitle == null) {
          throw Exception('VFS service not available');
        }

        try {
          // 处理类 Unix 路径，自动添加前缀
          String resolvedPath;
          
          // 确保路径是类 Unix 格式且不带协议前缀
          if (filePath.contains('://')) {
            throw Exception('Path should not contain protocol prefix. Use Unix-style path only.');
          }
          
          if (filePath.startsWith('/')) {
            // 绝对路径：拼接在 indexeddb://r6box/fs/ 后面
            resolvedPath = 'indexeddb://r6box/fs$filePath';
          } else {
            // 相对路径：相对于脚本路径 indexeddb://r6box/maps/maptitle.mapdata/scripts/
            resolvedPath = 'indexeddb://r6box/maps/$_currentMapTitle.mapdata/scripts/$filePath';
          }

          // 将内容转换为字节数组
          final contentBytes = Uint8List.fromList(content.codeUnits);
          final fileContent = VfsFileContent(
            data: contentBytes,
            mimeType: 'text/plain',
          );

          // 写入文件
          await _vfsStorageService!.writeFile(resolvedPath, fileContent);
          return true;
        } catch (e) {
          throw Exception('Failed to write text file: $e');
        }
      },

      // 便签相关过滤函数
      'getStickyNotes': () {
        return _currentStickyNotes
                ?.map((note) => _stickyNoteToMap(note))
                .toList() ??
            [];
      },

      'getStickyNoteById': (String id) {
        final note = _currentStickyNotes?.firstWhere(
          (n) => n.id == id,
          orElse: () => throw Exception('Sticky note not found: $id'),
        );
        return note != null ? _stickyNoteToMap(note) : null;
      },

      'getElementsInStickyNote': (String noteId) {
        final note = _currentStickyNotes?.firstWhere(
          (n) => n.id == noteId,
          orElse: () => throw Exception('Sticky note not found: $noteId'),
        );
        return note?.elements
                .map((element) => _elementToMap(element))
                .toList() ??
            [];
      },

      'filterStickyNotesByTags': (dynamic tagFilter, String filterType) {
        final matchingNotes = <Map<String, dynamic>>[];
        if (_currentStickyNotes != null) {
          for (final note in _currentStickyNotes!) {
            if (!note.isVisible) continue;

            final noteTags = note.tags ?? [];
            bool matches = false;

            switch (filterType) {
              case 'contains':
                // 包含指定标签
                if (tagFilter is String) {
                  matches = noteTags.contains(tagFilter);
                } else if (tagFilter is List) {
                  matches = tagFilter.any((tag) => noteTags.contains(tag));
                }
                break;
              case 'exact':
                // 标签完全相同
                if (tagFilter is List) {
                  final Set<String> filterSet = Set.from(tagFilter);
                  final Set<String> noteSet = Set.from(noteTags);
                  matches =
                      filterSet.length == noteSet.length &&
                      filterSet.every((tag) => noteSet.contains(tag));
                }
                break;
              case 'excludes':
                // 不包含指定标签
                if (tagFilter is String) {
                  matches = !noteTags.contains(tagFilter);
                } else if (tagFilter is List) {
                  matches = !tagFilter.any((tag) => noteTags.contains(tag));
                }
                break;
              case 'any':
              default:
                // 任意标签（不过滤）
                matches = true;
                break;
            }

            if (matches) {
              matchingNotes.add(_stickyNoteToMap(note));
            }
          }
        }
        return matchingNotes;
      },

      'filterStickyNoteElementsByTags': (dynamic tagFilter, String filterType) {
        final matchingElements = <Map<String, dynamic>>[];
        if (_currentStickyNotes != null) {
          for (final note in _currentStickyNotes!) {
            if (!note.isVisible) continue;

            for (final element in note.elements) {
              final elementTags = element.tags ?? [];
              bool matches = false;

              switch (filterType) {
                case 'contains':
                  // 包含指定标签
                  if (tagFilter is String) {
                    matches = elementTags.contains(tagFilter);
                  } else if (tagFilter is List) {
                    matches = tagFilter.any((tag) => elementTags.contains(tag));
                  }
                  break;
                case 'exact':
                  // 标签完全相同
                  if (tagFilter is List) {
                    final Set<String> filterSet = Set.from(tagFilter);
                    final Set<String> elementSet = Set.from(elementTags);
                    matches =
                        filterSet.length == elementSet.length &&
                        filterSet.every((tag) => elementSet.contains(tag));
                  }
                  break;
                case 'excludes':
                  // 不包含指定标签
                  if (tagFilter is String) {
                    matches = !elementTags.contains(tagFilter);
                  } else if (tagFilter is List) {
                    matches = !tagFilter.any(
                      (tag) => elementTags.contains(tag),
                    );
                  }
                  break;
                case 'any':
                default:
                  // 任意标签（不过滤）
                  matches = true;
                  break;
              }

              if (matches) {
                final elementMap = _elementToMap(element);
                elementMap['stickyNoteId'] = note.id;
                elementMap['stickyNoteTitle'] = note.title;
                elementMap['stickyNoteTags'] = note.tags ?? [];
                elementMap['sourceType'] = 'stickyNote';
                matchingElements.add(elementMap);
              }
            }
          }
        }
        return matchingElements;
      }, // 图例和图例组相关函数
      'getLegendGroups': () {
        return _currentLegendGroups
                ?.map((group) => _legendGroupToMap(group))
                .toList() ??
            [];
      },

      'getLegendGroupById': (String groupId) {
        final group = _currentLegendGroups?.firstWhere(
          (g) => g.id == groupId,
          orElse: () => throw Exception('Legend group not found: $groupId'),
        );
        return group != null ? _legendGroupToMap(group) : null;
      },

      'updateLegendGroup': (String groupId, Map<String, dynamic> properties) {
        if (_currentLegendGroups == null || _onLegendGroupsChanged == null) {
          throw Exception('Legend groups not available');
        }

        final groupIndex = _currentLegendGroups!.indexWhere(
          (g) => g.id == groupId,
        );
        if (groupIndex == -1) {
          throw Exception('Legend group not found: $groupId');
        }

        final group = _currentLegendGroups![groupIndex];
        final updatedGroup = group.copyWith(
          name: properties['name'] ?? group.name,
          isVisible: properties['isVisible'] ?? group.isVisible,
          opacity: (properties['opacity'] as num?)?.toDouble() ?? group.opacity,
          tags: properties['tags'] != null
              ? List<String>.from(properties['tags'])
              : group.tags,
          updatedAt: DateTime.now(),
        );

        final updatedGroups = List<LegendGroup>.from(_currentLegendGroups!);
        updatedGroups[groupIndex] = updatedGroup;
        _onLegendGroupsChanged!(updatedGroups);
        return true;
      },

      'updateLegendGroupVisibility': (String groupId, bool isVisible) {
        if (_currentLegendGroups == null || _onLegendGroupsChanged == null) {
          throw Exception('Legend groups not available');
        }

        final groupIndex = _currentLegendGroups!.indexWhere(
          (g) => g.id == groupId,
        );
        if (groupIndex == -1) {
          throw Exception('Legend group not found: $groupId');
        }

        final group = _currentLegendGroups![groupIndex];
        final updatedGroup = group.copyWith(
          isVisible: isVisible,
          updatedAt: DateTime.now(),
        );

        final updatedGroups = List<LegendGroup>.from(_currentLegendGroups!);
        updatedGroups[groupIndex] = updatedGroup;
        _onLegendGroupsChanged!(updatedGroups);
        return true;
      },

      'updateLegendGroupOpacity': (String groupId, num opacity) {
        if (_currentLegendGroups == null || _onLegendGroupsChanged == null) {
          throw Exception('Legend groups not available');
        }

        final groupIndex = _currentLegendGroups!.indexWhere(
          (g) => g.id == groupId,
        );
        if (groupIndex == -1) {
          throw Exception('Legend group not found: $groupId');
        }

        final group = _currentLegendGroups![groupIndex];
        final updatedGroup = group.copyWith(
          opacity: opacity.toDouble().clamp(0.0, 1.0),
          updatedAt: DateTime.now(),
        );

        final updatedGroups = List<LegendGroup>.from(_currentLegendGroups!);
        updatedGroups[groupIndex] = updatedGroup;
        _onLegendGroupsChanged!(updatedGroups);
        return true;
      },

      'getLegendItems': (String groupId) {
        final group = _currentLegendGroups?.firstWhere(
          (g) => g.id == groupId,
          orElse: () => throw Exception('Legend group not found: $groupId'),
        );
        return group?.legendItems
                .map((item) => _legendItemToMap(item))
                .toList() ??
            [];
      },

      'getLegendItemById': (String groupId, String itemId) {
        final group = _currentLegendGroups?.firstWhere(
          (g) => g.id == groupId,
          orElse: () => throw Exception('Legend group not found: $groupId'),
        );
        final item = group?.legendItems.firstWhere(
          (i) => i.id == itemId,
          orElse: () => throw Exception('Legend item not found: $itemId'),
        );
        return item != null ? _legendItemToMap(item) : null;
      },

      'updateLegendItem':
          (String groupId, String itemId, Map<String, dynamic> properties) {
            if (_currentLegendGroups == null ||
                _onLegendGroupsChanged == null) {
              throw Exception('Legend groups not available');
            }

            final groupIndex = _currentLegendGroups!.indexWhere(
              (g) => g.id == groupId,
            );
            if (groupIndex == -1) {
              throw Exception('Legend group not found: $groupId');
            }

            final group = _currentLegendGroups![groupIndex];
            final itemIndex = group.legendItems.indexWhere(
              (i) => i.id == itemId,
            );
            if (itemIndex == -1) {
              throw Exception('Legend item not found: $itemId');
            }

            final item = group.legendItems[itemIndex];
            final updatedItem = item.copyWith(
              position: properties['position'] != null
                  ? Offset(
                      properties['position']['x'],
                      properties['position']['y'],
                    )
                  : item.position,
              size: (properties['size'] as num?)?.toDouble() ?? item.size,
              rotation:
                  (properties['rotation'] as num?)?.toDouble() ?? item.rotation,
              opacity:
                  (properties['opacity'] as num?)?.toDouble() ?? item.opacity,
              isVisible: properties['isVisible'] ?? item.isVisible,
              url: properties['url'] ?? item.url,
              tags: properties['tags'] != null
                  ? List<String>.from(properties['tags'])
                  : item.tags,
            );

            final updatedItems = List<LegendItem>.from(group.legendItems);
            updatedItems[itemIndex] = updatedItem;

            final updatedGroup = group.copyWith(
              legendItems: updatedItems,
              updatedAt: DateTime.now(),
            );

            final updatedGroups = List<LegendGroup>.from(_currentLegendGroups!);
            updatedGroups[groupIndex] = updatedGroup;
            _onLegendGroupsChanged!(updatedGroups);
            return true;
          },

      'updateLegendItemPosition':
          (String groupId, String itemId, num x, num y) {
            return _hetu!.invoke(
              'updateLegendItem',
              positionalArgs: [
                groupId,
                itemId,
                {
                  'position': {'x': x.toDouble(), 'y': y.toDouble()},
                },
              ],
            );
          },

      'updateLegendItemRotation':
          (String groupId, String itemId, num rotation) {
            return _hetu!.invoke(
              'updateLegendItem',
              positionalArgs: [
                groupId,
                itemId,
                {'rotation': rotation.toDouble()},
              ],
            );
          },

      'updateLegendItemSize': (String groupId, String itemId, num size) {
        return _hetu!.invoke(
          'updateLegendItem',
          positionalArgs: [
            groupId,
            itemId,
            {'size': size.toDouble()},
          ],
        );
      },

      'updateLegendItemVisibility':
          (String groupId, String itemId, bool isVisible) {
            return _hetu!.invoke(
              'updateLegendItem',
              positionalArgs: [
                groupId,
                itemId,
                {'isVisible': isVisible},
              ],
            );
          },

      'updateLegendItemOpacity': (String groupId, String itemId, num opacity) {
        return _hetu!.invoke(
          'updateLegendItem',
          positionalArgs: [
            groupId,
            itemId,
            {'opacity': opacity.toDouble().clamp(0.0, 1.0)},
          ],
        );
      },

      'filterLegendGroupsByTags': (dynamic tagFilter, String filterType) {
        final matchingGroups = <Map<String, dynamic>>[];
        if (_currentLegendGroups != null) {
          for (final group in _currentLegendGroups!) {
            if (!group.isVisible) continue; // 跳过不可见的图例组

            final groupTags = group.tags ?? [];
            bool matches = false;

            switch (filterType) {
              case 'contains':
                if (tagFilter is String) {
                  matches = groupTags.contains(tagFilter);
                } else if (tagFilter is List) {
                  matches = tagFilter.any((tag) => groupTags.contains(tag));
                }
                break;
              case 'exact':
                if (tagFilter is List) {
                  final Set<String> filterSet = Set.from(tagFilter);
                  final Set<String> groupSet = Set.from(groupTags);
                  matches =
                      filterSet.length == groupSet.length &&
                      filterSet.every((tag) => groupSet.contains(tag));
                }
                break;
              case 'excludes':
                if (tagFilter is String) {
                  matches = !groupTags.contains(tagFilter);
                } else if (tagFilter is List) {
                  matches = !tagFilter.any((tag) => groupTags.contains(tag));
                }
                break;
              case 'any':
              default:
                matches = true;
                break;
            }

            if (matches) {
              matchingGroups.add(_legendGroupToMap(group));
            }
          }
        }
        return matchingGroups;
      },

      'filterLegendItemsByTags': (dynamic tagFilter, String filterType) {
        final matchingItems = <Map<String, dynamic>>[];
        if (_currentLegendGroups != null) {
          for (final group in _currentLegendGroups!) {
            if (!group.isVisible) continue; // 跳过不可见的图例组

            for (final item in group.legendItems) {
              if (!item.isVisible) continue; // 跳过不可见的图例项

              final itemTags = item.tags ?? [];
              bool matches = false;

              switch (filterType) {
                case 'contains':
                  if (tagFilter is String) {
                    matches = itemTags.contains(tagFilter);
                  } else if (tagFilter is List) {
                    matches = tagFilter.any((tag) => itemTags.contains(tag));
                  }
                  break;
                case 'exact':
                  if (tagFilter is List) {
                    final Set<String> filterSet = Set.from(tagFilter);
                    final Set<String> itemSet = Set.from(itemTags);
                    matches =
                        filterSet.length == itemSet.length &&
                        filterSet.every((tag) => itemSet.contains(tag));
                  }
                  break;
                case 'excludes':
                  if (tagFilter is String) {
                    matches = !itemTags.contains(tagFilter);
                  } else if (tagFilter is List) {
                    matches = !tagFilter.any((tag) => itemTags.contains(tag));
                  }
                  break;
                case 'any':
                default:
                  matches = true;
                  break;
              }

              if (matches) {
                final itemMap = _legendItemToMap(item);
                itemMap['groupId'] = group.id;
                itemMap['groupName'] = group.name;
                itemMap['groupTags'] = group.tags ?? [];
                itemMap['sourceType'] = 'legendItem';
                matchingItems.add(itemMap);
              }
            }
          }
        }
        return matchingItems;
      },

      'findLegendGroupsByName': (String namePattern) {
        final matchingGroups = <Map<String, dynamic>>[];
        if (_currentLegendGroups != null) {
          for (final group in _currentLegendGroups!) {
            if (group.name.toLowerCase().contains(namePattern.toLowerCase())) {
              matchingGroups.add(_legendGroupToMap(group));
            }
          }
        }
        return matchingGroups;
      },

      'getVisibleLegendGroups': () {
        return _currentLegendGroups
                ?.where((group) => group.isVisible)
                .map((group) => _legendGroupToMap(group))
                .toList() ??
            [];
      },      'getVisibleLegendItems': (String groupId) {
        final group = _currentLegendGroups?.firstWhere(
          (g) => g.id == groupId,
          orElse: () => throw Exception('Legend group not found: $groupId'),
        );
        return group?.legendItems
                .where((item) => item.isVisible)
                .map((item) => _legendItemToMap(item))
                .toList() ??
            [];
      },

      // 图层管理函数
      'updateLayer': (String layerId, Map<String, dynamic> properties) {
        if (_currentLayers == null || _onLayersChanged == null) {
          throw Exception('Layers not available');
        }
        
        final layerIndex = _currentLayers!.indexWhere((l) => l.id == layerId);
        if (layerIndex == -1) {
          throw Exception('Layer not found: $layerId');
        }
        
        final layer = _currentLayers![layerIndex];
        final updatedLayer = layer.copyWith(
          name: properties['name'] ?? layer.name,
          isVisible: properties['isVisible'] ?? layer.isVisible,
          opacity: (properties['opacity'] as num?)?.toDouble() ?? layer.opacity,
          order: (properties['order'] as int?) ?? layer.order,
          tags: properties['tags'] != null ? List<String>.from(properties['tags']) : layer.tags,
        );
        
        final updatedLayers = List<MapLayer>.from(_currentLayers!);
        updatedLayers[layerIndex] = updatedLayer;
        _onLayersChanged!(updatedLayers);
        return true;
      },

      'updateLayerVisibility': (String layerId, bool isVisible) {
        if (_currentLayers == null || _onLayersChanged == null) {
          throw Exception('Layers not available');
        }
        
        final layerIndex = _currentLayers!.indexWhere((l) => l.id == layerId);
        if (layerIndex == -1) {
          throw Exception('Layer not found: $layerId');
        }
        
        final layer = _currentLayers![layerIndex];
        final updatedLayer = layer.copyWith(isVisible: isVisible);
        
        final updatedLayers = List<MapLayer>.from(_currentLayers!);
        updatedLayers[layerIndex] = updatedLayer;
        _onLayersChanged!(updatedLayers);
        return true;
      },

      'updateLayerOpacity': (String layerId, num opacity) {
        if (_currentLayers == null || _onLayersChanged == null) {
          throw Exception('Layers not available');
        }
        
        final layerIndex = _currentLayers!.indexWhere((l) => l.id == layerId);
        if (layerIndex == -1) {
          throw Exception('Layer not found: $layerId');
        }
        
        final layer = _currentLayers![layerIndex];
        final updatedLayer = layer.copyWith(opacity: opacity.toDouble().clamp(0.0, 1.0));
        
        final updatedLayers = List<MapLayer>.from(_currentLayers!);
        updatedLayers[layerIndex] = updatedLayer;
        _onLayersChanged!(updatedLayers);
        return true;
      },

      'updateLayerName': (String layerId, String name) {
        if (_currentLayers == null || _onLayersChanged == null) {
          throw Exception('Layers not available');
        }
        
        final layerIndex = _currentLayers!.indexWhere((l) => l.id == layerId);
        if (layerIndex == -1) {
          throw Exception('Layer not found: $layerId');
        }
        
        final layer = _currentLayers![layerIndex];
        final updatedLayer = layer.copyWith(name: name);
        
        final updatedLayers = List<MapLayer>.from(_currentLayers!);
        updatedLayers[layerIndex] = updatedLayer;
        _onLayersChanged!(updatedLayers);
        return true;
      },

      'updateLayerOrder': (String layerId, int order) {
        if (_currentLayers == null || _onLayersChanged == null) {
          throw Exception('Layers not available');
        }
        
        final layerIndex = _currentLayers!.indexWhere((l) => l.id == layerId);
        if (layerIndex == -1) {
          throw Exception('Layer not found: $layerId');
        }
        
        final layer = _currentLayers![layerIndex];
        final updatedLayer = layer.copyWith(order: order);
        
        final updatedLayers = List<MapLayer>.from(_currentLayers!);
        updatedLayers[layerIndex] = updatedLayer;
        _onLayersChanged!(updatedLayers);
        return true;
      },

      'getVisibleLayers': () {
        return _currentLayers?.where((layer) => layer.isVisible).map((layer) => _layerToMap(layer)).toList() ?? [];
      },

      'filterLayersByTags': (dynamic tagFilter, String filterType) {
        final matchingLayers = <Map<String, dynamic>>[];
        if (_currentLayers != null) {
          for (final layer in _currentLayers!) {
            final layerTags = layer.tags ?? [];
            bool matches = false;
            
            switch (filterType) {
              case 'contains':
                if (tagFilter is String) {
                  matches = layerTags.contains(tagFilter);
                } else if (tagFilter is List) {
                  matches = tagFilter.any((tag) => layerTags.contains(tag));
                }
                break;
              case 'exact':
                if (tagFilter is List) {
                  final Set<String> filterSet = Set.from(tagFilter);
                  final Set<String> layerSet = Set.from(layerTags);
                  matches = filterSet.length == layerSet.length && 
                           filterSet.every((tag) => layerSet.contains(tag));
                }
                break;
              case 'excludes':
                if (tagFilter is String) {
                  matches = !layerTags.contains(tagFilter);
                } else if (tagFilter is List) {
                  matches = !tagFilter.any((tag) => layerTags.contains(tag));
                }
                break;
              case 'any':
              default:
                matches = true;
                break;
            }
            
            if (matches) {
              matchingLayers.add(_layerToMap(layer));
            }
          }
        }
        return matchingLayers;
      },

      // 便签管理函数
      'updateStickyNote': (String noteId, Map<String, dynamic> properties) {
        if (_currentStickyNotes == null || _onStickyNotesChanged == null) {
          throw Exception('Sticky notes not available');
        }
        
        final noteIndex = _currentStickyNotes!.indexWhere((n) => n.id == noteId);
        if (noteIndex == -1) {
          throw Exception('Sticky note not found: $noteId');
        }
        
        final note = _currentStickyNotes![noteIndex];
        final updatedNote = note.copyWith(
          title: properties['title'] ?? note.title,
          content: properties['content'] ?? note.content,
          position: properties['position'] != null 
            ? Offset(properties['position']['x'], properties['position']['y'])
            : note.position,
          size: properties['size'] != null 
            ? Size(properties['size']['width'], properties['size']['height'])
            : note.size,
          opacity: (properties['opacity'] as num?)?.toDouble() ?? note.opacity,
          isVisible: properties['isVisible'] ?? note.isVisible,
          isCollapsed: properties['isCollapsed'] ?? note.isCollapsed,
          backgroundColor: properties['backgroundColor'] != null 
            ? Color(properties['backgroundColor']) 
            : note.backgroundColor,
          titleBarColor: properties['titleBarColor'] != null 
            ? Color(properties['titleBarColor']) 
            : note.titleBarColor,
          textColor: properties['textColor'] != null 
            ? Color(properties['textColor']) 
            : note.textColor,
          tags: properties['tags'] != null ? List<String>.from(properties['tags']) : note.tags,
          updatedAt: DateTime.now(),
        );
        
        final updatedNotes = List<StickyNote>.from(_currentStickyNotes!);
        updatedNotes[noteIndex] = updatedNote;
        _onStickyNotesChanged!(updatedNotes);
        return true;
      },

      'updateStickyNoteVisibility': (String noteId, bool isVisible) {
        return _hetu!.invoke('updateStickyNote', positionalArgs: [
          noteId, 
          {'isVisible': isVisible}
        ]);
      },

      'updateStickyNoteOpacity': (String noteId, num opacity) {
        return _hetu!.invoke('updateStickyNote', positionalArgs: [
          noteId, 
          {'opacity': opacity.toDouble().clamp(0.0, 1.0)}
        ]);
      },

      'updateStickyNotePosition': (String noteId, num x, num y) {
        return _hetu!.invoke('updateStickyNote', positionalArgs: [
          noteId, 
          {'position': {'x': x.toDouble(), 'y': y.toDouble()}}
        ]);
      },

      'updateStickyNoteSize': (String noteId, num width, num height) {
        return _hetu!.invoke('updateStickyNote', positionalArgs: [
          noteId, 
          {'size': {'width': width.toDouble(), 'height': height.toDouble()}}
        ]);
      },

      'updateStickyNoteColors': (String noteId, int backgroundColor, int titleBarColor, int textColor) {
        return _hetu!.invoke('updateStickyNote', positionalArgs: [
          noteId, 
          {
            'backgroundColor': backgroundColor,
            'titleBarColor': titleBarColor,
            'textColor': textColor
          }
        ]);
      },

      'updateStickyNoteBackgroundColor': (String noteId, int color) {
        return _hetu!.invoke('updateStickyNote', positionalArgs: [
          noteId, 
          {'backgroundColor': color}
        ]);
      },

      'updateStickyNoteTitleBarColor': (String noteId, int color) {
        return _hetu!.invoke('updateStickyNote', positionalArgs: [
          noteId, 
          {'titleBarColor': color}
        ]);
      },

      'updateStickyNoteTextColor': (String noteId, int color) {
        return _hetu!.invoke('updateStickyNote', positionalArgs: [
          noteId, 
          {'textColor': color}
        ]);
      },

      'updateStickyNoteTitle': (String noteId, String title) {
        return _hetu!.invoke('updateStickyNote', positionalArgs: [
          noteId, 
          {'title': title}
        ]);
      },

      'updateStickyNoteContent': (String noteId, String content) {
        return _hetu!.invoke('updateStickyNote', positionalArgs: [
          noteId, 
          {'content': content}
        ]);
      },

      'collapseStickyNote': (String noteId, bool isCollapsed) {
        return _hetu!.invoke('updateStickyNote', positionalArgs: [
          noteId, 
          {'isCollapsed': isCollapsed}
        ]);
      },

      'getVisibleStickyNotes': () {
        return _currentStickyNotes?.where((note) => note.isVisible).map((note) => _stickyNoteToMap(note)).toList() ?? [];
      },
    };
  }

  /// 执行脚本
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
      'tags': element.tags ?? [],
      'points': element.points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
    };
  }

  /// 将便签转换为脚本可用的Map
  Map<String, dynamic> _stickyNoteToMap(StickyNote note) {
    return {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'position': {'x': note.position.dx, 'y': note.position.dy},
      'size': {'width': note.size.width, 'height': note.size.height},
      'opacity': note.opacity,
      'isVisible': note.isVisible,
      'isCollapsed': note.isCollapsed,
      'zIndex': note.zIndex,
      'backgroundColor': note.backgroundColor.value,
      'titleBarColor': note.titleBarColor.value,
      'textColor': note.textColor.value,
      'tags': note.tags ?? [],
      'elements': note.elements.map((e) => _elementToMap(e)).toList(),
      'elementsCount': note.elements.length,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt.toIso8601String(),
    };
  }

  /// 更新元素属性
  bool _updateElementProperty(
    String elementId,
    String property,
    dynamic value,
  ) {
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
  MapDrawingElement _updateElement(
    MapDrawingElement element,
    String property,
    dynamic value,
  ) {
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
  Future<void> _animateElement(
    String elementId,
    String property,
    dynamic targetValue,
    int durationMs,
  ) async {
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

// 图层管理函数
external fun updateLayer(layerId, properties);
external fun updateLayerVisibility(layerId, isVisible);
external fun updateLayerOpacity(layerId, opacity);
external fun updateLayerName(layerId, name);
external fun updateLayerOrder(layerId, order);
external fun getVisibleLayers();
external fun filterLayersByTags(tagFilter, filterType);

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
external fun say(tagFilter, filterType, text);

// 文件操作函数
external fun readjson(filePath);
external fun writetext(filePath, content);

// 便签相关函数
external fun getStickyNotes();
external fun getStickyNoteById(id);
external fun getElementsInStickyNote(noteId);
external fun filterStickyNotesByTags(tagFilter, filterType);
external fun filterStickyNoteElementsByTags(tagFilter, filterType);

// 便签管理函数
external fun updateStickyNote(noteId, properties);
external fun updateStickyNoteVisibility(noteId, isVisible);
external fun updateStickyNoteOpacity(noteId, opacity);
external fun updateStickyNotePosition(noteId, x, y);
external fun updateStickyNoteSize(noteId, width, height);
external fun updateStickyNoteColors(noteId, backgroundColor, titleBarColor, textColor);
external fun updateStickyNoteBackgroundColor(noteId, color);
external fun updateStickyNoteTitleBarColor(noteId, color);
external fun updateStickyNoteTextColor(noteId, color);
external fun updateStickyNoteTitle(noteId, title);
external fun updateStickyNoteContent(noteId, content);
external fun collapseStickyNote(noteId, isCollapsed);
external fun getVisibleStickyNotes();

// 图例和图例组相关函数
external fun getLegendGroups();
external fun getLegendGroupById(groupId);
external fun updateLegendGroup(groupId, properties);
external fun updateLegendGroupVisibility(groupId, isVisible);
external fun updateLegendGroupOpacity(groupId, opacity);
external fun getLegendItems(groupId);
external fun getLegendItemById(groupId, itemId);
external fun updateLegendItem(groupId, itemId, properties);
external fun updateLegendItemPosition(groupId, itemId, x, y);
external fun updateLegendItemRotation(groupId, itemId, rotation);
external fun updateLegendItemSize(groupId, itemId, size);
external fun updateLegendItemVisibility(groupId, itemId, isVisible);
external fun updateLegendItemOpacity(groupId, itemId, opacity);
external fun filterLegendGroupsByTags(tagFilter, filterType);
external fun filterLegendItemsByTags(tagFilter, filterType);
external fun findLegendGroupsByName(namePattern);
external fun getVisibleLegendGroups();
external fun getVisibleLegendItems(groupId);
''';

    try {
      // 执行外部函数声明
      _hetu!.eval(externalDeclarations);
    } catch (e) {
      debugPrint('预定义外部函数时出错: $e');
    }
  }

  /// 将图例组转换为脚本可用的Map
  Map<String, dynamic> _legendGroupToMap(LegendGroup group) {
    return {
      'id': group.id,
      'name': group.name,
      'isVisible': group.isVisible,
      'opacity': group.opacity,
      'tags': group.tags ?? [],
      'legendItems': group.legendItems
          .map((item) => _legendItemToMap(item))
          .toList(),
      'legendItemsCount': group.legendItems.length,
      'visibleItemsCount': group.legendItems
          .where((item) => item.isVisible)
          .length,
      'createdAt': group.createdAt.toIso8601String(),
      'updatedAt': group.updatedAt.toIso8601String(),
    };
  }

  /// 将图例项转换为脚本可用的Map
  Map<String, dynamic> _legendItemToMap(LegendItem item) {
    return {
      'id': item.id,
      'legendId': item.legendId,
      'position': {'x': item.position.dx, 'y': item.position.dy},
      'size': item.size,
      'rotation': item.rotation,
      'opacity': item.opacity,
      'isVisible': item.isVisible,
      'url': item.url,
      'tags': item.tags ?? [],
      'createdAt': item.createdAt.toIso8601String(),
    };
  }
}
