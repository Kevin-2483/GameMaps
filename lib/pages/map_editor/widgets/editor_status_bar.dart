import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';
import '../../../models/sticky_note.dart';

/// 地图编辑器状态栏组件
/// 显示图层数量、图层组数量、便签数量、当前选中的图层、工具等状态信息
class EditorStatusBar extends StatelessWidget {
  final List<MapLayer>? layers;
  final List<StickyNote>? stickyNotes;
  final MapLayer? selectedLayer;
  final List<MapLayer>? selectedLayerGroup;
  final DrawingElementType? selectedDrawingTool;
  final Color? selectedColor;
  final double? selectedStrokeWidth;
  final double? selectedDensity;
  final double? selectedCurvature;
  final TriangleCutType? selectedTriangleCut;
  final bool isCompact;

  const EditorStatusBar({
    super.key,
    this.layers,
    this.stickyNotes,
    this.selectedLayer,
    this.selectedLayerGroup,
    this.selectedDrawingTool,
    this.selectedColor,
    this.selectedStrokeWidth,
    this.selectedDensity,
    this.selectedCurvature,
    this.selectedTriangleCut,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactStatus(context);
    } else {
      return _buildFullStatus(context);
    }
  }

  /// 构建紧凑状态显示（用于标题栏）
  Widget _buildCompactStatus(BuildContext context) {
    final theme = Theme.of(context);
    final statusItems = _getStatusItems();

    if (statusItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算可用宽度，预留空间给窗口控制按钮等
        final availableWidth = constraints.maxWidth - 200; // 预留200px给其他UI元素

        // 根据可用宽度动态调整显示的状态项数量
        int maxItems = statusItems.length;
        if (availableWidth < 600) {
          maxItems = 3; // 空间较小时最多显示3个
        } else if (availableWidth < 800) {
          maxItems = 4; // 中等空间时最多显示4个
        } else if (availableWidth < 1000) {
          maxItems = 5; // 较大空间时最多显示5个
        }
        // 否则显示所有状态项

        final displayItems = statusItems.take(maxItems).toList();

        return IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.7,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...displayItems
                    .map((item) => _buildStatusItem(context, item))
                    .expand((widget) => [widget, const SizedBox(width: 8)])
                    .take(displayItems.length * 2 - 1), // 移除最后一个分隔符
                // 如果有更多项目被隐藏，显示省略号
                if (statusItems.length > maxItems) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.more_horiz,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建完整状态显示
  Widget _buildFullStatus(BuildContext context) {
    final theme = Theme.of(context);
    final statusItems = _getStatusItems();

    if (statusItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '编辑器状态',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: statusItems
                .map((item) => _buildStatusItem(context, item))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// 获取状态项列表（按优先级排序）
  List<StatusItem> _getStatusItems() {
    final highPriorityItems = <StatusItem>[];
    final mediumPriorityItems = <StatusItem>[];
    final lowPriorityItems = <StatusItem>[];

    // 高优先级：当前选中的绘制工具
    if (selectedDrawingTool != null) {
      highPriorityItems.add(
        StatusItem(
          icon: _getToolIcon(selectedDrawingTool!),
          label: '工具',
          value: _getToolName(selectedDrawingTool!),
          color: Colors.red,
        ),
      );
    }

    // 高优先级：工具参数（仅在选择工具时显示）
    if (selectedDrawingTool != null) {
      final params = _getToolParameters();
      if (params.isNotEmpty) {
        highPriorityItems.add(
          StatusItem(
            icon: Icons.tune,
            label: '参数',
            value: params,
            color: Colors.teal,
          ),
        );
      }
    }

    // 中优先级：当前选中的图层
    if (selectedLayer != null) {
      mediumPriorityItems.add(
        StatusItem(
          icon: Icons.check_circle,
          label: '选中图层',
          value: selectedLayer!.name,
          color: Colors.green,
        ),
      );
    }

    // 中优先级：当前选中的图层组
    if (selectedLayerGroup != null && selectedLayerGroup!.isNotEmpty) {
      final layerNames = selectedLayerGroup!
          .map((layer) => layer.name)
          .join(', ');
      mediumPriorityItems.add(
        StatusItem(
          icon: Icons.group_work,
          label: '选中组',
          value: '${selectedLayerGroup!.length}层: $layerNames',
          color: Colors.purple,
        ),
      );
    }

    // 低优先级：图层数量
    if (layers != null && layers!.isNotEmpty) {
      lowPriorityItems.add(
        StatusItem(
          icon: Icons.layers,
          label: '图层',
          value: '${layers!.length}',
          color: Colors.blue,
        ),
      );
    }

    // 低优先级：便签数量
    if (stickyNotes != null && stickyNotes!.isNotEmpty) {
      lowPriorityItems.add(
        StatusItem(
          icon: Icons.sticky_note_2,
          label: '便签',
          value: '${stickyNotes!.length}',
          color: Colors.yellow.shade700,
        ),
      );
    }

    // 低优先级：图层组数量（通过分析图层的groupName计算）
    if (layers != null && layers!.isNotEmpty) {
      final groupNames = <String>{};
      for (final layer in layers!) {
        // 注意：MapLayer可能没有groupName属性，这里先注释掉
        // if (layer.groupName != null && layer.groupName!.isNotEmpty) {
        //   groupNames.add(layer.groupName!);
        // }
      }
      if (groupNames.isNotEmpty) {
        lowPriorityItems.add(
          StatusItem(
            icon: Icons.folder,
            label: '图层组',
            value: '${groupNames.length}',
            color: Colors.orange,
          ),
        );
      }
    }

    // 按优先级合并：高优先级 -> 中优先级 -> 低优先级
    return [...highPriorityItems, ...mediumPriorityItems, ...lowPriorityItems];
  }

  /// 构建单个状态项
  Widget _buildStatusItem(BuildContext context, StatusItem item) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.icon, size: 16, color: item.color),
        const SizedBox(width: 4),
        Text(
          '${item.label}: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        Text(
          item.value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: item.color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// 获取工具图标
  IconData _getToolIcon(DrawingElementType tool) {
    switch (tool) {
      case DrawingElementType.line:
        return Icons.timeline;
      case DrawingElementType.dashedLine:
        return Icons.more_horiz;
      case DrawingElementType.arrow:
        return Icons.arrow_forward;
      case DrawingElementType.rectangle:
        return Icons.crop_square;
      case DrawingElementType.hollowRectangle:
        return Icons.crop_square_outlined;
      case DrawingElementType.diagonalLines:
        return Icons.line_style;
      case DrawingElementType.crossLines:
        return Icons.grid_3x3;
      case DrawingElementType.dotGrid:
        return Icons.grid_on;
      case DrawingElementType.eraser:
        return Icons.cleaning_services;
      case DrawingElementType.freeDrawing:
        return Icons.brush;
      case DrawingElementType.text:
        return Icons.text_fields;
      case DrawingElementType.imageArea:
        return Icons.image;
      default:
        return Icons.edit;
    }
  }

  /// 获取工具名称
  String _getToolName(DrawingElementType tool) {
    switch (tool) {
      case DrawingElementType.line:
        return '实线';
      case DrawingElementType.dashedLine:
        return '虚线';
      case DrawingElementType.arrow:
        return '箭头';
      case DrawingElementType.rectangle:
        return '实心矩形';
      case DrawingElementType.hollowRectangle:
        return '空心矩形';
      case DrawingElementType.diagonalLines:
        return '斜线区域';
      case DrawingElementType.crossLines:
        return '交叉线区域';
      case DrawingElementType.dotGrid:
        return '点阵区域';
      case DrawingElementType.eraser:
        return '橡皮擦';
      case DrawingElementType.freeDrawing:
        return '自由绘制';
      case DrawingElementType.text:
        return '文本';
      case DrawingElementType.imageArea:
        return '图片选区';
      default:
        return '未知工具';
    }
  }

  /// 获取工具参数字符串
  String _getToolParameters() {
    final params = <String>[];

    // 总是显示颜色参数
    if (selectedColor != null) {
      final colorHex =
          '#${selectedColor!.value.toRadixString(16).substring(2).toUpperCase()}';
      params.add('颜色:$colorHex');
    }

    // 总是显示线宽参数
    if (selectedStrokeWidth != null) {
      params.add('线宽:${selectedStrokeWidth!.toStringAsFixed(1)}px');
    }

    // 显示密度参数（根据drawing_toolbar.dart的逻辑）
    if (selectedDrawingTool != null && _shouldShowDensityControl()) {
      if (selectedDensity != null) {
        params.add('密度:${selectedDensity!.toStringAsFixed(1)}');
      }
    }

    // 显示弧度参数（根据drawing_toolbar.dart的逻辑）
    if (selectedDrawingTool != null && _shouldShowCurvatureControl()) {
      if (selectedCurvature != null && selectedCurvature! != 0.0) {
        params.add('弧度:${selectedCurvature!.toStringAsFixed(1)}');
      }
    }

    // 显示切割参数（根据drawing_toolbar.dart的逻辑）
    if (selectedDrawingTool != null && _shouldShowTriangleCutControl()) {
      if (selectedTriangleCut != null &&
          selectedTriangleCut != TriangleCutType.none) {
        params.add('切割:${_getTriangleCutName(selectedTriangleCut!)}');
      }
    }

    final result = params.join(' | ');
    return result;
  }

  /// 获取三角形切割类型名称
  String _getTriangleCutName(TriangleCutType cutType) {
    switch (cutType) {
      case TriangleCutType.none:
        return '无';
      case TriangleCutType.topLeft:
        return '左上';
      case TriangleCutType.topRight:
        return '右上';
      case TriangleCutType.bottomLeft:
        return '左下';
      case TriangleCutType.bottomRight:
        return '右下';
      default:
        return '未知';
    }
  }

  /// 判断是否应该显示密度控制（仅对图案工具显示）
  bool _shouldShowDensityControl() {
    return selectedDrawingTool != null &&
        [
          DrawingElementType.diagonalLines,
          DrawingElementType.crossLines,
          DrawingElementType.dotGrid,
          DrawingElementType.dashedLine,
        ].contains(selectedDrawingTool);
  }

  /// 判断是否应该显示弧度控制（仅对矩形工具显示）
  bool _shouldShowCurvatureControl() {
    return selectedDrawingTool != null &&
        [
          DrawingElementType.rectangle,
          DrawingElementType.hollowRectangle,
          DrawingElementType.diagonalLines,
          DrawingElementType.crossLines,
          DrawingElementType.dotGrid,
          DrawingElementType.eraser,
        ].contains(selectedDrawingTool);
  }

  /// 判断是否应该显示三角形切割控制（仅对矩形选区工具显示）
  bool _shouldShowTriangleCutControl() {
    return selectedDrawingTool != null &&
        [
          DrawingElementType.rectangle,
          DrawingElementType.hollowRectangle,
          DrawingElementType.diagonalLines,
          DrawingElementType.crossLines,
          DrawingElementType.dotGrid,
          DrawingElementType.eraser,
        ].contains(selectedDrawingTool);
  }
}

/// 状态项数据类
class StatusItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const StatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
