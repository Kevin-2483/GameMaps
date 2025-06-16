import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/map_layer.dart';
import '../../../models/sticky_note.dart';
import '../../../components/common/tags_manager.dart';
import '../../../components/color_picker_dialog.dart';
import '../../../providers/user_preferences_provider.dart';

/// Z层级元素检视器 - 显示图层或便签中的绘制元素并支持删除操作
class ZIndexInspector extends StatelessWidget {
  final MapLayer? selectedLayer;
  final StickyNote? selectedStickyNote;
  final Function(String elementId) onElementDeleted; // 删除元素的回调
  final String? selectedElementId; // 当前选中的元素ID
  final Function(String? elementId)? onElementSelected; // 元素选中回调
  final Function(MapDrawingElement element)? onElementUpdated; // 元素更新回调

  const ZIndexInspector({
    super.key,
    this.selectedLayer,
    this.selectedStickyNote,
    required this.onElementDeleted,
    this.selectedElementId,
    this.onElementSelected,
    this.onElementUpdated,
  }) : assert(
         selectedLayer != null || selectedStickyNote != null,
         'Either selectedLayer or selectedStickyNote must be provided',
       );
  @override
  Widget build(BuildContext context) {
    // 获取要显示的元素列表
    List<MapDrawingElement> elements;

    if (selectedStickyNote != null) {
      elements = selectedStickyNote!.elements;
    } else if (selectedLayer != null) {
      elements = selectedLayer!.elements;
    } else {
      elements = [];
    }

    if (elements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '当前${selectedStickyNote != null ? '便签' : '图层'}没有绘制元素',
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
    final sortedElements = List<MapDrawingElement>.from(elements)
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
        _buildDetailRow(
          context,
          '类型',
          _getElementTypeDisplayName(element.type),
        ),
        _buildDetailRow(
          context,
          'Z层级',
          element.zIndex.toString(),
          element: element,
          propertyName: 'zIndex',
        ),
        if (element.text != null && element.text!.isNotEmpty)
          _buildDetailRow(
            context,
            '文本内容',
            element.text!,
            element: element,
            propertyName: 'text',
          ),
        if (element.fontSize != null)
          _buildDetailRow(
            context,
            '字体大小',
            element.fontSize!.toStringAsFixed(1),
            element: element,
            propertyName: 'fontSize',
          ),
        _buildDetailRow(
          context,
          '颜色',
          '#${element.color.value.toRadixString(16).toUpperCase()}',
          element: element,
          propertyName: 'color',
        ),
        _buildDetailRow(
          context,
          '描边宽度',
          element.strokeWidth.toStringAsFixed(1),
          element: element,
          propertyName: 'strokeWidth',
        ),
        if (element.rotation != 0)
          _buildDetailRow(
            context,
            '旋转角度',
            '${element.rotation.toStringAsFixed(1)}°',
            element: element,
            propertyName: 'rotation',
          ),
        if (element.type != DrawingElementType.freeDrawing ||
            element.type != DrawingElementType.text ||
            element.type != DrawingElementType.imageArea ||
            element.type != DrawingElementType.line ||
            element.type != DrawingElementType.dashedLine ||
            element.type != DrawingElementType.arrow)
          _buildDetailRow(
            context,
            '弧度',
            '${element.curvature}',
            element: element,
            propertyName: 'curvature',
          ),
        if (element.type == DrawingElementType.dashedLine ||
            element.type == DrawingElementType.diagonalLines ||
            element.type == DrawingElementType.crossLines ||
            element.type == DrawingElementType.dotGrid)
          _buildDetailRow(
            context,
            '密度',
            '${element.density}',
            element: element,
            propertyName: 'density',
          ),
        if (element.type == DrawingElementType.rectangle ||
            element.type == DrawingElementType.hollowRectangle ||
            element.type == DrawingElementType.diagonalLines ||
            element.type == DrawingElementType.crossLines ||
            element.type == DrawingElementType.dotGrid ||
            element.type == DrawingElementType.eraser)
          _buildDetailRow(
            context,
            '三角分割',
            '${element.triangleCut}',
            element: element,
            propertyName: 'triangleCut',
          ), // 标签管理区域
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        Consumer<UserPreferencesProvider>(
          builder: (context, userPrefsProvider, child) {
            return TagsManager(
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
              suggestedTags: TagsManagerUtils.getSuggestedTagsWithCustomTags(
                userPrefsProvider.isInitialized ? userPrefsProvider : null,
              ),
              tagValidator: TagsManagerUtils.defaultTagValidator,
              enablePreferencesIntegration: true,
              autoSaveCustomTags: true,
            );
          },
        ),
      ],
    );
  }

  /// 构建详细信息行 - 支持编辑
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    MapDrawingElement? element,
    String? propertyName,
  }) {
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
          Expanded(
            child: element != null && propertyName != null
                ? _buildEditableValue(context, element, propertyName, value)
                : Text(value, style: const TextStyle(fontSize: 11)),
          ),
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
    final baseTags = ['重要', '标记', '临时', '完成'];

    switch (type) {
      case DrawingElementType.text:
        return [...baseTags];
      case DrawingElementType.rectangle:
      case DrawingElementType.hollowRectangle:
        return [...baseTags];
      case DrawingElementType.line:
      case DrawingElementType.dashedLine:
        return [...baseTags];
      case DrawingElementType.arrow:
        return [...baseTags];
      case DrawingElementType.freeDrawing:
        return [...baseTags];
      case DrawingElementType.imageArea:
        return [...baseTags];
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

  /// 构建可编辑的属性值
  Widget _buildEditableValue(
    BuildContext context,
    MapDrawingElement element,
    String propertyName,
    String displayValue,
  ) {
    return InkWell(
      onTap: () => _editProperty(context, element, propertyName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(4),
          color: Colors.blue.withOpacity(0.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                displayValue,
                style: const TextStyle(fontSize: 11, color: Colors.blue),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit, size: 12, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  /// 编辑属性
  void _editProperty(
    BuildContext context,
    MapDrawingElement element,
    String propertyName,
  ) {
    switch (propertyName) {
      case 'color':
        _editColor(context, element);
        break;
      case 'zIndex':
        _editZIndex(context, element);
        break;
      case 'text':
        _editText(context, element);
        break;
      case 'fontSize':
        _editFontSize(context, element);
        break;
      case 'strokeWidth':
        _editStrokeWidth(context, element);
        break;
      case 'rotation':
        _editRotation(context, element);
        break;
      case 'curvature':
        _editCurvature(context, element);
        break;
      case 'density':
        _editDensity(context, element);
        break;
      case 'triangleCut':
        _editTriangleCut(context, element);
        break;
    }
  }

  /// 编辑颜色
  void _editColor(BuildContext context, MapDrawingElement element) async {
    final color = await ColorPicker.showColorPicker(
      context: context,
      initialColor: element.color,
      title: '选择颜色',
      enableAlpha: true,
    );

    if (color != null && onElementUpdated != null) {
      final updatedElement = element.copyWith(color: color);
      onElementUpdated!(updatedElement);
    }
  }

  /// 编辑Z层级
  void _editZIndex(BuildContext context, MapDrawingElement element) {
    final controller = TextEditingController(text: element.zIndex.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑Z层级'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Z层级',
            hintText: '输入数字',
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
              final value = int.tryParse(controller.text);
              if (value != null && onElementUpdated != null) {
                final updatedElement = element.copyWith(zIndex: value);
                onElementUpdated!(updatedElement);
              }
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 编辑文本内容
  void _editText(BuildContext context, MapDrawingElement element) {
    final controller = TextEditingController(text: element.text ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑文本内容'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: '文本内容',
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
              if (onElementUpdated != null) {
                final updatedElement = element.copyWith(text: controller.text);
                onElementUpdated!(updatedElement);
              }
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 编辑字体大小
  void _editFontSize(BuildContext context, MapDrawingElement element) {
    final controller = TextEditingController(
      text: element.fontSize?.toString() ?? '14.0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑字体大小'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '字体大小',
            hintText: '输入数字',
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
              final value = double.tryParse(controller.text);
              if (value != null && onElementUpdated != null) {
                final updatedElement = element.copyWith(fontSize: value);
                onElementUpdated!(updatedElement);
              }
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 编辑描边宽度
  void _editStrokeWidth(BuildContext context, MapDrawingElement element) {
    double currentValue = element.strokeWidth;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑描边宽度'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('当前值: ${currentValue.toStringAsFixed(1)}px'),
              const SizedBox(height: 16),
              Slider(
                value: currentValue,
                min: 0.5,
                max: 20.0,
                divisions: 39,
                label: '${currentValue.toStringAsFixed(1)}px',
                onChanged: (value) {
                  setState(() {
                    currentValue = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (onElementUpdated != null) {
                  final updatedElement = element.copyWith(
                    strokeWidth: currentValue,
                  );
                  onElementUpdated!(updatedElement);
                }
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  /// 编辑旋转角度
  void _editRotation(BuildContext context, MapDrawingElement element) {
    double currentValue = element.rotation;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑旋转角度'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('当前值: ${currentValue.toStringAsFixed(1)}°'),
              const SizedBox(height: 16),
              Slider(
                value: currentValue,
                min: -180.0,
                max: 180.0,
                divisions: 360,
                label: '${currentValue.toStringAsFixed(1)}°',
                onChanged: (value) {
                  setState(() {
                    currentValue = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (onElementUpdated != null) {
                  final updatedElement = element.copyWith(
                    rotation: currentValue,
                  );
                  onElementUpdated!(updatedElement);
                }
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  /// 编辑弧度
  void _editCurvature(BuildContext context, MapDrawingElement element) {
    double currentValue = element.curvature;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑弧度'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('当前值: ${(currentValue * 100).round()}%'),
              const SizedBox(height: 16),
              Slider(
                value: currentValue,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                label: '${(currentValue * 100).round()}%',
                onChanged: (value) {
                  setState(() {
                    currentValue = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (onElementUpdated != null) {
                  final updatedElement = element.copyWith(
                    curvature: currentValue,
                  );
                  onElementUpdated!(updatedElement);
                }
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  /// 编辑密度
  void _editDensity(BuildContext context, MapDrawingElement element) {
    double currentValue = element.density;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑密度'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('当前值: ${currentValue.toStringAsFixed(1)}x'),
              const SizedBox(height: 16),
              Slider(
                value: currentValue,
                min: 1.0,
                max: 8.0,
                divisions: 14,
                label: '${currentValue.toStringAsFixed(1)}x',
                onChanged: (value) {
                  setState(() {
                    currentValue = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (onElementUpdated != null) {
                  final updatedElement = element.copyWith(
                    density: currentValue,
                  );
                  onElementUpdated!(updatedElement);
                }
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  /// 编辑三角分割
  void _editTriangleCut(BuildContext context, MapDrawingElement element) {
    TriangleCutType currentValue = element.triangleCut;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择三角分割'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TriangleCutType.values.map((type) {
            return RadioListTile<TriangleCutType>(
              title: Text(_getTriangleCutDisplayName(type)),
              value: type,
              groupValue: currentValue,
              onChanged: (value) {
                if (value != null) {
                  currentValue = value;
                  if (onElementUpdated != null) {
                    final updatedElement = element.copyWith(
                      triangleCut: currentValue,
                    );
                    onElementUpdated!(updatedElement);
                  }
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 获取三角分割类型的显示名称
  String _getTriangleCutDisplayName(TriangleCutType type) {
    switch (type) {
      case TriangleCutType.none:
        return '无切割';
      case TriangleCutType.topLeft:
        return '左上三角';
      case TriangleCutType.topRight:
        return '右上三角';
      case TriangleCutType.bottomRight:
        return '右下三角';
      case TriangleCutType.bottomLeft:
        return '左下三角';
    }
  }
}
