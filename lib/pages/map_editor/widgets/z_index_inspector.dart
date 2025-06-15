import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';
import '../../../components/common/tags_manager.dart';

/// Z层级元素检视器 - 显示图层中的绘制元素并支持删除操作
class ZIndexInspector extends StatelessWidget {
  final MapLayer? selectedLayer;
  final Function(String elementId) onElementDeleted; // 删除元素的回调
  final String? selectedElementId; // 当前选中的元素ID
  final Function(String? elementId)? onElementSelected; // 元素选中回调
  final Function(MapDrawingElement element)? onElementUpdated; // 元素更新回调

  const ZIndexInspector({
    super.key,
    required this.selectedLayer,
    required this.onElementDeleted,
    this.selectedElementId,
    this.onElementSelected,
    this.onElementUpdated,
  });
  @override
  Widget build(BuildContext context) {
    if (selectedLayer == null || selectedLayer!.elements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '当前图层没有绘制元素',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withAlpha((0.6 * 255).toInt()),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // 按z值排序，最高的在前面
    final sortedElements = List<MapDrawingElement>.from(selectedLayer!.elements)
      ..sort((a, b) => b.zIndex.compareTo(a.zIndex));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            '元素列表 (${sortedElements.length})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withAlpha((0.7 * 255).toInt()),
            ),
          ),
        ),
        const SizedBox(height: 4),
        ...sortedElements.map((element) => _buildElementItem(context, element)),
      ],
    );
  }

  Widget _buildElementItem(BuildContext context, MapDrawingElement element) {
    final isSelected = selectedElementId == element.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
        color: isSelected
            ? Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt())
            : Theme.of(context).cardColor,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        initiallyExpanded: false,
        onExpansionChanged: (expanded) {
          if (expanded && onElementSelected != null) {
            onElementSelected!(element.id);
          }
        },
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: element.color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Center(
            child: Icon(
              _getElementTypeIcon(element.type),
              size: 14,
              color: _getContrastColor(element.color),
            ),
          ),
        ),
        title: Text(
          _getElementTypeDisplayName(element.type),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Z层级: ${element.zIndex}',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            if (element.text != null && element.text!.isNotEmpty)
              Text(
                '内容: ${element.text!.length > 10 ? element.text!.substring(0, 10) + "..." : element.text!}',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            if (element.type == DrawingElementType.freeDrawing)
              Text(
                '点数: ${element.points.length}',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            // 显示标签预览
            if (element.tags != null && element.tags!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children:
                      element.tags!
                          .take(3)
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          )
                          .toList()
                        ..addAll(
                          element.tags!.length > 3
                              ? [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    child: Text(
                                      '+${element.tags!.length - 3}',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ),
                                ]
                              : [],
                        ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标签管理按钮
            IconButton(
              icon: Icon(
                Icons.label_outline,
                size: 16,
                color: (element.tags != null && element.tags!.isNotEmpty)
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).iconTheme.color,
              ),
              onPressed: () => _showTagsDialog(context, element),
              tooltip: '管理标签',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
            // 删除按钮
            IconButton(
              icon: Icon(
                Icons.delete,
                size: 16,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => _showDeleteConfirmDialog(context, element),
              tooltip: '删除元素',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
        children: [
          // 展开后的详细信息
          _buildElementDetails(context, element),
        ],
      ),
    );
  }

  /// 根据元素类型返回对应的图标
  IconData _getElementTypeIcon(DrawingElementType type) {
    switch (type) {
      case DrawingElementType.line:
        return Icons.remove;
      case DrawingElementType.dashedLine:
        return Icons.line_style;
      case DrawingElementType.arrow:
        return Icons.arrow_forward;
      case DrawingElementType.rectangle:
        return Icons.rectangle;
      case DrawingElementType.hollowRectangle:
        return Icons.rectangle_outlined;
      case DrawingElementType.diagonalLines:
        return Icons.line_style;
      case DrawingElementType.crossLines:
        return Icons.grid_3x3;
      case DrawingElementType.dotGrid:
        return Icons.grid_on;
      case DrawingElementType.freeDrawing:
        return Icons.gesture;
      case DrawingElementType.text:
        return Icons.text_fields;
      case DrawingElementType.eraser:
        return Icons.cleaning_services;
      case DrawingElementType.imageArea:
        return Icons.photo_size_select_actual;
    }
  }

  /// 根据元素类型返回显示名称
  String _getElementTypeDisplayName(DrawingElementType type) {
    switch (type) {
      case DrawingElementType.line:
        return '直线';
      case DrawingElementType.dashedLine:
        return '虚线';
      case DrawingElementType.arrow:
        return '箭头';
      case DrawingElementType.rectangle:
        return '实心矩形';
      case DrawingElementType.hollowRectangle:
        return '空心矩形';
      case DrawingElementType.diagonalLines:
        return '单斜线';
      case DrawingElementType.crossLines:
        return '交叉线';
      case DrawingElementType.dotGrid:
        return '点阵';
      case DrawingElementType.freeDrawing:
        return '像素笔';
      case DrawingElementType.text:
        return '文本';
      case DrawingElementType.eraser:
        return '橡皮擦';
      case DrawingElementType.imageArea:
        return '图片选区';
    }
  }

  /// 根据背景色计算对比色
  Color _getContrastColor(Color backgroundColor) {
    // 计算亮度
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  /// 构建元素详细信息
  Widget _buildElementDetails(BuildContext context, MapDrawingElement element) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 基本信息
        _buildDetailRow('类型', _getElementTypeDisplayName(element.type)),
        _buildDetailRow('Z层级', element.zIndex.toString()),
        if (element.text != null && element.text!.isNotEmpty)
          _buildDetailRow('文本内容', element.text!),
        if (element.fontSize != null)
          _buildDetailRow('字体大小', element.fontSize!.toStringAsFixed(1)),
        _buildDetailRow(
          '颜色',
          '#${element.color.value.toRadixString(16).toUpperCase()}',
        ),
        _buildDetailRow('描边宽度', element.strokeWidth.toStringAsFixed(1)),
        if (element.rotation != 0)
          _buildDetailRow('旋转角度', '${element.rotation.toStringAsFixed(1)}°'),
        if (element.type != DrawingElementType.freeDrawing ||
            element.type != DrawingElementType.text ||
            element.type != DrawingElementType.imageArea ||
            element.type != DrawingElementType.line ||
            element.type != DrawingElementType.dashedLine ||
            element.type != DrawingElementType.arrow)
          _buildDetailRow('弧度', '${element.curvature}'),
        if (element.type == DrawingElementType.dashedLine ||
            element.type == DrawingElementType.diagonalLines ||
            element.type == DrawingElementType.crossLines ||
            element.type == DrawingElementType.dotGrid)
          _buildDetailRow('密度', '${element.density}'),
        if (element.type == DrawingElementType.rectangle ||
            element.type == DrawingElementType.hollowRectangle ||
            element.type == DrawingElementType.diagonalLines ||
            element.type == DrawingElementType.crossLines ||
            element.type == DrawingElementType.dotGrid ||
            element.type == DrawingElementType.eraser)
          _buildDetailRow('三角分割', '${element.triangleCut}'),
        // 标签管理区域
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        TagsManager(
          tags: element.tags ?? [],
          onTagsChanged: (newTags) {
            if (onElementUpdated != null) {
              final updatedElement = element.copyWith(tags: newTags);
              onElementUpdated!(updatedElement);
            }
          },
          title: '元素标签',
          hintText: '为元素添加标签',
          maxTags: 10,
          suggestedTags: _getElementSuggestedTags(element.type),
          tagValidator: TagsManagerUtils.defaultTagValidator,
        ),
      ],
    );
  }

  /// 构建详细信息行
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11))),
        ],
      ),
    );
  }

  /// 显示标签管理对话框
  void _showTagsDialog(BuildContext context, MapDrawingElement element) {
    TagsManagerUtils.showTagsDialog(
      context,
      initialTags: element.tags ?? [],
      title: '管理 ${_getElementTypeDisplayName(element.type)} 标签',
      maxTags: 10,
      suggestedTags: _getElementSuggestedTags(element.type),
      tagValidator: TagsManagerUtils.defaultTagValidator,
    ).then((newTags) {
      if (newTags != null && onElementUpdated != null) {
        final updatedElement = element.copyWith(tags: newTags);
        onElementUpdated!(updatedElement);
      }
    });
  }

  /// 根据元素类型获取建议标签
  List<String> _getElementSuggestedTags(DrawingElementType type) {
    final baseTags = ['重要', '标记', '临时', '完成', '草稿', '审核'];

    switch (type) {
      case DrawingElementType.text:
        return [...baseTags, '标题', '注释', '说明', '备注'];
      case DrawingElementType.rectangle:
      case DrawingElementType.hollowRectangle:
        return [...baseTags, '区域', '框架', '边界', '选择'];
      case DrawingElementType.line:
      case DrawingElementType.dashedLine:
        return [...baseTags, '连接', '分隔', '指示', '路径'];
      case DrawingElementType.arrow:
        return [...baseTags, '指向', '流程', '方向', '引导'];
      case DrawingElementType.freeDrawing:
        return [...baseTags, '手绘', '涂鸦', '标注', '强调'];
      case DrawingElementType.imageArea:
        return [...baseTags, '图片', '媒体', '素材', '参考'];
      default:
        return baseTags;
    }
  }

  /// 显示删除确认对话框
  void _showDeleteConfirmDialog(
    BuildContext context,
    MapDrawingElement element,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text(
          '确定要删除这个${_getElementTypeDisplayName(element.type)}元素吗？\n\n'
          'Z层级: ${element.zIndex}\n'
          '${element.text != null && element.text!.isNotEmpty ? "内容: ${element.text}" : ""}'
          '\n\n此操作可以通过撤销功能恢复。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onElementDeleted(element.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
