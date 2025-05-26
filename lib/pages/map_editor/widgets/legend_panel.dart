import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';
import '../../../models/legend_item.dart' as legend_db;

class LegendPanel extends StatelessWidget {
  final List<LegendGroup> legendGroups;
  final List<legend_db.LegendItem> availableLegends;
  final bool isPreviewMode;
  final Function(LegendGroup) onLegendGroupUpdated;
  final Function(LegendGroup) onLegendGroupDeleted;
  final Function() onLegendGroupAdded;

  const LegendPanel({
    super.key,
    required this.legendGroups,
    required this.availableLegends,
    required this.isPreviewMode,
    required this.onLegendGroupUpdated,
    required this.onLegendGroupDeleted,
    required this.onLegendGroupAdded,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend groups list
          Expanded(
            child: legendGroups.isEmpty
                ? const Center(
                    child: Text(
                      '暂无图例组',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: legendGroups.length,
                    itemBuilder: (context, index) {
                      return _buildLegendGroupCard(context, legendGroups[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendGroupCard(BuildContext context, LegendGroup legendGroup) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                legendGroup.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            // Visibility toggle
            IconButton(
              icon: Icon(
                legendGroup.isVisible ? Icons.visibility : Icons.visibility_off,
                size: 18,
              ),
              onPressed: () {
                final updatedGroup = legendGroup.copyWith(
                  isVisible: !legendGroup.isVisible,
                  updatedAt: DateTime.now(),
                );
                onLegendGroupUpdated(updatedGroup);
              },
            ),
            if (!isPreviewMode)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('编辑'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16),
                        SizedBox(width: 8),
                        Text('删除'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditLegendGroupDialog(context, legendGroup);
                      break;
                    case 'delete':
                      _showDeleteConfirmDialog(context, legendGroup);
                      break;
                  }
                },
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Opacity slider
                Row(
                  children: [
                    const Text('透明度: ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: legendGroup.opacity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: '${(legendGroup.opacity * 100).round()}%',
                        onChanged: (value) {
                          final updatedGroup = legendGroup.copyWith(
                            opacity: value,
                            updatedAt: DateTime.now(),
                          );
                          onLegendGroupUpdated(updatedGroup);
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Legend items
                if (legendGroup.legendItems.isNotEmpty) ...[
                  const Text(
                    '图例项:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...legendGroup.legendItems.map((item) => _buildLegendItemTile(item)),
                ] else
                  const Text(
                    '暂无图例项',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                // Add legend item button
                if (!isPreviewMode)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddLegendItemDialog(context, legendGroup),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('添加图例项'),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Preview image
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Icon(Icons.image, size: 16, color: Colors.grey),
          ),
          
          const SizedBox(width: 8),
            // Label
          Expanded(
            child: Builder(
              builder: (context) {
                final legend = availableLegends.firstWhere(
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
                return Text(
                  legend.title,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
          
          // Position info
          Text(
            '(${item.position.dx.toStringAsFixed(1)}, ${item.position.dy.toStringAsFixed(1)})',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditLegendGroupDialog(BuildContext context, LegendGroup legendGroup) {
    final TextEditingController nameController = TextEditingController(text: legendGroup.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑图例组'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '图例组名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final updatedGroup = legendGroup.copyWith(
                  name: nameController.text.trim(),
                  updatedAt: DateTime.now(),
                );
                onLegendGroupUpdated(updatedGroup);
                Navigator.of(context).pop();
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, LegendGroup legendGroup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图例组'),
        content: Text('确定要删除图例组 "${legendGroup.name}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              onLegendGroupDeleted(legendGroup);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showAddLegendItemDialog(BuildContext context, LegendGroup legendGroup) {
    if (availableLegends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无可用图例，请先在图例管理页面添加图例')),
      );
      return;
    }

    legend_db.LegendItem? selectedLegend;
    double positionX = 0.5;
    double positionY = 0.5;
    double size = 24.0;
    double rotation = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加图例项'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Legend selection
                DropdownButtonFormField<legend_db.LegendItem>(
                  value: selectedLegend,
                  decoration: const InputDecoration(
                    labelText: '选择图例',
                    border: OutlineInputBorder(),
                  ),
                  items: availableLegends.map((legend) {
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
                
                // Position controls
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'X坐标',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
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
                        onChanged: (value) {
                          positionY = double.tryParse(value) ?? positionY;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Size control
                TextField(
                  decoration: const InputDecoration(
                    labelText: '大小',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    size = double.tryParse(value) ?? size;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Rotation control
                TextField(
                  decoration: const InputDecoration(
                    labelText: '旋转角度',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    rotation = double.tryParse(value) ?? rotation;
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
            ElevatedButton(              onPressed: selectedLegend != null ? () {
                final newItem = LegendItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  legendId: selectedLegend!.id.toString(),
                  position: Offset(positionX, positionY),
                  size: size,
                  rotation: rotation,
                  createdAt: DateTime.now(),
                );
                
                final updatedGroup = legendGroup.copyWith(
                  legendItems: [...legendGroup.legendItems, newItem],
                  updatedAt: DateTime.now(),
                );
                
                onLegendGroupUpdated(updatedGroup);
                Navigator.of(context).pop();
              } : null,
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }
}
