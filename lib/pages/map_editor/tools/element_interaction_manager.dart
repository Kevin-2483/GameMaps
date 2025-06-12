import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';
import '../widgets/map_canvas.dart';

/// 绘画元素交互管理器
/// 负责处理元素的拖拽、调整大小、碰撞检测等交互逻辑
class ElementInteractionManager {
  // 回调函数
  final Function(MapLayer)? onLayerUpdated;
  final VoidCallback? onStateChanged;

  // 构造函数
  ElementInteractionManager({this.onLayerUpdated, this.onStateChanged});

  // 拖拽相关状态
  String? _draggingElementId;
  Offset? _elementDragStartOffset;

  // 调整大小相关状态
  String? _resizingElementId;
  ResizeHandle? _activeResizeHandle;
  Offset? _resizeStartPosition;
  Rect? _originalElementBounds;

  // Getters
  String? get draggingElementId => _draggingElementId;
  String? get resizingElementId => _resizingElementId;
  bool get isDragging => _draggingElementId != null;
  bool get isResizing => _resizingElementId != null;

  /// 检查点是否在指定元素内
  bool isPointInElement(Offset canvasPosition, MapDrawingElement element) {
    const size = Size(kCanvasWidth, kCanvasHeight);

    switch (element.type) {
      case DrawingElementType.text:
        if (element.points.isEmpty) return false;
        final textPosition = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );
        // 为文本创建一个点击区域
        final hitArea = Rect.fromCenter(
          center: textPosition,
          width: 100, // 假设文本宽度
          height: element.fontSize ?? 16.0,
        );
        return hitArea.contains(canvasPosition);

      case DrawingElementType.freeDrawing:
        // 检查点是否靠近自由绘制路径
        for (final point in element.points) {
          final screenPoint = Offset(
            point.dx * size.width,
            point.dy * size.height,
          );
          if ((screenPoint - canvasPosition).distance < 10) {
            return true;
          }
        }
        return false;

      default:
        // 其他元素基于矩形边界检测
        if (element.points.length < 2) return false;
        final start = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );
        final end = Offset(
          element.points[1].dx * size.width,
          element.points[1].dy * size.height,
        );
        final rect = Rect.fromPoints(start, end);
        return rect.contains(canvasPosition);
    }
  }

  /// 获取命中的元素ID（按Z轴排序）
  String? getHitElement(Offset canvasPosition, MapLayer? selectedLayer) {
    if (selectedLayer == null || selectedLayer.elements.isEmpty) {
      return null;
    }

    // 按z值倒序检查，确保优先选择上层元素
    final sortedElements = List<MapDrawingElement>.from(selectedLayer.elements)
      ..sort((a, b) => b.zIndex.compareTo(a.zIndex));

    for (final element in sortedElements) {
      if (isPointInElement(canvasPosition, element)) {
        return element.id;
      }
    }
    return null;
  }

  /// 获取调整大小控制柄的矩形区域
  static List<Rect> getResizeHandles(
    MapDrawingElement element, {
    double? handleSize,
  }) {
    if (element.points.length < 2) return [];

    const size = Size(kCanvasWidth, kCanvasHeight);
    final start = Offset(
      element.points[0].dx * size.width,
      element.points[0].dy * size.height,
    );
    final end = Offset(
      element.points[1].dx * size.width,
      element.points[1].dy * size.height,
    );
    final rect = Rect.fromPoints(start, end);

    final effectiveHandleSize = handleSize ?? 8.0;
    final handles = <Rect>[];

    // 四个角的控制柄
    handles.add(
      Rect.fromCenter(
        center: rect.topLeft,
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: rect.topRight,
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: rect.bottomLeft,
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: rect.bottomRight,
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );

    // 边中点的控制柄
    handles.add(
      Rect.fromCenter(
        center: Offset(rect.center.dx, rect.top),
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: Offset(rect.center.dx, rect.bottom),
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: Offset(rect.left, rect.center.dy),
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: Offset(rect.right, rect.center.dy),
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );

    return handles;
  }

  /// 检测点击位置命中哪个调整大小控制柄
  ResizeHandle? getHitResizeHandle(
    Offset canvasPosition,
    MapDrawingElement element, {
    double? handleSize,
  }) {
    final handles = getResizeHandles(element, handleSize: handleSize);

    for (int i = 0; i < handles.length; i++) {
      if (handles[i].contains(canvasPosition)) {
        return ResizeHandle.values[i];
      }
    }
    return null;
  }

  /// 开始元素拖拽
  void onElementDragStart(
    String elementId,
    DragStartDetails details,
    MapLayer selectedLayer,
    Offset Function(Offset) getCanvasPosition,
  ) {
    _draggingElementId = elementId;

    // 计算拖拽开始时的偏移量
    final canvasPosition = getCanvasPosition(details.localPosition);
    final element = selectedLayer.elements
        .where((e) => e.id == elementId)
        .first;

    // 计算元素中心位置
    Offset elementCenter;
    if (element.type == DrawingElementType.text) {
      elementCenter = Offset(
        element.points[0].dx * kCanvasWidth,
        element.points[0].dy * kCanvasHeight,
      );
    } else if (element.points.length >= 2) {
      final start = Offset(
        element.points[0].dx * kCanvasWidth,
        element.points[0].dy * kCanvasHeight,
      );
      final end = Offset(
        element.points[1].dx * kCanvasWidth,
        element.points[1].dy * kCanvasHeight,
      );
      elementCenter = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    } else {
      return;
    }

    _elementDragStartOffset = Offset(
      canvasPosition.dx - elementCenter.dx,
      canvasPosition.dy - elementCenter.dy,
    );

    onStateChanged?.call();
  }

  /// 更新元素拖拽
  void onElementDragUpdate(
    String elementId,
    DragUpdateDetails details,
    MapLayer selectedLayer,
    Offset Function(Offset) getCanvasPosition,
  ) {
    if (_draggingElementId != elementId || _elementDragStartOffset == null) {
      return;
    }

    final canvasPosition = getCanvasPosition(details.localPosition);
    final adjustedPosition = Offset(
      canvasPosition.dx - _elementDragStartOffset!.dx,
      canvasPosition.dy - _elementDragStartOffset!.dy,
    );

    // 更新元素位置
    updateElementPosition(elementId, adjustedPosition, selectedLayer);
  }

  /// 结束元素拖拽
  void onElementDragEnd(String elementId, DragEndDetails details) {
    _draggingElementId = null;
    _elementDragStartOffset = null;
    onStateChanged?.call();
  }

  /// 更新元素位置
  void updateElementPosition(
    String elementId,
    Offset newCenter,
    MapLayer selectedLayer,
  ) {
    final elementIndex = selectedLayer.elements.indexWhere(
      (e) => e.id == elementId,
    );
    if (elementIndex == -1) return;

    final element = selectedLayer.elements[elementIndex];
    final updatedElements = List<MapDrawingElement>.from(
      selectedLayer.elements,
    );

    // 转换为标准化坐标
    final normalizedCenter = Offset(
      (newCenter.dx / kCanvasWidth).clamp(0.0, 1.0),
      (newCenter.dy / kCanvasHeight).clamp(0.0, 1.0),
    );

    MapDrawingElement updatedElement;

    if (element.type == DrawingElementType.text) {
      // 文本元素只有一个点
      updatedElement = element.copyWith(points: [normalizedCenter]);
    } else if (element.points.length >= 2) {
      // 计算当前元素的尺寸
      final currentStart = element.points[0];
      final currentEnd = element.points[1];
      final width = (currentEnd.dx - currentStart.dx).abs();
      final height = (currentEnd.dy - currentStart.dy).abs();

      // 保持尺寸，更新位置
      final newStart = Offset(
        normalizedCenter.dx - width / 2,
        normalizedCenter.dy - height / 2,
      );
      final newEnd = Offset(
        normalizedCenter.dx + width / 2,
        normalizedCenter.dy + height / 2,
      );
      updatedElement = element.copyWith(points: [newStart, newEnd]);
    } else {
      return;
    }

    updatedElements[elementIndex] = updatedElement;
    final updatedLayer = selectedLayer.copyWith(elements: updatedElements);
    onLayerUpdated?.call(updatedLayer);
  }

  /// 开始调整大小
  void onResizeStart(
    String elementId,
    ResizeHandle handle,
    DragStartDetails details,
    MapLayer selectedLayer,
    Offset Function(Offset) getCanvasPosition,
  ) {
    _resizingElementId = elementId;
    _activeResizeHandle = handle;
    _resizeStartPosition = getCanvasPosition(details.localPosition);

    final element = selectedLayer.elements
        .where((e) => e.id == elementId)
        .first;
    if (element.points.length >= 2) {
      const size = Size(kCanvasWidth, kCanvasHeight);
      final start = Offset(
        element.points[0].dx * size.width,
        element.points[0].dy * size.height,
      );
      final end = Offset(
        element.points[1].dx * size.width,
        element.points[1].dy * size.height,
      );
      _originalElementBounds = Rect.fromPoints(start, end);
    }

    onStateChanged?.call();
  }

  /// 更新调整大小
  void onResizeUpdate(
    String elementId,
    DragUpdateDetails details,
    MapLayer selectedLayer,
    Offset Function(Offset) getCanvasPosition,
  ) {
    if (_resizingElementId != elementId ||
        _activeResizeHandle == null ||
        _resizeStartPosition == null ||
        _originalElementBounds == null) {
      return;
    }

    final currentPosition = getCanvasPosition(details.localPosition);
    final delta = currentPosition - _resizeStartPosition!;

    // 根据控制柄类型计算新的边界
    final newBounds = calculateNewBounds(
      _originalElementBounds!,
      _activeResizeHandle!,
      delta,
    );

    // 更新元素大小
    updateElementSize(elementId, newBounds, selectedLayer);
  }

  /// 结束调整大小
  void onResizeEnd(String elementId, DragEndDetails details) {
    _resizingElementId = null;
    _activeResizeHandle = null;
    _resizeStartPosition = null;
    _originalElementBounds = null;
    onStateChanged?.call();
  }

  /// 根据控制柄和拖拽偏移计算新边界
  Rect calculateNewBounds(
    Rect originalBounds,
    ResizeHandle handle,
    Offset delta,
  ) {
    double left = originalBounds.left;
    double top = originalBounds.top;
    double right = originalBounds.right;
    double bottom = originalBounds.bottom;

    switch (handle) {
      case ResizeHandle.topLeft:
        left += delta.dx;
        top += delta.dy;
        break;
      case ResizeHandle.topRight:
        right += delta.dx;
        top += delta.dy;
        break;
      case ResizeHandle.bottomLeft:
        left += delta.dx;
        bottom += delta.dy;
        break;
      case ResizeHandle.bottomRight:
        right += delta.dx;
        bottom += delta.dy;
        break;
      case ResizeHandle.topCenter:
        top += delta.dy;
        break;
      case ResizeHandle.bottomCenter:
        bottom += delta.dy;
        break;
      case ResizeHandle.centerLeft:
        left += delta.dx;
        break;
      case ResizeHandle.centerRight:
        right += delta.dx;
        break;
    }

    // 确保最小尺寸
    const minSize = 0.0;
    if (right - left < minSize) {
      if (handle == ResizeHandle.centerLeft ||
          handle == ResizeHandle.topLeft ||
          handle == ResizeHandle.bottomLeft) {
        left = right - minSize;
      } else {
        right = left + minSize;
      }
    }
    if (bottom - top < minSize) {
      if (handle == ResizeHandle.topCenter ||
          handle == ResizeHandle.topLeft ||
          handle == ResizeHandle.topRight) {
        top = bottom - minSize;
      } else {
        bottom = top + minSize;
      }
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  /// 更新元素大小
  void updateElementSize(
    String elementId,
    Rect newBounds,
    MapLayer selectedLayer,
  ) {
    final elementIndex = selectedLayer.elements.indexWhere(
      (e) => e.id == elementId,
    );
    if (elementIndex == -1) return;

    final element = selectedLayer.elements[elementIndex];
    final updatedElements = List<MapDrawingElement>.from(
      selectedLayer.elements,
    );

    // 转换为标准化坐标
    final normalizedStart = Offset(
      (newBounds.left / kCanvasWidth).clamp(0.0, 1.0),
      (newBounds.top / kCanvasHeight).clamp(0.0, 1.0),
    );
    final normalizedEnd = Offset(
      (newBounds.right / kCanvasWidth).clamp(0.0, 1.0),
      (newBounds.bottom / kCanvasHeight).clamp(0.0, 1.0),
    );

    final updatedElement = element.copyWith(
      points: [normalizedStart, normalizedEnd],
    );

    updatedElements[elementIndex] = updatedElement;
    final updatedLayer = selectedLayer.copyWith(elements: updatedElements);
    onLayerUpdated?.call(updatedLayer);
  }

  /// 重置状态
  void reset() {
    _draggingElementId = null;
    _elementDragStartOffset = null;
    _resizingElementId = null;
    _activeResizeHandle = null;
    _resizeStartPosition = null;
    _originalElementBounds = null;
  }
}
