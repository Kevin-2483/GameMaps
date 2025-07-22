import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';
import '../widgets/map_canvas.dart';

enum ResizeHandle {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topCenter,
  bottomCenter,
  centerLeft,
  centerRight,
  rotation,
}

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
        final fontSize = element.fontSize ?? 16.0;
        final anchorPoint = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );
        // 创建正方形点击区域，调整位置使其包围文本
        final hitArea = Rect.fromLTWH(
          anchorPoint.dx - fontSize / 2,
          anchorPoint.dy - fontSize / 2,
          fontSize,
          fontSize,
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
    bool includeRotationHandle = false,
  }) {
    const size = Size(kCanvasWidth, kCanvasHeight);
    final effectiveHandleSize = handleSize ?? 8.0;
    final handles = <Rect>[];

    // 文本元素特殊处理
    if (element.type == DrawingElementType.text) {
      if (element.points.isEmpty) return [];

      final fontSize = element.fontSize ?? 16.0;
      final anchorPoint = Offset(
        element.points[0].dx * size.width,
        element.points[0].dy * size.height,
      );

      // 创建正方形边界框，调整位置使其包围文本
      final boundingRect = Rect.fromLTWH(
        anchorPoint.dx - fontSize / 2,
        anchorPoint.dy - fontSize / 2,
        fontSize,
        fontSize,
      );

      // 按照ResizeHandle枚举顺序添加调整柄
      // topLeft
      handles.add(
        Rect.fromCenter(
          center: boundingRect.topLeft,
          width: effectiveHandleSize,
          height: effectiveHandleSize,
        ),
      );
      // topRight
      handles.add(
        Rect.fromCenter(
          center: boundingRect.topRight,
          width: effectiveHandleSize,
          height: effectiveHandleSize,
        ),
      );
      // bottomLeft
      handles.add(
        Rect.fromCenter(
          center: boundingRect.bottomLeft,
          width: effectiveHandleSize,
          height: effectiveHandleSize,
        ),
      );
      // bottomRight
      handles.add(
        Rect.fromCenter(
          center: boundingRect.bottomRight,
          width: effectiveHandleSize,
          height: effectiveHandleSize,
        ),
      );
      // topCenter
      handles.add(
        Rect.fromCenter(
          center: Offset(boundingRect.center.dx, boundingRect.top),
          width: effectiveHandleSize,
          height: effectiveHandleSize,
        ),
      );
      // bottomCenter
      handles.add(
        Rect.fromCenter(
          center: Offset(boundingRect.center.dx, boundingRect.bottom),
          width: effectiveHandleSize,
          height: effectiveHandleSize,
        ),
      );
      // centerLeft
      handles.add(
        Rect.fromCenter(
          center: Offset(boundingRect.left, boundingRect.center.dy),
          width: effectiveHandleSize,
          height: effectiveHandleSize,
        ),
      );
      // centerRight
      handles.add(
        Rect.fromCenter(
          center: Offset(boundingRect.right, boundingRect.center.dy),
          width: effectiveHandleSize,
          height: effectiveHandleSize,
        ),
      );

      return handles;
    }

    // 其他元素的处理
    if (element.points.length < 2) return [];

    final start = Offset(
      element.points[0].dx * size.width,
      element.points[0].dy * size.height,
    );
    final end = Offset(
      element.points[1].dx * size.width,
      element.points[1].dy * size.height,
    );
    final rect = Rect.fromPoints(start, end);

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

    // 添加旋转拖动柄（如果需要）
    if (includeRotationHandle) {
      // 旋转拖动柄位置在元素上方，距离为元素高度的60%
      final rotationHandleDistance = rect.height * 0.6;
      final rotationHandleCenter = Offset(
        rect.center.dx,
        rect.top - rotationHandleDistance,
      );
      handles.add(
        Rect.fromCenter(
          center: rotationHandleCenter,
          width: effectiveHandleSize,
          height: effectiveHandleSize,
        ),
      );
    }

    return handles;
  }

  /// 检测点击位置命中哪个调整大小控制柄
  ResizeHandle? getHitResizeHandle(
    Offset canvasPosition,
    MapDrawingElement element, {
    double? handleSize,
    bool includeRotationHandle = false,
  }) {
    final handles = getResizeHandles(
      element,
      handleSize: handleSize,
      includeRotationHandle: includeRotationHandle,
    );

    // Debug output for text elements
    if (element.type == DrawingElementType.text) {
      debugPrint('Text element hit test:');
      debugPrint('  Canvas position: $canvasPosition');
      debugPrint('  Element points: ${element.points}');
      debugPrint('  Font size: ${element.fontSize}');
      debugPrint('  Number of handles: ${handles.length}');
      for (int i = 0; i < handles.length; i++) {
        final handle = handles[i];
        final expandedHandle = Rect.fromCenter(
          center: handle.center,
          width: handle.width * 1.5,
          height: handle.height * 1.5,
        );
        debugPrint(
          '  Handle $i (${ResizeHandle.values[i]}): ${handle.center} -> expanded: $expandedHandle',
        );
        if (expandedHandle.contains(canvasPosition)) {
          debugPrint('  -> HIT!');
        }
      }
    }

    // 增加检测区域，使调整柄更容易被点击
    const double hitAreaMultiplier = 1.5; // 检测区域放大1.5倍

    for (int i = 0; i < handles.length; i++) {
      final handle = handles[i];
      // 创建一个放大的检测区域
      final expandedHandle = Rect.fromCenter(
        center: handle.center,
        width: handle.width * hitAreaMultiplier,
        height: handle.height * hitAreaMultiplier,
      );

      if (expandedHandle.contains(canvasPosition)) {
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

    // 文本元素特殊处理
    if (element.type == DrawingElementType.text) {
      if (element.points.isNotEmpty) {
        const size = Size(kCanvasWidth, kCanvasHeight);
        final fontSize = element.fontSize ?? 16.0;
        final anchorPoint = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );
        _originalElementBounds = Rect.fromLTWH(
          anchorPoint.dx - fontSize / 2,
          anchorPoint.dy - fontSize / 2,
          fontSize,
          fontSize,
        );
      }
    } else if (element.points.length >= 2) {
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

    final element = selectedLayer.elements
        .where((e) => e.id == elementId)
        .first;

    Rect newBounds;

    // 文本元素特殊处理
    if (element.type == DrawingElementType.text) {
      // 调整字体大小（保持正方形）
      newBounds = calculateNewBounds(
        _originalElementBounds!,
        _activeResizeHandle!,
        delta,
      );

      // 确保文本框保持正方形
      final size = (newBounds.width + newBounds.height) / 2;
      newBounds = Rect.fromLTWH(newBounds.left, newBounds.top, size, size);
    } else {
      // 其他元素的处理
      newBounds = calculateNewBounds(
        _originalElementBounds!,
        _activeResizeHandle!,
        delta,
      );
    }

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
      case ResizeHandle.rotation:
        // 旋转柄不改变边界，这里不做任何操作
        break;
    }

    // 确保最小尺寸
    const minSize = 8.0; // 文本最小字体大小
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

    MapDrawingElement updatedElement;

    // 文本元素特殊处理
    if (element.type == DrawingElementType.text) {
      // 对于文本元素，更新锚点位置和字体大小
      // 锚点应该是边界框中心对应的位置
      final normalizedAnchor = Offset(
        ((newBounds.left + newBounds.width / 2) / kCanvasWidth).clamp(0.0, 1.0),
        ((newBounds.top + newBounds.height / 2) / kCanvasHeight).clamp(
          0.0,
          1.0,
        ),
      );

      // 字体大小等于选择框的高度（只限制最小值）
      final newFontSize = newBounds.height.clamp(8.0, double.infinity);

      updatedElement = element.copyWith(
        points: [normalizedAnchor],
        fontSize: newFontSize,
      );
    } else {
      // 其他元素的处理
      final normalizedStart = Offset(
        (newBounds.left / kCanvasWidth).clamp(0.0, 1.0),
        (newBounds.top / kCanvasHeight).clamp(0.0, 1.0),
      );
      final normalizedEnd = Offset(
        (newBounds.right / kCanvasWidth).clamp(0.0, 1.0),
        (newBounds.bottom / kCanvasHeight).clamp(0.0, 1.0),
      );

      updatedElement = element.copyWith(
        points: [normalizedStart, normalizedEnd],
      );
    }

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

  /// 获取LegendItem的旋转拖动柄位置
  static Rect? getLegendRotationHandle(
    Offset legendCenter,
    double legendSize,
    double handleSize, {
    double rotation = 0.0, // 图例的旋转角度（度数）
  }) {
    // 旋转拖动柄位置在图例上方，距离为图例大小的60%
    final rotationHandleDistance = legendSize * 0.6;

    // 将角度转换为弧度，现在旋转指示器在Transform.rotate内部
    // 直接使用图例的旋转角度，不需要额外调整
    final angleInRadians = rotation * (math.pi / 180);

    // 根据旋转角度计算手柄位置
    final rotationHandleCenter = Offset(
      legendCenter.dx + rotationHandleDistance * math.cos(angleInRadians),
      legendCenter.dy + rotationHandleDistance * math.sin(angleInRadians),
    );

    return Rect.fromCenter(
      center: rotationHandleCenter,
      width: handleSize,
      height: handleSize,
    );
  }

  /// 检测点击位置是否命中LegendItem的旋转拖动柄
  static bool isHitLegendRotationHandle(
    Offset canvasPosition,
    Offset legendCenter,
    double legendSize,
    double handleSize, {
    double rotation = 0.0, // 图例的旋转角度（度数）
  }) {
    final rotationHandle = getLegendRotationHandle(
      legendCenter,
      legendSize,
      handleSize,
      rotation: rotation,
    );
    if (rotationHandle == null) return false;

    // 增加检测区域，使拖动柄更容易被点击
    const double hitAreaMultiplier = 1.5;
    final expandedHandle = Rect.fromCenter(
      center: rotationHandle.center,
      width: rotationHandle.width * hitAreaMultiplier,
      height: rotationHandle.height * hitAreaMultiplier,
    );

    return expandedHandle.contains(canvasPosition);
  }
}
