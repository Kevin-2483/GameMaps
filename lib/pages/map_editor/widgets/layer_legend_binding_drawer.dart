import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/map_layer.dart';
import '../../../providers/user_preferences_provider.dart';

/// 图层图例组绑定抽屉
class LayerLegendBindingDrawer extends StatefulWidget {
  final MapLayer layer;
  final List<LegendGroup> allLegendGroups;
  final Function(MapLayer) onLayerUpdated;
  final Function(LegendGroup) onLegendGroupTapped; // 点击图例组时的回调
  final VoidCallback onClose; // 关闭回调

  const LayerLegendBindingDrawer({
    super.key,
    required this.layer,
    required this.allLegendGroups,
    required this.onLayerUpdated,
    required this.onLegendGroupTapped,
    required this.onClose,
  });

  @override
  State<LayerLegendBindingDrawer> createState() =>
      _LayerLegendBindingDrawerState();
}

class _LayerLegendBindingDrawerState extends State<LayerLegendBindingDrawer> {
  late Set<String> _selectedLegendGroupIds;

  @override
  void initState() {
    super.initState();
    _selectedLegendGroupIds = Set.from(widget.layer.legendGroupIds);
  }

  @override
  void didUpdateWidget(LayerLegendBindingDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 如果图层发生变化，更新选中的图例组ID
    if (oldWidget.layer.id != widget.layer.id) {
      setState(() {
        _selectedLegendGroupIds = Set.from(widget.layer.legendGroupIds);
      });
    }
    // 如果是同一个图层但图例组绑定发生了变化，也需要更新
    else if (oldWidget.layer.legendGroupIds != widget.layer.legendGroupIds) {
      setState(() {
        _selectedLegendGroupIds = Set.from(widget.layer.legendGroupIds);
      });
    }
    
    // 如果图例组列表发生变化，触发UI重新构建
    if (oldWidget.allLegendGroups != widget.allLegendGroups) {
      setState(() {
        // 检查当前选中的图例组ID是否仍然有效
        final validGroupIds = widget.allLegendGroups.map((g) => g.id).toSet();
        _selectedLegendGroupIds = _selectedLegendGroupIds.intersection(validGroupIds);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = context.watch<UserPreferencesProvider>();
    final drawerWidth = userPrefs.layout.drawerWidth;

    // 分离已绑定和未绑定的图例组
    final boundGroups = widget.allLegendGroups
        .where((group) => _selectedLegendGroupIds.contains(group.id))
        .toList();
    final unboundGroups = widget.allLegendGroups
        .where((group) => !_selectedLegendGroupIds.contains(group.id))
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
                      Icons.layers,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '图层: ${widget.layer.name}',
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
                  '选择要绑定到此图层的图例组',
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
                // 已绑定的图例组
                if (boundGroups.isNotEmpty) ...[
                  Text(
                    '已绑定的图例组 (${boundGroups.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...boundGroups.map(
                    (group) => _buildLegendGroupTile(group, true),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                ],

                // 未绑定的图例组
                Text(
                  '可用的图例组 (${unboundGroups.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (unboundGroups.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '暂无可用的图例组',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...unboundGroups.map(
                    (group) => _buildLegendGroupTile(group, false),
                  ),
              ],
            ),
          ),

          // 底部按钮
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _applyChanges,
                    icon: const Icon(Icons.save),
                    label: const Text('应用更改'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: widget.onClose,
                  child: const Text('取消'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendGroupTile(LegendGroup group, bool isBound) {
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
          value: _selectedLegendGroupIds.contains(group.id),
          onChanged: (value) => _toggleLegendGroup(group.id, value ?? false),
        ),
        title: Text(
          group.name,
          style: TextStyle(
            fontWeight: isBound ? FontWeight.w500 : null,
            color: isBound ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              group.isVisible ? Icons.visibility : Icons.visibility_off,
              size: 12,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              '${group.legendItems.length} 个图例',
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(width: 8),
            Text(
              '${(group.opacity * 100).round()}%',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.settings, size: 16),
          onPressed: () => widget.onLegendGroupTapped(group),
          tooltip: '管理图例组',
        ),
        onTap: () => _toggleLegendGroup(
          group.id,
          !_selectedLegendGroupIds.contains(group.id),
        ),
      ),
    );
  }

  void _toggleLegendGroup(String groupId, bool selected) {
    setState(() {
      if (selected) {
        _selectedLegendGroupIds.add(groupId);
      } else {
        _selectedLegendGroupIds.remove(groupId);
      }
    });
  }

  void _applyChanges() {
    final updatedLayer = widget.layer.copyWith(
      legendGroupIds: _selectedLegendGroupIds.toList(),
      updatedAt: DateTime.now(),
    );
    widget.onLayerUpdated(updatedLayer);
    widget.onClose();
  }
}
