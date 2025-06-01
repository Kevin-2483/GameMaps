import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';

/// Z层级元素检视器 - 显示图层中的绘制元素并支持删除操作
class ZIndexInspector extends StatelessWidget {
  final MapLayer? selectedLayer;
  final Function(String elementId) onElementDeleted; // 删除元素的回调
  final String? selectedElementId; // 当前选中的元素ID
  final Function(String? elementId)? onElementSelected; // 元素选中回调

  const ZIndexInspector({
    super.key,
    required this.selectedLayer,
    required this.onElementDeleted,
    this.selectedElementId,
    this.onElementSelected,
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
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 0,
        ),
        onTap: () {
          // 点击选中/取消选中元素
          if (onElementSelected != null) {
            onElementSelected!(isSelected ? null : element.id);
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
          ],
        ),
        trailing: IconButton(
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
