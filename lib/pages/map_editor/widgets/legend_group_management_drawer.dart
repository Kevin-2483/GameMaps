import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jovial_svg/jovial_svg.dart';
import '../../../models/map_layer.dart';
import '../../../models/legend_item.dart' as legend_db;
import '../../../components/vfs/vfs_file_picker_window.dart';
import '../../../services/vfs/vfs_file_opener_service.dart';
import '../../../services/legend_vfs/legend_vfs_service.dart'; // 导入图例VFS服务
import '../../../services/legend_cache_manager.dart'; // 导入图例缓存管理器
import '../../../components/common/tags_manager.dart';
import '../../../models/script_data.dart'; // 新增：导入脚本数据模型
import '../../../components/dialogs/script_parameters_dialog.dart'; // 新增：导入脚本参数对话框
import '../../../providers/user_preferences_provider.dart';
import '../../../services/reactive_version/reactive_version_manager.dart'; // 使用ReactiveVersionManager
import '../../../data/new_reactive_script_manager.dart'; // 导入新的响应式脚本管理器
import 'vfs_directory_tree_display.dart'; // 导入VFS目录树显示组件
import 'cached_legends_display.dart'; // 导入缓存图例显示组件
import '../../../services/notification/notification_service.dart';
import '../../../utils/legend_path_resolver.dart'; // 导入图例路径解析器
import '../../../data/map_data_bloc.dart'; // 导入MapDataBloc
import '../../../data/map_data_event.dart'; // 导入MapDataEvent
import '../../../data/map_data_state.dart'; // 导入MapDataState

/// 图例组管理抽屉
class LegendGroupManagementDrawer extends StatefulWidget {
  final String? mapId; // 地图ID，用于扩展设置隔离
  final LegendGroup legendGroup;
  final List<legend_db.LegendItem> availableLegends;
  final Function(LegendGroup) onLegendGroupUpdated;
  final bool isPreviewMode;
  final VoidCallback onClose; // 关闭回调
  final Function(String)? onLegendItemSelected; // 图例项选中回调
  final List<MapLayer>? allLayers; // 所有图层，用于智能隐藏功能
  final MapLayer? selectedLayer; // 当前选中的图层
  final List<MapLayer>? selectedLayerGroup; // 当前选中的图层组
  final String? initialSelectedLegendItemId; // 初始选中的图例项ID
  final String? selectedElementId; // 外部传入的选中元素ID，用于同步状态
  final List<ScriptData> scripts; // 新增：脚本列表
  final NewReactiveScriptManager scriptManager; // 新增：脚本管理器
  final Function(String, bool)? onSmartHideStateChanged;
  final bool Function(String)? getSmartHideState;
  final Function(String, double)? onZoomFactorChanged; // 缩放因子变更回调
  final double Function(String)? getZoomFactor; // 获取缩放因子的函数
  final ReactiveVersionManager versionManager; // 版本管理器
  final Function(String, Offset)? onLegendDragToCanvas; // 新增：拖拽到画布的回调
  final VoidCallback? onDragStart; // 新增：拖拽开始回调（用于关闭抽屉）
  final VoidCallback? onDragEnd; // 新增：拖拽结束回调（用于重新打开抽屉）
  final Function(bool isFocused)? onInputFieldFocusChanged; // 输入框焦点状态变化回调
  final String?
  defaultExpandedPanel; // 默认展开的面板：'settings', 'legendList', 'vfsTree', 'cacheDisplay'
  final String? absoluteMapPath; // 地图的绝对路径，用于图例路径占位符处理
  final MapDataBloc? mapDataBloc; // MapDataBloc实例，用于管理手动关闭状态
  final Function(LegendGroup)? onShowLayerBinding; // 显示图层绑定抽屉的回调

  const LegendGroupManagementDrawer({
    super.key,
    this.mapId, // 地图ID参数
    required this.legendGroup,
    required this.availableLegends,
    required this.onLegendGroupUpdated,
    this.isPreviewMode = false,
    required this.onClose,
    this.onLegendItemSelected,
    this.allLayers,
    this.selectedLayer,
    this.selectedLayerGroup,
    this.initialSelectedLegendItemId,
    this.selectedElementId,
    required this.scripts, // 新增：必传脚本列表
    required this.scriptManager, // 新增：必传脚本管理器
    this.onSmartHideStateChanged, // 新增：智能隐藏状态变更回调
    this.getSmartHideState, // 新增：获取智能隐藏状态的函数
    this.onZoomFactorChanged, // 缩放因子变更回调
    this.getZoomFactor, // 获取缩放因子的函数
    required this.versionManager, // 版本管理器参数
    this.onLegendDragToCanvas, // 新增：拖拽到画布的回调
    this.onDragStart, // 新增：拖拽开始回调
    this.onDragEnd, // 新增：拖拽结束回调
    this.onInputFieldFocusChanged, // 输入框焦点状态变化回调
    this.defaultExpandedPanel, // 默认展开的面板
    this.absoluteMapPath, // 地图的绝对路径
    this.mapDataBloc, // MapDataBloc实例
    this.onShowLayerBinding, // 显示图层绑定抽屉的回调
  });

  @override
  State<LegendGroupManagementDrawer> createState() =>
      _LegendGroupManagementDrawerState();
}

class _LegendGroupManagementDrawerState
    extends State<LegendGroupManagementDrawer> {
  String? _selectedLegendItemId; // 当前选中的图例项ID

  // 新增：折叠区域状态控制
  bool _isSettingsExpanded = false; // 设置选项是否展开
  bool _isLegendListExpanded = false; // 图例列表是否展开
  bool _isVfsTreeExpanded = false; // VFS目录树是否展开
  bool _isCacheDisplayExpanded = false; // 缓存显示是否展开

  /// 切换折叠面板状态，实现互斥展开（一次只能展开一个面板）
  void _togglePanel(String panelName) {
    setState(() {
      // 检查当前要切换的面板是否已经展开
      bool isCurrentPanelExpanded = false;
      switch (panelName) {
        case 'settings':
          isCurrentPanelExpanded = _isSettingsExpanded;
          break;
        case 'legendList':
          isCurrentPanelExpanded = _isLegendListExpanded;
          break;
        case 'vfsTree':
          isCurrentPanelExpanded = _isVfsTreeExpanded;
          break;
        case 'cacheDisplay':
          isCurrentPanelExpanded = _isCacheDisplayExpanded;
          break;
      }

      // 先关闭所有面板
      _isSettingsExpanded = false;
      _isLegendListExpanded = false;
      _isVfsTreeExpanded = false;
      _isCacheDisplayExpanded = false;

      // 如果当前面板之前是关闭的，则展开它；如果之前是展开的，则保持关闭状态
      if (!isCurrentPanelExpanded) {
        switch (panelName) {
          case 'settings':
            _isSettingsExpanded = true;
            break;
          case 'legendList':
            _isLegendListExpanded = true;
            // 如果展开的是图例列表，自动滚动到选中项
            _scrollToSelectedLegendItem();
            break;
          case 'vfsTree':
            _isVfsTreeExpanded = true;
            break;
          case 'cacheDisplay':
            _isCacheDisplayExpanded = true;
            break;
        }
      }
    });
  }

  /// 强制展开指定面板（不切换，总是展开）
  void _expandPanel(String panelName) {
    // debugPrint('_expandPanel 被调用: $panelName');
    // debugPrint('当前面板状态: legendList=$_isLegendListExpanded, vfsTree=$_isVfsTreeExpanded, cacheDisplay=$_isCacheDisplayExpanded');

    setState(() {
      // 先关闭所有面板
      _isSettingsExpanded = false;
      _isLegendListExpanded = false;
      _isVfsTreeExpanded = false;
      _isCacheDisplayExpanded = false;

      // 展开指定面板
      switch (panelName) {
        case 'settings':
          _isSettingsExpanded = true;
          break;
        case 'legendList':
          _isLegendListExpanded = true;
          // debugPrint('设置 _isLegendListExpanded = true');
          // 如果展开的是图例列表，自动滚动到选中项
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // debugPrint('延迟执行滚动到选中项: $_selectedLegendItemId');
            _scrollToSelectedLegendItem();
          });
          break;
        case 'vfsTree':
          _isVfsTreeExpanded = true;
          break;
        case 'cacheDisplay':
          _isCacheDisplayExpanded = true;
          break;
      }
    });

    // debugPrint('_expandPanel 完成，新状态: legendList=$_isLegendListExpanded, vfsTree=$_isVfsTreeExpanded, cacheDisplay=$_isCacheDisplayExpanded');
  }

  /// 滚动到选中的图例项
  void _scrollToSelectedLegendItem() {
    if (!_legendListScrollController.hasClients) {
      return;
    }

    // 如果有选中的图例项，滚动到该项
    if (_selectedLegendItemId != null) {
      final selectedIndex = widget.legendGroup.legendItems.indexWhere(
        (item) => item.id == _selectedLegendItemId,
      );

      if (selectedIndex != -1) {
        const itemHeight = 400.0;
        final scrollOffset = selectedIndex * itemHeight;

        // 确保滚动位置不超过最大滚动范围
        final maxScrollExtent =
            _legendListScrollController.position.maxScrollExtent;
        final targetOffset = scrollOffset > maxScrollExtent
            ? maxScrollExtent
            : scrollOffset;

        _legendListScrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return;
      }
    }

    // 如果没有选中项或找不到选中项，滚动到顶部
    _legendListScrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 新增：URL输入框控制器映射，用于管理每个图例项的输入框状态
  final Map<String, TextEditingController> _urlControllers = {};

  // 图例列表滚动控制器
  final ScrollController _legendListScrollController = ScrollController();

  // 通过getter访问智能隐藏状态
  bool get _isSmartHidingEnabled =>
      widget.getSmartHideState?.call(widget.legendGroup.id) ?? true;

  // 缩放因子相关状态
  double _currentZoomFactor = 1.0; // 默认值为1.0

  // 手动操作标记，防止智能隐藏逻辑覆盖用户操作
  bool _isManualOperation = false;

  /// 获取或创建URL输入框控制器
  TextEditingController _getUrlController(LegendItem item) {
    if (!_urlControllers.containsKey(item.id)) {
      _urlControllers[item.id] = TextEditingController(text: item.url ?? '');
    } else {
      // 如果控制器已存在，但URL值发生了变化，需要更新控制器的文本
      final controller = _urlControllers[item.id]!;
      final currentUrl = item.url ?? '';
      if (controller.text != currentUrl) {
        controller.text = currentUrl;
      }
    }
    return _urlControllers[item.id]!;
  }

  /// 清理不再使用的URL控制器
  void _cleanupUnusedControllers() {
    final currentItemIds = widget.legendGroup.legendItems
        .map((item) => item.id)
        .toSet();
    final controllersToRemove = <String>[];

    for (final itemId in _urlControllers.keys) {
      if (!currentItemIds.contains(itemId)) {
        controllersToRemove.add(itemId);
      }
    }

    for (final itemId in controllersToRemove) {
      _urlControllers[itemId]?.dispose();
      _urlControllers.remove(itemId);
    }
  }

  @override
  void initState() {
    super.initState();
    // 设置初始选中的图例项
    _selectedLegendItemId = widget.initialSelectedLegendItemId;

    // 根据传入的参数设置默认展开的面板
    _initializeDefaultExpandedPanel();

    // 版本管理器已通过widget传入，无需额外设置

    // 延迟执行检查，避免在初始化期间调用setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSmartHidingStateFromExtensionSettings();
      _loadZoomFactorFromParent();
      _checkSmartHiding();
    });
  }

  /// 初始化默认展开的面板
  void _initializeDefaultExpandedPanel() {
    // 先关闭所有面板
    _isSettingsExpanded = false;
    _isLegendListExpanded = false;
    _isVfsTreeExpanded = false;
    _isCacheDisplayExpanded = false;

    // 根据传入的参数展开指定面板，默认展开缓存显示
    switch (widget.defaultExpandedPanel) {
      case 'settings':
        _isSettingsExpanded = true;
        break;
      case 'legendList':
        _isLegendListExpanded = true;
        // 如果默认展开图例列表，延迟滚动到选中项
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToSelectedLegendItem();
        });
        break;
      case 'vfsTree':
        _isVfsTreeExpanded = true;
        break;
      case 'cacheDisplay':
      default:
        _isCacheDisplayExpanded = true;
        break;
    }
  }

  @override
  void dispose() {
    // 清理所有URL输入框控制器
    for (final controller in _urlControllers.values) {
      controller.dispose();
    }
    _urlControllers.clear();

    // 清理滚动控制器
    _legendListScrollController.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(LegendGroupManagementDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 检查图例组是否发生变化（ID变化或内容变化）
    bool needsUpdate = false;
    String reason = '';

    if (oldWidget.legendGroup.id != widget.legendGroup.id) {
      needsUpdate = true;
      reason = 'ID变化';
      // 清除选中的图例项，因为切换到了新的图例组
      _selectedLegendItemId = null;
    } else if (oldWidget.legendGroup.legendItems.length !=
        widget.legendGroup.legendItems.length) {
      needsUpdate = true;
      reason =
          '图例项数量变化: ${oldWidget.legendGroup.legendItems.length} -> ${widget.legendGroup.legendItems.length}';
    } else if (oldWidget.legendGroup.updatedAt !=
        widget.legendGroup.updatedAt) {
      needsUpdate = true;
      reason = '更新时间变化';
    }

    if (needsUpdate) {
      debugPrint('图例组管理抽屉更新: $reason');
      debugPrint('新图例组有 ${widget.legendGroup.legendItems.length} 个图例项');

      setState(() {
        // 状态更新：清理不再使用的控制器
      });

      // 清理不再存在的图例项的控制器
      _cleanupUnusedControllers();

      // 延迟执行检查，确保新图例组的智能隐藏逻辑正确应用
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSmartHidingStateFromExtensionSettings();
        _loadZoomFactorFromParent();
        _checkSmartHiding();
      });
    }

    // 如果地图ID发生变化，更新路径选择管理器的当前版本
    if (oldWidget.mapId != widget.mapId && widget.mapId != null) {
      debugPrint('地图ID变更: ${oldWidget.mapId} -> ${widget.mapId}');

      // 强制刷新VFS目录树状态
      setState(() {
        _isVfsTreeExpanded = true; // 自动展开目录树以便用户查看更新后的状态
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSmartHidingStateFromExtensionSettings();
        _loadZoomFactorFromParent();
        _checkSmartHiding();
      });
    }

    // 如果选中的图层发生变化，检查并清除不兼容的图例选择
    if (oldWidget.selectedLayer?.id != widget.selectedLayer?.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        clearIncompatibleLegendSelection();
      });
    }
    if (oldWidget.allLayers != widget.allLayers) {
      // 延迟执行检查，避免在build期间调用setState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkSmartHiding();
        // 同时检查图例选择的兼容性
        clearIncompatibleLegendSelection();
      });
    }

    // 如果外部选中元素ID发生变化，同步内部状态
    if (oldWidget.selectedElementId != widget.selectedElementId) {
      // 如果外部清除了选择（selectedElementId为null），同时清除内部选择
      if (widget.selectedElementId == null && _selectedLegendItemId != null) {
        setState(() {
          _selectedLegendItemId = null;
        });
      }
      // 如果外部选择了新元素，且该元素是图例项，同步选择
      else if (widget.selectedElementId != null) {
        // 检查选中的元素是否是当前图例组中的图例项
        final isLegendItemInCurrentGroup = widget.legendGroup.legendItems.any(
          (item) => item.id == widget.selectedElementId,
        );

        if (isLegendItemInCurrentGroup) {
          setState(() {
            _selectedLegendItemId = widget.selectedElementId;
          });
        }
      }
    }

    // 检查初始选中图例项ID是否发生变化
    if (oldWidget.initialSelectedLegendItemId !=
        widget.initialSelectedLegendItemId) {
      // debugPrint('didUpdateWidget: initialSelectedLegendItemId 变化: ${oldWidget.initialSelectedLegendItemId} -> ${widget.initialSelectedLegendItemId}');
      if (widget.initialSelectedLegendItemId != null) {
        setState(() {
          _selectedLegendItemId = widget.initialSelectedLegendItemId;
        });
      }
    }

    // 检查默认展开面板是否发生变化
    if (oldWidget.defaultExpandedPanel != widget.defaultExpandedPanel) {
      // debugPrint('didUpdateWidget: defaultExpandedPanel 变化: ${oldWidget.defaultExpandedPanel} -> ${widget.defaultExpandedPanel}');
      if (widget.defaultExpandedPanel == 'legendList') {
        // 延迟调用，避免在didUpdateWidget中直接调用setState
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // debugPrint('执行 _expandPanel(legendList)');
          _expandPanel('legendList');
        });
      }
    }
  }

  /// 外部调用：当图层状态发生变化时，检查智能隐藏逻辑
  void checkSmartHidingOnLayerChange() {
    // 延迟执行检查，确保不会在build期间调用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSmartHiding();
    });
  }

  /// 外部调用：清除不兼容的图例选择
  void clearIncompatibleLegendSelection() {
    // 如果没有选中的图例项，直接返回
    if (_selectedLegendItemId == null) return;

    // 检查当前选择是否仍然有效
    if (!_canSelectLegendItem()) {
      setState(() {
        _selectedLegendItemId = null;
      });
      // 通知父组件选中状态变化
      widget.onLegendItemSelected?.call('');
    }
  }

  // 检查图例项是否被选中
  bool _isLegendItemSelected(LegendItem item) {
    return _selectedLegendItemId == item.id;
  }

  // 选中图例项
  void _selectLegendItem(LegendItem item) {
    // 在选中前检查是否满足条件
    if (!_canSelectLegendItem()) {
      _showSelectionNotAllowedDialog();
      return;
    }

    setState(() {
      _selectedLegendItemId = _selectedLegendItemId == item.id ? null : item.id;
    });
    // 通知父组件选中状态变化，用于高亮显示地图上的图例项
    widget.onLegendItemSelected?.call(_selectedLegendItemId ?? '');
  }

  /// 判断是否可以选择图例项
  /// 灵活的选择条件：
  /// 1. 图例组可见
  /// 2. 如果有绑定图层被直接选中，允许选择
  /// 3. 如果没有绑定图层被直接选中，但选中的图层组包含绑定图层，允许选择
  /// 4. 如果没有选中任何图层或图层组，基于最高优先级图层组的绑定图层允许选择
  bool _canSelectLegendItem() {
    // 检查图例组是否可见
    if (!widget.legendGroup.isVisible) {
      return false;
    }

    // 如果没有提供图层信息，允许选择（兼容性）
    if (widget.allLayers == null || widget.allLayers!.isEmpty) {
      return true;
    }

    // 获取绑定的图层
    final boundLayers = _getBoundLayers();
    if (boundLayers.isEmpty) {
      return true; // 如果没有绑定图层，允许选择
    }

    // 条件2：检查绑定的图层中是否有被直接选中的
    if (widget.selectedLayer != null) {
      if (boundLayers.any((layer) => layer.id == widget.selectedLayer!.id)) {
        return true;
      }
    }

    // 条件3：检查选中的图层组是否包含绑定图层
    if (widget.selectedLayer != null ||
        (widget.allLayers != null && _getSelectedLayerGroup().isNotEmpty)) {
      final selectedGroup = _getSelectedLayerGroup();
      if (selectedGroup.isNotEmpty) {
        // 检查选中的图层组中是否包含绑定图层
        final selectedGroupIds = selectedGroup.map((l) => l.id).toSet();
        final boundLayerIds = boundLayers.map((l) => l.id).toSet();
        if (selectedGroupIds.intersection(boundLayerIds).isNotEmpty) {
          return true;
        }
      }
    }

    // 条件4：如果没有选中任何图层或图层组，基于最高优先级图层组的绑定图层允许选择
    if (widget.selectedLayer == null && _getSelectedLayerGroup().isEmpty) {
      final highestPriorityLayers = _getHighestPriorityLayers();
      if (highestPriorityLayers.isNotEmpty) {
        final highestPriorityIds = highestPriorityLayers
            .map((l) => l.id)
            .toSet();
        final boundLayerIds = boundLayers.map((l) => l.id).toSet();
        if (highestPriorityIds.intersection(boundLayerIds).isNotEmpty) {
          return true;
        }
      }
    }

    return false;
  }

  /// 获取选中的图层组
  List<MapLayer> _getSelectedLayerGroup() {
    // 使用传入的选中图层组信息
    if (widget.selectedLayerGroup != null &&
        widget.selectedLayerGroup!.isNotEmpty) {
      return widget.selectedLayerGroup!;
    }

    // 如果没有传入选中的图层组，返回基于显示顺序推断的最高优先级图层
    return _getHighestPriorityLayers();
  }

  /// 获取最高优先级的图层组（基于显示顺序或其他逻辑）
  List<MapLayer> _getHighestPriorityLayers() {
    if (widget.allLayers == null || widget.allLayers!.isEmpty) {
      return [];
    }

    // 按 order 字段排序，获取最高优先级的图层
    final sortedLayers = List<MapLayer>.from(widget.allLayers!)
      ..sort((a, b) => b.order.compareTo(a.order)); // 降序排列，最高优先级在前

    // 返回前几个可见的图层作为最高优先级图层
    return sortedLayers.where((layer) => layer.isVisible).take(3).toList();
  }

  /// 显示不允许选择的提示对话框
  void _showSelectionNotAllowedDialog() {
    String message = '';

    if (!widget.legendGroup.isVisible) {
      message = '无法选择图例：图例组当前不可见，请先显示图例组';
    } else {
      message = '无法选择图例：请先选择一个绑定了此图例组的图层';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择受限'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 更新图例项
  void _updateLegendItem(LegendItem updatedItem) {
    // 1. 从 widget.legendGroup 开始构建新列表
    final updatedItems = widget.legendGroup.legendItems.map((item) {
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();

    // 2. 基于 widget.legendGroup 创建新的图例组
    final newGroup = widget.legendGroup.copyWith(
      legendItems: updatedItems,
      updatedAt: DateTime.now(),
    );

    // 3. 【只】调用回调函数通知父组件，不调用 setState
    widget.onLegendGroupUpdated(newGroup);
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = context.watch<UserPreferencesProvider>();
    final drawerWidth = userPrefs.layout.drawerWidth;

    return Container(
      width: drawerWidth, // 使用用户偏好设置的抽屉宽度
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.legend_toggle,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.legendGroup.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showLayerBindingDialog,
                      icon: const Icon(Icons.layers, size: 16),
                      label: const Text('绑定图层'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // if (!widget.isPreviewMode)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: _showEditNameDialog,
                      tooltip: '编辑名称',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '管理图例组中的图例',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 可折叠的内容区域 - 使用平分空间的布局
          Expanded(
            child: Column(
              children: [
                // 设置选项 (可折叠)
                if (!_isSettingsExpanded)
                  Container(
                    height: 40.0,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: InkWell(
                      onTap: () => _togglePanel('settings'),
                      child: Row(
                        children: [
                          const Icon(Icons.settings, size: 18),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              '设置选项',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const Icon(Icons.expand_more, size: 18),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 40.0,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withAlpha((0.3 * 255).toInt()),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: InkWell(
                              onTap: () => _togglePanel('settings'),
                              child: const Row(
                                children: [
                                  Icon(Icons.settings, size: 18),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '设置选项',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.expand_less, size: 18),
                                ],
                              ),
                            ),
                          ),
                          _buildSettingsContent(),
                        ],
                      ),
                    ),
                  ),

                // VFS目录树 (可折叠)
                if (!_isVfsTreeExpanded)
                  Container(
                    height: 40.0,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: InkWell(
                      onTap: () => _togglePanel('vfsTree'),
                      child: Row(
                        children: [
                          const Icon(Icons.folder_outlined, size: 18),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'VFS图例目录',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const Icon(Icons.expand_more, size: 18),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 40.0,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withAlpha((0.3 * 255).toInt()),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: InkWell(
                              onTap: () => _togglePanel('vfsTree'),
                              child: const Row(
                                children: [
                                  Icon(Icons.folder_outlined, size: 18),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'VFS图例目录',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.expand_less, size: 18),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: VfsDirectoryTreeDisplay(
                                legendGroupId: widget.legendGroup.id,
                                versionManager: widget.versionManager,
                                onCacheCleared: _clearLegendCacheForFolder,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 缓存图例 (可折叠)
                if (!_isCacheDisplayExpanded)
                  Container(
                    height: 40.0,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: InkWell(
                      onTap: () => _togglePanel('cacheDisplay'),
                      child: Row(
                        children: [
                          const Icon(Icons.storage, size: 18),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              '缓存图例',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const Icon(Icons.expand_more, size: 18),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 40.0,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withAlpha((0.3 * 255).toInt()),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: InkWell(
                              onTap: () => _togglePanel('cacheDisplay'),
                              child: const Row(
                                children: [
                                  Icon(Icons.storage, size: 18),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '缓存图例',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.expand_less, size: 18),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: CachedLegendsDisplay(
                                onLegendSelected: _onCachedLegendSelected,
                                versionManager: widget.versionManager,
                                currentLegendGroupId: widget.legendGroup.id,
                                onDragStart: widget.onDragStart, // 传递拖拽开始回调
                                onDragEnd: widget.onDragEnd, // 传递拖拽结束回调
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 图例列表 (可折叠)
                if (!_isLegendListExpanded)
                  Container(
                    height: 40.0,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: InkWell(
                      onTap: () => _togglePanel('legendList'),
                      child: Row(
                        children: [
                          const Icon(Icons.legend_toggle, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '图例列表 (${widget.legendGroup.legendItems.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Icon(Icons.expand_more, size: 18),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 40.0,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withAlpha((0.3 * 255).toInt()),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: InkWell(
                              onTap: () => _togglePanel('legendList'),
                              child: Row(
                                children: [
                                  const Icon(Icons.legend_toggle, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '图例列表 (${widget.legendGroup.legendItems.length})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _showAddLegendDialog,
                                    icon: const Icon(Icons.add, size: 14),
                                    label: const Text('添加图例', style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.expand_less, size: 18),
                                ],
                              ),
                            ),
                          ),
                          _buildLegendListContent(),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItemTile(LegendItem item) {
    return FutureBuilder<legend_db.LegendItem?>(
      future: _loadLegendFromPath(item.legendPath),
      builder: (context, snapshot) {
        final legend =
            snapshot.data ??
            legend_db.LegendItem(
              title: '载入中...',
              centerX: 0.5,
              centerY: 0.5,
              version: 1,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _isLegendItemSelected(item)
                ? Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withAlpha((0.3 * 255).toInt())
                : null,
            borderRadius: BorderRadius.circular(12),
            border: _isLegendItemSelected(item)
                ? Border.all(color: Theme.of(context).colorScheme.primary)
                : Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _selectLegendItem(item),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 图例标题和操作按钮
                    Row(
                      children: [
                        // 图例图片预览
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isLegendItemSelected(item)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.3),
                              width: _isLegendItemSelected(item) ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: legend.hasImageData
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: _buildLegendThumbnail(legend),
                                )
                              : Icon(
                                  Icons.image,
                                  size: 24,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                        ),
                        const SizedBox(width: 12),
                        // 标题和信息
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                legend.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _isLegendItemSelected(item)
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '位置: (${item.position.dx.toStringAsFixed(2)}, ${item.position.dy.toStringAsFixed(2)})',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 可见性切换
                        IconButton(
                          icon: Icon(
                            item.isVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 18,
                            color: item.isVisible
                                ? null
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => _updateLegendItem(
                            item.copyWith(isVisible: !item.isVisible),
                          ),
                          // onPressed: widget.isPreviewMode
                          //     ? null
                          //     : () => _updateLegendItem(
                          //         item.copyWith(isVisible: !item.isVisible),
                          //       ),
                          tooltip: item.isVisible ? '隐藏' : '显示',
                        ),
                        // 更多操作
                        // if (!widget.isPreviewMode)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 16),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '删除',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteLegendItem(item);
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 控制滑块
                    // if (!widget.isPreviewMode)
                    ...[
                      // 大小控制
                      _buildSliderControl(
                        label: '大小',
                        value: item.size,
                        min: 0.1,
                        max: 3.0,
                        divisions: 29,
                        displayValue: '${item.size.toStringAsFixed(1)}x',
                        onChanged: (value) =>
                            _updateLegendItem(item.copyWith(size: value)),
                      ),

                      const SizedBox(height: 8),

                      // 旋转角度控制
                      _buildSliderControl(
                        label: '旋转',
                        value: item.rotation,
                        min: -180.0,
                        max: 180.0,
                        divisions: 72,
                        displayValue: '${item.rotation.toStringAsFixed(0)}°',
                        onChanged: (value) =>
                            _updateLegendItem(item.copyWith(rotation: value)),
                      ),
                      const SizedBox(height: 8),

                      // 透明度控制
                      _buildSliderControl(
                        label: '透明度',
                        value: item.opacity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        displayValue: '${(item.opacity * 100).round()}%',
                        onChanged: (value) =>
                            _updateLegendItem(item.copyWith(opacity: value)),
                      ),

                      const SizedBox(height: 12),

                      // URL编辑字段
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withAlpha((0.2 * 255).toInt()),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline
                                .withAlpha((0.2 * 255).toInt()),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '链接设置',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildUrlInputField(item),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 标签管理
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withAlpha((0.2 * 255).toInt()),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline
                                .withAlpha((0.2 * 255).toInt()),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.label,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '标签',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () => _editLegendItemTags(item),
                                  icon: const Icon(Icons.edit, size: 12),
                                  label: const Text(
                                    '编辑',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _buildLegendItemTagsDisplay(item.tags ?? []),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建URL输入字段
  Widget _buildUrlInputField(LegendItem item) {
    // 使用持久的控制器，避免每次重建时创建新的控制器
    final TextEditingController controller = _getUrlController(item);

    return Focus(
      onFocusChange: (hasFocus) {
        widget.onInputFieldFocusChanged?.call(hasFocus);
      },
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: '图例链接 (可选)',
          hintText: '输入网络链接、选择VFS文件或绑定脚本',
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            // 直接调用 _buildUrlActionButtons，不再需要传递 setState
            children: _buildUrlActionButtons(item, controller),
          ),
        ),
        style: const TextStyle(fontSize: 12),
        onChanged: (value) {
          final trimmedValue = value.trim();
          _updateLegendItem(
            trimmedValue.isEmpty
                ? item.copyWith(clearUrl: true)
                : item.copyWith(url: trimmedValue),
          );
        },
        onSubmitted: (value) {
          _updateUrlAndRefresh(item, value);
        },
        onEditingComplete: () {
          _updateUrlAndRefresh(item, controller.text);
        },
      ),
    );
  }

  /// 更新URL并刷新按钮显示
  void _updateUrlAndRefresh(LegendItem item, String value) {
    final trimmedValue = value.trim();
    _updateLegendItem(
      trimmedValue.isEmpty
          ? item.copyWith(clearUrl: true)
          : item.copyWith(url: trimmedValue),
    );
  }

  /// 构建URL操作按钮
  List<Widget> _buildUrlActionButtons(
    LegendItem item,
    TextEditingController controller,
  ) {
    final String? url = item.url;
    final bool isEmpty = url == null || url.isEmpty;
    final bool isScript = url != null && url.startsWith('script://');
    final bool isVfs =
        url != null &&
        (url.startsWith('indexeddb://') ||
            url.startsWith('{{MAP_DIR}}') ||
            url.contains('.legend'));
    final bool isHttp =
        url != null &&
        (url.startsWith('http://') || url.startsWith('https://'));

    List<Widget> buttons = [];

    if (isEmpty) {
      // 空状态：显示添加脚本和选择VFS文件按钮
      buttons.addAll([
        IconButton(
          icon: const Icon(Icons.code, size: 16),
          tooltip: '添加脚本',
          onPressed: () async {
            final selectedScript = await _showScriptPickerDialog();
            if (selectedScript != null) {
              await _bindScriptWithParameters(item, selectedScript);
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.folder, size: 16),
          tooltip: '选择VFS文件',
          onPressed: () async {
            final selectedFile = await _showVfsFilePicker();
            if (selectedFile != null) {
              _updateLegendItem(item.copyWith(url: selectedFile));
            }
          },
        ),
      ]);
    } else {
      // 有内容状态：根据链接类型显示不同按钮
      if (isScript) {
        // 脚本链接：显示脚本编辑按钮
        buttons.add(
          IconButton(
            icon: const Icon(Icons.code, size: 16),
            tooltip: '编辑脚本参数',
            onPressed: () async {
              await _editExistingScriptParameters(item);
            },
          ),
        );
      }

      if (isHttp || isVfs) {
        // 网络链接或VFS链接：显示打开链接按钮
        buttons.add(
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 16),
            tooltip: '打开链接',
            onPressed: () => _openUrl(url),
          ),
        );
      }

      // 所有非空状态都显示红色清空按钮
      buttons.add(
        IconButton(
          icon: const Icon(Icons.clear, size: 16),
          tooltip: '清空链接',
          color: Theme.of(context).colorScheme.error,
          onPressed: () {
            // 清空输入框内容
            controller.clear();
            // 更新数据模型
            _updateLegendItem(item.copyWith(clearUrl: true));
          },
        ),
      );
    }

    return buttons;
  }

  /// 构建图例缩略图组件
  Widget _buildLegendThumbnail(legend_db.LegendItem legend) {
    if (!legend.hasImageData) {
      return Icon(
        Icons.image,
        size: 24,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }

    // 检查是否为SVG格式
    if (legend.fileType == legend_db.LegendFileType.svg) {
      try {
        return ScalableImageWidget.fromSISource(
          si: ScalableImageSource.fromSvgHttpUrl(
            Uri.dataFromBytes(legend.imageData!, mimeType: 'image/svg+xml'),
          ),
          fit: BoxFit.contain,
        );
      } catch (e) {
        debugPrint('SVG图例缩略图加载失败: $e');
        return Icon(
          Icons.image_not_supported,
          size: 24,
          color: Theme.of(context).colorScheme.error,
        );
      }
    } else {
      // 普通图片格式
      return Image.memory(
        legend.imageData!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_not_supported,
            size: 24,
            color: Theme.of(context).colorScheme.error,
          );
        },
      );
    }
  }

  /// 从VFS路径载入图例数据
  Future<legend_db.LegendItem?> _loadLegendFromPath(String legendPath) async {
    if (legendPath.isEmpty || !legendPath.endsWith('.legend')) {
      return null;
    }

    try {
      final legendService = LegendVfsService();

      // 处理占位符路径，转换为实际路径
      final actualPath = LegendPathResolver.convertToActualPath(
        legendPath,
        widget.absoluteMapPath,
      );
      debugPrint('图例路径转换: $legendPath -> $actualPath');

      // 直接使用绝对路径，让legendService处理路径解析
      if (actualPath.startsWith('indexeddb://')) {
        // 传递完整的VFS路径给legendService
        debugPrint('加载图例: 绝对路径=$actualPath');
        return await legendService.getLegendFromAbsolutePath(actualPath);
      } else {
        // 兼容相对路径的旧逻辑
        final pathParts = actualPath.split('/');
        if (pathParts.isEmpty) return null;

        final fileName = pathParts.last;
        final title = fileName.replaceAll('.legend', '');
        final folderPath = pathParts.length > 1
            ? pathParts.sublist(0, pathParts.length - 1).join('/')
            : null;

        debugPrint(
          '加载图例: title=$title, folderPath=$folderPath, 相对路径=$actualPath',
        );
        return await legendService.getLegend(title, folderPath);
      }
    } catch (e) {
      debugPrint('载入图例失败: $legendPath, 错误: $e');
      return null;
    }
  }

  Widget _buildSliderControl({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            displayValue,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// 应用智能隐藏逻辑
  void _applySmartHidingLogic() {
    if (!_isSmartHidingEnabled) return; // 只有启用智能隐藏才应用逻辑
    if (!mounted) return; // 确保组件仍然挂载
    if (_isManualOperation) return; // 如果正在进行手动操作，跳过智能隐藏逻辑

    final shouldHide = _shouldSmartHideGroup();
    final shouldShow = _shouldSmartShowGroup();

    // 从MapDataBloc状态中获取手动关闭标记
    bool isManuallyClosedGroup = false;
    if (widget.mapDataBloc != null &&
        widget.mapDataBloc!.state is MapDataLoaded) {
      final state = widget.mapDataBloc!.state as MapDataLoaded;
      isManuallyClosedGroup =
          state.manuallyClosedLegendGroups[widget.legendGroup.id] ?? false;
    }

    // 双向智能控制：
    // 1. 当所有绑定图层都隐藏时，自动隐藏图例组（但不覆盖手动关闭的状态）
    if (shouldHide && widget.legendGroup.isVisible && !isManuallyClosedGroup) {
      final updatedGroup = widget.legendGroup.copyWith(
        isVisible: false,
        updatedAt: DateTime.now(),
      );
      widget.onLegendGroupUpdated(updatedGroup);
    }
    // 2. 当有绑定图层重新显示时，自动显示图例组（但不覆盖手动关闭的状态）
    else if (shouldShow &&
        !widget.legendGroup.isVisible &&
        !isManuallyClosedGroup) {
      final updatedGroup = widget.legendGroup.copyWith(
        isVisible: true,
        updatedAt: DateTime.now(),
      );
      widget.onLegendGroupUpdated(updatedGroup);
    }
  }

  void _showEditNameDialog() {
    final TextEditingController nameController = TextEditingController(
      text: widget.legendGroup.name,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑图例组名称'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '图例组名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final updatedGroup = widget.legendGroup.copyWith(
                  name: nameController.text.trim(),
                  updatedAt: DateTime.now(),
                );
                widget.onLegendGroupUpdated(updatedGroup);
                Navigator.of(context).pop();
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showAddLegendDialog() {
    String selectedLegendPath = '';
    // 设置更合理的默认位置 - 避免总是在中心，使用较为随机的初始位置
    final baseX = 0.2; // 左侧起始位置
    final baseY = 0.2; // 顶部起始位置
    final offsetX = (widget.legendGroup.legendItems.length * 0.1) % 0.6; // 水平偏移
    final offsetY =
        ((widget.legendGroup.legendItems.length ~/ 6) * 0.1) % 0.6; // 垂直偏移

    double positionX = (baseX + offsetX).clamp(0.1, 0.9);
    double positionY = (baseY + offsetY).clamp(0.1, 0.9);
    double size = 1.0;
    double rotation = 0.0;
    String url = ''; // 图例链接URL
    List<String> itemTags = []; // 图例项标签
    final urlController = TextEditingController(text: url);
    final legendPathController = TextEditingController(
      text: selectedLegendPath,
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加图例'),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // VFS图例路径选择
                TextField(
                  controller: legendPathController,
                  decoration: InputDecoration(
                    labelText: '图例路径 (.legend)',
                    hintText: '选择或输入.legend文件路径',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.folder_open),
                      tooltip: '选择图例文件',
                      onPressed: () async {
                        final selectedFile =
                            await VfsFileManagerWindow.showFilePicker(
                              context,
                              allowDirectorySelection: true,
                              selectionType: SelectionType.directoriesOnly,
                            );
                        if (selectedFile != null &&
                            selectedFile.endsWith('.legend')) {
                          setState(() {
                            selectedLegendPath = selectedFile;
                            legendPathController.text = selectedFile;
                          });
                        } else if (selectedFile != null && mounted) {
                          context.showErrorSnackBar('请选择.legend文件');
                        }
                      },
                    ),
                  ),
                  onChanged: (value) {
                    selectedLegendPath = value;
                  },
                ),
                const SizedBox(height: 16),

                // URL输入字段
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: '图例链接 (可选)',
                    hintText: '输入网络链接或选择VFS文件',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.folder),
                      tooltip: '选择VFS文件',
                      onPressed: () async {
                        final selectedFile = await _showVfsFilePicker();
                        if (selectedFile != null) {
                          setState(() {
                            url = selectedFile;
                            urlController.text = selectedFile;
                          });
                        }
                      },
                    ),
                  ),
                  onChanged: (value) {
                    url = value;
                  },
                ),
                const SizedBox(height: 16),

                // 标签管理
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.label,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '图例项标签',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _showLegendItemTagsDialog(itemTags)
                                .then((newTags) {
                                  if (newTags != null) {
                                    setState(() {
                                      itemTags = newTags;
                                    });
                                  }
                                }),
                            icon: const Icon(Icons.edit, size: 14),
                            label: const Text(
                              '管理',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItemTagsDisplay(itemTags),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'X坐标',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: positionX.toString(),
                        ),
                        onChanged: (value) {
                          positionX = double.tryParse(value) ?? positionX;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Y坐标',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: positionY.toString(),
                        ),
                        onChanged: (value) {
                          positionY = double.tryParse(value) ?? positionY;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: '大小',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: size.toString(),
                        ),
                        onChanged: (value) {
                          size = double.tryParse(value) ?? size;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: '旋转角度',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: rotation.toString(),
                        ),
                        onChanged: (value) {
                          rotation = double.tryParse(value) ?? rotation;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: selectedLegendPath.isNotEmpty
                  ? () {
                      // 从路径生成唯一的legendId
                      final pathSegments = selectedLegendPath.split('/');
                      final fileName = pathSegments.last.replaceAll(
                        '.legend',
                        '',
                      );
                      final timestamp = DateTime.now().microsecondsSinceEpoch;
                      final legendId = 'path_${fileName}_${timestamp}';

                      // 使用LegendPathResolver处理路径占位符
                      final storagePath =
                          LegendPathResolver.convertToStoragePath(
                            selectedLegendPath,
                            widget.absoluteMapPath,
                          );

                      final newItem = LegendItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        legendPath: storagePath,
                        legendId: legendId, // 生成向后兼容的legendId
                        position: Offset(positionX, positionY),
                        size: size,
                        rotation: rotation,
                        url: url.trim().isEmpty ? null : url.trim(), // 添加URL字段
                        tags: itemTags.isNotEmpty ? itemTags : null, // 添加标签字段
                        createdAt: DateTime.now(),
                      );

                      final updatedGroup = widget.legendGroup.copyWith(
                        legendItems: [
                          ...widget.legendGroup.legendItems,
                          newItem,
                        ],
                      );
                      final finalUpdatedGroup = updatedGroup.copyWith(
                        updatedAt: DateTime.now(),
                      );
                      widget.onLegendGroupUpdated(finalUpdatedGroup);
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteLegendItem(LegendItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图例'),
        content: const Text('确定要删除此图例吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedItems = widget.legendGroup.legendItems
                  .where((i) => i.id != item.id)
                  .toList();
              final updatedGroup = widget.legendGroup.copyWith(
                legendItems: updatedItems,
                updatedAt: DateTime.now(),
              );
              widget.onLegendGroupUpdated(updatedGroup);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  // 智能隐藏相关方法
  /// 检查智能隐藏状态
  void _checkSmartHiding() {
    // 智能隐藏开关状态不会自动改变，只能由用户手动控制
    // 这里只是检查如果启用了智能隐藏，是否需要应用智能隐藏逻辑
    if (_isSmartHidingEnabled) {
      _applySmartHidingLogic();
    }
  }

  /// 判断是否应该智能隐藏该图例组
  /// 条件：当所有绑定到该图例组的图层都隐藏时，返回true
  bool _shouldSmartHideGroup() {
    if (widget.allLayers == null || widget.allLayers!.isEmpty) {
      return false;
    }

    // 找到所有绑定了当前图例组的图层
    final boundLayers = widget.allLayers!.where((layer) {
      return layer.legendGroupIds.contains(widget.legendGroup.id);
    }).toList();

    // 如果没有图层绑定到这个图例组，不智能隐藏
    if (boundLayers.isEmpty) {
      return false;
    }

    // 检查所有绑定的图层是否都隐藏了
    return boundLayers.every((layer) => !layer.isVisible);
  }

  /// 判断是否应该智能显示该图例组
  /// 条件：当有任意绑定到该图例组的图层显示时，返回true
  bool _shouldSmartShowGroup() {
    if (widget.allLayers == null || widget.allLayers!.isEmpty) {
      return false;
    }

    // 找到所有绑定了当前图例组的图层
    final boundLayers = widget.allLayers!.where((layer) {
      return layer.legendGroupIds.contains(widget.legendGroup.id);
    }).toList();

    // 如果没有图层绑定到这个图例组，不智能显示
    if (boundLayers.isEmpty) {
      return false;
    }

    // 检查是否有任意绑定的图层是可见的
    return boundLayers.any((layer) => layer.isVisible);
  }

  /// 获取绑定了当前图例组的图层列表
  List<MapLayer> _getBoundLayers() {
    if (widget.allLayers == null) return [];
    return widget.allLayers!.where((layer) {
      return layer.legendGroupIds.contains(widget.legendGroup.id);
    }).toList();
  }

  /// 从扩展设置加载智能隐藏状态
  void _loadSmartHidingStateFromExtensionSettings() {
    // 智能隐藏状态现在由地图编辑器管理，不需要在这里处理
    // 状态通过 widget.getSmartHideState 回调获取
  }

  /// 从扩展设置加载缩放因子
  /// 从父组件加载缩放因子状态
  void _loadZoomFactorFromParent() {
    // 缩放因子状态由地图编辑器统一管理，通过回调获取
    final zoomFactor = widget.getZoomFactor?.call(widget.legendGroup.id) ?? 1.0;

    setState(() {
      _currentZoomFactor = zoomFactor;
    });
  }

  /// 通过回调保存缩放因子到父组件
  void _saveZoomFactorToExtensionSettings(double zoomFactor) {
    // 通过回调更新缩放因子状态，由地图编辑器统一管理和持久化
    widget.onZoomFactorChanged?.call(widget.legendGroup.id, zoomFactor);

    setState(() {
      _currentZoomFactor = zoomFactor;
    });
  }

  /// 重置缩放因子为默认值
  void _clearZoomFactorSetting() {
    // 通过回调重置缩放因子为默认值1.0，由地图编辑器统一管理
    widget.onZoomFactorChanged?.call(widget.legendGroup.id, 1.0);

    setState(() {
      _currentZoomFactor = 1.0;
    });
  }

  /// 切换智能隐藏开关
  void _toggleSmartHiding(bool enabled) {
    // 通过回调更新智能隐藏状态，由地图编辑器管理
    widget.onSmartHideStateChanged?.call(widget.legendGroup.id, enabled);

    // 如果启用智能隐藏，立即应用双向逻辑
    if (enabled) {
      final shouldHide = _shouldSmartHideGroup();
      final shouldShow = _shouldSmartShowGroup();

      if (shouldHide && widget.legendGroup.isVisible) {
        final updatedGroup = widget.legendGroup.copyWith(
          isVisible: false,
          updatedAt: DateTime.now(),
        );
        widget.onLegendGroupUpdated(updatedGroup);
      } else if (shouldShow && !widget.legendGroup.isVisible) {
        final updatedGroup = widget.legendGroup.copyWith(
          isVisible: true,
          updatedAt: DateTime.now(),
        );
        widget.onLegendGroupUpdated(updatedGroup);
      }
    }
    // 如果禁用智能隐藏，不改变当前显示状态，让用户手动控制
  }

  /// 构建智能隐藏的描述文本
  String _buildSmartHidingDescription() {
    final boundLayers = _getBoundLayers();

    if (boundLayers.isEmpty) {
      return '当前图例组未绑定任何图层';
    }

    final hiddenLayersCount = boundLayers
        .where((layer) => !layer.isVisible)
        .length;
    final totalLayersCount = boundLayers.length;

    if (_isSmartHidingEnabled) {
      if (hiddenLayersCount == totalLayersCount) {
        return '已启用：绑定的 $totalLayersCount 个图层均已隐藏，图例组已自动隐藏';
      } else {
        final visibleLayersCount = totalLayersCount - hiddenLayersCount;
        return '已启用：绑定的 $totalLayersCount 个图层中有 $visibleLayersCount 个可见，图例组已自动显示';
      }
    } else {
      return '启用后，根据绑定图层的可见性自动控制图例组显示/隐藏（共 $totalLayersCount 个图层）';
    }
  }

  /// 显示VFS文件选择器
  Future<String?> _showVfsFilePicker() async {
    try {
      final selectedFile = await VfsFileManagerWindow.showFilePicker(
        context,
        allowDirectorySelection: false,
        selectionType: SelectionType.filesOnly,
      );

      if (selectedFile != null) {
        // 自动转换为占位符路径（如果是地图子目录）
        final convertedPath = LegendPathResolver.convertToStoragePath(
          selectedFile,
          widget.absoluteMapPath,
        );
        return convertedPath;
      }

      return selectedFile;
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('文件选择失败: $e');
      }
      return null;
    }
  }

  /// 打开URL链接
  Future<void> _openUrl(String url) async {
    try {
      if (url.startsWith('indexeddb://')) {
        // VFS协议链接，使用VFS文件打开服务
        await VfsFileOpenerService.openFile(context, url);
      } else if (url.startsWith('{{MAP_DIR}}')) {
        // 占位符路径，先转换为实际路径再打开
        final actualPath = LegendPathResolver.convertToActualPath(
          url,
          widget.absoluteMapPath,
        );
        await VfsFileOpenerService.openFile(context, actualPath);
      } else if (url.startsWith('http://') || url.startsWith('https://')) {
        // 网络链接，使用系统默认浏览器
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showErrorMessage('无法打开链接: $url');
        }
      } else {
        _showErrorMessage('不支持的链接格式: $url');
      }
    } catch (e) {
      _showErrorMessage('打开链接失败: $e');
    }
  }

  /// 显示错误消息
  void _showErrorMessage(String message) {
    if (mounted) {
      context.showErrorSnackBar(message);
    }
  }

  /// 显示图例组标签管理对话框
  void _showTagsManagerDialog() async {
    final currentTags = widget.legendGroup.tags ?? [];

    final result = await TagsManagerUtils.showTagsDialog(
      context,
      initialTags: currentTags,
      title: '管理图例组标签 - ${widget.legendGroup.name}',
      maxTags: 10, // 限制最多10个标签
      suggestedTags: _getLegendGroupSuggestedTags(),
      tagValidator: TagsManagerUtils.defaultTagValidator,
      enableCustomTagsManagement: true,
    );

    if (result != null) {
      final updatedGroup = widget.legendGroup.copyWith(
        tags: result,
        updatedAt: DateTime.now(),
      );
      widget.onLegendGroupUpdated(updatedGroup);

      if (mounted) {
        if (result.isEmpty) {
          context.showInfoSnackBar('已清空图例组标签');
        } else {
          context.showSuccessSnackBar('图例组标签已更新 (${result.length}个标签)');
        }
      }
    }
  }

  /// 构建图例组标签显示
  Widget _buildTagsDisplay() {
    final tags = widget.legendGroup.tags ?? [];

    if (tags.isEmpty) {
      return Text(
        '暂无标签',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  /// 获取图例组建议标签
  List<String> _getLegendGroupSuggestedTags() {
    return [
      '建筑',
      '房间',
      '入口',
      '装置',
      '掩体',
      '路径',
      '标记',
      '战术',
      '重要',
      '可破坏',
      '陷阱',
      '监控',
    ];
  }

  /// 显示图例项标签管理对话框
  Future<List<String>?> _showLegendItemTagsDialog(
    List<String> currentTags,
  ) async {
    return await TagsManagerUtils.showTagsDialog(
      context,
      initialTags: currentTags,
      title: '管理图例项标签',
      maxTags: 10, // 限制最多10个标签
      suggestedTags: _getLegendItemSuggestedTags(),
      tagValidator: TagsManagerUtils.defaultTagValidator,
      enableCustomTagsManagement: true,
    );
  }

  /// 构建图例项标签显示
  Widget _buildLegendItemTagsDisplay(List<String> tags) {
    if (tags.isEmpty) {
      return Text(
        '暂无标签',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  /// 获取图例项建议标签
  List<String> _getLegendItemSuggestedTags() {
    return [
      '入口',
      '楼梯',
      '电梯',
      '窗户',
      '门',
      '墙',
      '掩体',
      '装置',
      '摄像头',
      '陷阱',
      '可破坏',
      '重要',
    ];
  }

  /// 编辑图例项标签
  void _editLegendItemTags(LegendItem item) async {
    final currentTags = item.tags ?? [];

    final result = await TagsManagerUtils.showTagsDialog(
      context,
      initialTags: currentTags,
      title: '管理图例项标签',
      maxTags: 10, // 限制最多10个标签
      suggestedTags: _getLegendItemSuggestedTags(),
      tagValidator: TagsManagerUtils.defaultTagValidator,
      enableCustomTagsManagement: true,
    );

    if (result != null) {
      // 如果用户清空了所有标签，使用clearTags参数来明确清空
      final updatedItem = result.isEmpty
          ? item.copyWith(clearTags: true)
          : item.copyWith(tags: result);
      _updateLegendItem(updatedItem);

      if (mounted) {
        if (result.isEmpty) {
          context.showInfoSnackBar('已清空图例项标签');
        } else {
          context.showSuccessSnackBar('图例项标签已更新 (${result.length}个标签)');
        }
      }
    }
  }

  // 新增：脚本选择弹窗
  Future<ScriptData?> _showScriptPickerDialog() async {
    // 中文注释：弹出脚本选择对话框，选中后返回ScriptData
    return await showDialog<ScriptData>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择要绑定的脚本'),
          content: SizedBox(
            width: 350,
            height: 400,
            child: widget.scripts.where((script) => script.isEnabled).isEmpty
                ? const Center(child: Text('暂无可用的启用脚本'))
                : ListView(
                    children: widget.scripts
                        .where((script) => script.isEnabled)
                        .map((script) {
                          return ListTile(
                            leading: const Icon(Icons.code),
                            title: Text(script.name),
                            subtitle: Text(
                              script.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => Navigator.of(context).pop(script),
                          );
                        })
                        .toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  // 新增：解析脚本URL
  Map<String, dynamic> _parseScriptUrl(String scriptUrl) {
    final uri = Uri.parse(scriptUrl);
    final scriptId = uri.host;
    final parameters = <String, dynamic>{};

    // 解析查询参数
    uri.queryParameters.forEach((key, value) {
      // 尝试解析为不同类型
      if (value.toLowerCase() == 'true') {
        parameters[key] = true;
      } else if (value.toLowerCase() == 'false') {
        parameters[key] = false;
      } else if (int.tryParse(value) != null) {
        parameters[key] = int.parse(value);
      } else if (double.tryParse(value) != null) {
        parameters[key] = double.parse(value);
      } else {
        parameters[key] = value;
      }
    });

    return {'scriptId': scriptId, 'parameters': parameters};
  }

  // 新增：编辑现有脚本参数
  Future<void> _editExistingScriptParameters(LegendItem item) async {
    if (item.url == null || !item.url!.startsWith('script://')) {
      return;
    }

    try {
      // 解析当前脚本URL
      final parsedUrl = _parseScriptUrl(item.url!);
      final scriptId = parsedUrl['scriptId'] as String;
      final currentParameters = parsedUrl['parameters'] as Map<String, dynamic>;

      // 查找对应的脚本
      final script = widget.scripts.firstWhere(
        (s) => s.id == scriptId,
        orElse: () => throw Exception('未找到脚本ID: $scriptId'),
      );

      // 解析脚本参数定义
      final scriptParameters = widget.scriptManager.parseScriptParameters(
        script.content,
      );

      if (scriptParameters.isNotEmpty) {
        // 显示参数编辑对话框，使用当前参数作为初始值
        final runtimeParameters = await ScriptParametersDialog.show(
          context,
          parameters: scriptParameters,
          initialValues: currentParameters,
          scriptName: script.name,
        );

        // 如果用户取消了参数设置，不进行更新
        if (runtimeParameters == null) {
          return;
        }

        // 重新构建脚本URL
        String newScriptUrl = 'script://$scriptId';
        final paramString = runtimeParameters.entries
            .map(
              (entry) =>
                  '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}',
            )
            .join('&');

        if (paramString.isNotEmpty) {
          newScriptUrl += '?$paramString';
        }

        // 更新图例项的URL
        _updateLegendItem(item.copyWith(url: newScriptUrl));

        if (mounted) {
          context.showSuccessSnackBar('已更新脚本参数: ${script.name}');
        }
      } else {
        if (mounted) {
          context.showInfoSnackBar('脚本 ${script.name} 无需参数');
        }
      }
    } catch (e) {
      debugPrint('编辑脚本参数失败: $e');
      if (mounted) {
        context.showErrorSnackBar('编辑脚本参数失败: $e');
      }
    }
  }

  // 新增：绑定脚本并处理参数
  Future<void> _bindScriptWithParameters(
    LegendItem item,
    ScriptData script,
  ) async {
    try {
      // 获取脚本参数
      final parameters = script.parameters;

      String scriptUrl = 'script://${script.id}';

      // 解析脚本参数定义
      final scriptParameters = widget.scriptManager.parseScriptParameters(
        script.content,
      );

      // 如果脚本有参数，显示参数设置对话框
      if (scriptParameters.isNotEmpty) {
        final runtimeParameters = await ScriptParametersDialog.show(
          context,
          parameters: scriptParameters,
          initialValues: parameters, // 使用现有参数作为初始值
          scriptName: script.name,
        );

        // 如果用户取消了参数设置，不进行绑定
        if (runtimeParameters == null) {
          return;
        }

        // 将参数编码到URL中
        final paramString = runtimeParameters.entries
            .map(
              (entry) =>
                  '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}',
            )
            .join('&');

        if (paramString.isNotEmpty) {
          scriptUrl += '?$paramString';
        }
      }

      // 更新图例项的URL
      _updateLegendItem(item.copyWith(url: scriptUrl));

      if (mounted) {
        context.showSuccessSnackBar('已绑定脚本: ${script.name}');
      }
    } catch (e) {
      debugPrint('绑定脚本失败: $e');
      if (mounted) {
        context.showErrorSnackBar('绑定脚本失败: $e');
      }
    }
  }

  /// 构建可折叠面板，使用与地图编辑器主页面相同的模式

  /// 构建设置内容
  Widget _buildSettingsContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 可见性和透明度控制
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    widget.legendGroup.isVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 18,
                  ),
                  onPressed: () {
                    final newVisibility = !widget.legendGroup.isVisible;

                    // 先设置本地标记，防止智能隐藏逻辑立即覆盖
                    _isManualOperation = true;

                    // 通过MapDataBloc设置手动关闭标记
                    if (widget.mapDataBloc != null) {
                      widget.mapDataBloc!.add(
                        SetLegendGroupManuallyClosedFlag(
                          groupId: widget.legendGroup.id,
                          isManuallyClosed: !newVisibility,
                        ),
                      );
                    }

                    final updatedGroup = widget.legendGroup.copyWith(
                      isVisible: newVisibility,
                      updatedAt: DateTime.now(),
                    );
                    widget.onLegendGroupUpdated(updatedGroup);

                    // 延迟重置手动操作标记
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) {
                        _isManualOperation = false;
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('透明度:', style: TextStyle(fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: widget.legendGroup.opacity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(widget.legendGroup.opacity * 100).round()}%',
                    onChanged: (value) {
                      final updatedGroup = widget.legendGroup.copyWith(
                        opacity: value,
                        updatedAt: DateTime.now(),
                      );
                      widget.onLegendGroupUpdated(updatedGroup);
                    },
                  ),
                ),
              ],
            ),

            // 智能隐藏设置
            if (widget.allLayers != null && widget.allLayers!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest
                      .withAlpha((0.3 * 255).toInt()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withAlpha((0.2 * 255).toInt()),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '智能隐藏',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isSmartHidingEnabled,
                          onChanged: _toggleSmartHiding,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSmartHidingDescription(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 缩放因子设置
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest
                    .withAlpha((0.3 * 255).toInt()),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withAlpha((0.2 * 255).toInt()),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.zoom_in,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '缩放因子',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      if (_currentZoomFactor != 1.0)
                        IconButton(
                          onPressed: _clearZoomFactorSetting,
                          icon: const Icon(Icons.clear, size: 16),
                          tooltip: '重置为默认值 (1.0)',
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '0.3',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: _currentZoomFactor.clamp(0.3, 3.0),
                              min: 0.3,
                              max: 3.0,
                              divisions: 27, // (3.0 - 0.3) / 0.1 = 27
                              label: _currentZoomFactor.toStringAsFixed(1),
                              onChanged: (value) {
                                setState(() {
                                  _currentZoomFactor = value;
                                });
                              },
                              onChangeEnd: (value) {
                                _saveZoomFactorToExtensionSettings(value);
                              },
                            ),
                          ),
                          Text(
                            '3.0',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '当前值: ${_currentZoomFactor.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '新拖拽的图例将根据此缩放因子和当前画布缩放级别自动调整大小',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // 标签管理
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.label,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '图例组标签',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                if (!widget.isPreviewMode)
                  TextButton.icon(
                    onPressed: _showTagsManagerDialog,
                    icon: const Icon(Icons.edit, size: 14),
                    label: const Text('管理', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTagsDisplay(),
          ],
        ),
      ),
    );
  }

  /// 构建图例列表内容
  Widget _buildLegendListContent() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: widget.legendGroup.legendItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.legend_toggle_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '此图例组暂无图例',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                controller: _legendListScrollController,
                itemCount: widget.legendGroup.legendItems.length,
                itemBuilder: (context, index) {
                  return _buildLegendItemTile(
                    widget.legendGroup.legendItems[index],
                  );
                },
              ),
      ),
    );
  }

  /// 清理指定目录下的图例缓存 - 步进型清理，智能排除正在使用的图例
  void _clearLegendCacheForFolder(String folderPath) {
    // 获取当前图例组中正在使用的图例路径
    final usedLegendPaths = widget.legendGroup.legendItems
        .map((item) => item.legendPath)
        .toSet();

    // 检查目录中的图例是否在当前图例组中使用（精确匹配该目录）
    final usedPathsInThisFolder = usedLegendPaths.where((path) {
      // 检查路径是否属于当前清理的目录
      if (folderPath.isEmpty) {
        // 根目录：检查路径是否没有"/"（即直接在根目录下）
        return !path.contains('/');
      } else {
        // 特定目录：检查路径是否以"folderPath/"开头，且是直接在该目录下
        if (path.startsWith('$folderPath/')) {
          final relativePath = path.substring(folderPath.length + 1);
          // 只考虑直接在该目录下的文件（不包含子目录）
          return !relativePath.contains('/');
        }
        return false;
      }
    }).toList();

    if (usedPathsInThisFolder.isNotEmpty) {
      // 如果有图例在使用，显示信息但继续清理（排除正在使用的）
      context.showInfoSnackBar(
        '目录 "$folderPath" 中有 ${usedPathsInThisFolder.length} 个图例正在使用，将排除这些图例进行清理',
      );
    }

    try {
      // 使用步进型缓存管理器清理该目录下的图例缓存（不递归清理子目录）
      // 排除当前图例组正在使用的路径
      LegendCacheManager().clearCacheByFolderStepwise(
        folderPath,
        excludePaths: usedLegendPaths,
      );

      // 通知用户清理完成
      context.showSuccessSnackBar(
        '已清理目录 "$folderPath" 下的图例缓存（排除 ${usedPathsInThisFolder.length} 个正在使用的图例）',
      );

      debugPrint(
        '智能清理完成: 目录=$folderPath, 排除=${usedPathsInThisFolder.length}个正在使用的图例',
      );
      debugPrint('排除的图例路径: $usedPathsInThisFolder');
    } catch (e) {
      // 清理失败显示错误消息
      context.showErrorSnackBar('清理缓存失败: $e');
    }
  }

  /// 处理缓存图例选择
  void _onCachedLegendSelected(String legendPath) {
    // 这里可以添加将缓存图例添加到当前图例组的逻辑
    // 或者直接应用图例到地图的逻辑
    debugPrint('选择了缓存图例: $legendPath');

    // 通知父组件选中状态变化
    widget.onLegendItemSelected?.call(legendPath);
  }

  /// 显示图层绑定抽屉
  void _showLayerBindingDialog() {
    if (widget.allLayers == null || widget.allLayers!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无可用图层')),
      );
      return;
    }

    // 调用父组件的回调来显示图层绑定抽屉
    widget.onShowLayerBinding?.call(widget.legendGroup);
  }


}
