# R6Box - 跨平台智能地图编辑器

<div align="center">

![R6Box Logo](assets/icon/icon.png)

**一个功能强大的跨平台地图编辑器，专为游戏地图设计和战术规划而生**

[![Flutter](https://img.shields.io/badge/Flutter-3.8.0+-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Web-blue)](#支持平台)
[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

[功能特性](#-功能特性) • [快速开始](#-快速开始) • [使用说明](#-使用说明) • [构建指南](#-构建指南) • [贡献指南](#-贡献指南)

</div>

## 📸 应用截图

<div align="center">

| 主页界面 | 地图编辑器 |
|:---:|:---:|
| ![主页](screenshot/主页.png) | ![地图编辑器](screenshot/地图册页面.png) |

| 图例管理 | 用户设置 |
|:---:|:---:|
| ![图例管理](screenshot/图例管理页面.png) | ![用户设置](screenshot/用户偏好设置页.png) |

</div>

## ✨ 功能特性

### 🎯 核心功能
- **🗺️ 智能地图编辑器** - 支持多图层编辑、绘制工具、元素管理
- **📋 图例系统** - 完整的图例创建、管理和绑定功能
- **📝 便签系统** - 支持富文本便签，可添加到地图任意位置
- **🎨 绘制工具** - 线条、矩形、圆形、文本等多种绘制工具
- **📱 响应式设计** - 适配不同屏幕尺寸和设备类型

### 🚀 高级特性
- **🔄 响应式架构** - 基于 Bloc 模式的状态管理
- **⚡ 异步脚本引擎** - 支持 Hetu Script 的多线程脚本执行
- **💾 虚拟文件系统** - 统一的跨平台文件存储抽象层
- **🎭 主题系统** - 支持亮色/暗色主题，Material You 设计
- **🌍 国际化** - 支持中文和英文界面
- **🔧 用户偏好** - 丰富的个性化设置选项

### 🛠️ 技术特性
- **📊 数据管理** - SQLite 数据库存储，支持数据导入导出
- **🎵 多媒体支持** - 音频播放、视频查看功能
- **📱 平台适配** - 针对不同平台的原生UI适配
- **🔒 安全性** - 数据加密存储，权限管理
- **⚡ 性能优化** - 智能缓存、懒加载、内存管理

## 🚀 快速开始

### 系统要求

- **Flutter SDK**: 3.8.0 或更高版本
- **Dart SDK**: 3.8.0 或更高版本
- **操作系统**: Windows 10+, macOS 10.14+, Linux (Ubuntu 18.04+)

## 📖 使用说明

### 基本操作

1. **创建地图**
   - 点击主页的"新建地图"按钮
   - 设置地图名称和基本属性
   - 选择背景图片（可选）

2. **编辑地图**
   - 使用左侧工具栏选择绘制工具
   - 在画布上绘制元素
   - 使用图层面板管理图层

3. **管理图例**
   - 在图例面板创建图例组
   - 添加图例项目
   - 绑定图例到图层

4. **添加便签**
   - 选择便签工具
   - 在地图上点击添加便签
   - 编辑便签内容和样式

### 高级功能

- **脚本系统**: 使用 Hetu Script 编写自动化脚本
- **版本管理**: 支持地图版本控制和历史记录
- **协作功能**: 多用户协作编辑（开发中）
- **数据导入导出**: 支持多种格式的数据交换

## 🔨 构建指南

### 安装依赖

```bash
# 克隆项目
git clone https://github.com/your-username/GameMaps.git
cd GameMaps

# 安装依赖
flutter pub get

# 生成代码（如果需要）
flutter packages pub run build_runner build
```

### 运行应用

```bash
# 运行在调试模式
flutter run

# 运行在发布模式
flutter run --release

# 指定设备运行
flutter run -d chrome    # Web
flutter run -d windows   # Windows
flutter run -d macos     # macOS
```

### macOS 构建

#### 依赖安装
```bash
# 安装 CocoaPods
sudo gem install cocoapods

# 确保安装了 Xcode Command Line Tools
xcode-select --install
```

#### 构建步骤
```bash
# 使用构建脚本
./macos_build.sh

# 或使用 Xcode
open macos/Runner.xcworkspace
```

### Web 构建
```bash
flutter build web --release
```

### Windows 构建
```bash
flutter build windows --release
```

## 🏗️ 项目架构

```
lib/
├── components/          # 可复用组件
│   ├── common/         # 通用组件
│   ├── platform/       # 平台特定组件
│   └── vfs/           # 虚拟文件系统组件
├── data/               # 数据层
│   ├── map_data_bloc.dart
│   └── reactive_script_engine.dart
├── models/             # 数据模型
├── pages/              # 页面
│   ├── home/          # 主页
│   ├── map_editor/    # 地图编辑器
│   └── settings/      # 设置页面
├── services/           # 服务层
│   ├── database/      # 数据库服务
│   ├── vfs/          # 虚拟文件系统
│   └── scripting/    # 脚本服务
└── utils/              # 工具类
```

## 🤝 贡献指南

我们欢迎所有形式的贡献！请查看 [贡献指南](CONTRIBUTING.md) 了解详细信息。

### 开发流程

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 代码规范

- 遵循 [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- 使用 `flutter analyze` 检查代码质量
- 添加适当的注释和文档
- 编写单元测试

## 📋 支持平台

| 平台 | 状态 | 备注 |
|------|------|------|
| 🪟 Windows | ✅ 完全支持 | Windows 10+ |
| 🍎 macOS | ✅ 完全支持 | macOS 10.14+ |
| 🐧 Linux | ✅ 完全支持 | Ubuntu 18.04+ |
| 🌐 Web | ✅ 完全支持 | 现代浏览器 |

## 🔧 配置说明

### 环境变量

创建 `.env` 文件并配置以下变量：

```env
# 数据库配置
DATABASE_PATH=./data/app.db

# 脚本引擎配置
SCRIPT_TIMEOUT=30000
MAX_SCRIPT_MEMORY=128MB

# 功能开关
ENABLE_COLLABORATION=false
ENABLE_ANALYTICS=false
```

### 用户偏好

应用支持丰富的用户偏好设置：

- **主题设置**: 亮色/暗色主题，Material You
- **语言设置**: 中文/英文界面
- **编辑器设置**: 网格显示、吸附、快捷键
- **性能设置**: 缓存大小、渲染质量

## 📚 文档

- [架构设计文档](docs/ARCHITECTURE_DESIGN_DOCUMENT.md)
- [API 文档](docs/API_DOCUMENTATION.md)
- [脚本引擎指南](docs/SCRIPT_ENGINE_API.md)
- [部署指南](docs/DEPLOYMENT_GUIDE.md)

## 🐛 问题反馈

如果您遇到任何问题或有功能建议，请：

1. 查看 [常见问题](docs/FAQ.md)
2. 搜索现有的 [Issues](https://github.com/your-username/GameMaps/issues)
3. 创建新的 Issue 并提供详细信息

## 📄 许可证

本项目采用 GPLv3 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

<div align="center">

**如果这个项目对您有帮助，请给我们一个 ⭐ Star！**

[🏠 主页](https://github.com/your-username/GameMaps) • [📖 文档](docs/) • [🐛 问题反馈](https://github.com/your-username/GameMaps/issues) • [💬 讨论](https://github.com/your-username/GameMaps/discussions)

</div>
