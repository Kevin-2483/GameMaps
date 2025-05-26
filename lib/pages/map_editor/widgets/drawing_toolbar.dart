import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';

class DrawingToolbar extends StatelessWidget {
  final DrawingElementType? selectedTool;
  final Color selectedColor;
  final double selectedStrokeWidth;
  final bool isEditMode;
  final Function(DrawingElementType?) onToolSelected;
  final Function(Color) onColorSelected;
  final Function(double) onStrokeWidthChanged;

  const DrawingToolbar({
    super.key,
    required this.selectedTool,
    required this.selectedColor,
    required this.selectedStrokeWidth,
    required this.isEditMode,
    required this.onToolSelected,
    required this.onColorSelected,
    required this.onStrokeWidthChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEditMode) return const SizedBox.shrink();

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
                  value: selectedStrokeWidth,
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  label: selectedStrokeWidth.round().toString(),
                  onChanged: onStrokeWidthChanged,
                ),
              ),
              Text('${selectedStrokeWidth.round()}px'),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Clear selection button
          if (selectedTool != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => onToolSelected(null),
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
    final isSelected = selectedTool == tool;
    
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => onToolSelected(isSelected ? null : tool),
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
    final isSelected = selectedColor == color;
    
    return InkWell(
      onTap: () => onColorSelected(color),
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
