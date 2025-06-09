# 浮动窗口组件使用指南

## 概述

`FloatingWindow` 是一个通用的浮动窗口组件，模仿了VFS文件选择器的设计风格，提供统一的浮动窗口外观和行为。

## 特性

- 🎨 **统一设计风格** - 与VFS文件选择器保持一致的外观
- 📱 **响应式设计** - 自动适应不同屏幕尺寸
- 🖱️ **拖拽支持** - 支持拖拽移动窗口位置
- 🔧 **高度可定制** - 丰富的配置选项
- 🏗️ **构建器模式** - 支持链式调用配置
- ⚡ **扩展方法** - 提供便捷的快速创建方式

## 基本使用

### 1. 简单的浮动窗口

```dart
FloatingWindow.show(
  context,
  title: '窗口标题',
  child: YourContentWidget(),
);
```

### 2. 带图标和副标题

```dart
FloatingWindow.show(
  context,
  title: '设置',
  subtitle: '配置应用程序设置',
  icon: Icons.settings,
  child: SettingsWidget(),
);
```

### 3. 自定义尺寸

```dart
FloatingWindow.show(
  context,
  title: '小窗口',
  widthRatio: 0.6,   // 60%屏幕宽度
  heightRatio: 0.4,  // 40%屏幕高度
  minSize: Size(400, 300),  // 最小尺寸
  child: SmallContentWidget(),
);
```

### 4. 可拖拽窗口

```dart
FloatingWindow.show(
  context,
  title: '可拖拽窗口',
  draggable: true,
  child: DraggableContentWidget(),
);
```

### 5. 带操作按钮

```dart
FloatingWindow.show(
  context,
  title: '文件管理',
  headerActions: [
    IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () => refreshFiles(),
      tooltip: '刷新',
    ),
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () => openSettings(),
      tooltip: '设置',
    ),
  ],
  child: FileManagerWidget(),
);
```

## 构建器模式

使用 `FloatingWindowBuilder` 可以更优雅地配置复杂的窗口：

```dart
FloatingWindowBuilder()
    .title('高级窗口')
    .icon(Icons.advanced)
    .subtitle('使用构建器模式创建')
    .size(widthRatio: 0.8, heightRatio: 0.7)
    .constraints(minSize: Size(600, 400), maxSize: Size(1200, 800))
    .draggable()
    .headerActions([
      IconButton(icon: Icon(Icons.help), onPressed: showHelp),
    ])
    .borderRadius(20)
    .barrierColor(Colors.black87)
    .child(ComplexContentWidget())
    .show(context);
```

## 扩展方法

为了快速创建简单的浮动窗口，可以使用 `BuildContext` 扩展方法：

```dart
// 简单窗口
context.showFloatingWindow(
  title: '快速窗口',
  child: SimpleContentWidget(),
);

// 或者获取构建器
context.floatingWindow
    .title('构建器窗口')
    .child(ContentWidget())
    .show();
```

## 配置选项

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `title` | `String` | 必需 | 窗口标题 |
| `child` | `Widget` | 必需 | 窗口内容 |
| `icon` | `IconData?` | `null` | 标题图标 |
| `subtitle` | `String?` | `null` | 副标题 |
| `widthRatio` | `double` | `0.9` | 窗口宽度比例 |
| `heightRatio` | `double` | `0.9` | 窗口高度比例 |
| `minSize` | `Size?` | `null` | 最小尺寸限制 |
| `maxSize` | `Size?` | `null` | 最大尺寸限制 |
| `draggable` | `bool` | `false` | 是否支持拖拽 |
| `resizable` | `bool` | `false` | 是否支持调整大小 |
| `headerActions` | `List<Widget>?` | `null` | 头部操作按钮 |
| `showCloseButton` | `bool` | `true` | 是否显示关闭按钮 |
| `barrierColor` | `Color?` | `Colors.black54` | 背景遮罩颜色 |
| `borderRadius` | `double` | `16.0` | 窗口圆角半径 |
| `shadows` | `List<BoxShadow>?` | 默认阴影 | 自定义阴影效果 |

## 在现有VFS文件选择器中的应用

您可以将现有的VFS文件选择器迁移到使用这个通用组件：

```dart
// 原来的VFS文件选择器调用
VfsFileManagerWindow.show(context, ...);

// 改为使用通用浮动窗口
FloatingWindow.show(
  context,
  title: 'VFS 文件管理器',
  icon: Icons.folder_special,
  child: VfsFileManagerContent(), // 将原来的内容提取为独立组件
);
```

## VFS 文件选择器迁移示例

以下是将现有VFS文件选择器迁移到FloatingWindow的完整示例：

### 迁移前（自定义浮动窗口结构）

```dart
@override
Widget build(BuildContext context) {
  return Material(
    color: Colors.transparent,
    child: Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(), // 自定义头部
          Expanded(child: _buildContent()),
        ],
      ),
    ),
  );
}
```

### 迁移后（使用FloatingWindow）

```dart
@override
Widget build(BuildContext context) {
  final isSelectionMode = widget.onFilesSelected != null;
  
  return FloatingWindow(
    title: isSelectionMode ? '选择文件' : 'VFS 文件管理器',
    subtitle: _buildSubtitle(),
    icon: Icons.folder_special,
    onClose: widget.onClose,
    headerActions: _buildActionButtons(),
    child: Column(
      children: [
        _buildToolbar(),
        Expanded(child: _buildContent()),
      ],
    ),
  );
}

// 辅助方法
String? _buildSubtitle() {
  final isSelectionMode = widget.onFilesSelected != null;
  if (!isSelectionMode) return null;
  
  String subtitle = _buildSelectionModeDescription();
  if (_selectedFiles.isNotEmpty) {
    subtitle += ' - 已选择 ${_selectedFiles.length} 个项目';
  }
  return subtitle;
}

List<Widget> _buildActionButtons() {
  final isSelectionMode = widget.onFilesSelected != null;
  
  if (isSelectionMode) {
    return [
      TextButton(
        onPressed: widget.onClose,
        child: const Text('取消'),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: _canConfirmSelection() ? _confirmSelection : null,
        child: const Text('确认'),
      ),
    ];
  } else {
    return [
      IconButton(
        onPressed: widget.onClose,
        icon: const Icon(Icons.close),
        tooltip: '关闭',
      ),
    ];
  }
}
```

### 迁移收益

1. **代码简化**：移除了约50行自定义UI代码
2. **设计一致性**：自动获得统一的浮动窗口外观
3. **功能增强**：自动获得拖拽、响应式设计等功能
4. **维护性提升**：样式更新只需修改FloatingWindow组件

## 样式自定义

组件会自动使用当前主题的颜色方案，包括：

- 主色调 (`colorScheme.primary`)
- 表面颜色 (`colorScheme.surface`)
- 主容器颜色 (`colorScheme.primaryContainer`)

如需自定义样式，可以通过 `shadows` 参数提供自定义阴影效果，或者通过 `borderRadius` 调整圆角。

## 注意事项

1. **性能考虑**：对于复杂内容，建议使用状态管理来避免不必要的重建
2. **拖拽限制**：拖拽功能会自动限制窗口在屏幕可见区域内
3. **响应式设计**：组件会根据屏幕尺寸自动调整，但建议为小屏幕设备提供合适的最小尺寸
4. **键盘导航**：组件支持标准的键盘导航和焦点管理

## 示例项目

完整的使用示例请参考 `lib/components/examples/floating_window_examples.dart` 文件。
