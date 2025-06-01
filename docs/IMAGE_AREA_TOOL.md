# 图片选区绘制工具数据结构设计

## 概述

新增了一个图片选区绘制工具，允许用户：
1. 选择一个选区（矩形或多边形）
2. 上传一张图片
3. 将图片渲染到选区中，自动拉伸适应选区大小
4. 支持z元素检视器选中和操作

## 数据结构变更

### 1. 新增绘制元素类型

在 `DrawingElementType` 枚举中新增：
```dart
enum DrawingElementType {
  // ...existing types...
  imageArea, // 图片选区
}
```

### 2. MapDrawingElement 类新增字段

```dart
class MapDrawingElement {
  // ...existing fields...
  
  @Uint8ListConverter()
  final Uint8List? imageData; // 图片二进制数据（用于图片选区）
  
  @BoxFitConverter()
  final BoxFit? imageFit; // 图片适应方式（用于图片选区）
  
  // ...
}
```

### 3. 新增 BoxFit JSON 转换器

添加了 `BoxFitConverter` 类来处理 `BoxFit` 枚举的 JSON 序列化：
```dart
class BoxFitConverter implements JsonConverter<BoxFit?, String?> {
  // 支持所有 BoxFit 枚举值的转换
}
```

## 字段说明

### imageData (Uint8List?)
- **用途**: 存储图片的二进制数据
- **类型**: `Uint8List?`，可为空
- **JSON转换**: 使用 `Uint8ListConverter` 进行 base64 编码/解码
- **渲染**: 使用 `Image.memory(imageData)` 进行渲染

### imageFit (BoxFit?)
- **用途**: 控制图片在选区中的适应方式
- **类型**: `BoxFit?`，可为空
- **默认值**: `BoxFit.contain`
- **支持值**:
  - `BoxFit.fill`: 填充整个选区，可能变形
  - `BoxFit.contain`: 保持宽高比，完全显示在选区内
  - `BoxFit.cover`: 保持宽高比，覆盖整个选区
  - `BoxFit.fitWidth`: 适应选区宽度
  - `BoxFit.fitHeight`: 适应选区高度
  - `BoxFit.none`: 原始尺寸
  - `BoxFit.scaleDown`: 缩小到适合选区

### points (List<Offset>)
- **用途**: 定义选区的边界点
- **类型**: `List<Offset>`，相对坐标 (0.0-1.0)
- **矩形选区**: 通常包含4个点（左上、右上、右下、左下）
- **多边形选区**: 可包含任意数量的点

## 使用方式

### 创建矩形图片选区
```dart
final imageElement = MapDrawingElement(
  id: 'img_001',
  type: DrawingElementType.imageArea,
  points: [
    Offset(0.1, 0.1), // 左上
    Offset(0.5, 0.1), // 右上
    Offset(0.5, 0.4), // 右下
    Offset(0.1, 0.4), // 左下
  ],
  imageData: imageBytes, // Uint8List 图片数据
  imageFit: BoxFit.contain,
  zIndex: 1,
  createdAt: DateTime.now(),
);
```

### 更新图片数据
```dart
final updatedElement = imageElement.copyWith(
  imageData: newImageBytes,
  imageFit: BoxFit.cover,
);
```

### 清除图片数据
```dart
final clearedElement = imageElement.copyWith(
  clearImageData: true, // 明确清除图片数据
);
```

## z元素检视器支持

图片选区元素完全支持z元素检视器的所有功能：
- **选中**: 可以被选中并高亮显示
- **移动**: 可以拖拽移动位置
- **调整大小**: 可以调整选区边界
- **旋转**: 支持rotation属性
- **层级调整**: 支持zIndex属性控制绘制顺序
- **删除**: 可以被删除
- **属性编辑**: 可以编辑imageFit等属性

## 渲染实现

在绘制时，应该：
1. 检查 `type == DrawingElementType.imageArea`
2. 检查 `imageData != null && imageData!.isNotEmpty`
3. 使用 `Image.memory(imageData!)` 创建图片组件
4. 根据 `points` 确定选区范围
5. 应用 `imageFit` 属性控制图片适应方式
6. 应用 `rotation` 属性进行旋转
7. 考虑 `zIndex` 属性确定绘制顺序

## JSON 序列化

新字段完全支持JSON序列化：
- `imageData` 通过 base64 编码存储
- `imageFit` 通过字符串枚举存储
- 向后兼容：旧数据中缺失的字段会使用默认值

## 数据存储

- **直接存储**: 图片数据直接存储为 `Uint8List`，不存储文件路径
- **内存渲染**: 使用 `Image.memory()` 直接从内存渲染
- **数据完整性**: 所有图片数据都包含在数据模型中，无外部依赖
