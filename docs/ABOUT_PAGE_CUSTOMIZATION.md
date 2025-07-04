# 关于页面自定义致谢指南

## 📝 概述

关于页面现在支持两种类型的开源项目致谢：

1. **自定义手动致谢**：您手动添加的特殊项目（如素材、数据等）
2. **自动依赖致谢**：从 `pubspec.yaml` 自动生成的所有 Flutter 包依赖

## 🔧 如何添加自定义致谢项目

### 1. 打开文件
编辑 `lib/pages/about/about_page.dart` 文件

### 2. 找到配置区域
找到 `_customAcknowledgments` 列表（约第 29 行）

### 3. 添加新项目
在列表中添加新的 Map 条目：

```dart
{
  'name': '项目名称',                    // 必需：显示的项目名称
  'description': '项目描述',             // 必需：简短的项目描述
  'subtitle': '详细信息或来源',           // 必需：详细信息或来源说明
  'url': 'https://github.com/...',     // 可选：项目链接（用户可点击访问）
  'icon': 'image',                     // 可选：图标名称
},
```

## 🎨 支持的图标

| 图标名称 | 图标样式 | 适用场景 |
|---------|---------|---------|
| `folder_special` | 📁 | 默认图标，通用资源 |
| `code` | 💻 | 代码库、工具 |
| `image` | 🖼️ | 图片资源、素材 |
| `palette` | 🎨 | 设计资源、主题 |
| `library_books` | 📚 | 文档、数据 |

## 📋 示例用法

### 示例 1：图片资源致谢
```dart
{
  'name': 'R6 Operators Assets',
  'description': '彩虹六号干员头像和图标资源',
  'subtitle': 'marcopixel/r6operators 仓库提供的干员素材',
  'url': 'https://github.com/marcopixel/r6operators',
  'icon': 'image',
},
```

### 示例 2：无链接的资源致谢
```dart
{
  'name': 'Ubisoft 官方资源',
  'description': '游戏内素材和图标',
  'subtitle': '来自《彩虹六号：围攻》官方资源',
  'icon': 'palette',
},
```

### 示例 3：数据库致谢
```dart
{
  'name': 'Community Maps Data',
  'description': '社区贡献的地图数据',
  'subtitle': '来自 R6 社区的地图标注和战术点位',
  'url': 'https://github.com/your-repo/r6-maps-data',
  'icon': 'library_books',
},
```

## ⚠️ 注意事项

1. **必需字段**：`name`、`description`、`subtitle` 是必需的
2. **可选字段**：`url`、`icon` 是可选的
3. **逗号**：每个项目后面都要加逗号（除了最后一个）
4. **链接验证**：确保提供的 URL 是有效的
5. **重新编译**：修改后需要重新运行应用才能看到变化

## 🔄 自动功能

- **版本信息**：自动从 `pubspec.yaml` 获取应用版本
- **依赖列表**：自动显示所有 Flutter 包的许可证信息
- **许可证文件**：自动读取并显示项目根目录的 `LICENSE` 文件

这样的设计既保证了合规性（显示所有依赖），又允许您灵活地添加特殊致谢项目！
