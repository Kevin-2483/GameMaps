import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/map_item.dart';
import '../../models/map_layer.dart';
import '../../providers/user_preferences_provider.dart';
import 'widgets/shortcuts_dialog.dart';
import 'widgets/layer_export_dialog.dart';
import 'utils/keyboard_shortcuts_manager.dart';
import 'utils/keyboard_shortcut_actions.dart';
import '../../services/vfs_map_storage/vfs_map_service_factory.dart';
import '../../services/vfs_map_storage/vfs_map_service.dart';

import '../../l10n/app_localizations.dart';
import '../../components/layout/main_layout.dart';
// import '../../components/web/web_readonly_components.dart';
import '../../components/common/draggable_title_bar.dart';
import '../../utils/extension_settings_managers.dart';
// import '../../config/config_manager.dart';
import 'widgets/map_canvas.dart';
import 'widgets/layer_panel.dart';
import 'widgets/legend_panel.dart';
import 'widgets/drawing_toolbar.dart';
import 'widgets/layer_legend_binding_drawer.dart';
import 'widgets/layer_binding_drawer.dart';
import 'widgets/legend_group_management_drawer.dart';
import 'widgets/z_index_inspector.dart';
import 'widgets/reactive_version_tab_bar.dart';
import 'widgets/sticky_note_panel.dart';
import 'widgets/radial_menu_integration.dart';
import 'widgets/editor_status_bar.dart';
import 'widgets/legend_dock_bar.dart';
import 'widgets/drawing_tools_dock_bar.dart';
// import '../../components/common/radial_gesture_menu.dart';
import '../../models/sticky_note.dart';
// import '../../services/version_session_manager.dart';
import '../../services/reactive_version/reactive_version_adapter.dart';
import '../../models/script_data.dart';
// import 'widgets/script_panel.dart';
import 'widgets/reactive_script_panel.dart';
import '../../data/map_editor_reactive_integration.dart';
import '../../data/map_data_state.dart';
import '../../data/new_reactive_script_manager.dart';
import '../../services/legend_cache_manager.dart';
import '../../services/script_template_service.dart';
import '../../components/color_filter_dialog.dart';
import '../../components/common/window_controls.dart';
import '../../widgets/compact_timer_widget.dart';
import '../../../services/notification/notification_service.dart';
import '../../utils/legend_path_resolver.dart'; // 导入图例路径解析器
import '../../collaboration/mixins/auto_presence_mixin.dart'; // 导入在线状态管理混入
import '../../collaboration/services/websocket/websocket_client_manager.dart'; // 导入WebSocket客户端管理器

class MapEditorPage extends BasePage {
  final MapItem? mapItem; // 可选的预加载地图数据
  final String? mapTitle; // 地图标题，用于按需加载
  final String? folderPath; // 地图所在文件夹路径
  final String? absoluteMapPath; // 地图的绝对路径
  final bool isPreviewMode;

  const MapEditorPage({
    super.key,
    this.mapItem,
    this.mapTitle,
    this.folderPath,
    this.absoluteMapPath,
    this.isPreviewMode = false,
  }) : assert(
         mapItem != null || mapTitle != null,
         'Either mapItem or mapTitle must be provided',
       );
  @override
  bool get showTrayNavigation => false; // 禁用 TrayNavigation

  @override
  Widget buildContent(BuildContext context) {
    return _MapEditorContent(
      mapItem: mapItem,
      mapTitle: mapTitle,
      folderPath: folderPath,
      absoluteMapPath: absoluteMapPath,
      isPreviewMode: isPreviewMode,
    );
  }
}

class _MapEditorContent extends StatefulWidget {
  final MapItem? mapItem;
  final String? mapTitle;
  final String? folderPath;
  final String? absoluteMapPath;
  final bool isPreviewMode;

  const _MapEditorContent({
    this.mapItem,
    this.mapTitle,
    this.folderPath,
    this.absoluteMapPath,
    this.isPreviewMode = false,
  });

  @override
  State<_MapEditorContent> createState() => _MapEditorContentState();
}

class _MapEditorContentState extends State<_MapEditorContent>
    with MapEditorReactiveMixin, ReactiveVersionMixin, AutoPresenceMixin
    implements KeyboardShortcutCallbacks {
  // 缓存的客户端信息
  String? _cachedClientId;
  String? _cachedClientName;

  // 实现AutoPresenceMixin的抽象方法
  @override
  String getCurrentClientId() {
    return _cachedClientId ?? 'unknown_client';
  }

  @override
  String getCurrentUserName() {
    // 优先使用用户偏好设置中的显示名称
    try {
      final userPreferencesProvider = Provider.of<UserPreferencesProvider>(
        context,
        listen: false,
      );
      final userPreferences = userPreferencesProvider.currentPreferences;
      if (userPreferences != null && userPreferences.displayName.isNotEmpty) {
        return userPreferences.displayName;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('获取用户偏好设置显示名称失败: $e');
      }
    }

    // 回退到WebSocket客户端配置中的显示名称
    return _cachedClientName ?? '未知客户端';
  }

  /// 异步获取并缓存客户端信息
  Future<void> _loadClientInfo() async {
    try {
      final manager = WebSocketClientManager();
      final activeConfig = await manager.getActiveConfig();
      if (activeConfig != null) {
        setState(() {
          _cachedClientId = activeConfig.clientId;
          _cachedClientName = activeConfig.displayName;
        });
        if (kDebugMode) {
          debugPrint(
            '客户端信息已加载: ID=${activeConfig.clientId}, Name=${activeConfig.displayName}',
          );
        }
      } else {
        if (kDebugMode) {
          debugPrint('未找到活跃的客户端配置');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('获取客户端信息失败: $e');
      }
    }
  }

  @override
  Bloc<dynamic, dynamic>? getMapDataBloc() {
    return reactiveIntegration.mapDataBloc;
  }

  final GlobalKey<MapCanvasState> _mapCanvasKey = GlobalKey<MapCanvasState>();
  MapItem? _currentMap; // 可能为空，需要加载
  final VfsMapService _vfsMapService =
      VfsMapServiceFactory.createVfsMapService();
  // 移除图例数据库服务，改为按需载入
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
  bool _isMenuButtonDown = false; // 中键按下状态

  // 工具栏折叠状态
  bool _isDrawingToolbarCollapsed = false;
  bool _isLayerPanelCollapsed = false;
  bool _isLegendPanelCollapsed = false;
  bool _isStickyNotePanelCollapsed = false;
  bool _isScriptPanelCollapsed = false;

  //：图层组折叠状态
  Map<String, bool> _layerGroupCollapsedStates = {};
  // 自动关闭开关状态
  bool _isDrawingToolbarAutoClose = true;
  bool _isLayerPanelAutoClose = true;
  bool _isLegendPanelAutoClose = true;
  bool _isStickyNotePanelAutoClose = true;
  bool _isScriptPanelAutoClose = true;

  // 侧边栏折叠状态
  bool _isSidebarCollapsed = false;

  // 输入框焦点状态，用于控制快捷键启用/禁用
  bool _isInputFieldFocused = false;

  // 主焦点节点，用于管理快捷键
  late FocusNode _mainFocusNode;

  /// 设置输入框焦点状态
  void _setInputFieldFocused(bool focused) {
    debugPrint('DEBUG: Setting _isInputFieldFocused to $focused');
    setState(() {
      _isInputFieldFocused = focused;
    });

    // 当输入框失去焦点时，确保主FocusNode重新获得焦点
    if (!focused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mainFocusNode.requestFocus();
        debugPrint('DEBUG: Requested focus back to main FocusNode');
      });
    }
  }

  // 透明度预览状态
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
  bool _isLayerBindingDrawerOpen = false; // 新增：图层绑定抽屉状态
  bool _isZIndexInspectorOpen = false;
  MapLayer? _currentLayerForBinding;
  List<LegendGroup>? _allLegendGroupsForBinding;
  LegendGroup? _currentLegendGroupForBinding; // 新增：当前用于图层绑定的图例组
  LegendGroup? _currentLegendGroupForManagement;
  String? _initialSelectedLegendItemId; // 初始选中的图例项ID
  String? _defaultExpandedPanel; // 默认展开的面板  // 撤销/重做历史记录管理（已迁移到响应式系统）
  // final List<MapItem> _undoHistory = [];
  // final List<MapItem> _redoHistory = [];

  // 版本管理（已迁移到响应式系统）
  // MapVersionManager? _versionManager;
  // bool _hasUnsavedVersionChanges = false;  // 动态获取撤销历史记录数量限制（已废弃，使用响应式系统）
  // int get _maxUndoHistory {
  //   final provider = context.read<UserPreferencesProvider>();
  //   return provider.mapEditor.undoHistoryLimit;
  // }

  // 数据变更跟踪
  bool _hasUnsavedChanges = false;
  // 面板状态变更跟踪
  bool _panelStatesChanged = false;
  // 便签管理状态
  StickyNote? _selectedStickyNote; // 当前选中的便签
  final Map<String, double> _previewStickyNoteOpacityValues = {}; // 便签透明度预览状态

  // 智能隐藏状态管理（从抽屉迁移到地图编辑器）
  final Map<String, bool> _legendGroupSmartHideStates = {}; // 图例组智能隐藏状态

  // 缩放因子状态管理（统一管理）
  final Map<String, double> _legendGroupZoomFactors = {}; // 图例组缩放因子状态

  bool _isDragTemporaryHidden = false; // 标记抽屉是否因拖拽而临时隐藏
  LegendGroup? _hiddenLegendGroupForDrag; // 保存因拖拽而隐藏的图例组
  bool _wasDrawerOpenBeforeDrag = false; // 保存拖拽前抽屉的开启状态

  // 快捷键动作实例
  KeyboardShortcutActions? _keyboardShortcutActions;

  // 十字线功能状态
  bool _isCrosshairEnabled = false;

  @override
  void dispose() {
    // 在页面销毁时尝试保存面板状态（异步但不等待）
    if (_panelStatesChanged && mounted) {
      _savePanelStatesOnExit().catchError((e) {
        debugPrint('在dispose中保存面板状态失败: $e');
      });
    }

    // 保存智能隐藏状态到扩展存储（现在使用保存的引用，不访问context）
    if (_currentMap != null) {
      _saveLegendGroupSmartHideStatesOnExit().catchError((e) {
        debugPrint('在dispose中保存智能隐藏状态失败: $e');
      });

      // 保存缩放因子状态到扩展存储
      _saveLegendGroupZoomFactorsOnExit().catchError((e) {
        debugPrint('在dispose中保存缩放因子状态失败: $e');
      });
    }

    // 清理图例缓存管理器的所有缓存
    try {
      LegendCacheManager().clearAllCache();
      debugPrint('地图编辑器退出：已清理所有图例缓存');
    } catch (e) {
      debugPrint('在dispose中清理图例缓存失败: $e');
    }

    // 清理颜色滤镜会话管理器的所有滤镜
    try {
      ColorFilterSessionManager().clearAllFilters();
      debugPrint('地图编辑器退出：已清理所有颜色滤镜');
    } catch (e) {
      debugPrint('在dispose中清理颜色滤镜失败: $e');
    }

    // 释放在线状态管理资源
    disposeCollaboration();
    debugPrint('在线状态管理资源已释放');

    // 释放响应式系统资源
    disposeReactiveIntegration();

    // 释放响应式版本管理资源（包括路径选择状态清理）
    disposeVersionManagement();

    // 释放主焦点节点
    _mainFocusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _mainFocusNode = FocusNode();
    _initializeMapAndReactiveSystem();
    _initializeLayoutFromPreferences();
    // 先异步加载客户端信息，然后初始化在线状态管理
    _initializeWithClientInfo();
    // 脚本管理器现在通过响应式系统自动初始化
  }

  /// 先加载客户端信息，然后初始化协作
  Future<void> _initializeWithClientInfo() async {
    await _loadClientInfo();
    initializeCollaboration();
  }

  // 添加用户偏好设置提供者的引用
  UserPreferencesProvider? _userPreferencesProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在这里安全地获取UserPreferencesProvider的引用
    _userPreferencesProvider = context.read<UserPreferencesProvider>();
  }

  /// 初始化图例组智能隐藏状态
  void _initializeLegendGroupSmartHideStates() {
    if (_currentMap == null) return;

    // 使用保存的引用而不是context.read
    final enableExtensionStorage =
        _userPreferencesProvider?.layout.enableExtensionStorage ?? false;

    if (enableExtensionStorage) {
      // 扩展储存功能开启时，从扩展设置加载状态
      for (final group in _currentMap!.legendGroups) {
        final savedState = LegendGroupSmartHideManager.getSmartHideEnabled(
          _currentMap!.title,
          group.id,
        );
        _legendGroupSmartHideStates[group.id] = savedState;
      }
    } else {
      // 扩展储存功能关闭时，所有图例组默认开启智能隐藏
      for (final group in _currentMap!.legendGroups) {
        _legendGroupSmartHideStates[group.id] = true;
      }
    }

    debugPrint('图例组智能隐藏状态已初始化: $_legendGroupSmartHideStates');
  }

  /// 初始化图例组缩放因子状态
  void _initializeLegendGroupZoomFactors() {
    if (_currentMap == null) return;

    // 使用保存的引用而不是context.read
    final enableExtensionStorage =
        _userPreferencesProvider?.layout.enableExtensionStorage ?? false;

    if (enableExtensionStorage) {
      // 扩展储存功能开启时，从扩展设置加载状态
      for (final group in _currentMap!.legendGroups) {
        final savedZoomFactor = LegendGroupZoomFactorManager.getZoomFactor(
          _currentMap!.title,
          group.id,
        );
        _legendGroupZoomFactors[group.id] = savedZoomFactor;
      }
    } else {
      // 扩展储存功能关闭时，所有图例组默认使用1.0缩放因子
      for (final group in _currentMap!.legendGroups) {
        _legendGroupZoomFactors[group.id] = 1.0;
      }
    }

    debugPrint('图例组缩放因子状态已初始化: $_legendGroupZoomFactors');
  }

  /// 获取图例组智能隐藏状态
  bool getLegendGroupSmartHideState(String legendGroupId) {
    return _legendGroupSmartHideStates[legendGroupId] ?? true;
  }

  /// 设置图例组智能隐藏状态
  void setLegendGroupSmartHideState(String legendGroupId, bool enabled) {
    setState(() {
      _legendGroupSmartHideStates[legendGroupId] = enabled;
    });

    // 使用保存的引用而不是context.read
    final enableExtensionStorage =
        _userPreferencesProvider?.layout.enableExtensionStorage ?? false;

    // 只有扩展储存功能开启时才保存到扩展设置
    if (enableExtensionStorage && _currentMap != null) {
      LegendGroupSmartHideManager.setSmartHideEnabled(
        _currentMap!.title,
        legendGroupId,
        enabled,
      );
    }

    debugPrint('图例组 $legendGroupId 智能隐藏状态已更新: $enabled');
  }

  /// 获取图例组缩放因子
  double getLegendGroupZoomFactor(String legendGroupId) {
    return _legendGroupZoomFactors[legendGroupId] ?? 1.0;
  }

  /// 设置图例组缩放因子
  void setLegendGroupZoomFactor(String legendGroupId, double zoomFactor) {
    setState(() {
      _legendGroupZoomFactors[legendGroupId] = zoomFactor;
    });

    // 使用保存的引用而不是context.read
    final enableExtensionStorage =
        _userPreferencesProvider?.layout.enableExtensionStorage ?? false;

    // 只有扩展储存功能开启时才保存到扩展设置
    if (enableExtensionStorage && _currentMap != null) {
      LegendGroupZoomFactorManager.setZoomFactor(
        _currentMap!.title,
        legendGroupId,
        zoomFactor,
      );
    }

    debugPrint('图例组 $legendGroupId 缩放因子已更新: $zoomFactor');
  }

  /// 处理从缓存拖拽图例到画布
  void _handleLegendDragToCanvas(String legendPath, Offset canvasPosition) {
    // 找到当前打开的图例组管理抽屉对应的图例组
    if (_currentLegendGroupForManagement != null) {
      // 生成完全唯一的ID - 使用更高精度的时间戳和随机数
      final now = DateTime.now();
      final timestamp = now.millisecondsSinceEpoch;
      final randomSuffix = (now.microsecond * 1000 + (timestamp % 1000))
          .toString();

      // 从路径生成legendId - 确保每次都不同
      final pathSegments = legendPath.split('/');
      final fileName = pathSegments.last.replaceAll('.legend', '');
      final legendId = 'drag_${fileName}_${timestamp}_${randomSuffix}';
      final itemId = 'item_${timestamp}_${randomSuffix}';

      // 计算图例大小 - 根据用户偏好设置和缩放因子
      double legendSize = 1.0; // 默认大小

      // 获取用户偏好设置中的默认图例大小
      final defaultLegendSize =
          _userPreferencesProvider?.mapEditor.defaultLegendSize ?? 0.0;

      if (defaultLegendSize == 0.0) {
        // 使用动态公式：1/(缩放*系数)
        final currentZoomLevel =
            _mapCanvasKey.currentState?.getCurrentZoomLevel() ?? 1.0;
        final zoomFactor = getLegendGroupZoomFactor(
          _currentLegendGroupForManagement!.id,
        );
        legendSize = zoomFactor / currentZoomLevel;
        debugPrint(
          '使用动态公式计算图例大小: zoomFactor=$zoomFactor, currentZoom=$currentZoomLevel, legendSize=$legendSize',
        );
      } else {
        // 使用固定大小
        legendSize = defaultLegendSize;
        debugPrint('使用固定图例大小: $legendSize');
      }

      // 使用LegendPathResolver处理路径占位符
      final storagePath = LegendPathResolver.convertToStoragePath(
        legendPath,
        widget.absoluteMapPath,
      );

      // 创建新的图例项
      final newItem = LegendItem(
        id: itemId,
        legendPath: storagePath,
        legendId: legendId,
        position: canvasPosition, // 使用拖拽的位置
        size: legendSize, // 根据缩放因子计算的大小
        rotation: 0.0, // 默认旋转
        opacity: 1.0, // 默认透明度
        isVisible: true, // 默认可见
        createdAt: now,
      );

      // 创建新的图例项列表 - 确保是新的列表实例
      final currentItems = List<LegendItem>.from(
        _currentLegendGroupForManagement!.legendItems,
      );
      currentItems.add(newItem);

      // 添加到当前图例组
      final updatedGroup = _currentLegendGroupForManagement!.copyWith(
        legendItems: currentItems,
        updatedAt: now,
      );

      debugPrint(
        '拖拽添加图例项到地图编辑器: ID=${newItem.id}, legendId=${newItem.legendId}',
      );
      debugPrint(
        '更新前图例数量: ${_currentLegendGroupForManagement!.legendItems.length}',
      );
      debugPrint('更新后图例数量: ${updatedGroup.legendItems.length}');

      // 更新图例组
      _updateLegendGroup(updatedGroup);

      // 显示成功提示
      if (mounted) {
        context.showSuccessSnackBar(
          '已将图例添加到 ${updatedGroup.name} (${updatedGroup.legendItems.length}个图例)',
        );
      }

      debugPrint('从缓存拖拽添加图例: $legendPath 到位置: $canvasPosition');
    }
  }

  /// 处理拖拽开始 - 临时关闭抽屉
  void _handleDragStart() {
    if (_isLegendGroupManagementDrawerOpen && !_isDragTemporaryHidden) {
      debugPrint('拖拽开始：临时关闭图例组管理抽屉');
      setState(() {
        _isDragTemporaryHidden = true;
        _hiddenLegendGroupForDrag = _currentLegendGroupForManagement;
        _wasDrawerOpenBeforeDrag = true;
      });
    }
  }

  /// 处理拖拽结束 - 重新打开抽屉
  void _handleDragEnd() {
    debugPrint('拖拽结束：检查是否需要重新打开图例组管理抽屉');
    debugPrint('  _isDragTemporaryHidden: $_isDragTemporaryHidden');
    debugPrint('  _wasDrawerOpenBeforeDrag: $_wasDrawerOpenBeforeDrag');
    debugPrint('  _hiddenLegendGroupForDrag: $_hiddenLegendGroupForDrag');

    if (_isDragTemporaryHidden && _wasDrawerOpenBeforeDrag) {
      debugPrint('拖拽结束：重新打开图例组管理抽屉');
      setState(() {
        _isDragTemporaryHidden = false;
        // 保持原来的状态不变，只取消临时隐藏
        _wasDrawerOpenBeforeDrag = false;
        _hiddenLegendGroupForDrag = null;
      });
    }
  }

  /// 退出时保存智能隐藏状态
  Future<void> _saveLegendGroupSmartHideStatesOnExit() async {
    if (_currentMap == null || _userPreferencesProvider == null) return;

    final enableExtensionStorage =
        _userPreferencesProvider!.layout.enableExtensionStorage;

    if (!enableExtensionStorage) return;

    try {
      // 清理此地图的旧设置
      await LegendGroupSmartHideManager.clearAllSmartHideSettings(
        _currentMap!.title,
      );

      // 重新序列化当前状态，只保存当前存在的图例组
      final currentGroupIds = _currentMap!.legendGroups
          .map((g) => g.id)
          .toSet();
      for (final entry in _legendGroupSmartHideStates.entries) {
        if (currentGroupIds.contains(entry.key)) {
          await LegendGroupSmartHideManager.setSmartHideEnabled(
            _currentMap!.title,
            entry.key,
            entry.value,
          );
        }
      }

      debugPrint('地图 ${_currentMap!.title} 的图例组智能隐藏状态已保存');
    } catch (e) {
      debugPrint('保存图例组智能隐藏状态失败: $e');
    }
  }

  /// 退出时保存缩放因子状态
  Future<void> _saveLegendGroupZoomFactorsOnExit() async {
    if (_currentMap == null || _userPreferencesProvider == null) return;

    final enableExtensionStorage =
        _userPreferencesProvider!.layout.enableExtensionStorage;

    if (!enableExtensionStorage) return;

    try {
      // 清理此地图的旧设置
      await LegendGroupZoomFactorManager.clearAllZoomFactors(
        _currentMap!.title,
      );

      // 重新序列化当前状态，只保存当前存在的图例组
      final currentGroupIds = _currentMap!.legendGroups
          .map((g) => g.id)
          .toSet();
      for (final entry in _legendGroupZoomFactors.entries) {
        if (currentGroupIds.contains(entry.key)) {
          await LegendGroupZoomFactorManager.setZoomFactor(
            _currentMap!.title,
            entry.key,
            entry.value,
          );
        }
      }

      debugPrint('地图 ${_currentMap!.title} 的图例组缩放因子状态已保存');
    } catch (e) {
      debugPrint('保存图例组缩放因子状态失败: $e');
    }
  }

  /// 同步初始化地图和响应式系统
  void _initializeMapAndReactiveSystem() async {
    setState(() => _isLoading = true);

    try {
      // 1. 首先初始化响应式系统（传递地图绝对路径）
      await initializeReactiveSystem(mapAbsolutePath: widget.absoluteMapPath);
      debugPrint('响应式系统初始化完成');

      // 2. 然后加载地图数据
      await _loadMapData();

      // 3. 将地图数据立即加载到响应式系统
      if (_currentMap != null) {
        await loadMapToReactiveSystem(_currentMap!);
        debugPrint('地图数据已加载到响应式系统: ${_currentMap!.title}');

        // 4. 设置响应式监听器，确保数据同步
        _setupReactiveListeners();

        // 5. 立即初始化响应式版本管理系统
        await _initializeReactiveVersionManagement();

        // 6. 初始化在线状态管理
        await initializeCollaboration();
        debugPrint('在线状态管理初始化完成');

        // 7. 进入地图编辑器模式，设置地图信息用于协作
        await enterMapEditor(
          mapId: _currentMap!.id?.toString() ?? _currentMap!.title,
          mapTitle: _currentMap!.title,
          mapCover: _currentMap!.imageData,
        );
        debugPrint('已进入地图编辑器协作模式: ${_currentMap!.title}');
      } // 8. 重新初始化脚本引擎以确保外部函数声明正确
      await reactiveIntegration.newScriptManager.initialize();
      debugPrint('新脚本引擎重新初始化完成');

      // 9. 初始化键盘快捷键操作实例
      _initializeKeyboardShortcutActions();
      debugPrint('键盘快捷键操作实例初始化完成');
    } catch (e) {
      _showErrorSnackBar('初始化地图失败: ${e.toString()}');
      debugPrint('地图和响应式系统初始化失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 分离的地图数据加载方法
  Future<void> _loadMapData() async {
    try {
      // 如果已有 mapItem，直接使用；否则通过 mapTitle 从数据库加载
      if (widget.mapItem != null) {
        _currentMap = widget.mapItem!;
      } else if (widget.mapTitle != null) {
        final loadedMap = await _vfsMapService.getMapByTitle(
          widget.mapTitle!,
          widget.folderPath,
        );
        if (loadedMap == null) {
          throw Exception('未找到标题为 "${widget.mapTitle}" 的地图');
        }
        _currentMap = loadedMap;
      } else {
        throw Exception('mapItem 和 mapTitle 都为空');
      }

      // 移除预载图例，改为按需载入

      // 如果没有图层，创建一个默认图层
      if (_currentMap!.layers.isEmpty) {
        _addDefaultLayer();
      }

      // 预加载所有图层的图片
      _preloadAllLayerImages(); // 更新脚本管理器的地图数据访问器
      _updateScriptMapDataAccessor();

      // 新的脚本管理器会通过响应式系统自动获取地图数据
      // 无需手动设置地图标题

      // 初始化图例组智能隐藏状态（在地图数据加载完成后）
      _initializeLegendGroupSmartHideStates();

      // 初始化图例组缩放因子状态
      _initializeLegendGroupZoomFactors();

      debugPrint('地图数据加载完成: ${_currentMap!.title}');
    } catch (e) {
      debugPrint('加载地图数据失败: $e');
      rethrow;
    }
  }

  /// 初始化键盘快捷键操作实例
  void _initializeKeyboardShortcutActions() {
    _keyboardShortcutActions = KeyboardShortcutActions(
      context: context,
      setState: () => setState(() {}),
      getCurrentMap: () => _currentMap,
      getSelectedLayer: () => _selectedLayer,
      getSelectedLayerGroup: () => _selectedLayerGroup,
      getCurrentDrawingTargetLayer: () => _getCurrentDrawingTargetLayer(),
      getCurrentLegendGroupForManagement: () =>
          _currentLegendGroupForManagement,
      getIsLegendGroupManagementDrawerOpen: () =>
          _isLegendGroupManagementDrawerOpen,
      getIsLayerLegendBindingDrawerOpen: () => _isLayerLegendBindingDrawerOpen,
      getIsSidebarCollapsed: () => _isSidebarCollapsed,
      getIsZIndexInspectorOpen: () => _isZIndexInspectorOpen,
      getMapCanvasKey: () => _mapCanvasKey,
      canUndoReactive: () => canUndoReactive,
      canRedoReactive: () => canRedoReactive,
      undoReactive: undoReactive,
      redoReactive: redoReactive,
      updateLayer: _updateLayer,
      updateLegendGroup: _updateLegendGroup,
      setSelectedLayer: (layer) => setState(() => _selectedLayer = layer),
      setSelectedLayerGroup: (layerGroup) =>
          setState(() => _selectedLayerGroup = layerGroup),
      setIsSidebarCollapsed: (collapsed) =>
          setState(() => _isSidebarCollapsed = collapsed),
      setIsZIndexInspectorOpen: (open) =>
          setState(() => _isZIndexInspectorOpen = open),
      setIsLegendGroupManagementDrawerOpen: (open) =>
          setState(() => _isLegendGroupManagementDrawerOpen = open),
      setIsLayerLegendBindingDrawerOpen: (open) =>
          setState(() => _isLayerLegendBindingDrawerOpen = open),
      setCurrentLegendGroupForManagement: (group) =>
          setState(() => _currentLegendGroupForManagement = group),
      setCurrentLayerForBinding: (layer) =>
          setState(() => _currentLayerForBinding = layer),
      setAllLegendGroupsForBinding: (groups) =>
          setState(() => _allLegendGroupsForBinding = groups),
      setInitialSelectedLegendItemId: (id) =>
          setState(() => _initialSelectedLegendItemId = id),
      getAllVersionStates: () => allVersionStates,
      getCurrentVersionId: () => currentVersionId,
      switchVersion: (versionId) => switchVersion(versionId),
      createVersion: (name) async {
        final versionId = 'version_${DateTime.now().millisecondsSinceEpoch}';
        await createVersion(versionId, versionName: name);
      },
      prioritizeLayerAndGroupDisplay: _prioritizeLayerAndGroupDisplay,
      clearCanvasSelection: () => _mapCanvasKey.currentState?.clearSelection(),
      getLayerGroups: () => _groupLinkedLayers(),
      getBoundLegendGroups: () => _currentMap?.legendGroups ?? [],
      showLegendGroupManagementDrawer: _showLegendGroupManagementDrawer,
      closeLegendGroupManagementDrawer: _closeLegendGroupManagementDrawer,
      saveWithReactiveVersions: _saveWithReactiveVersions,
      vfsMapService: _vfsMapService,
      folderPath: widget.folderPath ?? '',
    );
  }

  /// 初始化响应式版本管理系统
  Future<void> _initializeReactiveVersionManagement() async {
    if (_currentMap == null) {
      debugPrint('无法初始化响应式版本管理：当前地图为空');
      return;
    }

    try {
      debugPrint('开始初始化响应式版本管理，地图标题: ${_currentMap!.title}');

      // 初始化响应式版本管理（重构后通过集成适配器）
      initializeVersionManagement(
        mapTitle: _currentMap!.title,
        integrationAdapter: reactiveIntegration.adapter,
        folderPath: widget.folderPath,
      );

      debugPrint('响应式版本管理器已创建');

      // 加载VFS中所有已存储的版本
      await _loadExistingVersionsFromVfs(); // 确保默认版本存在并开始编辑
      bool shouldStartEditingDefault = false;
      if (!allVersionStates.any((v) => v.versionId == 'default')) {
        final defaultVersionState = await createVersion(
          'default',
          versionName: '默认版本',
        );
        debugPrint('默认版本已创建: ${defaultVersionState?.versionId}');
        // 新创建的版本会自动切换并开始编辑，不需要额外设置
      } else {
        debugPrint('默认版本已存在');
        shouldStartEditingDefault = true;
      }

      // 关键修复：确保始终有一个版本在编辑状态
      // 如果没有正在编辑的版本，开始编辑适当的版本
      if (versionAdapter?.versionManager.activeEditingVersionId == null) {
        if (shouldStartEditingDefault ||
            allVersionStates.any((v) => v.versionId == 'default')) {
          versionAdapter?.versionManager.startEditingVersion('default');
          debugPrint('开始编辑默认版本以确保数据同步正常工作');
        } else if (allVersionStates.isNotEmpty) {
          // 如果没有默认版本但有其他版本，开始编辑第一个版本
          final firstVersionId = allVersionStates.first.versionId;
          versionAdapter?.versionManager.startEditingVersion(firstVersionId);
          debugPrint('开始编辑第一个可用版本: $firstVersionId');
        }
      }

      // 关键修复：初始化完成后，立即同步当前响应式数据到版本系统
      // 确保响应式系统的当前数据和版本系统保持一致
      await _syncCurrentDataToVersionSystem();

      // 触发UI更新以显示版本标签栏
      if (mounted) {
        setState(() {
          // 触发重建以显示版本信息
        });
      }

      // 添加版本管理器状态监听
      if (versionAdapter != null) {
        versionAdapter!.versionManager.addListener(() {
          if (mounted) {
            setState(() {
              // 当版本状态变化时，触发UI重建
            });
            debugPrint('版本状态已更新，版本数量: ${allVersionStates.length}');
          }
        });
      }

      debugPrint('响应式版本管理系统初始化完成，当前版本: $currentVersionId');
    } catch (e) {
      debugPrint('响应式版本管理初始化失败: $e');
    }
  }

  Future<void> _syncCurrentDataToVersionSystem() async {
    try {
      // 获取当前响应式系统的数据状态
      final currentMapData = getCurrentMapData();
      if (currentMapData == null) {
        debugPrint('当前响应式系统没有数据，跳过同步');
        return;
      }

      // 获取当前正在编辑的版本ID
      final activeVersionId =
          versionAdapter?.versionManager.activeEditingVersionId;
      if (activeVersionId == null) {
        debugPrint('没有正在编辑的版本，跳过数据同步到版本系统');
        return;
      }

      // 构建完整的地图数据
      final mapItemToSync = currentMapData.mapItem.copyWith(
        layers: currentMapData.layers,
        legendGroups: currentMapData.legendGroups,
        stickyNotes: currentMapData.mapItem.stickyNotes,
        updatedAt: DateTime.now(),
      );

      // 更新版本数据，但不标记为已修改（因为这是初始同步）
      versionAdapter?.versionManager.updateVersionData(
        activeVersionId,
        mapItemToSync,
        markAsChanged: false, // 初始同步不标记为已修改
      );

      debugPrint(
        '初始数据同步完成 [$activeVersionId], 图层数: ${mapItemToSync.layers.length}, 便签数: ${mapItemToSync.stickyNotes.length}',
      );

      // 详细日志：便签绘画元素数量
      for (int i = 0; i < mapItemToSync.stickyNotes.length; i++) {
        final note = mapItemToSync.stickyNotes[i];
        debugPrint('  同步便签[$i] ${note.title}: ${note.elements.length}个绘画元素');
      }
    } catch (e) {
      debugPrint('同步当前数据到版本系统失败: $e');
      // 不抛出异常，允许系统继续工作
    }
  }

  /// 从VFS存储加载所有已存在的版本到响应式版本管理系统
  Future<void> _loadExistingVersionsFromVfs() async {
    if (_currentMap == null) return;

    try {
      debugPrint('开始从VFS加载已存储的版本...');

      // 获取VFS中所有版本ID
      final versionIds = await _vfsMapService.getMapVersions(
        _currentMap!.title,
        widget.folderPath,
      );
      debugPrint('找到 ${versionIds.length} 个已存储的版本: $versionIds');

      // 获取所有版本的元数据（包含版本名称）
      final versionNames = await _vfsMapService.getAllVersionNames(
        _currentMap!.title,
        widget.folderPath,
      );
      debugPrint('版本名称映射: $versionNames');

      // 为每个版本创建响应式版本状态并加载完整数据到会话
      for (final versionId in versionIds) {
        try {
          final versionName = versionNames[versionId] ?? versionId;

          // 检查版本是否已经在响应式系统中
          if (versionAdapter?.versionManager.versionExists(versionId) == true) {
            debugPrint('版本 $versionId 已存在于响应式系统中，但需要确保数据已加载');

            // 检查是否已有会话数据，如果没有则加载
            final existingState = versionAdapter?.versionManager
                .getVersionState(versionId);
            if (existingState?.sessionData == null) {
              await _loadVersionDataToSession(versionId, versionName);
            }
            continue;
          }

          // 加载版本完整数据到会话中
          await _loadVersionDataToSession(versionId, versionName);

          debugPrint('已加载版本到响应式系统: $versionId ($versionName)');
        } catch (e) {
          debugPrint('加载版本 $versionId 失败: $e');
          // 继续加载其他版本
        }
      }

      debugPrint('完成从VFS加载版本，响应式系统中共有 ${allVersionStates.length} 个版本');
    } catch (e) {
      debugPrint('从VFS加载版本失败: $e');
      // 不抛出异常，允许系统继续工作
    }
  }

  /// 加载指定版本的完整数据到会话中
  Future<void> _loadVersionDataToSession(
    String versionId,
    String versionName,
  ) async {
    if (_currentMap == null) return;

    try {
      debugPrint('开始加载版本数据到会话: $versionId'); // 从VFS加载该版本的完整数据
      final versionLayers = await _vfsMapService.getMapLayers(
        _currentMap!.title,
        versionId,
        widget.folderPath,
      );
      final versionLegendGroups = await _vfsMapService.getMapLegendGroups(
        _currentMap!.title,
        versionId,
        widget.folderPath,
      );
      final versionStickyNotes = await _vfsMapService.getMapStickyNotes(
        _currentMap!.title,
        versionId,
        widget.folderPath,
      );

      // 构建该版本的完整MapItem数据
      final versionMapData = _currentMap!.copyWith(
        layers: versionLayers,
        legendGroups: versionLegendGroups,
        stickyNotes: versionStickyNotes,
        updatedAt: DateTime.now(),
      );

      // 初始化版本状态并设置会话数据
      versionAdapter?.versionManager.initializeVersion(
        versionId,
        versionName: versionName,
        initialData: versionMapData,
      );

      debugPrint(
        '版本 $versionId 数据已加载到会话，图层数: ${versionLayers.length}, 图例组数: ${versionLegendGroups.length}, 便签数: ${versionStickyNotes.length}',
      );
    } catch (e) {
      // 如果加载失败，至少创建空的版本状态
      debugPrint('加载版本 $versionId 数据失败，创建空版本状态: $e');
      versionAdapter?.versionManager.initializeVersion(
        versionId,
        versionName: versionName,
      );
    }
  }

  /// 设置响应式监听器
  void _setupReactiveListeners() {
    // 监听地图数据变化
    mapDataStream.listen((state) {
      if (state is MapDataLoaded) {
        debugPrint('=== 响应式监听器收到 MapDataLoaded 事件 ===');
        debugPrint(
          '响应式数据图层order: ${state.layers.map((l) => '${l.name}(${l.order})').toList()}',
        );

        // 同步更新传统状态
        if (mounted) {
          setState(() {
            // 关键修复：需要同步 mapItem 中的图层数据
            _currentMap = state.mapItem.copyWith(
              layers: state.layers,
              legendGroups: state.legendGroups,
            );

            debugPrint(
              '_currentMap已更新，图层order: ${_currentMap!.layers.map((l) => '${l.name}(${l.order})').toList()}',
            );

            // 同步更新选中图层的引用，确保引用最新的图层对象
            if (_selectedLayer != null) {
              final selectedLayerId = _selectedLayer!.id;
              _selectedLayer = state.layers
                  .where((layer) => layer.id == selectedLayerId)
                  .firstOrNull;
              debugPrint('选中图层引用已更新: ${_selectedLayer?.name}');
            }

            // 同步更新选中图层组的引用
            if (_selectedLayerGroup != null) {
              final updatedGroup = <MapLayer>[];
              for (final groupLayer in _selectedLayerGroup!) {
                final updatedLayer = state.layers.firstWhere(
                  (layer) => layer.id == groupLayer.id,
                  orElse: () => groupLayer,
                );
                updatedGroup.add(updatedLayer);
              }
              _selectedLayerGroup = updatedGroup;
              debugPrint('选中图层组引用已更新');
            }

            // 同步更新选中便利贴的引用，确保引用最新的便利贴对象
            if (_selectedStickyNote != null) {
              final selectedNoteId = _selectedStickyNote!.id;
              _selectedStickyNote = state.mapItem.stickyNotes
                  .where((note) => note.id == selectedNoteId)
                  .firstOrNull;
            }

            // 关键修复：同步更新当前正在管理的图例组引用
            // 确保LegendGroupManagementDrawer能够接收到最新的图例组数据
            if (_currentLegendGroupForManagement != null) {
              final managedGroupId = _currentLegendGroupForManagement!.id;
              _currentLegendGroupForManagement = state.legendGroups
                  .where((group) => group.id == managedGroupId)
                  .firstOrNull;
              debugPrint(
                '图例组管理状态已同步: ${_currentLegendGroupForManagement?.name}',
              );
            }

            // 重要修复：同步未保存更改状态
            // 当响应式系统有数据变化时，UI也应该反映这个变化
            _hasUnsavedChanges = hasUnsavedChangesReactive;

            // 更新显示顺序
            debugPrint('调用 _updateDisplayOrderAfterLayerChange()');
            _updateDisplayOrderAfterLayerChange();
            debugPrint(
              '_updateDisplayOrderAfterLayerChange() 完成，_displayOrderLayers: ${_displayOrderLayers.map((l) => '${l.name}(${l.order})').toList()}',
            );
          });

          // 重要：在状态同步后，确保UI能够正确反映更改状态
          // 这样用户就能看到未保存的更改指示
          debugPrint('UI状态已同步响应式数据，未保存更改: $_hasUnsavedChanges');
        }
      }
    });

    // 添加额外的监听器来确保未保存状态的同步
    // 这是为了确保当响应式系统状态变化时，UI能够及时更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 定期检查响应式系统的未保存状态并同步到UI
      _syncUnsavedChangesFromReactive();
    });
  }

  /// 同步响应式系统的未保存更改状态到UI
  void _syncUnsavedChangesFromReactive() {
    if (mounted && hasUnsavedChangesReactive != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasUnsavedChangesReactive;
      });
      debugPrint('已同步响应式系统的未保存状态到UI: $_hasUnsavedChanges');
    }
  }

  /// 旧的脚本引擎地图数据访问器更新方法已移除
  /// 新的响应式脚本管理器通过MapDataBloc自动获取地图数据
  void _updateScriptMapDataAccessor() {
    // 新的响应式脚本管理器通过MapDataBloc自动访问地图数据
    // 无需手动设置访问器
    debugPrint('新的响应式脚本管理器自动通过MapDataBloc访问地图数据');
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
      // 更新侧边栏折叠状态
      _isSidebarCollapsed =
          layout.panelCollapsedStates['sidebar'] ?? false; // 更新面板折叠状态
      _isDrawingToolbarCollapsed =
          layout.panelCollapsedStates['drawing'] ?? false;
      _isLayerPanelCollapsed = layout.panelCollapsedStates['layer'] ?? false;
      _isLegendPanelCollapsed = layout.panelCollapsedStates['legend'] ?? false;
      _isStickyNotePanelCollapsed =
          layout.panelCollapsedStates['stickyNote'] ?? false;
      _isScriptPanelCollapsed =
          layout.panelCollapsedStates['script'] ?? false; // 更新面板自动关闭状态
      _isDrawingToolbarAutoClose =
          layout.panelAutoCloseStates['drawing'] ?? true;
      _isLayerPanelAutoClose = layout.panelAutoCloseStates['layer'] ?? true;
      _isLegendPanelAutoClose = layout.panelAutoCloseStates['legend'] ?? true;
      _isStickyNotePanelAutoClose =
          layout.panelAutoCloseStates['stickyNote'] ?? true;
      _isScriptPanelAutoClose = layout.panelAutoCloseStates['script'] ?? true;
    });
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

  // // 撤销历史记录管理方法
  // void _saveToUndoHistory() {
  //   if (_currentMap == null) return;

  //   // 只有在非初始化状态时才标记为有未保存更改
  //   if (_undoHistory.isNotEmpty) {
  //     _hasUnsavedChanges = true;
  //     _hasUnsavedVersionChanges = true;
  //   }

  //   // 创建地图的深拷贝，避免引用问题
  //   final deepCopiedMap = _currentMap!.copyWith(
  //     layers: _currentMap!.layers.map((layer) => layer.copyWith()).toList(),
  //     legendGroups: _currentMap!.legendGroups
  //         .map((group) => group.copyWith())
  //         .toList(),
  //   );

  //   // 保存当前状态到撤销历史
  //   _undoHistory.add(deepCopiedMap);

  //   // 同时保存到版本会话管理器
  //   if (_versionSessionManager != null && _versionManager != null) {
  //     final currentVersionId = _versionManager!.currentVersionId;
  //     _versionSessionManager!.addToUndoHistory(currentVersionId, deepCopiedMap);
  //   }

  //   // 清空重做历史，因为新的操作会使重做历史失效
  //   _redoHistory.clear();
  //   // 限制历史记录数量
  //   if (_undoHistory.length > _maxUndoHistory) {
  //     _undoHistory.removeAt(0);
  //   }
  // }

  void _undo() {
    _keyboardShortcutActions?.undo();
  }

  void _redo() {
    _keyboardShortcutActions?.redo();
  }

  bool get _canUndo {
    return _keyboardShortcutActions?.canUndo() ?? false;
  }

  bool get _canRedo {
    return _keyboardShortcutActions?.canRedo() ?? false;
  }

  // ==================== 实现 KeyboardShortcutCallbacks 接口 ====================

  // 撤销/重做相关
  @override
  bool canUndo() {
    return _keyboardShortcutActions?.canUndo() ?? false;
  }

  @override
  bool canRedo() {
    return _keyboardShortcutActions?.canRedo() ?? false;
  }

  @override
  void undo() {
    _keyboardShortcutActions?.undo();
  }

  @override
  void redo() {
    _keyboardShortcutActions?.redo();
  }

  @override
  void handleCopySelection() {
    _keyboardShortcutActions?.handleCopySelection();
  }

  // 图层相关
  @override
  void selectPreviousLayer() {
    _keyboardShortcutActions?.selectPreviousLayer();
  }

  @override
  void selectNextLayer() {
    _keyboardShortcutActions?.selectNextLayer();
  }

  @override
  void selectPreviousLayerGroup() {
    _keyboardShortcutActions?.selectPreviousLayerGroup();
  }

  @override
  void selectNextLayerGroup() {
    _keyboardShortcutActions?.selectNextLayerGroup();
  }

  @override
  void selectLayerGroupByIndex(int index) {
    _keyboardShortcutActions?.selectLayerGroupByIndex(index);
  }

  @override
  void selectLayerByIndex(int index) {
    _keyboardShortcutActions?.selectLayerByIndex(index);
  }

  @override
  void clearLayerSelection() {
    _keyboardShortcutActions?.clearLayerSelection();
  }

  @override
  void hideOtherLayers() {
    _keyboardShortcutActions?.hideOtherLayers();
  }

  @override
  void hideOtherLayerGroups() {
    _keyboardShortcutActions?.hideOtherLayerGroups();
  }

  @override
  void showCurrentLayer() {
    _keyboardShortcutActions?.showCurrentLayer();
  }

  @override
  void showCurrentLayerGroup() {
    _keyboardShortcutActions?.showCurrentLayerGroup();
  }

  // 图例相关
  @override
  void openPreviousLegendGroup() {
    _keyboardShortcutActions?.openPreviousLegendGroup();
  }

  @override
  void openNextLegendGroup() {
    _keyboardShortcutActions?.openNextLegendGroup();
  }

  @override
  void toggleLegendGroupManagementDrawer() {
    _keyboardShortcutActions?.toggleLegendGroupManagementDrawer();
  }

  @override
  void toggleLegendGroupBindingDrawer() {
    _keyboardShortcutActions?.toggleLegendGroupBindingDrawer();
  }

  @override
  void hideOtherLegendGroups() {
    _keyboardShortcutActions?.hideOtherLegendGroups();
  }

  @override
  void showCurrentLegendGroup() {
    _keyboardShortcutActions?.showCurrentLegendGroup();
  }

  // UI相关
  @override
  void toggleSidebar() {
    _keyboardShortcutActions?.toggleSidebar();
  }

  @override
  void openZInspector() {
    _keyboardShortcutActions?.openZInspector();
  }

  // 地图相关
  @override
  void saveMap() async {
    setState(() => _isLoading = true);
    try {
      await _keyboardShortcutActions?.saveMapAction();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 版本相关
  @override
  void switchToPreviousVersion() {
    _keyboardShortcutActions?.switchToPreviousVersion();
  }

  @override
  void switchToNextVersion() {
    _keyboardShortcutActions?.switchToNextVersion();
  }

  @override
  void createNewVersionWithShortcut() {
    _keyboardShortcutActions?.createNewVersionWithShortcut();
  }

  // 删除指定图层中的绘制元素（使用响应式系统重构）
  void _deleteElement(String elementId) {
    MapDrawingElement? elementToDelete;

    // 优先检查便签中的元素
    if (_selectedStickyNote != null) {
      elementToDelete = _selectedStickyNote!.elements
          .where((element) => element.id == elementId)
          .firstOrNull;

      if (elementToDelete != null) {
        // 删除便签中的元素
        try {
          final updatedElements = _selectedStickyNote!.elements
              .where((element) => element.id != elementId)
              .toList();

          final updatedStickyNote = _selectedStickyNote!.copyWith(
            elements: updatedElements,
            updatedAt: DateTime.now(),
          );

          updateStickyNoteReactive(updatedStickyNote);
          debugPrint('使用响应式系统删除便签绘制元素: ${_selectedStickyNote!.id}/$elementId');

          // 如果删除的是图片元素，强制触发缓存清理
          if (elementToDelete.type == DrawingElementType.imageArea) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {});
              }
            });
          }

          // 显示删除成功消息
          _showSuccessSnackBar('已删除便签元素');
          return;
        } catch (e) {
          debugPrint('响应式系统删除便签元素失败: $e');
          _showErrorSnackBar('删除便签元素失败: $e');
          return;
        }
      }
    }

    // 如果便签中没有找到元素，检查图层中的元素
    if (_selectedLayer == null) return;

    // 找到要删除的元素
    elementToDelete = _selectedLayer!.elements
        .where((element) => element.id == elementId)
        .firstOrNull;

    if (elementToDelete == null) return;

    // 尝试使用响应式系统删除元素
    try {
      deleteDrawingElementReactive(_selectedLayer!.id, elementId);
      debugPrint('使用响应式系统删除绘制元素: ${_selectedLayer!.id}/$elementId');

      // 响应式系统会自动处理撤销历史和数据同步
      // 无需手动调用 _saveToUndoHistory() 和 _updateLayer()

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
    } catch (e) {
      debugPrint('响应式系统删除元素失败: $e');
      _showErrorSnackBar('删除元素失败: $e');
    }
  }

  // 更新指定图层或便签中的绘制元素（使用响应式系统）
  void _updateElement(MapDrawingElement element) {
    try {
      // 如果有选中的便签，优先处理便签中的元素
      if (_selectedStickyNote != null) {
        // 检查元素是否属于当前选中的便签
        final elementIndex = _selectedStickyNote!.elements.indexWhere(
          (e) => e.id == element.id,
        );
        if (elementIndex != -1) {
          // 更新便签中的元素
          final updatedElements = List<MapDrawingElement>.from(
            _selectedStickyNote!.elements,
          );
          updatedElements[elementIndex] = element;

          final updatedStickyNote = _selectedStickyNote!.copyWith(
            elements: updatedElements,
            updatedAt: DateTime.now(),
          );

          updateStickyNoteReactive(updatedStickyNote);
          debugPrint(
            '使用响应式系统更新便签绘制元素: ${_selectedStickyNote!.id}/${element.id}',
          );

          // 显示更新成功消息
          _showSuccessSnackBar('已更新便签元素标签');
          return;
        }
      }

      // 如果没有选中便签或元素不属于便签，则处理图层中的元素
      if (_selectedLayer != null) {
        updateDrawingElementReactive(_selectedLayer!.id, element);
        debugPrint('使用响应式系统更新图层绘制元素: ${_selectedLayer!.id}/${element.id}');

        // 显示更新成功消息
        _showSuccessSnackBar('已更新图层元素标签');
      }
    } catch (e) {
      debugPrint('响应式系统更新元素失败: $e');
      _showErrorSnackBar('更新元素失败: $e');
    }
  }

  /// 传统的元素删除方式（作为备用）
  // void _deleteElementTraditional(String elementId, MapDrawingElement elementToDelete) {
  //   // 保存当前状态到撤销历史
  //   _saveToUndoHistory();

  //   // 创建新的元素列表，排除要删除的元素
  //   final updatedElements = _selectedLayer!.elements
  //       .where((element) => element.id != elementId)
  //       .toList();

  //   // 更新图层
  //   final updatedLayer = _selectedLayer!.copyWith(
  //     elements: updatedElements,
  //     updatedAt: DateTime.now(),
  //   );

  //   _updateLayer(updatedLayer);

  //   //：如果删除的是图片元素，强制触发缓存清理
  //   if (elementToDelete.type == DrawingElementType.imageArea) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (mounted) {
  //         setState(() {});
  //       }
  //     });
  //   }

  //   // 显示删除成功消息
  //   _showSuccessSnackBar('已删除绘制元素（传统模式）');
  // }

  void _addDefaultLayer() {
    if (_currentMap == null) return;

    final defaultLayer = MapLayer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '图层 1',
      order: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 使用响应式系统添加默认图层
    try {
      addLayerReactive(defaultLayer);
      debugPrint('使用响应式系统添加默认图层: ${defaultLayer.name}');

      // 更新UI状态
      setState(() {
        _selectedLayer = defaultLayer;
        // 更新显示顺序
        _updateDisplayOrderAfterLayerChange();
      });

      debugPrint('默认图层已添加: "${defaultLayer.name}"');
    } catch (e) {
      debugPrint('响应式系统添加默认图层失败: $e');
      // // 如果响应式系统失败，回退到传统方式
      // setState(() {
      //   _currentMap = _currentMap!.copyWith(
      //     layers: [..._currentMap!.layers, defaultLayer],
      //   );
      //   _selectedLayer = defaultLayer;
      // });
      // debugPrint('使用传统方式添加默认图层作为回退');
    }
  }

  void _addNewLayer() {
    if (_currentMap == null) return;

    final newLayer = MapLayer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '图层 ${_currentMap!.layers.length + 1}',
      order: _currentMap!.layers.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 使用响应式系统添加图层
    try {
      addLayerReactive(newLayer);
      debugPrint('使用响应式系统添加图层: ${newLayer.name}');

      // 更新UI状态
      setState(() {
        _selectedLayer = newLayer;
        // 更新显示顺序
        _updateDisplayOrderAfterLayerChange();
      });

      // 显示成功消息
      _showSuccessSnackBar('已添加图层 "${newLayer.name}"');
    } catch (e) {
      debugPrint('响应式系统添加图层失败: $e');
      _showErrorSnackBar('添加图层失败: ${e.toString()}');
    }
  }

  void _deleteLayer(MapLayer layer) {
    if (_currentMap == null || _currentMap!.layers.length <= 1) return;

    // 使用响应式系统删除图层
    try {
      deleteLayerReactive(layer.id);
      debugPrint('使用响应式系统删除图层: ${layer.name}');

      // 更新UI状态
      setState(() {
        // 删除逻辑会通过响应式流处理，这里只需要更新选择状态
        final remainingLayers = _currentMap!.layers
            .where((l) => l.id != layer.id)
            .toList();

        if (_selectedLayer?.id == layer.id) {
          _selectedLayer = remainingLayers.isNotEmpty
              ? remainingLayers.first
              : null;
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
      });

      // 显示成功消息
      _showSuccessSnackBar('已删除图层 "${layer.name}"');
    } catch (e) {
      debugPrint('响应式系统删除图层失败: $e');
      _showErrorSnackBar('删除图层失败: ${e.toString()}');
    }
  }

  // /// 传统的图层删除方式（作为备用）
  // void _deleteLayerTraditional(MapLayer layer) {
  //   setState(() {
  //     final updatedLayers = _currentMap!.layers
  //         .where((l) => l.id != layer.id)
  //         .toList();
  //     _currentMap = _currentMap!.copyWith(layers: updatedLayers);

  //     if (_selectedLayer?.id == layer.id) {
  //       _selectedLayer = updatedLayers.isNotEmpty ? updatedLayers.first : null;
  //     }

  //     // 如果删除的图层在选中的组中，更新组选择
  //     if (_selectedLayerGroup != null) {
  //       final updatedGroup = _selectedLayerGroup!
  //           .where((l) => l.id != layer.id)
  //           .toList();

  //       if (updatedGroup.isEmpty) {
  //         // 如果组内所有图层都被删除，清除组选择
  //         _selectedLayerGroup = null;
  //         _restoreNormalLayerOrder();
  //       } else {
  //         // 更新组选择
  //         _selectedLayerGroup = updatedGroup;
  //         _prioritizeLayerGroup(updatedGroup);
  //       }
  //     } else {
  //       // 更新显示顺序
  //       _updateDisplayOrderAfterLayerChange();
  //     }
  //   });
  // }

  //TODO: 考虑使用响应式系统
  void _onLayerSelected(MapLayer layer) {
    setState(() {
      _selectedLayer = layer;
      // 修改：不清除图层组选择，允许同时选择图层和图层组
      // _selectedLayerGroup = null; // 注释掉这行，保持图层组选择
    });

    // 触发优先显示逻辑
    _prioritizeLayerAndGroupDisplay();
    // 清除画布上的选区
    _clearCanvasSelection();

    // 如果图例组抽屉已打开，自动切换到绑定的第一个图例组
    _autoSwitchToFirstBoundLegendGroup();
  }

  //TODO: 考虑使用响应式系统
  void _onLayerGroupSelected(List<MapLayer> group) {
    setState(() {
      // 修改：不清除单图层选择，允许同时选择
      _selectedLayerGroup = group; // 设置组选择

      // 检查用户偏好设置，是否自动选择图层组的最后一层
      final userPreferences = Provider.of<UserPreferencesProvider>(
        context,
        listen: false,
      );

      if (userPreferences.mapEditor.autoSelectLastLayerInGroup &&
          group.isNotEmpty) {
        // 找到图层组中的最后一层
        MapLayer? lastLayer;

        for (final layer in group) {
          if (!layer.isLinkedToNext) {
            lastLayer = layer;
          }
        }

        // 如果找到了最后一层，自动选择它
        if (lastLayer != null) {
          _selectedLayer = lastLayer;
        }
      }
    });

    // 触发优先显示逻辑
    _prioritizeLayerAndGroupDisplay();
    //：清除画布上的选区
    _clearCanvasSelection();

    // 如果图例组抽屉已打开，自动切换到绑定的第一个图例组
    _autoSwitchToFirstBoundLegendGroup();
  }

  //TODO: 考虑使用响应式系统
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

  void _onLayerGroupSelectionCleared() {
    setState(() {
      _selectedLayerGroup = null;
      // 保留 _selectedLayer，不清除
    });
    // 更新显示顺序
    _prioritizeLayerAndGroupDisplay();
    _clearCanvasSelection();
  }

  // 修改：新的优先显示逻辑，支持图层和图层组的组合显示
  void _prioritizeLayerAndGroupDisplay() {
    debugPrint('优先显示图层和图层组的组合');

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

      debugPrint('重新排列后的显示顺序:');
      debugPrint(
        '- 其他图层: ${otherLayers.map((l) => '${l.name}(${l.order})').toList()}',
      );
      debugPrint(
        '- 组内图层: ${groupLayers.map((l) => '${l.name}(${l.order})').toList()}',
      );
      debugPrint(
        '- 优先图层: ${priorityLayers.map((l) => '${l.name}(${l.order})').toList()}',
      );
    });
  }

  //TODO: 考虑使用响应式系统
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
    debugPrint('=== _prioritizeLayerGroup 开始 ===');
    debugPrint('优先显示图层组: ${group.map((l) => l.name).toList()}');
    debugPrint(
      '当前_currentMap.layers顺序: ${_currentMap?.layers.map((l) => '${l.name}(${l.order})').toList()}',
    );
    debugPrint(
      '当前_displayOrderLayers顺序: ${_displayOrderLayers.map((l) => '${l.name}(${l.order})').toList()}',
    );

    if (_currentMap == null) return;

    setState(() {
      // 将选中的图层组移到显示列表的最前面（最后绘制，显示在上层）
      final allLayers = List<MapLayer>.from(_currentMap!.layers);
      final nonGroupLayers = <MapLayer>[];
      final groupLayers = <MapLayer>[];
      final groupLayerIds = group.map((l) => l.id).toSet();

      debugPrint(
        'allLayers从_currentMap获取: ${allLayers.map((l) => '${l.name}(${l.order})').toList()}',
      );

      // 分离组内图层和其他图层，保持在当前地图数据中的实际顺序
      for (final layer in allLayers) {
        if (groupLayerIds.contains(layer.id)) {
          groupLayers.add(layer);
        } else {
          nonGroupLayers.add(layer);
        }
      }

      // 不再按order排序，保持图层在_currentMap!.layers中的实际顺序
      // 这样可以正确反映组内重排序的结果
      debugPrint(
        '分离后的组内图层顺序: ${groupLayers.map((l) => '${l.name}(${l.order})').toList()}',
      );
      debugPrint(
        '分离后的非组图层顺序: ${nonGroupLayers.map((l) => '${l.name}(${l.order})').toList()}',
      );

      // 重新组织显示顺序：非组图层在前，组图层在后（后绘制的显示在上层）
      _displayOrderLayers = [...nonGroupLayers, ...groupLayers];

      debugPrint(
        '最终_displayOrderLayers顺序: ${_displayOrderLayers.map((l) => '${l.name}(${l.order})').toList()}',
      );
      debugPrint('=== _prioritizeLayerGroup 结束 ===');
    });
  }

  void _restoreNormalLayerOrder() {
    if (_currentMap == null) return;

    setState(() {
      // 按原始order顺序排列
      final sortedLayers = List<MapLayer>.from(_currentMap!.layers)
        ..sort((a, b) => a.order.compareTo(b.order));

      _displayOrderLayers = sortedLayers;
    });
  }

  void _disableDrawingTools() {
    // 禁用绘制工具的逻辑
    setState(() {
      _selectedDrawingTool = null; // 清除选中的绘制工具
      _selectedElementId = null; // 清除选中的元素
    });
    debugPrint('绘制工具已禁用');
  }

  /// 检查绘制工具是否应该被禁用
  bool get _shouldDisableDrawingTools {
    // 如果选中了便签，绘制工具应该启用
    if (_selectedStickyNote != null) {
      return false;
    }
    // 如果选中了具体的图层，绘制工具应该启用
    if (_selectedLayer != null) {
      return false;
    }
    // 如果没有选中图层，检查是否有可用的默认图层
    final defaultLayer = _getTopVisibleLayer();
    if (defaultLayer != null) {
      return false; // 有可用的默认图层，启用绘制工具
    }
    // 只有在没有任何可见图层时才禁用绘制工具
    return true;
  }

  /// 获取最上层的可见图层（考虑图层选择和图例组选择的影响）
  MapLayer? _getTopVisibleLayer() {
    if (_currentMap == null) return null;

    // 使用显示顺序图层，如果没有则使用默认排序
    final layersToCheck = _displayOrderLayers.isNotEmpty
        ? _displayOrderLayers
        : (_currentMap!.layers..sort((a, b) => a.order.compareTo(b.order)));

    // 从后往前查找（后面的图层在上层）
    for (int i = layersToCheck.length - 1; i >= 0; i--) {
      final layer = layersToCheck[i];
      if (layer.isVisible) {
        return layer;
      }
    }

    return null;
  }

  /// 获取当前绘制的目标图层（选中的图层或默认的最上层图层）
  MapLayer? _getCurrentDrawingTargetLayer() {
    if (_selectedLayer != null) {
      return _selectedLayer;
    }
    return _getTopVisibleLayer();
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

    // 使用响应式系统更新图层
    try {
      updateLayerReactive(updatedLayer);
    } catch (e) {
      _showErrorSnackBar('更新图层失败: ${e.toString()}');
    }
  }

  // /// 传统的图层更新方式（作为备用）
  // void _updateLayerTraditional(MapLayer updatedLayer) {
  //   setState(() {
  //     final layerIndex = _currentMap!.layers.indexWhere(
  //       (l) => l.id == updatedLayer.id,
  //     );
  //     if (layerIndex != -1) {
  //       final updatedLayers = List<MapLayer>.from(_currentMap!.layers);
  //       updatedLayers[layerIndex] = updatedLayer;
  //       _currentMap = _currentMap!.copyWith(layers: updatedLayers);

  //       if (_selectedLayer?.id == updatedLayer.id) {
  //         _selectedLayer = updatedLayer;
  //       }

  //       // 同步更新显示顺序列表
  //       _updateDisplayOrderAfterLayerChange();
  //     }
  //   });
  // }

  void _reorderLayers(int oldIndex, int newIndex) {
    if (_currentMap == null) return;

    // 验证索引范围
    if (oldIndex < 0 ||
        oldIndex >= _currentMap!.layers.length ||
        newIndex < 0 ||
        newIndex >= _currentMap!.layers.length ||
        oldIndex == newIndex) {
      return;
    }

    // 使用响应式系统重排序图层
    try {
      reorderLayersReactive(oldIndex, newIndex);

      setState(() {
        _updateLayerSelectionAfterReorder(oldIndex, newIndex);
      });

      _showSuccessSnackBar('图层顺序已更新');
    } catch (e) {
      debugPrint('响应式系统重排序图层失败: $e');
      _showErrorSnackBar('重排序图层失败: ${e.toString()}');
    }
  }

  /// 组内重排序图层（同时处理链接状态和顺序）
  void _reorderLayersInGroup(
    int oldIndex,
    int newIndex,
    List<MapLayer> layersToUpdate,
  ) {
    if (_currentMap == null) return;

    // 验证索引范围
    if (oldIndex < 0 ||
        oldIndex >= _currentMap!.layers.length ||
        newIndex < 0 ||
        newIndex >= _currentMap!.layers.length ||
        oldIndex == newIndex) {
      return;
    }

    // 使用响应式系统进行组内重排序
    try {
      reorderLayersInGroupReactive(oldIndex, newIndex, layersToUpdate);

      setState(() {
        _updateLayerSelectionAfterReorder(oldIndex, newIndex);
      });

      _showSuccessSnackBar('图层组内顺序已更新');
    } catch (e) {
      debugPrint('响应式系统组内重排序图层失败: $e');
      _showErrorSnackBar('组内重排序图层失败: ${e.toString()}');
    }
  }

  /// 重排序后更新图层选择状态
  //TODO: 考虑使用响应式系统
  void _updateLayerSelectionAfterReorder(int oldIndex, int newIndex) {
    if (_currentMap == null) return;

    final layers = _currentMap!.layers;

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
  }

  /// 传统的图层重排序方式（作为备用）
  // void _reorderLayersTraditional(int oldIndex, int newIndex) {
  //   setState(() {
  //     final layers = List<MapLayer>.from(_currentMap!.layers);

  //     // 记录移动前的链接状态，用于组内重排序时保持组的完整性
  //     final movedLayer = layers[oldIndex];
  //     final isGroupInternalMove = _isGroupInternalMove(
  //       layers,
  //       oldIndex,
  //       newIndex,
  //     );

  //     debugPrint('是否为组内移动: $isGroupInternalMove');

  //     // 执行重排序 - 不需要调整newIndex，直接使用
  //     final item = layers.removeAt(oldIndex);
  //     layers.insert(newIndex, item);

  //     debugPrint('重排序后图层名称: ${layers.map((l) => l.name).toList()}');

  //     // 重新分配order
  //     for (int i = 0; i < layers.length; i++) {
  //       layers[i] = layers[i].copyWith(order: i);
  //     }

  //     // 如果是组内移动，需要特殊处理链接状态
  //     if (isGroupInternalMove) {
  //       _preserveGroupLinkingForInternalMove(layers, movedLayer, newIndex);
  //     }

  //     _currentMap = _currentMap!.copyWith(layers: layers);

  //     debugPrint('更新后的_currentMap图层数量: ${_currentMap!.layers.length}');
  //     debugPrint('=== _reorderLayers 结束 ===');

  //     // 更新选中图层的引用
  //     if (_selectedLayer != null) {
  //       final selectedLayerId = _selectedLayer!.id;
  //       _selectedLayer = layers.firstWhere(
  //         (layer) => layer.id == selectedLayerId,
  //         orElse: () => _selectedLayer!,
  //       );
  //     }

  //     // 如果有选中的图层组，更新组选择并重新应用优先显示
  //     if (_selectedLayerGroup != null) {
  //       final updatedGroup = <MapLayer>[];
  //       for (final groupLayer in _selectedLayerGroup!) {
  //         final updatedLayer = layers.firstWhere(
  //           (layer) => layer.id == groupLayer.id,
  //           orElse: () => groupLayer,
  //         );
  //         updatedGroup.add(updatedLayer);
  //       }
  //       _selectedLayerGroup = updatedGroup;
  //       _prioritizeLayerGroup(updatedGroup);
  //     } else {
  //       // 更新显示顺序
  //       _updateDisplayOrderAfterLayerChange();
  //     }
  //   });
  // }

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

    // 使用响应式系统批量更新图层
    try {
      updateLayersReactive(updatedLayers);

      // 更新UI状态
      setState(() {
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

      // 显示成功消息
      // _showSuccessSnackBar('已批量更新 ${updatedLayers.length} 个图层');
    } catch (e) {
      _showErrorSnackBar('批量更新图层失败: ${e.toString()}');
    }
  }

  /// 图层绑定更新回调 - 用于LayerBindingDrawer
  void _updateLayersBinding(List<MapLayer> updatedLayers) {
    _updateLayersBatch(updatedLayers);
  }

  /// 传统的批量图层更新方式（作为备用）
  // void _updateLayersBatchTraditional(List<MapLayer> updatedLayers) {
  //   setState(() {
  //     _currentMap = _currentMap!.copyWith(layers: updatedLayers);

  //     // 如果当前选中的图层也被更新了，同步更新选中图层的引用
  //     if (_selectedLayer != null) {
  //       final updatedSelectedLayer = updatedLayers.firstWhere(
  //         (layer) => layer.id == _selectedLayer!.id,
  //         orElse: () => _selectedLayer!,
  //       );
  //       _selectedLayer = updatedSelectedLayer;
  //     }

  //     // 如果有选中的图层组，更新组选择
  //     if (_selectedLayerGroup != null) {
  //       final updatedGroup = <MapLayer>[];
  //       for (final groupLayer in _selectedLayerGroup!) {
  //         final updatedLayer = updatedLayers.firstWhere(
  //           (layer) => layer.id == groupLayer.id,
  //           orElse: () => groupLayer,
  //         );
  //         updatedGroup.add(updatedLayer);
  //       }
  //       _selectedLayerGroup = updatedGroup;
  //       _prioritizeLayerGroup(updatedGroup);
  //     } else {
  //       // 更新显示顺序
  //       _updateDisplayOrderAfterLayerChange();
  //     }
  //   });
  // }

  /// 为组内移动保持组的链接完整性
  // void _preserveGroupLinkingForInternalMove(
  //   List<MapLayer> layers,
  //   MapLayer movedLayer,
  //   int newIndex,
  // ) {
  //   debugPrint('保持组内链接完整性');

  //   // 重新找到移动后的组边界
  //   int groupStart = _findGroupStart(layers, newIndex);
  //   int groupEnd = _findGroupEnd(layers, newIndex);

  //   debugPrint('组边界: start=$groupStart, end=$groupEnd, newIndex=$newIndex');

  //   // 确保组内所有图层（除了最后一个）都保持链接状态
  //   for (int i = groupStart; i < groupEnd; i++) {
  //     if (!layers[i].isLinkedToNext) {
  //       debugPrint('修复图层 ${layers[i].name} 的链接状态');
  //       layers[i] = layers[i].copyWith(
  //         isLinkedToNext: true,
  //         updatedAt: DateTime.now(),
  //       );
  //     }
  //   }

  //   // 确保组的最后一个图层不链接到组外
  //   if (groupEnd < layers.length - 1 && layers[groupEnd].isLinkedToNext) {
  //     // 检查下一个图层是否应该在同一组中
  //     bool shouldLinkToNext = false;
  //     if (groupEnd + 1 < layers.length) {
  //       // 这里可以添加更复杂的逻辑来判断是否应该保持链接
  //       // 暂时保持简单：组内移动不改变与组外图层的链接关系
  //       shouldLinkToNext = layers[groupEnd].isLinkedToNext;
  //     }

  //     if (!shouldLinkToNext) {
  //       debugPrint('断开组最后图层 ${layers[groupEnd].name} 的链接');
  //       layers[groupEnd] = layers[groupEnd].copyWith(
  //         isLinkedToNext: false,
  //         updatedAt: DateTime.now(),
  //       );
  //     }
  //   }
  // }

  /// 检查是否为组内移动
  // bool _isGroupInternalMove(List<MapLayer> layers, int oldIndex, int newIndex) {
  //   // 找到oldIndex所在的组
  //   int groupStart = _findGroupStart(layers, oldIndex);
  //   int groupEnd = _findGroupEnd(layers, oldIndex);

  //   // 检查newIndex是否在同一个组内
  //   return newIndex >= groupStart && newIndex <= groupEnd;
  // }
  // 使用响应式系统添加图例组
  void _addLegendGroup() {
    if (_currentMap == null) return;

    final newGroup = LegendGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '图例组 ${_currentMap!.legendGroups.length + 1}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 使用响应式系统添加图例组
    try {
      addLegendGroupReactive(newGroup);

      // 为新图例组设置默认的智能隐藏状态
      setLegendGroupSmartHideState(newGroup.id, true);

      // 显示成功消息
      _showSuccessSnackBar('已添加图例组 "${newGroup.name}"');
    } catch (e) {
      _showErrorSnackBar('添加图例组失败: ${e.toString()}');
    }
  }

  // /// 查找组的开始位置
  // int _findGroupStart(List<MapLayer> layers, int index) {
  //   int start = index;

  //   // 向前查找组的开始
  //   while (start > 0) {
  //     if (layers[start - 1].isLinkedToNext) {
  //       start--;
  //     } else {
  //       break;
  //     }
  //   }

  //   return start;
  // }

  /// 查找组的结束位置
  // int _findGroupEnd(List<MapLayer> layers, int index) {
  //   int end = index;

  //   // 向后查找组的结束
  //   while (end < layers.length - 1) {
  //     if (layers[end].isLinkedToNext) {
  //       end++;
  //     } else {
  //       break;
  //     }
  //   }

  //   return end;
  // }
  // 使用响应式系统删除图例组
  void _deleteLegendGroup(LegendGroup group) {
    if (_currentMap == null) return;

    // 使用响应式系统删除图例组
    try {
      deleteLegendGroupReactive(group.id);
      debugPrint('使用响应式系统删除图例组: ${group.name}');

      // 显示成功消息
      _showSuccessSnackBar('已删除图例组 "${group.name}"');
    } catch (e) {
      debugPrint('响应式系统删除图例组失败: $e');
      _showErrorSnackBar('删除图例组失败: ${e.toString()}');
    }
  }

  // 使用响应式系统更新图例组
  void _updateLegendGroup(LegendGroup updatedGroup) {
    if (_currentMap == null) return;

    debugPrint('地图编辑器：更新图例组 ${updatedGroup.name}');
    debugPrint('更新的图例项数量: ${updatedGroup.legendItems.length}');

    // 如果当前正在管理这个图例组，同时更新管理抽屉的状态
    if (_currentLegendGroupForManagement?.id == updatedGroup.id) {
      debugPrint('同步更新图例组管理抽屉的状态');
      setState(() {
        _currentLegendGroupForManagement = updatedGroup;
      });
    }

    // 使用响应式系统更新图例组
    try {
      updateLegendGroupReactive(updatedGroup);
      debugPrint('使用响应式系统更新图例组: ${updatedGroup.name}');

      // // 显示成功消息
      // _showSuccessSnackBar('已更新图例组 "${updatedGroup.name}"');
    } catch (e) {
      debugPrint('响应式系统更新图例组失败: $e');
      _showErrorSnackBar('更新图例组失败: ${e.toString()}');
    }
  } // 处理透明度预览

  void _handleOpacityPreview(String layerId, double opacity) {
    // 只更新预览状态，不触发完整重绘
    _previewOpacityValues[layerId] = opacity;

    // 使用优化的setState，避免全量重绘
    if (mounted) {
      setState(() {
        // 只更新透明度预览值
      });
    }
  } // 显示图层图例绑定抽屉

  void _showLayerLegendBindingDrawer(
    MapLayer layer,
    List<LegendGroup> allLegendGroups,
  ) {
    setState(() {
      // 关闭其他抽屉
      _isLegendGroupManagementDrawerOpen = false;
      _isLayerBindingDrawerOpen = false;
      _isZIndexInspectorOpen = false;
      _currentLegendGroupForManagement = null;
      _currentLegendGroupForBinding = null;
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
    String? defaultExpandedPanel,
  }) {
    setState(() {
      // 关闭其他抽屉
      _isLayerLegendBindingDrawerOpen = false;
      _isLayerBindingDrawerOpen = false;
      _isZIndexInspectorOpen = false;
      _currentLayerForBinding = null;
      _allLegendGroupsForBinding = null;
      _currentLegendGroupForBinding = null;

      // 打开图例组管理抽屉
      _currentLegendGroupForManagement = legendGroup;
      _initialSelectedLegendItemId = selectedLegendItemId;
      _defaultExpandedPanel = defaultExpandedPanel;
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

    // 如果找到了包含该图例项的图例组
    if (containingGroup != null) {
      // 检查抽屉是否已经打开且是同一个图例组
      if (_isLegendGroupManagementDrawerOpen &&
          _currentLegendGroupForManagement?.id == containingGroup.id) {
        // 抽屉已经打开且是同一个图例组，强制更新选中项和展开状态
        // debugPrint('双击图例：抽屉已打开，更新选中项 ${item.id}');
        setState(() {
          // 先清空再设置，确保触发变化
          _initialSelectedLegendItemId = null;
          _defaultExpandedPanel = null;
        });
        // 延迟设置新值，确保触发 didUpdateWidget
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _initialSelectedLegendItemId = item.id;
            _defaultExpandedPanel = 'legendList';
          });
        });
      } else {
        // 抽屉未打开或是不同的图例组，正常打开抽屉
        // debugPrint('双击图例：打开新抽屉，图例组 ${containingGroup.id}，选中项 ${item.id}');
        _showLegendGroupManagementDrawer(
          containingGroup,
          selectedLegendItemId: item.id,
          defaultExpandedPanel: 'legendList',
        );
      }
    }
  }

  // 显示图层绑定抽屉
  void _showLayerBindingDrawer(LegendGroup legendGroup) {
    setState(() {
      // 关闭其他抽屉
      _isLayerLegendBindingDrawerOpen = false;
      _isLegendGroupManagementDrawerOpen = false;
      _isZIndexInspectorOpen = false;
      _currentLayerForBinding = null;
      _allLegendGroupsForBinding = null;
      _currentLegendGroupForManagement = null;
      _initialSelectedLegendItemId = null;

      // 打开图层绑定抽屉
      _isLayerBindingDrawerOpen = true;
      _currentLegendGroupForBinding = legendGroup;
    });
  }

  // 关闭图层图例绑定抽屉
  void _closeLayerLegendBindingDrawer() {
    setState(() {
      _isLayerLegendBindingDrawerOpen = false;
      _currentLayerForBinding = null;
      _allLegendGroupsForBinding = null;
    });
  }

  // 关闭图层绑定抽屉
  void _closeLayerBindingDrawer() {
    setState(() {
      _isLayerBindingDrawerOpen = false;
      _currentLegendGroupForBinding = null;
    });
  }

  // 更新图层绑定状态

  // 关闭图例组管理抽屉
  void _closeLegendGroupManagementDrawer() {
    setState(() {
      _isLegendGroupManagementDrawerOpen = false;
      _currentLegendGroupForManagement = null;
      _initialSelectedLegendItemId = null;
      _defaultExpandedPanel = null;
    });
  }

  // 显示Z层级检视器
  void _showZIndexInspector() {
    // 如果没有选中图层或便签，尝试获取默认绘制目标图层
    MapLayer? targetLayer = _selectedLayer;
    if (targetLayer == null && _selectedStickyNote == null) {
      targetLayer = _getCurrentDrawingTargetLayer();
      if (targetLayer == null) return; // 如果仍然没有可用图层，则返回
      
      // 自动选择默认图层
      _onLayerSelected(targetLayer);
    }

    setState(() {
      // 关闭其他抽屉
      _isLayerLegendBindingDrawerOpen = false;
      _isLegendGroupManagementDrawerOpen = false;
      _isLayerBindingDrawerOpen = false;
      _currentLayerForBinding = null;
      _allLegendGroupsForBinding = null;
      _currentLegendGroupForManagement = null;
      _currentLegendGroupForBinding = null;
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

  /// 使用响应式版本管理系统保存所有版本
  Future<void> _saveWithReactiveVersions(MapItem baseMap) async {
    final adapter = versionAdapter!;
    final versionManager = adapter.versionManager;

    debugPrint('开始保存响应式版本数据 [地图: ${baseMap.title}]');
    debugPrint('版本数量: ${allVersionStates.length}');

    for (final versionState in allVersionStates) {
      final versionId = versionState.versionId;
      debugPrint('保存版本: $versionId (${versionState.versionName})');
      debugPrint(
        '版本状态: 有会话数据=${versionState.sessionData != null}, 有未保存更改=${versionState.hasUnsavedChanges}',
      );

      // 获取版本的完整数据
      MapItem versionMapData;
      if (versionState.sessionData != null) {
        // 使用会话中的数据
        versionMapData = versionState.sessionData!.copyWith(
          updatedAt: DateTime.now(),
        );
        debugPrint('版本 $versionId 使用会话数据，图层数: ${versionMapData.layers.length}');
      } else {
        // 如果没有会话数据，尝试从VFS加载该版本的数据
        debugPrint('版本 $versionId 没有会话数据，尝试从VFS加载');
        try {
          final versionExists = await _vfsMapService.mapVersionExists(
            baseMap.title,
            versionId,
            widget.folderPath,
          );
          if (versionExists) {
            // 从VFS加载该版本的数据
            final mapLayers = await _vfsMapService.getMapLayers(
              baseMap.title,
              versionId,
              widget.folderPath,
            );
            final legendGroups = await _vfsMapService.getMapLegendGroups(
              baseMap.title,
              versionId,
              widget.folderPath,
            );
            final stickyNotes = await _vfsMapService.getMapStickyNotes(
              baseMap.title,
              versionId,
              widget.folderPath,
            );
            versionMapData = baseMap.copyWith(
              layers: mapLayers,
              legendGroups: legendGroups,
              stickyNotes: stickyNotes,
              updatedAt: DateTime.now(),
            );
            debugPrint(
              '从VFS加载版本 $versionId 数据，图层数: ${mapLayers.length}, 便签数: ${stickyNotes.length}',
            );
          } else {
            // 版本不存在，使用基础地图数据（这可能是第一次保存）
            versionMapData = baseMap.copyWith(updatedAt: DateTime.now());
            debugPrint('版本 $versionId 不存在，使用基础数据作为初始数据');
          }
        } catch (e) {
          debugPrint('加载版本 $versionId 数据失败: $e，使用基础数据');
          versionMapData = baseMap.copyWith(updatedAt: DateTime.now());
        }
      }

      // 3. 保存版本数据到VFS（使用清理重建模式）
      if (versionId == 'default') {
        // 默认版本：保存完整的地图结构
        await _saveVersionToVfs(versionMapData, versionId, isDefault: true);
      } else {
        // 其他版本：保存版本特定的数据
        await _saveVersionToVfs(versionMapData, versionId, isDefault: false);
      }

      // 4. 保存版本元数据
      await _vfsMapService.saveVersionMetadata(
        baseMap.title,
        versionId,
        versionState.versionName,
        createdAt: versionState.createdAt,
        updatedAt: versionState.lastModified,
        folderPath: widget.folderPath,
      );
    }

    // 5. 标记所有版本为已保存状态
    versionManager.markAllVersionsSaved();

    debugPrint('所有响应式版本数据已成功保存到VFS存储');
  }

  /// 保存单个版本的数据到VFS存储
  Future<void> _saveVersionToVfs(
    MapItem versionData,
    String versionId, {
    required bool isDefault,
  }) async {
    try {
      debugPrint('保存版本数据到VFS: ${versionData.title}/$versionId');

      if (isDefault) {
        // 默认版本：使用完整的saveMap方法（包含清理逻辑）
        await _vfsMapService.saveMap(versionData, widget.folderPath);
        debugPrint('默认版本已保存 (完整重建)');
      } else {
        // 其他版本：确保版本目录存在
        final versionExists = await _vfsMapService.mapVersionExists(
          versionData.title,
          versionId,
          widget.folderPath,
        );
        if (!versionExists) {
          // 创建空的版本目录，不从默认版本复制
          await _vfsMapService.createMapVersion(
            versionData.title,
            versionId,
            null, // 不从其他版本复制，创建空目录
            widget.folderPath,
          );
        } // 保存版本特定的图层数据（保存该版本实际的数据）
        for (final layer in versionData.layers) {
          await _vfsMapService.saveLayer(
            versionData.title,
            layer,
            versionId,
            widget.folderPath,
          );
        }

        // 保存版本特定的图例组数据（保存该版本实际的数据）
        for (final group in versionData.legendGroups) {
          await _vfsMapService.saveLegendGroup(
            versionData.title,
            group,
            versionId,
            widget.folderPath,
          );
        }

        // 保存版本特定的便签数据（保存该版本实际的数据）
        for (final stickyNote in versionData.stickyNotes) {
          await _vfsMapService.saveStickyNote(
            versionData.title,
            stickyNote,
            versionId,
            widget.folderPath,
          );
        }

        debugPrint('版本 $versionId 数据已保存 (使用该版本的实际数据)');
      }
    } catch (e) {
      debugPrint('保存版本数据失败 [$versionId]: $e');
      rethrow;
    }
  }

  // 版本管理相关方法 - 已迁移到响应式系统
  /// 初始化版本管理（已废弃，使用响应式系统）
  // Future<void> _initializeVersions() async {
  //   // 已迁移到响应式版本管理系统
  // }
  /// 加载已存在的版本（已废弃，使用响应式系统）
  // Future<void> _loadExistingVersions() async {
  //   // 已迁移到响应式版本管理系统
  // }
  /// 为版本ID生成友好的显示名称（已废弃，使用响应式系统）
  // Future<String> _getVersionDisplayName(String versionId) async {
  //   // 已迁移到响应式版本管理系统
  // }  /// 创建新版本（使用响应式系统）
  void _createVersion(String name) async {
    if (_currentMap == null) return;

    try {
      // 生成唯一的版本ID
      final versionId = 'version_${DateTime.now().millisecondsSinceEpoch}';

      debugPrint(
        '创建版本前状态: 当前版本=$currentVersionId, 当前地图图层数=${_currentMap!.layers.length}',
      );

      // 使用响应式版本管理创建新版本（从当前版本复制数据）
      final newVersionState = await createVersion(
        versionId,
        versionName: name,
        sourceVersionId: currentVersionId, // 从当前版本复制
      );

      if (newVersionState != null) {
        debugPrint(
          '新版本已创建: $versionId, 会话数据=${newVersionState.sessionData != null ? '有(图层数: ${newVersionState.sessionData!.layers.length})' : '无'}',
        );

        setState(() {
          // 新版本创建时重置选择状态
          if (_currentMap != null && _currentMap!.layers.isNotEmpty) {
            _selectedLayer = _currentMap!.layers.first;
          } else {
            _selectedLayer = null;
          }
          _selectedLayerGroup = null;
          _selectedElementId = null;

          // 更新显示顺序
          _updateDisplayOrderAfterLayerChange();
        });

        // 保存版本名称到VFS元数据
        try {
          await _vfsMapService.saveVersionMetadata(
            _currentMap!.title,
            versionId,
            name,
            createdAt: newVersionState.createdAt,
            updatedAt: newVersionState.lastModified,
            folderPath: widget.folderPath,
          );
          debugPrint('版本名称已保存到元数据: $name (ID: $versionId)');
        } catch (e) {
          debugPrint('保存版本元数据失败: $e');
          // 不影响主流程，只是记录错误
        }

        debugPrint('新版本已创建: $versionId');
        _showSuccessSnackBar('版本 "$name" 已创建');
      }
    } catch (e) {
      debugPrint('创建版本失败: $e');
      _showErrorSnackBar('创建版本失败: ${e.toString()}');
    }
  }

  /// 切换版本（使用响应式系统）
  void _switchVersion(String versionId) {
    if (versionId == currentVersionId) {
      return; // 已经是当前版本
    }
    try {
      // 保存当前的选择状态
      final previousSelectedLayerId = _selectedLayer?.id;
      final previousSelectedLayerGroupIds = _selectedLayerGroup
          ?.map((layer) => layer.id)
          .toList();
      final previousSelectedElementId = _selectedElementId;
      final previousSelectedStickyNoteId = _selectedStickyNote?.id;

      // 使用响应式版本管理切换版本
      switchVersion(versionId).then((_) {
        setState(() {
          // 响应式系统会自动管理状态

          // 尝试恢复选择状态
          if (_currentMap != null && _currentMap!.layers.isNotEmpty) {
            // 尝试恢复选中的图层
            if (previousSelectedLayerId != null) {
              final matchingLayer = _currentMap!.layers
                  .where((layer) => layer.id == previousSelectedLayerId)
                  .firstOrNull;
              if (matchingLayer != null) {
                _selectedLayer = matchingLayer;
              } else {
                // 如果找不到之前选中的图层，选择第一个图层
                _selectedLayer = _currentMap!.layers.first;
              }
            } else {
              _selectedLayer = _currentMap!.layers.first;
            }

            // 尝试恢复选中的图层组
            if (previousSelectedLayerGroupIds != null &&
                previousSelectedLayerGroupIds.isNotEmpty) {
              final matchingLayers = <MapLayer>[];
              for (final layerId in previousSelectedLayerGroupIds) {
                final matchingLayer = _currentMap!.layers
                    .where((layer) => layer.id == layerId)
                    .firstOrNull;
                if (matchingLayer != null) {
                  matchingLayers.add(matchingLayer);
                }
              }
              if (matchingLayers.isNotEmpty) {
                _selectedLayerGroup = matchingLayers;
                // 不清除单个图层选择，保持图层和图层组可以同时存在的状态
              } else {
                // 如果图层组无法恢复，清除图层组选择
                _selectedLayerGroup = null;
              }
            } else {
              // 如果之前没有选中图层组，确保清除图层组选择
              _selectedLayerGroup = null;
            }
          } else {
            _selectedLayer = null;
            _selectedLayerGroup = null;
          }

          // 尝试恢复选中的元素
          if (previousSelectedElementId != null && _selectedLayer != null) {
            final hasElement = _selectedLayer!.elements.any(
              (element) => element.id == previousSelectedElementId,
            );
            if (hasElement) {
              _selectedElementId = previousSelectedElementId;
            } else {
              _selectedElementId = null;
            }
          } else {
            _selectedElementId = null;
          }

          // 尝试恢复选中的便签
          if (previousSelectedStickyNoteId != null && _currentMap != null) {
            final matchingStickyNote = _currentMap!.stickyNotes
                .where((note) => note.id == previousSelectedStickyNoteId)
                .firstOrNull;
            if (matchingStickyNote != null) {
              _selectedStickyNote = matchingStickyNote;
            } else {
              _selectedStickyNote = null;
            }
          } else {
            _selectedStickyNote = null;
          }

          // 更新显示顺序
          _updateDisplayOrderAfterLayerChange();
        });

        // _showSuccessSnackBar('已切换到版本');
        debugPrint('已切换到版本: $versionId');
      });
    } catch (e) {
      debugPrint('切换版本失败: $e');
      _showErrorSnackBar('切换版本失败: ${e.toString()}');
    }
  }

  /// 删除版本（使用响应式系统）
  Future<void> _deleteVersion(String versionId) async {
    if (_currentMap == null || versionId == 'default') {
      _showErrorSnackBar('无法删除默认版本');
      return;
    }

    try {
      // 记录删除前的当前版本ID
      final previousVersionId = currentVersionId;

      // 使用响应式版本管理删除版本
      await deleteVersion(versionId);

      // 删除VFS存储中的版本数据和元数据
      debugPrint('开始删除版本存储数据...');

      // 1. 删除VFS中的版本数据
      try {
        await _vfsMapService.deleteMapVersion(
          _currentMap!.title,
          versionId,
          widget.folderPath,
        );
        debugPrint('VFS版本数据删除成功: $versionId');
      } catch (e) {
        debugPrint('删除VFS版本数据失败: $e');
        // 如果删除VFS数据失败，仍然继续删除元数据
      }

      // 2. 删除版本元数据
      try {
        await _vfsMapService.deleteVersionMetadata(
          _currentMap!.title,
          versionId,
          widget.folderPath,
        );
        debugPrint('版本元数据删除成功: $versionId');
      } catch (e) {
        debugPrint('删除版本元数据失败: $e');
        // 元数据删除失败不影响主流程
      }

      // 检查当前版本是否已经改变（如果删除的是当前版本）
      final newCurrentVersionId = currentVersionId;
      if (previousVersionId == versionId &&
          newCurrentVersionId != null &&
          newCurrentVersionId != versionId) {
        // 当前版本已经自动切换到其他版本，需要加载新版本的数据到画布
        // debugPrint('当前版本已自动切换到: $newCurrentVersionId，正在加载画布数据...');
        await switchVersion(newCurrentVersionId);
      }

      setState(() {
        // 响应式系统会自动管理状态
      });

      _showSuccessSnackBar('版本已完全删除');
      debugPrint('版本删除完成: $versionId');
    } catch (e) {
      debugPrint('删除版本失败: $e');
      _showErrorSnackBar('删除版本失败: ${e.toString()}');
    }
  }

  /// 保存所有版本数据到持久存储（已废弃，使用响应式系统）
  // Future<void> _saveAllVersionsToStorage() async {
  //   // 已迁移到响应式版本管理系统
  // }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      context.showErrorSnackBar(message);
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      context.showSuccessSnackBar(message);
    }
  }

  // 退出确认对话框
  Future<bool> _showExitConfirmDialog() async {
    // 无论是否有未保存的更改，都先保存会话状态和面板状态
    await _savePanelStatesOnExit();

    // 使用ReactiveVersionTabBar的静态属性检查是否有未保存的版本
    final hasUnsavedVersions = ReactiveVersionTabBar.hasAnyUnsavedVersions;
    debugPrint(
      '退出确认检查: _hasUnsavedChanges=$_hasUnsavedChanges, hasUnsavedVersions=$hasUnsavedVersions',
    );

    // 如果没有未保存更改且没有未保存的版本，或者在预览模式，直接允许退出
    if ((!_hasUnsavedChanges && !hasUnsavedVersions) ||
        widget.isPreviewMode ||
        kIsWeb) {
      return true;
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
            onPressed: () async {
              Navigator.of(context).pop(true); // 先弹出对话框
              if (mounted) {
                await _savePanelStatesOnExit(); // 保存面板状态
              }
            },
            child: const Text('不保存退出'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(false); // 先关闭对话框
              saveMap(); // 保存地图
              if (mounted) {
                await _savePanelStatesOnExit(); // 保存面板状态
                if (!_hasUnsavedChanges && context.mounted) {
                  context.pop(); // 使用 go_router 的方式退出
                }
              }
            },
            child: const Text('保存并退出'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// 在退出时保存面板状态
  Future<void> _savePanelStatesOnExit() async {
    if (!_panelStatesChanged || !mounted) {
      return;
    }

    try {
      final prefsProvider = context.read<UserPreferencesProvider>();
      final layout =
          prefsProvider.layout; // 只有当autoRestorePanelStates为true时才保存面板状态
      if (layout.autoRestorePanelStates) {
        await prefsProvider.updateLayout(
          panelCollapsedStates: {
            ...layout.panelCollapsedStates,
            'sidebar': _isSidebarCollapsed,
            'drawing': _isDrawingToolbarCollapsed,
            'layer': _isLayerPanelCollapsed,
            'legend': _isLegendPanelCollapsed,
            'stickyNote': _isStickyNotePanelCollapsed,
            'script': _isScriptPanelCollapsed,
          },
          panelAutoCloseStates: {
            ...layout.panelAutoCloseStates,
            'drawing': _isDrawingToolbarAutoClose,
            'layer': _isLayerPanelAutoClose,
            'legend': _isLegendPanelAutoClose,
            'stickyNote': _isStickyNotePanelAutoClose,
            'script': _isScriptPanelAutoClose,
          },
        );

        _panelStatesChanged = false;
        debugPrint('面板状态已在退出时保存');
      }
    } catch (e) {
      debugPrint('保存面板状态失败: $e');
    }
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
          if (_isStickyNotePanelAutoClose && !_isStickyNotePanelCollapsed) {
            _isStickyNotePanelCollapsed = true;
            changedPanels.add('stickyNote');
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
          if (_isStickyNotePanelAutoClose && !_isStickyNotePanelCollapsed) {
            _isStickyNotePanelCollapsed = true;
            changedPanels.add('stickyNote');
          }
          if (_isScriptPanelAutoClose && !_isScriptPanelCollapsed) {
            _isScriptPanelCollapsed = true;
            changedPanels.add('script');
          }
          _isLayerPanelCollapsed = !_isLayerPanelCollapsed;
          break;
        case 'legend':
          // 如果其他面板开启了自动关闭，则关闭它们
          if (_isDrawingToolbarAutoClose && !_isDrawingToolbarCollapsed) {
            _isDrawingToolbarCollapsed = true;
            changedPanels.add('drawing');
          }
          if (_isLayerPanelAutoClose && !_isLayerPanelCollapsed) {
            _isLayerPanelCollapsed = true;
            changedPanels.add('layer');
          }
          if (_isStickyNotePanelAutoClose && !_isStickyNotePanelCollapsed) {
            _isStickyNotePanelCollapsed = true;
            changedPanels.add('stickyNote');
          }
          if (_isScriptPanelAutoClose && !_isScriptPanelCollapsed) {
            _isScriptPanelCollapsed = true;
            changedPanels.add('script');
          }
          _isLegendPanelCollapsed = !_isLegendPanelCollapsed;
          break;
        case 'stickyNote':
          // 如果其他面板开启了自动关闭，则关闭它们
          if (_isDrawingToolbarAutoClose && !_isDrawingToolbarCollapsed) {
            _isDrawingToolbarCollapsed = true;
            changedPanels.add('drawing');
          }
          if (_isLayerPanelAutoClose && !_isLayerPanelCollapsed) {
            _isLayerPanelCollapsed = true;
            changedPanels.add('layer');
          }
          if (_isLegendPanelAutoClose && !_isLegendPanelCollapsed) {
            _isLegendPanelCollapsed = true;
            changedPanels.add('legend');
          }
          if (_isScriptPanelAutoClose && !_isScriptPanelCollapsed) {
            _isScriptPanelCollapsed = true;
            changedPanels.add('script');
          }
          _isStickyNotePanelCollapsed = !_isStickyNotePanelCollapsed;
          break;
        case 'script':
          // 如果其他面板开启了自动关闭，则关闭它们
          if (_isDrawingToolbarAutoClose && !_isDrawingToolbarCollapsed) {
            _isDrawingToolbarCollapsed = true;
            changedPanels.add('drawing');
          }
          if (_isLayerPanelAutoClose && !_isLayerPanelCollapsed) {
            _isLayerPanelCollapsed = true;
            changedPanels.add('layer');
          }
          if (_isLegendPanelAutoClose && !_isLegendPanelCollapsed) {
            _isLegendPanelCollapsed = true;
            changedPanels.add('legend');
          }
          if (_isStickyNotePanelAutoClose && !_isStickyNotePanelCollapsed) {
            _isStickyNotePanelCollapsed = true;
            changedPanels.add('stickyNote');
          }
          _isScriptPanelCollapsed = !_isScriptPanelCollapsed;
          break;
      }
    });

    // 标记面板状态有变化，但不立即保存
    _panelStatesChanged = true;
  }

  /// 构建图层面板的副标题
  String _buildLayerPanelSubtitle() {
    final hasSelectedLayer = _selectedLayer != null;
    final hasSelectedGroup =
        _selectedLayerGroup != null && _selectedLayerGroup!.isNotEmpty;

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
    }
  }

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
        case 'stickyNote':
          _isStickyNotePanelAutoClose = value;
          break;
        case 'script':
          _isScriptPanelAutoClose = value;
          break;
      }
    });

    // 标记面板状态有变化，但不立即保存
    _panelStatesChanged = true;
  }

  /// 构建窗口控制按钮组
  List<Widget> _buildWindowControls() {
    return [const WindowControls(spacing: 4.0)];
  }

  /// 构建地图编辑器标题
  Widget _buildMapEditorTitle() {
    final l10n = AppLocalizations.of(context)!;
    final baseTitle = widget.isPreviewMode ? l10n.mapPreview : l10n.mapEditor;
    final titleText = '$baseTitle - ${widget.mapTitle}';

    return Row(
      children: [
        Text(
          titleText,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 16),
        if (!widget.isPreviewMode) // 只在编辑模式下显示状态栏
          EditorStatusBar(
            layers: _currentMap?.layers,
            stickyNotes: _currentMap?.stickyNotes,
            selectedLayer: _selectedLayer,
            selectedLayerGroup: _selectedLayerGroup,
            selectedDrawingTool: _selectedDrawingTool,
            selectedColor: _selectedColor,
            selectedStrokeWidth: _selectedStrokeWidth,
            selectedDensity: _selectedDensity,
            selectedCurvature: _selectedCurvature,
            selectedTriangleCut: _selectedTriangleCut,
            isCompact: true,
            getCurrentDrawingTargetLayer: () => _getCurrentDrawingTargetLayer(),
          ),
      ],
    );
  }

  /// 构建标题栏操作按钮
  List<Widget> _buildTitleBarActions() {
    return [
      // 计时器组件
      CompactTimerWidget(mapDataBloc: reactiveIntegration.mapDataBloc),
      const SizedBox(width: 4),

      // 地图信息按钮
      IconButton(
        icon: const Icon(Icons.info_outline),
        onPressed: _showMapInfo,
        tooltip: '地图信息',
      ),

      // 十字线按钮
      const SizedBox(width: 4),
      IconButton(
        icon: Icon(
          Icons.square_foot,
          color: _isCrosshairEnabled
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
        onPressed: () {
          setState(() {
            _isCrosshairEnabled = !_isCrosshairEnabled;
          });
        },
        tooltip: _isCrosshairEnabled ? '关闭十字线' : '开启十字线',
      ),

      // 导出按钮
      const SizedBox(width: 4),
      IconButton(
        icon: const Icon(Icons.download),
        onPressed: _showExportDialog,
        tooltip: '导出图层',
      ),

      // 保存按钮（仅在编辑模式下显示）
      if (!widget.isPreviewMode) ...[
        const SizedBox(width: 4),
        IconButton(
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.save),
          onPressed: _isLoading ? null : saveMap,
          tooltip: _isLoading ? '保存中...' : '保存',
        ),
      ],

      // 分隔符
      Container(
        height: 24,
        width: 1,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: Theme.of(context).dividerColor,
      ),

      // 窗口控制按钮（始终放在最后）
      ..._buildWindowControls(),
    ];
  }

  /// 显示地图信息对话框
  void _showMapInfo() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.map, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('地图信息'),
            ],
          ),
          content: SizedBox(
            width: 400, // 设置固定宽度
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoRow('地图名称', widget.mapTitle ?? '未知地图'),
                  _buildInfoRow('编辑模式', widget.isPreviewMode ? '预览模式' : '编辑模式'),
                  if (widget.folderPath != null)
                    _buildInfoRow('文件夹路径', widget.folderPath ?? ''),
                  _buildInfoRow('当前版本', 'default'),
                  const SizedBox(height: 16),
                  Text(
                    '编辑器状态',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusRow(
                    '是否有未保存更改',
                    _hasUnsavedChanges ||
                        ReactiveVersionTabBar.hasAnyUnsavedVersions,
                  ),
                  _buildStatusRow('面板状态已更改', _panelStatesChanged),
                  const SizedBox(height: 16),
                  // 快捷键按钮
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(); // 关闭当前对话框
                        ShortcutsDialog.show(context); // 显示快捷键对话框
                      },
                      icon: const Icon(Icons.keyboard),
                      label: const Text('查看快捷键列表'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  /// 显示导出对话框
  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return LayerExportDialog(
          layers: _currentMap?.layers ?? [],
          legendGroups: _currentMap?.legendGroups,
          stickyNotes: _currentMap?.stickyNotes,
          mapCanvasState: _mapCanvasKey.currentState,
          onExport: (layerId) {
            // TODO: 实现导出功能
            final layer = _currentMap?.layers.firstWhere(
              (l) => l.id == layerId,
              orElse: () => throw Exception('Layer not found: $layerId'),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('导出图层: ${layer?.name ?? layerId}'),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      },
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建状态行（使用对钩和叉子符号）
  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(
                  status ? Icons.check_circle : Icons.cancel,
                  size: 18,
                  color: status ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  status ? '是' : '否',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: status ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefsProvider, child) {
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
            focusNode: _mainFocusNode,
            autofocus: true,
            onKey: _handleKeyEvent,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(64), // 只有标题栏高度
                child: DraggableTitleBar(
                  titleWidget: _buildMapEditorTitle(),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.arrow_back),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                final shouldExit =
                                    await _showExitConfirmDialog();
                                if (shouldExit && context.mounted) {
                                  context.pop(); // 使用 go_router 的方式退出
                                }
                              },
                        tooltip: _isLoading ? '保存中...' : '返回',
                      ),
                      Icon(
                        Icons.edit_location,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ],
                  ),
                  actions: _buildTitleBarActions(),
                  exemptFromWindowControlsMode: true,
                ),
              ),
              body: Column(
                children: [
                  // 版本管理标签栏，紧贴标题栏
                  ReactiveVersionTabBar(
                    versions: allVersionStates,
                    currentVersionId: currentVersionId,
                    onVersionSelected: _switchVersion,
                    onVersionCreated: _createVersion,
                    onVersionDeleted: _deleteVersion,
                    isPreviewMode: widget.isPreviewMode,
                  ),
                  // 主体内容区域
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Stack(
                            children: [
                              // 主要内容 - 使用统一的布局，支持侧边栏折叠
                              _buildMainLayout(userPrefsProvider),

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
                                      allLegendGroups:
                                          _allLegendGroupsForBinding!,
                                      onLayerUpdated: _updateLayer,
                                      onLegendGroupTapped:
                                          _showLegendGroupManagementDrawer,
                                      onClose: _closeLayerLegendBindingDrawer,
                                    ),
                                  ),
                                ),
                              // 图例组管理抽屉覆盖层
                              if (_isLegendGroupManagementDrawerOpen &&
                                  _currentLegendGroupForManagement != null &&
                                  !_isDragTemporaryHidden) // 添加拖拽临时隐藏条件
                                Positioned(
                                  top: 16,
                                  bottom: 16,
                                  right: 16,
                                  child: Material(
                                    elevation: 8,
                                    borderRadius: BorderRadius.circular(12),
                                    child: ListenableBuilder(
                                      listenable: newReactiveScriptManager,
                                      builder: (context, child) {
                                        return LegendGroupManagementDrawer(
                                          mapId:
                                              widget.mapTitle, // 传递地图ID用于扩展设置隔离
                                          legendGroup:
                                              _currentLegendGroupForManagement!,
                                          availableLegends: [], // 不再需要预载图例列表
                                          onLegendGroupUpdated:
                                              _updateLegendGroup,
                                          isPreviewMode: widget.isPreviewMode,
                                          onClose:
                                              _closeLegendGroupManagementDrawer,
                                          onLegendItemSelected:
                                              _selectLegendItem,
                                          allLayers: _currentMap
                                              ?.layers, // 传递所有图层用于智能隐藏功能
                                          selectedLayer:
                                              _selectedLayer, // 传递当前选中的图层
                                          initialSelectedLegendItemId:
                                              _initialSelectedLegendItemId, // 传递初始选中的图例项ID
                                          selectedElementId:
                                              _selectedElementId, // 传递当前选中的元素ID用于外部状态同步
                                          scripts: newReactiveScriptManager
                                              .scripts, // 修正：传递正确的脚本列表
                                          scriptManager:
                                              newReactiveScriptManager, // 新增：传递脚本管理器
                                          onSmartHideStateChanged:
                                              setLegendGroupSmartHideState,
                                          getSmartHideState:
                                              getLegendGroupSmartHideState,
                                          onZoomFactorChanged:
                                              setLegendGroupZoomFactor,
                                          getZoomFactor:
                                              getLegendGroupZoomFactor,
                                          versionManager: versionAdapter!
                                              .versionManager, // 传递版本管理器
                                          onLegendDragToCanvas:
                                              _handleLegendDragToCanvas, // 新增：拖拽图例到画布的回调
                                          onDragStart: _handleDragStart, // 添加这行
                                          onDragEnd: _handleDragEnd, // 添加这行
                                          onInputFieldFocusChanged:
                                              _setInputFieldFocused, // 输入框焦点状态变化回调
                                          defaultExpandedPanel:
                                              _defaultExpandedPanel, // 传递默认展开的面板
                                          absoluteMapPath: widget
                                              .absoluteMapPath, // 传递地图的绝对路径
                                          onShowLayerBinding: (legendGroup) {
                                            _showLayerBindingDrawer(
                                              legendGroup,
                                            );
                                          }, // 显示图层绑定抽屉的回调
                                        );
                                      },
                                    ),
                                  ),
                                ), // Z层级检视器覆盖层
                              if (_isZIndexInspectorOpen &&
                                  (_selectedLayer != null ||
                                      _selectedStickyNote != null))
                                Positioned(
                                  top: 16,
                                  bottom: 16,
                                  right: 16,
                                  child: Material(
                                    elevation: 8,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: userPrefsProvider
                                          .layout
                                          .drawerWidth, // 使用用户偏好设置的抽屉宽度
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 标题栏
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondaryContainer,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      12,
                                                    ),
                                                    topRight: Radius.circular(
                                                      12,
                                                    ),
                                                  ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.layers,
                                                  size: 20,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSecondaryContainer,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _selectedStickyNote != null
                                                      ? '便签元素检视器 - ${_selectedStickyNote!.title}'
                                                      : 'Z层级检视器',
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
                                                  onPressed:
                                                      _closeZIndexInspector,
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
                                                  selectedStickyNote:
                                                      _selectedStickyNote,
                                                  onElementDeleted:
                                                      _deleteElement,
                                                  selectedElementId:
                                                      _selectedElementId,
                                                  onElementSelected: (elementId) {
                                                    setState(
                                                      () => _selectedElementId =
                                                          elementId,
                                                    );
                                                  },
                                                  onElementUpdated:
                                                      _updateElement,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              // 图层绑定抽屉覆盖层
                              if (_isLayerBindingDrawerOpen &&
                                  _currentLegendGroupForBinding != null &&
                                  !_isDragTemporaryHidden) // 添加拖拽临时隐藏条件
                                Positioned(
                                  top: 16,
                                  bottom: 16,
                                  right: 16,
                                  child: Material(
                                    elevation: 8,
                                    borderRadius: BorderRadius.circular(12),
                                    child: LayerBindingDrawer(
                                      legendGroup:
                                          _currentLegendGroupForBinding!,
                                      allLayers: _currentMap?.layers ?? [],
                                      onLayersUpdated: _updateLayersBinding,
                                      onClose: _closeLayerBindingDrawer,
                                    ),
                                  ),
                                ),

                              // 图例浮动dock栏
                              Positioned(
                                bottom: 20,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: LegendDockBar(
                                    mapItem: _currentMap!,
                                    selectedLayerGroup: _selectedLayerGroup,
                                    selectedLayer: _selectedLayer,
                                    legendSessionManager:
                                        versionAdapter?.legendSessionManager,
                                    onLegendItemSelected: _selectLegendItem,
                                    onToggleLegendGroupManagement:
                                        toggleLegendGroupManagementDrawer,
                                    onLegendGroupSelected:
                                        _showLegendGroupManagementDrawer,
                                    currentLegendGroupForManagement:
                                        _currentLegendGroupForManagement,
                                    selectedElementId: _selectedElementId,
                                    onLayerSelected: _onLayerSelected,
                                    onLayerGroupSelected: _onLayerGroupSelected,
                                    onSelectionCleared: () =>
                                        _keyboardShortcutActions
                                            ?.clearLayerSelection(),
                                    onLayerSelectionCleared:
                                        _onLayerSelectionCleared,
                                    onLayerGroupSelectionCleared:
                                        _onLayerGroupSelectionCleared,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ), // 关闭 PopScope 的 child 参数
                ],
              ),
            ),
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
        isCollapsed: _isDrawingToolbarCollapsed,
        onToggleCollapsed: () => _handlePanelToggle('drawing'),
        autoCloseEnabled: _isDrawingToolbarAutoClose,
        onAutoCloseToggled: (value) => _handleAutoCloseToggle('drawing', value),
        compactMode: layout.compactMode,
        showTooltips: layout.showTooltips,
        animationDuration: layout.animationDuration,
        enableAnimations: layout.enableAnimations, // 修改禁用状态提示逻辑
        collapsedSubtitle: _shouldDisableDrawingTools
            ? '无可见图层，绘制工具已禁用'
            : _selectedStickyNote != null
            ? '绘制到便签: ${_selectedStickyNote!.title}'
            : _selectedLayer != null
            ? '绘制到: ${_selectedLayer!.name}'
            : _getCurrentDrawingTargetLayer() != null
            ? '绘制到: ${_getCurrentDrawingTargetLayer()!.name} (默认最上层)'
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
                        // 选择绘制工具时清除当前选择，但保留便签选择
                        if (tool != null) {
                          _mapCanvasKey.currentState?.clearSelection(
                            clearStickyNote: false,
                          );
                        }
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
                    selectedStickyNote: _selectedStickyNote,
                    onElementDeleted: _deleteElement,
                    selectedElementId: _selectedElementId,
                    getCurrentDrawingTargetLayer: () => _getCurrentDrawingTargetLayer(),
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
                  ), // 修改禁用蒙板逻辑
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
                                Icons.layers_clear_outlined,
                                size: 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  '暂无可用图层\n请先创建或显示图层',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
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
                onLayersInGroupReordered: _reorderLayersInGroup,
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
                onInputFieldFocusChanged: _setInputFieldFocused,
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
                availableLegends: [], // 不再需要预载图例列表
                isPreviewMode: widget.isPreviewMode,
                onLegendGroupUpdated: _updateLegendGroup,
                onLegendGroupDeleted: _deleteLegendGroup,
                onLegendGroupAdded: _addLegendGroup,
                onLegendGroupTapped: _showLegendGroupManagementDrawer,
                onLayerBinding: _showLayerBindingDrawer,
              ),
      ),
    );

    // 便签面板
    panels.add(
      _buildCollapsiblePanel(
        title: '便签',
        icon: Icons.sticky_note_2,
        isCollapsed: _isStickyNotePanelCollapsed,
        onToggleCollapsed: () => _handlePanelToggle('stickyNote'),
        autoCloseEnabled: _isStickyNotePanelAutoClose,
        onAutoCloseToggled: (value) =>
            _handleAutoCloseToggle('stickyNote', value),
        compactMode: layout.compactMode,
        showTooltips: layout.showTooltips,
        animationDuration: layout.animationDuration,
        enableAnimations: layout.enableAnimations,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: _addNewStickyNote,
            tooltip: layout.showTooltips ? '添加便签' : null,
          ),
        ],
        child: _isStickyNotePanelCollapsed
            ? null
            : StickyNotePanel(
                stickyNotes: _currentMap?.stickyNotes ?? [],
                selectedStickyNote: _selectedStickyNote,
                isPreviewMode: widget.isPreviewMode,
                onStickyNoteUpdated: _updateStickyNote,
                onStickyNoteDeleted: _deleteStickyNote,
                onStickyNoteAdded: _addNewStickyNote,
                onStickyNotesReordered: _reorderStickyNotes,
                onOpacityPreview: _handleStickyNoteOpacityPreview,
                onStickyNoteSelected: _selectStickyNote,
                onZIndexInspectorRequested: _showZIndexInspector,
                onInputFieldFocusChanged: _setInputFieldFocused,
              ),
      ),
    ); // 脚本管理面板
    panels.add(
      _buildCollapsiblePanel(
        title: '脚本管理',
        icon: Icons.code,
        isCollapsed: _isScriptPanelCollapsed,
        onToggleCollapsed: () => _handlePanelToggle('script'),
        autoCloseEnabled: _isScriptPanelAutoClose,
        onAutoCloseToggled: (value) => _handleAutoCloseToggle('script', value),
        compactMode: layout.compactMode,
        showTooltips: layout.showTooltips,
        animationDuration: layout.animationDuration,
        enableAnimations: layout.enableAnimations,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: _showNewScriptDialog,
            tooltip: layout.showTooltips ? '新建脚本' : null,
          ),
        ],
        child: _isScriptPanelCollapsed
            ? null
            : ReactiveScriptPanel(
                scriptManager: newReactiveScriptManager,
                onNewScript: _showNewScriptDialog,
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
    }
    return Expanded(
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
                  ],
                ),
              ),
            ), // 内容
            if (child != null) Expanded(child: child),
          ],
        ),
      ),
    );
  }

  /// 主布局（传统侧边栏）
  Widget _buildMainLayout(UserPreferencesProvider userPrefsProvider) {
    final layout = userPrefsProvider.layout;
    final sidebarWidth = layout.sidebarWidth;

    return Row(
      children: [
        // 侧边栏区域
        if (!_isSidebarCollapsed)
          AnimatedContainer(
            duration: Duration(
              milliseconds: layout.enableAnimations
                  ? layout.animationDuration
                  : 0,
            ),
            curve: Curves.easeInOut,
            width: sidebarWidth,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(children: _buildToolPanels(userPrefsProvider)),
              ),
            ),
          ),

        // 主要内容区域
        Expanded(child: _buildMapCanvasArea()),
      ],
    );
  }

  Widget _buildMapCanvasArea() {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefsProvider, child) {
        return Listener(
          onPointerDown: (event) {
            final userPrefs = context.read<UserPreferencesProvider>();
            if (event.buttons == userPrefs.mapEditor.radialMenuButton) {
              setState(() {
                _isMenuButtonDown = true;
              });
            }
          },
          onPointerUp: (event) {
            setState(() {
              _isMenuButtonDown = false;
            });
          },
          child: Stack(
            children: [
              // 主画布区域 - 包装在轮盘菜单中
              MapEditorRadialMenu(
                currentMap: _currentMap!,
                selectedDrawingTool: _selectedDrawingTool,
                selectedLayer: _selectedLayer,
                selectedLayerGroup: _selectedLayerGroup,
                selectedStickyNote: _selectedStickyNote,
                onDrawingToolSelected: (tool) {
                  setState(() {
                    _selectedDrawingTool = tool;
                    _previewDrawingTool = null; // 清除预览状态，确保与工具栏行为一致
                  });
                  // 选择绘制工具时清除当前选择
                  if (tool != null) {
                    _mapCanvasKey.currentState?.clearSelection();
                  }
                },
                onLayerSelected: (layer) {
                  setState(() {
                    _selectedLayer = layer;
                  });
                },
                onLayerGroupSelected: (layerGroup) {
                  if (layerGroup != null) {
                    _onLayerGroupSelected(layerGroup);
                  } else {
                    setState(() {
                      _selectedLayerGroup = null;
                    });
                    _restoreNormalLayerOrder();
                  }
                },
                onStickyNoteSelected: (note) {
                  setState(() {
                    _selectedStickyNote = note;
                  });
                },
                onColorSelected: (color) {
                  setState(() {
                    _selectedColor = color;
                    _handleColorPreview(color);
                  });
                  // 更新最近使用的颜色
                  final userPrefs = context.read<UserPreferencesProvider>();
                  userPrefs.addRecentColor(color.value).catchError((e) {
                    debugPrint('更新最近使用颜色失败: $e');
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: _buildMapCanvas(),
                ),
              ),

              // 绘制工具竖直dock栏 - 不包装在轮盘菜单中
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: DrawingToolsDockBar(
                  selectedTool: _selectedDrawingTool,
                  isVisible: !widget.isPreviewMode,
                  onToolSelected: (tool) {
                    if (!_shouldDisableDrawingTools) {
                      setState(() => _selectedDrawingTool = tool);
                      // 选择绘制工具时清除当前选择
                      if (tool != null) {
                        _mapCanvasKey.currentState?.clearSelection();
                      }
                    }
                  },
                  onToolPreview: _handleDrawingToolPreview,
                  onColorPreview: _handleColorPreview,
                  isEditMode: !widget.isPreviewMode,
                  shouldDisableDrawingTools: _shouldDisableDrawingTools,
                  onToggleSidebar: () {
                    _keyboardShortcutActions?.toggleSidebar();
                  },
                  selectedColor: _selectedColor,
                  selectedStrokeWidth: _selectedStrokeWidth,
                  selectedDensity: _selectedDensity,
                  selectedCurvature: _selectedCurvature,
                  selectedTriangleCut: _selectedTriangleCut,
                  onColorChanged: (color) {
                    setState(() {
                      _selectedColor = color;
                    });
                    // 更新最近使用的颜色
                    final userPrefs = context.read<UserPreferencesProvider>();
                    userPrefs.addRecentColor(color.toARGB32()).catchError((e) {
                      debugPrint('更新最近使用颜色失败: $e');
                    });
                  },
                  onStrokeWidthChanged: (width) {
                    setState(() {
                      _selectedStrokeWidth = width;
                    });
                  },
                  onDensityChanged: (density) {
                    setState(() {
                      _selectedDensity = density;
                    });
                  },
                  onCurvatureChanged: (curvature) {
                    setState(() {
                      _selectedCurvature = curvature;
                    });
                  },
                  onTriangleCutChanged: (triangleCut) {
                    setState(() {
                      _selectedTriangleCut = triangleCut;
                    });
                  },
                  // 图片缓冲区相关参数
                  imageBufferData: _imageBufferData,
                  imageBufferFit: _imageBufferFit,
                  onImageBufferUpdated: (imageData) {
                    setState(() {
                      _imageBufferData = imageData;
                    });
                  },
                  onImageBufferFitChanged: (fit) {
                    setState(() {
                      _imageBufferFit = fit;
                    });
                  },
                  onImageBufferCleared: () {
                    setState(() {
                      _imageBufferData = null;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建地图画布组件
  Widget _buildMapCanvas() {
    if (_currentMap == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefsProvider, child) {
        // 添加调试信息
        debugPrint('=== 构建地图画布 ===');
        debugPrint('当前地图: ${_currentMap?.title}');
        debugPrint('图例组数量: ${_currentMap?.legendGroups.length ?? 0}');
        if (_currentMap?.legendGroups != null) {
          for (int i = 0; i < _currentMap!.legendGroups.length; i++) {
            final group = _currentMap!.legendGroups[i];
            debugPrint(
              '图例组 $i: ${group.name}, 可见: ${group.isVisible}, 图例项: ${group.legendItems.length}',
            );
          }
        }
        debugPrint('版本适配器存在: ${versionAdapter != null}');
        debugPrint(
          '图例会话管理器存在: ${versionAdapter?.legendSessionManager != null}',
        );

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
          availableLegends: [], // 不再需要预载图例列表
          legendSessionManager:
              versionAdapter?.legendSessionManager, // 传递图例会话管理器
          isPreviewMode: widget.isPreviewMode,
          onLayerUpdated: _updateLayer,
          addDrawingElement: (layerId, element) {
            addDrawingElementReactive(layerId, element);
          },
          getSelectedLayerId: () => _getCurrentDrawingTargetLayer()?.id,
          getLayerMaxZIndex: _getLayerMaxZIndex,
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
          // 添加便签相关参数
          selectedStickyNote: _selectedStickyNote,
          previewStickyNoteOpacityValues: _previewStickyNoteOpacityValues,
          onStickyNoteUpdated: _updateStickyNote,
          onStickyNoteSelected: _selectStickyNote,
          onStickyNotesReordered: _reorderStickyNotesByDrag,
          onStickyNoteOpacityChanged: (noteId, opacity) {
            setState(() {
              _previewStickyNoteOpacityValues[noteId] = opacity;
            });
          },
          scriptManager: newReactiveScriptManager,
          onLegendDragToCanvas: _handleLegendDragToCanvas, // 新增：拖拽图例到画布的回调
          isMenuButtonDown: _isMenuButtonDown, // 传递中键状态
          isCrosshairEnabled: _isCrosshairEnabled, // 传递十字线状态
        );
      },
    );
  }

  /// 处理键盘事件
  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    // 获取用户偏好设置
    final userPrefs = context.read<UserPreferencesProvider>();
    final mapEditorPrefs = userPrefs.mapEditor;

    // 使用新的快捷键管理器处理键盘事件
    return KeyboardShortcutsManager.handleKeyEvent(
      node,
      event,
      context,
      mapEditorPrefs,
      _isInputFieldFocused,
      this, // 传递当前实例作为回调接口
    );
  }

  /// 获取指定图层的最大z值
  int _getLayerMaxZIndex(String layerId) {
    final mapData = reactiveIntegration.mapDataBloc.state;
    if (mapData is! MapDataLoaded) return 0;

    final layer = mapData.layers.firstWhere(
      (l) => l.id == layerId,
      orElse: () => throw StateError('Layer not found'),
    );

    if (layer.elements.isEmpty) return 0;

    return layer.elements.map((e) => e.zIndex).reduce((a, b) => a > b ? a : b);
  }

  /// 获取当前选中图层或图层组绑定的图例组列表
  List<LegendGroup> _getBoundLegendGroups() {
    if (_currentMap == null) return [];

    final allBoundGroupIds = <String>{};

    // 收集选中图层绑定的图例组ID
    if (_selectedLayer != null) {
      allBoundGroupIds.addAll(_selectedLayer!.legendGroupIds);
    }

    // 收集选中图层组中所有图层绑定的图例组ID
    if (_selectedLayerGroup != null && _selectedLayerGroup!.isNotEmpty) {
      for (final layer in _selectedLayerGroup!) {
        allBoundGroupIds.addAll(layer.legendGroupIds);
      }
    }

    // 返回对应的图例组列表
    return _currentMap!.legendGroups
        .where((group) => allBoundGroupIds.contains(group.id))
        .toList();
  }

  /// 自动切换到绑定的第一个图例组（如果图例组抽屉已打开）
  void _autoSwitchToFirstBoundLegendGroup() {
    // 只有在图例组管理抽屉打开时才执行自动切换
    if (!_isLegendGroupManagementDrawerOpen) return;

    // 获取当前选中图层或图层组绑定的图例组
    final boundLegendGroups = _getBoundLegendGroups();

    // 如果有绑定的图例组，切换到第一个
    if (boundLegendGroups.isNotEmpty) {
      final firstBoundGroup = boundLegendGroups.first;
      debugPrint('自动切换图例组抽屉到绑定的图例组: ${firstBoundGroup.name}');

      // 切换到第一个绑定的图例组
      _showLegendGroupManagementDrawer(firstBoundGroup);
    } else {
      debugPrint('当前选中的图层或图层组没有绑定任何图例组');
    }
  }

  /// 恢复版本会话状态（已废弃，使用响应式系统）
  // void _restoreVersionSession(String versionId) {
  //   // 已迁移到响应式版本管理系统
  // }

  // 便签管理方法  /// 添加新便利贴（使用响应式系统）
  void _addNewStickyNote() {
    if (_currentMap == null) return;

    final newNote = StickyNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '新便签 ${_currentMap!.stickyNotes.length + 1}',
      position: const Offset(0.1, 0.1), // 相对位置 (10%, 10%)
      size: const Size(0.2, 0.15), // 相对大小 (20%宽, 15%高)
      opacity: 1.0,
      backgroundColor: Colors.yellow.shade100,
      textColor: Colors.black,
      isCollapsed: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 使用响应式系统添加便利贴
    addStickyNoteReactive(newNote);

    // 设置当前选中的便利贴（响应式系统状态更新后会自动同步）
    _selectedStickyNote = newNote;
  }

  /// 更新便利贴（使用响应式系统）
  void _updateStickyNote(StickyNote updatedNote) {
    if (_currentMap == null) return;

    final updatedNoteWithTimestamp = updatedNote.copyWith(
      updatedAt: DateTime.now(),
    );

    // 使用响应式系统更新便利贴
    updateStickyNoteReactive(updatedNoteWithTimestamp);

    // 如果当前选中的是这个便签，更新选中状态（响应式系统会自动同步）
    if (_selectedStickyNote?.id == updatedNote.id) {
      _selectedStickyNote = updatedNoteWithTimestamp;
    }
  }

  /// 删除便利贴（使用响应式系统）
  void _deleteStickyNote(StickyNote note) {
    if (_currentMap == null) return;

    // 使用响应式系统删除便利贴
    deleteStickyNoteReactive(note.id);

    // 如果删除的是当前选中的便签，清除选中状态
    if (_selectedStickyNote?.id == note.id) {
      _selectedStickyNote = null;
    }
  }

  /// 重新排序便利贴（使用响应式系统）
  void _reorderStickyNotes(int oldIndex, int newIndex) {
    if (_currentMap == null ||
        oldIndex < 0 ||
        oldIndex >= _currentMap!.stickyNotes.length ||
        newIndex < 0 ||
        newIndex >= _currentMap!.stickyNotes.length ||
        oldIndex == newIndex) {
      return;
    }

    // 使用响应式系统重新排序便利贴
    reorderStickyNotesReactive(oldIndex, newIndex);
  }

  /// 处理拖拽便签重排序（通过z-index调整）（使用响应式系统）
  void _reorderStickyNotesByDrag(List<StickyNote> reorderedNotes) {
    if (_currentMap == null) return;

    // 使用响应式系统处理拖拽重排序
    reorderStickyNotesByDragReactive(reorderedNotes);

    // 如果当前选中的便签在重排序后发生了变化，更新选中状态
    if (_selectedStickyNote != null) {
      _selectedStickyNote = reorderedNotes.firstWhere(
        (note) => note.id == _selectedStickyNote!.id,
        orElse: () => _selectedStickyNote!,
      );
    }
  }

  /// 防抖自动保存

  /// 处理便签透明度预览
  void _handleStickyNoteOpacityPreview(String noteId, double opacity) {
    // 只更新预览状态，不触发完整重绘
    _previewStickyNoteOpacityValues[noteId] = opacity;

    // 使用优化的setState，只更新必要的部分
    if (mounted) {
      setState(() {
        // 只更新透明度预览值
      });
    }
  }

  // 选中便签
  //TODO: 考虑使用响应式系统
  void _selectStickyNote(StickyNote? note) {
    setState(() {
      _selectedStickyNote = note;
    });
  } // 脚本管理方法

  void _showNewScriptDialog() {
    _showReactiveScriptDialog();
  }

  /// 显示响应式脚本创建对话框
  void _showReactiveScriptDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          _ReactiveScriptCreateDialog(scriptManager: newReactiveScriptManager),
    );
  }

  /// 将图层分组为链接组
  List<List<MapLayer>> _groupLinkedLayers() {
    if (_currentMap == null) return [];

    final groups = <List<MapLayer>>[];
    List<MapLayer> currentGroup = [];

    for (int i = 0; i < _currentMap!.layers.length; i++) {
      final layer = _currentMap!.layers[i];
      currentGroup.add(layer);

      // 如果当前图层不链接到下一个，或者是最后一个图层，结束当前组
      if (!layer.isLinkedToNext || i == _currentMap!.layers.length - 1) {
        groups.add(List.from(currentGroup));
        currentGroup.clear();
      }
    }

    return groups;
  }
}

/// 响应式脚本创建对话框
class _ReactiveScriptCreateDialog extends StatefulWidget {
  final NewReactiveScriptManager scriptManager;

  const _ReactiveScriptCreateDialog({required this.scriptManager});

  @override
  State<_ReactiveScriptCreateDialog> createState() =>
      _ReactiveScriptCreateDialogState();
}

class _ReactiveScriptCreateDialogState
    extends State<_ReactiveScriptCreateDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  ScriptType _selectedType = ScriptType.automation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.stream,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text('新建响应式脚本'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '响应式脚本会自动响应地图数据变化，确保实时数据一致性',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '脚本名称',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ScriptType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: '脚本类型',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: ScriptType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        _getTypeIcon(type),
                        size: 16,
                        color: _getTypeColor(type),
                      ),
                      const SizedBox(width: 8),
                      Text(_getTypeDisplayName(type)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton.icon(
          onPressed: _saveScript,
          icon: const Icon(Icons.save, size: 16),
          label: const Text('创建脚本'),
        ),
      ],
    );
  }

  void _saveScript() async {
    if (_nameController.text.trim().isEmpty) {
      context.showErrorSnackBar('请输入脚本名称');
      return;
    }

    final now = DateTime.now();
    final content = await _getDefaultScriptContent(_selectedType);
    final script = ScriptData(
      id: now.millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      content: content,
      parameters: {},
      isEnabled: true,
      createdAt: now,
      updatedAt: now,
    );

    widget.scriptManager.addScript(script);
    Navigator.of(context).pop();

    // 显示成功
    context.showSuccessSnackBar('响应式脚本 "${script.name}" 创建成功');
  }

  IconData _getTypeIcon(ScriptType type) {
    switch (type) {
      case ScriptType.automation:
        return Icons.auto_mode;
      case ScriptType.animation:
        return Icons.animation;
      case ScriptType.filter:
        return Icons.filter_list;
      case ScriptType.statistics:
        return Icons.analytics;
    }
  }

  Color _getTypeColor(ScriptType type) {
    switch (type) {
      case ScriptType.automation:
        return Colors.blue;
      case ScriptType.animation:
        return Colors.green;
      case ScriptType.filter:
        return Colors.orange;
      case ScriptType.statistics:
        return Colors.purple;
    }
  }

  Future<String> _getDefaultScriptContent(ScriptType type) async {
    return await ScriptTemplateService.getTemplateContent(type);
  }

  String _getTypeDisplayName(ScriptType type) {
    switch (type) {
      case ScriptType.automation:
        return '自动化';
      case ScriptType.animation:
        return '动画';
      case ScriptType.filter:
        return '过滤';
      case ScriptType.statistics:
        return '统计';
    }
  }
}
