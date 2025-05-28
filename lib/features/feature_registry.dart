import 'package:flutter/material.dart';

/// 功能模块接口
abstract class FeatureModule {
  String get name;
  String get description;
  IconData get icon;
  bool get isEnabled;
  Widget buildWidget(BuildContext context);
}

/// 功能注册管理器
class FeatureRegistry {
  static final FeatureRegistry _instance = FeatureRegistry._internal();
  factory FeatureRegistry() => _instance;
  FeatureRegistry._internal();

  final Map<String, FeatureModule> _features = {};

  /// 注册功能模块
  void register(FeatureModule feature) {
    _features[feature.name] = feature;
  }

  /// 获取所有启用的功能
  List<FeatureModule> getEnabledFeatures() {
    return _features.values.where((feature) => feature.isEnabled).toList();
  }

  /// 获取所有功能
  List<FeatureModule> getAllFeatures() {
    return _features.values.toList();
  }

  /// 根据名称获取功能
  FeatureModule? getFeature(String name) {
    return _features[name];
  }

  /// 检查功能是否启用
  bool isFeatureEnabled(String name) {
    return _features[name]?.isEnabled ?? false;
  }
}
