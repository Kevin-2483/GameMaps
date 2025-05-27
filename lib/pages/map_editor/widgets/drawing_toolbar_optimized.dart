import 'package:flutter/material.dart';
import 'dart:async';
import '../../../models/map_layer.dart';

/// 优化的绘制工具栏，避免在工具选择时触发主页面的setState
class DrawingToolbarOptimized extends StatefulWidget {
  final DrawingElementType? selectedTool;
  final Color selectedColor;
  final double selectedStrokeWidth;
  final bool isEditMode;
  final Function(DrawingElementType?) onToolSelected;
  final Function(Color) onColorSelected;
  final Function(double) onStrokeWidthChanged;
  
  // 预览回调，用于实时更新画布而不修改实际数据
  final Function(DrawingElementType?)? onToolPreview;
  final Function(Color)? onColorPreview;
  final Function(double)? onStrokeWidthPreview;

  const DrawingToolbarOptimized({
    super.key,
    required this.selectedTool,
    required this.selectedColor,
    required this.selectedStrokeWidth,
    required this.isEditMode,
    required this.onToolSelected,
    required this.onColorSelected,
    required this.onStrokeWidthChanged,
    this.onToolPreview,
    this.onColorPreview,
    this.onStrokeWidthPreview,
  });

  @override
  State<DrawingToolbarOptimized> createState() => _DrawingToolbarOptimizedState();
}

class _DrawingToolbarOptimizedState extends State<DrawingToolbarOptimized> {
  // 临时状态，用于预览
  DrawingElementType? _tempSelectedTool;
  Color? _tempSelectedColor;
  double? _tempSelectedStrokeWidth;
  
  // 定时器，用于延迟提交更改
  Timer? _toolTimer;
  Timer? _colorTimer;
  Timer? _strokeWidthTimer;

  @override
  void dispose() {
    _toolTimer?.cancel();
    _colorTimer?.cancel();
    _strokeWidthTimer?.cancel();
    super.dispose();
  }

  // 获取有效的工具选择（临时值或实际值）
  DrawingElementType? get _effectiveTool => _tempSelectedTool ?? widget.selectedTool;
  Color get _effectiveColor => _tempSelectedColor ?? widget.selectedColor;
  double get _effectiveStrokeWidth => _tempSelectedStrokeWidth ?? widget.selectedStrokeWidth;

  void _handleToolSelection(DrawingElementType? tool) {
    setState(() {
      _tempSelectedTool = tool;
    });

    // 立即通知预览（如果提供了回调）
    widget.onToolPreview?.call(tool);

    // 取消之前的定时器
    _toolTimer?.cancel();
    
    // 设置新的定时器，延迟提交更改
    _toolTimer = Timer(const Duration(milliseconds: 100), () {
      widget.onToolSelected(tool);
      if (mounted) {
        setState(() {
          _tempSelectedTool = null;
        });
      }
    });
  }

  void _handleColorSelection(Color color) {
    setState(() {
      _tempSelectedColor = color;
    });

    // 立即通知预览（如果提供了回调）
    widget.onColorPreview?.call(color);

    // 取消之前的定时器
    _colorTimer?.cancel();
    
    // 设置新的定时器，延迟提交更改
    _colorTimer = Timer(const Duration(milliseconds: 100), () {
      widget.onColorSelected(color);
      if (mounted) {
        setState(() {
          _tempSelectedColor = null;
        });
      }
    });
  }

  void _handleStrokeWidthChange(double width) {
    setState(() {
      _tempSelectedStrokeWidth = width;
    });

    // 立即通知预览（如果提供了回调）
    widget.onStrokeWidthPreview?.call(width);

    // 取消之前的定时器
    _strokeWidthTimer?.cancel();
    
    // 设置新的定时器，延迟提交更改
    _strokeWidthTimer = Timer(const Duration(milliseconds: 200), () {
      widget.onStrokeWidthChanged(width);
      if (mounted) {
        setState(() {
          _tempSelectedStrokeWidth = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditMode) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drawing tools
          const Text(
            '工具',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildToolButton(
                context,
                icon: Icons.remove,
                tooltip: '实线',
                tool: DrawingElementType.line,
              ),
              _buildToolButton(
                context,
                icon: Icons.more_horiz,
                tooltip: '虚线',
                tool: DrawingElementType.dashedLine,
              ),
              _buildToolButton(
                context,
                icon: Icons.arrow_forward,
                tooltip: '箭头',
                tool: DrawingElementType.arrow,
              ),
              _buildToolButton(
                context,
                icon: Icons.rectangle,
                tooltip: '实心矩形',
                tool: DrawingElementType.rectangle,
              ),
              _buildToolButton(
                context,
                icon: Icons.rectangle_outlined,
                tooltip: '空心矩形',
                tool: DrawingElementType.hollowRectangle,
              ),
              _buildToolButton(
                context,
                icon: Icons.line_style,
                tooltip: '单斜线',
                tool: DrawingElementType.diagonalLines,
              ),
              _buildToolButton(
                context,
                icon: Icons.grid_3x3,
                tooltip: '交叉线',
                tool: DrawingElementType.crossLines,
              ),
              _buildToolButton(
                context,
                icon: Icons.grid_on,
                tooltip: '点阵',
                tool: DrawingElementType.dotGrid,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Color picker
          const Text(
            '颜色',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildColorButton(Colors.black),
              _buildColorButton(Colors.red),
              _buildColorButton(Colors.blue),
              _buildColorButton(Colors.green),
              _buildColorButton(Colors.orange),
              _buildColorButton(Colors.purple),
              _buildColorButton(Colors.brown),
              _buildColorButton(Colors.grey),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stroke width
          const Text(
            '线条粗细',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _effectiveStrokeWidth,
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  label: _effectiveStrokeWidth.round().toString(),
                  onChanged: _handleStrokeWidthChange,
                ),
              ),
              Text('${_effectiveStrokeWidth.round()}px'),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Clear selection button
          if (_effectiveTool != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _handleToolSelection(null),
                child: const Text('取消选择'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required DrawingElementType tool,
  }) {
    final isSelected = _effectiveTool == tool;
    
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => _handleToolSelection(isSelected ? null : tool),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected 
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    final isSelected = _effectiveColor == color;
    
    return InkWell(
      onTap: () => _handleColorSelection(color),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
