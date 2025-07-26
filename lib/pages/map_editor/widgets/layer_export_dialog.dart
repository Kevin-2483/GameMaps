import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';
import 'map_canvas.dart';

/// 图层导出对话框
class LayerExportDialog extends StatefulWidget {
  final List<MapLayer> layers;
  final Function(String layerId) onExport;
  final MapCanvasState? mapCanvasState;

  const LayerExportDialog({
    super.key,
    required this.layers,
    required this.onExport,
    this.mapCanvasState,
  });

  @override
  State<LayerExportDialog> createState() => _LayerExportDialogState();
}

// 导出项目基类
abstract class ExportItem {
  String get id;
}

// 图层导出项
class LayerExportItem extends ExportItem {
  final MapLayer layer;
  
  LayerExportItem(this.layer);
  
  @override
  String get id => layer.id;
}

// 分割线导出项
class DividerExportItem extends ExportItem {
  final String _id;
  static int _counter = 0;
  
  DividerExportItem() : _id = 'divider_${DateTime.now().millisecondsSinceEpoch}_${++_counter}';
  
  @override
  String get id => _id;
}

// 背景导出项
class BackgroundExportItem extends ExportItem {
  final String _id;
  static int _counter = 0;
  
  BackgroundExportItem() : _id = 'background_${DateTime.now().millisecondsSinceEpoch}_${++_counter}';
  
  @override
  String get id => _id;
}

class _LayerExportDialogState extends State<LayerExportDialog> {
  List<ExportItem> _selectedItems = [];
  ui.Image? _previewImage;
  bool _isGeneratingPreview = false;

  /// 获取选中的图层列表
  List<MapLayer> get _selectedLayers {
    return _selectedItems
        .whereType<LayerExportItem>()
        .map((item) => item.layer)
        .toList();
  }

  /// 生成图层预览图像
  Future<void> _generatePreview() async {
    if (widget.mapCanvasState == null || _selectedLayers.isEmpty) return;

    setState(() {
      _isGeneratingPreview = true;
      _previewImage?.dispose();
      _previewImage = null;
    });

    try {
      // 导出选中的多个图层
      final layerIds = _selectedLayers.map((layer) => layer.id).toList();
      final image = await widget.mapCanvasState!.exportLayers(layerIds, includeBackground: false);
      if (mounted) {
        setState(() {
          _previewImage = image;
          _isGeneratingPreview = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingPreview = false;
        });
      }
      debugPrint('生成预览失败: $e');
    }
  }

  /// 将图层分组为链接组
  List<List<MapLayer>> _groupLinkedLayers() {
    final groups = <List<MapLayer>>[];
    List<MapLayer> currentGroup = [];

    // 先按order排序（数字越小越在上层，显示顺序）
    final sortedLayers = List<MapLayer>.from(widget.layers)
      ..sort((a, b) => a.order.compareTo(b.order));

    for (int i = 0; i < sortedLayers.length; i++) {
      final layer = sortedLayers[i];
      currentGroup.add(layer);

      // 如果当前图层不链接到下一个，或者是最后一个图层，结束当前组
      if (!layer.isLinkedToNext || i == sortedLayers.length - 1) {
        groups.add(List.from(currentGroup));
        currentGroup.clear();
      }
    }

    return groups;
  }

  void _addLayer(MapLayer layer) {
    if (!_selectedItems.any((item) => item is LayerExportItem && item.layer.id == layer.id)) {
      setState(() {
        _selectedItems.add(LayerExportItem(layer));
      });
      _generatePreview();
    }
  }

  void _addLayerGroup(List<MapLayer> group) {
    setState(() {
      // 按order排序，order大的在下
      final sortedGroup = List<MapLayer>.from(group)
        ..sort((a, b) => a.order.compareTo(b.order));
      
      for (final layer in sortedGroup) {
        if (!_selectedItems.any((item) => item is LayerExportItem && item.layer.id == layer.id)) {
          _selectedItems.add(LayerExportItem(layer));
        }
      }
      // 在组的结束处添加分割线
      _selectedItems.add(DividerExportItem());
    });
    _generatePreview();
  }

  void _removeItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
      _generatePreview();
    });
  }

  void _moveItem(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedItems.removeAt(oldIndex);
      _selectedItems.insert(newIndex, item);
      _generatePreview();
    });
  }

  void _addDivider() {
    setState(() {
      _selectedItems.add(DividerExportItem());
    });
  }

  void _addBackground() {
    setState(() {
      _selectedItems.add(BackgroundExportItem());
    });
  }

  @override
  void dispose() {
    _previewImage?.dispose();
    super.dispose();
  }



  /// 计算总项目数（包括组头和子项）
  int _calculateTotalItems(List<List<MapLayer>> layerGroups) {
    int total = 0;
    for (final group in layerGroups) {
      if (group.length > 1) {
        total += 1; // 组标题
        total += group.length; // 组内图层
      } else {
        total += 1; // 单个图层
      }
    }
    return total;
  }

  Widget _buildPreviewCard(ExportItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 序号
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 图标和标题
                Expanded(
                  child: Row(
                    children: [
                      if (item is LayerExportItem) ...[
                        Icon(
                          Icons.layers,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.layer.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else if (item is DividerExportItem) ...[
                        Icon(
                          Icons.horizontal_rule,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '分割线',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ] else if (item is BackgroundExportItem) ...[
                        Icon(
                          Icons.image,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '背景',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            // 详细信息
            if (item is LayerExportItem) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '图层 ID: ${item.layer.id}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '顺序: ${item.layer.order}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (item is DividerExportItem) ...[
              const SizedBox(height: 8),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Theme.of(context).dividerColor,
              ),
            ] else if (item is BackgroundExportItem) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.palette,
                      size: 12,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '背景元素',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedItem(ExportItem item, int index) {
     if (item is LayerExportItem) {
       final layer = item.layer;
       return Container(
         key: ValueKey(item.id),
         margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
         decoration: BoxDecoration(
           border: Border.all(color: Theme.of(context).dividerColor),
           borderRadius: BorderRadius.circular(4),
           color: Theme.of(context).colorScheme.surface,
         ),
        child: Row(
           children: [
             // 删除按钮
             GestureDetector(
               onTap: () => _removeItem(index),
               child: Container(
                 padding: const EdgeInsets.all(2),
                 child: const Icon(Icons.close, size: 14, color: Colors.red),
               ),
             ),
             const SizedBox(width: 6),
             // 可见性图标
             Icon(
               layer.isVisible ? Icons.visibility : Icons.visibility_off,
               size: 14,
               color: layer.isVisible ? Colors.green : Colors.grey,
             ),
             const SizedBox(width: 6),
             // 图层名称和order
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text(
                     layer.name,
                     style: const TextStyle(fontSize: 11),
                     overflow: TextOverflow.ellipsis,
                   ),
                   Text(
                     'Order: ${layer.order}',
                     style: const TextStyle(fontSize: 9, color: Colors.grey),
                   ),
                 ],
               ),
             ),
           ],
         ),
      );
    } else if (item is DividerExportItem) {
       return Container(
         key: ValueKey(item.id),
         margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
         decoration: BoxDecoration(
           border: Border.all(color: Theme.of(context).dividerColor),
           borderRadius: BorderRadius.circular(4),
           color: Theme.of(context).colorScheme.surfaceVariant,
         ),
        child: Row(
          children: [
            // 删除按钮
            GestureDetector(
              onTap: () => _removeItem(index),
              child: Container(
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, size: 14, color: Colors.red),
              ),
            ),
            const SizedBox(width: 6),
            // 分割线图标
             Icon(
               Icons.horizontal_rule,
               size: 14,
               color: Theme.of(context).colorScheme.onSurfaceVariant,
             ),
             const SizedBox(width: 6),
             // 分割线文本
             Expanded(
               child: Text(
                 '分割线',
                 style: TextStyle(
                   fontSize: 11, 
                   fontStyle: FontStyle.italic,
                   color: Theme.of(context).colorScheme.onSurfaceVariant,
                 ),
                 overflow: TextOverflow.ellipsis,
               ),
             ),
          ],
         ),
       );
     } else if (item is BackgroundExportItem) {
       return Container(
         key: ValueKey(item.id),
         margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
         decoration: BoxDecoration(
           border: Border.all(color: Theme.of(context).dividerColor),
           borderRadius: BorderRadius.circular(4),
           color: Theme.of(context).colorScheme.secondaryContainer,
         ),
         child: Row(
           children: [
             // 删除按钮
             GestureDetector(
               onTap: () => _removeItem(index),
               child: Container(
                 padding: const EdgeInsets.all(2),
                 child: const Icon(Icons.close, size: 14, color: Colors.red),
               ),
             ),
             const SizedBox(width: 6),
             // 背景图标
             Icon(
               Icons.image,
               size: 14,
               color: Theme.of(context).colorScheme.onSecondaryContainer,
             ),
             const SizedBox(width: 6),
             // 背景文本
             Expanded(
               child: Text(
                 '背景',
                 style: TextStyle(
                   fontSize: 11,
                   fontWeight: FontWeight.w500,
                   color: Theme.of(context).colorScheme.onSecondaryContainer,
                 ),
                 overflow: TextOverflow.ellipsis,
               ),
             ),
           ],
         ),
       );
     }
     return const SizedBox.shrink();
   }

  Widget _buildAvailableLayerGroupItem(List<List<MapLayer>> layerGroups, int index) {
    int currentIndex = 0;
    
    for (int groupIndex = 0; groupIndex < layerGroups.length; groupIndex++) {
      final group = layerGroups[groupIndex];
      
      // 如果是多图层组，先显示组标题
      if (group.length > 1) {
        if (index == currentIndex) {
          return _buildAvailableLayerGroupHeader(group, groupIndex);
        }
        currentIndex++;
      }
      
      // 显示组内的所有图层
      for (int i = 0; i < group.length; i++) {
        if (index == currentIndex) {
          final layer = group[i];
          return _buildAvailableLayerMenuItem(
            layer,
            isIndented: group.length > 1,
            onTap: () => _addLayer(layer),
          );

        }
        currentIndex++;
      }
    }
    
    return const SizedBox.shrink();
  }

  /// 构建可选图层组头
  Widget _buildAvailableLayerGroupHeader(List<MapLayer> group, int groupIndex) {
    return GestureDetector(
      onTap: () => _addLayerGroup(group),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 0.5, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.add,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '图层组 ${groupIndex + 1} (${group.length} 个图层)',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableLayerMenuItem(
    MapLayer layer, {
    bool isGroup = false,
    bool isIndented = false,
    required VoidCallback onTap,
  }) {
    final isAlreadySelected = _selectedItems.any((item) => item is LayerExportItem && item.layer.id == layer.id);
    
    return GestureDetector(
      onTap: isAlreadySelected ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 0.5),
        padding: EdgeInsets.symmetric(
          horizontal: isIndented ? 24 : 12,
          vertical: 1,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: isAlreadySelected
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                : Colors.transparent,
            border: isAlreadySelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  )
                : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              // 添加按钮
              Icon(
                isAlreadySelected ? Icons.check : Icons.add,
                size: 16,
                color: isAlreadySelected
                    ? Theme.of(context).disabledColor
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              
              // 可见性图标
              Icon(
                layer.isVisible ? Icons.visibility : Icons.visibility_off,
                size: isIndented ? 14 : 16,
                color: isAlreadySelected
                    ? Theme.of(context).disabledColor
                    : layer.isVisible
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).disabledColor,
              ),
              const SizedBox(width: 4),
              
              // 图层信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 图层名称
                    Text(
                      isGroup ? '${layer.name} (组)' : layer.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isAlreadySelected
                            ? Theme.of(context).disabledColor
                            : isIndented
                            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isGroup ? FontWeight.w600 : FontWeight.normal,
                        fontSize: isIndented ? 13 : 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 图层详细信息
                    Row(
                      children: [
                        Text(
                          '透明度: ${(layer.opacity * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isAlreadySelected
                                ? Theme.of(context).disabledColor
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: isIndented ? 11 : 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '元素: ${layer.elements.length}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isAlreadySelected
                                ? Theme.of(context).disabledColor
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: isIndented ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 图层图标
              Icon(
                isGroup ? Icons.layers : Icons.layers_outlined,
                size: isIndented ? 16 : 18,
                color: isAlreadySelected
                    ? Theme.of(context).disabledColor
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    final layerGroups = _groupLinkedLayers();

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.download,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('导出图层为PNG'),
        ],
      ),
      content: SizedBox(
        width: 900,
        height: 500,
        child: Row(
          children: [
            // 左侧：可选择的图层列表
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.layers,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '可选择的图层',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: _calculateTotalItems(layerGroups),
                            itemBuilder: (context, index) {
                              return _buildAvailableLayerGroupItem(layerGroups, index);
                            },
                          ),
                        ),
                        // 分割线
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: Theme.of(context).dividerColor,
                        ),
                        // 常驻按钮区域
                         Container(
                           padding: const EdgeInsets.all(8),
                           child: Column(
                             children: [
                               // 添加全部图层按钮
                               SizedBox(
                                 width: double.infinity,
                                 child: ElevatedButton.icon(
                                   onPressed: () {
                                     setState(() {
                                       for (final group in layerGroups) {
                                         // 按order排序，order大的在下
                                         final sortedGroup = List<MapLayer>.from(group)
                                           ..sort((a, b) => a.order.compareTo(b.order));
                                         
                                         for (final layer in sortedGroup) {
                                           if (!_selectedItems.any((item) => item is LayerExportItem && item.layer.id == layer.id)) {
                                             _selectedItems.add(LayerExportItem(layer));
                                           }
                                         }
                                         // 在组的结束处添加分割线
                                         _selectedItems.add(DividerExportItem());
                                       }
                                       _generatePreview();
                                     });
                                   },
                                   icon: const Icon(Icons.add_box, size: 16),
                                   label: const Text('添加全部图层', style: TextStyle(fontSize: 12)),
                                   style: ElevatedButton.styleFrom(
                                     padding: const EdgeInsets.symmetric(vertical: 8),
                                   ),
                                 ),
                               ),
                               const SizedBox(height: 4),
                               // 添加分割线按钮
                               SizedBox(
                                 width: double.infinity,
                                 child: OutlinedButton.icon(
                                   onPressed: _addDivider,
                                   icon: const Icon(Icons.horizontal_rule, size: 16),
                                   label: const Text('添加分割线', style: TextStyle(fontSize: 12)),
                                   style: OutlinedButton.styleFrom(
                                     padding: const EdgeInsets.symmetric(vertical: 8),
                                   ),
                                 ),
                               ),
                               const SizedBox(height: 4),
                               // 添加背景按钮
                               SizedBox(
                                 width: double.infinity,
                                 child: OutlinedButton.icon(
                                   onPressed: _addBackground,
                                   icon: const Icon(Icons.image, size: 16),
                                   label: const Text('添加背景', style: TextStyle(fontSize: 12)),
                                   style: OutlinedButton.styleFrom(
                                     padding: const EdgeInsets.symmetric(vertical: 8),
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 中间：选中的图层列表
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.list_alt,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '导出列表',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _selectedItems.isEmpty
                          ? const Center(
                              child: Text(
                                '点击左侧加号\n添加图层',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ReorderableListView.builder(
                              padding: const EdgeInsets.all(4),
                              itemCount: _selectedItems.length,
                              onReorder: _moveItem,
                              itemBuilder: (context, index) {
                                final item = _selectedItems[index];
                                return _buildSelectedItem(item, index);
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 右侧：导出预览
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 预览标题
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.preview,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '导出预览',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_selectedItems.length} 项',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 预览内容
                  Expanded(
                    child: _selectedItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.preview_outlined,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '暂无导出项目',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '从左侧添加图层或项目',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _selectedItems.length,
                            itemBuilder: (context, index) {
                              return _buildPreviewCard(_selectedItems[index], index);
                            },
                          ),
                  ),
                ],
              ),
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
           onPressed: _selectedItems.isNotEmpty
               ? () {
                   Navigator.of(context).pop(_selectedLayers);
                 }
               : null,
          child: const Text('导出'),
        ),
      ],
    );
  }
}