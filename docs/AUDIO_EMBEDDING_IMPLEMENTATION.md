# 音频嵌入功能实现总结

## 📋 功能概述

成功为 Markdown 渲染器添加了完整的音频嵌入功能，模仿视频嵌入的实现模式，支持可折叠的音频播放器。

## 🎯 实现的核心组件

### 1. 音频处理器 (`audio_processor.dart`)
- **AudioProcessor**: 核心音频处理类
  - 支持多种音频格式：MP3、WAV、OGG、AAC、M4A、FLAC、WMA、OPUS
  - 检测 Markdown 中的音频内容
  - 转换 Markdown 图片语法为音频标签
  - 解析音频参数（标题、艺术家、专辑等）
  - 提供音频统计信息

- **AudioNodeConfig**: 音频节点配置类
  - 支持主题适配
  - 提供错误处理回调
  - 实现 WidgetConfig 接口

- **AudioNode**: 音频渲染节点
  - 生成可折叠的音频播放器组件
  - 解析音频属性和参数
  - 支持 VFS 路径和网络 URL

- **AudioSyntax**: 音频语法解析器
  - 解析 HTML audio 标签
  - 提取音频属性和元数据

### 2. 嵌入式音频播放器 (`embedded_audio_player.dart`)
- **EmbeddedAudioPlayer**: 专为 Markdown 嵌入设计的轻量级播放器
  - 默认折叠状态，节省空间
  - 可展开显示详细控制
  - 支持播放/暂停、进度控制、音量调节
  - 支持快进/快退、播放速度调节
  - 美观的 Material Design 界面

- **EmbeddedAudioConfig**: 播放器配置类
  - 自动播放设置
  - 显示信息配置
  - 默认展开/折叠状态
  - 自定义主题色

### 3. Markdown 渲染器集成
更新了 `vfs_markdown_renderer.dart`：
- 添加音频渲染开关 (`_enableAudioRendering`)
- 集成音频预处理流程
- 添加音频渲染切换按钮
- 在状态栏显示音频统计信息
- 添加音频信息对话框
- 支持混合渲染配置（HTML、LaTeX、视频、音频）

## 🎵 支持的音频语法

### 1. Markdown 图片语法
```markdown
![音频标题](audio.mp3)
![title:我的音乐,artist:音乐家,album:专辑名称](music.mp3)
![autoplay](demo.mp3)
![loop](demo.wav)
```

### 2. HTML 音频标签
```html
<audio src="example.mp3" controls></audio>
<audio src="demo.wav" controls autoplay title="标题" artist="艺术家"></audio>
```

## 📁 支持的音频格式
- **MP3** - 最常用的音频格式
- **WAV** - 无损音频格式
- **OGG** - 开源音频格式
- **AAC** - 高级音频编码
- **M4A** - Apple 音频格式
- **FLAC** - 无损压缩格式
- **WMA** - Windows Media Audio
- **OPUS** - 现代音频编解码器

## 🎛️ 播放器功能

### 折叠状态
- 显示音频图标和基本信息
- 播放/暂停按钮
- 展开/折叠切换按钮
- 紧凑的界面设计

### 展开状态
- 完整的进度条控制
- 时间显示（当前/总时长）
- 详细的音频信息显示
- 扩展控制按钮：
  - 快退/快进 10 秒
  - 播放速度调节（0.5x - 2.0x）
  - 音量控制面板

## ⚙️ 配置选项

### 全局配置
- 音频渲染开关（工具栏按钮）
- 主题适配（浅色/深色模式）
- 错误处理和回调

### 播放器配置
```dart
EmbeddedAudioConfig(
  autoPlay: false,           // 自动播放
  showFullInfo: true,        // 显示完整信息
  defaultCollapsed: true,    // 默认折叠
  accentColor: Colors.blue,  // 主题色
)
```

## 📊 状态栏集成
- 显示音频数量统计
- 音频渲染状态指示
- 颜色编码：
  - 绿色：音频渲染已启用
  - 橙色：音频渲染已禁用

## 🔄 与现有功能的集成
- 与视频、HTML、LaTeX 渲染完美协作
- 支持混合渲染配置
- 统一的错误处理机制
- 一致的用户界面风格

## 📝 使用示例

创建了 `audio_test.md` 测试文档，包含：
- 基本音频嵌入示例
- 带参数的音频嵌入
- 自动播放和循环播放
- HTML 音频标签示例
- 多种格式支持演示
- 网络和 VFS 音频示例

## 🎉 实现效果

1. **无缝集成**：音频播放器完美嵌入到 Markdown 文档中
2. **用户友好**：默认折叠节省空间，按需展开详细控制
3. **功能丰富**：支持完整的音频播放功能
4. **响应式设计**：适配不同屏幕尺寸和主题
5. **高性能**：异步加载，不阻塞文档渲染

这个实现为 R6Box 应用提供了强大的音频文档支持能力，让用户可以在 Markdown 文档中轻松嵌入和播放音频内容。
