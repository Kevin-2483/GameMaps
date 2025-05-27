## 透明度优化功能说明

### 问题描述
之前每次修改透明度时，画面都会消失一下，导致卡顿和闪烁。这是因为每次透明度变化都会立即调用 `setState` 更新整个组件状态。

### 优化方案

#### 1. 分离透明度预览和数据更新
- **拖动时**: 只进行视觉预览，不更新实际数据
- **拖动结束**: 延迟更新实际数据，避免频繁数据库操作

#### 2. 实现的关键改进

**LayerPanel 优化 (`layer_panel.dart`)**:
```dart
// 临时透明度值存储
final Map<String, double> _tempOpacityValues = {};
final Map<String, Timer?> _opacityTimers = {};

// 拖动时只更新预览
void _handleOpacityChange(MapLayer layer, double opacity) {
  setState(() {
    _tempOpacityValues[layer.id] = opacity;
  });
  // 立即通知画布进行预览
  widget.onOpacityPreview?.call(layer.id, opacity);
}

// 拖动结束后延迟更新数据
void _handleOpacityChangeEnd(MapLayer layer, double opacity) {
  _opacityTimers[layer.id] = Timer(const Duration(milliseconds: 100), () {
    // 更新实际数据
    final updatedLayer = layer.copyWith(opacity: opacity, updatedAt: DateTime.now());
    widget.onLayerUpdated(updatedLayer);
    // 清除临时值
    setState(() {
      _tempOpacityValues.remove(layer.id);
    });
  });
}
```

**MapCanvas 优化 (`map_canvas.dart`)**:
```dart
// 支持透明度预览值
final Map<String, double> previewOpacityValues;

Widget _buildLayerWidget(MapLayer layer) {
  // 优先使用预览值，否则使用实际值
  final effectiveOpacity = widget.previewOpacityValues[layer.id] ?? layer.opacity;
  
  return Positioned.fill(
    child: Opacity(
      opacity: layer.isVisible ? effectiveOpacity : 0.0,
      child: CustomPaint(/* ... */),
    ),
  );
}
```

**MapEditorPage 优化 (`map_editor_page.dart`)**:
```dart
// 透明度预览状态管理
final Map<String, double> _previewOpacityValues = {};

void _handleOpacityPreview(String layerId, double opacity) {
  setState(() {
    _previewOpacityValues[layerId] = opacity;
  });
}
```

#### 3. 核心优化特性

1. **实时预览**: 拖动滑块时立即看到透明度变化
2. **避免闪烁**: 预览期间不更新实际数据，画面保持流畅
3. **延迟保存**: 拖动结束后短暂延迟再保存，避免频繁数据操作
4. **状态隔离**: 预览状态与实际数据状态分离管理

#### 4. 使用效果

- ✅ 拖动透明度滑块时画面不再闪烁
- ✅ 透明度变化实时平滑显示
- ✅ 减少了不必要的数据库更新操作
- ✅ 提升了用户体验和性能

### 适用场景

这个优化方案同样适用于其他需要实时预览的功能：
- 图层位置拖动
- 颜色选择
- 画笔大小调整
- 其他需要连续调整的参数

### 技术要点

1. **Timer 使用**: 防抖动机制，避免频繁更新
2. **状态分离**: 临时状态与持久状态分开管理
3. **回调链**: 通过回调函数传递预览状态到渲染层
4. **内存管理**: 及时清理定时器和临时状态
