import 'package:flutter/foundation.dart';
import '../providers/user_preferences_provider.dart';

/// 扩展设置的键常量定义
class ExtensionSettingsKeys {
  // 地图相关设置
  static const String mapPrefix = 'map.';

  // 图例组相关设置
  static const String legendGroupPrefix = 'legendGroup.';
  static const String legendGroupSmartHide = 'legendGroup.smartHide';
  static const String legendGroupLastView = 'legendGroup.lastView';

  // 图层相关设置
  static const String layerPrefix = 'layer.';
  static const String layerOpacityPresets = 'layer.opacityPresets';

  // 画布相关设置
  static const String canvasPrefix = 'canvas.';
  static const String canvasZoomLevels = 'canvas.zoomLevels';

  // 工具栏相关设置
  static const String toolbarPrefix = 'toolbar.';
  static const String toolbarCustomPositions = 'toolbar.customPositions';
}

/// 扩展设置辅助类
/// 提供类型安全的扩展设置访问方法
class ExtensionSettingsHelper {
  final UserPreferencesProvider _provider;

  ExtensionSettingsHelper(this._provider);

  // 图例组智能隐藏设置

  /// 获取图例组的智能隐藏状态
  bool getLegendGroupSmartHide(String mapId, String legendGroupId) {
    final key =
        '${ExtensionSettingsKeys.legendGroupSmartHide}.$mapId.$legendGroupId';
    return _provider.getExtensionSetting<bool>(key, true) ?? true; // 默认开启智能隐藏
  }

  /// 设置图例组的智能隐藏状态
  Future<void> setLegendGroupSmartHide(
    String mapId,
    String legendGroupId,
    bool isHidden,
  ) async {
    final key =
        '${ExtensionSettingsKeys.legendGroupSmartHide}.$mapId.$legendGroupId';
    await _provider.setExtensionSetting(key, isHidden);

    if (kDebugMode) {
      print('扩展设置: 地图 $mapId 的图例组 $legendGroupId 智能隐藏状态已设置为 $isHidden');
    }
  }

  /// 获取地图的所有图例组智能隐藏设置
  Map<String, bool> getAllLegendGroupSmartHide(String mapId) {
    final prefix = '${ExtensionSettingsKeys.legendGroupSmartHide}.$mapId.';
    final result = <String, bool>{};

    for (final entry in _provider.extensionSettings.entries) {
      if (entry.key.startsWith(prefix)) {
        final legendGroupId = entry.key.substring(prefix.length);
        if (entry.value is bool) {
          result[legendGroupId] = entry.value;
        }
      }
    }

    return result;
  }

  /// 清除地图的所有图例组智能隐藏设置
  Future<void> clearLegendGroupSmartHide(String mapId) async {
    final prefix = '${ExtensionSettingsKeys.legendGroupSmartHide}.$mapId.';
    final keysToRemove = _provider.extensionSettings.keys
        .where((key) => key.startsWith(prefix))
        .toList();

    for (final key in keysToRemove) {
      await _provider.removeExtensionSetting(key);
    }

    if (kDebugMode) {
      print('扩展设置: 已清除地图 $mapId 的所有图例组智能隐藏设置');
    }
  }

  // 图层透明度预设设置

  /// 获取图层的透明度预设
  List<double> getLayerOpacityPresets(String mapId, String layerId) {
    final key = '${ExtensionSettingsKeys.layerOpacityPresets}.$mapId.$layerId';
    final presets = _provider.getExtensionSetting<List<dynamic>>(key, []);
    return presets?.map((e) => (e as num).toDouble()).toList() ?? [];
  }

  /// 设置图层的透明度预设
  Future<void> setLayerOpacityPresets(
    String mapId,
    String layerId,
    List<double> presets,
  ) async {
    final key = '${ExtensionSettingsKeys.layerOpacityPresets}.$mapId.$layerId';
    await _provider.setExtensionSetting(key, presets);

    if (kDebugMode) {
      print('扩展设置: 地图 $mapId 的图层 $layerId 透明度预设已设置: $presets');
    }
  }

  // 画布缩放级别记录

  /// 获取画布的常用缩放级别
  List<double> getCanvasZoomLevels(String mapId) {
    final key = '${ExtensionSettingsKeys.canvasZoomLevels}.$mapId';
    final levels = _provider.getExtensionSetting<List<dynamic>>(key, []);
    return levels?.map((e) => (e as num).toDouble()).toList() ?? [];
  }

  /// 添加画布缩放级别到记录
  Future<void> addCanvasZoomLevel(String mapId, double zoomLevel) async {
    final currentLevels = getCanvasZoomLevels(mapId);

    // 避免重复，保持最多10个记录
    if (!currentLevels.contains(zoomLevel)) {
      currentLevels.add(zoomLevel);
      currentLevels.sort();

      // 保持最多10个缩放级别
      if (currentLevels.length > 10) {
        currentLevels.removeRange(0, currentLevels.length - 10);
      }

      final key = '${ExtensionSettingsKeys.canvasZoomLevels}.$mapId';
      await _provider.setExtensionSetting(key, currentLevels);

      if (kDebugMode) {
        print('扩展设置: 地图 $mapId 添加缩放级别记录 $zoomLevel');
      }
    }
  }

  // 工具栏自定义位置

  /// 获取工具栏的自定义位置
  Map<String, dynamic>? getToolbarCustomPosition(String toolbarId) {
    final key = '${ExtensionSettingsKeys.toolbarCustomPositions}.$toolbarId';
    return _provider.getExtensionSetting<Map<String, dynamic>>(key);
  }

  /// 设置工具栏的自定义位置
  Future<void> setToolbarCustomPosition(
    String toolbarId,
    double x,
    double y, {
    double? width,
    double? height,
  }) async {
    final key = '${ExtensionSettingsKeys.toolbarCustomPositions}.$toolbarId';
    final position = {
      'x': x,
      'y': y,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    await _provider.setExtensionSetting(key, position);

    if (kDebugMode) {
      print('扩展设置: 工具栏 $toolbarId 位置已设置为 ($x, $y)');
    }
  }

  // 通用辅助方法

  /// 获取特定前缀的所有设置
  Map<String, dynamic> getSettingsByPrefix(String prefix) {
    final result = <String, dynamic>{};

    for (final entry in _provider.extensionSettings.entries) {
      if (entry.key.startsWith(prefix)) {
        result[entry.key] = entry.value;
      }
    }

    return result;
  }

  /// 清除特定前缀的所有设置
  Future<void> clearSettingsByPrefix(String prefix) async {
    final keysToRemove = _provider.extensionSettings.keys
        .where((key) => key.startsWith(prefix))
        .toList();

    for (final key in keysToRemove) {
      await _provider.removeExtensionSetting(key);
    }

    if (kDebugMode) {
      print('扩展设置: 已清除前缀为 $prefix 的所有设置');
    }
  }

  /// 获取设置的存储统计信息
  Map<String, dynamic> getStorageStats() {
    final allSettings = _provider.extensionSettings;
    final stats = <String, dynamic>{
      'totalKeys': allSettings.length,
      'totalSize': _provider.getExtensionSettingsSize(),
      'categories': <String, int>{},
    };

    // 按前缀统计
    for (final key in allSettings.keys) {
      final category = key.contains('.') ? key.split('.')[0] : 'other';
      stats['categories'][category] = (stats['categories'][category] ?? 0) + 1;
    }

    return stats;
  }
}

/// 扩展设置管理器
/// 提供全局访问扩展设置的便利方法
class ExtensionSettingsManager {
  static ExtensionSettingsHelper? _helper;

  /// 初始化扩展设置管理器
  static void initialize(UserPreferencesProvider provider) {
    _helper = ExtensionSettingsHelper(provider);
  }

  /// 获取扩展设置辅助类实例
  static ExtensionSettingsHelper get instance {
    if (_helper == null) {
      throw StateError(
        'ExtensionSettingsManager not initialized. Call initialize() first.',
      );
    }
    return _helper!;
  }

  /// 检查是否已初始化
  static bool get isInitialized => _helper != null;

  /// 便利方法：直接设置扩展设置值
  static Future<void> setExtensionSetting<T>(String key, T value) async {
    if (_helper == null) {
      throw StateError('ExtensionSettingsManager not initialized');
    }
    await _helper!._provider.setExtensionSetting(key, value);
  }

  /// 便利方法：直接获取扩展设置值
  static T? getExtensionSetting<T>(String key, [T? defaultValue]) {
    if (_helper == null) return defaultValue;
    return _helper!._provider.getExtensionSetting<T>(key, defaultValue);
  }
}
