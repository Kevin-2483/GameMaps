// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'R6盒子';

  @override
  String get home => '首页';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get darkMode => '深色模式';

  @override
  String get lightMode => '浅色模式';

  @override
  String get systemMode => '跟随系统';

  @override
  String get systemLanguage => '跟随系统';

  @override
  String get about => '关于';

  @override
  String get error => '错误';

  @override
  String pageNotFound(String uri) {
    return '页面未找到：$uri';
  }

  @override
  String get goHome => '回到首页';

  @override
  String get comprehensiveFramework => '全面的 Flutter 跨平台框架';

  @override
  String get platformIntegration => '平台集成';

  @override
  String get features => '功能特性';

  @override
  String get noFeaturesEnabled => '暂无启用的功能';

  @override
  String get enableFeaturesInSettings => '在设置中启用功能以在此处查看';

  @override
  String get aboutDialogContent => 'Flutter 跨平台框架\n支持多个平台的现代架构';

  @override
  String get windowsPlatform => 'Windows 平台';

  @override
  String get windowsFeatures => 'Windows 功能：';

  @override
  String get windowsSpecificFeatures => '可以在此处实现 Windows 特定功能。';

  @override
  String get nativeWindowsUI => '原生 Windows UI';

  @override
  String get fileSystemAccess => '文件系统访问';

  @override
  String get systemTrayIntegration => '系统托盘集成';

  @override
  String get windowsNotifications => 'Windows 通知';

  @override
  String get macOSPlatform => 'macOS 平台';

  @override
  String get macOSFeatures => 'macOS 功能：';

  @override
  String get macOSSpecificFeatures => '可以在此处实现 macOS 特定功能。';

  @override
  String get nativeMacOSUI => '原生 macOS UI';

  @override
  String get menuBarIntegration => '菜单栏集成';

  @override
  String get touchBarSupport => 'Touch Bar 支持';

  @override
  String get macOSNotifications => 'macOS 通知';

  @override
  String get androidPlatform => 'Android 平台';

  @override
  String get androidFeatures => 'Android 功能：';

  @override
  String get androidSpecificFeatures => '可以在此处实现 Android 特定功能。';

  @override
  String get nativeAndroidUI => '原生 Android UI';

  @override
  String get androidNotifications => 'Android 通知';

  @override
  String get androidPermissions => 'Android 权限';

  @override
  String get materialDesign => 'Material Design';

  @override
  String get pushNotifications => '推送通知';

  @override
  String get appShortcuts => '应用快捷方式';

  @override
  String get backgroundServices => '后台服务';

  @override
  String get iOSPlatform => 'iOS 平台';

  @override
  String get iOSFeatures => 'iOS 功能：';

  @override
  String get iOSSpecificFeatures => '可以在此处实现 iOS 特定功能。';

  @override
  String get nativeIOSUI => '原生 iOS UI';

  @override
  String get iOSNotifications => 'iOS 通知';

  @override
  String get appStoreIntegration => 'App Store 集成';

  @override
  String get cupertinoDesign => 'Cupertino 设计';

  @override
  String get appClips => 'App Clips';

  @override
  String get siriShortcuts => 'Siri 快捷指令';

  @override
  String get linuxPlatform => 'Linux 平台';

  @override
  String get linuxFeatures => 'Linux 功能：';

  @override
  String get linuxSpecificFeatures => 'Linux 特定功能可以在这里实现。';

  @override
  String get nativeGtkIntegration => '原生 GTK 集成';

  @override
  String get systemTraySupport => '系统托盘支持';

  @override
  String get desktopFiles => '桌面文件';

  @override
  String get packageManagement => '包管理';

  @override
  String get webPlatform => 'Web 平台';

  @override
  String get webFeatures => 'Web 功能：';

  @override
  String get webSpecificFeatures => 'Web 特定功能可以在这里实现。';

  @override
  String get progressiveWebApp => '渐进式Web应用';

  @override
  String get browserStorage => '浏览器存储';

  @override
  String get urlRouting => 'URL路由';

  @override
  String get webApis => 'Web API';

  @override
  String get configEditor => '配置编辑器';

  @override
  String get configUpdated => '配置已更新';

  @override
  String currentPlatform(String platform) {
    return '当前平台：$platform';
  }

  @override
  String availablePages(String pages) {
    return '可用页面：$pages';
  }

  @override
  String availableFeatures(String features) {
    return '可用功能：$features';
  }

  @override
  String get pageConfiguration => '页面配置';

  @override
  String get featureConfiguration => '功能配置';

  @override
  String get debugInfo => '调试信息';

  @override
  String get printConfigInfo => '打印配置信息';

  @override
  String get saveConfig => '保存配置';
}
