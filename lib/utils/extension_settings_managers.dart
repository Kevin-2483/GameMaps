// This file has been processed by AI for internationalization
import 'package:flutter/foundation.dart';
import '../utils/extension_settings_helper.dart';

import '../services/localization_service.dart';

/// 图例组智能隐藏管理器
/// 使用扩展设置存储每个地图的图例组智能隐藏状态
class LegendGroupSmartHideManager {
  /// 获取图例组的智能隐藏状态
  static bool getSmartHideEnabled(String mapId, String legendGroupId) {
    if (!ExtensionSettingsManager.isInitialized) return false;

    return ExtensionSettingsManager.instance.getLegendGroupSmartHide(
      mapId,
      legendGroupId,
    );
  }

  /// 设置图例组的智能隐藏状态
  static Future<void> setSmartHideEnabled(
    String mapId,
    String legendGroupId,
    bool enabled,
  ) async {
    if (!ExtensionSettingsManager.isInitialized) return;

    await ExtensionSettingsManager.instance.setLegendGroupSmartHide(
      mapId,
      legendGroupId,
      enabled,
    );

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.legendGroupHiddenStatusSaved(
          mapId,
          legendGroupId,
          enabled,
        ),
      );
    }
  }

  /// 获取地图的所有图例组智能隐藏设置
  static Map<String, bool> getAllSmartHideSettings(String mapId) {
    if (!ExtensionSettingsManager.isInitialized) return {};

    return ExtensionSettingsManager.instance.getAllLegendGroupSmartHide(mapId);
  }

  /// 清除地图的所有图例组智能隐藏设置
  static Future<void> clearAllSmartHideSettings(String mapId) async {
    if (!ExtensionSettingsManager.isInitialized) return;

    await ExtensionSettingsManager.instance.clearLegendGroupSmartHide(mapId);

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.clearedMapLegendSettings(mapId),
      );
    }
  }

  /// 导出智能隐藏设置为JSON
  static Map<String, dynamic> exportSettings(String mapId) {
    final settings = getAllSmartHideSettings(mapId);
    return {
      'mapId': mapId,
      'smartHideSettings': settings,
      'exportTime': DateTime.now().toIso8601String(),
    };
  }

  /// 从JSON导入智能隐藏设置
  static Future<void> importSettings(Map<String, dynamic> data) async {
    if (!data.containsKey('mapId') || !data.containsKey('smartHideSettings')) {
      throw ArgumentError(
        LocalizationService.instance.current.invalidImportDataFormat_4271,
      );
    }

    final mapId = data['mapId'] as String;
    final settings = data['smartHideSettings'] as Map<String, dynamic>;

    for (final entry in settings.entries) {
      final legendGroupId = entry.key;
      final enabled = entry.value as bool;
      await setSmartHideEnabled(mapId, legendGroupId, enabled);
    }

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.importedMapLegendSettings(
          mapId,
          settings.length,
        ),
      );
    }
  }
}

/// 图例组缩放因子管理器
/// 使用扩展设置存储每个地图的图例组缩放因子
class LegendGroupZoomFactorManager {
  /// 获取图例组的缩放因子
  static double getZoomFactor(String mapId, String legendGroupId) {
    if (!ExtensionSettingsManager.isInitialized) return 1.0;

    return ExtensionSettingsManager.instance.getLegendGroupZoomFactor(
      mapId,
      legendGroupId,
    );
  }

  /// 设置图例组的缩放因子
  static Future<void> setZoomFactor(
    String mapId,
    String legendGroupId,
    double zoomFactor,
  ) async {
    if (!ExtensionSettingsManager.isInitialized) return;

    await ExtensionSettingsManager.instance.setLegendGroupZoomFactor(
      mapId,
      legendGroupId,
      zoomFactor,
    );

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.legendGroupZoomFactorSaved(
          mapId,
          legendGroupId,
          zoomFactor,
        ),
      );
    }
  }

  /// 获取地图的所有图例组缩放因子设置
  static Map<String, double> getAllZoomFactors(String mapId) {
    if (!ExtensionSettingsManager.isInitialized) return {};

    return ExtensionSettingsManager.instance.getAllLegendGroupZoomFactors(
      mapId,
    );
  }

  /// 清除地图的所有图例组缩放因子设置
  static Future<void> clearAllZoomFactors(String mapId) async {
    if (!ExtensionSettingsManager.isInitialized) return;

    await ExtensionSettingsManager.instance.clearLegendGroupZoomFactors(mapId);

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.clearedMapLegendGroups_7421(mapId),
      );
    }
  }

  /// 导出缩放因子设置为JSON
  static Map<String, dynamic> exportSettings(String mapId) {
    final settings = getAllZoomFactors(mapId);
    return {
      'mapId': mapId,
      'zoomFactorSettings': settings,
      'exportTime': DateTime.now().toIso8601String(),
    };
  }

  /// 从JSON导入缩放因子设置
  static Future<void> importSettings(Map<String, dynamic> data) async {
    if (!data.containsKey('mapId') || !data.containsKey('zoomFactorSettings')) {
      throw ArgumentError(
        LocalizationService.instance.current.invalidImportDataFormat_7281,
      );
    }

    final mapId = data['mapId'] as String;
    final settings = data['zoomFactorSettings'] as Map<String, dynamic>;

    for (final entry in settings.entries) {
      final legendGroupId = entry.key;
      final zoomFactor = (entry.value as num).toDouble();
      await setZoomFactor(mapId, legendGroupId, zoomFactor);
    }

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.importedMapLegendSettings(
          mapId,
          settings.length,
        ),
      );
    }
  }
}

/// 画布视图设置管理器
/// 管理用户在地图编辑时的临时视图偏好
class CanvasViewManager {
  /// 记录常用的缩放级别
  static Future<void> recordZoomLevel(String mapId, double zoomLevel) async {
    if (!ExtensionSettingsManager.isInitialized) return;

    await ExtensionSettingsManager.instance.addCanvasZoomLevel(
      mapId,
      zoomLevel,
    );
  }

  /// 获取常用的缩放级别
  static List<double> getCommonZoomLevels(String mapId) {
    if (!ExtensionSettingsManager.isInitialized) return [];

    return ExtensionSettingsManager.instance.getCanvasZoomLevels(mapId);
  }

  /// 保存视口状态
  static Future<void> saveViewportState(
    String mapId,
    double centerX,
    double centerY,
    double zoomLevel,
  ) async {
    if (!ExtensionSettingsManager.isInitialized) return;

    await ExtensionSettingsManager.setExtensionSetting(
      'canvas.viewport.$mapId',
      {
        'centerX': centerX,
        'centerY': centerY,
        'zoomLevel': zoomLevel,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// 获取保存的视口状态
  static Map<String, dynamic>? getSavedViewportState(String mapId) {
    if (!ExtensionSettingsManager.isInitialized) return null;

    return ExtensionSettingsManager.getExtensionSetting<Map<String, dynamic>>(
      'canvas.viewport.$mapId',
    );
  }
}

/// 工具栏布局管理器
/// 管理用户自定义的工具栏位置
class ToolbarLayoutManager {
  /// 保存工具栏位置
  static Future<void> saveToolbarPosition(
    String toolbarId,
    double x,
    double y, {
    double? width,
    double? height,
  }) async {
    if (!ExtensionSettingsManager.isInitialized) return;

    await ExtensionSettingsManager.instance.setToolbarCustomPosition(
      toolbarId,
      x,
      y,
      width: width,
      height: height,
    );
  }

  /// 获取工具栏位置
  static Map<String, dynamic>? getToolbarPosition(String toolbarId) {
    if (!ExtensionSettingsManager.isInitialized) return null;

    return ExtensionSettingsManager.instance.getToolbarCustomPosition(
      toolbarId,
    );
  }

  /// 重置工具栏布局
  static Future<void> resetToolbarLayout() async {
    if (!ExtensionSettingsManager.isInitialized) return;

    await ExtensionSettingsManager.instance.clearSettingsByPrefix('toolbar.');
  }
}

/// 图层透明度预设管理器
/// 管理图层的常用透明度设置
class LayerOpacityPresetManager {
  /// 保存图层透明度预设
  static Future<void> saveOpacityPreset(
    String mapId,
    String layerId,
    double opacity,
  ) async {
    if (!ExtensionSettingsManager.isInitialized) return;

    final currentPresets = ExtensionSettingsManager.instance
        .getLayerOpacityPresets(mapId, layerId);

    // 避免重复，保持最多5个预设
    if (!currentPresets.contains(opacity)) {
      currentPresets.add(opacity);
      currentPresets.sort();

      if (currentPresets.length > 5) {
        currentPresets.removeRange(0, currentPresets.length - 5);
      }

      await ExtensionSettingsManager.instance.setLayerOpacityPresets(
        mapId,
        layerId,
        currentPresets,
      );
    }
  }

  /// 获取图层透明度预设
  static List<double> getOpacityPresets(String mapId, String layerId) {
    if (!ExtensionSettingsManager.isInitialized) return [];

    return ExtensionSettingsManager.instance.getLayerOpacityPresets(
      mapId,
      layerId,
    );
  }

  /// 清除图层透明度预设
  static Future<void> clearOpacityPresets(String mapId, String layerId) async {
    if (!ExtensionSettingsManager.isInitialized) return;

    await ExtensionSettingsManager.instance.setLayerOpacityPresets(
      mapId,
      layerId,
      [],
    );
  }
}

/// 扩展设置使用示例类
/// 展示如何在实际组件中使用扩展设置
class ExtensionSettingsUsageExample {
  /// 示例：在图例组管理组件中应用智能隐藏设置
  static Future<void> initializeLegendGroupSmartHide(
    String mapId,
    String legendGroupId,
  ) async {
    // 从扩展设置中恢复智能隐藏状态
    final isEnabled = LegendGroupSmartHideManager.getSmartHideEnabled(
      mapId,
      legendGroupId,
    );

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.legendGroupSmartHideStatus_7421(
          legendGroupId,
          isEnabled,
        ),
      );
    }

    // 在组件中设置智能隐藏状态
    // _isSmartHidingEnabled = isEnabled;
  }

  /// 示例：保存智能隐藏状态变更
  static Future<void> onSmartHideToggled(
    String mapId,
    String legendGroupId,
    bool enabled,
  ) async {
    // 保存到扩展设置
    await LegendGroupSmartHideManager.setSmartHideEnabled(
      mapId,
      legendGroupId,
      enabled,
    );

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.smartHideStatusSaved(enabled),
      );
    }
  }

  /// 示例：记录画布缩放操作
  static Future<void> onCanvasZoomed(String mapId, double zoomLevel) async {
    // 记录常用缩放级别
    await CanvasViewManager.recordZoomLevel(mapId, zoomLevel);

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.zoomLevelRecorded(zoomLevel),
      );
    }
  }

  /// 示例：保存工具栏拖拽位置
  static Future<void> onToolbarDragged(
    String toolbarId,
    double x,
    double y,
  ) async {
    // 保存工具栏位置
    await ToolbarLayoutManager.saveToolbarPosition(toolbarId, x, y);

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.toolbarPositionSaved(
          toolbarId,
          x,
          y,
        ),
      );
    }
  }

  /// 示例：获取扩展设置统计信息
  static Map<String, dynamic> getUsageStats() {
    if (!ExtensionSettingsManager.isInitialized) {
      return {
        'error': LocalizationService
            .instance
            .current
            .extensionManagerNotInitialized_7281,
      };
    }

    return ExtensionSettingsManager.instance.getStorageStats();
  }
}
