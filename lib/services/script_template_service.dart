// This file has been processed by AI for internationalization
import 'package:flutter/services.dart';
import '../models/script_data.dart';
import 'localization_service.dart';

/// 脚本模板服务
/// 负责从assets文件中加载脚本模板内容
class ScriptTemplateService {
  static const String _basePath = 'assets/scripts';

  /// 脚本类型到模板文件的映射
  static const Map<ScriptType, String> _templateFiles = {
    ScriptType.automation: '$_basePath/automation_template.ht',
    ScriptType.animation: '$_basePath/animation_template.ht',
    ScriptType.filter: '$_basePath/filter_template.ht',
    ScriptType.statistics: '$_basePath/statistics_template.ht',
  };

  /// 模板内容缓存
  static final Map<ScriptType, String> _templateCache = {};

  /// 获取指定类型的脚本模板内容
  ///
  /// [type] 脚本类型
  /// 返回模板内容字符串，如果加载失败则返回默认内容
  static Future<String> getTemplateContent(ScriptType type) async {
    // 检查缓存
    if (_templateCache.containsKey(type)) {
      return _templateCache[type]!;
    }

    try {
      final templateFile = _templateFiles[type];
      if (templateFile == null) {
        throw Exception('Unknown script type: $type');
      }

      // 从assets加载模板内容
      final content = await rootBundle.loadString(templateFile);

      // 缓存内容
      _templateCache[type] = content;

      return content;
    } catch (e) {
      // 如果加载失败，返回默认内容
      return _getDefaultContent(type);
    }
  }

  /// 获取默认模板内容（同步方法，用于向后兼容）
  ///
  /// [type] 脚本类型
  /// 返回默认模板内容字符串
  static String getDefaultTemplate(ScriptType type) {
    return _getDefaultContent(type);
  }

  /// 同步获取模板内容（仅从缓存或默认内容）
  /// 注意：如果缓存中没有内容，将返回默认模板
  static String getTemplateContentSync(ScriptType type) {
    // 检查缓存
    if (_templateCache.containsKey(type)) {
      return _templateCache[type]!;
    }

    // 如果缓存中没有，返回默认内容
    return _getDefaultContent(type);
  }

  /// 清除模板缓存
  /// 主要用于开发阶段或需要重新加载模板时
  static void clearCache() {
    _templateCache.clear();
  }

  /// 预加载所有模板
  /// 可以在应用启动时调用以提高性能
  static Future<void> preloadTemplates() async {
    for (final type in ScriptType.values) {
      await getTemplateContent(type);
    }
  }

  /// 获取默认模板内容（作为fallback）
  static String _getDefaultContent(ScriptType type) {
    switch (type) {
      case ScriptType.automation:
        return '''// ${LocalizationService.instance.current.automationScriptExample_1234}
var layers = getLayers();
log('${LocalizationService.instance.current.totalLayers_5678} ' + layers.length.toString() + ' ${LocalizationService.instance.current.layers_9101}');

// ${LocalizationService.instance.current.iterateAllElements_1121}
var elements = getAllElements();
for (var element in elements) {
    log('${LocalizationService.instance.current.element_3141} ' + element['id'] + ' ${LocalizationService.instance.current.type_5161}: ' + element['type']);
}''';
      case ScriptType.animation:
        return '''// ${LocalizationService.instance.current.animationScriptExample_7181}
var elements = getAllElements();
if (elements.length > 0) {
    var element = elements[0];
    
    // ${LocalizationService.instance.current.animateColorChange_9202}
    animate(element['id'], 'color', 0xFF00FF00, 1000);
    delay(1000);
    
    // ${LocalizationService.instance.current.animateElementMovement_1222}
    animate(element['id'], 'x', 0.5, 1000);
}''';
      case ScriptType.filter:
        return '''// ${LocalizationService.instance.current.filterScriptExample_3242}
var allElements = getAllElements();
var filteredElements = filterElements(allElements, {
    'type': 'rectangle',
    'color': 0xFF0000FF
});

log('${LocalizationService.instance.current.foundBlueRectangles_5262} ' + filteredElements.length.toString() + ' ${LocalizationService.instance.current.blueRectangles_7282}');''';
      case ScriptType.statistics:
        return '''// ${LocalizationService.instance.current.statisticsScriptExample_9303}
var layers = getLayers();
var totalElements = 0;

for (var layer in layers) {
    var elementCount = layer['elementCount'];
    totalElements += elementCount;
    log('${LocalizationService.instance.current.layer_1323} ' + layer['name'] + ': ' + elementCount.toString() + ' ${LocalizationService.instance.current.elements_3343}');
}

log('${LocalizationService.instance.current.total_5363}: ' + totalElements.toString() + ' ${LocalizationService.instance.current.elements_7383}');''';
    }
  }
}
