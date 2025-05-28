import 'package:flutter/material.dart';
import '../../models/map_item.dart';
import '../../models/map_layer.dart';
import '../../services/map_database_service.dart';
import '../../services/legend_database_service.dart';
import '../../l10n/app_localizations.dart';
import '../../models/legend_item.dart' as legend_db;
import 'widgets/map_canvas.dart';
import 'widgets/layer_panel.dart';
import 'widgets/legend_panel.dart';
import 'widgets/drawing_toolbar.dart';
import 'widgets/layer_legend_binding_drawer.dart';
import 'widgets/legend_group_management_drawer.dart';
import 'widgets/z_index_inspector.dart';

class MapEditorPage extends StatefulWidget {
  final MapItem? mapItem; // 可选的预加载地图数据
  final int? mapId; // 地图ID，用于按需加载
  final bool isPreviewMode;

  const MapEditorPage({
    super.key,
    this.mapItem,
    this.mapId,
    this.isPreviewMode = false,
  }) : assert(mapItem != null || mapId != null, 'Either mapItem or mapId must be provided');

  @override
  State<MapEditorPage> createState() => _MapEditorPageState();
}

class _MapEditorPageState extends State<MapEditorPage> {
  MapItem? _currentMap; // 可能为空，需要加载
  final MapDatabaseService _mapDatabaseService = MapDatabaseService();
  final LegendDatabaseService _legendDatabaseService = LegendDatabaseService();
  List<legend_db.LegendItem> _availableLegends = [];
  bool _isLoading = false;
  // 当前选中的图层和绘制工具
  MapLayer? _selectedLayer;  DrawingElementType? _selectedDrawingTool;  Color _selectedColor = Colors.black;
  double _selectedStrokeWidth = 2.0;
  double _selectedDensity = 3.0; // 默认密度为3.0
  double _selectedCurvature = 0.0; // 默认弧度为0.0 (无弧度)
  TriangleCutType _selectedTriangleCut = TriangleCutType.none; // 默认无三角形切割
  String? _selectedElementId; // 当前选中的元素ID
  // 工具栏折叠状态
  bool _isDrawingToolbarCollapsed = false;
  bool _isLayerPanelCollapsed = false;
  bool _isLegendPanelCollapsed = false;

  // 自动关闭开关状态
  bool _isDrawingToolbarAutoClose = true;
  bool _isLayerPanelAutoClose = true;
  bool _isLegendPanelAutoClose = true;

  // 悬浮工具栏状态（用于窄屏）
  bool _isFloatingToolbarVisible = false; // 透明度预览状态
  final Map<String, double> _previewOpacityValues = {};  // 绘制工具预览状态
  DrawingElementType? _previewDrawingTool;
  Color? _previewColor;
  double? _previewStrokeWidth;
  double? _previewDensity;
  double? _previewCurvature; // 弧度预览状态
  TriangleCutType? _previewTriangleCut; // 三角形切割预览状态
  // 覆盖层状态
  bool _isLayerLegendBindingDrawerOpen = false;
  bool _isLegendGroupManagementDrawerOpen = false;
  bool _isZIndexInspectorOpen = false;
  MapLayer? _currentLayerForBinding;
  List<LegendGroup>? _allLegendGroupsForBinding;
  LegendGroup? _currentLegendGroupForManagement;

  // 撤销/重做历史记录管理
  final List<MapItem> _undoHistory = [];
  final List<MapItem> _redoHistory = [];
  static const int _maxUndoHistory = 20; // 最大撤销历史记录数量  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);
    
    try {
      // 如果已有 mapItem，直接使用；否则通过 mapId 从数据库加载
      if (widget.mapItem != null) {
        _currentMap = widget.mapItem!;
      } else if (widget.mapId != null) {
        final loadedMap = await _mapDatabaseService.getMapById(widget.mapId!);
        if (loadedMap == null) {
          throw Exception('未找到ID为 ${widget.mapId} 的地图');
        }
        _currentMap = loadedMap;
      } else {
        throw Exception('mapItem 和 mapId 都为空');
      }

      // 加载可用图例
      await _loadAvailableLegends();

      // 如果没有图层，创建一个默认图层
      if (_currentMap!.layers.isEmpty) {
        _addDefaultLayer();
      } else {
        _selectedLayer = _currentMap!.layers.first;
      }

      // 保存初始状态到撤销历史
      _saveToUndoHistory();
      
    } catch (e) {
      _showErrorSnackBar('初始化地图失败: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  // 撤销历史记录管理方法
  void _saveToUndoHistory() {
    if (_currentMap == null) return;
    // 保存当前状态到撤销历史
    _undoHistory.add(_currentMap!.copyWith());

    // 清空重做历史，因为新的操作会使重做历史失效
    _redoHistory.clear();

    // 限制历史记录数量
    if (_undoHistory.length > _maxUndoHistory) {
      _undoHistory.removeAt(0);
    }
  }

  void _undo() {
    if (_undoHistory.isEmpty || _currentMap == null) return;

    setState(() {
      // 将当前状态保存到重做历史
      _redoHistory.add(_currentMap!.copyWith());

      // 限制重做历史记录数量
      if (_redoHistory.length > _maxUndoHistory) {
        _redoHistory.removeAt(0);
      }

      _currentMap = _undoHistory.removeLast();

      // 更新选中图层，确保引用正确
      if (_selectedLayer != null) {
        final selectedLayerId = _selectedLayer!.id;
        _selectedLayer = _currentMap!.layers
            .where((layer) => layer.id == selectedLayerId)
            .firstOrNull;

        // 如果原选中图层不存在，选择第一个图层
        if (_selectedLayer == null && _currentMap!.layers.isNotEmpty) {
          _selectedLayer = _currentMap!.layers.first;
        }
      }
    });
  }

  void _redo() {
    if (_redoHistory.isEmpty || _currentMap == null) return;

    setState(() {
      // 将当前状态保存到撤销历史
      _undoHistory.add(_currentMap!.copyWith());

      // 限制撤销历史记录数量
      if (_undoHistory.length > _maxUndoHistory) {
        _undoHistory.removeAt(0);
      }

      _currentMap = _redoHistory.removeLast();

      // 更新选中图层，确保引用正确
      if (_selectedLayer != null) {
        final selectedLayerId = _selectedLayer!.id;
        _selectedLayer = _currentMap!.layers
            .where((layer) => layer.id == selectedLayerId)
            .firstOrNull;

        // 如果原选中图层不存在，选择第一个图层
        if (_selectedLayer == null && _currentMap!.layers.isNotEmpty) {
          _selectedLayer = _currentMap!.layers.first;
        }
      }
    });
  }

  bool get _canUndo => _undoHistory.isNotEmpty;
  bool get _canRedo => _redoHistory.isNotEmpty;

  // 删除指定图层中的绘制元素
  void _deleteElement(String elementId) {
    if (widget.isPreviewMode || _selectedLayer == null) return;

    // 找到要删除的元素
    final elementToDelete = _selectedLayer!.elements
        .where((element) => element.id == elementId)
        .firstOrNull;

    if (elementToDelete == null) return;

    // 保存当前状态到撤销历史
    _saveToUndoHistory();

    // 创建新的元素列表，排除要删除的元素
    final updatedElements = _selectedLayer!.elements
        .where((element) => element.id != elementId)
        .toList();

    // 更新图层
    final updatedLayer = _selectedLayer!.copyWith(
      elements: updatedElements,
      updatedAt: DateTime.now(),
    );

    _updateLayer(updatedLayer);

    // 显示删除成功消息
    _showSuccessSnackBar('已删除绘制元素');
  }

  Future<void> _loadAvailableLegends() async {
    setState(() => _isLoading = true);
    try {
      final legends = await _legendDatabaseService.getAllLegends();
      setState(() {
        _availableLegends = legends;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('加载图例失败: ${e.toString()}');
    }
  }
  void _addDefaultLayer() {
    if (_currentMap == null) return;
    
    final defaultLayer = MapLayer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '图层 1',
      order: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _currentMap = _currentMap!.copyWith(
        layers: [..._currentMap!.layers, defaultLayer],
      );
      _selectedLayer = defaultLayer;
    });
  }
  void _addNewLayer() {
    if (widget.isPreviewMode || _currentMap == null) return;

    final newLayer = MapLayer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '图层 ${_currentMap!.layers.length + 1}',
      order: _currentMap!.layers.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _currentMap = _currentMap!.copyWith(
        layers: [..._currentMap!.layers, newLayer],
      );
      _selectedLayer = newLayer;
    });
  }
  void _deleteLayer(MapLayer layer) {
    if (widget.isPreviewMode || _currentMap == null || _currentMap!.layers.length <= 1) return;

    setState(() {
      final updatedLayers = _currentMap!.layers
          .where((l) => l.id != layer.id)
          .toList();
      _currentMap = _currentMap!.copyWith(layers: updatedLayers);

      if (_selectedLayer?.id == layer.id) {
        _selectedLayer = updatedLayers.isNotEmpty ? updatedLayers.first : null;
      }
    });
  }
  void _updateLayer(MapLayer updatedLayer) {
    if (widget.isPreviewMode || _currentMap == null) return;
    
    // 在修改前保存当前状态
    _saveToUndoHistory();

    setState(() {
      final layerIndex = _currentMap!.layers.indexWhere(
        (l) => l.id == updatedLayer.id,
      );
      if (layerIndex != -1) {
        final updatedLayers = List<MapLayer>.from(_currentMap!.layers);
        updatedLayers[layerIndex] = updatedLayer;
        _currentMap = _currentMap!.copyWith(layers: updatedLayers);

        if (_selectedLayer?.id == updatedLayer.id) {
          _selectedLayer = updatedLayer;
        }
      }
    });
  }
  void _reorderLayers(int oldIndex, int newIndex) {
    if (widget.isPreviewMode || _currentMap == null) return;

    setState(() {
      final layers = List<MapLayer>.from(_currentMap!.layers);
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = layers.removeAt(oldIndex);
      layers.insert(newIndex, item);

      // 重新分配order
      for (int i = 0; i < layers.length; i++) {
        layers[i] = layers[i].copyWith(order: i);
      }

      _currentMap = _currentMap!.copyWith(layers: layers);
    });
  }
  void _addLegendGroup() {
    if (widget.isPreviewMode || _currentMap == null) return;

    final newGroup = LegendGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '图例组 ${_currentMap!.legendGroups.length + 1}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _currentMap = _currentMap!.copyWith(
        legendGroups: [..._currentMap!.legendGroups, newGroup],
      );
    });
  }
  void _deleteLegendGroup(LegendGroup group) {
    if (widget.isPreviewMode || _currentMap == null) return;

    setState(() {
      final updatedGroups = _currentMap!.legendGroups
          .where((g) => g.id != group.id)
          .toList();
      _currentMap = _currentMap!.copyWith(legendGroups: updatedGroups);
    });
  }
  void _updateLegendGroup(LegendGroup updatedGroup) {
    if (_currentMap == null) return;
    
    setState(() {
      final groupIndex = _currentMap!.legendGroups.indexWhere(
        (g) => g.id == updatedGroup.id,
      );
      if (groupIndex != -1) {
        final updatedGroups = List<LegendGroup>.from(_currentMap!.legendGroups);
        updatedGroups[groupIndex] = updatedGroup;
        _currentMap = _currentMap!.copyWith(legendGroups: updatedGroups);
      }
    });
  }// 处理透明度预览

  void _handleOpacityPreview(String layerId, double opacity) {
    setState(() {
      _previewOpacityValues[layerId] = opacity;
    });
  } // 显示图层图例绑定抽屉

  void _showLayerLegendBindingDrawer(
    MapLayer layer,
    List<LegendGroup> allLegendGroups,
  ) {
    if (widget.isPreviewMode) return;

    setState(() {
      // 关闭其他抽屉
      _isLegendGroupManagementDrawerOpen = false;
      _isZIndexInspectorOpen = false;
      _currentLegendGroupForManagement = null;

      // 打开图层图例绑定抽屉
      _currentLayerForBinding = layer;
      _allLegendGroupsForBinding = allLegendGroups;
      _isLayerLegendBindingDrawerOpen = true;
    });
  } // 显示图例组管理抽屉

  void _showLegendGroupManagementDrawer(LegendGroup legendGroup) {
    if (widget.isPreviewMode) return;

    setState(() {
      // 关闭其他抽屉
      _isLayerLegendBindingDrawerOpen = false;
      _isZIndexInspectorOpen = false;
      _currentLayerForBinding = null;
      _allLegendGroupsForBinding = null;

      // 打开图例组管理抽屉
      _currentLegendGroupForManagement = legendGroup;
      _isLegendGroupManagementDrawerOpen = true;
    });
  }
  // 处理图例项双击事件
  void _handleLegendItemDoubleClick(LegendItem item) {
    if (widget.isPreviewMode || _currentMap == null) return;

    // 查找包含此图例项的图例组
    LegendGroup? containingGroup;
    for (final legendGroup in _currentMap!.legendGroups) {
      if (legendGroup.legendItems.any((legendItem) => legendItem.id == item.id)) {
        containingGroup = legendGroup;
        break;
      }
    }

    // 如果找到了包含该图例项的图例组，打开管理抽屉
    if (containingGroup != null) {
      _showLegendGroupManagementDrawer(containingGroup);
    }
  }

  // 关闭图层图例绑定抽屉
  void _closeLayerLegendBindingDrawer() {
    setState(() {
      _isLayerLegendBindingDrawerOpen = false;
      _currentLayerForBinding = null;
      _allLegendGroupsForBinding = null;
    });
  }

  // 关闭图例组管理抽屉
  void _closeLegendGroupManagementDrawer() {
    setState(() {
      _isLegendGroupManagementDrawerOpen = false;
      _currentLegendGroupForManagement = null;
    });
  }

  // 显示Z层级检视器
  void _showZIndexInspector() {
    if (widget.isPreviewMode || _selectedLayer == null) return;

    setState(() {
      // 关闭其他抽屉
      _isLayerLegendBindingDrawerOpen = false;
      _isLegendGroupManagementDrawerOpen = false;
      _currentLayerForBinding = null;
      _allLegendGroupsForBinding = null;
      _currentLegendGroupForManagement = null;

      // 打开Z层级检视器
      _isZIndexInspectorOpen = true;
    });
  }

  // 关闭Z层级检视器
  void _closeZIndexInspector() {
    setState(() {
      _isZIndexInspectorOpen = false;
    });
  }
  // 选中图例项
  void _selectLegendItem(String legendItemId) {
    setState(() {
      _selectedElementId = legendItemId.isEmpty ? null : legendItemId; // 空字符串表示取消选中
    });
  }

  // 处理绘制工具预览
  void _handleDrawingToolPreview(DrawingElementType? tool) {
    setState(() {
      _previewDrawingTool = tool;
    });
  }

  void _handleColorPreview(Color color) {
    setState(() {
      _previewColor = color;
    });
  }
  void _handleStrokeWidthPreview(double width) {
    setState(() {
      _previewStrokeWidth = width;
    });
  }

  void _handleDensityPreview(double density) {
    setState(() {
      _previewDensity = density;
    });
  }
  void _handleCurvaturePreview(double curvature) {
    setState(() {
      _previewCurvature = curvature;
    });
  }

  void _handleTriangleCutPreview(TriangleCutType triangleCut) {
    setState(() {
      _previewTriangleCut = triangleCut;
    });
  }

  Future<void> _saveMap() async {
    if (widget.isPreviewMode || _currentMap == null) return;

    setState(() => _isLoading = true);
    try {
      final updatedMap = _currentMap!.copyWith(updatedAt: DateTime.now());

      // 添加详细的调试信息
      print('开始保存地图：');
      print('- 地图ID: ${updatedMap.id}');
      print('- 地图标题: ${updatedMap.title}');
      print('- 图层数量: ${updatedMap.layers.length}');
      print('- 图例组数量: ${updatedMap.legendGroups.length}');
      print('- 是否有图像数据: ${updatedMap.imageData != null}');
      
      // 验证必要字段
      if (updatedMap.id == null) {
        throw Exception('地图ID为空，无法保存');
      }
      
      if (updatedMap.title.isEmpty) {
        throw Exception('地图标题为空，无法保存');
      }

      // 尝试序列化数据以检查是否有格式问题
      final databaseData = updatedMap.toDatabase();
      print('数据库数据准备完成，字段数量: ${databaseData.keys.length}');

      await _mapDatabaseService.updateMap(updatedMap);
      print('地图保存成功完成');
      _showSuccessSnackBar('地图保存成功');
    } catch (e, stackTrace) {
      print('保存失败详细错误:');
      print('错误: $e');
      print('堆栈: $stackTrace');
      _showErrorSnackBar('保存失败: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 处理工具栏自动关闭逻辑
  void _handlePanelToggle(String panelType) {
    setState(() {
      switch (panelType) {
        case 'drawing':
          // 如果其他面板开启了自动关闭，则关闭它们
          if (_isLayerPanelAutoClose && !_isLayerPanelCollapsed) {
            _isLayerPanelCollapsed = true;
          }
          if (_isLegendPanelAutoClose && !_isLegendPanelCollapsed) {
            _isLegendPanelCollapsed = true;
          }
          _isDrawingToolbarCollapsed = !_isDrawingToolbarCollapsed;
          break;
        case 'layer':
          // 如果其他面板开启了自动关闭，则关闭它们
          if (_isDrawingToolbarAutoClose && !_isDrawingToolbarCollapsed) {
            _isDrawingToolbarCollapsed = true;
          }
          if (_isLegendPanelAutoClose && !_isLegendPanelCollapsed) {
            _isLegendPanelCollapsed = true;
          }
          _isLayerPanelCollapsed = !_isLayerPanelCollapsed;
          break;
        case 'legend':
          // 如果其他面板开启了自动关闭，则关闭它们
          if (_isDrawingToolbarAutoClose && !_isDrawingToolbarCollapsed) {
            _isDrawingToolbarCollapsed = true;
          }
          if (_isLayerPanelAutoClose && !_isLayerPanelCollapsed) {
            _isLayerPanelCollapsed = true;
          }
          _isLegendPanelCollapsed = !_isLegendPanelCollapsed;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrowScreen = screenWidth < 800; // 判断是否为窄屏

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPreviewMode ? l10n.mapPreview : l10n.mapEditor),
        actions: [
          if (!widget.isPreviewMode) ...[
            IconButton(
              onPressed: _isLoading ? null : _saveMap,
              icon: const Icon(Icons.save),
              tooltip: '保存地图',
            ),
          ],          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('地图信息'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('标题: ${_currentMap?.title ?? "未知"}'),
                      Text('版本: v${_currentMap?.version ?? "0"}'),
                      Text('图层数量: ${_currentMap?.layers.length ?? 0}'),
                      Text('图例组数量: ${_currentMap?.legendGroups.length ?? 0}'),
                      Text('模式: ${widget.isPreviewMode ? "预览模式" : "编辑模式"}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.info),
            tooltip: '地图信息',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 主要内容
                isNarrowScreen
                    ? _buildNarrowScreenLayout()
                    : _buildWideScreenLayout(),

                // 图层图例绑定抽屉覆盖层
                if (_isLayerLegendBindingDrawerOpen &&
                    _currentLayerForBinding != null &&
                    _allLegendGroupsForBinding != null)
                  Positioned(
                    top: 16,
                    bottom: 16,
                    right: 16,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      child: LayerLegendBindingDrawer(
                        layer: _currentLayerForBinding!,
                        allLegendGroups: _allLegendGroupsForBinding!,
                        onLayerUpdated: _updateLayer,
                        onLegendGroupTapped: _showLegendGroupManagementDrawer,
                        onClose: _closeLayerLegendBindingDrawer,
                      ),
                    ),
                  ),                // 图例组管理抽屉覆盖层
                if (_isLegendGroupManagementDrawerOpen &&
                    _currentLegendGroupForManagement != null)
                  Positioned(
                    top: 16,
                    bottom: 16,
                    right: 16,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),                      child: LegendGroupManagementDrawer(
                        legendGroup: _currentLegendGroupForManagement!,
                        availableLegends: _availableLegends,
                        onLegendGroupUpdated: _updateLegendGroup,
                        isPreviewMode: widget.isPreviewMode,
                        onClose: _closeLegendGroupManagementDrawer,
                        onLegendItemSelected: _selectLegendItem,
                        allLayers: _currentMap?.layers, // 传递所有图层用于智能隐藏功能
                      ),
                    ),
                  ),

                // Z层级检视器覆盖层
                if (_isZIndexInspectorOpen && _selectedLayer != null)
                  Positioned(
                    top: 16,
                    bottom: 16,
                    right: 16,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 400, //Z层级检视器宽度
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 标题栏
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.layers,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Z层级检视器',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: _closeZIndexInspector,
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),

                            // Z层级检视器内容
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: ZIndexInspector(
                                    selectedLayer: _selectedLayer,
                                    onElementDeleted: _deleteElement,
                                    selectedElementId: _selectedElementId,
                                    onElementSelected: (elementId) {
                                      setState(
                                        () => _selectedElementId = elementId,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: isNarrowScreen
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    _isFloatingToolbarVisible = !_isFloatingToolbarVisible;
                  });
                },
                icon: AnimatedRotation(
                  turns: _isFloatingToolbarVisible ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isFloatingToolbarVisible ? Icons.close : Icons.menu,
                  ),
                ),
                label: Text(_isFloatingToolbarVisible ? '关闭工具栏' : '工具栏'),
                tooltip: _isFloatingToolbarVisible ? '关闭工具栏' : '打开工具栏',
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  List<Widget> _buildToolPanels() {
    final List<Widget> panels = [];

    // 绘制工具栏（仅编辑模式）
    if (!widget.isPreviewMode) {
      panels.add(
        _buildCollapsiblePanel(
          title: '绘制工具',
          icon: Icons.brush,
          isCollapsed: _isDrawingToolbarCollapsed,
          onToggleCollapsed: () => _handlePanelToggle('drawing'),
          autoCloseEnabled: _isDrawingToolbarAutoClose,
          onAutoCloseToggled: (value) =>
              setState(() => _isDrawingToolbarAutoClose = value),
          needsScrolling: true,
          child: _isDrawingToolbarCollapsed
              ? null              : DrawingToolbarOptimized(
                  selectedTool: _selectedDrawingTool,
                  selectedColor: _selectedColor,
                  selectedStrokeWidth: _selectedStrokeWidth,
                  selectedDensity: _selectedDensity,
                  selectedCurvature: _selectedCurvature,
                  selectedTriangleCut: _selectedTriangleCut,
                  isEditMode: !widget.isPreviewMode,
                  onToolSelected: (tool) {
                    setState(() => _selectedDrawingTool = tool);
                  },
                  onColorSelected: (color) {
                    setState(() => _selectedColor = color);
                  },
                  onStrokeWidthChanged: (width) {
                    setState(() => _selectedStrokeWidth = width);
                  },
                  onDensityChanged: (density) {
                    setState(() => _selectedDensity = density);
                  },
                  onCurvatureChanged: (curvature) {
                    setState(() => _selectedCurvature = curvature);
                  },
                  onTriangleCutChanged: (triangleCut) {
                    setState(() => _selectedTriangleCut = triangleCut);
                  },
                  onToolPreview: _handleDrawingToolPreview,
                  onColorPreview: _handleColorPreview,
                  onStrokeWidthPreview: _handleStrokeWidthPreview,
                  onDensityPreview: _handleDensityPreview,
                  onCurvaturePreview: _handleCurvaturePreview,
                  onTriangleCutPreview: _handleTriangleCutPreview,
                  onUndo: _undo,
                  onRedo: _redo,
                  canUndo: _canUndo,
                  canRedo: _canRedo,
                  selectedLayer: _selectedLayer,
                  onElementDeleted: _deleteElement,
                  selectedElementId: _selectedElementId,
                  onElementSelected: (elementId) {
                    setState(() => _selectedElementId = elementId);
                  },
                  onZIndexInspectorRequested: _showZIndexInspector,
                ),
        ),
      );
    }
    // 图层面板
    panels.add(
      _buildCollapsiblePanel(
        title: '图层',
        icon: Icons.layers,
        isCollapsed: _isLayerPanelCollapsed,
        onToggleCollapsed: () => _handlePanelToggle('layer'),
        autoCloseEnabled: _isLayerPanelAutoClose,
        onAutoCloseToggled: (value) =>
            setState(() => _isLayerPanelAutoClose = value),
        collapsedSubtitle: _selectedLayer != null
            ? '当前: ${_selectedLayer!.name}'
            : '未选择图层',
        actions: widget.isPreviewMode
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: _addNewLayer,
                  tooltip: '添加图层',
                ),
              ],        child: _isLayerPanelCollapsed
            ? null            : LayerPanel(
                layers: _currentMap?.layers ?? [],
                selectedLayer: _selectedLayer,
                isPreviewMode: widget.isPreviewMode,
                onLayerSelected: (layer) {
                  setState(() => _selectedLayer = layer);
                },
                onLayerUpdated: _updateLayer,
                onLayerDeleted: _deleteLayer,
                onLayerAdded: _addNewLayer,
                onLayersReordered: _reorderLayers,
                onError: _showErrorSnackBar,
                onSuccess: _showSuccessSnackBar,
                onOpacityPreview: _handleOpacityPreview,
                allLegendGroups: _currentMap?.legendGroups ?? [],
                onShowLayerLegendBinding: _showLayerLegendBindingDrawer,
                onLayersBatchUpdated: _updateLayersBatch,
              ),
      ),
    );

    // 图例面板
    panels.add(
      _buildCollapsiblePanel(
        title: '图例管理',
        icon: Icons.legend_toggle,
        isCollapsed: _isLegendPanelCollapsed,
        onToggleCollapsed: () => _handlePanelToggle('legend'),
        autoCloseEnabled: _isLegendPanelAutoClose,
        onAutoCloseToggled: (value) =>
            setState(() => _isLegendPanelAutoClose = value),
        actions: widget.isPreviewMode
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: _addLegendGroup,
                  tooltip: '添加图例组',
                ),
              ],        child: _isLegendPanelCollapsed
            ? null
            : LegendPanel(
                legendGroups: _currentMap?.legendGroups ?? [],
                availableLegends: _availableLegends,
                isPreviewMode: widget.isPreviewMode,
                onLegendGroupUpdated: _updateLegendGroup,
                onLegendGroupDeleted: _deleteLegendGroup,
                onLegendGroupAdded: _addLegendGroup,
                onLegendGroupTapped: _showLegendGroupManagementDrawer,
              ),
      ),
    );

    return panels;
  }

  Widget _buildCollapsiblePanel({
    required String title,
    required IconData icon,
    required bool isCollapsed,
    required VoidCallback onToggleCollapsed,
    Widget? child,
    List<Widget>? actions,
    bool needsScrolling = false,
    bool autoCloseEnabled = true,
    ValueChanged<bool>? onAutoCloseToggled,
    String? collapsedSubtitle, // 折叠状态下显示的附加信息
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrowScreen = screenWidth < 800;
    const double headerHeight = 48.0;
    final double minContentHeight = isNarrowScreen ? 600.0 : 700.0; // 窄屏时减小高度
    if (isCollapsed) {
      return Container(
        height: headerHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: InkWell(
          onTap: onToggleCollapsed,
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (collapsedSubtitle != null &&
                        collapsedSubtitle.isNotEmpty)
                      Text(
                        collapsedSubtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // 自动关闭开关（仅在折叠状态时显示）
              if (onAutoCloseToggled != null) ...[
                Tooltip(
                  message: '自动关闭：当点击其他工具栏时自动关闭此工具栏',
                  child: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: autoCloseEnabled,
                      onChanged: onAutoCloseToggled,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              const Icon(Icons.expand_more, size: 20),
            ],
          ),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(minHeight: minContentHeight),
      child: Card(
        margin: EdgeInsets.all(isNarrowScreen ? 2 : 4), // 窄屏时减小边距
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Container(
              height: headerHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: InkWell(
                onTap: onToggleCollapsed,
                child: Row(
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isNarrowScreen ? 14 : 16, // 窄屏时使用较小字体
                        ),
                      ),
                    ),
                    // 自动关闭开关
                    if (onAutoCloseToggled != null) ...[
                      Tooltip(
                        message: '自动关闭：当点击其他工具栏时自动关闭此工具栏',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '自动关闭',
                              style: TextStyle(
                                fontSize: isNarrowScreen ? 11 : 12,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: autoCloseEnabled,
                                onChanged: onAutoCloseToggled,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // 动作按钮
                    if (actions != null) ...actions,
                    const Icon(Icons.expand_less, size: 20),
                  ],
                ),
              ),
            ),

            // 内容
            if (child != null)
              Container(
                height: minContentHeight,
                child: needsScrolling
                    ? SingleChildScrollView(child: child)
                    : child,
              ),
          ],
        ),
      ),
    );
  }

  /// 宽屏布局（传统横向布局）
  Widget _buildWideScreenLayout() {
    return Row(
      children: [
        // 左侧工具面板
        SizedBox(
          width: 300,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
              ),
              child: Column(children: _buildToolPanels()),
            ),
          ),
        ),

        const VerticalDivider(),

        // 右侧地图画布
        Expanded(child: _buildMapCanvas()),
      ],
    );
  }

  /// 窄屏布局（悬浮工具栏）
  Widget _buildNarrowScreenLayout() {
    return Stack(
      children: [
        // 地图画布占满全屏
        _buildMapCanvas(),

        // 半透明遮罩（当工具栏打开时）- 放在工具栏下层，铺满整个屏幕
        if (_isFloatingToolbarVisible)
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isFloatingToolbarVisible ? 1.0 : 0.0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isFloatingToolbarVisible = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.4), // 稍微增加透明度
                ),
              ),
            ),
          ),

        // 悬浮工具栏 - 放在遮罩上层
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 0,
          bottom: 0,
          left: _isFloatingToolbarVisible ? 0 : -300,
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // 工具栏顶部拖拽条
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(
                        Icons.drag_handle,
                        color: Theme.of(context).hintColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '工具栏',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isFloatingToolbarVisible = false;
                          });
                        },
                        icon: const Icon(Icons.close),
                        iconSize: 20,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),

                // 工具面板内容
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(children: _buildToolPanels()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }  /// 构建地图画布组件
  Widget _buildMapCanvas() {
    if (_currentMap == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }    return MapCanvas(
      mapItem: _currentMap!,
      selectedLayer: _selectedLayer,
      selectedDrawingTool: _selectedDrawingTool,
      selectedColor: _selectedColor,
      selectedStrokeWidth: _selectedStrokeWidth,
      selectedDensity: _selectedDensity,
      selectedCurvature: _selectedCurvature,
      availableLegends: _availableLegends,
      isPreviewMode: widget.isPreviewMode,
      onLayerUpdated: _updateLayer,
      onLegendGroupUpdated: _updateLegendGroup,
      onLegendItemSelected: _selectLegendItem,
      onLegendItemDoubleClicked: _handleLegendItemDoubleClick,
      previewOpacityValues: _previewOpacityValues,
      previewDrawingTool: _previewDrawingTool,
      previewColor: _previewColor,
      previewStrokeWidth: _previewStrokeWidth,
      previewDensity: _previewDensity,
      previewCurvature: _previewCurvature,
      previewTriangleCut: _previewTriangleCut,
      selectedElementId: _selectedElementId,
    );
  }

  /// 批量更新图层
  void _updateLayersBatch(List<MapLayer> updatedLayers) {
    if (widget.isPreviewMode || _currentMap == null) return;
    
    // 在修改前保存当前状态
    _saveToUndoHistory();

    setState(() {
      _currentMap = _currentMap!.copyWith(layers: updatedLayers);
      
      // 如果当前选中的图层也被更新了，同步更新选中图层的引用
      if (_selectedLayer != null) {
        final updatedSelectedLayer = updatedLayers.firstWhere(
          (layer) => layer.id == _selectedLayer!.id,
          orElse: () => _selectedLayer!,
        );
        _selectedLayer = updatedSelectedLayer;
      }
    });
  }
}
