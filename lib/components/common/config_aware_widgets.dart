import 'package:flutter/material.dart';
import '../../config/build_config.dart';
import '../../config/config_manager.dart';

/// 配置感知组件 - 根据配置决定是否渲染子组件
class ConfigAwareWidget extends StatelessWidget {
  final String? pageId;
  final String? featureId;
  final Widget child;
  final Widget? fallback;
  final bool requireBuildTime;
  final bool requireRuntime;

  const ConfigAwareWidget({
    super.key,
    this.pageId,
    this.featureId,
    required this.child,
    this.fallback,
    this.requireBuildTime = true,
    this.requireRuntime = true,
  }) : assert(
         pageId != null || featureId != null,
         'Either pageId or featureId must be provided',
       );

  @override
  Widget build(BuildContext context) {
    bool isEnabled = true;

    if (pageId != null) {
      // 检查页面配置
      if (requireBuildTime && !BuildTimeConfig.isPageEnabled(pageId!)) {
        isEnabled = false;
      }
      if (requireRuntime && isEnabled) {
        isEnabled = ConfigManager.instance.isCurrentPlatformPageEnabled(
          pageId!,
        );
      }
    }

    if (featureId != null) {
      // 检查功能配置
      if (requireBuildTime && !BuildTimeConfig.isFeatureEnabled(featureId!)) {
        isEnabled = false;
      }
      if (requireRuntime && isEnabled) {
        isEnabled = ConfigManager.instance.isCurrentPlatformFeatureEnabled(
          featureId!,
        );
      }
    }

    if (isEnabled) {
      return child;
    } else {
      return fallback ?? const SizedBox.shrink();
    }
  }
}

/// 配置感知的 AppBar 操作按钮
class ConfigAwareAppBarAction extends StatelessWidget {
  final String? pageId;
  final String? featureId;
  final Widget action;

  const ConfigAwareAppBarAction({
    super.key,
    this.pageId,
    this.featureId,
    required this.action,
  }) : assert(
         pageId != null || featureId != null,
         'Either pageId or featureId must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return ConfigAwareWidget(
      pageId: pageId,
      featureId: featureId,
      child: action,
    );
  }
}

/// 配置感知的列表项
class ConfigAwareListTile extends StatelessWidget {
  final String? pageId;
  final String? featureId;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ConfigAwareListTile({
    super.key,
    this.pageId,
    this.featureId,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  }) : assert(
         pageId != null || featureId != null,
         'Either pageId or featureId must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return ConfigAwareWidget(
      pageId: pageId,
      featureId: featureId,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

/// 条件渲染 Mixin
mixin ConfigAwareMixin on Widget {
  String? get pageId => null;
  String? get featureId => null;

  Widget buildConfigAware(BuildContext context, Widget child) {
    return ConfigAwareWidget(
      pageId: pageId,
      featureId: featureId,
      child: child,
    );
  }
}

/// 配置工具类
class ConfigUtils {
  static const ConfigUtils _instance = ConfigUtils._internal();
  const ConfigUtils._internal();
  static const ConfigUtils instance = _instance;

  /// 检查是否应该显示调试信息
  bool get shouldShowDebugInfo {
    return false; // DebugMode feature removed
  }

  /// 检查是否启用实验性功能
  bool get isExperimentalEnabled {
    return BuildTimeConfig.isFeatureEnabled('ExperimentalFeatures') &&
        ConfigManager.instance.isCurrentPlatformFeatureEnabled(
          'ExperimentalFeatures',
        );
  }

  /// 获取当前平台的可用页面列表
  List<String> get availablePages {
    final platform = ConfigManager.instance.getCurrentPlatform();
    final config = ConfigManager.instance.getPlatformConfig(platform);
    return config?.pages ?? [];
  }

  /// 获取当前平台的可用功能列表
  List<String> get availableFeatures {
    final platform = ConfigManager.instance.getCurrentPlatform();
    final config = ConfigManager.instance.getPlatformConfig(platform);
    return config?.features ?? [];
  }

  /// 打印配置调试信息
  void printConfigInfo() {
    if (shouldShowDebugInfo) {
      debugPrint('=== 配置信息 ===');
      debugPrint('当前平台: ${ConfigManager.instance.getCurrentPlatform()}');
      debugPrint('可用页面: ${availablePages.join(', ')}');
      debugPrint('可用功能: ${availableFeatures.join(', ')}');
      debugPrint('构建时信息:');
      debugPrint(BuildTimeConfig.buildInfo);
      debugPrint('================');
    }
  }
}
