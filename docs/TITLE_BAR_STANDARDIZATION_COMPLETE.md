# 页面标题栏标准化和拖动功能实现报告

## 概述

本次更新统一了VFS文件管理器、图例管理器、地图册、设置页面和用户偏好设置页面的标题栏格式，并为所有页面添加了窗口拖动功能。

## 主要更改

### 1. 创建了通用可拖动标题栏组件

**文件**: `lib/components/common/draggable_title_bar.dart`

创建了两个标题栏组件：
- `DraggableTitleBar`: 基础可拖动标题栏
- `DraggableTitleBarWithContent`: 带有额外内容区域的可拖动标题栏

#### 主要特性：
- **统一高度**: 所有标题栏高度统一为64像素
- **拖动功能**: 在桌面平台（Windows、Linux、macOS）支持窗口拖动
- **一致样式**: 所有页面使用相同的标题栏样式和颜色主题
- **图标支持**: 每个页面都有对应的图标
- **操作按钮**: 支持在标题栏右侧添加操作按钮

### 2. 更新的页面

#### VFS文件管理器页面
- 替换了原有的头部区域为新的`DraggableTitleBarWithContent`
- 保持了数据库和集合选择下拉菜单的功能
- 图标: `Icons.folder_special`

#### 图例管理页面
- 移除了原有的AppBar，使用新的`DraggableTitleBar`
- 保持了所有操作按钮功能
- 图标: `Icons.legend_toggle`
- 添加了`_buildContent`方法来组织页面内容

#### 地图册页面
- 移除了原有的AppBar，使用新的`DraggableTitleBar`
- 保持了上传本地化文件和调试模式功能
- 图标: `Icons.map`
- 添加了`_buildContent`方法来组织页面内容

#### 设置页面
- 移除了原有的文本标题，使用新的`DraggableTitleBar`
- 图标: `Icons.settings`
- 简化了页面结构

#### 用户偏好设置页面
- 重构为使用Scaffold和新的`DraggableTitleBar`
- 将原有的标题栏操作按钮移到了标题栏的actions中
- 图标: `Icons.tune`

### 3. 拖动功能实现

所有页面现在都支持窗口拖动：
- **桌面平台**: 点击并拖动标题栏可以移动窗口
- **Web平台**: 自动禁用拖动功能
- **移动平台**: 自动禁用拖动功能

拖动功能使用`bitsdojo_window`包的`appWindow.startDragging()`方法实现。

## 技术实现细节

### 拖动区域检测
```dart
final isDraggable = !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

GestureDetector(
  behavior: HitTestBehavior.translucent,
  onPanStart: isDraggable ? (details) {
    appWindow.startDragging();
  } : null,
  child: titleContent,
)
```

### 统一样式
所有标题栏使用相同的：
- 背景色: `Theme.of(context).colorScheme.primaryContainer`
- 前景色: `Theme.of(context).colorScheme.primary`
- 字体样式: `headlineSmall` with `FontWeight.bold`
- 边框: 底部有淡色边框

## 兼容性

- **桌面平台**: 完全支持拖动功能
- **Web平台**: 所有功能正常，但禁用拖动
- **移动平台**: 所有功能正常，但禁用拖动

## 受影响的文件

1. `lib/components/common/draggable_title_bar.dart` (新建)
2. `lib/pages/vfs/vfs_file_manager_page.dart` (修改)
3. `lib/pages/legend_manager/legend_manager_page.dart` (修改)
4. `lib/pages/map_atlas/map_atlas_page.dart` (修改)
5. `lib/pages/settings/settings_page.dart` (修改)
6. `lib/pages/settings/user_preferences_page.dart` (修改)

## 用户体验改进

1. **一致性**: 所有页面现在都有统一的外观和感觉
2. **拖动性**: 桌面用户可以通过拖动标题栏来移动窗口
3. **可访问性**: 保持了所有原有的功能和操作按钮
4. **响应式**: 标题栏在不同屏幕尺寸下都能正常工作

## 注意事项

- 拖动功能仅在桌面平台启用，确保了跨平台兼容性
- 所有原有的页面功能都被保留
- 样式更改遵循Material Design规范
- 代码结构更加模块化和可重用

这次更新成功地统一了所有主要页面的标题栏格式，并为桌面用户提供了更好的窗口管理体验。
