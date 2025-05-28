import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';
import '../../../models/legend_item.dart' as legend_db;

/// 图例组管理抽屉
class LegendGroupManagementDrawer extends StatefulWidget {
  final LegendGroup legendGroup;
  final List<legend_db.LegendItem> availableLegends;
  final Function(LegendGroup) onLegendGroupUpdated;
  final bool isPreviewMode;
  final VoidCallback onClose; // 关闭回调
  final Function(String)? onLegendItemSelected; // 图例项选中回调

  const LegendGroupManagementDrawer({
    super.key,
    required this.legendGroup,
    required this.availableLegends,
    required this.onLegendGroupUpdated,
    this.isPreviewMode = false,
    required this.onClose,
    this.onLegendItemSelected,
  });

  @override
  State<LegendGroupManagementDrawer> createState() => _LegendGroupManagementDrawerState();
}

class _LegendGroupManagementDrawerState extends State<LegendGroupManagementDrawer> {
  late LegendGroup _currentGroup;
  String? _selectedLegendItemId; // 当前选中的图例项ID

  @override
  void initState() {
    super.initState();
    _currentGroup = widget.legendGroup;
  }

  // 检查图例项是否被选中
  bool _isLegendItemSelected(LegendItem item) {
    return _selectedLegendItemId == item.id;
  }

  // 选中图例项
  void _selectLegendItem(LegendItem item) {
    setState(() {
      _selectedLegendItemId = _selectedLegendItemId == item.id ? null : item.id;
    });
    // 通知父组件选中状态变化，用于高亮显示地图上的图例项
    widget.onLegendItemSelected?.call(_selectedLegendItemId ?? '');
  }

  // 更新图例项
  void _updateLegendItem(LegendItem updatedItem) {
    final updatedItems = _currentGroup.legendItems.map((item) {
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();

    _updateGroup(_currentGroup.copyWith(legendItems: updatedItems));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400, // 管理图例组宽度
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
                        _currentGroup.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    if (!widget.isPreviewMode)
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
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 图例组设置
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 可见性和透明度控制
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _currentGroup.isVisible ? Icons.visibility : Icons.visibility_off,
                        size: 18,
                      ),
                      onPressed: widget.isPreviewMode
                          ? null
                          : () => _updateGroup(_currentGroup.copyWith(
                                isVisible: !_currentGroup.isVisible,
                              )),
                    ),
                    const SizedBox(width: 8),
                    const Text('透明度:', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: _currentGroup.opacity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: '${(_currentGroup.opacity * 100).round()}%',
                        onChanged: widget.isPreviewMode
                            ? null
                            : (value) => _updateGroup(_currentGroup.copyWith(opacity: value)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          // 图例列表
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        '图例列表 (${_currentGroup.legendItems.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (!widget.isPreviewMode)
                        ElevatedButton.icon(
                          onPressed: _showAddLegendDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('添加图例'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _currentGroup.legendItems.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.legend_toggle_outlined, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                '此图例组暂无图例',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _currentGroup.legendItems.length,
                          itemBuilder: (context, index) {
                            return _buildLegendItemTile(_currentGroup.legendItems[index]);
                          },
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
    final legend = widget.availableLegends.firstWhere(
      (l) => l.id.toString() == item.legendId,
      orElse: () => legend_db.LegendItem(
        title: '未知图例',
        centerX: 0.0,
        centerY: 0.0,
        version: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _isLegendItemSelected(item)
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        borderRadius: BorderRadius.circular(12),
        border: _isLegendItemSelected(item)
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : Border.all(color: Colors.grey.shade300),
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
                              : Colors.grey.shade300,
                          width: _isLegendItemSelected(item) ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: legend.hasImageData
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.memory(
                                legend.imageData!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : const Icon(Icons.image, size: 24, color: Colors.grey),
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
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 可见性切换
                    IconButton(
                      icon: Icon(
                        item.isVisible ? Icons.visibility : Icons.visibility_off,
                        size: 18,
                        color: item.isVisible ? null : Colors.grey,
                      ),
                      onPressed: widget.isPreviewMode ? null : () => _updateLegendItem(
                        item.copyWith(isVisible: !item.isVisible),
                      ),
                      tooltip: item.isVisible ? '隐藏' : '显示',
                    ),
                    // 更多操作
                    if (!widget.isPreviewMode)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 16),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 14, color: Colors.red),
                                SizedBox(width: 8),
                                Text('删除', style: TextStyle(color: Colors.red)),
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
                if (!widget.isPreviewMode) ...[
                  // 大小控制
                  _buildSliderControl(
                    label: '大小',
                    value: item.size,
                    min: 0.1,
                    max: 3.0,
                    divisions: 29,
                    displayValue: '${item.size.toStringAsFixed(1)}x',
                    onChanged: (value) => _updateLegendItem(
                      item.copyWith(size: value),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 旋转角度控制
                  _buildSliderControl(
                    label: '旋转',
                    value: item.rotation,
                    min: 0.0,
                    max: 360.0,
                    divisions: 72,
                    displayValue: '${item.rotation.toStringAsFixed(0)}°',
                    onChanged: (value) => _updateLegendItem(
                      item.copyWith(rotation: value),
                    ),
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
                    onChanged: (value) => _updateLegendItem(
                      item.copyWith(opacity: value),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
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

  void _updateGroup(LegendGroup updatedGroup) {
    setState(() {
      _currentGroup = updatedGroup.copyWith(updatedAt: DateTime.now());
    });
    widget.onLegendGroupUpdated(_currentGroup);
  }

  void _showEditNameDialog() {
    final TextEditingController nameController = TextEditingController(text: _currentGroup.name);

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
                _updateGroup(_currentGroup.copyWith(name: nameController.text.trim()));
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
    if (widget.availableLegends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无可用图例，请先在图例管理页面添加图例')),
      );
      return;
    }

    legend_db.LegendItem? selectedLegend;
    double positionX = 0.5;
    double positionY = 0.5;
    double size = 1.0;
    double rotation = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加图例'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<legend_db.LegendItem>(
                  value: selectedLegend,
                  decoration: const InputDecoration(
                    labelText: '选择图例',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.availableLegends.map((legend) {
                    return DropdownMenuItem(
                      value: legend,
                      child: Text(legend.title),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedLegend = value);
                  },
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
                        controller: TextEditingController(text: positionX.toString()),
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
                        controller: TextEditingController(text: positionY.toString()),
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
                        controller: TextEditingController(text: size.toString()),
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
                        controller: TextEditingController(text: rotation.toString()),
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
              onPressed: selectedLegend != null
                  ? () {
                      final newItem = LegendItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        legendId: selectedLegend!.id.toString(),
                        position: Offset(positionX, positionY),
                        size: size,
                        rotation: rotation,
                        createdAt: DateTime.now(),
                      );

                      final updatedGroup = _currentGroup.copyWith(
                        legendItems: [..._currentGroup.legendItems, newItem],
                      );
                      _updateGroup(updatedGroup);
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
              final updatedItems = _currentGroup.legendItems
                  .where((i) => i.id != item.id)
                  .toList();
              final updatedGroup = _currentGroup.copyWith(legendItems: updatedItems);
              _updateGroup(updatedGroup);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
