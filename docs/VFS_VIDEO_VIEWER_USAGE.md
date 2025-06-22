# VFS 视频查看器使用指南

## 概述

VFS 视频查看器已经集成到系统中，支持两种显示模式：

- **窗口模式** (`VfsVideoViewerWindow`) - 在浮动窗口中显示
- **页面模式** (`VfsVideoViewerPage`) - 作为完整页面显示
- **核心播放器** (`MediaKitVideoPlayer`) - 可嵌入任何布局的核心组件

## 架构设计

```
MediaKitVideoPlayer (核心播放器 - 支持VFS协议)
├── VfsVideoViewerWindow (窗口组件)
└── VfsVideoViewerPage (页面组件)
```

## 支持的视频格式

- **MP4** (.mp4)
- **AVI** (.avi) 
- **MOV** (.mov)
- **WMV** (.wmv)

更多格式的支持依赖于 media_kit 库的能力。

## 使用方式

### 1. 窗口模式 (推荐)

```dart
// 在浮动窗口中打开视频文件
VfsVideoViewerWindow.show(
  context,
  vfsPath: 'indexeddb://r6box/fs/videos/sample.mp4',
  fileInfo: fileInfo, // 可选
  config: VfsFileOpenConfig.forVideo,
);
```

### 2. 页面模式

```dart
// 作为页面打开视频文件
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => VfsVideoViewerPage(
      vfsPath: 'indexeddb://r6box/fs/videos/sample.mp4',
      fileInfo: fileInfo, // 可选
      onClose: () => Navigator.of(context).pop(),
    ),
  ),
);
```

### 3. 通过文件打开服务 (自动识别)

```dart
// 系统会自动识别视频文件并使用合适的查看器
await VfsFileOpenerService.openFile(
  context,
  'indexeddb://r6box/fs/videos/sample.mp4',
  fileInfo: fileInfo, // 可选
);
```

### 4. 直接使用核心播放器组件

```dart
// 在自定义布局中嵌入视频播放器
MediaKitVideoPlayer(
  url: 'indexeddb://r6box/fs/videos/sample.mp4',
  config: MediaKitVideoConfig(
    autoPlay: true,
    looping: false,
    aspectRatio: 16 / 9,
  ),
  muted: false,
)
```

## 配置选项

### VfsFileOpenConfig.forVideo

默认的视频查看器窗口配置：

```dart
static const VfsFileOpenConfig forVideo = VfsFileOpenConfig(
  widthRatio: 0.9,      // 90% 屏幕宽度
  heightRatio: 0.8,     // 80% 屏幕高度
  draggable: true,      // 可拖拽
  resizable: true,      // 可调整大小
  barrierDismissible: true, // 点击外部可关闭
);
```

### MediaKitVideoConfig

视频播放器配置：

```dart
MediaKitVideoConfig(
  aspectRatio: 16 / 9,  // 视频宽高比
  autoPlay: false,      // 是否自动播放
  looping: false,       // 是否循环播放
  maxWidth: 800,        // 最大宽度
  maxHeight: 450,       // 最大高度
)
```

## 功能特性

### 窗口模式特性
- 📱 响应式窗口大小调整
- 🖱️ 拖拽移动窗口
- 🎮 播放控制工具栏
- 🔇 音量控制和静音
- 🔄 循环播放开关
- 📋 复制链接功能
- ℹ️ 视频信息查看

### 页面模式特性
- 🌓 全屏播放支持
- 🎯 沉浸式播放体验
- 🎮 完整的播放控制
- 📱 移动友好的界面
- 🔄 全屏/窗口模式切换

### VFS 协议支持
- 🗄️ 支持 `indexeddb://` 协议的视频文件
- 📦 自动处理VFS文件URL转换
- 💾 支持大文件(4MB以下)的在线播放
- 🔄 自动资源清理和内存管理

## Markdown 中的视频链接

在 Markdown 文件中，可以使用以下方式引用VFS视频：

```markdown
<!-- 使用图片语法引用视频文件 -->
![视频演示](indexeddb://r6box/fs/videos/demo.mp4)

<!-- 使用HTML video标签 -->
<video controls>
  <source src="indexeddb://r6box/fs/videos/demo.mp4" type="video/mp4">
  您的浏览器不支持视频标签。
</video>

<!-- 使用链接方式 -->
[观看演示视频](indexeddb://r6box/fs/videos/demo.mp4)
```

当在 Markdown 渲染器中点击这些视频链接时，会自动打开视频查看器。

## 错误处理

### 常见错误和解决方案

1. **"VFS视频加载失败: 无法为VFS视频文件生成可播放URL"**
   - 原因：文件超过4MB限制
   - 解决：压缩视频文件或使用外部链接

2. **"视频初始化失败"**
   - 原因：不支持的视频格式或文件损坏
   - 解决：检查视频格式，确保是支持的格式

3. **"播放器初始化失败"**
   - 原因：media_kit库初始化问题
   - 解决：重启应用或检查media_kit库状态

## 最佳实践

### 1. 视频文件管理
```dart
// 建议的视频文件命名规范
indexeddb://r6box/fs/videos/category/filename_resolution.mp4

// 示例
indexeddb://r6box/fs/videos/tutorials/react_basics_720p.mp4
indexeddb://r6box/fs/videos/demos/feature_demo_1080p.mp4
```

### 2. 性能优化
- 保持视频文件在4MB以下以获得最佳性能
- 使用适当的视频分辨率（推荐720p或1080p）
- 对于大文件，考虑使用外部链接而非VFS存储

### 3. 用户体验
- 为视频文件提供缩略图
- 在Markdown中添加视频描述
- 使用有意义的文件名

## 开发集成

### 添加自定义视频处理

```dart
// 扩展视频文件类型支持
case 'webm':
case 'mkv':
  return VfsFileType.video;

// 自定义视频播放器配置
final customConfig = MediaKitVideoConfig(
  aspectRatio: 4 / 3,  // 自定义宽高比
  autoPlay: true,
  looping: true,
  maxWidth: 1200,
  maxHeight: 900,
);
```

### 监听播放事件

```dart
// 在MediaKitVideoPlayer中可以监听播放状态
_player.stream.position.listen((position) {
  print('播放位置: $position');
});

_player.stream.buffering.listen((buffering) {
  print('缓冲状态: $buffering');
});
```

## 技术细节

### 跨平台支持
- ✅ Windows (使用 media_kit_libs_windows_video)
- ✅ macOS (使用 media_kit_libs_macos_video)  
- ✅ Linux (使用 media_kit_libs_linux_video)
- ✅ Android (使用 media_kit_libs_android_video)
- ✅ iOS (使用 media_kit_libs_ios_video)
- ✅ Web (使用 media_kit_libs_web_video)

### VFS协议处理流程
1. 检测到 `indexeddb://` 协议
2. 通过 VfsServiceProvider 读取文件数据
3. 转换为平台特定的可播放URL
4. 传递给 media_kit 播放器
5. 播放结束后自动清理资源

## 故障排除

### 调试模式
启用详细日志以排查问题：

```dart
// 在MediaKitVideoPlayer中已经包含了调试日志
print('🎥 MediaKitVideoPlayer: 开始初始化VFS视频 - $url');
print('🎥 MediaKitVideoPlayer: 成功生成VFS视频URL - $playableUrl');
```

### 常见问题检查清单
- [ ] 确认视频文件在VFS中存在
- [ ] 检查文件路径格式是否正确
- [ ] 验证视频格式是否受支持
- [ ] 确认文件大小不超过4MB
- [ ] 检查媒体库是否正确初始化

## 更新日志

### v1.0.0
- ✅ 基本的视频窗口查看器
- ✅ VFS协议支持
- ✅ 多平台兼容
- ✅ 基本的播放控制
- ✅ 错误处理和重试机制

### 计划中的功能
- 📊 视频播放进度保存
- 🎬 视频缩略图生成
- 📱 移动端优化
- 🎵 音频轨道选择
- 📝 字幕支持
