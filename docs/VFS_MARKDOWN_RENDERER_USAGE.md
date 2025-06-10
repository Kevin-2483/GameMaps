# VFS Markdown 渲染器使用指南

## 概述

VFS Markdown 渲染器已经被拆分为独立的组件，支持不同的布局模式：

- **窗口模式** (`VfsMarkdownViewerWindow`) - 在浮动窗口中显示
- **页面模式** (`VfsMarkdownViewerPage`) - 作为完整页面显示
- **核心渲染器** (`VfsMarkdownRenderer`) - 可嵌入任何布局的核心组件

## 架构设计

```
VfsMarkdownRenderer (核心渲染器)
├── VfsMarkdownViewerWindow (窗口组件)
└── VfsMarkdownViewerPage (页面组件)
```

## 使用方式

### 1. 窗口模式 (现有方式保持不变)

```dart
// 在浮动窗口中打开Markdown文件
VfsMarkdownViewerWindow.show(
  context,
  vfsPath: 'indexeddb://r6box/fs/docs/README.md',
  fileInfo: fileInfo, // 可选
  config: VfsFileOpenConfig.forText,
);
```

### 2. 页面模式 (新增)

```dart
// 作为页面打开Markdown文件
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => VfsMarkdownViewerPage(
      vfsPath: 'indexeddb://r6box/fs/docs/README.md',
      fileInfo: fileInfo, // 可选
      onClose: () => Navigator.of(context).pop(),
    ),
  ),
);
```

### 3. 自定义嵌入模式

```dart
// 直接使用核心渲染器
VfsMarkdownRenderer(
  vfsPath: 'indexeddb://r6box/fs/docs/README.md',
  config: MarkdownRendererConfig.embedded, // 无工具栏和状态栏
  onError: (error) => print('Error: $error'),
  onLoaded: () => print('Loaded'),
)
```

## 配置选项

### MarkdownRendererConfig

```dart
/// 预定义配置
MarkdownRendererConfig.window    // 窗口模式：完整工具栏+状态栏
MarkdownRendererConfig.page      // 页面模式：简化工具栏，无状态栏
MarkdownRendererConfig.embedded  // 嵌入模式：无工具栏和状态栏

/// 自定义配置
MarkdownRendererConfig(
  showToolbar: true,               // 是否显示工具栏
  showStatusBar: false,           // 是否显示状态栏
  allowEdit: true,                // 是否允许编辑功能
  customToolbarActions: [         // 自定义工具栏按钮
    IconButton(icon: Icon(Icons.save), onPressed: () {}),
  ],
  customStatusBar: MyCustomStatusBar(), // 自定义状态栏
)
```

## 功能特性

### 核心功能 (所有模式)
- ✅ Markdown 语法渲染
- ✅ VFS 协议链接支持
- ✅ VFS 协议图片支持
- ✅ 外部链接支持
- ✅ 相对路径链接解析
- ✅ 锚点链接跳转
- ✅ 主题切换 (深色/浅色)
- ✅ 内容缩放 (50%-300%)
- ✅ 目录导航 (TOC)

### 窗口模式特有功能
- ✅ 完整工具栏
- ✅ 状态栏 (行数、字数、字符数、文件大小、缩放比例)
- ✅ 在文本编辑器中打开
- ✅ 复制内容
- ✅ 刷新功能

### 页面模式特有功能
- ✅ 应用栏 (AppBar)
- ✅ 面包屑导航
- ✅ 文件信息对话框
- ✅ 在窗口中打开功能
- ✅ 全屏模式 (开发中)
- ✅ 分享功能 (开发中)

## 布局对比

### 窗口模式布局
```
┌─── FloatingWindow ────────────────┐
│ ┌─ Header (title, subtitle) ────┐ │
│ └─────────────────────────────────┘ │
│ ┌─ Toolbar ─────────────────────┐ │
│ │ [目录] [主题] [缩放] ... [刷新] │ │
│ └─────────────────────────────────┘ │
│ ┌─ Content ─────────────────────┐ │
│ │ [TOC Panel] │ [Markdown]      │ │
│ └─────────────────────────────────┘ │
│ ┌─ StatusBar ───────────────────┐ │
│ │ 行数 | 字数 | 字符数 | 缩放    │ │
│ └─────────────────────────────────┘ │
└───────────────────────────────────┘
```

### 页面模式布局
```
┌─── AppBar ─────────────────────────┐
│ [<] Title               [⛶] [⋮]   │
└─────────────────────────────────────┘
┌─── PageToolbar ────────────────────┐
│ 📁 database > collection > file.md │
└─────────────────────────────────────┘
┌─── Toolbar ─────────────────────────┐
│ [目录] [主题] [缩放] ... [<] [⛶]    │
└─────────────────────────────────────┘
┌─── Content ─────────────────────────┐
│ [TOC Panel] │ [Markdown Content]    │
└─────────────────────────────────────┘
```

## 扩展开发

### 添加自定义工具栏按钮

```dart
VfsMarkdownRenderer(
  vfsPath: vfsPath,
  config: MarkdownRendererConfig(
    customToolbarActions: [
      IconButton(
        icon: const Icon(Icons.bookmark),
        onPressed: () => _addBookmark(),
        tooltip: '添加书签',
      ),
      IconButton(
        icon: const Icon(Icons.print),
        onPressed: () => _printDocument(),
        tooltip: '打印',
      ),
    ],
  ),
)
```

### 添加自定义状态栏

```dart
VfsMarkdownRenderer(
  vfsPath: vfsPath,
  config: MarkdownRendererConfig(
    customStatusBar: Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Text('自定义状态信息'),
          Spacer(),
          Text('阅读时间: 5分钟'),
        ],
      ),
    ),
  ),
)
```

## 迁移指南

### 从旧窗口组件迁移

旧代码不需要修改，`VfsMarkdownViewerWindow.show()` 方法保持完全兼容。

### 新增页面模式

在需要全屏显示Markdown文件的地方，使用新的页面组件：

```dart
// 旧方式 (窗口)
VfsMarkdownViewerWindow.show(context, vfsPath: path);

// 新方式 (页面)
Navigator.push(context, MaterialPageRoute(
  builder: (context) => VfsMarkdownViewerPage(vfsPath: path),
));
```

## 技术实现

### 组件分层
1. **VfsMarkdownRenderer** - 核心渲染逻辑，无UI框架依赖
2. **VfsMarkdownViewerWindow** - 窗口包装器，使用FloatingWindow
3. **VfsMarkdownViewerPage** - 页面包装器，使用Scaffold + AppBar

### 配置系统
- 使用 `MarkdownRendererConfig` 统一管理不同模式的配置
- 预定义的配置模板简化使用
- 支持完全自定义的配置选项

### 功能复用
- 所有核心功能在渲染器中实现
- 窗口和页面组件只负责UI框架和交互
- 配置系统确保功能的灵活性和可扩展性

这种设计使得Markdown渲染功能既可以作为浮动窗口使用，也可以作为完整页面使用，同时保持代码的复用性和可维护性。
