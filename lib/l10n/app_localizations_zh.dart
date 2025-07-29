// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

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
  String get features => '功能特性';

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

  @override
  String get mapAtlas => '地图册';

  @override
  String get mapAtlasEmpty => '暂无地图';

  @override
  String get addMap => '添加地图';

  @override
  String get mapTitle => '地图标题';

  @override
  String get enterMapTitle => '请输入地图标题';

  @override
  String get deleteMap => '删除地图';

  @override
  String confirmDeleteMap(String title) {
    return '确定要删除地图\"$title\"吗？';
  }

  @override
  String get exportDatabase => '导出数据库';

  @override
  String get importDatabase => '导入数据库';

  @override
  String get resourceManagement => '资源管理';

  @override
  String importFailed(String error) {
    return '导入失败：$error';
  }

  @override
  String get mapAddedSuccessfully => '地图添加成功';

  @override
  String get mapDeletedSuccessfully => '地图删除成功';

  @override
  String addMapFailed(String error) {
    return '添加地图失败：$error';
  }

  @override
  String deleteMapFailed(String error) {
    return '删除地图失败：$error';
  }

  @override
  String loadMapsFailed(String error) {
    return '加载地图失败：$error';
  }

  @override
  String get legendManager => '图例管理';

  @override
  String get legendManagerEmpty => '暂无图例';

  @override
  String get addLegend => '添加图例';

  @override
  String get legendTitle => '图例标题';

  @override
  String get enterLegendTitle => '请输入图例标题';

  @override
  String get legendVersion => '图例版本';

  @override
  String get selectCenterPoint => '选择中心点:';

  @override
  String get deleteLegend => '删除图例';

  @override
  String confirmDeleteLegend(String title) {
    return '确认删除图例 \"$title\" 吗？';
  }

  @override
  String get legendDeletedSuccessfully => '图例删除成功';

  @override
  String deleteLegendFailed(String error) {
    return '删除图例失败：$error';
  }

  @override
  String get uploadLocalizationFile => '上传本地化文件';

  @override
  String get mapEditor => '地图编辑器';

  @override
  String get mapPreview => '地图预览';

  @override
  String get close => '关闭';

  @override
  String get layers => '图层';

  @override
  String get legend => '图例';

  @override
  String get addLayer => '添加图层';

  @override
  String get deleteLayer => '删除图层';

  @override
  String get opacity => '不透明度';

  @override
  String get elements => '个元素';

  @override
  String get drawingTools => '绘制工具';

  @override
  String get line => '直线';

  @override
  String get dashedLine => '虚线';

  @override
  String get arrow => '箭头';

  @override
  String get rectangle => '矩形';

  @override
  String get hollowRectangle => '空心矩形';

  @override
  String get diagonalLines => '对角线';

  @override
  String get crossLines => '十字线';

  @override
  String get dotGrid => '点网格';

  @override
  String get strokeWidth => '笔触宽度';

  @override
  String get color => '颜色';

  @override
  String get addLegendGroup => '添加图例组';

  @override
  String get deleteLegendGroup => '删除图例组';

  @override
  String get saveMap => '保存地图';

  @override
  String get mode => '模式';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get userPreferences => '用户偏好设置';

  @override
  String get layerSelectionSettings => '图层选择设置';

  @override
  String get autoSelectLastLayerInGroup => '自动选择图层组的最后一层';

  @override
  String get autoSelectLastLayerInGroupDescription => '选择图层组时自动选择该组的最后一层';

  @override
  String get primaryColor => '主色调';

  @override
  String get accentColor => '强调色';

  @override
  String get autoSave => '自动保存';

  @override
  String get gridSize => '网格大小';

  @override
  String get compactMode => '紧凑模式';

  @override
  String get showTooltips => '显示工具提示';

  @override
  String get enableAnimations => '启用动画';

  @override
  String get animationDuration => '动画持续时间（毫秒）';

  @override
  String get recentColors => '最近使用的颜色';

  @override
  String get favoriteStrokeWidths => '常用线条宽度';

  @override
  String get showAdvancedTools => '显示高级工具';

  @override
  String get currentUser => '当前用户';

  @override
  String get userProfiles => '用户配置文件';

  @override
  String get exportSettings => '导出设置';

  @override
  String get importSettings => '导入设置';

  @override
  String get resetSettings => '重置为默认值';

  @override
  String get confirmResetSettings => '确定要将所有设置重置为默认值吗？此操作不可撤销。';

  @override
  String get settingsExported => '设置导出成功';

  @override
  String get settingsImported => '设置导入成功';

  @override
  String get settingsReset => '设置已重置为默认值';
}
