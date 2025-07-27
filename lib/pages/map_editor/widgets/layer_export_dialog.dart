import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';
import '../../../models/sticky_note.dart';
import '../../../utils/image_export_utils.dart';
import 'map_canvas.dart';
import '../../../services/notification/notification_service.dart';
import '../../../services/notification/notification_models.dart';
import 'pdf_export_dialog.dart';

/// 图层导出对话框
class LayerExportDialog extends StatefulWidget {
  final List<MapLayer> layers;
  final List<LegendGroup>? legendGroups;
  final List<StickyNote>? stickyNotes;
  final Function(List<ExportItem>) onExport;
  final MapCanvasState? mapCanvasState;

  const LayerExportDialog({
    super.key,
    required this.layers,
    this.legendGroups,
    this.stickyNotes,
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

  DividerExportItem()
    : _id = 'divider_${DateTime.now().millisecondsSinceEpoch}_${++_counter}';

  @override
  String get id => _id;
}

// 背景导出项
class BackgroundExportItem extends ExportItem {
  final String _id;
  static int _counter = 0;

  BackgroundExportItem()
    : _id = 'background_${DateTime.now().millisecondsSinceEpoch}_${++_counter}';

  @override
  String get id => _id;
}

// 图例组导出项
class LegendGroupExportItem extends ExportItem {
  final LegendGroup legendGroup;

  LegendGroupExportItem(this.legendGroup);

  @override
  String get id => legendGroup.id;
}

// 便签导出项
class StickyNoteExportItem extends ExportItem {
  final StickyNote stickyNote;

  StickyNoteExportItem(this.stickyNote);

  @override
  String get id => stickyNote.id;
}

class _LayerExportDialogState extends State<LayerExportDialog> {
  List<ExportItem> _selectedItems = [];
  List<ui.Image?> _previewImages = [];
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
    if (widget.mapCanvasState == null || _selectedItems.isEmpty) {
      setState(() {
        // 清理旧的预览图片
        for (final image in _previewImages) {
          image?.dispose();
        }
        _previewImages.clear();
      });
      return;
    }

    setState(() {
      _isGeneratingPreview = true;
      // 清理旧的预览图片
      for (final image in _previewImages) {
        image?.dispose();
      }
      _previewImages.clear();
    });

    try {
      // 使用新的分组导出功能
      final images = await widget.mapCanvasState!.exportLayerGroups(
        _selectedItems,
      );
      if (mounted) {
        setState(() {
          _previewImages = List.from(images);
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
    setState(() {
      _selectedItems.add(LayerExportItem(layer));
    });
    _generatePreview();
  }

  void _addLayerGroup(List<MapLayer> group) {
    setState(() {
      // 按order排序，order大的在下
      final sortedGroup = List<MapLayer>.from(group)
        ..sort((a, b) => a.order.compareTo(b.order));

      for (final layer in sortedGroup) {
        _selectedItems.add(LayerExportItem(layer));
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
    _generatePreview();
  }

  void _addBackground() {
    setState(() {
      _selectedItems.add(BackgroundExportItem());
    });
    _generatePreview();
  }

  void _addLegendGroup(LegendGroup legendGroup) {
    setState(() {
      _selectedItems.add(LegendGroupExportItem(legendGroup));
    });
    _generatePreview();
  }

  void _addStickyNote(StickyNote stickyNote) {
    setState(() {
      _selectedItems.add(StickyNoteExportItem(stickyNote));
    });
    _generatePreview();
  }

  @override
  void dispose() {
    // 清理所有预览图片
    for (final image in _previewImages) {
      image?.dispose();
    }
    _previewImages.clear();
    super.dispose();
  }

  /// 获取未绑定的图例组
  List<LegendGroup> _getUnboundLegendGroups(List<List<MapLayer>> groups) {
    if (widget.legendGroups == null) return [];

    // 获取所有绑定了图例组的图例组ID
    final Set<String> boundLegendGroupIds = {};
    for (final group in groups) {
      for (final layer in group) {
        boundLegendGroupIds.addAll(layer.legendGroupIds);
      }
    }

    // 返回未绑定的图例组（没有被任何现有图层绑定的图例组）
    return widget.legendGroups!.where((legendGroup) {
      return !boundLegendGroupIds.contains(legendGroup.id);
    }).toList();
  }

  /// 获取绑定到指定图层组的图例组（只返回最后一次出现的）
  List<LegendGroup> _getBoundLegendGroupsForLayerGroup(
    List<MapLayer> layerGroup,
    int groupIndex,
    List<List<MapLayer>> allGroups,
  ) {
    if (widget.legendGroups == null) return [];

    // 获取这个图层组中所有图层绑定的图例组ID
    final Set<String> boundLegendGroupIds = {};
    for (final layer in layerGroup) {
      boundLegendGroupIds.addAll(layer.legendGroupIds);
    }

    // 只返回在当前组是最后一次出现的图例组（即在后续组中不再出现）
    final List<LegendGroup> result = [];
    for (final legendGroup in widget.legendGroups!) {
      if (boundLegendGroupIds.contains(legendGroup.id)) {
        // 检查这个图例组是否在后续的组中还会出现
        bool willAppearLater = false;
        for (int i = groupIndex + 1; i < allGroups.length; i++) {
          final laterGroup = allGroups[i];
          final Set<String> laterGroupLegendIds = {};
          for (final layer in laterGroup) {
            laterGroupLegendIds.addAll(layer.legendGroupIds);
          }
          if (laterGroupLegendIds.contains(legendGroup.id)) {
            willAppearLater = true;
            break;
          }
        }

        // 只有在后续组中不会再出现的情况下才显示（即这是最后一次出现）
        if (!willAppearLater) {
          result.add(legendGroup);
        }
      }
    }

    return result;
  }

  /// 计算总项目数（包括组头和子项）
  int _calculateTotalItems(
    List<List<MapLayer>> layerGroups,
    List<LegendGroup> legendGroups,
  ) {
    int total = 0;

    // 添加未绑定图例组数量
    final unboundLegendGroups = _getUnboundLegendGroups(layerGroups);
    total += unboundLegendGroups.length;

    for (int groupIndex = 0; groupIndex < layerGroups.length; groupIndex++) {
      final group = layerGroups[groupIndex];
      if (group.length > 1) {
        total += 1; // 组标题
        total += group.length; // 组内图层
      } else {
        total += 1; // 单个图层
      }

      // 添加绑定到此组的图例组数量
      final boundLegendGroups = _getBoundLegendGroupsForLayerGroup(
        group,
        groupIndex,
        layerGroups,
      );
      total += boundLegendGroups.length;
    }

    // 添加便签数量
    final stickyNotes = widget.stickyNotes ?? [];
    total += stickyNotes.length;

    return total;
  }

  Widget _buildPreviewImageCard(ui.Image? image, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
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
                Icon(
                  Icons.image,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '导出图片 ${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 图片预览
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: RawImage(
                        image: image,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 32,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '图片生成失败',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            // 图片信息
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.3),
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
                    image != null
                        ? '尺寸: ${image.width} × ${image.height}'
                        : '无效图片',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
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
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3),
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
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withOpacity(0.3),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
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
        key: ValueKey('layer_${index}_${item.id}'),
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
        key: ValueKey('divider_${index}_${item.id}'),
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
        key: ValueKey('background_${index}_${item.id}'),
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
    } else if (item is LegendGroupExportItem) {
      final legendGroup = item.legendGroup;
      return Container(
        key: ValueKey('legend_${index}_${item.id}'),
        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(4),
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withOpacity(0.3),
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
              legendGroup.isVisible ? Icons.visibility : Icons.visibility_off,
              size: 14,
              color: legendGroup.isVisible ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 6),
            // 图例组图标
            Icon(
              Icons.legend_toggle,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            // 图例组名称和信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    legendGroup.name,
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '图例组: ${legendGroup.legendItems.length} 项',
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (item is StickyNoteExportItem) {
      return Container(
        key: ValueKey('sticky_note_${index}_${item.stickyNote.id}'),
        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(4),
          color: Theme.of(
            context,
          ).colorScheme.tertiaryContainer.withOpacity(0.3),
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
            // 便签图标
            Icon(
              Icons.sticky_note_2,
              size: 14,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 6),
            // 可见性图标
            Icon(
              item.stickyNote.isVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              size: 12,
              color: item.stickyNote.isVisible
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).disabledColor,
            ),
            const SizedBox(width: 6),
            // 便签内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.stickyNote.title.isEmpty
                        ? '无标题便签'
                        : item.stickyNote.title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (item.stickyNote.content.isNotEmpty)
                    Text(
                      item.stickyNote.content,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildAvailableLayerGroupItem(
    List<List<MapLayer>> layerGroups,
    int index,
  ) {
    int currentIndex = 0;

    // 首先处理未绑定的图例组
    final unboundLegendGroups = _getUnboundLegendGroups(layerGroups);
    if (index < unboundLegendGroups.length) {
      final legendGroup = unboundLegendGroups[index];
      return _buildAvailableLegendGroupMenuItem(legendGroup);
    }
    currentIndex += unboundLegendGroups.length;

    // 然后处理图层组
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

      // 显示绑定到此组的图例组
      final boundLegendGroups = _getBoundLegendGroupsForLayerGroup(
        group,
        groupIndex,
        layerGroups,
      );
      for (final legendGroup in boundLegendGroups) {
        if (index == currentIndex) {
          return _buildAvailableLegendGroupMenuItem(legendGroup);
        }
        currentIndex++;
      }
    }

    // 最后添加便签
    final stickyNotes = widget.stickyNotes ?? [];
    if (index < currentIndex + stickyNotes.length) {
      final stickyNoteIndex = index - currentIndex;
      final stickyNote = stickyNotes[stickyNoteIndex];
      return _buildAvailableStickyNoteMenuItem(stickyNote);
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
            const Icon(Icons.add, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '图层组 ${groupIndex + 1} (${group.length} 个图层)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 0.5),
        padding: EdgeInsets.symmetric(
          horizontal: isIndented ? 24 : 12,
          vertical: 1,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              // 添加按钮
              Icon(
                Icons.add,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),

              // 可见性图标
              Icon(
                layer.isVisible ? Icons.visibility : Icons.visibility_off,
                size: isIndented ? 14 : 16,
                color: layer.isVisible
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
                        color: isIndented
                            ? Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.8)
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isGroup
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: isIndented ? 13 : 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 图层详细信息
                    Row(
                      children: [
                        Text(
                          '透明度: ${(layer.opacity * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: isIndented ? 11 : 12,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '元素: ${layer.elements.length}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
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
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableStickyNoteMenuItem(StickyNote stickyNote) {
    return GestureDetector(
      onTap: () => _addStickyNote(stickyNote),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              // 添加按钮
              Icon(
                Icons.add,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              // 便签图标
              Icon(
                Icons.sticky_note_2,
                size: 16,
                color: stickyNote.titleBarColor,
              ),
              const SizedBox(width: 4),
              // 便签信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stickyNote.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (stickyNote.content.isNotEmpty)
                      Text(
                        stickyNote.content,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // 可见性指示器
              if (!stickyNote.isVisible)
                Icon(
                  Icons.visibility_off,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableLegendGroupMenuItem(LegendGroup legendGroup) {
    return GestureDetector(
      onTap: () => _addLegendGroup(legendGroup),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 添加按钮
              Icon(
                Icons.add,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),

              // 可见性图标
              Icon(
                legendGroup.isVisible ? Icons.visibility : Icons.visibility_off,
                size: 16,
                color: legendGroup.isVisible
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).disabledColor,
              ),
              const SizedBox(width: 4),

              // 图例组图标
              Icon(
                Icons.legend_toggle,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),

              // 图例组信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 图例组名称
                    Text(
                      legendGroup.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 图例组详细信息
                    Row(
                      children: [
                        Text(
                          '透明度: ${(legendGroup.opacity * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '图例: ${legendGroup.legendItems.length}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
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
          Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
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
                            itemCount: _calculateTotalItems(
                              layerGroups,
                              widget.legendGroups ?? [],
                            ),
                            itemBuilder: (context, index) {
                              return _buildAvailableLayerGroupItem(
                                layerGroups,
                                index,
                              );
                            },
                          ),
                        ),
                        // 分割线
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
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
                                      // 首先添加未绑定的图例组
                                      final unboundLegendGroups =
                                          _getUnboundLegendGroups(layerGroups);
                                      for (final legendGroup
                                          in unboundLegendGroups) {
                                        _selectedItems.add(
                                          LegendGroupExportItem(legendGroup),
                                        );
                                      }

                                      // 然后按顺序添加图层组和绑定的图例组
                                      for (
                                        int groupIndex = 0;
                                        groupIndex < layerGroups.length;
                                        groupIndex++
                                      ) {
                                        final group = layerGroups[groupIndex];

                                        // 按order排序，order大的在下
                                        final sortedGroup =
                                            List<MapLayer>.from(group)..sort(
                                              (a, b) =>
                                                  a.order.compareTo(b.order),
                                            );

                                        for (final layer in sortedGroup) {
                                          _selectedItems.add(
                                            LayerExportItem(layer),
                                          );
                                        }

                                        // 添加绑定到此组的图例组
                                        final boundLegendGroups =
                                            _getBoundLegendGroupsForLayerGroup(
                                              group,
                                              groupIndex,
                                              layerGroups,
                                            );
                                        for (final legendGroup
                                            in boundLegendGroups) {
                                          _selectedItems.add(
                                            LegendGroupExportItem(legendGroup),
                                          );
                                        }

                                        // 在组的结束处添加分割线
                                        _selectedItems.add(DividerExportItem());
                                      }
                                    });
                                    _generatePreview();
                                  },
                                  icon: const Icon(Icons.add_box, size: 16),
                                  label: const Text(
                                    '添加全部图层',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // 添加分割线按钮
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _addDivider,
                                  icon: const Icon(
                                    Icons.horizontal_rule,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    '添加分割线',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
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
                                  label: const Text(
                                    '添加背景',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
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
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
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
                          '${_previewImages.length} 张图片',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '暂无导出项目',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '从左侧添加图层或项目',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _isGeneratingPreview
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('正在生成预览图片...'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _previewImages.length,
                            itemBuilder: (context, index) {
                              return _buildPreviewImageCard(
                                _previewImages[index],
                                index,
                              );
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
              ? () async {
                  // 执行分组导出
                  if (widget.mapCanvasState != null) {
                    const String notificationId = 'image-export-notification';
                    try {
                      // 显示导出进度
                      if (mounted) {
                        NotificationService.instance.show(
                          id: notificationId,
                          message: '正在导出图片...',
                          type: NotificationType.info,
                          isPersistent: true,
                          borderEffect: NotificationBorderEffect.loading,
                        );
                      }

                      final images = await widget.mapCanvasState!
                          .exportLayerGroups(_selectedItems);

                      // 过滤掉空图片
                      final validImages = images
                          .where((img) => img != null)
                          .cast<ui.Image>()
                          .toList();

                      if (validImages.isNotEmpty) {
                        // 使用新的图片导出工具
                        final success = await ImageExportUtils.exportImages(
                          validImages,
                          baseName: 'map_export',
                          format: 'png',
                        );

                        // 更新通知为成功状态
                        if (mounted) {
                          if (success) {
                            NotificationService.instance.updateNotification(
                              notificationId: notificationId,
                              message: '成功导出 ${validImages.length} 张图片',
                              type: NotificationType.success,
                              isPersistent: false,
                              duration: const Duration(seconds: 3),
                              borderEffect: NotificationBorderEffect.none,
                            );
                            Navigator.of(context).pop();
                          } else {
                            NotificationService.instance.updateNotification(
                              notificationId: notificationId,
                              message: '导出失败，请重试',
                              type: NotificationType.success,
                              isPersistent: false,
                              duration: const Duration(seconds: 3),
                              borderEffect: NotificationBorderEffect.none,
                            );
                          }
                        }
                      } else {
                        if (mounted) {
                          context.showErrorSnackBar('没有有效的图片可导出');
                        }
                      }
                    } catch (e) {
                      debugPrint('导出失败: $e');
                      if (mounted) {
                        context.showErrorSnackBar('导出失败: $e');
                      }
                    }
                  }
                }
              : null,
          child: const Text('导出图片'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _selectedItems.isNotEmpty
              ? () async {
                  // 执行PDF导出
                  if (widget.mapCanvasState != null) {
                    try {
                      final images = await widget.mapCanvasState!
                          .exportLayerGroups(_selectedItems);

                      // 过滤掉空图片
                      final validImages = images
                          .where((img) => img != null)
                          .cast<ui.Image>()
                          .toList();

                      if (validImages.isNotEmpty) {
                        // 显示PDF导出配置对话框
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => PdfExportDialog(
                            images: validImages,
                            defaultFileName: 'map_export',
                          ),
                        );
                        
                        if (result == true && mounted) {
                          Navigator.of(context).pop();
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('没有有效的图片可导出')),
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint('获取图片失败: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('获取图片失败: $e')),
                        );
                      }
                    }
                  }
                }
              : null,
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('导出PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }
}
