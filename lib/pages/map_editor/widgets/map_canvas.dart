import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../models/map_layer.dart';
import '../../../models/map_item.dart';
import '../../../models/legend_item.dart' as legend_db;
import '../../../utils/image_utils.dart';

// 画布固定尺寸常量，确保坐标转换的一致性
const double kCanvasWidth = 1200.0;
const double kCanvasHeight = 800.0;

/// 绘制预览数据
class DrawingPreviewData {
  final Offset start;
  final Offset end;
  final DrawingElementType elementType;
  final Color color;
  final double strokeWidth;
  final double density;
  final double curvature; // 弧度值
  final List<Offset>? freeDrawingPath; // 自由绘制路径

  const DrawingPreviewData({
    required this.start,
    required this.end,
    required this.elementType,
    required this.color,
    required this.strokeWidth,
    required this.density,
    required this.curvature,
    this.freeDrawingPath,
  });
}

/// 辅助类：用于管理分层元素
class _LayeredElement {
  final int order;
  final bool isSelected;
  final Widget widget;

  const _LayeredElement({
    required this.order,
    required this.isSelected,
    required this.widget,
  });
}

class MapCanvas extends StatefulWidget {
  final MapItem mapItem;
  final MapLayer? selectedLayer;
  final DrawingElementType? selectedDrawingTool;
  final Color selectedColor;
  final double selectedStrokeWidth;
  final double selectedDensity;
  final double selectedCurvature; // 弧度值
  final List<legend_db.LegendItem> availableLegends;
  final bool isPreviewMode;  final Function(MapLayer) onLayerUpdated;
  final Function(LegendGroup) onLegendGroupUpdated;
  final Function(String)? onLegendItemSelected; // 图例项选中回调
  final Function(LegendItem)? onLegendItemDoubleClicked; // 图例项双击回调
  final Map<String, double> previewOpacityValues;
  // 绘制工具预览状态
  final DrawingElementType? previewDrawingTool;
  final Color? previewColor;
  final double? previewStrokeWidth;
  final double? previewDensity;
  final double? previewCurvature; // 弧度预览状态
  
  // 选中元素高亮
  final String? selectedElementId;  const MapCanvas({
    super.key,
    required this.mapItem,
    this.selectedLayer,
    this.selectedDrawingTool,
    required this.selectedColor,
    required this.selectedStrokeWidth,
    required this.selectedDensity,
    required this.selectedCurvature,
    required this.availableLegends,
    required this.isPreviewMode,
    required this.onLayerUpdated,
    required this.onLegendGroupUpdated,
    this.onLegendItemSelected,
    this.onLegendItemDoubleClicked,
    this.previewOpacityValues = const {},
    this.previewDrawingTool,
    this.previewColor,
    this.previewStrokeWidth,
    this.previewDensity,
    this.previewCurvature,
    this.selectedElementId,
  });

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  final TransformationController _transformationController = TransformationController();
  Offset? _currentDrawingStart;
  Offset? _currentDrawingEnd;
  bool _isDrawing = false;
  
  // 自由绘制路径支持
  List<Offset> _freeDrawingPath = [];
  
  // 绘制预览的 ValueNotifier，避免整个 widget 重绘
  final ValueNotifier<DrawingPreviewData?> _drawingPreviewNotifier = ValueNotifier(null);
  // 获取有效的绘制工具状态（预览值或实际值）
  DrawingElementType? get _effectiveDrawingTool => widget.previewDrawingTool ?? widget.selectedDrawingTool;
  Color get _effectiveColor => widget.previewColor ?? widget.selectedColor;
  double get _effectiveStrokeWidth => widget.previewStrokeWidth ?? widget.selectedStrokeWidth;
  double get _effectiveDensity => widget.previewDensity ?? widget.selectedDensity;
  double get _effectiveCurvature => widget.previewCurvature ?? widget.selectedCurvature;
  @override
  void dispose() {
    _transformationController.dispose();
    _drawingPreviewNotifier.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.1,
          maxScale: 5.0,
          constrained: false, // 关键：不约束子组件大小
          child: SizedBox(
            width: kCanvasWidth,
            height: kCanvasHeight,
            child: Stack(
              children: [
                // 画布容器
                Container(
                  width: kCanvasWidth,
                  height: kCanvasHeight,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),                  child: Stack(
                    children: [
                      // 透明背景指示器（棋盘格图案）
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _TransparentBackgroundPainter(),
                        ),
                      ),
                      
                      // 按层级顺序渲染所有元素
                      ..._buildLayeredElements(),
                        // Current drawing preview
                      ValueListenableBuilder<DrawingPreviewData?>(
                        valueListenable: _drawingPreviewNotifier,
                        builder: (context, previewData, child) {
                          if (previewData == null) return const SizedBox.shrink();
                          return CustomPaint(
                            size: const Size(kCanvasWidth, kCanvasHeight),                            painter: _CurrentDrawingPainter(
                              start: previewData.start,
                              end: previewData.end,
                              elementType: previewData.elementType,
                              color: previewData.color,
                              strokeWidth: previewData.strokeWidth,
                              density: previewData.density,
                              curvature: previewData.curvature,
                              freeDrawingPath: previewData.freeDrawingPath,
                              selectedElementId: widget.selectedElementId,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                  // Touch handler for drawing - 覆盖整个画布区域
                if (!widget.isPreviewMode && _effectiveDrawingTool != null)
                  Positioned(
                    left: 0,
                    top: 0,
                    width: kCanvasWidth,
                    height: kCanvasHeight,
                    child: _effectiveDrawingTool == DrawingElementType.text
                        ? GestureDetector(
                            // 文本工具使用点击手势
                            onTapDown: (details) {
                              _currentDrawingStart = _getCanvasPosition(details.localPosition);
                              _showTextInputDialog();
                            },
                            behavior: HitTestBehavior.translucent,
                          )
                        : GestureDetector(
                            // 其他工具使用拖拽手势
                            onPanStart: _onDrawingStart,
                            onPanUpdate: _onDrawingUpdate,
                            onPanEnd: _onDrawingEnd,
                            behavior: HitTestBehavior.translucent,
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildLayerImageWidget(MapLayer layer) {
    if (layer.imageData == null) return const SizedBox.shrink();
    
    // 获取有效透明度（预览值或实际值）
    final effectiveOpacity = widget.previewOpacityValues[layer.id] ?? layer.opacity;
    
    return Positioned.fill(
      child: Opacity(
        opacity: layer.isVisible ? effectiveOpacity : 0.0,        child: ImageUtils.buildImageFromBase64(
          layer.imageData!,
          width: kCanvasWidth,
          height: kCanvasHeight,
          fit: BoxFit.contain,
          opacity: 1.0, // 透明度已经通过Opacity widget控制
        ),
      ),
    );
  }
  Widget _buildLayerWidget(MapLayer layer) {
    // 获取有效透明度（预览值或实际值）
    final effectiveOpacity = widget.previewOpacityValues[layer.id] ?? layer.opacity;
    
    return Positioned.fill(      child: Opacity(
        opacity: layer.isVisible ? effectiveOpacity : 0.0,
        child: CustomPaint(
          size: const Size(kCanvasWidth, kCanvasHeight),
          painter: _LayerPainter(
            layer: layer,
            isEditMode: !widget.isPreviewMode,
            selectedElementId: widget.selectedElementId,
          ),
        ),
      ),
    );
  }
  Widget _buildLegendWidget(LegendGroup legendGroup) {
    if (!legendGroup.isVisible) return const SizedBox.shrink();

    return Positioned.fill(
      child: Opacity(
        opacity: legendGroup.opacity,
        child: Stack(
          children: legendGroup.legendItems.map((item) => _buildLegendSticker(item)).toList(),
        ),
      ),
    );
  }
  Widget _buildLegendSticker(LegendItem item) {
    // 获取对应的图例数据
    final legend = widget.availableLegends.firstWhere(
      (l) => l.id.toString() == item.legendId,
      orElse: () => legend_db.LegendItem(
        title: '未知图例',
        centerX: 0.0,
        centerY: 0.0,
        version: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (!legend.hasImageData) return const SizedBox.shrink();

    // 转换相对坐标到画布坐标
    final canvasPosition = Offset(
      item.position.dx * kCanvasWidth,
      item.position.dy * kCanvasHeight,
    );

    // 计算图例的中心点（基于图例的中心点坐标）
    final imageSize = 60.0 * item.size; // 基础大小60像素
    final centerOffset = Offset(
      imageSize * legend.centerX,
      imageSize * legend.centerY,
    );    return Positioned(
      left: canvasPosition.dx - centerOffset.dx,
      top: canvasPosition.dy - centerOffset.dy,
      child: GestureDetector(
        onPanStart: widget.isPreviewMode ? null : (details) => _onLegendDragStart(item, details),
        onPanUpdate: widget.isPreviewMode ? null : (details) => _onLegendDragUpdate(item, details),
        onPanEnd: widget.isPreviewMode ? null : (details) => _onLegendDragEnd(item, details),
        onTap: () => _onLegendTap(item),
        onDoubleTap: () => _onLegendDoubleTap(item),
        child: Transform.rotate(
          angle: item.rotation * (3.14159 / 180), // 转换为弧度
          child: Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              border: widget.selectedElementId == item.id 
                ? Border.all(color: Colors.blue, width: 2)
                : null,
              borderRadius: BorderRadius.circular(4),
            ),            child: Opacity(
              opacity: item.isVisible ? item.opacity : 0.0,
              child: Stack(
                children: [
                  // 图例图片
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.memory(
                      legend.imageData!,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // 中心点指示器（选中时显示）
                  if (widget.selectedElementId == item.id)
                    Positioned(
                      left: centerOffset.dx - 4,
                      top: centerOffset.dy - 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }  // 图例拖拽相关方法
  LegendItem? _draggingLegendItem;
  Offset? _dragStartOffset; // 记录拖拽开始时的偏移量

  void _onLegendDragStart(LegendItem item, DragStartDetails details) {
    _draggingLegendItem = item;
    
    // 计算拖拽开始时的偏移量（点击位置相对于图例中心的偏移）
    final canvasPosition = _getCanvasPosition(details.localPosition);
    final itemCanvasPosition = Offset(
      item.position.dx * kCanvasWidth,
      item.position.dy * kCanvasHeight,
    );
    
    _dragStartOffset = Offset(
      canvasPosition.dx - itemCanvasPosition.dx,
      canvasPosition.dy - itemCanvasPosition.dy,
    );
    
    setState(() {
      // 触发重绘以显示拖拽状态
    });
  }
  void _onLegendDragUpdate(LegendItem item, DragUpdateDetails details) {
    if (_draggingLegendItem?.id != item.id || _dragStartOffset == null) return;
    
    // 获取当前拖拽位置（不限制在画布范围内，以支持正确的偏移计算）
    final canvasPosition = _getCanvasPosition(details.localPosition);
    final adjustedPosition = Offset(
      canvasPosition.dx - _dragStartOffset!.dx,
      canvasPosition.dy - _dragStartOffset!.dy,
    );
    
    // 转换为相对坐标
    final relativePosition = Offset(
      adjustedPosition.dx / kCanvasWidth,
      adjustedPosition.dy / kCanvasHeight,
    );

    // 在相对坐标系统中限制范围（0.0 到 1.0）
    final clampedPosition = Offset(
      relativePosition.dx.clamp(0.0, 1.0),
      relativePosition.dy.clamp(0.0, 1.0),
    );

    // 更新图例位置
    _updateLegendItemPosition(item, clampedPosition);
  }void _onLegendDragEnd(LegendItem item, DragEndDetails details) {
    _draggingLegendItem = null;
    _dragStartOffset = null; // 清理偏移量
    // 保存更改到撤销历史
    // 这里可以通过回调通知主页面保存状态
  }  void _onLegendTap(LegendItem item) {
    // 选中图例项，高亮显示
    widget.onLegendItemSelected?.call(item.id);
  }

  void _onLegendDoubleTap(LegendItem item) {
    // 双击图例项，触发双击回调
    widget.onLegendItemDoubleClicked?.call(item);
  }

  void _updateLegendItemPosition(LegendItem item, Offset newPosition) {
    // 找到包含此图例项的图例组
    for (final legendGroup in widget.mapItem.legendGroups) {
      final itemIndex = legendGroup.legendItems.indexWhere((li) => li.id == item.id);
      if (itemIndex != -1) {
        final updatedItem = item.copyWith(position: newPosition);
        final updatedItems = List<LegendItem>.from(legendGroup.legendItems);
        updatedItems[itemIndex] = updatedItem;
        
        final updatedGroup = legendGroup.copyWith(
          legendItems: updatedItems,
          updatedAt: DateTime.now(),
        );
        
        widget.onLegendGroupUpdated(updatedGroup);
        break;
      }
    }
  }  void _onDrawingStart(DragStartDetails details) {
    if (widget.isPreviewMode || _effectiveDrawingTool == null) return;

    // 获取相对于画布的坐标，对于绘制操作需要限制在画布范围内
    _currentDrawingStart = _getClampedCanvasPosition(details.localPosition);
    _currentDrawingEnd = _currentDrawingStart;
    _isDrawing = true;
    
    // 初始化自由绘制路径
    if (_effectiveDrawingTool == DrawingElementType.freeDrawing) {
      _freeDrawingPath = [_currentDrawingStart!];
    }
      // 只更新绘制预览，不触发整个 widget 重绘
    _drawingPreviewNotifier.value = DrawingPreviewData(
      start: _currentDrawingStart!,
      end: _currentDrawingEnd!,
      elementType: _effectiveDrawingTool!,
      color: _effectiveColor,
      strokeWidth: _effectiveStrokeWidth,
      density: _effectiveDensity,
      curvature: _effectiveCurvature,
      freeDrawingPath: _effectiveDrawingTool == DrawingElementType.freeDrawing ? _freeDrawingPath : null,
    );
  }  void _onDrawingUpdate(DragUpdateDetails details) {
    if (!_isDrawing) return;

    // 获取相对于画布的坐标，对于绘制操作需要限制在画布范围内
    _currentDrawingEnd = _getClampedCanvasPosition(details.localPosition);    // 自由绘制路径处理
    if (_effectiveDrawingTool == DrawingElementType.freeDrawing) {
      _freeDrawingPath.add(_currentDrawingEnd!);
      // 对于自由绘制，使用路径信息更新预览
      _drawingPreviewNotifier.value = DrawingPreviewData(
        start: _freeDrawingPath.first,
        end: _freeDrawingPath.last,
        elementType: _effectiveDrawingTool!,
        color: _effectiveColor,
        strokeWidth: _effectiveStrokeWidth,
        density: _effectiveDensity,
        curvature: _effectiveCurvature,
        freeDrawingPath: _freeDrawingPath,
      );
      return;
    }
    
    // 只更新绘制预览，不触发整个 widget 重绘
    _drawingPreviewNotifier.value = DrawingPreviewData(
      start: _currentDrawingStart!,
      end: _currentDrawingEnd!,
      elementType: _effectiveDrawingTool!,
      color: _effectiveColor,
      strokeWidth: _effectiveStrokeWidth,
      density: _effectiveDensity,
      curvature: _effectiveCurvature,
      freeDrawingPath: null,
    );
  }
  // 获取相对于画布的正确坐标
  Offset _getCanvasPosition(Offset localPosition) {
    // localPosition 已经是相对于画布容器的坐标
    // 对于绘制操作，需要限制在画布范围内
    // 对于拖拽操作，不应该限制以避免偏移量计算错误
    return localPosition;
  }
  
  // 专门用于绘制操作的坐标获取，会进行边界限制
  Offset _getClampedCanvasPosition(Offset localPosition) {
    final clampedX = localPosition.dx.clamp(0.0, kCanvasWidth);
    final clampedY = localPosition.dy.clamp(0.0, kCanvasHeight);
    return Offset(clampedX, clampedY);
  }void _onDrawingEnd(DragEndDetails details) {
    if (!_isDrawing || _currentDrawingStart == null || _currentDrawingEnd == null || widget.selectedLayer == null) {
      _isDrawing = false;
      _currentDrawingStart = null;
      _currentDrawingEnd = null;
      _drawingPreviewNotifier.value = null; // 清除预览
      return;
    }

    // Convert screen coordinates to normalized coordinates (0.0-1.0)
    // 使用固定的画布尺寸，与绘制时保持一致
    final normalizedStart = Offset(
      _currentDrawingStart!.dx / kCanvasWidth,
      _currentDrawingStart!.dy / kCanvasHeight,
    );
    final normalizedEnd = Offset(
      _currentDrawingEnd!.dx / kCanvasWidth,
      _currentDrawingEnd!.dy / kCanvasHeight,
    );    // 处理橡皮擦功能
    if (_effectiveDrawingTool == DrawingElementType.eraser) {
      _handleEraserAction(normalizedStart, normalizedEnd);    } else if (_effectiveDrawingTool == DrawingElementType.freeDrawing) {
      _handleFreeDrawingEnd();
    } else {
      // 计算新元素的 z 值（比当前最大 z 值大 1）
      final maxZIndex = widget.selectedLayer!.elements.isEmpty 
          ? 0 
          : widget.selectedLayer!.elements.map((e) => e.zIndex).reduce((a, b) => a > b ? a : b);      // Add the drawing element to the selected layer
      final element = MapDrawingElement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _effectiveDrawingTool!,
        points: [normalizedStart, normalizedEnd],
        color: _effectiveColor,
        strokeWidth: _effectiveStrokeWidth,
        density: _effectiveDensity,
        curvature: _effectiveCurvature,
        zIndex: maxZIndex + 1,
        createdAt: DateTime.now(),
      );

      final updatedLayer = widget.selectedLayer!.copyWith(
        elements: [...widget.selectedLayer!.elements, element],
        updatedAt: DateTime.now(),
      );

      widget.onLayerUpdated(updatedLayer);
    }

    // 清理绘制状态，不需要 setState
    _isDrawing = false;
    _currentDrawingStart = null;
    _currentDrawingEnd = null;
    _drawingPreviewNotifier.value = null; // 清除预览
  }  // 处理橡皮擦动作 - 使用 z 值方式
  void _handleEraserAction(Offset normalizedStart, Offset normalizedEnd) {
    // 计算橡皮擦的 z 值（比当前最大 z 值大 1）
    final maxZIndex = widget.selectedLayer!.elements.isEmpty 
        ? 0 
        : widget.selectedLayer!.elements.map((e) => e.zIndex).reduce((a, b) => a > b ? a : b);
    
    // 创建一个橡皮擦元素，用于遮挡下方的绘制元素
    final eraserElement = MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: DrawingElementType.eraser,
      points: [normalizedStart, normalizedEnd],
      color: Colors.transparent, // 橡皮擦本身是透明的
      strokeWidth: 0.0,
      zIndex: maxZIndex + 1,
      createdAt: DateTime.now(),
    );    final updatedLayer = widget.selectedLayer!.copyWith(
      elements: [...widget.selectedLayer!.elements, eraserElement],
      updatedAt: DateTime.now(),
    );

    widget.onLayerUpdated(updatedLayer);
  }

  // 处理自由绘制完成
  void _handleFreeDrawingEnd() {
    if (_freeDrawingPath.isEmpty || widget.selectedLayer == null) return;
    
    // 将路径点转换为标准化坐标
    final normalizedPoints = _freeDrawingPath.map((point) => Offset(
      point.dx / kCanvasWidth,
      point.dy / kCanvasHeight,
    )).toList();
    
    // 计算新元素的 z 值
    final maxZIndex = widget.selectedLayer!.elements.isEmpty 
        ? 0 
        : widget.selectedLayer!.elements.map((e) => e.zIndex).reduce((a, b) => a > b ? a : b);    // 创建自由绘制元素
    final element = MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: DrawingElementType.freeDrawing,
      points: normalizedPoints,
      color: _effectiveColor,
      strokeWidth: _effectiveStrokeWidth,
      density: _effectiveDensity,
      curvature: _effectiveCurvature,
      zIndex: maxZIndex + 1,
      createdAt: DateTime.now(),
    );
    
    final updatedLayer = widget.selectedLayer!.copyWith(
      elements: [...widget.selectedLayer!.elements, element],
      updatedAt: DateTime.now(),
    );
    
    widget.onLayerUpdated(updatedLayer);
    
    // 清空路径
    _freeDrawingPath.clear();
  }
  void _showTextInputDialog() async {
    final textController = TextEditingController();
    final fontSize = ValueNotifier<double>(16.0);
    
    // 保存文本位置，避免在对话框期间被清除
    final textPosition = _currentDrawingStart;
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加文本'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: '文本内容',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<double>(
              valueListenable: fontSize,
              builder: (context, value, child) => Column(
                children: [
                  Text('字体大小: ${value.round()}px'),
                  Slider(
                    value: value,
                    min: 10.0,
                    max: 48.0,
                    divisions: 19,
                    onChanged: (newValue) => fontSize.value = newValue,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                Navigator.of(context).pop({
                  'text': textController.text,
                  'fontSize': fontSize.value,
                });
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
    
    if (result != null && result['text'] != null && textPosition != null) {
      _createTextElement(result['text'], result['fontSize'], textPosition);
    }
    
    // 重置绘制状态
    _isDrawing = false;
    _currentDrawingStart = null;
    _currentDrawingEnd = null;
    _drawingPreviewNotifier.value = null;
  }
  
  void _createTextElement(String text, double fontSize, Offset position) {
    if (widget.selectedLayer == null) return;
    
    final normalizedPosition = Offset(
      position.dx / kCanvasWidth,
      position.dy / kCanvasHeight,
    );
    
    final maxZIndex = widget.selectedLayer!.elements.isEmpty 
        ? 0 
        : widget.selectedLayer!.elements.map((e) => e.zIndex).reduce((a, b) => a > b ? a : b);      final element = MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: DrawingElementType.text,
      points: [normalizedPosition],
      color: _effectiveColor,
      strokeWidth: _effectiveStrokeWidth,
      density: _effectiveDensity,
      curvature: _effectiveCurvature,
      zIndex: maxZIndex + 1,
      text: text,
      fontSize: fontSize,
      createdAt: DateTime.now(),
    );
    
    final updatedLayer = widget.selectedLayer!.copyWith(
      elements: [...widget.selectedLayer!.elements, element],
      updatedAt: DateTime.now(),
    );
    
    widget.onLayerUpdated(updatedLayer);
  }
  
  /// 构建按层级排序的所有元素
  List<Widget> _buildLayeredElements() {
    final List<_LayeredElement> allElements = [];

    // 收集所有图层及其元素
    for (final layer in widget.mapItem.layers) {
      if (!layer.isVisible) continue;

      final isSelectedLayer = widget.selectedLayer?.id == layer.id;
      
      // 添加图层图片（如果有）
      if (layer.imageData != null) {
        allElements.add(_LayeredElement(
          order: layer.order,
          isSelected: isSelectedLayer,
          widget: _buildLayerImageWidget(layer),
        ));
      }
      
      // 添加图层绘制元素
      allElements.add(_LayeredElement(
        order: layer.order,
        isSelected: isSelectedLayer,
        widget: _buildLayerWidget(layer),
      ));
    }

    // 收集所有图例组
    for (final legendGroup in widget.mapItem.legendGroups) {
      if (!legendGroup.isVisible) continue;

      // 计算图例组的层级（基于绑定的最高图层order）
      int legendOrder = -1;
      bool isLegendSelected = false;
      
      for (final layer in widget.mapItem.layers) {
        if (layer.legendGroupIds.contains(legendGroup.id)) {
          legendOrder = math.max(legendOrder, layer.order);
          // 如果任何绑定的图层被选中，图例也被认为是选中的
          if (widget.selectedLayer?.id == layer.id) {
            isLegendSelected = true;
          }
        }
      }
      
      // 如果图例组没有绑定到任何图层，使用默认order
      if (legendOrder == -1) {
        legendOrder = 0;
      }

      allElements.add(_LayeredElement(
        order: legendOrder,
        isSelected: isLegendSelected,
        widget: _buildLegendWidget(legendGroup),
      ));
    }

    // 按order排序，选中的元素排在最后（显示在最上层）
    allElements.sort((a, b) {
      if (a.isSelected && !b.isSelected) return 1;
      if (!a.isSelected && b.isSelected) return -1;
      return a.order.compareTo(b.order);
    });

    return allElements.map((e) => e.widget).toList();
  }
}

class _LayerPainter extends CustomPainter {
  final MapLayer layer;
  final bool isEditMode;
  final String? selectedElementId;

  _LayerPainter({
    required this.layer,
    required this.isEditMode,
    this.selectedElementId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 按 z 值排序元素
    final sortedElements = List<MapDrawingElement>.from(layer.elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    
    // 找到所有橡皮擦元素
    final eraserElements = sortedElements.where((e) => e.type == DrawingElementType.eraser).toList();
    
    // 首先绘制所有常规元素
    for (final element in sortedElements) {
      if (element.type == DrawingElementType.eraser) {
        continue; // 橡皮擦本身不绘制
      }
      
      // 使用裁剪来实现选择性遮挡
      _drawElementWithEraserMask(canvas, element, eraserElements, size);
    }
      // 最后绘制选中元素的彩虹效果，确保它不受任何遮挡
    if (selectedElementId != null) {
      MapDrawingElement? selectedElement;
      try {
        selectedElement = sortedElements.firstWhere((e) => e.id == selectedElementId);
        _drawRainbowHighlight(canvas, selectedElement, size);
      } catch (e) {
        // 如果找不到元素，忽略绘制
      }
    }
  }
    // 根据元素类型直接显示内容
  void _drawRainbowHighlight(Canvas canvas, MapDrawingElement element, Size size) {
    // 首先获取元素的坐标
    if (element.points.isEmpty) return;
    
    // 彩虹色渐变效果（用于填充文本或形状）
    final rainbowColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];
    
    // 获取当前时间以创建动画效果
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    final animOffset = now % 1.0; // 0.0 - 1.0 之间循环变化
    
    // 根据元素类型绘制不同的内容
    switch (element.type) {
      case DrawingElementType.text:
        // 文本元素
        if (element.text == null || element.text!.isEmpty) return;
        
        final position = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );
        
        // 创建彩虹渐变文本
        final textPainter = TextPainter(
          text: TextSpan(
            text: element.text!,
            style: TextStyle(
              fontSize: element.fontSize ?? 16.0,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: rainbowColors,
                  transform: GradientRotation(animOffset * math.pi * 2),
                ).createShader(Rect.fromLTWH(0, 0, 300, 50)),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        textPainter.paint(canvas, position);
        break;
        
      case DrawingElementType.freeDrawing:
        // 自由绘制路径
        if (element.points.length < 2) return;
        
        final path = Path();
        final screenPoints = element.points.map((point) => Offset(
          point.dx * size.width,
          point.dy * size.height,
        )).toList();
        
        path.moveTo(screenPoints[0].dx, screenPoints[0].dy);
        for (int i = 1; i < screenPoints.length; i++) {
          path.lineTo(screenPoints[i].dx, screenPoints[i].dy);
        }
        
        // 彩虹渐变画笔
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = element.strokeWidth + 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..shader = LinearGradient(
            colors: rainbowColors,
            transform: GradientRotation(animOffset * math.pi * 2),
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
        
        canvas.drawPath(path, paint);
        break;
        
      default:
        // 其他基于两点的元素
        if (element.points.length < 2) return;
        
        final start = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );
        
        final end = Offset(
          element.points[1].dx * size.width,
          element.points[1].dy * size.height,
        );
        
        // 彩虹渐变画笔
        final paint = Paint()
          ..strokeWidth = element.strokeWidth + 2
          ..shader = LinearGradient(
            colors: rainbowColors,
            transform: GradientRotation(animOffset * math.pi * 2),
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
        
        // 根据不同的绘制类型绘制不同的形状
        switch (element.type) {
          case DrawingElementType.line:
            paint.style = PaintingStyle.stroke;
            canvas.drawLine(start, end, paint);
            break;
              case DrawingElementType.dashedLine:
            paint.style = PaintingStyle.stroke;
            _drawDashedLine(canvas, start, end, paint, element.density);
            break;
            
          case DrawingElementType.arrow:
            paint.style = PaintingStyle.stroke;
            _drawArrow(canvas, start, end, paint);
            break;
            
          case DrawingElementType.rectangle:
            paint.style = PaintingStyle.fill;
            final rect = Rect.fromPoints(start, end);
            canvas.drawRect(rect, paint);
            break;
            
          case DrawingElementType.hollowRectangle:
            paint.style = PaintingStyle.stroke;
            final rect = Rect.fromPoints(start, end);
            canvas.drawRect(rect, paint);
            break;
              case DrawingElementType.diagonalLines:
            paint.style = PaintingStyle.stroke;
            _drawDiagonalPattern(canvas, start, end, paint, element.density);
            break;
            
          case DrawingElementType.crossLines:
            paint.style = PaintingStyle.stroke;
            _drawCrossPattern(canvas, start, end, paint, element.density);
            break;
            
          case DrawingElementType.dotGrid:
            paint.style = PaintingStyle.fill;
            _drawDotGrid(canvas, start, end, paint, element.density);
            break;
            
          default:
            // 默认绘制一个边框
            paint.style = PaintingStyle.stroke;
            final rect = Rect.fromPoints(start, end);
            canvas.drawRect(rect, paint);
            break;
        }
        break;
    }
  }

  // 使用遮罩绘制元素，实现选择性遮挡
  void _drawElementWithEraserMask(Canvas canvas, MapDrawingElement element, List<MapDrawingElement> eraserElements, Size size) {
    // 找到影响当前元素的橡皮擦（z值更高的）
    final affectingErasers = eraserElements.where((eraser) => eraser.zIndex > element.zIndex).toList();
    
    if (affectingErasers.isEmpty) {
      // 没有橡皮擦影响，直接绘制
      _drawElement(canvas, element, size);
      return;
    }
    
    // 保存canvas状态
    canvas.save();
      // 创建裁剪路径，排除所有橡皮擦区域
      Path clipPath = Path();
    
    // 添加整个画布区域
    clipPath.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // 减去所有影响当前元素的橡皮擦区域
    for (final eraser in affectingErasers) {
      if (eraser.points.length >= 2) {
        // 转换橡皮擦坐标到屏幕坐标
        final eraserStart = Offset(
          eraser.points[0].dx * size.width,
          eraser.points[0].dy * size.height,
        );
        final eraserEnd = Offset(
          eraser.points[1].dx * size.width,
          eraser.points[1].dy * size.height,
        );
        
        final eraserRect = Rect.fromPoints(eraserStart, eraserEnd);
        
        // 检查橡皮擦是否与当前元素重叠
        if (_doesEraserAffectElement(element, eraser, size)) {
          // 从裁剪路径中减去橡皮擦区域
          final eraserPath = Path()..addRect(eraserRect);
          clipPath = Path.combine(PathOperation.difference, clipPath, eraserPath);
        }
      }
    }
    
    // 应用裁剪
    canvas.clipPath(clipPath);
    
    // 绘制元素
    _drawElement(canvas, element, size);
    
    // 恢复canvas状态
    canvas.restore();
  }
    // 检查橡皮擦是否影响元素
  bool _doesEraserAffectElement(MapDrawingElement element, MapDrawingElement eraser, Size size) {
    if (element.points.isEmpty || eraser.points.length < 2) return false;
    
    // 获取橡皮擦矩形
    final eraserStart = Offset(
      eraser.points[0].dx * size.width,
      eraser.points[0].dy * size.height,
    );
    final eraserEnd = Offset(
      eraser.points[1].dx * size.width,
      eraser.points[1].dy * size.height,
    );
    final eraserRect = Rect.fromPoints(eraserStart, eraserEnd);
    
    // 根据元素类型检查重叠
    switch (element.type) {
      case DrawingElementType.text:
        // 文本元素只有一个点，检查这个点是否在橡皮擦区域内
        if (element.points.isNotEmpty) {
          final textPosition = Offset(
            element.points[0].dx * size.width,
            element.points[0].dy * size.height,
          );
          return eraserRect.contains(textPosition);
        }
        return false;
        
      case DrawingElementType.freeDrawing:
        // 自由绘制：检查路径上的任意一点是否与橡皮擦重叠
        for (final point in element.points) {
          final screenPoint = Offset(
            point.dx * size.width,
            point.dy * size.height,
          );
          if (eraserRect.contains(screenPoint)) {
            return true;
          }
        }
        return false;
        
      default:
        // 其他元素类型：使用原来的两点矩形检查方法
        if (element.points.length < 2) return false;
        
        final elementStart = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );
        final elementEnd = Offset(
          element.points[1].dx * size.width,
          element.points[1].dy * size.height,
        );
        final elementRect = Rect.fromPoints(elementStart, elementEnd);
        
        return eraserRect.overlaps(elementRect);
    }
  }
  void _drawElement(Canvas canvas, MapDrawingElement element, Size size) {
    final paint = Paint()
      ..color = element.color
      ..strokeWidth = element.strokeWidth
      ..style = PaintingStyle.stroke;

    // Convert normalized coordinates to screen coordinates
    final points = element.points.map((point) => Offset(
      point.dx * size.width,
      point.dy * size.height,
    )).toList();

    // 特殊处理：文本元素只需要一个点，自由绘制可能有多个点
    if (element.type == DrawingElementType.text) {
      if (points.isEmpty) return;
      _drawText(canvas, element, size);
      return;
    }
    
    if (element.type == DrawingElementType.freeDrawing) {
      if (points.isEmpty) return;
      _drawFreeDrawingPath(canvas, element, paint, size);
      return;
    }

    // 其他绘制类型需要至少两个点
    if (points.length < 2) return;

    final start = points[0];
    final end = points[1];

    switch (element.type) {
      case DrawingElementType.line:
        canvas.drawLine(start, end, paint);
        break;
        case DrawingElementType.dashedLine:
        _drawDashedLine(canvas, start, end, paint, element.density);
        break;
      
      case DrawingElementType.arrow:
        _drawArrow(canvas, start, end, paint);
        break;
        case DrawingElementType.rectangle:
        final rect = Rect.fromPoints(start, end);
        paint.style = PaintingStyle.fill;
        if (element.curvature > 0.0) {
          _drawCurvedRectangle(canvas, rect, paint, element.curvature);
        } else {
          canvas.drawRect(rect, paint);
        }
        break;
      
      case DrawingElementType.hollowRectangle:
        final rect = Rect.fromPoints(start, end);
        paint.style = PaintingStyle.stroke;
        if (element.curvature > 0.0) {
          _drawCurvedRectangle(canvas, rect, paint, element.curvature);
        } else {
          canvas.drawRect(rect, paint);
        }
        break;
        case DrawingElementType.diagonalLines:
        if (element.curvature > 0.0) {
          final rect = Rect.fromPoints(start, end);
          _drawCurvedDiagonalPattern(canvas, rect, paint, element.density, element.curvature);
        } else {
          _drawDiagonalPattern(canvas, start, end, paint, element.density);
        }
        break;
      
      case DrawingElementType.crossLines:
        if (element.curvature > 0.0) {
          final rect = Rect.fromPoints(start, end);
          _drawCurvedCrossPattern(canvas, rect, paint, element.density, element.curvature);
        } else {
          _drawCrossPattern(canvas, start, end, paint, element.density);
        }
        break;

      case DrawingElementType.dotGrid:
        if (element.curvature > 0.0) {
          final rect = Rect.fromPoints(start, end);
          _drawCurvedDotGrid(canvas, rect, paint, element.density, element.curvature);
        } else {
          _drawDotGrid(canvas, start, end, paint, element.density);
        }
        break;
      
      case DrawingElementType.freeDrawing:
        // 已在上面处理
        break;
        
      case DrawingElementType.text:
        // 已在上面处理
        break;
      
      case DrawingElementType.eraser:
        // 橡皮擦不需要绘制，它只是删除元素
        break;
    }
  }
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, double density) {
    final dashWidth = paint.strokeWidth * density * 0.8; // 虚线长度基于密度
    final dashSpace = paint.strokeWidth * density * 0.4; // 间隔基于密度
    
    final distance = (end - start).distance;
    if (distance == 0) return;
    
    final direction = (end - start) / distance;
    
    double currentDistance = 0;
    bool isDash = true;
    
    while (currentDistance < distance) {
      final segmentLength = isDash ? dashWidth : dashSpace;
      final segmentEnd = currentDistance + segmentLength > distance 
          ? distance 
          : currentDistance + segmentLength;
      
      if (isDash) {
        final segmentStart = start + direction * currentDistance;
        final segmentEndPoint = start + direction * segmentEnd;
        canvas.drawLine(segmentStart, segmentEndPoint, paint);
      }
      
      currentDistance = segmentEnd;
      isDash = !isDash;
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    // Draw main line
    canvas.drawLine(start, end, paint);
    
    // Draw arrowhead
    const arrowLength = 10.0;
    const arrowAngle = 0.5;
    
    final direction = (end - start).direction;
    final arrowPoint1 = end + Offset(
      arrowLength * -1 * math.cos(direction - arrowAngle),
      arrowLength * -1 * math.sin(direction - arrowAngle),
    );
    final arrowPoint2 = end + Offset(
      arrowLength * -1 * math.cos(direction + arrowAngle),
      arrowLength * -1 * math.sin(direction + arrowAngle),
    );
    
    canvas.drawLine(end, arrowPoint1, paint);
    canvas.drawLine(end, arrowPoint2, paint);
  }  void _drawDiagonalPattern(Canvas canvas, Offset start, Offset end, Paint paint, double density) {
    final rect = Rect.fromPoints(start, end);
    final spacing = paint.strokeWidth * density;
    
    final width = rect.width;
    final height = rect.height;
    
    // 计算需要的线条数量：覆盖从左上到右下的所有45度平行线
    final int totalLines = ((width + height) / spacing).ceil();
    
    for (int i = 0; i < totalLines; i++) {
      final double offset = i * spacing;
      
      Offset lineStart;
      Offset lineEnd;
      
      if (offset <= width) {
        // 起点在顶边界上（从左上角往右推进）
        lineStart = Offset(rect.left + offset, rect.top);
      } else {
        // 起点在右边界上（从右上角往下推进）
        lineStart = Offset(rect.right, rect.top + (offset - width));
      }
      
      if (offset <= height) {
        // 终点在左边界上（从左上角往下推进）
        lineEnd = Offset(rect.left, rect.top + offset);
      } else {
        // 终点在底边界上（从左下角往右推进）
        lineEnd = Offset(rect.left + (offset - height), rect.bottom);
      }
      
      canvas.drawLine(lineStart, lineEnd, paint);
    }
  }
  void _drawCrossPattern(Canvas canvas, Offset start, Offset end, Paint paint, double density) {
    final rect = Rect.fromPoints(start, end);
    final spacing = paint.strokeWidth * density;
    
    // Vertical lines
    for (double x = rect.left; x <= rect.right; x += spacing) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
    }
    
    // Horizontal lines
    for (double y = rect.top; y <= rect.bottom; y += spacing) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }
  }
  void _drawDotGrid(Canvas canvas, Offset start, Offset end, Paint paint, double density) {
    final rect = Rect.fromPoints(start, end);
    final spacing = paint.strokeWidth * density;
    final dotRadius = paint.strokeWidth * 0.5; // 点的半径基于线宽
    
    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    
    for (double x = rect.left; x <= rect.right; x += spacing) {
      for (double y = rect.top; y <= rect.bottom; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }

  void _drawFreeDrawingPath(Canvas canvas, MapDrawingElement element, Paint paint, Size size) {
    if (element.points.length < 2) return;
    
    final path = Path();
    final screenPoints = element.points.map((point) => Offset(
      point.dx * size.width,
      point.dy * size.height,
    )).toList();
    
    path.moveTo(screenPoints[0].dx, screenPoints[0].dy);
    for (int i = 1; i < screenPoints.length; i++) {
      path.lineTo(screenPoints[i].dx, screenPoints[i].dy);
    }
    
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }
  
  void _drawText(Canvas canvas, MapDrawingElement element, Size size) {
    if (element.text == null || element.text!.isEmpty || element.points.isEmpty) return;
    
    final position = Offset(
      element.points[0].dx * size.width,
      element.points[0].dy * size.height,
    );
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: element.text!,
        style: TextStyle(
          color: element.color,
          fontSize: element.fontSize ?? 16.0,
          fontWeight: FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  /// 绘制弧度矩形（超椭圆形状）
  void _drawCurvedRectangle(Canvas canvas, Rect rect, Paint paint, double curvature) {
    if (curvature <= 0.0) {
      canvas.drawRect(rect, paint);
      return;
    }
    
    // 限制弧度值在合理范围内 (0.0 到 1.0)
    final clampedCurvature = curvature.clamp(0.0, 1.0);
    
    // 计算超椭圆参数
    // curvature = 0.0 -> n = 2 (椭圆)
    // curvature = 0.5 -> n = 4 (接近圆角矩形)
    // curvature = 1.0 -> n = 8 (非常尖锐的角)
    final n = 2.0 + (clampedCurvature * 6.0);
    
    final centerX = rect.center.dx;
    final centerY = rect.center.dy;
    final a = rect.width / 2; // 半宽
    final b = rect.height / 2; // 半高
    
    // 如果矩形太小，直接绘制普通矩形
    if (a < 2 || b < 2) {
      canvas.drawRect(rect, paint);
      return;
    }
    
    final path = Path();
    const int numPoints = 100; // 用于绘制曲线的点数
    
    bool isFirstPoint = true;
    
    for (int i = 0; i <= numPoints; i++) {
      final t = (i / numPoints) * 2 * math.pi;
      
      // 超椭圆参数方程
      // x = a * sign(cos(t)) * |cos(t)|^(2/n)
      // y = b * sign(sin(t)) * |sin(t)|^(2/n)
      final cosT = math.cos(t);
      final sinT = math.sin(t);
      
      final signCos = cosT >= 0 ? 1.0 : -1.0;
      final signSin = sinT >= 0 ? 1.0 : -1.0;
      
      final x = centerX + a * signCos * math.pow(cosT.abs(), 2.0 / n);
      final y = centerY + b * signSin * math.pow(sinT.abs(), 2.0 / n);
      
      if (isFirstPoint) {
        path.moveTo(x, y);
        isFirstPoint = false;
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  /// 绘制弧度对角线图案
  void _drawCurvedDiagonalPattern(Canvas canvas, Rect rect, Paint paint, double density, double curvature) {
    // 创建超椭圆路径作为裁剪区域
    final clipPath = _createSuperellipsePath(rect, curvature);
    
    // 保存画布状态
    canvas.save();
    canvas.clipPath(clipPath);
    
    // 在裁剪区域内绘制对角线图案
    final spacing = paint.strokeWidth * density;
    final width = rect.width;
    final height = rect.height;
    
    final int totalLines = ((width + height) / spacing).ceil();
    
    for (int i = 0; i < totalLines; i++) {
      final double offset = i * spacing;
      
      Offset lineStart;
      Offset lineEnd;
      
      if (offset <= width) {
        lineStart = Offset(rect.left + offset, rect.top);
      } else {
        lineStart = Offset(rect.right, rect.top + (offset - width));
      }
      
      if (offset <= height) {
        lineEnd = Offset(rect.left, rect.top + offset);
      } else {
        lineEnd = Offset(rect.left + (offset - height), rect.bottom);
      }
      
      canvas.drawLine(lineStart, lineEnd, paint);
    }
    
    // 恢复画布状态
    canvas.restore();
  }

  /// 绘制弧度十字线图案
  void _drawCurvedCrossPattern(Canvas canvas, Rect rect, Paint paint, double density, double curvature) {
    // 创建超椭圆路径作为裁剪区域
    final clipPath = _createSuperellipsePath(rect, curvature);
    
    // 保存画布状态
    canvas.save();
    canvas.clipPath(clipPath);
    
    // 在裁剪区域内绘制十字线图案
    final spacing = paint.strokeWidth * density;
    
    // 垂直线
    for (double x = rect.left; x <= rect.right; x += spacing) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
    }
    
    // 水平线
    for (double y = rect.top; y <= rect.bottom; y += spacing) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }
    
    // 恢复画布状态
    canvas.restore();
  }

  /// 绘制弧度点网格图案
  void _drawCurvedDotGrid(Canvas canvas, Rect rect, Paint paint, double density, double curvature) {
    // 创建超椭圆路径作为裁剪区域
    final clipPath = _createSuperellipsePath(rect, curvature);
    
    // 保存画布状态
    canvas.save();
    canvas.clipPath(clipPath);
    
    // 在裁剪区域内绘制点网格
    final spacing = paint.strokeWidth * density;
    final dotRadius = paint.strokeWidth * 0.5;
    
    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    
    for (double x = rect.left; x <= rect.right; x += spacing) {
      for (double y = rect.top; y <= rect.bottom; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
    
    // 恢复画布状态
    canvas.restore();
  }

  /// 创建超椭圆路径
  Path _createSuperellipsePath(Rect rect, double curvature) {
    if (curvature <= 0.0) {
      return Path()..addRect(rect);
    }
    
    // 限制弧度值在合理范围内 (0.0 到 1.0)
    final clampedCurvature = curvature.clamp(0.0, 1.0);
    
    // 计算超椭圆参数
    final n = 2.0 + (clampedCurvature * 6.0);
    
    final centerX = rect.center.dx;
    final centerY = rect.center.dy;
    final a = rect.width / 2;
    final b = rect.height / 2;
    
    if (a < 2 || b < 2) {
      return Path()..addRect(rect);
    }
    
    final path = Path();
    const int numPoints = 100;
    
    bool isFirstPoint = true;
    
    for (int i = 0; i <= numPoints; i++) {
      final t = (i / numPoints) * 2 * math.pi;
      
      final cosT = math.cos(t);
      final sinT = math.sin(t);
      
      final signCos = cosT >= 0 ? 1.0 : -1.0;
      final signSin = sinT >= 0 ? 1.0 : -1.0;
      
      final x = centerX + a * signCos * math.pow(cosT.abs(), 2.0 / n);
      final y = centerY + b * signSin * math.pow(sinT.abs(), 2.0 / n);
      
      if (isFirstPoint) {
        path.moveTo(x, y);
        isFirstPoint = false;
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CurrentDrawingPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final DrawingElementType elementType;
  final Color color;
  final double strokeWidth;
  final double density;
  final double curvature; // 曲率参数
  final List<Offset>? freeDrawingPath; // 自由绘制路径
  final String? selectedElementId; // 当前选中的元素ID
  
  _CurrentDrawingPainter({
    required this.start,
    required this.end,
    required this.elementType,
    required this.color,
    required this.strokeWidth,
    required this.density,
    required this.curvature,
    this.freeDrawingPath,
    this.selectedElementId,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // 橡皮擦特殊预览
    if (elementType == DrawingElementType.eraser) {
      final rect = Rect.fromPoints(start, end);
      final paint = Paint()
        ..color = Colors.red.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, paint);
      
      // 绘制边框
      final borderPaint = Paint()
        ..color = Colors.red.withOpacity(0.8)        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(rect, borderPaint);
      return;
    }
    
    // 自由绘制特殊预览
    if (elementType == DrawingElementType.freeDrawing && freeDrawingPath != null && freeDrawingPath!.isNotEmpty) {
      final paint = Paint()
        ..color = color.withOpacity(0.7)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      
      final path = Path();
      path.moveTo(freeDrawingPath![0].dx, freeDrawingPath![0].dy);
      for (int i = 1; i < freeDrawingPath!.length; i++) {
        path.lineTo(freeDrawingPath![i].dx, freeDrawingPath![i].dy);
      }
      canvas.drawPath(path, paint);
      return;
    }

    // 文本工具特殊预览 - 显示一个小方块指示放置位置
    if (elementType == DrawingElementType.text) {
      final paint = Paint()
        ..color = color.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      // 在文本位置绘制一个小方块作为预览
      final rect = Rect.fromCenter(
        center: start,
        width: 20,
        height: 20,
      );
      canvas.drawRect(rect, paint);
        // 绘制文本预览提示
      final textPainter = TextPainter(
        text: TextSpan(
          text: "点击添加文本",
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 12.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(
        start.dx - textPainter.width / 2,
        start.dy - textPainter.height / 2,
      ));
      return;
    }

    // 使用固定的画布尺寸来确保坐标转换的一致性
    List<Offset> points;
    if (elementType == DrawingElementType.freeDrawing && freeDrawingPath != null) {
      // 对于自由绘制，使用路径点
      points = freeDrawingPath!.map((point) => Offset(
        point.dx / kCanvasWidth,
        point.dy / kCanvasHeight,
      )).toList();
    } else {
      // 对于其他绘制类型，使用开始和结束点
      points = [
        Offset(start.dx / kCanvasWidth, start.dy / kCanvasHeight),
        Offset(end.dx / kCanvasWidth, end.dy / kCanvasHeight),
      ];
    }    final element = MapDrawingElement(
      id: 'preview',
      type: elementType,
      points: points,
      color: color.withOpacity(0.7),
      strokeWidth: strokeWidth,
      density: density,
      curvature: curvature, // 使用实际的曲率值进行预览
      createdAt: DateTime.now(),
    );final layerPainter = _LayerPainter(
      layer: MapLayer(
        id: 'preview',
        name: 'Preview',
        elements: [element],
        isVisible: true,
        opacity: 0.7,
        order: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      isEditMode: true,
      selectedElementId: selectedElementId,
    );

    layerPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 透明背景画笔，绘制棋盘格图案
class _TransparentBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double squareSize = 20.0;
    final Paint lightPaint = Paint()..color = Colors.grey.shade100;
    final Paint darkPaint = Paint()..color = Colors.grey.shade200;

    for (double x = 0; x < size.width; x += squareSize) {
      for (double y = 0; y < size.height; y += squareSize) {
        final isEvenRow = (y / squareSize).floor() % 2 == 0;
        final isEvenCol = (x / squareSize).floor() % 2 == 0;
        final isLightSquare = (isEvenRow && isEvenCol) || (!isEvenRow && !isEvenCol);
        
        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          isLightSquare ? lightPaint : darkPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
