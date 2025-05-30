import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';
import '../../../utils/image_utils.dart';
import '../../../components/web/web_context_menu_handler.dart';
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
  final List<LegendGroup> allLegendGroups;
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
    required this.allLegendGroups,
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
                : ReorderableListView.builder(
                    itemCount: widget.layers.length,
                    onReorder: widget.onLayersReordered,
                    buildDefaultDragHandles: false, // 禁用默认拖动手柄
                    itemBuilder: (context, index) {
                      final layer = widget.layers[index];
                      return _buildLayerTile(context, layer, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerTile(BuildContext context, MapLayer layer, int index) {
    final isSelected = widget.selectedLayer?.id == layer.id;

    return Container(
      key: ValueKey(layer.id),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withAlpha((0.3 * 255).toInt())
            : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : Border.all(color: Colors.grey.shade300),
      ),
      child: GestureDetector(
        onSecondaryTapDown: widget.isPreviewMode
            ? null
            : (details) {
                _showLayerContextMenu(context, layer, details.globalPosition);
              },
        child: InkWell(
          onTap: () => widget.onLayerSelected(layer),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一排：可见性按钮 + 图层名称输入框 + 操作按钮
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

                    // 操作按钮
                    if (!widget.isPreviewMode) ...[
                      // 图片管理按钮
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.image, size: 16),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'upload',
                            child: Row(
                              children: [
                                Icon(
                                  layer.imageData != null
                                      ? Icons.edit
                                      : Icons.upload,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(layer.imageData != null ? '更换图片' : '上传图片'),
                              ],
                            ),
                          ),
                          if (layer.imageData != null)
                            const PopupMenuItem(
                              value: 'remove',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 16),
                                  SizedBox(width: 8),
                                  Text('移除图片'),
                                ],
                              ),
                            ),
                        ],
                        onSelected: (value) async {
                          switch (value) {
                            case 'upload':
                              await _handleImageUpload(layer);
                              break;
                            case 'remove':
                              _removeLayerImage(layer);
                              break;
                          }
                        },
                      ),

                      // 删除按钮
                      if (widget.layers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 16),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('删除图层'),
                                content: Text(
                                  '确定要删除图层 "${layer.name}" 吗？此操作不可撤销。',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
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
                          },
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ],
                ),

                // 第二排：透明度滑块
                const SizedBox(height: 8),
                _buildOpacitySlider(layer),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建优化的透明度滑块和图例组绑定
  Widget _buildOpacitySlider(MapLayer layer) {
    // 获取当前显示的透明度值（临时值或实际值）
    final currentOpacity = _tempOpacityValues[layer.id] ?? layer.opacity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 透明度滑块
        Row(
          children: [
            const Text('不透明度:', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 3), // 你可以根据需要调小这个值
            Flexible(
              // 用 Flexible 而不是 Expanded 更好控制空间分配
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
            const SizedBox(width: 3), // 添加一点间距让数值不会贴太紧
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
    );
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
    final boundGroupsCount = layer.legendGroupIds.length;
    final layerIndex = widget.layers.indexOf(layer);

    return Row(
      children: [
        // 图例组绑定chip
        Expanded(
          child: InkWell(
            onTap: widget.isPreviewMode
                ? null
                : () => widget.onShowLayerLegendBinding?.call(
                    layer,
                    widget.allLegendGroups,
                  ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: boundGroupsCount > 0
                    ? Theme.of(context).colorScheme.primaryContainer.withAlpha(
                        (0.3 * 255).toInt(),
                      )
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
                        : '点击绑定图例组',
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
          ),
        ),

        // 拖动手柄
        if (!widget.isPreviewMode) ...[
          const SizedBox(width: 8),
          ReorderableDragStartListener(
            index: layerIndex,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                Icons.drag_handle,
                size: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ],
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
