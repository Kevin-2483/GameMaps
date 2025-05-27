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

  const DrawingPreviewData({
    required this.start,
    required this.end,
    required this.elementType,
    required this.color,
    required this.strokeWidth,
  });
}

class MapCanvas extends StatefulWidget {
  final MapItem mapItem;
  final MapLayer? selectedLayer;
  final DrawingElementType? selectedDrawingTool;
  final Color selectedColor;
  final double selectedStrokeWidth;
  final List<legend_db.LegendItem> availableLegends;
  final bool isPreviewMode;
  final Function(MapLayer) onLayerUpdated;
  final Function(LegendGroup) onLegendGroupUpdated;
  final Map<String, double> previewOpacityValues;
  
  // 绘制工具预览状态
  final DrawingElementType? previewDrawingTool;
  final Color? previewColor;
  final double? previewStrokeWidth;

  const MapCanvas({
    super.key,
    required this.mapItem,
    this.selectedLayer,
    this.selectedDrawingTool,
    required this.selectedColor,
    required this.selectedStrokeWidth,
    required this.availableLegends,
    required this.isPreviewMode,
    required this.onLayerUpdated,
    required this.onLegendGroupUpdated,
    this.previewOpacityValues = const {},
    this.previewDrawingTool,
    this.previewColor,
    this.previewStrokeWidth,
  });

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  final TransformationController _transformationController = TransformationController();
  Offset? _currentDrawingStart;
  Offset? _currentDrawingEnd;
  bool _isDrawing = false;
  
  // 绘制预览的 ValueNotifier，避免整个 widget 重绘
  final ValueNotifier<DrawingPreviewData?> _drawingPreviewNotifier = ValueNotifier(null);

  // 获取有效的绘制工具状态（预览值或实际值）
  DrawingElementType? get _effectiveDrawingTool => widget.previewDrawingTool ?? widget.selectedDrawingTool;
  Color get _effectiveColor => widget.previewColor ?? widget.selectedColor;
  double get _effectiveStrokeWidth => widget.previewStrokeWidth ?? widget.selectedStrokeWidth;
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
                  ),
                  child: Stack(
                    children: [
                      // 透明背景指示器（棋盘格图案）
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _TransparentBackgroundPainter(),
                        ),
                      ),
                      
                      // 图层图片（按order排序）
                      ...() {
                        final visibleLayers = widget.mapItem.layers
                            .where((layer) => layer.isVisible && layer.imageData != null)
                            .toList();
                        visibleLayers.sort((a, b) => a.order.compareTo(b.order));
                        return visibleLayers.map((layer) => _buildLayerImageWidget(layer));
                      }(),
                      
                      // Drawing layers (绘制元素)
                      ...widget.mapItem.layers.map((layer) => _buildLayerWidget(layer)),
                      
                      // Legend groups
                      ...widget.mapItem.legendGroups.map((legendGroup) => _buildLegendWidget(legendGroup)),
                      
                      // Current drawing preview
                      ValueListenableBuilder<DrawingPreviewData?>(
                        valueListenable: _drawingPreviewNotifier,
                        builder: (context, previewData, child) {
                          if (previewData == null) return const SizedBox.shrink();
                          return CustomPaint(
                            size: const Size(kCanvasWidth, kCanvasHeight),
                            painter: _CurrentDrawingPainter(
                              start: previewData.start,
                              end: previewData.end,
                              elementType: previewData.elementType,
                              color: previewData.color,
                              strokeWidth: previewData.strokeWidth,
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
                    child: GestureDetector(
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
          ),
        ),
      ),
    );
  }

  Widget _buildLegendWidget(LegendGroup legendGroup) {
    if (!legendGroup.isVisible) return const SizedBox.shrink();

    return Positioned(
      left: 100, // 默认位置，后续可以改为可拖拽
      top: 100,
      child: Opacity(
        opacity: legendGroup.opacity,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                legendGroup.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              ...legendGroup.legendItems.map((item) => _buildLegendItem(item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(LegendItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue, // 默认颜色，后续从图例数据获取
              border: Border.all(color: Colors.grey.shade600),
            ),
          ),          const SizedBox(width: 8),
          Builder(
            builder: (context) {
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
              return Text(
                legend.title,
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ],
      ),
    );
  }  void _onDrawingStart(DragStartDetails details) {
    if (widget.isPreviewMode || _effectiveDrawingTool == null) return;

    // 获取相对于画布的坐标
    _currentDrawingStart = _getCanvasPosition(details.localPosition);
    _currentDrawingEnd = _currentDrawingStart;
    _isDrawing = true;
    
    // 只更新绘制预览，不触发整个 widget 重绘
    _drawingPreviewNotifier.value = DrawingPreviewData(
      start: _currentDrawingStart!,
      end: _currentDrawingEnd!,
      elementType: _effectiveDrawingTool!,
      color: _effectiveColor,
      strokeWidth: _effectiveStrokeWidth,
    );
  }

  void _onDrawingUpdate(DragUpdateDetails details) {
    if (!_isDrawing) return;

    // 获取相对于画布的坐标
    _currentDrawingEnd = _getCanvasPosition(details.localPosition);
    
    // 只更新绘制预览，不触发整个 widget 重绘
    _drawingPreviewNotifier.value = DrawingPreviewData(
      start: _currentDrawingStart!,
      end: _currentDrawingEnd!,
      elementType: _effectiveDrawingTool!,
      color: _effectiveColor,
      strokeWidth: _effectiveStrokeWidth,
    );
  }

  // 获取相对于画布的正确坐标
  Offset _getCanvasPosition(Offset localPosition) {
    // localPosition 已经是相对于画布容器的坐标
    // 确保坐标在画布范围内
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
    }    // Convert screen coordinates to normalized coordinates (0.0-1.0)
    // 使用固定的画布尺寸，与绘制时保持一致
    final normalizedStart = Offset(
      _currentDrawingStart!.dx / kCanvasWidth,
      _currentDrawingStart!.dy / kCanvasHeight,
    );
    final normalizedEnd = Offset(
      _currentDrawingEnd!.dx / kCanvasWidth,
      _currentDrawingEnd!.dy / kCanvasHeight,
    );

    // Add the drawing element to the selected layer
    final element = MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _effectiveDrawingTool!,
      points: [normalizedStart, normalizedEnd],
      color: _effectiveColor,
      strokeWidth: _effectiveStrokeWidth,
      createdAt: DateTime.now(),
    );

    final updatedLayer = widget.selectedLayer!.copyWith(
      elements: [...widget.selectedLayer!.elements, element],
      updatedAt: DateTime.now(),
    );

    widget.onLayerUpdated(updatedLayer);

    // 清理绘制状态，不需要 setState
    _isDrawing = false;
    _currentDrawingStart = null;
    _currentDrawingEnd = null;
    _drawingPreviewNotifier.value = null; // 清除预览
  }
}

class _LayerPainter extends CustomPainter {
  final MapLayer layer;
  final bool isEditMode;

  _LayerPainter({
    required this.layer,
    required this.isEditMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final element in layer.elements) {
      _drawElement(canvas, element, size);
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

    if (points.length < 2) return;

    final start = points[0];
    final end = points[1];

    switch (element.type) {
      case DrawingElementType.line:
        canvas.drawLine(start, end, paint);
        break;
      
      case DrawingElementType.dashedLine:
        _drawDashedLine(canvas, start, end, paint);
        break;
      
      case DrawingElementType.arrow:
        _drawArrow(canvas, start, end, paint);
        break;
      
      case DrawingElementType.rectangle:
        final rect = Rect.fromPoints(start, end);
        paint.style = PaintingStyle.fill;
        canvas.drawRect(rect, paint);
        break;
      
      case DrawingElementType.hollowRectangle:
        final rect = Rect.fromPoints(start, end);
        paint.style = PaintingStyle.stroke;
        canvas.drawRect(rect, paint);
        break;
      
      case DrawingElementType.diagonalLines:
        _drawDiagonalPattern(canvas, start, end, paint);
        break;
      
      case DrawingElementType.crossLines:
        _drawCrossPattern(canvas, start, end, paint);
        break;
      
      case DrawingElementType.dotGrid:
        _drawDotGrid(canvas, start, end, paint);
        break;
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    
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
  }

  void _drawDiagonalPattern(Canvas canvas, Offset start, Offset end, Paint paint) {
    final rect = Rect.fromPoints(start, end);
    const spacing = 10.0;
    
    for (double x = rect.left; x <= rect.right; x += spacing) {
      final lineStart = Offset(x, rect.top);
      final lineEnd = Offset(
        math.min(x + rect.height, rect.right), 
        rect.bottom
      );
      canvas.drawLine(lineStart, lineEnd, paint);
    }
  }

  void _drawCrossPattern(Canvas canvas, Offset start, Offset end, Paint paint) {
    final rect = Rect.fromPoints(start, end);
    const spacing = 15.0;
    
    // Vertical lines
    for (double x = rect.left; x <= rect.right; x += spacing) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
    }
    
    // Horizontal lines
    for (double y = rect.top; y <= rect.bottom; y += spacing) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }
  }

  void _drawDotGrid(Canvas canvas, Offset start, Offset end, Paint paint) {
    final rect = Rect.fromPoints(start, end);
    const spacing = 10.0;
    const dotRadius = 1.0;
    
    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    
    for (double x = rect.left; x <= rect.right; x += spacing) {
      for (double y = rect.top; y <= rect.bottom; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
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

  _CurrentDrawingPainter({
    required this.start,
    required this.end,
    required this.elementType,
    required this.color,
    required this.strokeWidth,
  });  @override
  void paint(Canvas canvas, Size size) {
    // 使用固定的画布尺寸来确保坐标转换的一致性
    final element = MapDrawingElement(
      id: 'preview',
      type: elementType,
      points: [
        Offset(start.dx / kCanvasWidth, start.dy / kCanvasHeight),
        Offset(end.dx / kCanvasWidth, end.dy / kCanvasHeight),
      ],
      color: color.withOpacity(0.7),
      strokeWidth: strokeWidth,
      createdAt: DateTime.now(),
    );

    final layerPainter = _LayerPainter(
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
