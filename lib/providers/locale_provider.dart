// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/localization_service.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';

  Locale? _locale;

  Locale? get locale => _locale;

  // 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('zh', ''), // Chinese
  ];

  // 初始化语言
  Future<void> initLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);

    if (localeCode != null) {
      _locale = Locale(localeCode);
      LocalizationService.instance.setLocale(_locale!);
    } else {
      // 使用系统默认语言
      _locale = null;
      LocalizationService.instance.setLocale(const Locale('zh'));
    }
    notifyListeners();
  }

  // 设置语言
  Future<void> setLocale(Locale? locale) async {
    _locale = locale;

    // 更新本地化服务
    if (locale != null) {
      LocalizationService.instance.setLocale(locale);
    } else {
      // 使用默认语言（中文）
      LocalizationService.instance.setLocale(const Locale('zh'));
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (locale != null) {
      await prefs.setString(_localeKey, locale.languageCode);
    } else {
      await prefs.remove(_localeKey);
    }
  }

  // 获取语言显示名称
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return LocalizationService.instance.current.englishLanguage_4821;
      case 'zh':
        return LocalizationService.instance.current.chineseLanguage_5732;
      default:
        return locale.languageCode;
    }
  }
}
