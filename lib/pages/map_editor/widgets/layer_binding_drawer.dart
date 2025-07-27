import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/map_layer.dart';
import '../../../providers/user_preferences_provider.dart';

/// 图层绑定抽屉 - 从图例组角度选择要绑定的图层
class LayerBindingDrawer extends StatefulWidget {
  final LegendGroup legendGroup;
  final List<MapLayer> allLayers;
  final Function(List<MapLayer>) onLayersUpdated; // 图层更新回调
  final VoidCallback onClose; // 关闭回调

  const LayerBindingDrawer({
    super.key,
    required this.legendGroup,
    required this.allLayers,
    required this.onLayersUpdated,
    required this.onClose,
  });

  @override
  State<LayerBindingDrawer> createState() => _LayerBindingDrawerState();
}

class _LayerBindingDrawerState extends State<LayerBindingDrawer> {
  late Set<String> _selectedLayerIds;

  @override
  void initState() {
    super.initState();
    // 初始化时，找出所有已经绑定了当前图例组的图层
    _selectedLayerIds = widget.allLayers
        .where((layer) => layer.legendGroupIds.contains(widget.legendGroup.id))
        .map((layer) => layer.id)
        .toSet();
  }

  @override
  void didUpdateWidget(LayerBindingDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果图例组发生变化，更新选中的图层ID
    if (oldWidget.legendGroup.id != widget.legendGroup.id) {
      setState(() {
        _selectedLayerIds = widget.allLayers
            .where(
              (layer) => layer.legendGroupIds.contains(widget.legendGroup.id),
            )
            .map((layer) => layer.id)
            .toSet();
      });
    }

    // 如果图层列表发生变化，触发UI重新构建
    if (oldWidget.allLayers != widget.allLayers) {
      setState(() {
        // 检查当前选中的图层ID是否仍然有效
        final validLayerIds = widget.allLayers.map((l) => l.id).toSet();
        _selectedLayerIds = _selectedLayerIds.intersection(validLayerIds);

        // 重新计算绑定状态
        _selectedLayerIds = widget.allLayers
            .where(
              (layer) => layer.legendGroupIds.contains(widget.legendGroup.id),
            )
            .map((layer) => layer.id)
            .toSet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = context.watch<UserPreferencesProvider>();
    final drawerWidth = userPrefs.layout.drawerWidth;

    // 分离已绑定和未绑定的图层
    final boundLayers = widget.allLayers
        .where((layer) => _selectedLayerIds.contains(layer.id))
        .toList();
    final unboundLayers = widget.allLayers
        .where((layer) => !_selectedLayerIds.contains(layer.id))
        .toList();

    return Container(
      width: drawerWidth, // 使用用户偏好设置的抽屉宽度
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.legend_toggle,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '图例组: ${widget.legendGroup.name}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '选择要绑定到此图例组的图层',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor,
            thickness: 1,
          ),

          // 内容区域
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 已绑定的图层
                if (boundLayers.isNotEmpty) ...[
                  Text(
                    '已绑定的图层 (${boundLayers.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...boundLayers.map((layer) => _buildLayerTile(layer, true)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                ],

                // 未绑定的图层
                Text(
                  '可用的图层 (${unboundLayers.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (unboundLayers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '暂无可用的图层',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...unboundLayers.map(
                    (layer) => _buildLayerTile(layer, false),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerTile(MapLayer layer, bool isBound) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isBound
              ? Theme.of(
                  context,
                ).colorScheme.primary.withAlpha((0.5 * 255).toInt())
              : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isBound
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withAlpha((0.1 * 255).toInt())
            : null,
      ),
      child: ListTile(
        dense: true,
        leading: Checkbox(
          value: _selectedLayerIds.contains(layer.id),
          onChanged: (value) => _toggleLayer(layer.id, value ?? false),
        ),
        title: Text(
          layer.name,
          style: TextStyle(
            fontWeight: isBound ? FontWeight.w500 : null,
            color: isBound ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              layer.isVisible ? Icons.visibility : Icons.visibility_off,
              size: 12,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              '${layer.elements.length} 个元素',
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(width: 8),
            Text(
              '${(layer.opacity * 100).round()}%',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        onTap: () =>
            _toggleLayer(layer.id, !_selectedLayerIds.contains(layer.id)),
      ),
    );
  }

  void _toggleLayer(String layerId, bool selected) {
    setState(() {
      if (selected) {
        _selectedLayerIds.add(layerId);
      } else {
        _selectedLayerIds.remove(layerId);
      }
    });

    // 实时应用更改，但不关闭抽屉
    _applyChangesWithoutClosing();
  }

  void _applyChangesWithoutClosing() {
    // 更新图层的绑定状态
    final updatedLayers = widget.allLayers.map((layer) {
      if (_selectedLayerIds.contains(layer.id)) {
        // 绑定到图例组
        final updatedGroupIds = List<String>.from(layer.legendGroupIds);
        if (!updatedGroupIds.contains(widget.legendGroup.id)) {
          updatedGroupIds.add(widget.legendGroup.id);
        }
        return layer.copyWith(
          legendGroupIds: updatedGroupIds,
          updatedAt: DateTime.now(),
        );
      } else if (layer.legendGroupIds.contains(widget.legendGroup.id)) {
        // 取消绑定
        final updatedGroupIds = List<String>.from(layer.legendGroupIds)
          ..remove(widget.legendGroup.id);
        return layer.copyWith(
          legendGroupIds: updatedGroupIds,
          updatedAt: DateTime.now(),
        );
      }
      return layer;
    }).toList();

    // 通过回调函数更新图层
    widget.onLayersUpdated(updatedLayers);
  }
}
