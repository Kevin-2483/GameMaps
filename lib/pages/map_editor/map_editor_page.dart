import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/map_item.dart';
import '../../models/map_layer.dart';
import '../../providers/user_preferences_provider.dart';
import '../../services/map_database_service.dart';
import '../../services/vfs_map_storage/vfs_map_service_factory.dart';
import '../../services/vfs_map_storage/vfs_map_service.dart';
import '../../services/legend_vfs/legend_vfs_service.dart';
import '../../services/clipboard_service.dart';
import '../../l10n/app_localizations.dart';
import '../../models/legend_item.dart' as legend_db;
import '../../components/layout/main_layout.dart';
import '../../components/web/web_readonly_components.dart';
import 'widgets/map_canvas.dart';
import 'widgets/layer_panel.dart';
import 'widgets/legend_panel.dart';
import 'widgets/drawing_toolbar.dart';
import 'widgets/layer_legend_binding_drawer.dart';
import 'widgets/legend_group_management_drawer.dart';
import 'widgets/z_index_inspector.dart';
import 'widgets/version_tab_bar.dart';
import '../../models/map_version.dart';

class MapEditorPage extends BasePage {
  final MapItem? mapItem; // 可选的预加载地图数据
  final String? mapTitle; // 地图标题，用于按需加载
  final bool isPreviewMode;

  const MapEditorPage({
    super.key,
    this.mapItem,
    this.mapTitle,
    this.isPreviewMode = false,
  }) : assert(
         mapItem != null || mapTitle != null,
         'Either mapItem or mapTitle must be provided',
       );
  @override
  bool get showTrayNavigation => false; // 禁用 TrayNavigation

  @override
  Widget buildContent(BuildContext context) {
    return WebReadOnlyBanner(
      showBanner: kIsWeb,
      child: _MapEditorContent(
        mapItem: mapItem,
        mapTitle: mapTitle,
        // isPreviewMode: isPreviewMode || kIsWeb, // Web平台强制预览模式
        isPreviewMode: isPreviewMode,
      ),
    );
  }
}

class _MapEditorContent extends StatefulWidget {
  final MapItem? mapItem;
  final String? mapTitle;
  final bool isPreviewMode;

  const _MapEditorContent({
    this.mapItem,
    this.mapTitle,
    this.isPreviewMode = false,
  });

  @override
  State<_MapEditorContent> createState() => _MapEditorContentState();
}

class _MapEditorContentState extends State<_MapEditorContent> {
  final GlobalKey<MapCanvasState> _mapCanvasKey = GlobalKey<MapCanvasState>();  MapItem? _currentMap; // 可能为空，需要加载
  final MapDatabaseService _mapDatabaseService = VfsMapServiceFactory.createMapDatabaseService();
  final VfsMapService _vfsMapService = VfsMapServiceFactory.createVfsMapService();
  final LegendVfsService _legendDatabaseService = LegendVfsService();
  List<legend_db.LegendItem> _availableLegends = [];
  bool _isLoading = false;
  // 当前选中的图层和绘制工具
  MapLayer? _selectedLayer;
  List<MapLayer>? _selectedLayerGroup; // 修正：添加下划线前缀
  List<MapLayer> _displayOrderLayers = [];
  DrawingElementType? _selectedDrawingTool;
  Color _selectedColor = Colors.black;
  double _selectedStrokeWidth = 2.0;
  double _selectedDensity = 3.0; // 默认密度为3.0
  double _selectedCurvature = 0.0; // 默认弧度为0.0 (无弧度)
  TriangleCutType _selectedTriangleCut = TriangleCutType.none; // 默认无三角形切割
  String? _selectedElementId; // 当前选中的元素ID
  // 工具栏折叠状态
  bool _isDrawingToolbarCollapsed = false;
  bool _isLayerPanelCollapsed = false;
  bool _isLegendPanelCollapsed = false;

  //：图层组折叠状态
  Map<String, bool> _layerGroupCollapsedStates = {};

  // 自动关闭开关状态
  bool _isDrawingToolbarAutoClose = true;
  bool _isLayerPanelAutoClose = true;
  bool _isLegendPanelAutoClose = true;

  // 悬浮工具栏状态（用于窄屏）
  bool _isFloatingToolbarVisible = false; // 透明度预览状态
  final Map<String, double> _previewOpacityValues = {}; // 绘制工具预览状态
  DrawingElementType? _previewDrawingTool;
  Color? _previewColor;
  double? _previewStrokeWidth;
  double? _previewDensity;
  double? _previewCurvature; // 弧度预览状态
  TriangleCutType? _previewTriangleCut; // 三角形切割预览状态

  // 图片缓冲区状态
  Uint8List? _imageBufferData; // 缓冲区中的图片数据
  BoxFit _imageBufferFit = BoxFit.contain; // 缓冲区图片的适应方式

  // 覆盖层状态
  bool _isLayerLegendBindingDrawerOpen = false;
  bool _isLegendGroupManagementDrawerOpen = false;
  bool _isZIndexInspectorOpen = false;
  MapLayer? _currentLayerForBinding;
  List<LegendGroup>? _allLegendGroupsForBinding;
  LegendGroup? _currentLegendGroupForManagement;
  String? _initialSelectedLegendItemId; // 初始选中的图例项ID  // 撤销/重做历史记录管理
  final List<MapItem> _undoHistory = [];
  final List<MapItem> _redoHistory = [];
  
  // 版本管理
  MapVersionManager? _versionManager;
  bool _hasUnsavedVersionChanges = false;
  // 动态获取撤销历史记录数量限制
  int get _maxUndoHistory {
    final provider = context.read<UserPreferencesProvider>();
    return provider.mapEditor.undoHistoryLimit;
  }

  // 数据变更跟踪
  bool _hasUnsavedChanges = false;
  @override
  void initState() {
    super.initState();
    _initializeMap();
    _initializeLayoutFromPreferences();
  }

  /// 从用户首选项初始化界面布局
  void _initializeLayoutFromPreferences() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final prefsProvider = context.read<UserPreferencesProvider>();
        if (prefsProvider.isInitialized) {
          // 总是从首选项初始化面板状态，autoRestorePanelStates 只控制是否保存用户操作
          _updateLayoutFromPreferences(prefsProvider);
        }
      }
    });
  }

  /// 根据用户首选项更新界面布局
  void _updateLayoutFromPreferences(UserPreferencesProvider prefsProvider) {
    final layout = prefsProvider.layout;

    setState(() {
      // 更新面板折叠状态
      _isDrawingToolbarCollapsed =
          layout.panelCollapsedStates['drawing'] ?? false;
      _isLayerPanelCollapsed = layout.panelCollapsedStates['layer'] ?? false;
      _isLegendPanelCollapsed = layout.panelCollapsedStates['legend'] ?? false;

      // 更新面板自动关闭状态
      _isDrawingToolbarAutoClose =
          layout.panelAutoCloseStates['drawing'] ?? true;
      _isLayerPanelAutoClose = layout.panelAutoCloseStates['layer'] ?? true;
      _isLegendPanelAutoClose = layout.panelAutoCloseStates['legend'] ?? true;
    });
  }
  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);
    try {
      // 如果已有 mapItem，直接使用；否则通过 mapTitle 从数据库加载
      if (widget.mapItem != null) {
        _currentMap = widget.mapItem!;
      } else if (widget.mapTitle != null) {
        final loadedMap = await _mapDatabaseService.getMapByTitle(widget.mapTitle!);
        if (loadedMap == null) {
          throw Exception('未找到标题为 "${widget.mapTitle}" 的地图');
        }
        _currentMap = loadedMap;      } else {
        throw Exception('mapItem 和 mapTitle 都为空');
      }      // 初始化版本管理器
      final mapTitle = _currentMap!.title;
      _versionManager = MapVersionManager(mapTitle: mapTitle);
      
      // 初始化版本数据
      await _initializeVersions();

      // 加载可用图例
      await _loadAvailableLegends();

      // 如果没有图层，创建一个默认图层
      if (_currentMap!.layers.isEmpty) {
        _addDefaultLayer();
      }
      // 保存初始状态到撤销历史
      // _saveToUndoHistory();

      // 预加载所有图层的图片
      _preloadAllLayerImages();
    } catch (e) {
      _showErrorSnackBar('初始化地图失败: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 预加载所有图层的图片
  /// 在地图初始化完成后调用，确保所有图片区域元素立即显示而不是显示蓝色"解码中"占位符
  void _preloadAllLayerImages() {
    if (_currentMap == null) return;

    // 延迟一帧执行，确保MapCanvas已经初始化完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 通过更新显示顺序来触发MapCanvas中的图片预加载
      // 这会导致MapCanvas重新构建并预加载所有图层的图片
      _updateDisplayOrderAfterLayerChange();
    });
  }

  // 撤销历史记录管理方法
  void _saveToUndoHistory() {
    if (_currentMap == null) return;

    // 只有在非初始化状态时才标记为有未保存更改
    if (_undoHistory.isNotEmpty) {
      _hasUnsavedChanges = true;
    }

    // 保存当前状态到撤销历史
    _undoHistory.add(_currentMap!.copyWith());    // 清空重做历史，因为新的操作会使重做历史失效
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

      // 撤销操作也算作修改，除非回到初始状态
      _hasUnsavedChanges = _undoHistory.isNotEmpty;

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

      //：更新显示顺序以触发MapCanvas重建和缓存清理
      _updateDisplayOrderAfterLayerChange();
    });

    //：强制触发图片缓存清理和重新预加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 通过触发一个微小的状态变化来确保MapCanvas收到didUpdateWidget回调
        setState(() {});
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
      _hasUnsavedChanges = true; // 重做操作标记为有未保存更改

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

      //：更新显示顺序以触发MapCanvas重建和缓存清理
      _updateDisplayOrderAfterLayerChange();
    });

    //：强制触发图片缓存清理和重新预加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 通过触发一个微小的状态变化来确保MapCanvas收到didUpdateWidget回调
        setState(() {});
      }
    });
  }

  bool get _canUndo => _undoHistory.isNotEmpty;
  bool get _canRedo => _redoHistory.isNotEmpty;
  // 删除指定图层中的绘制元素
  void _deleteElement(String elementId) {
    if (_selectedLayer == null) return;

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

    //：如果删除的是图片元素，强制触发缓存清理
    if (elementToDelete.type == DrawingElementType.imageArea) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }

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
    if (_currentMap == null) return;

    // 保存当前状态到撤销历史
    _saveToUndoHistory();

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

      // 更新显示顺序
      _updateDisplayOrderAfterLayerChange();
    });
  }

  void _deleteLayer(MapLayer layer) {
    if (_currentMap == null || _currentMap!.layers.length <= 1) return;

    // 保存当前状态到撤销历史
    _saveToUndoHistory();

    setState(() {
      final updatedLayers = _currentMap!.layers
          .where((l) => l.id != layer.id)
          .toList();
      _currentMap = _currentMap!.copyWith(layers: updatedLayers);

      if (_selectedLayer?.id == layer.id) {
        _selectedLayer = updatedLayers.isNotEmpty ? updatedLayers.first : null;
      }

      // 如果删除的图层在选中的组中，更新组选择
      if (_selectedLayerGroup != null) {
        final updatedGroup = _selectedLayerGroup!
            .where((l) => l.id != layer.id)
            .toList();

        if (updatedGroup.isEmpty) {
          // 如果组内所有图层都被删除，清除组选择
          _selectedLayerGroup = null;
          _restoreNormalLayerOrder();
        } else {
          // 更新组选择
          _selectedLayerGroup = updatedGroup;
          _prioritizeLayerGroup(updatedGroup);
        }
      } else {
        // 更新显示顺序
        _updateDisplayOrderAfterLayerChange();
      }
    });  }
  void _onLayerSelected(MapLayer layer) {
    setState(() {
      _selectedLayer = layer;
      // 清除图层组选择，但保持单图层选择
      _selectedLayerGroup = null;
    });

    // 触发优先显示逻辑
    _prioritizeLayerAndGroupDisplay();
    // 清除画布上的选区
    _clearCanvasSelection();
  }

  void _onLayerGroupSelected(List<MapLayer> group) {
    setState(() {
      // 修改：不清除单图层选择，允许同时选择
      _selectedLayerGroup = group; // 设置组选择
    });

    // 触发优先显示逻辑
    _prioritizeLayerAndGroupDisplay();
    //：清除画布上的选区
    _clearCanvasSelection();
  }

  // 添加清除画布选区的方法
  void _clearCanvasSelection() {
    // 通过 GlobalKey 直接调用 MapCanvas 的清除选区方法
    _mapCanvasKey.currentState?.clearSelection();
  }

  void _onLayerSelectionCleared() {
    setState(() {
      _selectedLayer = null;
      // 保留 _selectedLayerGroup，不清除
    });
    _disableDrawingTools();
    // 更新显示顺序
    _prioritizeLayerAndGroupDisplay();
    _clearCanvasSelection();
  }

  // 修改：新的优先显示逻辑，支持图层和图层组的组合显示
  void _prioritizeLayerAndGroupDisplay() {
    print('优先显示图层和图层组的组合');

    if (_currentMap == null) return;

    setState(() {
      final allLayers = List<MapLayer>.from(_currentMap!.layers);
      final selectedLayer = _selectedLayer;
      final selectedGroup = _selectedLayerGroup;

      // 如果既没有选中图层也没有选中组，恢复正常顺序
      if (selectedLayer == null && selectedGroup == null) {
        _displayOrderLayers = allLayers
          ..sort((a, b) => a.order.compareTo(b.order));
        return;
      }

      // 分离图层：优先图层、组内图层、其他图层
      final priorityLayers = <MapLayer>[]; // 最优先显示的图层
      final groupLayers = <MapLayer>[]; // 组内图层（排除优先图层）
      final otherLayers = <MapLayer>[]; // 其他图层

      for (final layer in allLayers) {
        // 检查是否是选中的单个图层
        if (selectedLayer != null && layer.id == selectedLayer.id) {
          priorityLayers.add(layer);
        }
        // 检查是否在选中的组中
        else if (selectedGroup != null &&
            selectedGroup.any((groupLayer) => groupLayer.id == layer.id)) {
          groupLayers.add(layer);
        }
        // 其他图层
        else {
          otherLayers.add(layer);
        }
      }

      // 对各部分进行排序（保持内部相对顺序）
      priorityLayers.sort((a, b) => a.order.compareTo(b.order));
      groupLayers.sort((a, b) => a.order.compareTo(b.order));
      otherLayers.sort((a, b) => a.order.compareTo(b.order));

      // 构建最终的显示顺序：其他图层 -> 组内图层 -> 优先图层
      // （后绘制的显示在上层）
      _displayOrderLayers = [...otherLayers, ...groupLayers, ...priorityLayers];

      print('重新排列后的显示顺序:');
      print(
        '- 其他图层: ${otherLayers.map((l) => '${l.name}(${l.order})').toList()}',
      );
      print(
        '- 组内图层: ${groupLayers.map((l) => '${l.name}(${l.order})').toList()}',
      );
      print(
        '- 优先图层: ${priorityLayers.map((l) => '${l.name}(${l.order})').toList()}',
      );
    });
  }

  void _onSelectionCleared() {
    setState(() {
      _selectedLayer = null;
      _selectedLayerGroup = null;
    });

    // 清除绘制工具（因为没有图层选择）
    _disableDrawingTools();

    // 恢复正常绘制顺序
    _restoreNormalLayerOrder();
  }

  void _prioritizeLayerGroup(List<MapLayer> group) {
    print('优先显示图层组: ${group.map((l) => l.name).toList()}');

    if (_currentMap == null) return;

    setState(() {
      // 将选中的图层组移到显示列表的最前面（最后绘制，显示在上层）
      final allLayers = List<MapLayer>.from(_currentMap!.layers);
      final nonGroupLayers = <MapLayer>[];
      final groupLayers = <MapLayer>[];

      // 分离组内图层和其他图层
      for (final layer in allLayers) {
        if (group.any((groupLayer) => groupLayer.id == layer.id)) {
          groupLayers.add(layer);
        } else {
          nonGroupLayers.add(layer);
        }
      }

      // 按原有顺序排列组内图层（保持组内相对顺序）
      groupLayers.sort((a, b) => a.order.compareTo(b.order));

      // 重新组织显示顺序：非组图层在前，组图层在后（后绘制的显示在上层）
      _displayOrderLayers = [...nonGroupLayers, ...groupLayers];

      print(
        '重新排列后的显示顺序: ${_displayOrderLayers.map((l) => '${l.name}(${l.order})').toList()}',
      );
    });
  }

  void _restoreNormalLayerOrder() {
    print('恢复正常图层绘制顺序');

    if (_currentMap == null) return;

    setState(() {
      // 按原始order顺序排列
      _displayOrderLayers = List<MapLayer>.from(_currentMap!.layers)
        ..sort((a, b) => a.order.compareTo(b.order));

      print(
        '恢复后的显示顺序: ${_displayOrderLayers.map((l) => '${l.name}(${l.order})').toList()}',
      );
    });
  }

  void _disableDrawingTools() {
    // 禁用绘制工具的逻辑
    setState(() {
      _selectedDrawingTool = null; // 清除选中的绘制工具
      _selectedElementId = null; // 清除选中的元素
    });
    print('绘制工具已禁用');
  }

  /// 检查绘制工具是否应该被禁用
  bool get _shouldDisableDrawingTools {
    return _selectedLayer == null;
  }

  /// 检查是否没有任何图层选择
  bool get _hasNoLayerSelected {
    return _selectedLayer == null && _selectedLayerGroup == null;
  }
  List<MapLayer> get _layersForDisplay {
    if (_displayOrderLayers.isEmpty && _currentMap != null) {
      // 如果显示顺序列表为空，初始化为正常顺序
      _displayOrderLayers = List<MapLayer>.from(_currentMap!.layers)
        ..sort((a, b) => a.order.compareTo(b.order));
    }
    return _displayOrderLayers;
  }

  // 修改所有涉及图层更新的方法，确保同步更新显示顺序
  void _updateLayer(MapLayer updatedLayer) {
    if (_currentMap == null) return;

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

        // 同步更新显示顺序列表
        _updateDisplayOrderAfterLayerChange();
      }
    });
  }

  void _reorderLayers(int oldIndex, int newIndex) {
    if (_currentMap == null) return;

    print('=== _reorderLayers 开始 ===');
    print('oldIndex: $oldIndex, newIndex: $newIndex');
    print('当前图层数量: ${_currentMap!.layers.length}');
    print('重排序前图层名称: ${_currentMap!.layers.map((l) => l.name).toList()}');

    // 验证索引范围
    if (oldIndex < 0 ||
        oldIndex >= _currentMap!.layers.length ||
        newIndex < 0 ||
        newIndex >= _currentMap!.layers.length ||
        oldIndex == newIndex) {
      print('索引无效，跳过重排序');
      return;
    }

    // 保存当前状态到撤销历史
    _saveToUndoHistory();

    setState(() {
      final layers = List<MapLayer>.from(_currentMap!.layers);

      // 记录移动前的链接状态，用于组内重排序时保持组的完整性
      final movedLayer = layers[oldIndex];
      final isGroupInternalMove = _isGroupInternalMove(
        layers,
        oldIndex,
        newIndex,
      );

      print('是否为组内移动: $isGroupInternalMove');

      // 执行重排序 - 不需要调整newIndex，直接使用
      final item = layers.removeAt(oldIndex);
      layers.insert(newIndex, item);

      print('重排序后图层名称: ${layers.map((l) => l.name).toList()}');

      // 重新分配order
      for (int i = 0; i < layers.length; i++) {
        layers[i] = layers[i].copyWith(order: i);
      }

      // 如果是组内移动，需要特殊处理链接状态
      if (isGroupInternalMove) {
        _preserveGroupLinkingForInternalMove(layers, movedLayer, newIndex);
      }

      _currentMap = _currentMap!.copyWith(layers: layers);

      print('更新后的_currentMap图层数量: ${_currentMap!.layers.length}');
      print('=== _reorderLayers 结束 ===');

      // 更新选中图层的引用
      if (_selectedLayer != null) {
        final selectedLayerId = _selectedLayer!.id;
        _selectedLayer = layers.firstWhere(
          (layer) => layer.id == selectedLayerId,
          orElse: () => _selectedLayer!,
        );
      }

      // 如果有选中的图层组，更新组选择并重新应用优先显示
      if (_selectedLayerGroup != null) {
        final updatedGroup = <MapLayer>[];
        for (final groupLayer in _selectedLayerGroup!) {
          final updatedLayer = layers.firstWhere(
            (layer) => layer.id == groupLayer.id,
            orElse: () => groupLayer,
          );
          updatedGroup.add(updatedLayer);
        }
        _selectedLayerGroup = updatedGroup;
        _prioritizeLayerGroup(updatedGroup);
      } else {
        // 更新显示顺序
        _updateDisplayOrderAfterLayerChange();
      }
    });
  }

  /// 在图层变更后更新显示顺序
  void _updateDisplayOrderAfterLayerChange() {
    if (_currentMap == null) return;

    if (_selectedLayerGroup != null || _selectedLayer != null) {
      // 如果有选中的组或图层，重新应用优先显示
      _prioritizeLayerAndGroupDisplay();
    } else {
      // 否则恢复正常顺序
      _restoreNormalLayerOrder();
    }
  }

  /// 批量更新图层
  void _updateLayersBatch(List<MapLayer> updatedLayers) {
    if (_currentMap == null) return;

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

      // 如果有选中的图层组，更新组选择
      if (_selectedLayerGroup != null) {
        final updatedGroup = <MapLayer>[];
        for (final groupLayer in _selectedLayerGroup!) {
          final updatedLayer = updatedLayers.firstWhere(
            (layer) => layer.id == groupLayer.id,
            orElse: () => groupLayer,
          );
          updatedGroup.add(updatedLayer);
        }
        _selectedLayerGroup = updatedGroup;
        _prioritizeLayerGroup(updatedGroup);
      } else {
        // 更新显示顺序
        _updateDisplayOrderAfterLayerChange();
      }
    });
  }

  /// 为组内移动保持组的链接完整性
  void _preserveGroupLinkingForInternalMove(
    List<MapLayer> layers,
    MapLayer movedLayer,
    int newIndex,
  ) {
    print('保持组内链接完整性');

    // 重新找到移动后的组边界
    int groupStart = _findGroupStart(layers, newIndex);
    int groupEnd = _findGroupEnd(layers, newIndex);

    print('组边界: start=$groupStart, end=$groupEnd, newIndex=$newIndex');

    // 确保组内所有图层（除了最后一个）都保持链接状态
    for (int i = groupStart; i < groupEnd; i++) {
      if (!layers[i].isLinkedToNext) {
        print('修复图层 ${layers[i].name} 的链接状态');
        layers[i] = layers[i].copyWith(
          isLinkedToNext: true,
          updatedAt: DateTime.now(),
        );
      }
    }

    // 确保组的最后一个图层不链接到组外
    if (groupEnd < layers.length - 1 && layers[groupEnd].isLinkedToNext) {
      // 检查下一个图层是否应该在同一组中
      bool shouldLinkToNext = false;
      if (groupEnd + 1 < layers.length) {
        // 这里可以添加更复杂的逻辑来判断是否应该保持链接
        // 暂时保持简单：组内移动不改变与组外图层的链接关系
        shouldLinkToNext = layers[groupEnd].isLinkedToNext;
      }

      if (!shouldLinkToNext) {
        print('断开组最后图层 ${layers[groupEnd].name} 的链接');
        layers[groupEnd] = layers[groupEnd].copyWith(
          isLinkedToNext: false,
          updatedAt: DateTime.now(),
        );
      }
    }
  }

  /// 检查是否为组内移动
  bool _isGroupInternalMove(List<MapLayer> layers, int oldIndex, int newIndex) {
    // 找到oldIndex所在的组
    int groupStart = _findGroupStart(layers, oldIndex);
    int groupEnd = _findGroupEnd(layers, oldIndex);

    // 检查newIndex是否在同一个组内
    return newIndex >= groupStart && newIndex <= groupEnd;
  }

  void _addLegendGroup() {
    if (_currentMap == null) return;

    // 保存当前状态到撤销历史
    _saveToUndoHistory();

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

  /// 查找组的开始位置
  int _findGroupStart(List<MapLayer> layers, int index) {
    int start = index;

    // 向前查找组的开始
    while (start > 0) {
      if (layers[start - 1].isLinkedToNext) {
        start--;
      } else {
        break;
      }
    }

    return start;
  }

  /// 查找组的结束位置
  int _findGroupEnd(List<MapLayer> layers, int index) {
    int end = index;

    // 向后查找组的结束
    while (end < layers.length - 1) {
      if (layers[end].isLinkedToNext) {
        end++;
      } else {
        break;
      }
    }

    return end;
  }

  void _deleteLegendGroup(LegendGroup group) {
    if (_currentMap == null) return;

    // 保存当前状态到撤销历史
    _saveToUndoHistory();

    setState(() {
      final updatedGroups = _currentMap!.legendGroups
          .where((g) => g.id != group.id)
          .toList();
      _currentMap = _currentMap!.copyWith(legendGroups: updatedGroups);
    });
  }

  void _updateLegendGroup(LegendGroup updatedGroup) {
    if (_currentMap == null) return;

    // 保存当前状态到撤销历史（只在非预览模式下）
    _saveToUndoHistory();

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
  } // 处理透明度预览

  void _handleOpacityPreview(String layerId, double opacity) {
    setState(() {
      _previewOpacityValues[layerId] = opacity;
    });
  } // 显示图层图例绑定抽屉

  void _showLayerLegendBindingDrawer(
    MapLayer layer,
    List<LegendGroup> allLegendGroups,
  ) {
    setState(() {
      // 关闭其他抽屉
      _isLegendGroupManagementDrawerOpen = false;
      _isZIndexInspectorOpen = false;
      _currentLegendGroupForManagement = null;
      _initialSelectedLegendItemId = null;

      // 打开图层图例绑定抽屉
      _currentLayerForBinding = layer;
      _allLegendGroupsForBinding = allLegendGroups;
      _isLayerLegendBindingDrawerOpen = true;
    });
  } // 显示图例组管理抽屉

  void _showLegendGroupManagementDrawer(
    LegendGroup legendGroup, {
    String? selectedLegendItemId,
  }) {
    setState(() {
      // 关闭其他抽屉
      _isLayerLegendBindingDrawerOpen = false;
      _isZIndexInspectorOpen = false;
      _currentLayerForBinding = null;
      _allLegendGroupsForBinding = null;

      // 打开图例组管理抽屉
      _currentLegendGroupForManagement = legendGroup;
      _initialSelectedLegendItemId = selectedLegendItemId;
      _isLegendGroupManagementDrawerOpen = true;
    });
  } // 处理图例项双击事件

  void _handleLegendItemDoubleClick(LegendItem item) {
    if (_currentMap == null) return;

    // 首先选中该图例项，这样边框会立即显示
    _selectLegendItem(item.id);

    // 查找包含此图例项的图例组
    LegendGroup? containingGroup;
    for (final legendGroup in _currentMap!.legendGroups) {
      if (legendGroup.legendItems.any(
        (legendItem) => legendItem.id == item.id,
      )) {
        containingGroup = legendGroup;
        break;
      }
    }

    // 如果找到了包含该图例项的图例组，打开管理抽屉并选中该图例项
    if (containingGroup != null) {
      _showLegendGroupManagementDrawer(
        containingGroup,
        selectedLegendItemId: item.id,
      );
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
      _initialSelectedLegendItemId = null;
    });
  }

  // 显示Z层级检视器
  void _showZIndexInspector() {
    if (_selectedLayer == null) return;

    setState(() {
      // 关闭其他抽屉
      _isLayerLegendBindingDrawerOpen = false;
      _isLegendGroupManagementDrawerOpen = false;
      _currentLayerForBinding = null;
      _allLegendGroupsForBinding = null;
      _currentLegendGroupForManagement = null;
      _initialSelectedLegendItemId = null;

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
      _selectedElementId = legendItemId.isEmpty
          ? null
          : legendItemId; // 空字符串表示取消选中
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

  // 图片缓冲区管理方法
  void _handleImageBufferUpdated(Uint8List imageData) {
    setState(() {
      _imageBufferData = imageData;
    });
  }

  void _handleImageBufferFitChanged(BoxFit fit) {
    setState(() {
      _imageBufferFit = fit;
    });
  }

  void _handleImageBufferCleared() {
    setState(() {
      _imageBufferData = null;
      _imageBufferFit = BoxFit.contain;
    });
  }
  Future<void> _saveMap() async {
    if (widget.isPreviewMode || _currentMap == null || kIsWeb) return;

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
      
      // 如果有版本管理器，需要保存所有版本的数据
      if (_versionManager != null) {
        // 首先更新当前版本的数据
        final currentVersionId = _versionManager!.currentVersionId;
        _versionManager!.updateVersionData(currentVersionId, updatedMap);
        await _mapDatabaseService.updateMap(updatedMap);
        // 保存所有版本的数据到持久存储
        await _saveAllVersionsToStorage();
        print('所有版本数据已保存到持久存储');
        
        _hasUnsavedVersionChanges = false;
      } else {
        // 没有版本管理器时，直接保存当前地图
        await _mapDatabaseService.updateMap(updatedMap);
        print('单版本地图保存完成');
      }
      
      print('地图保存成功完成');
      _showSuccessSnackBar('地图保存成功');

      // 清除未保存更改标记
      _hasUnsavedChanges = false;
    } catch (e, stackTrace) {
      print('保存失败详细错误:');
      print('错误: $e');
      print('堆栈: $stackTrace');
      _showErrorSnackBar('保存失败: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  // 版本管理相关方法  /// 初始化版本管理
  Future<void> _initializeVersions() async {
    if (_versionManager == null || _currentMap == null) return;
    
    try {
      // 确保默认版本存在并包含当前地图数据
      _versionManager!.initializeDefault();
      _versionManager!.updateVersionData('default', _currentMap!);
      print('版本管理已初始化，默认版本已设置');
      
      // 加载已保存的版本
      await _loadExistingVersions();
    } catch (e) {
      print('初始化版本失败: $e');
      _showErrorSnackBar('初始化版本失败: ${e.toString()}');
    }
  }

  /// 加载已存在的版本
  Future<void> _loadExistingVersions() async {
    if (_versionManager == null || _currentMap == null) return;

    try {
      final mapTitle = _currentMap!.title;
      print('开始加载现有版本 [地图: $mapTitle]');
      
      // 获取VFS中存储的所有版本
      final storedVersions = await _vfsMapService.getMapVersions(mapTitle);
      print('在存储中找到版本: $storedVersions');
      
      for (final versionId in storedVersions) {
        if (versionId == 'default') {
          // 默认版本已经在初始化时处理，跳过
          continue;
        }
        
        try {
          print('加载版本数据: $versionId');
          
          // 加载图层数据
          final layers = await _vfsMapService.getMapLayers(mapTitle, versionId);
          
          // 加载图例组数据  
          final legendGroups = await _vfsMapService.getMapLegendGroups(mapTitle, versionId);
          
          // 构建版本的地图数据
          final versionMapData = _currentMap!.copyWith(
            layers: layers,
            legendGroups: legendGroups,
            updatedAt: DateTime.now(),
          );
          
          // 创建版本并添加到版本管理器
          final version = _versionManager!.createVersionFromData(
            versionId,
            _getVersionDisplayName(versionId), // 生成友好的显示名称
            versionMapData,
          );
          
          print('成功加载版本: ${version.name} (ID: ${version.id})');
        } catch (e) {
          print('加载版本 $versionId 失败: $e');
        }
      }
      
      print('版本加载完成，总共 ${_versionManager!.versions.length} 个版本');
      
      // 刷新UI显示版本列表
      if (mounted) {
        setState(() {
          // 触发UI更新以显示加载的版本
        });
      }
    } catch (e) {
      print('加载现有版本失败: $e');
    }
  }

  /// 为版本ID生成友好的显示名称
  String _getVersionDisplayName(String versionId) {
    if (versionId == 'default') {
      return '默认版本';
    }
    
    // 如果是时间戳格式的版本ID，尝试提取时间
    if (versionId.startsWith('version_')) {
      final timestampStr = versionId.replaceFirst('version_', '');
      final timestamp = int.tryParse(timestampStr);
      if (timestamp != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return '版本 ${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
    }
    
    // 默认使用版本ID作为名称
    return '版本 $versionId';
  }

  /// 创建新版本
  void _createVersion(String name) {
    if (_versionManager == null || _currentMap == null) return;
    
    // 保存当前状态到撤销历史
    _saveToUndoHistory();
    
    setState(() {
      final newVersion = _versionManager!.createVersion(name, _currentMap!);
      _versionManager!.switchToVersion(newVersion.id);
      _hasUnsavedVersionChanges = false; // 新版本创建时数据已保存到内存
    });
    
    print('新版本已创建: ${_versionManager!.currentVersionId}');
    _showSuccessSnackBar('版本 "$name" 已创建');
  }
  /// 切换版本
  void _switchVersion(String versionId) {
    if (_versionManager == null || versionId == _versionManager!.currentVersionId) {
      return;
    }
    
    // 保存当前版本的更改到内存
    if (_hasUnsavedVersionChanges && _currentMap != null) {
      final currentVersionId = _versionManager!.currentVersionId;
      _versionManager!.updateVersionData(currentVersionId, _currentMap!);
      print('当前版本数据已保存到内存 [版本: $currentVersionId]');
    }
    
    // 切换到新版本
    _versionManager!.switchToVersion(versionId);
    final versionData = _versionManager!.getVersionData(versionId);
    
    if (versionData != null) {
      setState(() {
        _currentMap = versionData;
        _hasUnsavedVersionChanges = false;
        
        // 重置选择状态
        _selectedLayer = _currentMap!.layers.isNotEmpty ? _currentMap!.layers.first : null;
        _selectedLayerGroup = null;
        _selectedElementId = null;
        
        // 更新显示顺序
        _updateDisplayOrderAfterLayerChange();
      });
      
      _showSuccessSnackBar('已切换到版本 "${_versionManager!.currentVersion?.name}"');
    }
  }  /// 删除版本
  Future<void> _deleteVersion(String versionId) async {
    if (_versionManager == null || _currentMap == null) return;
    
    final version = _versionManager!.getVersion(versionId);
    if (version == null) return;
    
    try {
      // 如果要删除的是当前版本，需要先切换到另一个版本
      if (versionId == _versionManager!.currentVersionId) {
        // 找到另一个可用的版本进行切换
        final availableVersions = _versionManager!.versions
            .where((v) => v.id != versionId)
            .toList();
        
        if (availableVersions.isEmpty) {
          _showErrorSnackBar('无法删除：这是唯一的版本');
          return;
        }
        
        // 优先切换到默认版本，如果默认版本就是要删除的版本，则切换到第一个可用版本
        final targetVersion = availableVersions.firstWhere(
          (v) => v.id == 'default',
          orElse: () => availableVersions.first,
        );
        
        print('正在切换到版本 "${targetVersion.name}" 以便删除当前版本');
        _versionManager!.switchToVersion(targetVersion.id);
        
        // 更新UI显示新的当前版本数据
        final targetVersionData = _versionManager!.getVersionData(targetVersion.id);
        if (targetVersionData != null) {
          setState(() {
            _currentMap = targetVersionData;
            _hasUnsavedVersionChanges = false;
            
            // 重置选择状态
            _selectedLayer = _currentMap!.layers.isNotEmpty ? _currentMap!.layers.first : null;
            _selectedLayerGroup = null;
            _selectedElementId = null;
            
            // 更新显示顺序
            _updateDisplayOrderAfterLayerChange();
          });
        }
      }
      
      // 现在可以安全地从内存中删除版本（只做内存删除，不删除持久存储）
      if (_versionManager!.deleteVersion(versionId)) {
        setState(() {
          _hasUnsavedVersionChanges = true;
        });
        _showSuccessSnackBar('版本 "${version.name}" 已从内存中删除');
      } else {
        _showErrorSnackBar('无法删除该版本');
      }
    } catch (e) {
      print('删除版本失败: $e');
      _showErrorSnackBar('删除版本失败: ${e.toString()}');
    }
  }

  /// 保存所有版本数据到持久存储
  Future<void> _saveAllVersionsToStorage() async {
    if (_versionManager == null || _currentMap == null) {
      print('版本管理器或当前地图为空，跳过保存所有版本');
      return;
    }

    try {
      final mapTitle = _currentMap!.title;
      print('开始保存所有版本到持久存储 [地图: $mapTitle]');
      
      // 获取所有版本
      final versions = _versionManager!.versions;
      print('找到 ${versions.length} 个版本需要保存');
      
      for (final version in versions) {
        final versionData = version.mapData;
        if (versionData != null) {
          print('保存版本 "${version.name}" (ID: ${version.id}) 到持久存储');
          
          // 为每个版本创建VFS存储的版本目录
          if (version.id != 'default') {
            // 非默认版本需要先确保版本目录存在
            final versionExists = await _vfsMapService.mapVersionExists(mapTitle, version.id);
            if (!versionExists) {
              print('创建新版本目录: ${version.id}');
              await _vfsMapService.createMapVersion(mapTitle, version.id, 'default');
            }
          }
          // 只在第一个版本时保存基础地图元数据
          if (version.id == 'default') {
            // 对于默认版本，只保存地图的基础元数据
            await _vfsMapService.updateMapMeta(mapTitle, versionData);
          }
          
          // 保存图层数据到对应版本
          for (final layer in versionData.layers) {
            await _vfsMapService.saveLayer(mapTitle, layer, version.id);
          }
          
          // 保存图例组数据到对应版本
          for (final group in versionData.legendGroups) {
            await _vfsMapService.saveLegendGroup(mapTitle, group, version.id);
          }
          
          print('版本 "${version.name}" 保存完成');
        } else {
          print('版本 "${version.name}" 没有地图数据，跳过');
        }
      }
      
      print('所有版本数据已成功保存到持久存储');
    } catch (e, stackTrace) {
      print('保存所有版本到持久存储时发生错误: $e');
      print('错误堆栈: $stackTrace');
      rethrow;
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

  // 退出确认对话框
  Future<bool> _showExitConfirmDialog() async {
    if (!_hasUnsavedChanges || widget.isPreviewMode || kIsWeb) {
      return true; // 如果没有未保存更改或在预览模式，直接允许退出
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('未保存的更改'),
        content: const Text('您有未保存的更改，确定要退出吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('不保存退出'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(false); // 先关闭对话框
              await _saveMap(); // 保存地图
              if (mounted && !_hasUnsavedChanges) {
                context.pop(); // 使用 go_router 的方式退出
              }
            },
            child: const Text('保存并退出'),
          ),
        ],
      ),
    );

    return result ?? false;
  } // 处理工具栏自动关闭逻辑

  void _handlePanelToggle(String panelType) {
    // 记录哪些面板状态发生了变化
    Set<String> changedPanels = {panelType};

    setState(() {
      switch (panelType) {
        case 'drawing':
          // 如果其他面板开启了自动关闭，则关闭它们
          if (_isLayerPanelAutoClose && !_isLayerPanelCollapsed) {
            _isLayerPanelCollapsed = true;
            changedPanels.add('layer');
          }
          if (_isLegendPanelAutoClose && !_isLegendPanelCollapsed) {
            _isLegendPanelCollapsed = true;
            changedPanels.add('legend');
          }
          _isDrawingToolbarCollapsed = !_isDrawingToolbarCollapsed;
          break;
        case 'layer':
          // 如果其他面板开启了自动关闭，则关闭它们
          if (_isDrawingToolbarAutoClose && !_isDrawingToolbarCollapsed) {
            _isDrawingToolbarCollapsed = true;
            changedPanels.add('drawing');
          }
          if (_isLegendPanelAutoClose && !_isLegendPanelCollapsed) {
            _isLegendPanelCollapsed = true;
            changedPanels.add('legend');
          }
          _isLayerPanelCollapsed = !_isLayerPanelCollapsed;
          break;        case 'legend':
          // 如果其他面板开启了自动关闭，则关闭它们
          if (_isDrawingToolbarAutoClose && !_isDrawingToolbarCollapsed) {
            _isDrawingToolbarCollapsed = true;
            changedPanels.add('drawing');
          }
          if (_isLayerPanelAutoClose && !_isLayerPanelCollapsed) {
            _isLayerPanelCollapsed = true;
            changedPanels.add('layer');
          }
          _isLegendPanelCollapsed = !_isLegendPanelCollapsed;
          break;
      }
    });
  }

  /// 构建图层面板的副标题
  String _buildLayerPanelSubtitle() {
    final hasSelectedLayer = _selectedLayer != null;
    final hasSelectedGroup = _selectedLayerGroup != null && _selectedLayerGroup!.isNotEmpty;
    
    if (hasSelectedLayer && hasSelectedGroup) {
      // 既选中图层又选中图层组
      return '图层: ${_selectedLayer!.name} | 组: ${_selectedLayerGroup!.map((layer) => layer.name).join(', ')}';
    } else if (hasSelectedLayer) {
      // 只选中图层
      return '当前: ${_selectedLayer!.name}';
    } else if (hasSelectedGroup) {
      // 只选中图层组
      return '图层组: ${_selectedLayerGroup!.map((layer) => layer.name).join(', ')}';
    } else {
      // 没有选择
      return '未选择图层';
    }}

  /// 处理自动关闭切换
  void _handleAutoCloseToggle(String panelType, bool value) {
    setState(() {
      switch (panelType) {
        case 'drawing':
          _isDrawingToolbarAutoClose = value;
          break;
        case 'layer':
          _isLayerPanelAutoClose = value;
          break;
        case 'legend':
          _isLegendPanelAutoClose = value;
          break;
      }
    });    // 保存到用户首选项
    if (mounted) {
      final prefsProvider = context.read<UserPreferencesProvider>();
      prefsProvider.updateLayout(
        panelAutoCloseStates: {
          ...prefsProvider.layout.panelAutoCloseStates,
          panelType: value,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefsProvider, child) {
        final l10n = AppLocalizations.of(context)!;
        final screenWidth = MediaQuery.of(context).size.width;
        final isNarrowScreen = screenWidth < 800; // 判断是否为窄屏

        return PopScope(
          canPop: false, // 阻止默认的返回行为
          onPopInvoked: (didPop) async {
            if (!didPop) {
              final shouldExit = await _showExitConfirmDialog();
              if (shouldExit && context.mounted) {
                context.pop(); // 使用 go_router 的方式退出
              }
            }
          },
          child: Focus(
            autofocus: true,
            onKey: _handleKeyEvent,            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight + 50), // 增加高度以容纳版本标签栏
                child: AppBar(
                  title: Text(
                    widget.isPreviewMode ? l10n.mapPreview : l10n.mapEditor,
                  ),
                  actions: [
                    ...[
                      WebFeatureRestriction(
                        operationName: '保存地图',
                        enabled: !kIsWeb,
                        child: IconButton(
                          onPressed: _isLoading || kIsWeb ? null : _saveMap,
                          icon: const Icon(Icons.save),
                          tooltip: kIsWeb ? 'Web版本为只读模式' : '保存地图',
                        ),
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
                                Text('标题: ${_currentMap?.title ?? "未知"}'),
                                Text('版本: v${_currentMap?.version ?? "0"}'),
                                Text('图层数量: ${_currentMap?.layers.length ?? 0}'),
                                Text(
                                  '图例组数量: ${_currentMap?.legendGroups.length ?? 0}',
                                ),
                                Text(
                                  '模式: ${widget.isPreviewMode ? "预览模式" : "编辑模式"}',
                                ),
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
                  bottom: _versionManager != null 
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(50),
                        child: VersionTabBar(
                          versions: _versionManager!.versions,
                          currentVersionId: _versionManager!.currentVersionId,
                          onVersionSelected: _switchVersion,
                          onVersionCreated: _createVersion,
                          onVersionDeleted: _deleteVersion,
                          isPreviewMode: widget.isPreviewMode,
                        ),
                      )
                    : null,
                ),
              ),
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        // 主要内容
                        isNarrowScreen
                            ? _buildNarrowScreenLayout(userPrefsProvider)
                            : _buildWideScreenLayout(userPrefsProvider),

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
                                onLegendGroupTapped:
                                    _showLegendGroupManagementDrawer,
                                onClose: _closeLayerLegendBindingDrawer,
                              ),
                            ),
                          ), // 图例组管理抽屉覆盖层
                        if (_isLegendGroupManagementDrawerOpen &&
                            _currentLegendGroupForManagement != null)
                          Positioned(
                            top: 16,
                            bottom: 16,
                            right: 16,
                            child: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(12),
                              child: LegendGroupManagementDrawer(
                                legendGroup: _currentLegendGroupForManagement!,
                                availableLegends: _availableLegends,
                                onLegendGroupUpdated: _updateLegendGroup,
                                isPreviewMode: widget.isPreviewMode,
                                onClose: _closeLegendGroupManagementDrawer,
                                onLegendItemSelected: _selectLegendItem,
                                allLayers:
                                    _currentMap?.layers, // 传递所有图层用于智能隐藏功能
                                selectedLayer: _selectedLayer, // 传递当前选中的图层
                                initialSelectedLegendItemId:
                                    _initialSelectedLegendItemId, // 传递初始选中的图例项ID
                                selectedElementId:
                                    _selectedElementId, // 传递当前选中的元素ID用于外部状态同步
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
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
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
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer,
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
                                          physics:
                                              const BouncingScrollPhysics(),
                                          child: ZIndexInspector(
                                            selectedLayer: _selectedLayer,
                                            onElementDeleted: _deleteElement,
                                            selectedElementId:
                                                _selectedElementId,
                                            onElementSelected: (elementId) {
                                              setState(
                                                () => _selectedElementId =
                                                    elementId,
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
                            _isFloatingToolbarVisible =
                                !_isFloatingToolbarVisible;
                          });
                        },
                        icon: AnimatedRotation(
                          turns: _isFloatingToolbarVisible ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isFloatingToolbarVisible
                                ? Icons.close
                                : Icons.menu,
                          ),
                        ),
                        label: Text(
                          _isFloatingToolbarVisible ? '关闭工具栏' : '工具栏',
                        ),
                        tooltip: _isFloatingToolbarVisible ? '关闭工具栏' : '打开工具栏',
                      ),
                    )
                  : null,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
            ), // 关闭 PopScope 的 child 参数
          ),
        );
      },
    );
  }

  List<Widget> _buildToolPanels(UserPreferencesProvider userPrefsProvider) {
    final List<Widget> panels = [];
    final layout = userPrefsProvider.layout;

    // 绘制工具栏（仅编辑模式）
    panels.add(
      _buildCollapsiblePanel(
        title: '绘制工具',
        icon: Icons.brush,
        isCollapsed: _isDrawingToolbarCollapsed,        onToggleCollapsed: () => _handlePanelToggle('drawing'),
        autoCloseEnabled: _isDrawingToolbarAutoClose,
        onAutoCloseToggled: (value) => _handleAutoCloseToggle('drawing', value),
        compactMode: layout.compactMode,
        showTooltips: layout.showTooltips,
        animationDuration: layout.animationDuration,
        enableAnimations: layout.enableAnimations,
        // 修改禁用状态提示逻辑
        collapsedSubtitle: _hasNoLayerSelected
            ? '需要选择图层才能使用绘制工具'
            : _selectedLayer != null
            ? '绘制到: ${_selectedLayer!.name}'
            : _selectedLayerGroup != null
            ? '选中图层组 (${_selectedLayerGroup!.length} 个图层)'
            : _selectedDrawingTool?.toString().split('.').last ?? '未选择工具',
        child: _isDrawingToolbarCollapsed
            ? null
            : Stack(
                children: [
                  // 绘制工具栏内容
                  DrawingToolbarOptimized(
                    selectedTool: _selectedDrawingTool,
                    selectedColor: _selectedColor,
                    selectedStrokeWidth: _selectedStrokeWidth,
                    selectedDensity: _selectedDensity,
                    selectedCurvature: _selectedCurvature,
                    selectedTriangleCut: _selectedTriangleCut,
                    isEditMode: true,
                    onToolSelected: (tool) {
                      if (!_shouldDisableDrawingTools) {
                        setState(() => _selectedDrawingTool = tool);
                      }
                    },
                    onColorSelected: (color) {
                      if (!_shouldDisableDrawingTools) {
                        setState(() => _selectedColor = color);
                      }
                    },
                    onStrokeWidthChanged: (width) {
                      if (!_shouldDisableDrawingTools) {
                        setState(() => _selectedStrokeWidth = width);
                      }
                    },
                    onDensityChanged: (density) {
                      if (!_shouldDisableDrawingTools) {
                        setState(() => _selectedDensity = density);
                      }
                    },
                    onCurvatureChanged: (curvature) {
                      if (!_shouldDisableDrawingTools) {
                        setState(() => _selectedCurvature = curvature);
                      }
                    },
                    onTriangleCutChanged: (triangleCut) {
                      if (!_shouldDisableDrawingTools) {
                        setState(() => _selectedTriangleCut = triangleCut);
                      }
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
                    // 图片缓冲区相关参数
                    imageBufferData: _imageBufferData,
                    imageBufferFit: _imageBufferFit,
                    onImageBufferUpdated: _handleImageBufferUpdated,
                    onImageBufferFitChanged: _handleImageBufferFitChanged,
                    onImageBufferCleared: _handleImageBufferCleared,
                  ),

                  // 修改禁用蒙板逻辑
                  if (_shouldDisableDrawingTools)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha((0.8 * 255).toInt()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.layers_outlined,
                                size: 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  '请先选择一个图层或图层组\n才能使用绘制工具',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _addNewLayer,
                                icon: const Icon(Icons.add),
                                label: const Text('添加新图层'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );

    // 图层面板
    panels.add(
      _buildCollapsiblePanel(
        title: '图层',
        icon: Icons.layers,
        isCollapsed: _isLayerPanelCollapsed,
        onToggleCollapsed: () => _handlePanelToggle('layer'),
        autoCloseEnabled: _isLayerPanelAutoClose,
        onAutoCloseToggled: (value) => _handleAutoCloseToggle('layer', value),
        // 修改折叠状态下的副标题显示逻辑
        collapsedSubtitle: _buildLayerPanelSubtitle(),
        compactMode: layout.compactMode,
        showTooltips: layout.showTooltips,
        animationDuration: layout.animationDuration,
        enableAnimations: layout.enableAnimations,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: _addNewLayer,
            tooltip: layout.showTooltips ? '添加图层' : null,
          ),
        ],
        child: _isLayerPanelCollapsed
            ? null
            : LayerPanel(
                layers: _currentMap?.layers ?? [],
                selectedLayerGroup: _selectedLayerGroup,
                onLayerGroupSelected: _onLayerGroupSelected,
                onSelectionCleared: _onSelectionCleared,
                selectedLayer: _selectedLayer,
                isPreviewMode: widget.isPreviewMode,
                onLayerSelected: _onLayerSelected,
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
                onLayerSelectionCleared: _onLayerSelectionCleared,
                //：图层组折叠状态相关参数
                groupCollapsedStates: _layerGroupCollapsedStates,
                onGroupCollapsedStatesChanged: (newStates) {
                  setState(() {
                    _layerGroupCollapsedStates = newStates;
                  });
                },
              ),
      ),
    );
    // 图例管理面板
    panels.add(
      _buildCollapsiblePanel(
        title: '图例管理',
        icon: Icons.legend_toggle,
        isCollapsed: _isLegendPanelCollapsed,
        onToggleCollapsed: () => _handlePanelToggle('legend'),
        autoCloseEnabled: _isLegendPanelAutoClose,
        onAutoCloseToggled: (value) => _handleAutoCloseToggle('legend', value),
        compactMode: layout.compactMode,
        showTooltips: layout.showTooltips,
        animationDuration: layout.animationDuration,
        enableAnimations: layout.enableAnimations,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: _addLegendGroup,
            tooltip: layout.showTooltips ? '添加图例组' : null,
          ),
        ],
        child: _isLegendPanelCollapsed
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
  }  Widget _buildCollapsiblePanel({
    required String title,
    required IconData icon,
    required bool isCollapsed,
    required VoidCallback onToggleCollapsed,
    Widget? child,
    List<Widget>? actions,
    bool autoCloseEnabled = true,
    ValueChanged<bool>? onAutoCloseToggled,
    String? collapsedSubtitle, // 折叠状态下显示的附加信息
    bool compactMode = false,
    bool showTooltips = true,
    int animationDuration = 300,
    bool enableAnimations = true,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrowScreen = screenWidth < 800;
    final double headerHeight = compactMode ? 40.0 : 48.0;

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
    }    return Expanded(
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest
                    .withAlpha((0.3 * 255).toInt()),
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
                  ],                ),
              ),
            ),            // 内容
            if (child != null)
              Expanded(
                child: child,
              ),
          ],
        ),
      ),
    );
  }
  /// 宽屏布局（传统横向布局）
  Widget _buildWideScreenLayout(UserPreferencesProvider userPrefsProvider) {
    final layout = userPrefsProvider.layout;
    final sidebarWidth = layout.sidebarWidth;

    return Row(
      children: [
        // 左侧工具面板 - 移除 SingleChildScrollView，改为不可滚动的固定容器
        SizedBox(
          width: sidebarWidth,
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          child: Column(children: _buildToolPanels(userPrefsProvider)),
        ),

        const VerticalDivider(),

        // 右侧地图画布
        Expanded(child: _buildMapCanvas()),
      ],
    );
  }

  /// 窄屏布局（悬浮工具栏）
  Widget _buildNarrowScreenLayout(UserPreferencesProvider userPrefsProvider) {
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
                  color: Colors.black.withAlpha((0.4 * 255).toInt()), // 稍微增加透明度
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
                  color: Colors.black.withAlpha((0.2 * 255).toInt()),
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
                    color: Theme.of(
                      context,
                    ).primaryColor.withAlpha((0.1 * 255).toInt()),
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
                ), // 工具面板内容
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _buildToolPanels(userPrefsProvider),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建地图画布组件
  Widget _buildMapCanvas() {
    if (_currentMap == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefsProvider, child) {
        // 创建用于显示的地图副本，使用重新排序的图层
        return MapCanvas(
          key: _mapCanvasKey, // 添加这一行
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
          onElementSelected: (elementId) {
            setState(() {
              _selectedElementId = elementId;
            });
          },
          backgroundPattern: context
              .read<UserPreferencesProvider>()
              .mapEditor
              .backgroundPattern,
          zoomSensitivity: context
              .read<UserPreferencesProvider>()
              .mapEditor
              .zoomSensitivity,
          shouldDisableDrawingTools: _shouldDisableDrawingTools,
          // 添加图片缓冲区数据
          imageBufferData: _imageBufferData,
          imageBufferFit: _imageBufferFit,
          displayOrderLayers: _layersForDisplay, //：传递显示顺序
        );
      },
    );
  }

  /// 处理键盘事件
  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    // 只处理按键按下事件
    if (event is! RawKeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // 获取用户偏好设置
    final userPrefs = context.read<UserPreferencesProvider>();
    final toolPrefs = userPrefs.tools;
    final copyShortcut = toolPrefs.shortcuts['copy'] ?? 'Ctrl+C';
    final undoShortcut = toolPrefs.shortcuts['undo'] ?? 'Ctrl+Z';
    final redoShortcut = toolPrefs.shortcuts['redo'] ?? 'Ctrl+Y';

    // 检查撤销快捷键
    if (_isShortcutPressed(event, undoShortcut)) {
      if (_canUndo) {
        _undo();
        return KeyEventResult.handled;
      }
    }

    // 检查重做快捷键
    if (_isShortcutPressed(event, redoShortcut)) {
      if (_canRedo) {
        _redo();
        return KeyEventResult.handled;
      }
    }

    // 检查复制快捷键
    if (_isShortcutPressed(event, copyShortcut)) {
      _handleCopySelection();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// 检查是否按下了指定的快捷键
  bool _isShortcutPressed(RawKeyEvent event, String shortcut) {
    final parts = shortcut.toLowerCase().split('+');
    final key = parts.last;
    final modifiers = parts.take(parts.length - 1).toList();

    // 检查主键
    bool keyMatch = false;
    switch (key) {
      case 'c':
        keyMatch = event.logicalKey == LogicalKeyboardKey.keyC;
        break;
      case 'v':
        keyMatch = event.logicalKey == LogicalKeyboardKey.keyV;
        break;
      case 'x':
        keyMatch = event.logicalKey == LogicalKeyboardKey.keyX;
        break;
      case 'z':
        keyMatch = event.logicalKey == LogicalKeyboardKey.keyZ;
        break;
      case 'y':
        keyMatch = event.logicalKey == LogicalKeyboardKey.keyY;
        break;
      default:
        return false;
    }

    if (!keyMatch) return false;

    // 检查修饰键
    bool ctrlRequired = modifiers.contains('ctrl');
    bool shiftRequired = modifiers.contains('shift');
    bool altRequired = modifiers.contains('alt');

    bool ctrlPressed = event.isControlPressed || event.isMetaPressed;
    bool shiftPressed = event.isShiftPressed;
    bool altPressed = event.isAltPressed;

    return (ctrlRequired == ctrlPressed) &&
        (shiftRequired == shiftPressed) &&
        (altRequired == altPressed);
  }

  /// 处理复制选区的逻辑
  Future<void> _handleCopySelection() async {
    // 检查是否有选区
    final mapCanvas = _mapCanvasKey.currentState;
    if (mapCanvas == null) {
      return;
    }

    final selectionRect = mapCanvas.currentSelectionRect;
    if (selectionRect == null) {
      // 没有选区时显示提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请先选择一个区域再复制'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    try {
      // 从画布捕获选区图像
      final imageData = await mapCanvas.captureCanvasAreaToRgbaUint8List(
        selectionRect,
      );
      if (imageData == null) {
        throw Exception('无法捕获画布区域');
      } // 复制到剪贴板
      final success = await ClipboardService.copyCanvasSelectionToClipboard(
        rgbaData: imageData,
        width: selectionRect.width.round(),
        height: selectionRect.height.round(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('选区已复制到剪贴板'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('复制到剪贴板失败'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('复制失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
