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
  final Function(LegendGroup)? onLegendGroupTapped; // 点击图例组时的回调

  const LegendPanel({
    super.key,
    required this.legendGroups,
    required this.availableLegends,
    required this.isPreviewMode,
    required this.onLegendGroupUpdated,
    required this.onLegendGroupDeleted,
    required this.onLegendGroupAdded,
    this.onLegendGroupTapped,
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
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    itemCount: legendGroups.length,
                    itemBuilder: (context, index) {
                      return _buildLegendGroupCard(
                        context,
                        legendGroups[index],
                      );
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
      child: ListTile(
        dense: true,
        title: Text(
          legendGroup.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            Text(
              '${legendGroup.legendItems.length} 个图例',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 8),
            Text(
              '透明度: ${(legendGroup.opacity * 100).round()}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
        onTap: () => onLegendGroupTapped?.call(legendGroup),
      ),
    );
  }

  void _showEditLegendGroupDialog(
    BuildContext context,
    LegendGroup legendGroup,
  ) {
    final TextEditingController nameController = TextEditingController(
      text: legendGroup.name,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑图例组'),
        content: TextField(
          controller: nameController,
          textInputAction: TextInputAction.done,
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
}
