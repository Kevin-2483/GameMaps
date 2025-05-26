import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';

class LayerPanel extends StatelessWidget {
  final List<MapLayer> layers;
  final MapLayer? selectedLayer;
  final bool isPreviewMode;
  final Function(MapLayer) onLayerSelected;
  final Function(MapLayer) onLayerUpdated;
  final Function(MapLayer) onLayerDeleted;
  final VoidCallback onLayerAdded;
  final Function(int oldIndex, int newIndex) onLayersReordered;

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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图层列表
          Expanded(
            child: layers.isEmpty
                ? const Center(
                    child: Text(
                      '暂无图层',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    itemCount: layers.length,
                    onReorder: onLayersReordered,
                    itemBuilder: (context, index) {
                      final layer = layers[index];
                      return _buildLayerTile(context, layer, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerTile(BuildContext context, MapLayer layer, int index) {
    final isSelected = selectedLayer?.id == layer.id;
    
    return Container(
      key: ValueKey(layer.id),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected 
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isPreviewMode)
              Icon(
                Icons.drag_handle,
                size: 16,
                color: Colors.grey[600],
              ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                layer.isVisible ? Icons.visibility : Icons.visibility_off,
                size: 18,
              ),
              onPressed: () {
                final updatedLayer = layer.copyWith(
                  isVisible: !layer.isVisible,
                  updatedAt: DateTime.now(),
                );
                onLayerUpdated(updatedLayer);
              },
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        title: Text(
          layer.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('不透明度:', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Expanded(
                  child: Slider(
                    value: layer.opacity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    onChanged: isPreviewMode ? null : (opacity) {
                      final updatedLayer = layer.copyWith(
                        opacity: opacity,
                        updatedAt: DateTime.now(),
                      );
                      onLayerUpdated(updatedLayer);
                    },
                  ),
                ),
                Text(
                  '${(layer.opacity * 100).round()}%',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            Text(
              '${layer.elements.length} 个元素',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: isPreviewMode ? null : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (layers.length > 1)
              IconButton(
                icon: const Icon(Icons.delete, size: 16),
                onPressed: () {
                  showDialog(
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
                            onLayerDeleted(layer);
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
        ),
        onTap: () => onLayerSelected(layer),
      ),
    );
  }
}
