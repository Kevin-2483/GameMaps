import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../../../models/map_layer.dart';
import '../../../providers/user_preferences_provider.dart';
import '../../../components/color_picker_dialog.dart';
import '../../../utils/image_utils.dart';

/// 优化的绘制工具栏，避免在工具选择时触发主页面的setState
class DrawingToolbarOptimized extends StatefulWidget {
  final DrawingElementType? selectedTool;
  final Color selectedColor;
  final double selectedStrokeWidth;
  final double selectedDensity;
  final double selectedCurvature; // 弧度值
  final TriangleCutType selectedTriangleCut; // 三角形切割类型
  final bool isEditMode;
  final Function(DrawingElementType?) onToolSelected;
  final Function(Color) onColorSelected;
  final Function(double) onStrokeWidthChanged;
  final Function(double) onDensityChanged;
  final Function(double) onCurvatureChanged; // 弧度变化回调
  final Function(TriangleCutType) onTriangleCutChanged; // 三角形切割变化回调
  // 预览回调，用于实时更新画布而不修改实际数据
  final Function(DrawingElementType?)? onToolPreview;
  final Function(Color)? onColorPreview;
  final Function(double)? onStrokeWidthPreview;
  final Function(double)? onDensityPreview;
  final Function(double)? onCurvaturePreview; // 弧度预览回调
  final Function(TriangleCutType)? onTriangleCutPreview; // 三角形切割预览回调
  // 撤销/重做功能
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool canUndo;
  final bool canRedo; // Z层级检视器相关
  final MapLayer? selectedLayer;
  final Function(String elementId)? onElementDeleted;
  final String? selectedElementId; // 当前选中的元素ID
  final Function(String? elementId)? onElementSelected; // 元素选中回调
  final VoidCallback? onZIndexInspectorRequested; // Z层级检视器显示回调

  // 图片缓冲区相关回调
  final Uint8List? imageBufferData; // 当前缓冲区中的图片数据
  final BoxFit imageBufferFit; // 缓冲区图片的适应方式
  final Function(Uint8List imageData)? onImageBufferUpdated; // 缓冲区更新回调
  final Function(BoxFit fit)? onImageBufferFitChanged; // 图片适应方式改变回调
  final VoidCallback? onImageBufferCleared; // 清除缓冲区回调
  const DrawingToolbarOptimized({
    super.key,
    required this.selectedTool,
    required this.selectedColor,
    required this.selectedStrokeWidth,
    required this.selectedDensity,
    required this.selectedCurvature,
    required this.selectedTriangleCut,
    required this.isEditMode,
    required this.onToolSelected,
    required this.onColorSelected,
    required this.onStrokeWidthChanged,
    required this.onDensityChanged,
    required this.onCurvatureChanged,
    required this.onTriangleCutChanged,
    this.onToolPreview,
    this.onColorPreview,
    this.onStrokeWidthPreview,
    this.onDensityPreview,
    this.onCurvaturePreview,
    this.onTriangleCutPreview,
    this.onUndo,
    this.onRedo,
    this.canUndo = false,
    this.canRedo = false,
    this.selectedLayer,
    this.onElementDeleted,
    this.selectedElementId,
    this.onElementSelected,
    this.onZIndexInspectorRequested,
    // 图片缓冲区相关参数
    this.imageBufferData,
    this.imageBufferFit = BoxFit.contain,
    this.onImageBufferUpdated,
    this.onImageBufferFitChanged,
    this.onImageBufferCleared,
  });

  @override
  State<DrawingToolbarOptimized> createState() =>
      _DrawingToolbarOptimizedState();
}

class _DrawingToolbarOptimizedState extends State<DrawingToolbarOptimized> {
  // 临时状态，用于预览
  DrawingElementType? _tempSelectedTool;
  Color? _tempSelectedColor;
  double? _tempSelectedStrokeWidth;
  double? _tempSelectedDensity;
  double? _tempSelectedCurvature; // 临时弧度值
  TriangleCutType? _tempSelectedTriangleCut; // 临时三角形切割值
  // 定时器，用于延迟提交更改
  Timer? _toolTimer;
  Timer? _colorTimer;
  Timer? _strokeWidthTimer;
  Timer? _densityTimer;
  Timer? _curvatureTimer;
  Timer? _triangleCutTimer; // 三角形切割定时器

  @override
  void dispose() {
    _toolTimer?.cancel();
    _colorTimer?.cancel();
    _strokeWidthTimer?.cancel();
    _densityTimer?.cancel();
    _curvatureTimer?.cancel();
    _triangleCutTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(DrawingToolbarOptimized oldWidget) {
    super.didUpdateWidget(oldWidget);
    // didUpdateWidget - 保留方法但移除画布交互逻辑
  }

  // 获取有效的工具选择（临时值或实际值）
  DrawingElementType? get _effectiveTool =>
      _tempSelectedTool ?? widget.selectedTool;
  Color get _effectiveColor => _tempSelectedColor ?? widget.selectedColor;
  double get _effectiveStrokeWidth =>
      _tempSelectedStrokeWidth ?? widget.selectedStrokeWidth;
  double get _effectiveDensity =>
      _tempSelectedDensity ?? widget.selectedDensity;
  double get _effectiveCurvature =>
      _tempSelectedCurvature ?? widget.selectedCurvature;
  TriangleCutType get _effectiveTriangleCut =>
      _tempSelectedTriangleCut ?? widget.selectedTriangleCut;

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

    // 添加到最近使用颜色
    final userPrefs = context.read<UserPreferencesProvider>();
    userPrefs.addRecentColor(color.value);

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

  void _handleDensityChange(double density) {
    setState(() {
      _tempSelectedDensity = density;
    });

    // 立即通知预览（如果提供了回调）
    widget.onDensityPreview?.call(density);

    // 取消之前的定时器
    _densityTimer?.cancel();

    // 设置新的定时器，延迟提交更改
    _densityTimer = Timer(const Duration(milliseconds: 200), () {
      widget.onDensityChanged(density);
      if (mounted) {
        setState(() {
          _tempSelectedDensity = null;
        });
      }
    });
  }

  void _handleCurvatureChange(double curvature) {
    setState(() {
      _tempSelectedCurvature = curvature;
    });

    // 立即通知预览（如果提供了回调）
    widget.onCurvaturePreview?.call(curvature);

    // 取消之前的定时器
    _curvatureTimer?.cancel();

    // 设置新的定时器，延迟提交更改
    _curvatureTimer = Timer(const Duration(milliseconds: 200), () {
      widget.onCurvatureChanged(curvature);
      if (mounted) {
        setState(() {
          _tempSelectedCurvature = null;
        });
      }
    });
  }

  void _handleTriangleCutChange(TriangleCutType triangleCut) {
    setState(() {
      _tempSelectedTriangleCut = triangleCut;
    });

    // 立即通知预览（如果提供了回调）
    widget.onTriangleCutPreview?.call(triangleCut);

    // 取消之前的定时器
    _triangleCutTimer?.cancel();

    // 设置新的定时器，延迟提交更改
    _triangleCutTimer = Timer(const Duration(milliseconds: 200), () {
      widget.onTriangleCutChanged(triangleCut);
      if (mounted) {
        setState(() {
          _tempSelectedTriangleCut = null;
        });
      }
    });
  }

  // 判断是否应该显示密度控制（仅对图案工具显示）
  bool _shouldShowDensityControl() {
    return _effectiveTool != null &&
        [
          DrawingElementType.diagonalLines,
          DrawingElementType.crossLines,
          DrawingElementType.dotGrid,
          DrawingElementType.dashedLine,
        ].contains(_effectiveTool);
  }

  // 判断是否应该显示弧度控制（仅对矩形工具显示）
  bool _shouldShowCurvatureControl() {
    return _effectiveTool != null &&
        [
          DrawingElementType.rectangle,
          DrawingElementType.hollowRectangle,
          DrawingElementType.diagonalLines,
          DrawingElementType.crossLines,
          DrawingElementType.dotGrid,
          DrawingElementType.eraser,
        ].contains(_effectiveTool);
  }

  // 判断是否应该显示三角形切割控制（仅对矩形选区工具显示）
  bool _shouldShowTriangleCutControl() {
    return _effectiveTool != null &&
        [
          DrawingElementType.rectangle,
          DrawingElementType.hollowRectangle,
          DrawingElementType.diagonalLines,
          DrawingElementType.crossLines,
          DrawingElementType.dotGrid,
          DrawingElementType.eraser,
        ].contains(_effectiveTool);
  }

  // 获取三角形切割类型的标签
  String _getTriangleCutLabel(TriangleCutType triangleCut) {
    switch (triangleCut) {
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

  // Helper methods for dynamic tool generation
  DrawingElementType? _getDrawingElementType(String toolName) {
    switch (toolName) {
      case 'line':
        return DrawingElementType.line;
      case 'dashedLine':
        return DrawingElementType.dashedLine;
      case 'arrow':
        return DrawingElementType.arrow;
      case 'rectangle':
        return DrawingElementType.rectangle;
      case 'hollowRectangle':
        return DrawingElementType.hollowRectangle;
      case 'diagonalLines':
        return DrawingElementType.diagonalLines;
      case 'crossLines':
        return DrawingElementType.crossLines;
      case 'dotGrid':
        return DrawingElementType.dotGrid;
      case 'freeDrawing':
        return DrawingElementType.freeDrawing;
      case 'text':
        return DrawingElementType.text;
      case 'eraser':
        return DrawingElementType.eraser;
      case 'imageArea':
        return DrawingElementType.imageArea;
      default:
        return null;
    }
  }

  IconData _getToolIcon(String toolName) {
    switch (toolName) {
      case 'line':
        return Icons.remove;
      case 'dashedLine':
        return Icons.more_horiz;
      case 'arrow':
        return Icons.arrow_forward;
      case 'rectangle':
        return Icons.rectangle;
      case 'hollowRectangle':
        return Icons.rectangle_outlined;
      case 'diagonalLines':
        return Icons.line_style;
      case 'crossLines':
        return Icons.grid_3x3;
      case 'dotGrid':
        return Icons.grid_on;
      case 'freeDrawing':
        return Icons.gesture;
      case 'text':
        return Icons.text_fields;
      case 'eraser':
        return Icons.cleaning_services;
      case 'imageArea':
        return Icons.photo_size_select_actual;
      default:
        return Icons.build;
    }
  }

  String _getToolTooltip(String toolName) {
    switch (toolName) {
      case 'line':
        return '实线';
      case 'dashedLine':
        return '虚线';
      case 'arrow':
        return '箭头';
      case 'rectangle':
        return '实心矩形';
      case 'hollowRectangle':
        return '空心矩形';
      case 'diagonalLines':
        return '单斜线';
      case 'crossLines':
        return '交叉线';
      case 'dotGrid':
        return '点阵';
      case 'freeDrawing':
        return '像素笔';
      case 'text':
        return '文本框';
      case 'eraser':
        return '橡皮擦';
      case 'imageArea':
        return '图片选区';
      default:
        return '工具';
    }
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Consumer<UserPreferencesProvider>(
            builder: (context, userPrefs, child) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: userPrefs.tools.toolbarLayout.map((toolName) {
                  final toolType = _getDrawingElementType(toolName);
                  if (toolType == null) return const SizedBox.shrink();

                  return _buildToolButton(
                    context,
                    icon: _getToolIcon(toolName),
                    tooltip: _getToolTooltip(toolName),
                    tool: toolType,
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),

          // Undo/Redo buttons
          if (widget.onUndo != null || widget.onRedo != null)
            Row(
              children: [
                if (widget.onUndo != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.canUndo ? widget.onUndo : null,
                      icon: const Icon(Icons.undo),
                      label: const Text('撤销'),
                    ),
                  ),
                if (widget.onUndo != null && widget.onRedo != null)
                  const SizedBox(width: 8),
                if (widget.onRedo != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.canRedo ? widget.onRedo : null,
                      icon: const Icon(Icons.redo),
                      label: const Text('重做'),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 16),

          // Recent colors section
          Consumer<UserPreferencesProvider>(
            builder: (context, userPrefs, child) {
              final recentColors = userPrefs.tools.recentColors;
              if (recentColors.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '最近使用',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recentColors.map((colorValue) {
                        final color = Color(colorValue);
                        return _buildColorButton(color);
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Color picker
          const Text(
            '颜色',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
              _buildColorButton(Colors.yellow),
              _buildColorButton(Colors.cyan),
              _buildColorButton(Colors.pink),
              // 更多颜色按钮
              _buildMoreColorsButton(),
            ],
          ),

          // Custom colors section
          Consumer<UserPreferencesProvider>(
            builder: (context, userPrefs, child) {
              final customColors = userPrefs.tools.customColors;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    '自定义颜色',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  if (customColors.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: customColors.map((colorValue) {
                        final color = Color(colorValue);
                        return _buildCustomColorButton(color, userPrefs);
                      }).toList(),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '点击调色盘按钮添加自定义颜色',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Favorite stroke widths section
          Consumer<UserPreferencesProvider>(
            builder: (context, userPrefs, child) {
              final favoriteStrokeWidths = userPrefs.tools.favoriteStrokeWidths;
              if (favoriteStrokeWidths.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '常用线条宽度',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: favoriteStrokeWidths.map((width) {
                        return _buildStrokeWidthButton(width);
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ), // Stroke width
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '线条粗细',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              IconButton(
                onPressed: () => _showStrokeWidthManager(context),
                icon: const Icon(Icons.settings, size: 18),
                tooltip: '管理常用线条宽度',
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _effectiveStrokeWidth,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  label: _effectiveStrokeWidth.round().toString(),
                  onChanged: (value) {
                    _handleStrokeWidthChange(value);
                  },
                ),
              ),
              Text('${_effectiveStrokeWidth.round()}px'),
            ],
          ),
          const SizedBox(height: 8),

          // Pattern density (only show for pattern tools)
          if (_shouldShowDensityControl()) ...[
            const SizedBox(height: 8),
            const Text(
              '图案密度',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _effectiveDensity,
                    min: 1.0,
                    max: 8.0,
                    divisions: 14,
                    label: _effectiveDensity.toStringAsFixed(1),
                    onChanged: _handleDensityChange,
                  ),
                ),
                Text('${_effectiveDensity.toStringAsFixed(1)}x'),
              ],
            ),
          ],

          // Curvature control (for rectangular selections)
          if (_shouldShowCurvatureControl()) ...[
            const SizedBox(height: 8),
            const Text(
              '弧度',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _effectiveCurvature,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    label: '${(_effectiveCurvature * 100).round()}%',
                    onChanged: _handleCurvatureChange,
                  ),
                ),
                Text('${(_effectiveCurvature * 100).round()}%'),
              ],
            ),
          ], // Triangle cut control (for rectangular selections)
          if (_shouldShowTriangleCutControl()) ...[
            const SizedBox(height: 8),
            const Text(
              '对角线切割',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _effectiveTriangleCut.index.toDouble(),
                        min: 0.0,
                        max: 4.0,
                        divisions: 4,
                        label: _getTriangleCutLabel(_effectiveTriangleCut),
                        onChanged: (value) => _handleTriangleCutChange(
                          TriangleCutType.values[value.round()],
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  _getTriangleCutLabel(_effectiveTriangleCut),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],

          // Image Area tool specific controls
          if (_effectiveTool == DrawingElementType.imageArea) ...[
            const SizedBox(height: 16),
            _buildImageAreaControls(),
          ],

          // Clear selection button
          if (_effectiveTool != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _handleToolSelection(null),
                child: const Text('取消选择'),
              ),
            ),

          const SizedBox(height: 16),

          // Z层级检视器按钮
          if (widget.selectedLayer != null &&
              widget.onZIndexInspectorRequested != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onZIndexInspectorRequested,
                icon: const Icon(Icons.layers),
                label: Text(
                  'Z层级检视器 (${widget.selectedLayer!.elements.length})',
                ),
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
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt())
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
                    color: color.withAlpha((0.3 * 255).toInt()),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildCustomColorButton(
    Color color,
    UserPreferencesProvider userPrefs,
  ) {
    final isSelected = _effectiveColor == color;

    return Stack(
      children: [
        InkWell(
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
                        color: color.withAlpha((0.3 * 255).toInt()),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: () => _removeCustomColor(color, userPrefs),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreColorsButton() {
    return InkWell(
      onTap: () => _showAdvancedColorPicker(),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade400,
            width: 2,
            style: BorderStyle.solid,
          ),
          color: Colors.transparent,
        ),
        child: Icon(Icons.palette, size: 16, color: Colors.grey.shade600),
      ),
    );
  }

  void _showAdvancedColorPicker() async {
    final result = await ColorPicker.showColorPickerWithActions(
      context: context,
      initialColor: _effectiveColor,
      title: '高级颜色选择器',
      enableAlpha: true,
    );

    if (result != null && result.action != ColorPickerAction.cancel) {
      final selectedColor = result.color;

      if (result.action == ColorPickerAction.addToCustom) {
        // 添加到自定义颜色
        final userPrefs = context.read<UserPreferencesProvider>();
        try {
          await userPrefs.addCustomColor(selectedColor.value);
          _handleColorSelection(selectedColor);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('颜色已添加到自定义'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            String errorMessage = '添加颜色失败';
            if (e.toString().contains('该颜色已存在')) {
              errorMessage = '该颜色已存在于自定义颜色中';
            } else {
              errorMessage = '添加颜色失败: $e';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.orange,
              ),
            );
          }
          // 即使添加失败，也选择该颜色
          _handleColorSelection(selectedColor);
        }
      } else if (result.action == ColorPickerAction.directUse) {
        // 直接使用颜色
        _handleColorSelection(selectedColor);
      }
    }
  }

  void _removeCustomColor(Color color, UserPreferencesProvider userPrefs) {
    userPrefs.removeCustomColor(color.value);
  }

  void _showStrokeWidthManager(BuildContext context) {
    final userPrefs = context.read<UserPreferencesProvider>();
    final currentWidths = userPrefs.tools.favoriteStrokeWidths;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('管理常用线条宽度'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '当前数量: ${currentWidths.length}/5',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              if (currentWidths.isNotEmpty) ...[
                const Text(
                  '已添加的线条宽度:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: currentWidths.asMap().entries.map((entry) {
                    final index = entry.key;
                    final width = entry.value;
                    return Chip(
                      label: Text('${width.round()}px'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        _removeFavoriteStrokeWidth(userPrefs, index);
                        Navigator.of(context).pop();
                        _showStrokeWidthManager(context); // 重新打开对话框以更新显示
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '还没有添加常用线条宽度',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (currentWidths.length < 5)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showAddStrokeWidthDialog(context, userPrefs);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('添加新的线条宽度'),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '已达到最大数量限制 (5个)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _removeFavoriteStrokeWidth(UserPreferencesProvider provider, int index) {
    final newWidths = List<double>.from(provider.tools.favoriteStrokeWidths);
    newWidths.removeAt(index);
    provider.updateTools(favoriteStrokeWidths: newWidths);
  }

  void _showAddStrokeWidthDialog(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    double newWidth = 1.0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加线条宽度'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('宽度: ${newWidth.round()}px'),
              const SizedBox(height: 16),
              Slider(
                value: newWidth,
                min: 1.0,
                max: 50.0,
                divisions: 49,
                onChanged: (value) => setState(() => newWidth = value),
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
            onPressed: () {
              final currentWidths = provider.tools.favoriteStrokeWidths;
              if (!currentWidths.contains(newWidth)) {
                if (currentWidths.length >= 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('最多只能添加5个常用线条宽度'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                final newWidths = List<double>.from(currentWidths);
                newWidths.add(newWidth);
                newWidths.sort();
                provider.updateTools(favoriteStrokeWidths: newWidths);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已添加线条宽度 ${newWidth.round()}px'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('该线条宽度已存在'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  Widget _buildStrokeWidthButton(double width) {
    final isSelected = _effectiveStrokeWidth == width;

    return InkWell(
      onTap: () => _handleStrokeWidthChange(width),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt())
              : Colors.transparent,
        ),
        child: Text(
          '${width.round()}px',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  /// 构建图片选区工具的专用控制面板
  Widget _buildImageAreaControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图片缓冲区
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade200, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.blue.shade50,
          ),
          child: Column(
            children: [
              // 缓冲区标题
              Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 20,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '图片缓冲区',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 缓冲区内容
              if (widget.imageBufferData != null)
                // 显示已上传的图片
                _buildImageBuffer()
              else
                // 显示上传提示
                _buildImageUploadPrompt(),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // 图片适应方式选择
        if (widget.imageBufferData != null) ...[
          const Text(
            '图片适应方式',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildBoxFitSelector(),
        ],

        const SizedBox(height: 8),

        // 使用说明
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '使用说明',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '1. 点击"上传图片"选择图片文件\n'
                '2. 在画布上拖拽创建选区\n'
                '3. 图片将自动适应选区大小\n'
                '4. 可通过Z层级检视器调整',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建BoxFit选择器
  Widget _buildBoxFitSelector() {
    final boxFitOptions = [
      BoxFit.contain,
      BoxFit.cover,
      BoxFit.fill,
      BoxFit.fitWidth,
      BoxFit.fitHeight,
      BoxFit.none,
      BoxFit.scaleDown,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: boxFitOptions.map((fit) {
        return _buildBoxFitButton(fit);
      }).toList(),
    );
  }

  /// 构建单个BoxFit按钮
  Widget _buildBoxFitButton(BoxFit fit) {
    final isSelected = _getSelectedImageFit() == fit; // 现在这个判断会正确工作

    return InkWell(
      onTap: () => _handleImageFitChange(fit),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt())
              : Colors.transparent,
        ),
        child: Text(
          _getBoxFitDisplayName(fit),
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  /// 获取BoxFit的显示名称
  String _getBoxFitDisplayName(BoxFit fit) {
    switch (fit) {
      case BoxFit.contain:
        return '包含';
      case BoxFit.cover:
        return '覆盖';
      case BoxFit.fill:
        return '填充';
      case BoxFit.fitWidth:
        return '适宽';
      case BoxFit.fitHeight:
        return '适高';
      case BoxFit.none:
        return '原始';
      case BoxFit.scaleDown:
        return '缩小';
    }
  }

  /// 获取当前选中的图片适应方式
  BoxFit _getSelectedImageFit() {
    // 修改：返回当前实际的图片适应方式，而不是固定的默认值
    return widget.imageBufferFit;
  }

  /// 处理图片适应方式改变
  void _handleImageFitChange(BoxFit fit) {
    // 调用回调函数更新缓冲区图片适应方式
    widget.onImageBufferFitChanged?.call(fit);

    // 显示更改提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('图片适应方式已设置为: ${_getBoxFitDisplayName(fit)}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 构建图片缓冲区显示组件（显示已上传的图片）
  Widget _buildImageBuffer() {
    return Column(
      children: [
        // 图片预览
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              widget.imageBufferData!,
              fit: widget.imageBufferFit,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade400,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '图片显示失败',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 操作按钮
        Row(
          children: [
            // 重新上传按钮
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleImageUpload,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('重新上传', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  foregroundColor: Colors.blue.shade600,
                  side: BorderSide(color: Colors.blue.shade300),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 清空缓冲区按钮
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  widget.onImageBufferCleared?.call();
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('清空', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade300),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建图片上传提示组件（缓冲区为空时显示）
  Widget _buildImageUploadPrompt() {
    return Column(
      children: [
        // 上传提示区域
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 32,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                '点击上传图片到缓冲区',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '支持 JPG、PNG、GIF 格式',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 上传按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleImageUpload,
            icon: const Icon(Icons.add_photo_alternate, size: 18),
            label: const Text('上传图片'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 处理图片上传
  Future<void> _handleImageUpload() async {
    try {
      // 显示加载指示器
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('正在选择图片...'),
              ],
            ),
            duration: Duration(seconds: 10),
          ),
        );
      }

      // 使用ImageUtils选择和上传图片
      final imageData = await ImageUtils.pickAndEncodeImage();

      // 清除加载指示器
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      if (imageData != null) {
        // 验证图片数据
        if (!ImageUtils.isValidImageData(imageData)) {
          throw Exception('无效的图片文件，请选择有效的图片');
        }

        // 更新缓冲区
        widget.onImageBufferUpdated?.call(imageData);

        // 显示成功消息
        if (mounted) {
          final sizeInKB = (imageData.length / 1024).toStringAsFixed(1);
          final mimeType = ImageUtils.getImageMimeType(imageData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '图片已上传到缓冲区\n大小: ${sizeInKB}KB${mimeType != null ? ' · 类型: $mimeType' : ''}',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // 用户取消选择
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已取消图片选择'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      // 清除加载指示器
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      if (mounted) {
        String errorMessage = e.toString();
        // 清理错误消息格式
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '图片上传失败',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(errorMessage),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: '重试',
              textColor: Colors.white,
              onPressed: _handleImageUpload,
            ),
          ),
        );
      }
    }
  }
}
