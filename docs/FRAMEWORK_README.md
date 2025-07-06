# R6Box - 全平台 Flutter 应用框架

这是一个结构化的 Flutter 全平台应用框架，支持国际化、主题切换、模块化组件和配置管理。

## 项目结构

```
lib/
├─components #组件
│  ├─common
│  ├─layout
│  ├─navigation
│  └─platform #特定平台组件
│      ├─android
│      ├─ios
│      ├─linux
│      ├─macos
│      ├─web
│      └─windows
├─config #配置
├─features #功能模块
│  ├─component-modules #页面模块
│  └─page-modules #组件模块
├─l10n #国际化
├─pages #页面
│  ├─config
│  ├─home
│  └─settings
├─providers
└─router

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


## 开发指南

### 配置文件结构

`assets/config/app_config.json` 现在使用以下结构：

```json
{
  "platform": {
    "Windows": {
      "pages": ["HomePage", "SettingsPage"],
      "features": ["DarkTheme", "MultiLanguage"]
    },
    "MacOS": {
      "pages": ["HomePage", "SettingsPage"], 
      "features": ["DarkTheme", "MultiLanguage"]
    },
    "Android": {
      "pages": ["HomePage"],
      "features": ["DarkTheme"]
    }
  },
  "build": {
    "appName": "R6Box",
    "version": "1.0.0",
    "buildNumber": "1",
    "enableLogging": true
  }
}
```

### 添加新页面
1. 在 `lib/pages/` 下创建新的文件夹和页面文件
2. 在 `features/page-modules` 下创建新的模块

### 添加新页面开关
1. 在 `assets/config/app_config.json` 和 `lib\config\build_config.dart` 中设置默认值
2. 在相关组件中检查配置状态

页面模块现在需要定义一个 `moduleId` 常量：

```dart
class HomePageModule extends PageModule {
  static const String moduleId = 'HomePage';
  
  @override
  bool get isEnabled {
    // 编译时检查
    if (!BuildTimeConfig.isPageEnabled(moduleId)) {
      return false;
    }
    
    // 运行时检查
    return ConfigManager.instance.isCurrentPlatformPageEnabled(moduleId);
  }
}
```

3. 在 `lib/router/app_router.dart` 中注册路由

```dart
  /// 初始化页面模块
  static void _initializePages() {
    final registry = PageRegistry();
    
    // 注册核心页面模块
    registry.register(HomePageModule());
    registry.register(SettingsPageModule());
    registry.register(ConfigEditorModule());
  }
```
4. 在 `scripts/config_validator.dart` 和 `scripts/build_config_generator.dart` 中定义新的配置项
5. 在国际化文件中添加相关文本

### 添加新组件
1. 通用组件：放在 `lib/components/common/`
2. 平台特定组件：放在对应的 `lib/components/platform/[platform]/`
3. 在 `features/component-modules` 下创建新的模块

### 添加新功能开关
1. 在 `assets/config/app_config.json` 和 `lib\config\build_config.dart` 中设置默认值
2. 在相关组件模块中检查配置状态

功能模块同样需要定义 `featureId`：

```dart
class SystemInfoFeature implements FeatureModule {
  static const String featureId = 'ExperimentalFeatures';
  
  @override
  bool get isEnabled {
    return ConfigManager.instance.isCurrentPlatformFeatureEnabled(featureId);
  }
}
```

3. 在对应页面注册组件

```dart
  void _initializeFeatures() {
    final registry = FeatureRegistry();
    registry.register(SystemInfoFeature());
  }
```

4. 在 `scripts/config_validator.dart` 和 `scripts/build_config_generator.dart` 中定义新的配置项
5. 在国际化文件中添加相关文本

### 添加新语言
1. 在 `lib/l10n/` 下创建新的 ARB 文件
2. 在 `lib/providers/locale_provider.dart` 中添加语言支持

## 构建命令

## 构建流程

### 1. 生成构建配置

```bash
# Windows
dart scripts/build_config_generator.dart Windows

# Android
dart scripts/build_config_generator.dart Android

# Web
dart scripts/build_config_generator.dart Web
```

### 2. 使用构建脚本

```bash
# Windows
scripts/build.ps1 Windows release

# Linux/macOS
./scripts/build.sh Android debug
```

## API 参考

### BuildTimeConfig

- `BuildTimeConfig.isPageEnabled(String pageId)` - 检查页面是否在编译时启用
- `BuildTimeConfig.isFeatureEnabled(String featureId)` - 检查功能是否在编译时启用
- `BuildTimeConfig.enabledPages` - 获取启用的页面列表
- `BuildTimeConfig.enabledFeatures` - 获取启用的功能列表

### ConfigManager

- `ConfigManager.instance.isCurrentPlatformPageEnabled(String pageId)` - 检查当前平台是否启用页面
- `ConfigManager.instance.isCurrentPlatformFeatureEnabled(String featureId)` - 检查当前平台是否启用功能
- `ConfigManager.instance.getCurrentPlatform()` - 获取当前平台名称
- `ConfigManager.instance.isPlatformConfigured(String platform)` - 检查平台是否配置

## 可用的 ID

### 页面 ID
- `HomePage` - 主页
- `SettingsPage` - 设置页
- `TrayNavigation` - 托盘导航

### 功能 ID
- `DarkTheme` - 深色主题
- `MultiLanguage` - 多语言支持

- `ExperimentalFeatures` - 实验性功能

## 最佳实践

1. **为每个模块定义常量 ID**：避免魔法字符串，使用 `static const String moduleId = 'HomePage'`
2. **同时检查编译时和运行时配置**：确保功能在两个级别都被正确启用
3. **使用描述性的 ID 名称**：如 `HomePage` 而不是 `home`
4. **平台特定配置**：根据不同平台的需求配置不同的功能集

## 故障排除

### 常见问题

1. **构建时找不到功能**：确保在 `app_config.json` 中为目标平台配置了相应的功能
2. **运行时功能不可用**：检查 `ConfigManager` 是否正确加载了配置文件
3. **编译错误**：确保运行了 `flutter packages pub run build_runner build` 重新生成序列化代码

### 调试技巧

使用 `BuildTimeConfig.buildInfo` 查看当前构建配置：

```dart
print(BuildTimeConfig.buildInfo);
```

这将输出当前启用的页面和功能列表。


## 技术栈

- Flutter 3.8+
- Provider (状态管理)
- go_router (路由)
- shared_preferences (本地存储)
- json_annotation/json_serializable (JSON 序列化)
- 国际化 (flutter_localizations)
