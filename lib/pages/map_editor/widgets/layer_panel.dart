import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';
import '../../../utils/image_utils.dart';
import 'dart:async';

class LayerPanel extends StatefulWidget {
  final List<MapLayer> layers;
  final MapLayer? selectedLayer;
  final bool isPreviewMode;
  final Function(MapLayer) onLayerSelected;
  final Function(MapLayer) onLayerUpdated;
  final Function(MapLayer) onLayerDeleted;
  final VoidCallback onLayerAdded;
  final Function(int oldIndex, int newIndex) onLayersReordered;
  final Function(String)? onError;
  final Function(String)? onSuccess;
  // 新增：实时透明度预览回调
  final Function(String layerId, double opacity)?
  onOpacityPreview; // 新增：图例组相关数据和回调
  final List<LegendGroup>? allLegendGroups; // 改为可空类型
  final Function(MapLayer, List<LegendGroup>)?
  onShowLayerLegendBinding; // 显示图层图例绑定抽屉
  // 新增：批量更新图层回调
  final Function(List<MapLayer>)? onLayersBatchUpdated;

  const LayerPanel({
    super.key,
    required this.layers,
    this.selectedLayer,
    required this.isPreviewMode,
    required this.onLayerSelected,
    required this.onLayerUpdated,
    required this.onLayerDeleted,
    required this.onLayerAdded,
    required this.onLayersReordered,
    this.onError,
    this.onSuccess,
    this.onOpacityPreview,
    this.allLegendGroups, // 改为可选参数
    this.onShowLayerLegendBinding,
    this.onLayersBatchUpdated,
  });

  @override
  State<LayerPanel> createState() => _LayerPanelState();
}

class _LayerPanelState extends State<LayerPanel> {
  // 用于存储临时的透明度值，避免频繁更新数据
  final Map<String, double> _tempOpacityValues = {};
  final Map<String, Timer?> _opacityTimers = {};

  @override
  void dispose() {
    // 清理所有定时器
    for (final timer in _opacityTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  /// 将图层分组为链接组
  List<List<MapLayer>> _groupLinkedLayers() {
    final groups = <List<MapLayer>>[];
    List<MapLayer> currentGroup = [];

    for (int i = 0; i < widget.layers.length; i++) {
      final layer = widget.layers[i];
      currentGroup.add(layer);

      // 安全访问 isLinkedToNext 属性
      final isLinked = layer.isLinkedToNext ?? false;

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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图层列表
          Expanded(
            child: widget.layers.isEmpty
                ? const Center(
                    child: Text(
                      '暂无图层',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : _buildGroupedLayerList(),
          ),
        ],
      ),
    );
  }

  /// 构建分组的图层列表
  Widget _buildGroupedLayerList() {
    final groups = _groupLinkedLayers();

    if (groups.isEmpty) {
      return const Center(
        child: Text('暂无图层', style: TextStyle(color: Colors.grey, fontSize: 14)),
      );
    }

    return ReorderableListView.builder(
      itemCount: groups.length,
      onReorder: (oldIndex, newIndex) {
        print('组重排序触发：oldIndex=$oldIndex, newIndex=$newIndex');
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

    return Container(
      key: ValueKey('group_${group.first.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 重要：让列收缩到内容大小
        children: [
          // 多图层组的拖动手柄
          if (isMultiLayer && !widget.isPreviewMode)
            _buildGroupDragHandle(groupIndex),

          // 图层列表
          if (isMultiLayer)
            _buildInGroupReorderableList(group)
          else
            // 单独图层也显示拖动手柄
            _buildSingleLayerTile(context, group.first, groupIndex),
        ],
      ),
    );
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
          print('组内重排序触发：oldIndex=$oldIndex, newIndex=$newIndex');
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
                  Divider(height: 1, color: Colors.grey.shade300),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建组拖动手柄
  Widget _buildGroupDragHandle(int groupIndex) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: ReorderableDragStartListener(
        index: groupIndex,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.drag_handle, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Icon(Icons.drag_handle, size: 16, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerTile(
    BuildContext context,
    MapLayer layer,
    List<MapLayer> group,
    int layerIndexInGroup,
    bool isMultiLayer,
  ) {
    final isSelected = widget.selectedLayer?.id == layer.id;
    final globalLayerIndex = widget.layers.indexOf(layer);
    final isLastLayer = globalLayerIndex == widget.layers.length - 1;

    return Container(
      // 移除固定高度，让内容自适应
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withAlpha((0.3 * 255).toInt())
            : null,
        borderRadius: isMultiLayer ? null : BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onSecondaryTapDown: widget.isPreviewMode
            ? null
            : (details) {
                _showLayerContextMenu(context, layer, details.globalPosition);
              },
        child: InkWell(
          onTap: () => widget.onLayerSelected(layer),
          borderRadius: isMultiLayer ? null : BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 让列收缩到内容大小
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一排：可见性按钮 + 图层名称输入框 + 链接按钮 + 操作按钮
                Row(
                  children: [
                    // 可见性按钮
                    IconButton(
                      icon: Icon(
                        layer.isVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 18,
                        color: layer.isVisible ? null : Colors.grey,
                      ),
                      onPressed: widget.isPreviewMode
                          ? null
                          : () {
                              final updatedLayer = layer.copyWith(
                                isVisible: !layer.isVisible,
                                updatedAt: DateTime.now(),
                              );
                              widget.onLayerUpdated(updatedLayer);
                            },
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),

                    // 图层名称输入框
                    Expanded(child: _buildLayerNameEditor(layer)),

                    // 链接按钮
                    if (!widget.isPreviewMode)
                      _buildLinkButton(layer, isLastLayer),

                    // 操作按钮
                    if (!widget.isPreviewMode) ...[
                      // 图片管理按钮 - 使用 GestureDetector 替代 PopupMenuButton
                      GestureDetector(
                        onTap: () => _showImageMenu(context, layer),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.image, size: 16),
                        ),
                      ),

                      // 删除按钮
                      if (widget.layers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 16),
                          onPressed: () => _showDeleteDialog(context, layer),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
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
              if (layer.imageData != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, size: 20),
                  title: const Text('移除图片'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeLayerImage(layer);
                  },
                ),
            ],
          ),
        );
      },
    );
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
    final isLinked = layer.isLinkedToNext ?? false; // 安全访问

    return IconButton(
      icon: Icon(
        isLinked ? Icons.link : Icons.link_off,
        size: 16,
        color: isLastLayer
            ? Colors.grey.shade400
            : (isLinked ? Colors.blue : Colors.grey.shade600),
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
      tooltip: isLastLayer ? '最后一个图层无法链接' : (isLinked ? '取消链接' : '链接到下一个图层'),
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
                  onChanged: widget.isPreviewMode
                      ? null
                      : (opacity) => _handleOpacityChange(layer, opacity),
                  onChangeEnd: widget.isPreviewMode
                      ? null
                      : (opacity) => _handleOpacityChangeEnd(layer, opacity),
                ),
              ),
              const SizedBox(width: 3),
              Text(
                '${(currentOpacity * 100).round()}%',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),

          // 图例组绑定 chip
          const SizedBox(height: 4),
          _buildLegendGroupsChip(layer),
        ],
      ),
    );
  }

  /// 处理组内重排序
  void _handleInGroupReorder(List<MapLayer> group, int oldIndex, int newIndex) {
    print('=== 组内重排序 ===');
    print('组内oldIndex: $oldIndex, newIndex: $newIndex');
    print('组大小: ${group.length}');
    print('组内图层: ${group.map((l) => l.name).toList()}');

    if (oldIndex == newIndex ||
        oldIndex >= group.length ||
        newIndex >= group.length) {
      print('索引无效，跳过');
      return;
    }

    // 安全地获取图层
    final oldLayer = group.elementAtOrNull(oldIndex);
    final newLayer = group.elementAtOrNull(newIndex);

    if (oldLayer == null || newLayer == null) {
      print('图层为空，跳过');
      return;
    }

    // 计算全局索引
    final oldGlobalIndex = widget.layers.indexOf(oldLayer);
    final newGlobalIndex = widget.layers.indexOf(newLayer);

    print(
      '全局索引: oldGlobalIndex=$oldGlobalIndex, newGlobalIndex=$newGlobalIndex',
    );

    if (oldGlobalIndex == -1 || newGlobalIndex == -1) {
      print('找不到图层的全局索引');
      return;
    }

    widget.onLayersReordered(oldGlobalIndex, newGlobalIndex);
  }

  /// 处理组重排序
  void _handleGroupReorder(int oldIndex, int newIndex) {
    print('=== 组重排序 ===');
    print('组oldIndex: $oldIndex, newIndex: $newIndex');

    if (oldIndex == newIndex) {
      print('索引相同，跳过');
      return;
    }

    final groups = _groupLinkedLayers();

    if (oldIndex >= groups.length ||
        newIndex > groups.length ||
        oldIndex < 0 ||
        newIndex < 0) {
      print('组索引超出范围');
      return;
    }

    // 安全地获取组
    final oldGroup = groups.elementAtOrNull(oldIndex);
    if (oldGroup == null || oldGroup.isEmpty) {
      print('源组为空');
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

    print('移动组大小: ${oldGroup.length}');
    print('移动组图层: ${oldGroup.map((l) => l.name).toList()}');
    print(
      '组全局索引: oldGlobalIndex=$oldGlobalIndex, newGlobalIndex=$newGlobalIndex',
    );

    // 对于组移动，需要特殊处理：移动整个组而不是单个图层
    _moveGroup(oldGlobalIndex, oldGroup.length, newGlobalIndex, oldIndex, newIndex);
  }

  /// 移动整个组
  void _moveGroup(int oldStartIndex, int groupSize, int newStartIndex, int oldGroupIndex, int newGroupIndex) {
    print('=== 移动组 ===');
    print(
      'oldStartIndex: $oldStartIndex, groupSize: $groupSize, newStartIndex: $newStartIndex',
    );
    print('oldGroupIndex: $oldGroupIndex, newGroupIndex: $newGroupIndex');

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

    print('移动后图层名称: ${currentLayers.map((l) => l.name).toList()}');

    // 通知父组件更新图层顺序
    if (widget.onLayersBatchUpdated != null) {
      widget.onLayersBatchUpdated!(currentLayers);
    } else {
      // 如果没有批量更新回调，使用传统方式
      print('使用传统重排序方式');
      print('警告：没有批量更新接口，无法正确移动组');
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
    final boundGroupsCount = layer.legendGroupIds?.length ?? 0;
    final hasAllLegendGroups = widget.allLegendGroups != null;

    return InkWell(
      onTap: widget.isPreviewMode || !hasAllLegendGroups
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
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: boundGroupsCount > 0
                ? Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha((0.3 * 255).toInt())
                : Colors.grey.shade300,
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
                  : Colors.grey,
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
                    : Colors.grey.shade600,
                fontWeight: boundGroupsCount > 0 ? FontWeight.w500 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图层名称编辑器
  Widget _buildLayerNameEditor(MapLayer layer) {
    final TextEditingController controller = TextEditingController(
      text: layer.name,
    );

    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade50,
      ),
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
        enabled: !widget.isPreviewMode,
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
