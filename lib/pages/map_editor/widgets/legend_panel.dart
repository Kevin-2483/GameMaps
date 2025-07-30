// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';
import '../../../models/legend_item.dart' as legend_db;
import '../../../l10n/app_localizations.dart';
import '../../../services/localization_service.dart';

class LegendPanel extends StatelessWidget {
  final List<LegendGroup> legendGroups;
  final List<legend_db.LegendItem> availableLegends;
  final bool isPreviewMode;
  final Function(LegendGroup) onLegendGroupUpdated;
  final Function(LegendGroup) onLegendGroupDeleted;
  final Function() onLegendGroupAdded;
  final Function(LegendGroup)? onLegendGroupTapped; // 点击图例组时的回调
  final Function(LegendGroup)? onLayerBinding; // 图层绑定回调

  const LegendPanel({
    super.key,
    required this.legendGroups,
    required this.availableLegends,
    required this.isPreviewMode,
    required this.onLegendGroupUpdated,
    required this.onLegendGroupDeleted,
    required this.onLegendGroupAdded,
    this.onLegendGroupTapped,
    this.onLayerBinding,
  });
  @override
  Widget build(BuildContext context) {
    return legendGroups.isEmpty
        ? Center(
            child: Text(
              LocalizationService.instance.current.noLegendGroup_4521,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: legendGroups.length,
            itemBuilder: (context, index) {
              return _buildLegendGroupCard(context, legendGroups[index]);
            },
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
              LocalizationService.instance.current.legendItemCount(
                legendGroup.legendItems.length,
              ),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 8),
            Text(
              LocalizationService.instance.current.opacityPercentage(
                (legendGroup.opacity * 100).round(),
              ),
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
            if (onLayerBinding != null)
              IconButton(
                icon: const Icon(Icons.layers, size: 18),
                tooltip: LocalizationService.instance.current.layerBinding_4271,
                onPressed: () => onLayerBinding!(legendGroup),
              ),
            // if (!isPreviewMode)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text(LocalizationService.instance.current.edit_7281),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16),
                      SizedBox(width: 8),
                      Text(LocalizationService.instance.current.delete_5421),
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
        title: Text(LocalizationService.instance.current.editLegendGroup_4271),
        content: TextField(
          controller: nameController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText:
                LocalizationService.instance.current.legendGroupName_4821,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.current.cancelButton_4271),
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
            child: Text(LocalizationService.instance.current.saveButton_7421),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, LegendGroup legendGroup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          LocalizationService.instance.current.deleteLegendGroup_4271,
        ),
        content: Text(
          LocalizationService.instance.current.confirmDeleteLegendGroup_7281(
            legendGroup.name,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.current.cancelButton_7421),
          ),
          ElevatedButton(
            onPressed: () {
              onLegendGroupDeleted(legendGroup);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(LocalizationService.instance.current.delete_4821),
          ),
        ],
      ),
    );
  }
}
