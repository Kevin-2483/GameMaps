// drawing_tool_manager.dart - 专门的绘制工具管理类
// 用于管理所有绘制相关的操作和状态

import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../../models/map_layer.dart';
import '../../../models/sticky_note.dart';
import '../widgets/map_canvas.dart';

/// 绘制工具管理器 - 负责管理所有绘制工具相关的操作
class DrawingToolManager {
  // 绘制状态
  Offset? _currentDrawingStart;
  Offset? _currentDrawingEnd;
  bool _isDrawing = false;
  List<Offset> _freeDrawingPath = [];

  // 绘制预览通知器
  final ValueNotifier<DrawingPreviewData?> _drawingPreviewNotifier =
      ValueNotifier(null);
  // 画布尺寸常量 - 与 map_canvas.dart 中的常量保持一致
  static const double kCanvasWidth = 1600.0;
  static const double kCanvasHeight = 1600.0;
  // 回调函数
  Function(MapLayer)? onLayerUpdated;
  BuildContext? context;

  // Sticky note drawing support
  StickyNote? _currentDrawingStickyNote;

  DrawingToolManager({this.onLayerUpdated, this.context});
  // Getters
  ValueNotifier<DrawingPreviewData?> get drawingPreviewNotifier =>
      _drawingPreviewNotifier;

  bool get isDrawing => _isDrawing;
  List<Offset> get freeDrawingPath => _freeDrawingPath;
  Offset? get currentDrawingStart => _currentDrawingStart;

  // Getters for sticky note drawing
  StickyNote? get currentDrawingStickyNote => _currentDrawingStickyNote;

  /// 1. 开始绘制
  void onDrawingStart(
    DragStartDetails details,
    DrawingElementType? effectiveDrawingTool,
    Color effectiveColor,
    double effectiveStrokeWidth,
    double effectiveDensity,
    double effectiveCurvature,
    TriangleCutType effectiveTriangleCut,
  ) {
    if (effectiveDrawingTool == null) return;

    // 获取相对于画布的坐标，对于绘制操作需要限制在画布范围内
    _currentDrawingStart = _getClampedCanvasPosition(details.localPosition);
    _currentDrawingEnd = _currentDrawingStart;
    _isDrawing = true;

    // 初始化自由绘制路径
    if (effectiveDrawingTool == DrawingElementType.freeDrawing) {
      _freeDrawingPath = [_currentDrawingStart!];
    }

    // 只更新绘制预览，不触发整个 widget 重绘
    _drawingPreviewNotifier.value = DrawingPreviewData(
      start: _currentDrawingStart!,
      end: _currentDrawingEnd!,
      elementType: effectiveDrawingTool,
      color: effectiveColor,
      strokeWidth: effectiveStrokeWidth,
      density: effectiveDensity,
      curvature: effectiveCurvature,
      triangleCut: effectiveTriangleCut,
      freeDrawingPath: effectiveDrawingTool == DrawingElementType.freeDrawing
          ? _freeDrawingPath
          : null,
    );
  }

  /// 2. 更新绘制
  void onDrawingUpdate(
    DragUpdateDetails details,
    DrawingElementType? effectiveDrawingTool,
    Color effectiveColor,
    double effectiveStrokeWidth,
    double effectiveDensity,
    double effectiveCurvature,
    TriangleCutType effectiveTriangleCut,
  ) {
    if (!_isDrawing || effectiveDrawingTool == null) return;

    // 获取相对于画布的坐标，对于绘制操作需要限制在画布范围内
    _currentDrawingEnd = _getClampedCanvasPosition(details.localPosition);

    // 自由绘制路径处理
    if (effectiveDrawingTool == DrawingElementType.freeDrawing) {
      _freeDrawingPath.add(_currentDrawingEnd!);

      // 对于自由绘制，使用路径信息更新预览
      _drawingPreviewNotifier.value = DrawingPreviewData(
        start: _freeDrawingPath.first,
        end: _freeDrawingPath.last,
        elementType: effectiveDrawingTool,
        color: effectiveColor,
        strokeWidth: effectiveStrokeWidth,
        density: effectiveDensity,
        curvature: effectiveCurvature,
        triangleCut: effectiveTriangleCut,
        freeDrawingPath: _freeDrawingPath,
      );
      return;
    }

    // 只更新绘制预览，不触发整个 widget 重绘
    _drawingPreviewNotifier.value = DrawingPreviewData(
      start: _currentDrawingStart!,
      end: _currentDrawingEnd!,
      elementType: effectiveDrawingTool,
      color: effectiveColor,
      strokeWidth: effectiveStrokeWidth,
      density: effectiveDensity,
      curvature: effectiveCurvature,
      triangleCut: effectiveTriangleCut,
      freeDrawingPath: null,
    );
  }

  /// 3. 结束绘制
  void onDrawingEnd(
    DragEndDetails details,
    DrawingElementType? effectiveDrawingTool,
    Color effectiveColor,
    double effectiveStrokeWidth,
    double effectiveDensity,
    double effectiveCurvature,
    TriangleCutType effectiveTriangleCut,
    MapLayer? selectedLayer,
    Uint8List? imageBufferData,
    BoxFit imageBufferFit,
  ) {
    if (!_isDrawing ||
        _currentDrawingStart == null ||
        _currentDrawingEnd == null ||
        selectedLayer == null ||
        effectiveDrawingTool == null) {
      _clearDrawingState();
      return;
    }

    // Convert screen coordinates to normalized coordinates (0.0-1.0)
    final normalizedStart = Offset(
      _currentDrawingStart!.dx / kCanvasWidth,
      _currentDrawingStart!.dy / kCanvasHeight,
    );
    final normalizedEnd = Offset(
      _currentDrawingEnd!.dx / kCanvasWidth,
      _currentDrawingEnd!.dy / kCanvasHeight,
    );

    // 处理不同类型的绘制工具
    if (effectiveDrawingTool == DrawingElementType.eraser) {
      handleEraserAction(
        normalizedStart,
        normalizedEnd,
        selectedLayer,
        effectiveCurvature,
        effectiveTriangleCut,
      );
    } else if (effectiveDrawingTool == DrawingElementType.freeDrawing) {
      handleFreeDrawingEnd(
        selectedLayer,
        effectiveColor,
        effectiveStrokeWidth,
        effectiveDensity,
        effectiveCurvature,
      );
    } else {
      _createStandardElement(
        normalizedStart,
        normalizedEnd,
        effectiveDrawingTool,
        effectiveColor,
        effectiveStrokeWidth,
        effectiveDensity,
        effectiveCurvature,
        effectiveTriangleCut,
        selectedLayer,
        imageBufferData,
        imageBufferFit,
      );
    }

    _clearDrawingState();
  }

  /// 4. 处理橡皮擦动作
  void handleEraserAction(
    Offset normalizedStart,
    Offset normalizedEnd,
    MapLayer selectedLayer,
    double effectiveCurvature,
    TriangleCutType effectiveTriangleCut,
  ) {
    // 计算橡皮擦的 z 值（比当前 z 值大 1）
    final maxZIndex = selectedLayer.elements.isEmpty
        ? 0
        : selectedLayer.elements
              .map((e) => e.zIndex)
              .reduce((a, b) => a > b ? a : b);

    // 创建一个橡皮擦元素，用于遮挡下方的绘制元素
    final eraserElement = MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: DrawingElementType.eraser,
      points: [normalizedStart, normalizedEnd],
      color: Colors.transparent, // 橡皮擦本身是透明的
      strokeWidth: 0.0,
      curvature: effectiveCurvature, // 保存曲率参数
      triangleCut: effectiveTriangleCut,
      zIndex: maxZIndex + 1,
      createdAt: DateTime.now(),
    );

    final updatedLayer = selectedLayer.copyWith(
      elements: [...selectedLayer.elements, eraserElement],
      updatedAt: DateTime.now(),
    );

    onLayerUpdated?.call(updatedLayer);
  }

  /// 5. 处理自由绘制结束
  void handleFreeDrawingEnd(
    MapLayer selectedLayer,
    Color effectiveColor,
    double effectiveStrokeWidth,
    double effectiveDensity,
    double effectiveCurvature,
  ) {
    if (_freeDrawingPath.isEmpty) return;

    // 将路径点转换为标准化坐标
    final normalizedPoints = _freeDrawingPath
        .map(
          (point) => Offset(point.dx / kCanvasWidth, point.dy / kCanvasHeight),
        )
        .toList();

    // 计算新元素的 z 值
    final maxZIndex = selectedLayer.elements.isEmpty
        ? 0
        : selectedLayer.elements
              .map((e) => e.zIndex)
              .reduce((a, b) => a > b ? a : b);

    // 创建自由绘制元素
    final element = MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: DrawingElementType.freeDrawing,
      points: normalizedPoints,
      color: effectiveColor,
      strokeWidth: effectiveStrokeWidth,
      density: effectiveDensity,
      curvature: effectiveCurvature,
      zIndex: maxZIndex + 1,
      createdAt: DateTime.now(),
    );

    final updatedLayer = selectedLayer.copyWith(
      elements: [...selectedLayer.elements, element],
      updatedAt: DateTime.now(),
    );

    onLayerUpdated?.call(updatedLayer);

    // 清空路径
    _freeDrawingPath.clear();
  }

  /// 6. 创建文本元素
  void createTextElement(
    String text,
    double fontSize,
    Offset position,
    MapLayer selectedLayer,
    Color effectiveColor,
    double effectiveStrokeWidth,
    double effectiveDensity,
    double effectiveCurvature,
  ) {
    final normalizedPosition = Offset(
      position.dx / kCanvasWidth,
      position.dy / kCanvasHeight,
    );

    final maxZIndex = selectedLayer.elements.isEmpty
        ? 0
        : selectedLayer.elements
              .map((e) => e.zIndex)
              .reduce((a, b) => a > b ? a : b);

    final element = MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: DrawingElementType.text,
      points: [normalizedPosition],
      color: effectiveColor,
      strokeWidth: effectiveStrokeWidth,
      density: effectiveDensity,
      curvature: effectiveCurvature,
      zIndex: maxZIndex + 1,
      text: text,
      fontSize: fontSize,
      createdAt: DateTime.now(),
    );

    final updatedLayer = selectedLayer.copyWith(
      elements: [...selectedLayer.elements, element],
      updatedAt: DateTime.now(),
    );

    onLayerUpdated?.call(updatedLayer);
  }

  /// 7. 显示文本输入对话框
  Future<void> showTextInputDialog(
    Offset position,
    MapLayer selectedLayer,
    Color effectiveColor,
    double effectiveStrokeWidth,
    double effectiveDensity,
    double effectiveCurvature,
  ) async {
    if (context == null) return;

    final textController = TextEditingController();
    final fontSize = ValueNotifier<double>(16.0);

    final result = await showDialog<Map<String, dynamic>>(
      context: context!,
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

    if (result != null && result['text'] != null) {
      createTextElement(
        result['text'],
        result['fontSize'],
        position,
        selectedLayer,
        effectiveColor,
        effectiveStrokeWidth,
        effectiveDensity,
        effectiveCurvature,
      );
    }

    _clearDrawingState();
  }

  /// 7.1 显示带预设字体大小的文本输入对话框
  Future<void> showTextInputDialogWithSize(
    Offset position,
    MapLayer selectedLayer,
    double presetFontSize,
    Color effectiveColor,
    double effectiveStrokeWidth,
    double effectiveDensity,
    double effectiveCurvature,
  ) async {
    if (context == null) return;

    final textController = TextEditingController();

    final result = await showDialog<String>(
      context: context!,
      builder: (context) => AlertDialog(
        title: Text('添加文本 (字体大小: ${presetFontSize.round()}px)'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: '文本内容',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                Navigator.of(context).pop(textController.text);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      createTextElement(
        result,
        presetFontSize,
        position,
        selectedLayer,
        effectiveColor,
        effectiveStrokeWidth,
        effectiveDensity,
        effectiveCurvature,
      );
    }

    _clearDrawingState();
  }

  /// 11. 在便签中创建文本元素
  void createStickyNoteTextElement(
    String text,
    double fontSize,
    Offset position,
    StickyNote targetStickyNote,
    Color effectiveColor,
    double effectiveStrokeWidth,
    double effectiveDensity,
    double effectiveCurvature,
    Function(StickyNote) onStickyNoteUpdated,
  ) {
    // Convert canvas position to sticky note local coordinates
    final normalizedPosition = _convertCanvasToStickyNoteCoordinates(
      position,
      targetStickyNote,
    );

    final maxZIndex = targetStickyNote.elements.isEmpty
        ? 0
        : targetStickyNote.elements
              .map((e) => e.zIndex)
              .reduce((a, b) => a > b ? a : b);

    final element = MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: DrawingElementType.text,
      points: [normalizedPosition],
      color: effectiveColor,
      strokeWidth: effectiveStrokeWidth,
      density: effectiveDensity,
      curvature: effectiveCurvature,
      zIndex: maxZIndex + 1,
      text: text,
      fontSize: fontSize,
      createdAt: DateTime.now(),
    );

    final updatedStickyNote = targetStickyNote.addElement(element);
    onStickyNoteUpdated(updatedStickyNote);
  }

  /// 12. 显示便签文本输入对话框
  Future<void> showStickyNoteTextInputDialog(
    Offset position,
    StickyNote targetStickyNote,
    Color effectiveColor,
    double effectiveStrokeWidth,
    double effectiveDensity,
    double effectiveCurvature,
    Function(StickyNote) onStickyNoteUpdated,
  ) async {
    if (context == null) return;

    final textController = TextEditingController();
    final fontSize = ValueNotifier<double>(16.0);

    final result = await showDialog<Map<String, dynamic>>(
      context: context!,
      builder: (context) => AlertDialog(
        title: const Text('添加文本到便签'),
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

    if (result != null && result['text'] != null) {
      createStickyNoteTextElement(
        result['text'],
        result['fontSize'],
        position,
        targetStickyNote,
        effectiveColor,
        effectiveStrokeWidth,
        effectiveDensity,
        effectiveCurvature,
        onStickyNoteUpdated,
      );
    }
  }

  /// 12.1 显示带预设字体大小的便签文本输入对话框
  Future<void> showStickyNoteTextInputDialogWithSize(
    Offset position,
    StickyNote targetStickyNote,
    double presetFontSize,
    Color effectiveColor,
    double effectiveStrokeWidth,
    double effectiveDensity,
    double effectiveCurvature,
    Function(StickyNote) onStickyNoteUpdated,
  ) async {
    if (context == null) return;

    final textController = TextEditingController();

    final result = await showDialog<String>(
      context: context!,
      builder: (context) => AlertDialog(
        title: Text('添加文本到便签 (字体大小: ${presetFontSize.round()}px)'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: '文本内容',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                Navigator.of(context).pop(textController.text);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      createStickyNoteTextElement(
        result,
        presetFontSize,
        position,
        targetStickyNote,
        effectiveColor,
        effectiveStrokeWidth,
        effectiveDensity,
        effectiveCurvature,
        onStickyNoteUpdated,
      );
    }
  }

  /// 创建标准绘制元素（非自由绘制、非橡皮擦、非文本）
  void _createStandardElement(
    Offset normalizedStart,
    Offset normalizedEnd,
    DrawingElementType elementType,
    Color effectiveColor,
    double effectiveStrokeWidth,
    double effectiveDensity,
    double effectiveCurvature,
    TriangleCutType effectiveTriangleCut,
    MapLayer selectedLayer,
    Uint8List? imageBufferData,
    BoxFit imageBufferFit,
  ) {
    // 计算新元素的 z 值（比当前最大 z 值大 1）
    final maxZIndex = selectedLayer.elements.isEmpty
        ? 0
        : selectedLayer.elements
              .map((e) => e.zIndex)
              .reduce((a, b) => a > b ? a : b);

    final element = MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: elementType,
      points: [normalizedStart, normalizedEnd],
      color: effectiveColor,
      strokeWidth: effectiveStrokeWidth,
      density: effectiveDensity,
      curvature: effectiveCurvature,
      triangleCut: effectiveTriangleCut,
      zIndex: maxZIndex + 1,
      createdAt: DateTime.now(),
      // 对于图片选区工具，将缓冲区数据复制到元素中，使其独立于缓冲区
      imageData: elementType == DrawingElementType.imageArea
          ? imageBufferData
          : null,
      imageFit: elementType == DrawingElementType.imageArea
          ? imageBufferFit
          : null,
    );

    final updatedLayer = selectedLayer.copyWith(
      elements: [...selectedLayer.elements, element],
      updatedAt: DateTime.now(),
    );

    onLayerUpdated?.call(updatedLayer);
  }

  /// 清理绘制状态
  void _clearDrawingState() {
    _isDrawing = false;
    _currentDrawingStart = null;
    _currentDrawingEnd = null;
    _drawingPreviewNotifier.value = null; // 清除预览
  }

  /// 专门用于绘制操作的坐标获取，会进行边界限制
  Offset _getClampedCanvasPosition(Offset localPosition) {
    final clampedX = localPosition.dx.clamp(0.0, kCanvasWidth);
    final clampedY = localPosition.dy.clamp(0.0, kCanvasHeight);
    return Offset(clampedX, clampedY);
  }

  /// 重置绘制状态（用于外部调用）
  void resetDrawingState() {
    _clearDrawingState();
    _freeDrawingPath.clear();
  }

  /// 检查是否正在进行特定类型的绘制
  bool isDrawingType(DrawingElementType type) {
    final previewData = _drawingPreviewNotifier.value;
    return _isDrawing && previewData != null && previewData.elementType == type;
  }

  /// 获取当前绘制的预览数据
  DrawingPreviewData? getCurrentPreviewData() {
    return _drawingPreviewNotifier.value;
  }

  /// 强制更新预览
  void updatePreview(DrawingPreviewData? previewData) {
    _drawingPreviewNotifier.value = previewData;
  }

  /// 清理资源
  void dispose() {
    _drawingPreviewNotifier.dispose();
  }

  /// 8. 开始在便签上绘制
  void onStickyNoteDrawingStart(
    DragStartDetails details,
    StickyNote targetStickyNote,
    DrawingElementType? effectiveDrawingTool,
    Color effectiveColor,
    double effectiveStrokeWidth,
    double effectiveDensity,
    double effectiveCurvature,
    TriangleCutType effectiveTriangleCut,
    Function(StickyNote) onStickyNoteUpdated, {
    Uint8List? imageBufferData, // 图片缓冲区数据
    BoxFit imageBufferFit = BoxFit.contain, // 图片适应方式
  }) {
    if (effectiveDrawingTool == null) return;

    _currentDrawingStickyNote = targetStickyNote;

    // Convert canvas position to sticky note local coordinates
    final stickyNotePosition = _convertCanvasToStickyNoteCoordinates(
      details.localPosition,
      targetStickyNote,
    );

    _currentDrawingStart = stickyNotePosition;
    _currentDrawingEnd = _currentDrawingStart;
    _isDrawing = true;

    if (effectiveDrawingTool == DrawingElementType.freeDrawing) {
      _freeDrawingPath.clear();
      _freeDrawingPath.add(stickyNotePosition);
    }

    // Update preview for sticky note drawing
    _drawingPreviewNotifier.value = DrawingPreviewData(
      start: stickyNotePosition,
      end: stickyNotePosition,
      elementType: effectiveDrawingTool,
      color: effectiveColor,
      strokeWidth: effectiveStrokeWidth,
      density: effectiveDensity,
      curvature: effectiveCurvature,
      triangleCut: effectiveTriangleCut,
      freeDrawingPath: effectiveDrawingTool == DrawingElementType.freeDrawing
          ? List.from(_freeDrawingPath)
          : null,
      targetStickyNote: targetStickyNote,
    );
  }

  /// 9. 更新便签上的绘制
  void onStickyNoteDrawingUpdate(
    DragUpdateDetails details,
    DrawingElementType? effectiveDrawingTool,
    Color effectiveColor,
    double effectiveStrokeWidth,
    double effectiveDensity,
    double effectiveCurvature,
    TriangleCutType effectiveTriangleCut,
  ) {
    if (!_isDrawing ||
        _currentDrawingStickyNote == null ||
        effectiveDrawingTool == null)
      return;

    // Convert canvas position to sticky note local coordinates
    final stickyNotePosition = _convertCanvasToStickyNoteCoordinates(
      details.localPosition,
      _currentDrawingStickyNote!,
    );

    _currentDrawingEnd = stickyNotePosition;

    if (effectiveDrawingTool == DrawingElementType.freeDrawing) {
      _freeDrawingPath.add(stickyNotePosition);

      _drawingPreviewNotifier.value = DrawingPreviewData(
        start: _currentDrawingStart!,
        end: _currentDrawingEnd!,
        elementType: effectiveDrawingTool,
        color: effectiveColor,
        strokeWidth: effectiveStrokeWidth,
        density: effectiveDensity,
        curvature: effectiveCurvature,
        triangleCut: effectiveTriangleCut,
        freeDrawingPath: List.from(_freeDrawingPath),
        targetStickyNote: _currentDrawingStickyNote,
      );
      return;
    }

    _drawingPreviewNotifier.value = DrawingPreviewData(
      start: _currentDrawingStart!,
      end: _currentDrawingEnd!,
      elementType: effectiveDrawingTool,
      color: effectiveColor,
      strokeWidth: effectiveStrokeWidth,
      density: effectiveDensity,
      curvature: effectiveCurvature,
      triangleCut: effectiveTriangleCut,
      freeDrawingPath: null,
      targetStickyNote: _currentDrawingStickyNote,
    );
  }

  /// 10. 结束便签上的绘制
  void onStickyNoteDrawingEnd(
    DragEndDetails details,
    DrawingElementType? effectiveDrawingTool,
    Color effectiveColor,
    double effectiveStrokeWidth,
    double effectiveDensity,
    double effectiveCurvature,
    TriangleCutType effectiveTriangleCut,
    Function(StickyNote) onStickyNoteUpdated, {
    Uint8List? imageBufferData, // 图片缓冲区数据
    BoxFit imageBufferFit = BoxFit.contain, // 图片适应方式
  }) {
    if (!_isDrawing ||
        _currentDrawingStickyNote == null ||
        _currentDrawingStart == null ||
        _currentDrawingEnd == null ||
        effectiveDrawingTool == null) {
      _clearStickyNoteDrawingState();
      return;
    } // 调试信息：检查图片选区工具的缓冲区数据
    if (effectiveDrawingTool == DrawingElementType.imageArea) {
      debugPrint(
        '便签创建图片选区: 缓冲区数据=${imageBufferData != null ? '${imageBufferData.length} bytes' : 'null'}',
      );
    }

    // 处理不同类型的绘制工具
    if (effectiveDrawingTool == DrawingElementType.eraser) {
      // 橡皮擦处理：创建橡皮擦元素
      final eraserElement = _createStickyNoteDrawingElement(
        _currentDrawingStart!,
        _currentDrawingEnd!,
        effectiveDrawingTool,
        Colors.transparent, // 橡皮擦颜色透明
        0.0, // 橡皮擦不需要笔触宽度
        effectiveDensity,
        effectiveCurvature,
        effectiveTriangleCut,
      );

      // Add eraser element to sticky note
      final updatedStickyNote = _currentDrawingStickyNote!.addElement(
        eraserElement,
      );
      onStickyNoteUpdated(updatedStickyNote);
    } else if (effectiveDrawingTool == DrawingElementType.freeDrawing) {
      // 自由绘制处理
      if (_freeDrawingPath.isNotEmpty) {
        final freeDrawingElement = _createStickyNoteFreeDrawingElement(
          effectiveColor,
          effectiveStrokeWidth,
          effectiveDensity,
          effectiveCurvature,
        );

        final updatedStickyNote = _currentDrawingStickyNote!.addElement(
          freeDrawingElement,
        );
        onStickyNoteUpdated(updatedStickyNote);
        _freeDrawingPath.clear();
      }
    } else {
      // 标准绘制元素处理
      final element = _createStickyNoteDrawingElement(
        _currentDrawingStart!,
        _currentDrawingEnd!,
        effectiveDrawingTool,
        effectiveColor,
        effectiveStrokeWidth,
        effectiveDensity,
        effectiveCurvature,
        effectiveTriangleCut,
        imageBufferData, // 传递图片缓冲区数据
        imageBufferFit, // 传递图片适应方式
      );

      // Add element to sticky note
      final updatedStickyNote = _currentDrawingStickyNote!.addElement(element);
      onStickyNoteUpdated(updatedStickyNote);
    }

    _clearStickyNoteDrawingState();
  }

  /// Convert canvas coordinates to sticky note local coordinates (0.0-1.0)
  Offset _convertCanvasToStickyNoteCoordinates(
    Offset canvasPosition,
    StickyNote stickyNote,
  ) {
    // Get sticky note bounds in canvas coordinates
    final stickyNoteCanvasPosition = Offset(
      stickyNote.position.dx * kCanvasWidth,
      stickyNote.position.dy * kCanvasHeight,
    );
    final stickyNoteCanvasSize = Size(
      stickyNote.size.width * kCanvasWidth,
      stickyNote.size.height * kCanvasHeight,
    ); // 计算标题栏高度和内容区域偏移（与预览渲染保持一致）
    const double titleBarHeight = 36.0; // 标题栏固定高度
    const double contentPadding = 10.0; // 内容区域的 padding

    // 计算内容区域的实际位置和大小（排除标题栏）
    final contentAreaPosition = Offset(
      stickyNoteCanvasPosition.dx + contentPadding,
      stickyNoteCanvasPosition.dy + titleBarHeight + contentPadding,
    );
    final contentAreaSize = Size(
      stickyNoteCanvasSize.width - (contentPadding * 2),
      stickyNoteCanvasSize.height - titleBarHeight - (contentPadding * 2),
    ); // Calculate relative position within content area (0.0-1.0)
    final relativeX =
        (canvasPosition.dx - contentAreaPosition.dx) / contentAreaSize.width;
    final relativeY =
        (canvasPosition.dy - contentAreaPosition.dy) / contentAreaSize.height;

    // 限制绘制只能在便签的内容区域内（0.0-1.0）
    return Offset(relativeX.clamp(0.0, 1.0), relativeY.clamp(0.0, 1.0));
  }

  /// Create drawing element for sticky note
  MapDrawingElement _createStickyNoteDrawingElement(
    Offset start,
    Offset end,
    DrawingElementType elementType,
    Color color,
    double strokeWidth,
    double density,
    double curvature,
    TriangleCutType triangleCut, [
    Uint8List? imageBufferData, // 图片缓冲区数据
    BoxFit? imageBufferFit, // 图片适应方式
  ]) {
    final stickyNote = _currentDrawingStickyNote!;
    final maxZIndex = stickyNote.elements.isEmpty
        ? 0
        : stickyNote.elements
              .map((e) => e.zIndex)
              .reduce((a, b) => a > b ? a : b);
    List<Offset> points;
    if (elementType == DrawingElementType.freeDrawing) {
      points = List.from(_freeDrawingPath);
    } else {
      points = [start, end];
    } // 调试信息：检查图片选区元素创建
    if (elementType == DrawingElementType.imageArea) {
      debugPrint(
        '创建便签图片选区元素: imageData=${imageBufferData != null ? '${imageBufferData.length} bytes' : 'null'}',
      );
    }

    return MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: elementType,
      points: points,
      color: color,
      strokeWidth: strokeWidth,
      density: density,
      curvature: curvature,
      triangleCut: triangleCut,
      zIndex: maxZIndex + 1,
      createdAt: DateTime.now(),
      // 对于图片选区工具，将缓冲区数据复制到元素中，使其独立于缓冲区
      imageData: elementType == DrawingElementType.imageArea
          ? imageBufferData
          : null,
      imageFit: elementType == DrawingElementType.imageArea
          ? (imageBufferFit ?? BoxFit.contain)
          : null,
    );
  }

  /// Create free drawing element for sticky note
  MapDrawingElement _createStickyNoteFreeDrawingElement(
    Color color,
    double strokeWidth,
    double density,
    double curvature,
  ) {
    final stickyNote = _currentDrawingStickyNote!;
    final maxZIndex = stickyNote.elements.isEmpty
        ? 0
        : stickyNote.elements
              .map((e) => e.zIndex)
              .reduce((a, b) => a > b ? a : b);

    return MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: DrawingElementType.freeDrawing,
      points: List.from(_freeDrawingPath),
      color: color,
      strokeWidth: strokeWidth,
      density: density,
      curvature: curvature,
      triangleCut: TriangleCutType.none, // 自由绘制不需要三角形切割
      zIndex: maxZIndex + 1,
      createdAt: DateTime.now(),
    );
  }

  /// 清理便签绘制状态
  void _clearStickyNoteDrawingState() {
    _currentDrawingStickyNote = null;
    _clearDrawingState();
  }
}
