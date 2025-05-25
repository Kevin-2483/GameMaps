# R6Box - 全平台 Flutter 应用框架

这是一个结构化的 Flutter 全平台应用框架，支持国际化、主题切换、模块化组件和配置管理。

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── config/                      # 配置管理
│   ├── app_config.dart         # 应用配置模型
│   └── config_manager.dart     # 配置管理器
├── providers/                   # 状态管理
│   ├── theme_provider.dart     # 主题管理
│   └── locale_provider.dart    # 语言管理
├── router/                      # 路由配置
│   └── app_router.dart         # 路由定义
├── pages/                       # 页面
│   ├── home/                   # 首页
│   │   └── home_page.dart
│   └── settings/               # 设置页
│       └── settings_page.dart
├── components/                  # 组件
│   ├── common/                 # 通用组件
│   │   ├── custom_button.dart
│   │   ├── custom_card.dart
│   │   └── platform_aware_component.dart
│   └── platform/               # 平台特定组件
│       ├── windows/
│       │   └── windows_component.dart
│       ├── macos/
│       │   └── macos_component.dart
│       ├── linux/
│       │   └── linux_component.dart
│       ├── android/
│       │   └── android_component.dart
│       ├── ios/
│       │   └── ios_component.dart
│       └── web/
│           └── web_component.dart
└── l10n/                       # 国际化资源
    ├── app_en.arb             # 英文
    └── app_zh.arb             # 中文

assets/
└── config/
    └── app_config.json         # 应用配置文件
```

## 功能特性

### 1. 国际化支持
- 支持中英文切换
- 使用 ARB 文件管理翻译
- 自动生成类型安全的本地化类

### 2. 主题管理
- 支持浅色/深色/跟随系统主题
- Material 3 设计
- 主题偏好自动保存

### 3. 平台感知组件
- 根据运行平台显示不同组件
- 支持 Windows、macOS、Linux、Android、iOS、Web
- 可通过配置控制平台功能的启用/禁用

### 4. 配置管理
- 基于 JSON 的配置文件
- 支持平台特性开关
- 支持功能模块开关
- 构建时配置控制

### 5. 模块化架构
- 清晰的目录结构
- 组件按平台分类
- 易于扩展和维护

## 配置说明

### 应用配置 (assets/config/app_config.json)

```json
{
  "platform": {
    "enableWindows": true,     // 启用 Windows 平台功能
    "enableMacOS": true,       // 启用 macOS 平台功能
    "enableLinux": true,       // 启用 Linux 平台功能
    "enableAndroid": true,     // 启用 Android 平台功能
    "enableIOS": true,         // 启用 iOS 平台功能
    "enableWeb": true          // 启用 Web 平台功能
  },
  "features": {
    "enableDarkTheme": true,        // 启用深色主题
    "enableMultiLanguage": true,    // 启用多语言
    "enableAdvancedSettings": false, // 启用高级设置
    "enableDebugMode": true         // 启用调试模式
  },
  "build": {
    "appName": "R6Box",        // 应用名称
    "version": "1.0.0",        // 应用版本
    "buildNumber": "1",        // 构建号
    "enableLogging": true      // 启用日志
  }
}
```

## 开发指南

### 添加新页面
1. 在 `lib/pages/` 下创建新的文件夹和页面文件
2. 在 `lib/router/app_router.dart` 中添加路由
3. 在国际化文件中添加相关文本

### 添加新组件
1. 通用组件：放在 `lib/components/common/`
2. 平台特定组件：放在对应的 `lib/components/platform/[platform]/`

### 添加新功能开关
1. 在 `lib/config/app_config.dart` 中定义新的配置项
2. 在 `assets/config/app_config.json` 中设置默认值
3. 在相关组件中检查配置状态

### 添加新语言
1. 在 `lib/l10n/` 下创建新的 ARB 文件
2. 在 `lib/providers/locale_provider.dart` 中添加语言支持

## 构建命令

```bash
# 安装依赖
flutter pub get

# 生成代码
dart run build_runner build

# 运行应用
flutter run

# 构建发布版本
flutter build [platform]
```

## 技术栈

- Flutter 3.8+
- Provider (状态管理)
- go_router (路由)
- shared_preferences (本地存储)
- json_annotation/json_serializable (JSON 序列化)
- 国际化 (flutter_localizations)
