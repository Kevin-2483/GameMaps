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

class MapEditorPage extends StatefulWidget {
  final MapItem mapItem;
  final bool isPreviewMode;

  const MapEditorPage({
    super.key,
    required this.mapItem,
    this.isPreviewMode = false,
  });

  @override
  State<MapEditorPage> createState() => _MapEditorPageState();
}

class _MapEditorPageState extends State<MapEditorPage> {
  late MapItem _currentMap;
  final MapDatabaseService _mapDatabaseService = MapDatabaseService();
  final LegendDatabaseService _legendDatabaseService = LegendDatabaseService();
  
  List<legend_db.LegendItem> _availableLegends = [];
  bool _isLoading = false;
    // 当前选中的图层和绘制工具
  MapLayer? _selectedLayer;
  DrawingElementType? _selectedDrawingTool;
  Color _selectedColor = Colors.black;
  double _selectedStrokeWidth = 2.0;
  
  // 工具栏折叠状态
  bool _isDrawingToolbarCollapsed = false;
  bool _isLayerPanelCollapsed = false;
  bool _isLegendPanelCollapsed = false;

  @override
  void initState() {
    super.initState();
    _currentMap = widget.mapItem;
    _loadAvailableLegends();
    
    // 如果没有图层，创建一个默认图层
    if (_currentMap.layers.isEmpty) {
      _addDefaultLayer();
    } else {
      _selectedLayer = _currentMap.layers.first;
    }
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
    final defaultLayer = MapLayer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '图层 1',
      order: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    setState(() {
      _currentMap = _currentMap.copyWith(
        layers: [..._currentMap.layers, defaultLayer],
      );
      _selectedLayer = defaultLayer;
    });
  }

  void _addNewLayer() {
    if (widget.isPreviewMode) return;
    
    final newLayer = MapLayer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '图层 ${_currentMap.layers.length + 1}',
      order: _currentMap.layers.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    setState(() {
      _currentMap = _currentMap.copyWith(
        layers: [..._currentMap.layers, newLayer],
      );
      _selectedLayer = newLayer;
    });
  }

  void _deleteLayer(MapLayer layer) {
    if (widget.isPreviewMode || _currentMap.layers.length <= 1) return;
    
    setState(() {
      final updatedLayers = _currentMap.layers.where((l) => l.id != layer.id).toList();
      _currentMap = _currentMap.copyWith(layers: updatedLayers);
      
      if (_selectedLayer?.id == layer.id) {
        _selectedLayer = updatedLayers.isNotEmpty ? updatedLayers.first : null;
      }
    });
  }

  void _updateLayer(MapLayer updatedLayer) {
    setState(() {
      final layerIndex = _currentMap.layers.indexWhere((l) => l.id == updatedLayer.id);
      if (layerIndex != -1) {
        final updatedLayers = List<MapLayer>.from(_currentMap.layers);
        updatedLayers[layerIndex] = updatedLayer;
        _currentMap = _currentMap.copyWith(layers: updatedLayers);
        
        if (_selectedLayer?.id == updatedLayer.id) {
          _selectedLayer = updatedLayer;
        }
      }
    });
  }

  void _reorderLayers(int oldIndex, int newIndex) {
    if (widget.isPreviewMode) return;
    
    setState(() {
      final layers = List<MapLayer>.from(_currentMap.layers);
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = layers.removeAt(oldIndex);
      layers.insert(newIndex, item);
      
      // 重新分配order
      for (int i = 0; i < layers.length; i++) {
        layers[i] = layers[i].copyWith(order: i);
      }
      
      _currentMap = _currentMap.copyWith(layers: layers);
    });
  }

  void _addLegendGroup() {
    if (widget.isPreviewMode) return;
    
    final newGroup = LegendGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '图例组 ${_currentMap.legendGroups.length + 1}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    setState(() {
      _currentMap = _currentMap.copyWith(
        legendGroups: [..._currentMap.legendGroups, newGroup],
      );
    });
  }

  void _deleteLegendGroup(LegendGroup group) {
    if (widget.isPreviewMode) return;
    
    setState(() {
      final updatedGroups = _currentMap.legendGroups.where((g) => g.id != group.id).toList();
      _currentMap = _currentMap.copyWith(legendGroups: updatedGroups);
    });
  }

  void _updateLegendGroup(LegendGroup updatedGroup) {
    setState(() {
      final groupIndex = _currentMap.legendGroups.indexWhere((g) => g.id == updatedGroup.id);
      if (groupIndex != -1) {
        final updatedGroups = List<LegendGroup>.from(_currentMap.legendGroups);
        updatedGroups[groupIndex] = updatedGroup;
        _currentMap = _currentMap.copyWith(legendGroups: updatedGroups);
      }
    });
  }

  Future<void> _saveMap() async {
    if (widget.isPreviewMode) return;
    
    setState(() => _isLoading = true);
    try {
      final updatedMap = _currentMap.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _mapDatabaseService.updateMap(updatedMap);
      _showSuccessSnackBar('地图保存成功');
    } catch (e) {
      _showErrorSnackBar('保存失败: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
          ],
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('地图信息'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('标题: ${_currentMap.title}'),
                      Text('版本: v${_currentMap.version}'),
                      Text('图层数量: ${_currentMap.layers.length}'),
                      Text('图例组数量: ${_currentMap.legendGroups.length}'),
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
          : Row(
              children: [                // 左侧工具面板
                SizedBox(
                  width: 300,
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
                      ),
                      child: Column(
                        children: _buildToolPanels(),
                      ),
                    ),
                  ),
                ),
                
                const VerticalDivider(),
                
                // 右侧地图画布
                Expanded(
                  child: MapCanvas(
                    mapItem: _currentMap,
                    selectedLayer: _selectedLayer,
                    selectedDrawingTool: _selectedDrawingTool,
                    selectedColor: _selectedColor,
                    selectedStrokeWidth: _selectedStrokeWidth,
                    availableLegends: _availableLegends,
                    isPreviewMode: widget.isPreviewMode,
                    onLayerUpdated: _updateLayer,
                    onLegendGroupUpdated: _updateLegendGroup,
                  ),
                ),
              ],
            ),    );
  }  List<Widget> _buildToolPanels() {
    final List<Widget> panels = [];
    
    // 绘制工具栏（仅编辑模式）
    if (!widget.isPreviewMode) {
      panels.add(
        _buildCollapsiblePanel(
          title: '绘制工具',
          icon: Icons.brush,
          isCollapsed: _isDrawingToolbarCollapsed,
          onToggleCollapsed: () => setState(() => _isDrawingToolbarCollapsed = !_isDrawingToolbarCollapsed),
          needsScrolling: true,
          child: _isDrawingToolbarCollapsed ? null : DrawingToolbar(
            selectedTool: _selectedDrawingTool,
            selectedColor: _selectedColor,
            selectedStrokeWidth: _selectedStrokeWidth,
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
        onToggleCollapsed: () => setState(() => _isLayerPanelCollapsed = !_isLayerPanelCollapsed),
        actions: widget.isPreviewMode ? null : [
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: _addNewLayer,
            tooltip: '添加图层',
          ),
        ],
        child: _isLayerPanelCollapsed ? null : LayerPanel(
          layers: _currentMap.layers,
          selectedLayer: _selectedLayer,
          isPreviewMode: widget.isPreviewMode,
          onLayerSelected: (layer) {
            setState(() => _selectedLayer = layer);
          },
          onLayerUpdated: _updateLayer,
          onLayerDeleted: _deleteLayer,
          onLayerAdded: _addNewLayer,
          onLayersReordered: _reorderLayers,
        ),
      ),
    );
    
    // 图例面板
    panels.add(
      _buildCollapsiblePanel(
        title: '图例管理',
        icon: Icons.legend_toggle,
        isCollapsed: _isLegendPanelCollapsed,
        onToggleCollapsed: () => setState(() => _isLegendPanelCollapsed = !_isLegendPanelCollapsed),
        actions: widget.isPreviewMode ? null : [
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: _addLegendGroup,
            tooltip: '添加图例组',
          ),
        ],
        child: _isLegendPanelCollapsed ? null : LegendPanel(
          legendGroups: _currentMap.legendGroups,
          availableLegends: _availableLegends,
          isPreviewMode: widget.isPreviewMode,
          onLegendGroupUpdated: _updateLegendGroup,
          onLegendGroupDeleted: _deleteLegendGroup,
          onLegendGroupAdded: _addLegendGroup,
        ),
      ),
    );
    
    return panels;
  }  Widget _buildCollapsiblePanel({
    required String title,
    required IconData icon,
    required bool isCollapsed,
    required VoidCallback onToggleCollapsed,
    Widget? child,
    List<Widget>? actions,
    bool needsScrolling = false,
  }) {
    const double headerHeight = 48.0;
    const double minContentHeight = 400.0;
    
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
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.expand_more, size: 20),
            ],
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(
        minHeight: minContentHeight,
      ),
      child: Card(
        margin: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Container(
              height: headerHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
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
}
