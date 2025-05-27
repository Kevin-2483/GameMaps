# 绘制工具优化功能说明

## 问题描述
之前每次选择绘制工具、颜色或改变线条粗细时，整个地图编辑页面都会重新构建，导致地图画布闪烁和性能问题。这是因为每次工具状态变化都会立即调用主页面的 `setState` 更新整个组件状态。

## 优化方案

### 1. 分离工具选择预览和数据更新
- **选择时**: 只进行视觉预览，不更新主页面状态
- **选择结束**: 延迟更新实际数据，避免频繁的主页面重建

### 2. 实现的关键改进

**DrawingToolbarOptimized 优化 (`drawing_toolbar_optimized.dart`)**:
```dart
// 临时工具状态存储
DrawingElementType? _tempSelectedTool;
Color? _tempSelectedColor;
double? _tempSelectedStrokeWidth;

// 定时器，用于延迟提交更改
Timer? _toolTimer;
Timer? _colorTimer;
Timer? _strokeWidthTimer;

// 选择时只更新预览
void _handleToolSelection(DrawingElementType? tool) {
  setState(() {
    _tempSelectedTool = tool;
  });
  // 立即通知画布进行预览
  widget.onToolPreview?.call(tool);
  // 延迟更新实际数据
  _toolTimer = Timer(const Duration(milliseconds: 100), () {
    widget.onToolSelected(tool);
  });
}
```

**MapCanvas 优化 (`map_canvas.dart`)**:
```dart
// 支持绘制工具预览值
final DrawingElementType? previewDrawingTool;
final Color? previewColor;
final double? previewStrokeWidth;

// 获取有效的绘制工具状态（预览值或实际值）
DrawingElementType? get _effectiveDrawingTool => widget.previewDrawingTool ?? widget.selectedDrawingTool;
Color get _effectiveColor => widget.previewColor ?? widget.selectedColor;
double get _effectiveStrokeWidth => widget.previewStrokeWidth ?? widget.selectedStrokeWidth;

// 使用有效值进行绘制
CustomPaint(
  painter: _CurrentDrawingPainter(
    elementType: _effectiveDrawingTool!,
    color: _effectiveColor,
    strokeWidth: _effectiveStrokeWidth,
  ),
),
```

**MapEditorPage 优化 (`map_editor_page.dart`)**:
```dart
// 绘制工具预览状态管理
DrawingElementType? _previewDrawingTool;
Color? _previewColor;
double? _previewStrokeWidth;

// 预览处理方法
void _handleDrawingToolPreview(DrawingElementType? tool) {
  setState(() {
    _previewDrawingTool = tool;
  });
}

// 使用优化的工具栏
DrawingToolbarOptimized(
  onToolPreview: _handleDrawingToolPreview,
  onColorPreview: _handleColorPreview,
  onStrokeWidthPreview: _handleStrokeWidthPreview,
)
```

### 3. 核心优化特性

#### 即时预览响应
- 工具选择立即反映在UI上
- 不触发主页面重建
- 保持画布稳定显示

#### 批量状态更新
- 使用定时器延迟批量更新
- 减少不必要的setState调用
- 提高整体性能

#### 分离关注点
- 预览状态与持久数据分离
- 独立的状态管理层
- 更清晰的数据流

### 4. 使用效果

#### 优化前
- 每次选择工具都会导致整个页面重建
- 地图画布会闪烁或消失
- 用户体验不流畅

#### 优化后
- 工具选择响应即时且流畅
- 地图画布保持稳定显示
- 无明显的界面闪烁或卡顿
- 绘制过程更加自然

### 5. 技术细节

#### 状态管理策略
```dart
// 获取有效值的模式
final effectiveValue = previewValue ?? actualValue;
```

#### 定时器管理
```dart
// 取消之前的定时器
_timer?.cancel();
// 设置新的定时器
_timer = Timer(const Duration(milliseconds: 100), () {
  // 更新实际数据
});
```

#### 内存管理
```dart
@override
void dispose() {
  _toolTimer?.cancel();
  _colorTimer?.cancel();
  _strokeWidthTimer?.cancel();
  super.dispose();
}
```

## 结论

通过分离预览状态和持久状态，实现了流畅的绘制工具选择体验。用户在使用绘制工具时不再遇到界面闪烁问题，操作更加自然流畅。这种优化模式也可以应用到其他需要频繁状态更新的UI组件中。
