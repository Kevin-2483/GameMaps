import 'dart:ui';
import '../l10n/app_localizations.dart';

/// 本地化服务类
/// 提供在服务类中访问本地化字符串的能力，无需BuildContext
class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  static LocalizationService get instance => _instance;

  AppLocalizations? _currentLocalizations;
  Locale _currentLocale = const Locale('zh'); // 默认中文

  /// 初始化本地化服务
  void initialize([Locale? locale]) {
    _currentLocale = locale ?? _currentLocale;
    _currentLocalizations = lookupAppLocalizations(_currentLocale);
  }

  /// 设置当前语言
  void setLocale(Locale locale) {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      _currentLocalizations = lookupAppLocalizations(locale);
    }
  }

  /// 获取当前本地化实例
  AppLocalizations get current {
    _currentLocalizations ??= lookupAppLocalizations(_currentLocale);
    return _currentLocalizations!;
  }

  /// 获取当前语言代码
  String get currentLanguageCode => _currentLocale.languageCode;

  /// 获取当前Locale
  Locale get currentLocale => _currentLocale;

  /// 检查是否支持指定语言
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  /// 获取支持的语言列表
  List<Locale> get supportedLocales => const [Locale('en'), Locale('zh')];
}

/// 全局本地化服务实例
final localizationService = LocalizationService.instance;
