import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';
import '../../../utils/image_utils.dart';
import '../../../components/background_image_settings_dialog.dart';
import '../../../components/color_filter_dialog.dart';
import '../../../components/common/tags_manager.dart';
import 'dart:async';

class LayerPanel extends StatefulWidget {
  final List<MapLayer> layers;
  final MapLayer? selectedLayer;
  final List<MapLayer>? selectedLayerGroup; //：选中的图层组
  final bool isPreviewMode;
  final Function(MapLayer) onLayerSelected;
  final Function(List<MapLayer>) onLayerGroupSelected; //：图层组选择回调
  final Function() onSelectionCleared; //：清除选择回调
  final Function(MapLayer) onLayerUpdated;
  final Function(MapLayer) onLayerDeleted;
  final VoidCallback onLayerAdded;
  final Function(int oldIndex, int newIndex) onLayersReordered;
  final Function(int oldIndex, int newIndex, List<MapLayer> layersToUpdate)?
  onLayersInGroupReordered;
  final Function(String)? onError;
  final Function(String)? onSuccess;
  //：实时透明度预览回调
  final Function(String layerId, double opacity)?
  onOpacityPreview; //：图例组相关数据和回调
  final List<LegendGroup>? allLegendGroups; // 改为可空类型
  final Function(MapLayer, List<LegendGroup>)?
  onShowLayerLegendBinding; // 显示图层图例绑定抽屉
  final Function(List<MapLayer>)? onLayersBatchUpdated;
  //：折叠状态相关参数
  final Map<String, bool>? groupCollapsedStates; // 传入的折叠状态
  final Function(Map<String, bool>)? onGroupCollapsedStatesChanged; // 折叠状态变化回调
  final Function()? onLayerSelectionCleared; //：只清除图层选择
  final Function(bool)? onInputFieldFocusChanged; // 新增：输入框焦点状态回调

  const LayerPanel({
    super.key,
    required this.layers,
    this.selectedLayer,
    this.selectedLayerGroup, //
    required this.isPreviewMode,
    required this.onLayerSelected,
    required this.onLayerGroupSelected, //
    required this.onSelectionCleared, //
    required this.onLayerUpdated,
    required this.onLayerDeleted,
    required this.onLayerAdded,
    required this.onLayersReordered,
    this.onLayersInGroupReordered,
    this.onError,
    this.onSuccess,
    this.onOpacityPreview,
    this.allLegendGroups, // 改为可选参数
    this.onShowLayerLegendBinding,
    this.onLayersBatchUpdated,
    this.groupCollapsedStates, //
    this.onGroupCollapsedStatesChanged, //
    this.onLayerSelectionCleared, //
    this.onInputFieldFocusChanged, // 新增：输入框焦点状态回调
  });

  @override
  State<LayerPanel> createState() => _LayerPanelState();
}

class _LayerPanelState extends State<LayerPanel> {
  // 用于存储临时的透明度值，避免频繁更新数据
  final Map<String, double> _tempOpacityValues = {};
  final Map<String, Timer?> _opacityTimers = {};

  // 修改：使用本地状态，但从父组件同步
  late Map<String, bool> _groupCollapsedStates;

  // 添加标志位避免在构建期间调用setState
  bool _isInitialized = false;

  @override
  void dispose() {
    // 清理所有定时器
    for (final timer in _opacityTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // 从父组件获取折叠状态，如果没有则初始化
    _groupCollapsedStates = Map<String, bool>.from(
      widget.groupCollapsedStates ?? {},
    );

    // 使用 addPostFrameCallback 延迟初始化，避免在构建期间调用 setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeGroupCollapsedStates();
        _isInitialized = true;
      }
    });
  }

  @override
  void didUpdateWidget(LayerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 同步父组件传入的折叠状态
    if (widget.groupCollapsedStates != null &&
        widget.groupCollapsedStates != oldWidget.groupCollapsedStates) {
      _groupCollapsedStates = Map<String, bool>.from(
        widget.groupCollapsedStates!,
      );
    }

    // 当图层发生变化时，更新折叠状态映射
    if (oldWidget.layers != widget.layers && _isInitialized) {
      // 使用 addPostFrameCallback 避免在构建期间调用 setState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateGroupCollapsedStates();
        }
      });
    }
  }

  /// 初始化图层组的折叠状态，只为新组设置默认值
  void _initializeGroupCollapsedStates() {
    if (!mounted) return;

    final groups = _groupLinkedLayers();
    bool hasNewGroups = false;

    for (int i = 0; i < groups.length; i++) {
      final group = groups[i];
      if (group.isNotEmpty && group.length > 1) {
        final groupId = 'group_${group.first.id}';
        // 只为没有状态的新组设置默认折叠状态
        if (!_groupCollapsedStates.containsKey(groupId)) {
          _groupCollapsedStates[groupId] = true; // 默认折叠
          hasNewGroups = true;
        }
      }
    }

    // 如果有新组被添加，通知父组件
    if (hasNewGroups) {
      _notifyGroupCollapsedStatesChanged();
    }
  }

  /// 更新图层组的折叠状态映射
  void _updateGroupCollapsedStates() {
    if (!mounted) return;

    final groups = _groupLinkedLayers();
    final newCollapsedStates = <String, bool>{};

    for (int i = 0; i < groups.length; i++) {
      final group = groups[i];
      if (group.isNotEmpty && group.length > 1) {
        final groupId = 'group_${group.first.id}';
        // 保持已有的折叠状态，新组默认折叠
        newCollapsedStates[groupId] = _groupCollapsedStates[groupId] ?? true;
      }
    }

    // 检查是否有变化
    final hasChanges = !_mapsEqual(_groupCollapsedStates, newCollapsedStates);

    // 更新状态映射，移除不存在的组
    _groupCollapsedStates.clear();
    _groupCollapsedStates.addAll(newCollapsedStates);

    // 如果有变化，通知父组件
    if (hasChanges) {
      _notifyGroupCollapsedStatesChanged();
    }
  }

  /// 比较两个Map是否相等
  bool _mapsEqual(Map<String, bool> map1, Map<String, bool> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }

  /// 通知父组件折叠状态发生变化
  void _notifyGroupCollapsedStatesChanged() {
    if (!mounted) return;
    widget.onGroupCollapsedStatesChanged?.call(
      Map<String, bool>.from(_groupCollapsedStates),
    );
  }

  /// 将图层分组为链接组
  List<List<MapLayer>> _groupLinkedLayers() {
    final groups = <List<MapLayer>>[];
    List<MapLayer> currentGroup = [];

    for (int i = 0; i < widget.layers.length; i++) {
      final layer = widget.layers[i];
      currentGroup.add(layer);

      // 安全访问 isLinkedToNext 属性
      final isLinked = layer.isLinkedToNext;

      // 如果当前图层不链接到下一个，或者是最后一个图层，结束当前组
      if (!isLinked || i == widget.layers.length - 1) {
        groups.add(List.from(currentGroup));
        currentGroup.clear();
      }
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return widget.layers.isEmpty
        ? Center(
            child: Text(
              '暂无图层',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          )
        : _buildGroupedLayerList();
  }

  /// 构建分组的图层列表
  Widget _buildGroupedLayerList() {
    final groups = _groupLinkedLayers();

    if (groups.isEmpty) {
      return Center(
        child: Text(
          '暂无图层',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: groups.length,
      onReorder: (oldIndex, newIndex) {
        debugPrint('组重排序触发：oldIndex=$oldIndex, newIndex=$newIndex');
        _handleGroupReorder(oldIndex, newIndex);
      },
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, groupIndex) {
        if (groupIndex >= groups.length) {
          return Container(key: ValueKey('empty_$groupIndex'));
        }
        final group = groups[groupIndex];
        if (group.isEmpty) {
          return Container(key: ValueKey('empty_group_$groupIndex'));
        }
        return _buildLayerGroup(context, group, groupIndex);
      },
    );
  }

  /// 构建图层组卡片
  Widget _buildLayerGroup(
    BuildContext context,
    List<MapLayer> group,
    int groupIndex,
  ) {
    final isMultiLayer = group.length > 1;
    final isGroupSelected = _isGroupSelected(group);

    // 为组生成唯一ID用于折叠状态管理
    final groupId = 'group_${group.first.id}';
    // 获取折叠状态，多图层组默认折叠，单图层组默认展开
    final isCollapsed = isMultiLayer
        ? (_groupCollapsedStates[groupId] ?? true)
        : false;

    return Container(
      key: ValueKey(groupId),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isGroupSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: isGroupSelected ? 2 : 1,
        ),
        color: isGroupSelected
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withAlpha((0.1 * 255).toInt())
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 多图层组的拖动手柄和折叠头部
          if (isMultiLayer)
            _buildGroupHeader(
              groupIndex,
              group,
              isCollapsed,
              groupId,
              isGroupSelected,
            ),

          // 图层列表（可折叠）
          if (isMultiLayer)
            _buildCollapsibleLayerList(group, isCollapsed)
          else
            // 单独图层也显示拖动手柄
            _buildSingleLayerTile(context, group.first, groupIndex),
        ],
      ),
    );
  }

  /// 检查图层组是否被选中
  bool _isGroupSelected(List<MapLayer> group) {
    if (widget.selectedLayerGroup == null ||
        widget.selectedLayerGroup!.isEmpty) {
      return false;
    }

    // 检查组的大小和所有图层ID是否匹配
    if (group.length != widget.selectedLayerGroup!.length) {
      return false;
    }

    final groupIds = group.map((l) => l.id).toSet();
    final selectedIds = widget.selectedLayerGroup!.map((l) => l.id).toSet();

    return groupIds.difference(selectedIds).isEmpty &&
        selectedIds.difference(groupIds).isEmpty;
  }

  /// 构建组头部（包含拖动手柄、折叠按钮和组信息）
  Widget _buildGroupHeader(
    int groupIndex,
    List<MapLayer> group,
    bool isCollapsed,
    String groupId,
    bool isGroupSelected, //参数
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isGroupSelected
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withAlpha((0.2 * 255).toInt())
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // 拖动手柄区域
          ReorderableDragStartListener(
            index: groupIndex,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Icon(
                Icons.drag_handle,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          // 可点击的组信息区域（用于选择图层组）
          Expanded(
            child: InkWell(
              onTap: () => _handleGroupSelection(group),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    // 折叠/展开图标
                    GestureDetector(
                      onTap: () => _toggleGroupCollapse(groupId),
                      child: Icon(
                        isCollapsed
                            ? Icons.keyboard_arrow_right
                            : Icons.keyboard_arrow_down,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 组信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 修改显示文本以反映新的选择逻辑
                          Text(
                            _buildGroupSelectionText(group, isGroupSelected),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isGroupSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isGroupSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            group.map((l) => l.name).join(', '),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 组可见性切换按钮 - 折叠和展开时都显示
          IconButton(
            icon: Icon(
              _isGroupVisible(group) ? Icons.visibility : Icons.visibility_off,
              size: 16,
              color: _isGroupVisible(group)
                  ? null
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () => _toggleGroupVisibility(group),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            tooltip: '',
          ),
        ],
      ),
    );
  }

  /// 构建组选择状态的文本
  String _buildGroupSelectionText(List<MapLayer> group, bool isGroupSelected) {
    final baseText = '图层组 (${group.length} 个图层)';

    if (isGroupSelected) {
      // 检查是否还有单图层选择
      final hasLayerSelected = widget.selectedLayer != null;
      if (hasLayerSelected) {
        return '$baseText - 已选中 (同时选择)';
      } else {
        return '$baseText - 已选中';
      }
    } else {
      return baseText;
    }
  }

  /// 处理图层组选择
  void _handleGroupSelection(List<MapLayer> group) {
    debugPrint('选择图层组: ${group.map((l) => l.name).toList()}');

    // 修改：检查是否已经选中，支持同时选择
    if (_isGroupSelected(group)) {
      // 如果当前组已经被选中，则取消组选择（但保留单图层选择）
      widget.onLayerGroupSelected([]); // 传递空列表表示取消组选择
      widget.onSuccess?.call('已取消图层组选择');
    } else {
      // 选择新的图层组（不影响单图层选择）
      widget.onLayerGroupSelected(group);

      // 根据是否有单图层选择给出不同的提示
      final hasLayerSelected = widget.selectedLayer != null;
      if (hasLayerSelected) {
        widget.onSuccess?.call('已选中图层组 (${group.length} 个图层)，可同时操作图层和图层组');
      } else {
        widget.onSuccess?.call('已选中图层组 (${group.length} 个图层)');
      }
    }
  }

  /// 构建可折叠的图层列表
  Widget _buildCollapsibleLayerList(List<MapLayer> group, bool isCollapsed) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 200),
      crossFadeState: isCollapsed
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: _buildInGroupReorderableList(group),
      secondChild: Container(
        height: 0,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
      ),
    );
  }

  /// 切换组的折叠状态
  void _toggleGroupCollapse(String groupId) {
    if (!mounted) return;

    setState(() {
      _groupCollapsedStates[groupId] =
          !(_groupCollapsedStates[groupId] ?? true);
    });

    // 通知父组件状态变化
    _notifyGroupCollapsedStatesChanged();
  }

  /// 检查组是否可见（组内所有图层都可见才认为组可见）
  bool _isGroupVisible(List<MapLayer> group) {
    return group.every((layer) => layer.isVisible);
  }

  /// 切换组的可见性
  void _toggleGroupVisibility(List<MapLayer> group) {
    final isGroupCurrentlyVisible = _isGroupVisible(group);
    final newVisibility = !isGroupCurrentlyVisible;

    final updatedLayers = group.map((layer) {
      return layer.copyWith(
        isVisible: newVisibility,
        updatedAt: DateTime.now(),
      );
    }).toList();

    // 使用批量更新
    if (widget.onLayersBatchUpdated != null) {
      // 创建完整的图层列表副本
      final allLayers = List<MapLayer>.from(widget.layers);

      // 更新对应的图层
      for (final updatedLayer in updatedLayers) {
        final index = allLayers.indexWhere((l) => l.id == updatedLayer.id);
        if (index != -1) {
          allLayers[index] = updatedLayer;
        }
      }

      widget.onLayersBatchUpdated!(allLayers);
    } else {
      // 逐个更新
      for (final updatedLayer in updatedLayers) {
        widget.onLayerUpdated(updatedLayer);
      }
    }

    widget.onSuccess?.call(newVisibility ? '已显示组内所有图层' : '已隐藏组内所有图层');
  }

  /// 构建单独图层瓦片（带拖动手柄）
  Widget _buildSingleLayerTile(
    BuildContext context,
    MapLayer layer,
    int groupIndex,
  ) {
    return ReorderableDragStartListener(
      index: groupIndex,
      child: _buildLayerTile(context, layer, [layer], 0, false),
    );
  }

  /// 构建组内可重排序列表
  Widget _buildInGroupReorderableList(List<MapLayer> group) {
    if (group.isEmpty) {
      return const SizedBox.shrink();
    }

    // 为了防止重建时的key冲突，使用组的第一个图层ID作为前缀
    final groupKey = 'group_${group.first.id}';

    return Container(
      child: ReorderableListView.builder(
        key: ValueKey('${groupKey}_reorderable'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: group.length,
        onReorder: (oldIndex, newIndex) {
          debugPrint('组内重排序触发：oldIndex=$oldIndex, newIndex=$newIndex');
          _handleInGroupReorder(group, oldIndex, newIndex);
        },
        buildDefaultDragHandles: false,
        itemBuilder: (context, index) {
          if (index >= group.length) {
            return Container(key: ValueKey('${groupKey}_empty_$index'));
          }

          final layer = group[index];
          final isLastInGroup = index == group.length - 1;

          return Container(
            key: ValueKey('${groupKey}_layer_${layer.id}'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: _buildLayerTile(context, layer, group, index, true),
                ),
                if (!isLastInGroup)
                  Divider(
                    height: 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建图层瓦片的修改版本，禁用所有 tooltip
  Widget _buildLayerTile(
    BuildContext context,
    MapLayer layer,
    List<MapLayer> group,
    int layerIndexInGroup,
    bool isMultiLayer,
  ) {
    final isSelected = widget.selectedLayer?.id == layer.id;
    final isGroupSelected = _isGroupSelected(group); // 检查所属组是否被选中
    final globalLayerIndex = widget.layers.indexOf(layer);
    final isLastLayer = globalLayerIndex == widget.layers.length - 1;

    // 修改背景色逻辑以支持同时选择
    Color? backgroundColor;
    if (isSelected && isGroupSelected) {
      // 图层和所属组都被选中时，使用最高优先级的背景色
      backgroundColor = Theme.of(
        context,
      ).colorScheme.primaryContainer.withAlpha((0.4 * 255).toInt());
    } else if (isSelected) {
      // 只有图层被选中时的背景色
      backgroundColor = Theme.of(
        context,
      ).colorScheme.primaryContainer.withAlpha((0.3 * 255).toInt());
    } else if (isGroupSelected) {
      // 只有图层组被选中时，组内图层显示组选中的背景色
      backgroundColor = Theme.of(
        context,
      ).colorScheme.primaryContainer.withAlpha((0.15 * 255).toInt());
    }

    return Container(
      // 移除固定高度，让内容自适应
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: isMultiLayer ? null : BorderRadius.circular(8),
        // 添加边框以更好地区分选择状态
        border: isSelected
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
      ),
      child: GestureDetector(
        onSecondaryTapDown: (details) {
          _showLayerContextMenu(context, layer, details.globalPosition);
        },
        child: InkWell(
          onTap: () => _handleLayerSelection(layer, group), // 修改点击处理
          borderRadius: isMultiLayer ? null : BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 让列收缩到内容大小
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一排：选择状态指示器 + 可见性按钮 + 图层名称输入框 + 链接按钮 + 操作按钮
                Row(
                  children: [
                    // 添加选择状态指示器
                    if (isSelected || isGroupSelected)
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    if (isSelected || isGroupSelected) const SizedBox(width: 8),

                    // 可见性按钮 - 禁用 tooltip
                    IconButton(
                      icon: Icon(
                        layer.isVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 18,
                        color: layer.isVisible
                            ? null
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        final updatedLayer = layer.copyWith(
                          isVisible: !layer.isVisible,
                          updatedAt: DateTime.now(),
                        );
                        widget.onLayerUpdated(updatedLayer);
                      },
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      tooltip: '', // 禁用 tooltip
                    ),
                    const SizedBox(width: 8),

                    // 图层名称输入框
                    Expanded(child: _buildLayerNameEditor(layer)),

                    // 链接按钮
                    // if (!widget.isPreviewMode)
                    _buildLinkButton(layer, isLastLayer),

                    // 操作按钮
                    // if (!widget.isPreviewMode)
                    ...[
                      // 图片管理按钮 - 使用 GestureDetector 替代 PopupMenuButton
                      GestureDetector(
                        onTap: () => _showImageMenu(context, layer),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.image, size: 16),
                        ),
                      ),

                      // 删除按钮 - 禁用 tooltip
                      if (widget.layers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 16),
                          onPressed: () => _showDeleteDialog(context, layer),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          tooltip: '', // 禁用 tooltip
                        ),
                    ],
                  ],
                ),

                // 第二排：透明度滑块
                const SizedBox(height: 8),
                _buildOpacitySlider(
                  layer,
                  group,
                  layerIndexInGroup,
                  isMultiLayer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 处理图层选择（最终修改版本）
  void _handleLayerSelection(MapLayer layer, List<MapLayer> group) {
    // 检查当前点击的图层是否已经被选中
    if (widget.selectedLayer?.id == layer.id) {
      // 如果已经选中，则只取消图层选择（保留图层组选择）
      if (widget.onLayerSelectionCleared != null) {
        widget.onLayerSelectionCleared!();
      }
    } else {
      // 如果未选中，则选择该图层（不影响图层组选择）
      widget.onLayerSelected(layer);
    }
  }

  /// 显示图片菜单
  void _showImageMenu(BuildContext context, MapLayer layer) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  layer.imageData != null ? Icons.edit : Icons.upload,
                  size: 20,
                ),
                title: Text(layer.imageData != null ? '更换图片' : '上传图片'),
                onTap: () {
                  Navigator.pop(context);
                  _handleImageUpload(layer);
                },
              ),
              // 色彩滤镜对所有图层都可用
              ListTile(
                leading: const Icon(Icons.palette, size: 20),
                title: const Text('色彩滤镜'),
                onTap: () {
                  Navigator.pop(context);
                  _showColorFilterDialog(context, layer);
                },
              ),
              if (layer.imageData != null) ...[
                ListTile(
                  leading: const Icon(Icons.settings, size: 20),
                  title: const Text('背景图片设置'),
                  onTap: () {
                    Navigator.pop(context);
                    _showBackgroundImageSettingsForLayer(context, layer);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, size: 20),
                  title: const Text('移除图片'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeLayerImage(layer);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 使用新的 BackgroundImageSettingsDialog 显示图片大小和偏移量编辑对话框
  Future<void> _showBackgroundImageSettingsForLayer(
    BuildContext context,
    MapLayer layer,
  ) async {
    // 确保 context 可用，因为 showDialog 需要它
    // 如果这个方法在 State 类中，可以直接使用 this.context 或 widget.context (取决于具体场景，通常是 this.context)

    final BackgroundImageSettings? result =
        await showDialog<BackgroundImageSettings>(
          context: context, // 使用 State 对象的 context
          barrierDismissible: false, // 建议设置为 false，让用户通过按钮明确关闭
          builder: (BuildContext dialogContext) {
            return BackgroundImageSettingsDialog(
              layer: layer, // 将当前图层传递给对话框
              // title: '编辑 "${layer.name}" 的背景图片', // 可选：可以动态设置标题
            );
          },
        );

    // 处理对话框返回的结果
    if (result != null) {
      // 用户点击了确认并且对话框返回了设置
      // 'result' 的类型是 BackgroundImageSettings

      final updatedLayer = layer.copyWith(
        imageFit: result.imageFit,
        xOffset: result.xOffset,
        yOffset: result.yOffset,
        imageScale: result.imageScale,
        updatedAt: DateTime.now(), // 保持更新时间的逻辑
      );

      widget.onLayerUpdated(updatedLayer); // 调用父组件的回调来更新图层
      widget.onSuccess?.call('图层 "${layer.name}" 的背景图片设置已更新'); // 调用成功回调
    } else {
      // 用户可能取消了对话框 (例如 BackgroundImageSettingsDialog 调用了 Navigator.pop(context) 而没有结果)
      debugPrint('背景图片设置对话框已关闭，没有应用更改。');
    }
  }

  /// 显示色彩滤镜设置对话框
  Future<void> _showColorFilterDialog(
    BuildContext context,
    MapLayer layer,
  ) async {
    final filterManager = ColorFilterSessionManager();
    final currentSettings =
        filterManager.getLayerFilter(layer.id) ?? const ColorFilterSettings();

    final ColorFilterSettings? result = await showDialog<ColorFilterSettings>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ColorFilterDialog(
          initialSettings: currentSettings,
          title: '"${layer.name}" 色彩滤镜设置',
          layerId: layer.id,
        );
      },
    );

    // 处理对话框返回的结果
    if (result != null) {
      // 应用滤镜设置到会话管理器
      filterManager.setLayerFilter(layer.id, result);

      final filterName = result.type == ColorFilterType.none
          ? '已移除'
          : _getFilterTypeName(result.type);
      widget.onSuccess?.call('图层 "${layer.name}" 的色彩滤镜已设置为：$filterName');
    }

    // 无论是否有返回结果，都触发界面更新以确保主题滤镜的变化能够显示
    widget.onLayerUpdated(layer.copyWith(updatedAt: DateTime.now()));
  }

  /// 获取滤镜类型名称
  String _getFilterTypeName(ColorFilterType type) {
    switch (type) {
      case ColorFilterType.none:
        return '无滤镜';
      case ColorFilterType.grayscale:
        return '灰度';
      case ColorFilterType.sepia:
        return '棕褐色';
      case ColorFilterType.invert:
        return '反色';
      case ColorFilterType.brightness:
        return '亮度';
      case ColorFilterType.contrast:
        return '对比度';
      case ColorFilterType.saturation:
        return '饱和度';
      case ColorFilterType.hue:
        return '色相';
    }
  }

  /// 显示删除确认对话框
  void _showDeleteDialog(BuildContext context, MapLayer layer) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图层'),
        content: Text('确定要删除图层 "${layer.name}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onLayerDeleted(layer);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 构建链接按钮
  Widget _buildLinkButton(MapLayer layer, bool isLastLayer) {
    final isLinked = layer.isLinkedToNext; // 安全访问

    return IconButton(
      icon: Icon(
        isLinked ? Icons.link : Icons.link_off,
        size: 16,
        color: isLastLayer
            ? Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
            : (isLinked
                  ? Colors.blue
                  : Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      onPressed: isLastLayer
          ? null
          : () {
              final updatedLayer = layer.copyWith(
                isLinkedToNext: !isLinked,
                updatedAt: DateTime.now(),
              );
              widget.onLayerUpdated(updatedLayer);
            },
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
      // 禁用 tooltip 以避免重排序时的错误
      tooltip: '', // 使用空字符串禁用 tooltip
      // 或者完全移除 tooltip 属性
    );
  }

  /// 构建优化的透明度滑块和图例组绑定
  Widget _buildOpacitySlider(
    MapLayer layer,
    List<MapLayer> group,
    int layerIndexInGroup,
    bool isMultiLayer,
  ) {
    // 获取当前显示的透明度值（临时值或实际值）
    final currentOpacity = _tempOpacityValues[layer.id] ?? layer.opacity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4), // 添加一些垂直间距
      child: Column(
        mainAxisSize: MainAxisSize.min, // 让列收缩到内容大小
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 透明度滑块
          Row(
            children: [
              const Text('不透明度:', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 3),
              Flexible(
                child: Slider(
                  value: currentOpacity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  onChanged: (opacity) => _handleOpacityChange(layer, opacity),
                  onChangeEnd: (opacity) =>
                      _handleOpacityChangeEnd(layer, opacity),
                ),
              ),
              const SizedBox(width: 3),
              Text(
                '${(currentOpacity * 100).round()}%',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ), // 图例组绑定 chip 和标签管理
          const SizedBox(height: 4),
          Row(
            children: [
              _buildLegendGroupsChip(layer),
              const SizedBox(width: 8),
              _buildTagsChip(layer),
            ],
          ),
        ],
      ),
    );
  }

  /// 检查指定位置之前的元素是否与当前元素直接或间接相连
  bool _isConnectedToPrevious(List<MapLayer> group, int targetIndex) {
    if (targetIndex <= 0) return false;

    // 从目标位置向前检查，看是否有连接链
    for (int i = targetIndex - 1; i >= 0;) {
      final layer = group[i];
      final isLinked = layer.isLinkedToNext;

      if (isLinked) {
        // 如果找到一个有链接的元素，说明目标位置与前面的元素相连
        return true;
      } else {
        // 如果遇到一个没有链接的元素，说明链断了
        break;
      }
    }

    return false;
  }

  /// 检查在组内重排序时，元素是否应该开启链接状态
  bool _shouldEnableLinkAfterMove(
    List<MapLayer> originalGroup,
    List<MapLayer> reorderedGroup,
    int newIndex,
    MapLayer movedLayer,
  ) {
    // 如果移动到组内最后一个位置，不需要链接
    if (newIndex >= reorderedGroup.length - 1) return false;

    // 检查原组是否是一个完整的连接组（除了最后一个元素）
    bool wasCompleteGroup = true;
    for (int i = 0; i < originalGroup.length - 1; i++) {
      final layer = originalGroup[i];
      final isLinked = layer.isLinkedToNext;
      if (!isLinked) {
        wasCompleteGroup = false;
        break;
      }
    }

    // 如果原来是一个完整的组，那么重排序后也应该保持完整
    if (wasCompleteGroup) {
      return true;
    }

    // 否则，检查目标位置前面是否有链接的元素
    return _isConnectedToPrevious(reorderedGroup, newIndex);
  }

  /// 处理组内重排序（修正版）
  void _handleInGroupReorder(List<MapLayer> group, int oldIndex, int newIndex) {
    debugPrint('=== 组内重排序 ===');
    debugPrint('组内oldIndex: $oldIndex, newIndex: $newIndex');
    debugPrint('组大小: ${group.length}');
    debugPrint('组内图层: ${group.map((l) => l.name).toList()}');

    if (oldIndex == newIndex) {
      debugPrint('索引相同，跳过');
      return;
    }

    if (oldIndex >= group.length || oldIndex < 0) {
      debugPrint('oldIndex 超出范围，跳过');
      return;
    }

    // 记录原始的 newIndex，用于判断是否是拖到最后
    final originalNewIndex = newIndex;

    // 重要修正：调整 newIndex 的边界
    if (newIndex > group.length) {
      newIndex = group.length;
      debugPrint('调整 newIndex 到: $newIndex');
    }
    if (newIndex < 0) {
      newIndex = 0;
      debugPrint('调整 newIndex 到: $newIndex');
    }

    // 重新检查调整后的索引
    if (oldIndex == newIndex) {
      debugPrint('调整后索引相同，跳过');
      return;
    }

    // 安全地获取图层
    final oldLayer = group.elementAtOrNull(oldIndex);
    if (oldLayer == null) {
      debugPrint('图层为空，跳过');
      return;
    }

    // 检查移动的图层是否是组内最后一个（连接状态为否）
    final isMovingLastElement = !(oldLayer.isLinkedToNext);

    debugPrint('移动的图层: ${oldLayer.name}, 是否为组内最后元素: $isMovingLastElement');
    debugPrint('调整后的 newIndex: $newIndex');

    // 计算当前图层的全局索引
    final oldGlobalIndex = widget.layers.indexOf(oldLayer);

    // 创建重排序后的组副本来进行检测
    final reorderedGroup = List<MapLayer>.from(group);
    final movedLayer = reorderedGroup.removeAt(oldIndex);

    // 修正：重新调整插入位置的计算
    int adjustedNewIndex;

    // 如果原始 newIndex 大于等于组长度，说明要移动到最后
    if (originalNewIndex >= group.length) {
      adjustedNewIndex = group.length - 1; // 移动到最后位置
      debugPrint('目标位置调整为组内最后位置: $adjustedNewIndex');
    } else {
      // 正常情况的调整
      adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
      debugPrint('正常位置调整: $adjustedNewIndex');
    }

    reorderedGroup.insert(adjustedNewIndex, movedLayer);

    // 计算重排序后目标位置的全局索引
    final groupStartIndex = widget.layers.indexOf(group.first);
    final newGlobalIndex = groupStartIndex + adjustedNewIndex;

    debugPrint('组在全局的起始位置: $groupStartIndex');
    debugPrint('目标位置在组内: $adjustedNewIndex');
    debugPrint('计算出的新全局索引: $newGlobalIndex');

    // 需要更新的图层列表
    List<MapLayer> layersToUpdate = [];

    // 检查原组是否是一个完整的连接组（除了最后一个元素）
    bool wasCompleteGroup = true;
    for (int i = 0; i < group.length - 1; i++) {
      final layer = group[i];
      final isLinked = layer.isLinkedToNext;
      if (!isLinked) {
        wasCompleteGroup = false;
        break;
      }
    }

    debugPrint('原组是否为完整连接组: $wasCompleteGroup');

    // 如果原来是一个完整的组，重排序后也应该保持完整
    if (wasCompleteGroup) {
      // 确保重排序后除了最后一个元素，其他都有链接
      for (int i = 0; i < reorderedGroup.length - 1; i++) {
        final layer = reorderedGroup[i];
        final isLinked = layer.isLinkedToNext;
        if (!isLinked) {
          final updatedLayer = layer.copyWith(
            isLinkedToNext: true,
            updatedAt: DateTime.now(),
          );
          layersToUpdate.add(updatedLayer);
          debugPrint('开启图层链接以保持组完整性: ${layer.name}');
        }
      }

      // 确保最后一个元素关闭链接
      final lastLayer = reorderedGroup.last;
      final lastIsLinked = lastLayer.isLinkedToNext;
      if (lastIsLinked) {
        final updatedLastLayer = lastLayer.copyWith(
          isLinkedToNext: false,
          updatedAt: DateTime.now(),
        );
        layersToUpdate.add(updatedLastLayer);
        debugPrint('关闭组内最后元素的链接: ${lastLayer.name}');
      }
    } else {
      // 如果不是完整组，使用原来的逻辑处理
      if (isMovingLastElement) {
        // 使用新的检测方法判断是否应该开启链接
        bool shouldEnableLink = _shouldEnableLinkAfterMove(
          group,
          reorderedGroup,
          adjustedNewIndex,
          oldLayer,
        );

        debugPrint('检测结果 - 应该开启链接: $shouldEnableLink');

        // 如果需要开启当前移动图层的链接（不是移动到组内最后一个位置）
        if (shouldEnableLink && adjustedNewIndex < group.length - 1) {
          final updatedMovedLayer = oldLayer.copyWith(
            isLinkedToNext: true,
            updatedAt: DateTime.now(),
          );
          layersToUpdate.add(updatedMovedLayer);
          debugPrint('开启移动图层的链接: ${oldLayer.name}');
        }

        // 重要：当组内最后一个元素移动到其他位置时，
        // 需要确保新的组内最后一个元素关闭链接状态
        if (group.length > 1) {
          // 找到重排序后新的组内最后一个元素
          final newLastLayer = reorderedGroup[group.length - 1];

          // 如果新的最后一个元素不是我们刚移动的元素，且它当前是链接状态
          if (newLastLayer.id != oldLayer.id) {
            final newLastIsLinked = newLastLayer.isLinkedToNext;
            if (newLastIsLinked) {
              final updatedNewLastLayer = newLastLayer.copyWith(
                isLinkedToNext: false,
                updatedAt: DateTime.now(),
              );
              layersToUpdate.add(updatedNewLastLayer);
              debugPrint('关闭新的组内最后元素的链接: ${newLastLayer.name}');
            }
          }
        }
      } else {
        // 如果移动的不是组内最后一个元素
        // 检查移动后是否有其他需要调整链接状态的情况

        // 检查是否有元素移动到了组内最后一个位置
        if (adjustedNewIndex == group.length - 1) {
          // 移动的元素变成了组内最后一个，需要关闭它的链接
          final isCurrentlyLinked = oldLayer.isLinkedToNext;
          if (isCurrentlyLinked) {
            final updatedMovedLayer = oldLayer.copyWith(
              isLinkedToNext: false,
              updatedAt: DateTime.now(),
            );
            layersToUpdate.add(updatedMovedLayer);
            debugPrint('关闭移动到最后位置的图层链接: ${oldLayer.name}');
          }
        }
      }
    }

    debugPrint(
      '全局索引: oldGlobalIndex=$oldGlobalIndex, newGlobalIndex=$newGlobalIndex',
    );

    if (oldGlobalIndex == -1 ||
        newGlobalIndex == -1 ||
        newGlobalIndex >= widget.layers.length) {
      debugPrint('找不到图层的全局索引或索引超出范围');
      return;
    }

    // 使用新的组内重排序功能，同时处理链接状态和顺序
    debugPrint('=== 执行组内重排序（同时处理链接状态和顺序）===');
    debugPrint(
      '调用 onLayersInGroupReordered($oldGlobalIndex, $newGlobalIndex, ${layersToUpdate.length} 个图层更新)',
    );
    widget.onLayersInGroupReordered?.call(
      oldGlobalIndex,
      newGlobalIndex,
      layersToUpdate,
    );
    debugPrint('=== 组内重排序完成 ===');
  }

  /// 处理组重排序
  void _handleGroupReorder(int oldIndex, int newIndex) {
    debugPrint('=== 组重排序 ===');
    debugPrint('组oldIndex: $oldIndex, newIndex: $newIndex');

    if (oldIndex == newIndex) {
      debugPrint('索引相同，跳过');
      return;
    }

    final groups = _groupLinkedLayers();

    if (oldIndex >= groups.length ||
        newIndex > groups.length ||
        oldIndex < 0 ||
        newIndex < 0) {
      debugPrint('组索引超出范围');
      return;
    }

    // 安全地获取组
    final oldGroup = groups.elementAtOrNull(oldIndex);
    if (oldGroup == null || oldGroup.isEmpty) {
      debugPrint('源组为空');
      return;
    }

    // 计算移动组的第一个图层的全局索引
    int oldGlobalIndex = 0;
    for (int i = 0; i < oldIndex; i++) {
      final group = groups.elementAtOrNull(i);
      if (group != null) {
        oldGlobalIndex += group.length;
      }
    }

    // 重新计算目标位置的全局索引
    int newGlobalIndex = 0;

    // 修正：无论向前还是向后移动，都计算到目标位置的开始
    // 然后在 _moveGroup 中根据移动方向进行调整
    for (int i = 0; i < newIndex; i++) {
      final group = groups.elementAtOrNull(i);
      if (group != null) {
        newGlobalIndex += group.length;
      }
    }

    debugPrint('移动组大小: ${oldGroup.length}');
    debugPrint('移动组图层: ${oldGroup.map((l) => l.name).toList()}');
    debugPrint(
      '组全局索引: oldGlobalIndex=$oldGlobalIndex, newGlobalIndex=$newGlobalIndex',
    );

    // 对于组移动，需要特殊处理：移动整个组而不是单个图层
    _moveGroup(
      oldGlobalIndex,
      oldGroup.length,
      newGlobalIndex,
      oldIndex,
      newIndex,
    );
  }

  /// 移动整个组
  void _moveGroup(
    int oldStartIndex,
    int groupSize,
    int newStartIndex,
    int oldGroupIndex,
    int newGroupIndex,
  ) {
    debugPrint('=== 移动组 ===');
    debugPrint(
      'oldStartIndex: $oldStartIndex, groupSize: $groupSize, newStartIndex: $newStartIndex',
    );
    debugPrint('oldGroupIndex: $oldGroupIndex, newGroupIndex: $newGroupIndex');

    // 使用批量更新方式
    final List<MapLayer> currentLayers = List.from(widget.layers);

    // 提取要移动的组
    final movedGroup = currentLayers.sublist(
      oldStartIndex,
      oldStartIndex + groupSize,
    );

    // 从原位置移除组
    currentLayers.removeRange(oldStartIndex, oldStartIndex + groupSize);

    // 重新计算插入位置
    int adjustedNewIndex = newStartIndex;

    if (newGroupIndex > oldGroupIndex) {
      // 向后移动：需要调整位置，因为前面移除了元素
      adjustedNewIndex = newStartIndex - groupSize;
    }
    // 向前移动：位置不需要调整

    // 在新位置插入组
    currentLayers.insertAll(adjustedNewIndex, movedGroup);

    debugPrint('移动后图层名称: ${currentLayers.map((l) => l.name).toList()}');

    // 通知父组件更新图层顺序
    if (widget.onLayersBatchUpdated != null) {
      widget.onLayersBatchUpdated!(currentLayers);
    } else {
      // 如果没有批量更新回调，使用传统方式
      debugPrint('使用传统重排序方式');
      debugPrint('警告：没有批量更新接口，无法正确移动组');
    }
  }

  /// 处理透明度变化（拖动时）
  void _handleOpacityChange(MapLayer layer, double opacity) {
    setState(() {
      _tempOpacityValues[layer.id] = opacity;
    });

    // 立即通知画布进行预览
    widget.onOpacityPreview?.call(layer.id, opacity);
  }

  /// 处理透明度变化结束（松开滑块时）
  void _handleOpacityChangeEnd(MapLayer layer, double opacity) {
    // 取消之前的定时器
    _opacityTimers[layer.id]?.cancel();

    // 设置一个短延迟，避免频繁更新
    _opacityTimers[layer.id] = Timer(const Duration(milliseconds: 100), () {
      // 更新实际数据
      final updatedLayer = layer.copyWith(
        opacity: opacity,
        updatedAt: DateTime.now(),
      );
      widget.onLayerUpdated(updatedLayer);

      // 清除临时值
      setState(() {
        _tempOpacityValues.remove(layer.id);
      });
    });
  }

  /// 构建图例组绑定 chip
  Widget _buildLegendGroupsChip(MapLayer layer) {
    // 安全获取绑定的图例组数量
    final boundGroupsCount = layer.legendGroupIds.length;
    final hasAllLegendGroups = widget.allLegendGroups != null;

    return InkWell(
      onTap: !hasAllLegendGroups
          ? null
          : () => widget.onShowLayerLegendBinding?.call(
              layer,
              widget.allLegendGroups!,
            ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: boundGroupsCount > 0
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withAlpha((0.3 * 255).toInt())
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: boundGroupsCount > 0
                ? Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha((0.3 * 255).toInt())
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.legend_toggle,
              size: 12,
              color: boundGroupsCount > 0
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              boundGroupsCount > 0
                  ? '已绑定 $boundGroupsCount 个图例组'
                  : (hasAllLegendGroups ? '点击绑定图例组' : '图例组不可用'),
              style: TextStyle(
                fontSize: 10,
                color: boundGroupsCount > 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: boundGroupsCount > 0 ? FontWeight.w500 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建标签管理 chip
  Widget _buildTagsChip(MapLayer layer) {
    final tags = layer.tags ?? [];
    final hasAllTags = tags.isNotEmpty;

    return InkWell(
      onTap: () => _showTagsManagerDialog(layer),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: hasAllTags
              ? Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withAlpha((0.3 * 255).toInt())
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasAllTags
                ? Theme.of(
                    context,
                  ).colorScheme.secondary.withAlpha((0.3 * 255).toInt())
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer,
              size: 12,
              color: hasAllTags
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              hasAllTags ? '${tags.length} 个标签' : '添加标签',
              style: TextStyle(
                fontSize: 10,
                color: hasAllTags
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: hasAllTags ? FontWeight.w500 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示标签管理对话框
  void _showTagsManagerDialog(MapLayer layer) async {
    final currentTags = layer.tags ?? [];

    final result = await TagsManagerUtils.showTagsDialog(
      context,
      initialTags: currentTags,
      title: '管理图层标签 - ${layer.name}',
      maxTags: 10, // 限制最多10个标签
      suggestedTags: _getLayerSuggestedTags(),
      tagValidator: TagsManagerUtils.defaultTagValidator,
      enableCustomTagsManagement: true,
    );

    if (result != null) {
      final updatedLayer = layer.copyWith(
        tags: result,
        updatedAt: DateTime.now(),
      );
      widget.onLayerUpdated(updatedLayer);

      if (result.isEmpty) {
        widget.onSuccess?.call('已清空图层标签');
      } else {
        widget.onSuccess?.call('已更新图层标签：${result.join(', ')}');
      }
    }
  }

  /// 获取图层的建议标签列表
  List<String> _getLayerSuggestedTags() {
    // 从当前所有图层中收集已使用的标签
    final allUsedTags = <String>[];
    for (final layer in widget.layers) {
      if (layer.tags != null) {
        allUsedTags.addAll(layer.tags!);
      }
    }

    // 去重并排序
    final uniqueTags = allUsedTags.toSet().toList()..sort();

    // 添加一些图层相关的默认建议标签
    const layerSpecificTags = ['背景图层', '前景图层', '标注图层', '参考图层', '基础图层', '装饰图层'];

    // 合并建议标签，优先显示已使用的标签
    final suggestedTags = <String>[];
    suggestedTags.addAll(uniqueTags);

    for (final tag in layerSpecificTags) {
      if (!suggestedTags.contains(tag)) {
        suggestedTags.add(tag);
      }
    }

    return suggestedTags;
  }

  /// 构建图层名称编辑器
  Widget _buildLayerNameEditor(MapLayer layer) {
    final TextEditingController controller = TextEditingController(
      text: layer.name,
    );

    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          // 通知父组件输入框焦点状态变化
          widget.onInputFieldFocusChanged?.call(hasFocus);
        },
        child: TextField(
          controller: controller,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.left,
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            border: InputBorder.none,
            hintText: '输入图层名称',
            hintStyle: TextStyle(fontSize: 14),
            isDense: true,
          ),
          enabled: true, //!widget.isPreviewMode,
          textInputAction: TextInputAction.done,
          onSubmitted: (newName) => _saveLayerName(layer, newName),
          onTapOutside: (event) {
            // 当用户点击输入框外部时保存名称
            _saveLayerName(layer, controller.text);
            // 失去焦点
            FocusScope.of(context).unfocus();
          },
          onEditingComplete: () {
            // 当用户完成编辑时保存名称
            _saveLayerName(layer, controller.text);
          },
        ),
      ),
    );
  }

  /// 保存图层名称
  void _saveLayerName(MapLayer layer, String newName) {
    if (newName.trim().isNotEmpty && newName.trim() != layer.name) {
      final updatedLayer = layer.copyWith(
        name: newName.trim(),
        updatedAt: DateTime.now(),
      );
      widget.onLayerUpdated(updatedLayer);
    }
    // 保存后立即失焦，恢复快捷键
    FocusScope.of(context).unfocus();
  }

  /// 处理图片上传
  Future<void> _handleImageUpload(MapLayer layer) async {
    try {
      final imageData = await ImageUtils.pickAndEncodeImage();
      if (imageData != null) {
        final updatedLayer = layer.copyWith(
          imageData: imageData,
          updatedAt: DateTime.now(),
        );
        widget.onLayerUpdated(updatedLayer);
        widget.onSuccess?.call('图片上传成功');
      }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      widget.onError?.call(errorMessage);
      debugPrint('上传图片失败: $e');
    }
  }

  /// 移除图层图片
  void _removeLayerImage(MapLayer layer) {
    final updatedLayer = layer.copyWith(
      clearImageData: true, // 使用新的 clearImageData 参数来明确移除图片
      updatedAt: DateTime.now(),
    );
    widget.onLayerUpdated(updatedLayer);
    widget.onSuccess?.call('图片已移除');
  }

  /// 显示图层右键菜单
  void _showLayerContextMenu(
    BuildContext context,
    MapLayer layer,
    Offset position,
  ) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'hide_others',
          child: Row(
            children: const [
              Icon(Icons.visibility_off_outlined, size: 16),
              SizedBox(width: 8),
              Text('隐藏其他图层'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'show_all',
          child: Row(
            children: const [
              Icon(Icons.visibility_outlined, size: 16),
              SizedBox(width: 8),
              Text('显示所有图层'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleContextMenuAction(value, layer);
      }
    });
  }

  /// 处理右键菜单操作
  void _handleContextMenuAction(String action, MapLayer layer) {
    switch (action) {
      case 'hide_others':
        _hideOtherLayers(layer);
        break;
      case 'show_all':
        _showAllLayers();
        break;
    }
  }

  /// 隐藏除指定图层外的所有其他图层
  void _hideOtherLayers(MapLayer targetLayer) {
    final updatedLayers = widget.layers.map((layer) {
      if (layer.id == targetLayer.id) {
        // 确保目标图层是可见的
        return layer.copyWith(isVisible: true, updatedAt: DateTime.now());
      } else {
        // 隐藏其他图层
        return layer.copyWith(isVisible: false, updatedAt: DateTime.now());
      }
    }).toList();

    // 使用批量更新回调
    if (widget.onLayersBatchUpdated != null) {
      widget.onLayersBatchUpdated!(updatedLayers);
    } else {
      // 如果没有批量更新回调，逐个更新
      for (final updatedLayer in updatedLayers) {
        widget.onLayerUpdated(updatedLayer);
      }
    }

    widget.onSuccess?.call('已隐藏其他图层，只显示 "${targetLayer.name}"');
  }

  /// 显示所有图层
  void _showAllLayers() {
    final updatedLayers = widget.layers.map((layer) {
      return layer.copyWith(isVisible: true, updatedAt: DateTime.now());
    }).toList();

    // 使用批量更新回调
    if (widget.onLayersBatchUpdated != null) {
      widget.onLayersBatchUpdated!(updatedLayers);
    } else {
      // 如果没有批量更新回调，逐个更新
      for (final updatedLayer in updatedLayers) {
        widget.onLayerUpdated(updatedLayer);
      }
    }
    widget.onSuccess?.call('已显示所有图层');
  }
}

// 扩展方法放在类的外面，文件的底部
extension ListExtension<T> on List<T> {
  T? elementAtOrNull(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }
}
