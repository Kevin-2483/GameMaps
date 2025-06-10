# Markdown 渲染器拆分完成

## 🎉 拆分成功

Markdown 渲染器已成功拆分为三个独立的组件：

### 1. 核心渲染器 (`VfsMarkdownRenderer`)
```dart
// 最基础的渲染组件，可嵌入任何布局
VfsMarkdownRenderer(
  vfsPath: 'indexeddb://r6box/fs/docs/README.md',
  config: MarkdownRendererConfig.embedded,
)
```

### 2. 窗口组件 (`VfsMarkdownViewerWindow`)
```dart
// 原有的浮动窗口模式，API 保持不变
VfsMarkdownViewerWindow.show(
  context,
  vfsPath: 'indexeddb://r6box/fs/docs/README.md',
  config: VfsFileOpenConfig.forText,
);
```

### 3. 页面组件 (`VfsMarkdownViewerPage`)
```dart
// 全新的页面模式，适合全屏显示
Navigator.push(context, MaterialPageRoute(
  builder: (context) => VfsMarkdownViewerPage(
    vfsPath: 'indexeddb://r6box/fs/docs/README.md',
  ),
));
```

## 🔧 配置模式

### 预设配置
- `MarkdownRendererConfig.window` - 窗口模式：完整功能
- `MarkdownRendererConfig.page` - 页面模式：简化工具栏
- `MarkdownRendererConfig.embedded` - 嵌入模式：纯渲染

### 自定义配置
```dart
MarkdownRendererConfig(
  showToolbar: true,
  showStatusBar: false,
  allowEdit: true,
  customToolbarActions: [
    IconButton(icon: Icon(Icons.save), onPressed: () {}),
  ],
)
```

## 📱 演示页面

访问 `/demo/markdown` 路径可以查看三种模式的演示：

1. **窗口模式演示** - 传统的浮动窗口
2. **页面模式演示** - 全屏页面显示
3. **嵌入模式演示** - 自定义布局集成

## ✅ 保持的功能

- VFS 协议链接支持
- VFS 协议图片支持  
- 外部链接支持
- 相对路径解析
- 锚点链接跳转
- 主题切换
- 内容缩放
- 目录导航 (TOC)
- 文本编辑器集成
- 内容复制
- 刷新功能

## 🔄 迁移指南

### 现有代码无需修改
原有的 `VfsMarkdownViewerWindow.show()` 调用方式完全兼容。

### 新增页面模式
```dart
// 在需要全屏显示的地方使用页面模式
Navigator.push(context, MaterialPageRoute(
  builder: (context) => VfsMarkdownViewerPage(
    vfsPath: vfsPath,
    onClose: () => Navigator.pop(context),
  ),
));
```

### 自定义集成
```dart
// 嵌入到自定义布局中
Container(
  child: VfsMarkdownRenderer(
    vfsPath: vfsPath,
    config: MarkdownRendererConfig.embedded,
  ),
)
```

拆分工作已完成！✨
