import 'package:flutter/material.dart';
import '../services/map_localization_service.dart';

/// 地图本地化混合类
mixin MapLocalizationMixin {
  final MapLocalizationService _localizationService = MapLocalizationService();

  /// 获取本地化服务实例
  MapLocalizationService get localizationService => _localizationService;

  /// 获取本地化的地图标题
  Future<String> getLocalizedMapTitle(String originalTitle, BuildContext context) async {
    // 获取当前语言代码
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;
    
    // 如果有地区代码，尝试完整的语言代码
    String fullLanguageCode = languageCode;
    if (locale.countryCode != null) {
      fullLanguageCode = '${languageCode}_${locale.countryCode!.toLowerCase()}';
    }
    
    // 先尝试完整的语言代码
    String? translation = await _localizationService.getMapTranslation(originalTitle, fullLanguageCode);
    
    // 如果没找到，尝试只用语言代码
    if (translation == null) {
      translation = await _localizationService.getMapTranslation(originalTitle, languageCode);
    }
    
    return translation ?? originalTitle;
  }

  /// 批量获取本地化标题
  Future<Map<String, String>> getLocalizedMapTitles(List<String> originalTitles, BuildContext context) async {
    final Map<String, String> result = {};
    
    for (final title in originalTitles) {
      result[title] = await getLocalizedMapTitle(title, context);
    }
    
    return result;
  }
}
