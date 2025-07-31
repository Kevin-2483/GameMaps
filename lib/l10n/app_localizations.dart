import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @aboutPageTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get aboutPageTitle_4821;

  /// No description provided for @aboutPageTitle_4901.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get aboutPageTitle_4901;

  /// No description provided for @aboutR6box_7281.
  ///
  /// In zh, this message translates to:
  /// **'关于 R6BOX'**
  String get aboutR6box_7281;

  /// No description provided for @about_5421.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about_5421;

  /// No description provided for @accentColor.
  ///
  /// In zh, this message translates to:
  /// **'强调色'**
  String get accentColor;

  /// No description provided for @accountAdded_5421.
  ///
  /// In zh, this message translates to:
  /// **'账户已添加'**
  String get accountAdded_5421;

  /// No description provided for @accountDeletedSuccess_4821.
  ///
  /// In zh, this message translates to:
  /// **'认证账户已删除'**
  String get accountDeletedSuccess_4821;

  /// No description provided for @accountInUseMessage_4821.
  ///
  /// In zh, this message translates to:
  /// **'此账户正在被 {configCount} 个配置使用，无法删除'**
  String accountInUseMessage_4821(Object configCount);

  /// No description provided for @accountNameHint_7532.
  ///
  /// In zh, this message translates to:
  /// **'例如：我的账户'**
  String get accountNameHint_7532;

  /// No description provided for @accountSettings_7421.
  ///
  /// In zh, this message translates to:
  /// **'账户设置'**
  String get accountSettings_7421;

  /// No description provided for @accountUpdated_5421.
  ///
  /// In zh, this message translates to:
  /// **'账户已更新'**
  String get accountUpdated_5421;

  /// No description provided for @activeClientDisplay.
  ///
  /// In zh, this message translates to:
  /// **'活跃客户端: {displayName}'**
  String activeClientDisplay(Object displayName);

  /// No description provided for @activeClient_7281.
  ///
  /// In zh, this message translates to:
  /// **'活跃客户端'**
  String get activeClient_7281;

  /// No description provided for @activeConfigCancelled_7281.
  ///
  /// In zh, this message translates to:
  /// **'活跃配置已取消'**
  String get activeConfigCancelled_7281;

  /// No description provided for @activeConfigChange.
  ///
  /// In zh, this message translates to:
  /// **'活跃配置变更: {displayName} ({clientId})'**
  String activeConfigChange(Object clientId, Object displayName);

  /// No description provided for @activeConfigCleared_7281.
  ///
  /// In zh, this message translates to:
  /// **'活跃配置已清除'**
  String get activeConfigCleared_7281;

  /// No description provided for @activeConfigLog.
  ///
  /// In zh, this message translates to:
  /// **'当前活跃配置: {displayName}'**
  String activeConfigLog(Object displayName);

  /// No description provided for @activeConfigSetSuccess_4821.
  ///
  /// In zh, this message translates to:
  /// **'活跃配置设置成功'**
  String get activeConfigSetSuccess_4821;

  /// No description provided for @activeMapWithCount.
  ///
  /// In zh, this message translates to:
  /// **'活跃地图 ({count})'**
  String activeMapWithCount(Object count);

  /// No description provided for @activeMap_7281.
  ///
  /// In zh, this message translates to:
  /// **'活跃地图'**
  String get activeMap_7281;

  /// No description provided for @activeMap_7421.
  ///
  /// In zh, this message translates to:
  /// **'活跃地图'**
  String get activeMap_7421;

  /// No description provided for @activeWebSocketClientConfigSet.
  ///
  /// In zh, this message translates to:
  /// **'活跃 WebSocket 客户端配置已设置: {clientId}'**
  String activeWebSocketClientConfigSet(Object clientId);

  /// No description provided for @activityLog_7281.
  ///
  /// In zh, this message translates to:
  /// **'活动日志'**
  String get activityLog_7281;

  /// No description provided for @actualSize_7421.
  ///
  /// In zh, this message translates to:
  /// **'实际大小'**
  String get actualSize_7421;

  /// No description provided for @adaptiveIconTheme_7421.
  ///
  /// In zh, this message translates to:
  /// **'让图标颜色适应当前主题'**
  String get adaptiveIconTheme_7421;

  /// No description provided for @addAccount_7421.
  ///
  /// In zh, this message translates to:
  /// **'添加账户'**
  String get addAccount_7421;

  /// No description provided for @addAllLayers_4821.
  ///
  /// In zh, this message translates to:
  /// **'添加全部图层'**
  String get addAllLayers_4821;

  /// No description provided for @addAtLeastOneExportItem_4821.
  ///
  /// In zh, this message translates to:
  /// **'请至少添加一个导出项'**
  String get addAtLeastOneExportItem_4821;

  /// No description provided for @addAuthAccount_8753.
  ///
  /// In zh, this message translates to:
  /// **'添加认证账户'**
  String get addAuthAccount_8753;

  /// No description provided for @addBackground_7281.
  ///
  /// In zh, this message translates to:
  /// **'添加背景'**
  String get addBackground_7281;

  /// No description provided for @addButton_4821.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get addButton_4821;

  /// No description provided for @addButton_5421.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get addButton_5421;

  /// No description provided for @addButton_7284.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get addButton_7284;

  /// No description provided for @addButton_7421.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get addButton_7421;

  /// No description provided for @addColorFailed.
  ///
  /// In zh, this message translates to:
  /// **'添加颜色失败: {e}'**
  String addColorFailed(Object e);

  /// No description provided for @addColorFailed_4829.
  ///
  /// In zh, this message translates to:
  /// **'添加颜色失败'**
  String get addColorFailed_4829;

  /// No description provided for @addColor_7421.
  ///
  /// In zh, this message translates to:
  /// **'添加颜色'**
  String get addColor_7421;

  /// No description provided for @addConfiguration_7421.
  ///
  /// In zh, this message translates to:
  /// **'添加配置'**
  String get addConfiguration_7421;

  /// No description provided for @addCustomColorFailed.
  ///
  /// In zh, this message translates to:
  /// **'添加自定义颜色失败: {error}'**
  String addCustomColorFailed(Object error);

  /// No description provided for @addCustomColorFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'添加自定义颜色失败: {e}'**
  String addCustomColorFailed_7285(Object e);

  /// No description provided for @addCustomColor_4271.
  ///
  /// In zh, this message translates to:
  /// **'添加自定义颜色'**
  String get addCustomColor_4271;

  /// No description provided for @addCustomColor_7421.
  ///
  /// In zh, this message translates to:
  /// **'添加自定义颜色'**
  String get addCustomColor_7421;

  /// No description provided for @addCustomField_4949.
  ///
  /// In zh, this message translates to:
  /// **'添加自定义字段'**
  String get addCustomField_4949;

  /// No description provided for @addCustomTagFailed.
  ///
  /// In zh, this message translates to:
  /// **'添加自定义标签失败: {error}'**
  String addCustomTagFailed(Object error);

  /// No description provided for @addCustomTagFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'添加自定义标签失败: {e}'**
  String addCustomTagFailed_7285(Object e);

  /// No description provided for @addCustomTagHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'添加自定义标签'**
  String get addCustomTagHint_4821;

  /// No description provided for @addCustomTag_4271.
  ///
  /// In zh, this message translates to:
  /// **'添加自定义标签'**
  String get addCustomTag_4271;

  /// No description provided for @addDefaultLayerWithReactiveSystem.
  ///
  /// In zh, this message translates to:
  /// **'使用响应式系统添加默认图层: {name}'**
  String addDefaultLayerWithReactiveSystem(Object name);

  /// No description provided for @addDividerLine_4821.
  ///
  /// In zh, this message translates to:
  /// **'添加分割线'**
  String get addDividerLine_4821;

  /// No description provided for @addDrawingElement.
  ///
  /// In zh, this message translates to:
  /// **'添加绘制元素: {layerId}/{elementId}'**
  String addDrawingElement(Object elementId, Object layerId);

  /// No description provided for @addExportItem_4964.
  ///
  /// In zh, this message translates to:
  /// **'添加导出项'**
  String get addExportItem_4964;

  /// No description provided for @addImageAreaTooltip_4282.
  ///
  /// In zh, this message translates to:
  /// **'添加图片区域'**
  String get addImageAreaTooltip_4282;

  /// No description provided for @addLabel_4271.
  ///
  /// In zh, this message translates to:
  /// **'添加标签'**
  String get addLabel_4271;

  /// No description provided for @addLayer.
  ///
  /// In zh, this message translates to:
  /// **'添加图层'**
  String get addLayer;

  /// No description provided for @addLayerFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'添加图层失败: {error}'**
  String addLayerFailed_4821(Object error);

  /// No description provided for @addLayerHint_7281.
  ///
  /// In zh, this message translates to:
  /// **'点击左侧加号\n添加图层'**
  String get addLayerHint_7281;

  /// No description provided for @addLayerLog.
  ///
  /// In zh, this message translates to:
  /// **'添加图层: {name}'**
  String addLayerLog(Object name);

  /// No description provided for @addLayerOrItemFromLeft_4821.
  ///
  /// In zh, this message translates to:
  /// **'从左侧添加图层或项目'**
  String get addLayerOrItemFromLeft_4821;

  /// No description provided for @addLayerWithReactiveSystem.
  ///
  /// In zh, this message translates to:
  /// **'使用响应式系统添加图层: {name}'**
  String addLayerWithReactiveSystem(Object name);

  /// No description provided for @addLayer_7281.
  ///
  /// In zh, this message translates to:
  /// **'添加图层'**
  String get addLayer_7281;

  /// No description provided for @addLegend.
  ///
  /// In zh, this message translates to:
  /// **'添加图例'**
  String get addLegend;

  /// No description provided for @addLegendFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'添加图例失败: {e}'**
  String addLegendFailed_7285(Object e);

  /// No description provided for @addLegendGroup.
  ///
  /// In zh, this message translates to:
  /// **'添加图例组'**
  String get addLegendGroup;

  /// No description provided for @addLegendGroupElement.
  ///
  /// In zh, this message translates to:
  /// **'添加图例组元素 - renderOrder={legendRenderOrder}, selected={isLegendSelected}'**
  String addLegendGroupElement(
    Object isLegendSelected,
    Object legendRenderOrder,
  );

  /// No description provided for @addLegendGroupFailed.
  ///
  /// In zh, this message translates to:
  /// **'添加图例组失败: {error}'**
  String addLegendGroupFailed(Object error);

  /// No description provided for @addLegendGroup_7352.
  ///
  /// In zh, this message translates to:
  /// **'添加图例组'**
  String get addLegendGroup_7352;

  /// No description provided for @addLegendTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'添加图例'**
  String get addLegendTooltip_7281;

  /// No description provided for @addLegend_4271.
  ///
  /// In zh, this message translates to:
  /// **'添加图例'**
  String get addLegend_4271;

  /// No description provided for @addLegend_4521.
  ///
  /// In zh, this message translates to:
  /// **'添加图例'**
  String get addLegend_4521;

  /// No description provided for @addLineWidthFailed.
  ///
  /// In zh, this message translates to:
  /// **'添加常用线条宽度失败: {error}'**
  String addLineWidthFailed(Object error);

  /// No description provided for @addLineWidth_4821.
  ///
  /// In zh, this message translates to:
  /// **'添加线条宽度'**
  String get addLineWidth_4821;

  /// No description provided for @addMap.
  ///
  /// In zh, this message translates to:
  /// **'添加地图'**
  String get addMap;

  /// No description provided for @addMapFailed.
  ///
  /// In zh, this message translates to:
  /// **'添加地图失败：{error}'**
  String addMapFailed(Object error);

  /// No description provided for @addNewLineWidth_4821.
  ///
  /// In zh, this message translates to:
  /// **'添加新的线条宽度'**
  String get addNewLineWidth_4821;

  /// No description provided for @addNewMapWithVersion.
  ///
  /// In zh, this message translates to:
  /// **'添加新地图: {title} (版本 {version})'**
  String addNewMapWithVersion(Object title, Object version);

  /// No description provided for @addNewShortcut_7421.
  ///
  /// In zh, this message translates to:
  /// **'添加新快捷键:'**
  String get addNewShortcut_7421;

  /// No description provided for @addNewTagHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'添加新标签'**
  String get addNewTagHint_4821;

  /// No description provided for @addNoteDebug_7421.
  ///
  /// In zh, this message translates to:
  /// **'添加便利贴: {id}'**
  String addNoteDebug_7421(Object id);

  /// No description provided for @addNoteFailed.
  ///
  /// In zh, this message translates to:
  /// **'添加便签失败: {e}'**
  String addNoteFailed(Object e);

  /// No description provided for @addNoteFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'添加便签失败: {e}'**
  String addNoteFailed_7285(Object e);

  /// No description provided for @addNote_7421.
  ///
  /// In zh, this message translates to:
  /// **'添加便签'**
  String get addNote_7421;

  /// No description provided for @addRecentColorFailed.
  ///
  /// In zh, this message translates to:
  /// **'添加最近使用颜色失败: {error}'**
  String addRecentColorFailed(Object error);

  /// No description provided for @addRecentColorsTitle_7421.
  ///
  /// In zh, this message translates to:
  /// **'添加最近使用颜色'**
  String get addRecentColorsTitle_7421;

  /// No description provided for @addRecentTagFailed.
  ///
  /// In zh, this message translates to:
  /// **'添加最近使用标签失败: {error}'**
  String addRecentTagFailed(Object error);

  /// No description provided for @addScript.
  ///
  /// In zh, this message translates to:
  /// **'添加脚本'**
  String get addScript;

  /// No description provided for @addShortcut_7421.
  ///
  /// In zh, this message translates to:
  /// **'添加快捷键'**
  String get addShortcut_7421;

  /// No description provided for @addStickyNote_7421.
  ///
  /// In zh, this message translates to:
  /// **'添加便签'**
  String get addStickyNote_7421;

  /// No description provided for @addTagTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'添加标签'**
  String get addTagTooltip_7281;

  /// No description provided for @addTag_7421.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get addTag_7421;

  /// No description provided for @addTextToNoteWithFontSize.
  ///
  /// In zh, this message translates to:
  /// **'添加文本到便签 (字体大小: {fontSize}px)'**
  String addTextToNoteWithFontSize(Object fontSize);

  /// No description provided for @addTextToNote_7421.
  ///
  /// In zh, this message translates to:
  /// **'添加文本到便签'**
  String get addTextToNote_7421;

  /// No description provided for @addTextTooltip_4821.
  ///
  /// In zh, this message translates to:
  /// **'添加文本'**
  String get addTextTooltip_4821;

  /// No description provided for @addTextWithFontSize.
  ///
  /// In zh, this message translates to:
  /// **'添加文本 (字体大小: {fontSize}px)'**
  String addTextWithFontSize(Object fontSize);

  /// No description provided for @addText_4271.
  ///
  /// In zh, this message translates to:
  /// **'添加文本'**
  String get addText_4271;

  /// No description provided for @addToCustom_7281.
  ///
  /// In zh, this message translates to:
  /// **'添加到自定义'**
  String get addToCustom_7281;

  /// No description provided for @addToPlaylist_4271.
  ///
  /// In zh, this message translates to:
  /// **'添加到播放列表'**
  String get addToPlaylist_4271;

  /// No description provided for @addWebDavConfig.
  ///
  /// In zh, this message translates to:
  /// **'添加 WebDAV 配置'**
  String get addWebDavConfig;

  /// No description provided for @addedLineWidth_4821.
  ///
  /// In zh, this message translates to:
  /// **'已添加的线条宽度:'**
  String get addedLineWidth_4821;

  /// No description provided for @addedPathsCount.
  ///
  /// In zh, this message translates to:
  /// **'新增路径: {count} 个'**
  String addedPathsCount(Object count);

  /// No description provided for @addedToQueue_7421.
  ///
  /// In zh, this message translates to:
  /// **'添加到播放队列'**
  String get addedToQueue_7421;

  /// No description provided for @addingCustomColor_7281.
  ///
  /// In zh, this message translates to:
  /// **'开始添加自定义颜色: {color}'**
  String addingCustomColor_7281(Object color);

  /// No description provided for @adjustDrawingElementHandleSize_7281.
  ///
  /// In zh, this message translates to:
  /// **'调整绘制元素控制柄的大小'**
  String get adjustDrawingElementHandleSize_7281;

  /// No description provided for @adjustNewIndexTo.
  ///
  /// In zh, this message translates to:
  /// **'调整 newIndex 到: {newIndex}'**
  String adjustNewIndexTo(Object newIndex);

  /// No description provided for @adjustVoicePitch_4271.
  ///
  /// In zh, this message translates to:
  /// **'调整语音音调高低'**
  String get adjustVoicePitch_4271;

  /// No description provided for @adjustVoiceSpeed_4271.
  ///
  /// In zh, this message translates to:
  /// **'调整语音播放速度'**
  String get adjustVoiceSpeed_4271;

  /// No description provided for @adjustVoiceVolume_4251.
  ///
  /// In zh, this message translates to:
  /// **'调整语音播放音量'**
  String get adjustVoiceVolume_4251;

  /// No description provided for @adjustedNewIndex_7421.
  ///
  /// In zh, this message translates to:
  /// **'调整后的 newIndex: {newIndex}'**
  String adjustedNewIndex_7421(Object newIndex);

  /// No description provided for @advancedColorPicker_4821.
  ///
  /// In zh, this message translates to:
  /// **'高级颜色选择器'**
  String get advancedColorPicker_4821;

  /// No description provided for @affectsPerspectiveBuffer_4821.
  ///
  /// In zh, this message translates to:
  /// **'影响透视缓冲'**
  String get affectsPerspectiveBuffer_4821;

  /// No description provided for @albumLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'专辑'**
  String get albumLabel_4821;

  /// No description provided for @allLayersDebugMessage_7421.
  ///
  /// In zh, this message translates to:
  /// **'allLayers从_currentMap获取: {layers}'**
  String allLayersDebugMessage_7421(Object layers);

  /// No description provided for @allLayersHiddenLegendAutoHidden.
  ///
  /// In zh, this message translates to:
  /// **'已启用：绑定的 {totalLayersCount} 个图层均已隐藏，图例组已自动隐藏'**
  String allLayersHiddenLegendAutoHidden(Object totalLayersCount);

  /// No description provided for @allLayersShown_7281.
  ///
  /// In zh, this message translates to:
  /// **'已显示所有图层'**
  String get allLayersShown_7281;

  /// No description provided for @allPathsValid_7281.
  ///
  /// In zh, this message translates to:
  /// **'所有文件路径检查通过，可以直接导入'**
  String get allPathsValid_7281;

  /// No description provided for @allReactiveVersionsSavedToVfs_7281.
  ///
  /// In zh, this message translates to:
  /// **'所有响应式版本数据已成功保存到VFS存储'**
  String get allReactiveVersionsSavedToVfs_7281;

  /// No description provided for @allTimersCleared_4821.
  ///
  /// In zh, this message translates to:
  /// **'所有计时器已清空'**
  String get allTimersCleared_4821;

  /// No description provided for @allTimersStopped_7281.
  ///
  /// In zh, this message translates to:
  /// **'所有计时器已停止'**
  String get allTimersStopped_7281;

  /// No description provided for @allUserPreferencesCleared_4821.
  ///
  /// In zh, this message translates to:
  /// **'所有用户偏好设置数据已清除'**
  String get allUserPreferencesCleared_4821;

  /// No description provided for @allVersionsSaved_7281.
  ///
  /// In zh, this message translates to:
  /// **'标记所有版本已保存 [{mapTitle}]'**
  String allVersionsSaved_7281(Object mapTitle);

  /// No description provided for @allWebDavPasswordsCleared_7281.
  ///
  /// In zh, this message translates to:
  /// **'所有WebDAV密码已清理'**
  String get allWebDavPasswordsCleared_7281;

  /// No description provided for @analysis_2346.
  ///
  /// In zh, this message translates to:
  /// **'分析'**
  String get analysis_2346;

  /// No description provided for @anchorJumpFailed_4829.
  ///
  /// In zh, this message translates to:
  /// **'锚点跳转失败: {e}'**
  String anchorJumpFailed_4829(Object e);

  /// No description provided for @anchorJumpFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'跳转到锚点失败: {e}'**
  String anchorJumpFailed_7285(Object e);

  /// No description provided for @anchorNotFound_7425.
  ///
  /// In zh, this message translates to:
  /// **'未找到锚点: {searchText}'**
  String anchorNotFound_7425(Object searchText);

  /// No description provided for @androidFeatures.
  ///
  /// In zh, this message translates to:
  /// **'Android 功能：'**
  String get androidFeatures;

  /// No description provided for @androidPlatform.
  ///
  /// In zh, this message translates to:
  /// **'Android 平台'**
  String get androidPlatform;

  /// No description provided for @androidSpecificFeatures.
  ///
  /// In zh, this message translates to:
  /// **'可以在此处实现 Android 特定功能。'**
  String get androidSpecificFeatures;

  /// No description provided for @animateColorChange_9202.
  ///
  /// In zh, this message translates to:
  /// **'动画改变颜色'**
  String get animateColorChange_9202;

  /// No description provided for @animateElementMovement_1222.
  ///
  /// In zh, this message translates to:
  /// **'动画移动元素'**
  String get animateElementMovement_1222;

  /// No description provided for @animationDuration.
  ///
  /// In zh, this message translates to:
  /// **'动画持续时间（毫秒）'**
  String get animationDuration;

  /// No description provided for @animationDuration_4271.
  ///
  /// In zh, this message translates to:
  /// **'动画持续时间'**
  String get animationDuration_4271;

  /// No description provided for @animationScriptExample_7181.
  ///
  /// In zh, this message translates to:
  /// **'动画脚本示例'**
  String get animationScriptExample_7181;

  /// No description provided for @animation_5678.
  ///
  /// In zh, this message translates to:
  /// **'动画'**
  String get animation_5678;

  /// No description provided for @animation_7281.
  ///
  /// In zh, this message translates to:
  /// **'动画'**
  String get animation_7281;

  /// No description provided for @annotationLayer_1234.
  ///
  /// In zh, this message translates to:
  /// **'标注图层'**
  String get annotationLayer_1234;

  /// No description provided for @apiResponseStatusError_7284.
  ///
  /// In zh, this message translates to:
  /// **'API 响应状态错误: {status}'**
  String apiResponseStatusError_7284(Object status);

  /// No description provided for @appClips.
  ///
  /// In zh, this message translates to:
  /// **'App Clips'**
  String get appClips;

  /// No description provided for @appDescriptionText_4904.
  ///
  /// In zh, this message translates to:
  /// **'R6BOX 是一款专为《彩虹六号：围攻》玩家设计的综合工具箱应用。提供地图编辑器、战术分析、数据统计等功能，帮助玩家提升游戏体验和竞技水平。'**
  String get appDescriptionText_4904;

  /// No description provided for @appDescription_4903.
  ///
  /// In zh, this message translates to:
  /// **'应用描述'**
  String get appDescription_4903;

  /// No description provided for @appName_4914.
  ///
  /// In zh, this message translates to:
  /// **'R6BOX'**
  String get appName_4914;

  /// No description provided for @appSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'应用设置'**
  String get appSettings_4821;

  /// No description provided for @appShortcuts.
  ///
  /// In zh, this message translates to:
  /// **'应用快捷方式'**
  String get appShortcuts;

  /// No description provided for @appVersion_4902.
  ///
  /// In zh, this message translates to:
  /// **'版本 {version} ({buildNumber})'**
  String appVersion_4902(Object buildNumber, Object version);

  /// No description provided for @applySameResolutionToAllConflicts_4821.
  ///
  /// In zh, this message translates to:
  /// **'对剩余的所有冲突使用相同的处理方式'**
  String get applySameResolutionToAllConflicts_4821;

  /// No description provided for @applyToAllConflicts_7281.
  ///
  /// In zh, this message translates to:
  /// **'应用到所有冲突'**
  String get applyToAllConflicts_7281;

  /// No description provided for @arabicSA_4890.
  ///
  /// In zh, this message translates to:
  /// **'阿拉伯语 (沙特阿拉伯)'**
  String get arabicSA_4890;

  /// No description provided for @arabic_4836.
  ///
  /// In zh, this message translates to:
  /// **'阿拉伯语'**
  String get arabic_4836;

  /// No description provided for @argbColorDescription_7281.
  ///
  /// In zh, this message translates to:
  /// **'• ARGB: FFFF0000 (红色，不透明)'**
  String get argbColorDescription_7281;

  /// No description provided for @arrow.
  ///
  /// In zh, this message translates to:
  /// **'箭头'**
  String get arrow;

  /// No description provided for @arrowLabel_5421.
  ///
  /// In zh, this message translates to:
  /// **'箭头'**
  String get arrowLabel_5421;

  /// No description provided for @arrowTool_7890.
  ///
  /// In zh, this message translates to:
  /// **'箭头'**
  String get arrowTool_7890;

  /// No description provided for @arrow_4823.
  ///
  /// In zh, this message translates to:
  /// **'箭头'**
  String get arrow_4823;

  /// No description provided for @arrow_6423.
  ///
  /// In zh, this message translates to:
  /// **'箭头'**
  String get arrow_6423;

  /// No description provided for @artistLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'艺术家'**
  String get artistLabel_4821;

  /// No description provided for @assetDeletionFailed_7425.
  ///
  /// In zh, this message translates to:
  /// **'删除资产失败 [{mapTitle}/{hash}]: {e}'**
  String assetDeletionFailed_7425(Object e, Object hash, Object mapTitle);

  /// No description provided for @assetFetchFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取资产失败 [{arg0}/{arg1}]: {arg2}'**
  String assetFetchFailed(Object arg0, Object arg1, Object arg2);

  /// No description provided for @asyncFunctionCompleteDebug.
  ///
  /// In zh, this message translates to:
  /// **'异步函数 {functionName} 完成，结果类型: {runtimeType}'**
  String asyncFunctionCompleteDebug(Object functionName, Object runtimeType);

  /// No description provided for @asyncFunctionError_4821.
  ///
  /// In zh, this message translates to:
  /// **'异步函数 {functionName} 出错: {error}'**
  String asyncFunctionError_4821(Object error, Object functionName);

  /// No description provided for @atlasClient_7421.
  ///
  /// In zh, this message translates to:
  /// **'地图集客户端'**
  String get atlasClient_7421;

  /// No description provided for @audioBackgroundPlay_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎵 窗口关闭，音频继续在后台播放'**
  String get audioBackgroundPlay_7281;

  /// No description provided for @audioBalanceError_4821.
  ///
  /// In zh, this message translates to:
  /// **'设置音频平衡失败: {e}'**
  String audioBalanceError_4821(Object e);

  /// No description provided for @audioBalanceSet_7421.
  ///
  /// In zh, this message translates to:
  /// **'音频平衡设置为 {balance}'**
  String audioBalanceSet_7421(Object balance);

  /// No description provided for @audioBalance_7281.
  ///
  /// In zh, this message translates to:
  /// **'音频平衡'**
  String get audioBalance_7281;

  /// No description provided for @audioConversionComplete_7284.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioProcessor.convertMarkdownAudios: 转换完成'**
  String get audioConversionComplete_7284;

  /// No description provided for @audioCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'音频数量: {audioCount}'**
  String audioCountLabel(Object audioCount);

  /// No description provided for @audioEqualizer_4821.
  ///
  /// In zh, this message translates to:
  /// **'音频均衡器'**
  String get audioEqualizer_4821;

  /// No description provided for @audioFile_7281.
  ///
  /// In zh, this message translates to:
  /// **'音频文件'**
  String get audioFile_7281;

  /// No description provided for @audioInfo_4271.
  ///
  /// In zh, this message translates to:
  /// **'音频信息'**
  String get audioInfo_4271;

  /// No description provided for @audioInfo_7284.
  ///
  /// In zh, this message translates to:
  /// **'音频信息'**
  String get audioInfo_7284;

  /// No description provided for @audioInfo_7421.
  ///
  /// In zh, this message translates to:
  /// **'音频信息'**
  String get audioInfo_7421;

  /// No description provided for @audioLinkCopiedToClipboard_4821.
  ///
  /// In zh, this message translates to:
  /// **'音频链接已复制到剪贴板'**
  String get audioLinkCopiedToClipboard_4821;

  /// No description provided for @audioList_7421.
  ///
  /// In zh, this message translates to:
  /// **'音频列表:'**
  String get audioList_7421;

  /// No description provided for @audioLoadFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'音频加载失败'**
  String get audioLoadFailed_7281;

  /// No description provided for @audioNodeBuildStart_7421.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioNode.build: 开始构建 - src: \\{src}'**
  String audioNodeBuildStart_7421(Object src);

  /// No description provided for @audioNodeGenerationLog.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioProcessor: 生成AudioNode - tag: \\{tag}, attributes: \\{attributes}, textContent: \\{textContent}, uuid: {playerId}'**
  String audioNodeGenerationLog(
    Object attributes,
    Object playerId,
    Object tag,
    Object textContent,
  );

  /// No description provided for @audioPlaybackFailed.
  ///
  /// In zh, this message translates to:
  /// **'停止音频播放失败: {e}'**
  String audioPlaybackFailed(Object e);

  /// No description provided for @audioPlayerClearQueue_4821.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 清空播放队列'**
  String get audioPlayerClearQueue_4821;

  /// No description provided for @audioPlayerError_4821.
  ///
  /// In zh, this message translates to:
  /// **'AudioNode: 播放器错误 - {error}'**
  String audioPlayerError_4821(Object error);

  /// No description provided for @audioPlayerFallback_4821.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 跳转操作超时，使用备选方案'**
  String get audioPlayerFallback_4821;

  /// No description provided for @audioPlayerInitFailed.
  ///
  /// In zh, this message translates to:
  /// **'初始化音频播放器失败: {e}'**
  String audioPlayerInitFailed(Object e);

  /// No description provided for @audioPlayerInitFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'初始化失败'**
  String get audioPlayerInitFailed_4821;

  /// No description provided for @audioPlayerInitFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'音频播放器初始化失败: {e}'**
  String audioPlayerInitFailed_7284(Object e);

  /// No description provided for @audioPlayerInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 音频播放器初始化完成'**
  String get audioPlayerInitialized_7281;

  /// No description provided for @audioPlayerPaused_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 已暂停'**
  String get audioPlayerPaused_7281;

  /// No description provided for @audioPlayerQueueUpdated_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 播放队列已更新'**
  String get audioPlayerQueueUpdated_7281;

  /// No description provided for @audioPlayerReachedEnd_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 已到播放队列末尾'**
  String get audioPlayerReachedEnd_7281;

  /// No description provided for @audioPlayerReachedStart_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 已到播放队列开头'**
  String get audioPlayerReachedStart_7281;

  /// No description provided for @audioPlayerServiceGenerateUrl_4821.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 从VFS生成播放URL'**
  String get audioPlayerServiceGenerateUrl_4821;

  /// No description provided for @audioPlayerStartPlaying_7421.
  ///
  /// In zh, this message translates to:
  /// **'开始播放 - {audioSource}'**
  String audioPlayerStartPlaying_7421(Object audioSource);

  /// No description provided for @audioPlayerStopFailure_4821.
  ///
  /// In zh, this message translates to:
  /// **'停止失败 - {e}'**
  String audioPlayerStopFailure_4821(Object e);

  /// No description provided for @audioPlayerStopped_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 已停止'**
  String get audioPlayerStopped_7281;

  /// No description provided for @audioPlayerTempQueuePlaying_7421.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 临时队列开始播放 - {title}'**
  String audioPlayerTempQueuePlaying_7421(Object title);

  /// No description provided for @audioPlayerTimeout_4821.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 暂停操作超时，但继续处理'**
  String get audioPlayerTimeout_4821;

  /// No description provided for @audioPlayerTimeout_7421.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 播放操作超时，但继续处理'**
  String get audioPlayerTimeout_7421;

  /// No description provided for @audioPlayerTitle_7281.
  ///
  /// In zh, this message translates to:
  /// **'音频播放器'**
  String get audioPlayerTitle_7281;

  /// No description provided for @audioPlayerUsingNetworkUrl_4821.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 使用网络URL播放'**
  String get audioPlayerUsingNetworkUrl_4821;

  /// No description provided for @audioProcessorConvertMarkdownAudios.
  ///
  /// In zh, this message translates to:
  /// **'AudioProcessor.convertMarkdownAudios: 生成标签 {audioTag}'**
  String audioProcessorConvertMarkdownAudios(Object audioTag);

  /// No description provided for @audioProcessorConvertMarkdownAudios_7428.
  ///
  /// In zh, this message translates to:
  /// **'AudioProcessor.convertMarkdownAudios: 转换 {src}'**
  String audioProcessorConvertMarkdownAudios_7428(Object src);

  /// No description provided for @audioProcessorConvertStart_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioProcessor.convertMarkdownAudios: 开始转换'**
  String get audioProcessorConvertStart_7281;

  /// No description provided for @audioProcessorCreated_4821.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioProcessor: 创建音频生成器'**
  String get audioProcessorCreated_4821;

  /// No description provided for @audioProcessorDebugInfo.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioProcessor.containsAudio: text长度={textLength}, 包含音频={result}'**
  String audioProcessorDebugInfo(Object result, Object textLength);

  /// No description provided for @audioServiceCleanupFailed.
  ///
  /// In zh, this message translates to:
  /// **'清理音频服务失败: {e}'**
  String audioServiceCleanupFailed(Object e);

  /// No description provided for @audioServiceError_4829.
  ///
  /// In zh, this message translates to:
  /// **'停止音频服务时发生错误: {e}'**
  String audioServiceError_4829(Object e);

  /// No description provided for @audioServiceStopFailed.
  ///
  /// In zh, this message translates to:
  /// **'停止音频播放服务失败: {e}'**
  String audioServiceStopFailed(Object e);

  /// No description provided for @audioServiceStopTime.
  ///
  /// In zh, this message translates to:
  /// **'音频服务停止耗时: {elapsedMilliseconds}ms'**
  String audioServiceStopTime(Object elapsedMilliseconds);

  /// No description provided for @audioServiceStopped_7281.
  ///
  /// In zh, this message translates to:
  /// **'音频服务停止完成'**
  String get audioServiceStopped_7281;

  /// No description provided for @audioSourceLoaded_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 音频源加载完成'**
  String get audioSourceLoaded_7281;

  /// No description provided for @audioSourceLoading_4821.
  ///
  /// In zh, this message translates to:
  /// **'开始加载音频源 - {source}'**
  String audioSourceLoading_4821(Object source);

  /// No description provided for @audioStatus_7421.
  ///
  /// In zh, this message translates to:
  /// **'音频{status}'**
  String audioStatus_7421(Object status);

  /// No description provided for @audioSyntaxParserAdded_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎵 _buildMarkdownContent: 添加音频语法解析器和生成器'**
  String get audioSyntaxParserAdded_7281;

  /// No description provided for @authFailedChallengeDecrypt_7281.
  ///
  /// In zh, this message translates to:
  /// **'authFailedChallengeDecrypt'**
  String get authFailedChallengeDecrypt_7281;

  /// No description provided for @authFailedMessage_4821.
  ///
  /// In zh, this message translates to:
  /// **'认证失败'**
  String get authFailedMessage_4821;

  /// No description provided for @authMessageSent.
  ///
  /// In zh, this message translates to:
  /// **'已发送认证消息: {type}'**
  String authMessageSent(Object type);

  /// No description provided for @authProcessError_4821.
  ///
  /// In zh, this message translates to:
  /// **'认证流程处理错误: {e}'**
  String authProcessError_4821(Object e);

  /// No description provided for @authenticating_6934.
  ///
  /// In zh, this message translates to:
  /// **'认证中'**
  String get authenticating_6934;

  /// No description provided for @authenticating_6943.
  ///
  /// In zh, this message translates to:
  /// **'认证中'**
  String get authenticating_6943;

  /// No description provided for @authenticationAccount_7281.
  ///
  /// In zh, this message translates to:
  /// **'认证账户'**
  String get authenticationAccount_7281;

  /// No description provided for @authenticationError.
  ///
  /// In zh, this message translates to:
  /// **'认证过程中发生错误: {e}'**
  String authenticationError(Object e);

  /// No description provided for @authenticationError_7425.
  ///
  /// In zh, this message translates to:
  /// **'认证过程中发生错误: {e}'**
  String authenticationError_7425(Object e);

  /// No description provided for @authenticationFailed.
  ///
  /// In zh, this message translates to:
  /// **'authenticationFailed: {reason}'**
  String authenticationFailed(Object reason);

  /// No description provided for @authenticationResult_7425.
  ///
  /// In zh, this message translates to:
  /// **'认证结果'**
  String get authenticationResult_7425;

  /// No description provided for @authenticationSuccess_7421.
  ///
  /// In zh, this message translates to:
  /// **'authenticationSuccess'**
  String get authenticationSuccess_7421;

  /// No description provided for @authenticationTimeout_7281.
  ///
  /// In zh, this message translates to:
  /// **'认证流程超时'**
  String get authenticationTimeout_7281;

  /// No description provided for @author_4937.
  ///
  /// In zh, this message translates to:
  /// **'作者'**
  String get author_4937;

  /// No description provided for @author_5028.
  ///
  /// In zh, this message translates to:
  /// **'作者'**
  String get author_5028;

  /// No description provided for @autoCleanupDescription_4984.
  ///
  /// In zh, this message translates to:
  /// **'处理完成后会自动清理临时文件'**
  String get autoCleanupDescription_4984;

  /// No description provided for @autoCleanup_4983.
  ///
  /// In zh, this message translates to:
  /// **'自动清理'**
  String get autoCleanup_4983;

  /// No description provided for @autoCloseTooltip_4821.
  ///
  /// In zh, this message translates to:
  /// **'自动关闭：当点击其他工具栏时自动关闭此工具栏'**
  String get autoCloseTooltip_4821;

  /// No description provided for @autoCloseWhenLoseFocus_7281.
  ///
  /// In zh, this message translates to:
  /// **'自动关闭'**
  String get autoCloseWhenLoseFocus_7281;

  /// No description provided for @autoClose_7421.
  ///
  /// In zh, this message translates to:
  /// **'自动关闭'**
  String get autoClose_7421;

  /// No description provided for @autoControlLegendVisibility.
  ///
  /// In zh, this message translates to:
  /// **'启用后，根据绑定图层的可见性自动控制图例组显示/隐藏（共 {totalLayersCount} 个图层）'**
  String autoControlLegendVisibility(Object totalLayersCount);

  /// No description provided for @autoPlayText_4821.
  ///
  /// In zh, this message translates to:
  /// **'自动播放'**
  String get autoPlayText_4821;

  /// No description provided for @autoPresenceEnterMapEditor_7421.
  ///
  /// In zh, this message translates to:
  /// **'调用AutoPresenceManager.enterMapEditor'**
  String get autoPresenceEnterMapEditor_7421;

  /// No description provided for @autoResizeWindowHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'自动记录窗口大小变化并在下次启动时恢复'**
  String get autoResizeWindowHint_4821;

  /// No description provided for @autoSave.
  ///
  /// In zh, this message translates to:
  /// **'自动保存'**
  String get autoSave;

  /// No description provided for @autoSavePanelStateOnExit_4821.
  ///
  /// In zh, this message translates to:
  /// **'退出地图编辑器时自动保存面板折叠/展开状态'**
  String get autoSavePanelStateOnExit_4821;

  /// No description provided for @autoSaveSetting_7421.
  ///
  /// In zh, this message translates to:
  /// **'自动保存'**
  String get autoSaveSetting_7421;

  /// No description provided for @autoSaveWindowSizeDisabled_7281.
  ///
  /// In zh, this message translates to:
  /// **'自动保存窗口大小已禁用，跳过保存'**
  String get autoSaveWindowSizeDisabled_7281;

  /// No description provided for @autoSaveWindowSize_4271.
  ///
  /// In zh, this message translates to:
  /// **'自动保存窗口大小'**
  String get autoSaveWindowSize_4271;

  /// No description provided for @autoSave_7421.
  ///
  /// In zh, this message translates to:
  /// **'自动保存'**
  String get autoSave_7421;

  /// No description provided for @autoSelectLastLayerInGroup.
  ///
  /// In zh, this message translates to:
  /// **'自动选择图层组的最后一层'**
  String get autoSelectLastLayerInGroup;

  /// No description provided for @autoSelectLastLayerInGroupDescription.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组时自动选择该组的最后一层'**
  String get autoSelectLastLayerInGroupDescription;

  /// No description provided for @autoSwitchLegendGroupDrawer.
  ///
  /// In zh, this message translates to:
  /// **'自动切换图例组抽屉到绑定的图例组: {name}'**
  String autoSwitchLegendGroupDrawer(Object name);

  /// No description provided for @autoThemeDark.
  ///
  /// In zh, this message translates to:
  /// **'自动主题(当前深色)'**
  String get autoThemeDark;

  /// No description provided for @autoThemeLight.
  ///
  /// In zh, this message translates to:
  /// **'自动主题(当前浅色)'**
  String get autoThemeLight;

  /// No description provided for @automationScriptExample_1234.
  ///
  /// In zh, this message translates to:
  /// **'自动化脚本示例'**
  String get automationScriptExample_1234;

  /// No description provided for @automation_1234.
  ///
  /// In zh, this message translates to:
  /// **'自动化'**
  String get automation_1234;

  /// No description provided for @automation_7281.
  ///
  /// In zh, this message translates to:
  /// **'自动化'**
  String get automation_7281;

  /// No description provided for @availableFeatures.
  ///
  /// In zh, this message translates to:
  /// **'可用功能：{features}'**
  String availableFeatures(Object features);

  /// No description provided for @availableFeaturesMessage_7281.
  ///
  /// In zh, this message translates to:
  /// **'可用功能: {features}'**
  String availableFeaturesMessage_7281(Object features);

  /// No description provided for @availableLanguages_7421.
  ///
  /// In zh, this message translates to:
  /// **'可用语言: {availableLanguages}'**
  String availableLanguages_7421(Object availableLanguages);

  /// No description provided for @availableLayersCount.
  ///
  /// In zh, this message translates to:
  /// **'可用的图层 ({count})'**
  String availableLayersCount(Object count);

  /// No description provided for @availableLegendGroups.
  ///
  /// In zh, this message translates to:
  /// **'可用的图例组 ({count})'**
  String availableLegendGroups(Object count);

  /// No description provided for @availablePages.
  ///
  /// In zh, this message translates to:
  /// **'可用页面：{pages}'**
  String availablePages(Object pages);

  /// No description provided for @availablePagesList_7281.
  ///
  /// In zh, this message translates to:
  /// **'可用页面: {pages}'**
  String availablePagesList_7281(Object pages);

  /// No description provided for @availableVoicesMessage.
  ///
  /// In zh, this message translates to:
  /// **'可用语音: {availableVoices}'**
  String availableVoicesMessage(Object availableVoices);

  /// No description provided for @avatarRemoved_4281.
  ///
  /// In zh, this message translates to:
  /// **'头像已移除'**
  String get avatarRemoved_4281;

  /// No description provided for @avatarTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'头像'**
  String get avatarTitle_4821;

  /// No description provided for @avatarUploaded_7421.
  ///
  /// In zh, this message translates to:
  /// **'头像已上传'**
  String get avatarUploaded_7421;

  /// No description provided for @avatarUrlOptional_4821.
  ///
  /// In zh, this message translates to:
  /// **'头像URL（可选）'**
  String get avatarUrlOptional_4821;

  /// No description provided for @backButton_7421.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get backButton_7421;

  /// No description provided for @backButton_75.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get backButton_75;

  /// No description provided for @back_4821.
  ///
  /// In zh, this message translates to:
  /// **'后退'**
  String get back_4821;

  /// No description provided for @backgroundDialogClosed_7281.
  ///
  /// In zh, this message translates to:
  /// **'背景图片设置对话框已关闭，没有应用更改。'**
  String get backgroundDialogClosed_7281;

  /// No description provided for @backgroundElement_4821.
  ///
  /// In zh, this message translates to:
  /// **'背景元素'**
  String get backgroundElement_4821;

  /// No description provided for @backgroundImageOpacityLabel.
  ///
  /// In zh, this message translates to:
  /// **'背景图片透明度: {value}%'**
  String backgroundImageOpacityLabel(Object value);

  /// No description provided for @backgroundImageRemoved_4821.
  ///
  /// In zh, this message translates to:
  /// **'背景图片已移除'**
  String get backgroundImageRemoved_4821;

  /// No description provided for @backgroundImageSetting_4271.
  ///
  /// In zh, this message translates to:
  /// **'背景图片设置'**
  String get backgroundImageSetting_4271;

  /// No description provided for @backgroundImageSetting_4821.
  ///
  /// In zh, this message translates to:
  /// **'背景图片设置'**
  String get backgroundImageSetting_4821;

  /// No description provided for @backgroundImageSettings_7421.
  ///
  /// In zh, this message translates to:
  /// **'背景图片设置'**
  String get backgroundImageSettings_7421;

  /// No description provided for @backgroundImageUploaded_4821.
  ///
  /// In zh, this message translates to:
  /// **'背景图片已上传'**
  String get backgroundImageUploaded_4821;

  /// No description provided for @backgroundImage_7421.
  ///
  /// In zh, this message translates to:
  /// **'背景图片'**
  String get backgroundImage_7421;

  /// No description provided for @backgroundLayer_1234.
  ///
  /// In zh, this message translates to:
  /// **'背景图层'**
  String get backgroundLayer_1234;

  /// No description provided for @backgroundOpacity_4271.
  ///
  /// In zh, this message translates to:
  /// **'背景不透明度'**
  String get backgroundOpacity_4271;

  /// No description provided for @backgroundPattern_4271.
  ///
  /// In zh, this message translates to:
  /// **'背景图案'**
  String get backgroundPattern_4271;

  /// No description provided for @backgroundPlayStatus.
  ///
  /// In zh, this message translates to:
  /// **'🎵 AudioPlayerService: 后台播放 {status}'**
  String backgroundPlayStatus(Object status);

  /// No description provided for @backgroundServices.
  ///
  /// In zh, this message translates to:
  /// **'后台服务'**
  String get backgroundServices;

  /// No description provided for @background_5421.
  ///
  /// In zh, this message translates to:
  /// **'背景'**
  String get background_5421;

  /// No description provided for @background_7281.
  ///
  /// In zh, this message translates to:
  /// **'背景'**
  String get background_7281;

  /// No description provided for @backupRestoreUnimplemented_7281.
  ///
  /// In zh, this message translates to:
  /// **'恢复备份功能待实现'**
  String get backupRestoreUnimplemented_7281;

  /// No description provided for @base64DecodeFailed.
  ///
  /// In zh, this message translates to:
  /// **'解码base64图片失败: {e}'**
  String base64DecodeFailed(Object e);

  /// No description provided for @baseBufferMultiplierLog.
  ///
  /// In zh, this message translates to:
  /// **'   - 基础缓冲区倍数: {multiplier}x'**
  String baseBufferMultiplierLog(Object multiplier);

  /// No description provided for @baseBufferMultiplierText.
  ///
  /// In zh, this message translates to:
  /// **'基础缓冲区倍数: {value}x'**
  String baseBufferMultiplierText(Object value);

  /// No description provided for @baseGridSpacing_4827.
  ///
  /// In zh, this message translates to:
  /// **'基础网格间距: {value}px'**
  String baseGridSpacing_4827(Object value);

  /// No description provided for @baseIconSizeText.
  ///
  /// In zh, this message translates to:
  /// **'基础图标大小: {size}px'**
  String baseIconSizeText(Object size);

  /// No description provided for @baseLayer_1234.
  ///
  /// In zh, this message translates to:
  /// **'基础图层'**
  String get baseLayer_1234;

  /// No description provided for @basicDisplayArea_7421.
  ///
  /// In zh, this message translates to:
  /// **'基础显示区域: {width} x {height}'**
  String basicDisplayArea_7421(Object height, Object width);

  /// No description provided for @basicFloatingWindowDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'最简单的浮动窗口，包含标题和内容'**
  String get basicFloatingWindowDescription_4821;

  /// No description provided for @basicFloatingWindowExample_4821.
  ///
  /// In zh, this message translates to:
  /// **'基础浮动窗口示例'**
  String get basicFloatingWindowExample_4821;

  /// No description provided for @basicFloatingWindowTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'基础浮动窗口'**
  String get basicFloatingWindowTitle_4821;

  /// No description provided for @basicFloatingWindow_4821.
  ///
  /// In zh, this message translates to:
  /// **'基础浮动窗口'**
  String get basicFloatingWindow_4821;

  /// No description provided for @basicInfo_4821.
  ///
  /// In zh, this message translates to:
  /// **'基本信息'**
  String get basicInfo_4821;

  /// No description provided for @basicOperations_4821.
  ///
  /// In zh, this message translates to:
  /// **'基本操作'**
  String get basicOperations_4821;

  /// No description provided for @basicScreenSize.
  ///
  /// In zh, this message translates to:
  /// **'基础屏幕尺寸: {width} x {height}'**
  String basicScreenSize(Object height, Object width);

  /// No description provided for @batchAddToQueue_7421.
  ///
  /// In zh, this message translates to:
  /// **'批量添加到播放队列'**
  String get batchAddToQueue_7421;

  /// No description provided for @batchDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'批量下载文件 \"{fileName}\" 失败: {error}'**
  String batchDownloadFailed(Object error, Object fileName);

  /// No description provided for @batchLoadComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'批量加载完成: {directoryPath}, 共 {count} 个图例'**
  String batchLoadComplete_7281(Object count, Object directoryPath);

  /// No description provided for @batchLoadDirectoryFailed.
  ///
  /// In zh, this message translates to:
  /// **'批量加载目录失败: {directoryPath}, 错误: {e}'**
  String batchLoadDirectoryFailed(Object directoryPath, Object e);

  /// No description provided for @batchUpdateElements.
  ///
  /// In zh, this message translates to:
  /// **'批量更新绘制元素: {layerId}, 数量: {count}'**
  String batchUpdateElements(Object count, Object layerId);

  /// No description provided for @batchUpdateLayerFailed.
  ///
  /// In zh, this message translates to:
  /// **'批量更新图层失败: {error}'**
  String batchUpdateLayerFailed(Object error);

  /// No description provided for @batchUpdateLayersCount.
  ///
  /// In zh, this message translates to:
  /// **'批量更新图层，数量: {count}'**
  String batchUpdateLayersCount(Object count);

  /// No description provided for @batchUpdateTimerFailed.
  ///
  /// In zh, this message translates to:
  /// **'批量更新计时器失败: {e}'**
  String batchUpdateTimerFailed(Object e);

  /// No description provided for @batchUpdateTimerFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'批量更新计时器失败: {e}'**
  String batchUpdateTimerFailed_7285(Object e);

  /// No description provided for @batchUpdateWarning_7281.
  ///
  /// In zh, this message translates to:
  /// **'警告：没有批量更新接口，无法正确移动组'**
  String get batchUpdateWarning_7281;

  /// No description provided for @bindLayer_7281.
  ///
  /// In zh, this message translates to:
  /// **'绑定图层'**
  String get bindLayer_7281;

  /// No description provided for @bindLegendGroup_5421.
  ///
  /// In zh, this message translates to:
  /// **'绑定图例组'**
  String get bindLegendGroup_5421;

  /// No description provided for @bindScriptFailed.
  ///
  /// In zh, this message translates to:
  /// **'绑定脚本失败'**
  String get bindScriptFailed;

  /// No description provided for @blankPattern_4821.
  ///
  /// In zh, this message translates to:
  /// **'空白'**
  String get blankPattern_4821;

  /// No description provided for @blockCountUnit_7281.
  ///
  /// In zh, this message translates to:
  /// **'个'**
  String blockCountUnit_7281(Object count);

  /// No description provided for @blockFormula_4821.
  ///
  /// In zh, this message translates to:
  /// **'块级公式'**
  String get blockFormula_4821;

  /// No description provided for @blueRectangles_7282.
  ///
  /// In zh, this message translates to:
  /// **'个蓝色矩形'**
  String get blueRectangles_7282;

  /// No description provided for @bookmark_7281.
  ///
  /// In zh, this message translates to:
  /// **'书签'**
  String get bookmark_7281;

  /// No description provided for @booleanType_3456.
  ///
  /// In zh, this message translates to:
  /// **'布尔'**
  String get booleanType_3456;

  /// No description provided for @bottomCenter_0123.
  ///
  /// In zh, this message translates to:
  /// **'下中'**
  String get bottomCenter_0123;

  /// No description provided for @bottomLeftCut_4824.
  ///
  /// In zh, this message translates to:
  /// **'左下切割'**
  String get bottomLeftCut_4824;

  /// No description provided for @bottomLeftTriangle_4821.
  ///
  /// In zh, this message translates to:
  /// **'左下三角'**
  String get bottomLeftTriangle_4821;

  /// No description provided for @bottomLeft_6789.
  ///
  /// In zh, this message translates to:
  /// **'左下'**
  String get bottomLeft_6789;

  /// No description provided for @bottomLeft_7145.
  ///
  /// In zh, this message translates to:
  /// **'左下'**
  String get bottomLeft_7145;

  /// No description provided for @bottomRightCut_4825.
  ///
  /// In zh, this message translates to:
  /// **'右下切割'**
  String get bottomRightCut_4825;

  /// No description provided for @bottomRightTriangle_4821.
  ///
  /// In zh, this message translates to:
  /// **'右下三角'**
  String get bottomRightTriangle_4821;

  /// No description provided for @bottomRight_4567.
  ///
  /// In zh, this message translates to:
  /// **'右下'**
  String get bottomRight_4567;

  /// No description provided for @bottomRight_8256.
  ///
  /// In zh, this message translates to:
  /// **'右下'**
  String get bottomRight_8256;

  /// No description provided for @boundGroupsCount.
  ///
  /// In zh, this message translates to:
  /// **'已绑定 {boundGroupsCount} 个图例组'**
  String boundGroupsCount(Object boundGroupsCount);

  /// No description provided for @boundLayersLog_7284.
  ///
  /// In zh, this message translates to:
  /// **'绑定的图层: {boundLayerNames}'**
  String boundLayersLog_7284(Object boundLayerNames);

  /// No description provided for @boundLayersTitle.
  ///
  /// In zh, this message translates to:
  /// **'已绑定的图层 ({count})'**
  String boundLayersTitle(Object count);

  /// No description provided for @boundLegendGroupsTitle.
  ///
  /// In zh, this message translates to:
  /// **'已绑定的图例组 ({count})'**
  String boundLegendGroupsTitle(Object count);

  /// No description provided for @boxFitContain_4821.
  ///
  /// In zh, this message translates to:
  /// **'包含'**
  String get boxFitContain_4821;

  /// No description provided for @boxFitContain_4822.
  ///
  /// In zh, this message translates to:
  /// **'包含'**
  String get boxFitContain_4822;

  /// No description provided for @boxFitContain_7281.
  ///
  /// In zh, this message translates to:
  /// **'包含'**
  String get boxFitContain_7281;

  /// No description provided for @boxFitCover_4822.
  ///
  /// In zh, this message translates to:
  /// **'覆盖'**
  String get boxFitCover_4822;

  /// No description provided for @boxFitCover_4823.
  ///
  /// In zh, this message translates to:
  /// **'覆盖'**
  String get boxFitCover_4823;

  /// No description provided for @boxFitCover_7285.
  ///
  /// In zh, this message translates to:
  /// **'覆盖'**
  String get boxFitCover_7285;

  /// No description provided for @boxFitFill_4821.
  ///
  /// In zh, this message translates to:
  /// **'填充'**
  String get boxFitFill_4821;

  /// No description provided for @boxFitFill_4823.
  ///
  /// In zh, this message translates to:
  /// **'填充'**
  String get boxFitFill_4823;

  /// No description provided for @boxFitFitHeight_4825.
  ///
  /// In zh, this message translates to:
  /// **'适高'**
  String get boxFitFitHeight_4825;

  /// No description provided for @boxFitFitWidth_4824.
  ///
  /// In zh, this message translates to:
  /// **'适宽'**
  String get boxFitFitWidth_4824;

  /// No description provided for @boxFitModeSetTo.
  ///
  /// In zh, this message translates to:
  /// **'图片适应方式已设置为: {fit}'**
  String boxFitModeSetTo(Object fit);

  /// No description provided for @boxFitNone_4826.
  ///
  /// In zh, this message translates to:
  /// **'原始'**
  String get boxFitNone_4826;

  /// No description provided for @boxFitScaleDown_4827.
  ///
  /// In zh, this message translates to:
  /// **'缩小'**
  String get boxFitScaleDown_4827;

  /// No description provided for @breadcrumbPath.
  ///
  /// In zh, this message translates to:
  /// **'/ 根目录 / 文档 / 项目文件'**
  String get breadcrumbPath;

  /// No description provided for @brightnessLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'亮度'**
  String get brightnessLabel_4821;

  /// No description provided for @brightnessPercentage.
  ///
  /// In zh, this message translates to:
  /// **'亮度: {percentage}%'**
  String brightnessPercentage(Object percentage);

  /// No description provided for @brightness_4825.
  ///
  /// In zh, this message translates to:
  /// **'亮度'**
  String get brightness_4825;

  /// No description provided for @brightness_7285.
  ///
  /// In zh, this message translates to:
  /// **'亮度'**
  String get brightness_7285;

  /// No description provided for @brightness_7890.
  ///
  /// In zh, this message translates to:
  /// **'亮度'**
  String get brightness_7890;

  /// No description provided for @broadcastStatusUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'广播用户状态更新失败: {error}'**
  String broadcastStatusUpdateFailed(Object error);

  /// No description provided for @browserContextMenuDisabled_4821.
  ///
  /// In zh, this message translates to:
  /// **'• 浏览器默认的右键菜单已被禁用'**
  String get browserContextMenuDisabled_4821;

  /// No description provided for @browserStorage.
  ///
  /// In zh, this message translates to:
  /// **'浏览器存储'**
  String get browserStorage;

  /// No description provided for @brushTool_4821.
  ///
  /// In zh, this message translates to:
  /// **'画笔'**
  String get brushTool_4821;

  /// No description provided for @brushTool_5678.
  ///
  /// In zh, this message translates to:
  /// **'画笔'**
  String get brushTool_5678;

  /// No description provided for @bufferCalculationFormula_4821.
  ///
  /// In zh, this message translates to:
  /// **'💡 缓冲计算公式: {baseMultiplier} × (1 + {perspectiveStrength} × {bufferFactor} × {areaMultiplier}) = {result}'**
  String bufferCalculationFormula_4821(
    Object areaMultiplier,
    Object baseMultiplier,
    Object bufferFactor,
    Object perspectiveStrength,
    Object result,
  );

  /// No description provided for @bufferedAreaSize.
  ///
  /// In zh, this message translates to:
  /// **'   - 缓冲后区域: {width} x {height}'**
  String bufferedAreaSize(Object height, Object width);

  /// No description provided for @buildContextExtensionTip_7281.
  ///
  /// In zh, this message translates to:
  /// **'使用BuildContext扩展方法可以更快速地创建简单的浮动窗口'**
  String get buildContextExtensionTip_7281;

  /// No description provided for @buildInfo_7421.
  ///
  /// In zh, this message translates to:
  /// **'构建时信息:'**
  String get buildInfo_7421;

  /// No description provided for @buildLegendSessionManager_4821.
  ///
  /// In zh, this message translates to:
  /// **'使用图例会话管理器构建'**
  String get buildLegendSessionManager_4821;

  /// No description provided for @buildLegendStickerWidget_7421.
  ///
  /// In zh, this message translates to:
  /// **'*** 构建图例贴纸Widget ***'**
  String get buildLegendStickerWidget_7421;

  /// No description provided for @buildLegendSticker_7421.
  ///
  /// In zh, this message translates to:
  /// **'构建图例贴纸'**
  String get buildLegendSticker_7421;

  /// No description provided for @buildMarkdownStart_7283.
  ///
  /// In zh, this message translates to:
  /// **'🔧 _buildMarkdownContent: 开始构建'**
  String get buildMarkdownStart_7283;

  /// No description provided for @builderPatternDescription_3821.
  ///
  /// In zh, this message translates to:
  /// **'使用构建器模式创建复杂配置的浮动窗口'**
  String get builderPatternDescription_3821;

  /// No description provided for @builderPatternTitle_3821.
  ///
  /// In zh, this message translates to:
  /// **'构建器模式'**
  String get builderPatternTitle_3821;

  /// No description provided for @builderPatternWindow_4821.
  ///
  /// In zh, this message translates to:
  /// **'构建器模式窗口'**
  String get builderPatternWindow_4821;

  /// No description provided for @builderPattern_4821.
  ///
  /// In zh, this message translates to:
  /// **'构建器模式'**
  String get builderPattern_4821;

  /// No description provided for @buildingLegendGroupTitle.
  ///
  /// In zh, this message translates to:
  /// **'构建图例组: {name}'**
  String buildingLegendGroupTitle(Object name);

  /// No description provided for @buildingMapCanvas_7281.
  ///
  /// In zh, this message translates to:
  /// **'=== 构建地图画布 ==='**
  String get buildingMapCanvas_7281;

  /// No description provided for @building_4821.
  ///
  /// In zh, this message translates to:
  /// **'建筑'**
  String get building_4821;

  /// No description provided for @bulgarianBG_4859.
  ///
  /// In zh, this message translates to:
  /// **'保加利亚语 (保加利亚)'**
  String get bulgarianBG_4859;

  /// No description provided for @bulgarian_4858.
  ///
  /// In zh, this message translates to:
  /// **'保加利亚语'**
  String get bulgarian_4858;

  /// No description provided for @cacheCleanError_7284.
  ///
  /// In zh, this message translates to:
  /// **'清理缓存时发生错误: {e}'**
  String cacheCleanError_7284(Object e);

  /// No description provided for @cacheCleanFailed.
  ///
  /// In zh, this message translates to:
  /// **'从缓存清理路径失败: {path}, 错误: {e}'**
  String cacheCleanFailed(Object e, Object path);

  /// No description provided for @cacheCleanPath.
  ///
  /// In zh, this message translates to:
  /// **'从缓存清理路径: {legendGroupId} -> {path}'**
  String cacheCleanPath(Object legendGroupId, Object path);

  /// No description provided for @cacheCleanedPath_7281.
  ///
  /// In zh, this message translates to:
  /// **'已从缓存清理路径: {path}'**
  String cacheCleanedPath_7281(Object path);

  /// No description provided for @cacheCleanupTime.
  ///
  /// In zh, this message translates to:
  /// **'缓存清理耗时: {elapsedMilliseconds}ms'**
  String cacheCleanupTime(Object elapsedMilliseconds);

  /// No description provided for @cacheCleared_7281.
  ///
  /// In zh, this message translates to:
  /// **'缓存清理完成'**
  String get cacheCleared_7281;

  /// No description provided for @cacheLegend_4521.
  ///
  /// In zh, this message translates to:
  /// **'缓存图例'**
  String get cacheLegend_4521;

  /// No description provided for @cacheLegend_7421.
  ///
  /// In zh, this message translates to:
  /// **'缓存图例'**
  String get cacheLegend_7421;

  /// No description provided for @cachedLegendCategories.
  ///
  /// In zh, this message translates to:
  /// **'[CachedLegendsDisplay] 缓存图例分类完成：自己组 {totalOwnSelected}，其他组 {totalOtherSelected}，未选中 {totalUnselected}'**
  String cachedLegendCategories(
    Object totalOtherSelected,
    Object totalOwnSelected,
    Object totalUnselected,
  );

  /// No description provided for @cachedLegendPath_7421.
  ///
  /// In zh, this message translates to:
  /// **'已缓存图例: {legendPath}'**
  String cachedLegendPath_7421(Object legendPath);

  /// No description provided for @cachedLegendsCount_7421.
  ///
  /// In zh, this message translates to:
  /// **'当前缓存图例数量: {count}'**
  String cachedLegendsCount_7421(Object count);

  /// No description provided for @calculatedNewGlobalIndex.
  ///
  /// In zh, this message translates to:
  /// **'计算出的新全局索引: {newGlobalIndex}'**
  String calculatedNewGlobalIndex(Object newGlobalIndex);

  /// No description provided for @cameraSpeedLabel.
  ///
  /// In zh, this message translates to:
  /// **'摄像机移动速度: {speed}px/s'**
  String cameraSpeedLabel(Object speed);

  /// No description provided for @camera_4829.
  ///
  /// In zh, this message translates to:
  /// **'摄像头'**
  String get camera_4829;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @cancelActiveConfigFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'取消活跃配置失败: {e}'**
  String cancelActiveConfigFailed_7285(Object e);

  /// No description provided for @cancelActiveConfig_7421.
  ///
  /// In zh, this message translates to:
  /// **'取消当前活跃配置...'**
  String get cancelActiveConfig_7421;

  /// No description provided for @cancelActive_7281.
  ///
  /// In zh, this message translates to:
  /// **'取消活跃'**
  String get cancelActive_7281;

  /// No description provided for @cancelButton_4271.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancelButton_4271;

  /// No description provided for @cancelButton_7281.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancelButton_7281;

  /// No description provided for @cancelButton_7284.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancelButton_7284;

  /// No description provided for @cancelButton_7421.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancelButton_7421;

  /// No description provided for @cancelOperation_4821.
  ///
  /// In zh, this message translates to:
  /// **'取消操作'**
  String get cancelOperation_4821;

  /// No description provided for @cancelSelection_4271.
  ///
  /// In zh, this message translates to:
  /// **'取消选择'**
  String get cancelSelection_4271;

  /// No description provided for @cancelWebDAVDownload_5032.
  ///
  /// In zh, this message translates to:
  /// **'取消WebDAV下载'**
  String get cancelWebDAVDownload_5032;

  /// No description provided for @cancelWebDAVImport_5017.
  ///
  /// In zh, this message translates to:
  /// **'取消WebDAV导入'**
  String get cancelWebDAVImport_5017;

  /// No description provided for @cancel_4821.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel_4821;

  /// No description provided for @cancel_4832.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel_4832;

  /// No description provided for @cancel_4928.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel_4928;

  /// No description provided for @cancel_7281.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel_7281;

  /// No description provided for @cannotDeleteAuthAccountWithConfigs.
  ///
  /// In zh, this message translates to:
  /// **'无法删除认证账户，仍有 {count} 个配置在使用此账户'**
  String cannotDeleteAuthAccountWithConfigs(Object count);

  /// No description provided for @cannotDeleteDefaultVersion_4271.
  ///
  /// In zh, this message translates to:
  /// **'无法删除默认版本'**
  String get cannotDeleteDefaultVersion_4271;

  /// No description provided for @cannotDeleteDefaultVersion_4821.
  ///
  /// In zh, this message translates to:
  /// **'无法删除默认版本'**
  String get cannotDeleteDefaultVersion_4821;

  /// No description provided for @cannotDeleteDefaultVersion_7281.
  ///
  /// In zh, this message translates to:
  /// **'无法删除默认版本'**
  String get cannotDeleteDefaultVersion_7281;

  /// No description provided for @cannotGenerateMetadataPath_5012.
  ///
  /// In zh, this message translates to:
  /// **'无法生成metadata.json系统临时文件路径'**
  String get cannotGenerateMetadataPath_5012;

  /// No description provided for @cannotGenerateTempPath_4821.
  ///
  /// In zh, this message translates to:
  /// **'无法生成系统临时文件路径'**
  String get cannotGenerateTempPath_4821;

  /// No description provided for @cannotLoadLicense_4913.
  ///
  /// In zh, this message translates to:
  /// **'无法加载 LICENSE 文件: {error}'**
  String cannotLoadLicense_4913(Object error);

  /// No description provided for @cannotOperateLegend.
  ///
  /// In zh, this message translates to:
  /// **'无法操作图例：请先选择一个绑定了图例组\"{name}\"的图层'**
  String cannotOperateLegend(Object name);

  /// No description provided for @cannotReadDirectoryContent_5034.
  ///
  /// In zh, this message translates to:
  /// **'无法读取目录内容'**
  String get cannotReadDirectoryContent_5034;

  /// No description provided for @cannotReadFileContent_4986.
  ///
  /// In zh, this message translates to:
  /// **'无法读取文件内容，请确保文件存在且有读取权限'**
  String get cannotReadFileContent_4986;

  /// No description provided for @cannotReadWebDAVDirectory_5021.
  ///
  /// In zh, this message translates to:
  /// **'无法读取WebDAV目录'**
  String get cannotReadWebDAVDirectory_5021;

  /// No description provided for @cannotReleaseLock.
  ///
  /// In zh, this message translates to:
  /// **'无法释放其他用户的锁定: {elementId}'**
  String cannotReleaseLock(Object elementId);

  /// No description provided for @cannotSelectLegend_4821.
  ///
  /// In zh, this message translates to:
  /// **'无法选择图例：请先选择一个绑定了此图例组的图层'**
  String get cannotSelectLegend_4821;

  /// No description provided for @cannotViewPermissionError_4821.
  ///
  /// In zh, this message translates to:
  /// **'无法查看权限: {error}'**
  String cannotViewPermissionError_4821(Object error);

  /// No description provided for @canvasBoundaryMarginDescription.
  ///
  /// In zh, this message translates to:
  /// **'控制画布内容与容器边缘的距离：{margin}px'**
  String canvasBoundaryMarginDescription(Object margin);

  /// No description provided for @canvasCaptureError_4821.
  ///
  /// In zh, this message translates to:
  /// **'无法捕获画布区域'**
  String get canvasCaptureError_4821;

  /// No description provided for @canvasMargin_4821.
  ///
  /// In zh, this message translates to:
  /// **'画布边距'**
  String get canvasMargin_4821;

  /// No description provided for @canvasPositionDebug.
  ///
  /// In zh, this message translates to:
  /// **'画布位置: ({dx}, {dy})'**
  String canvasPositionDebug(Object dx, Object dy);

  /// No description provided for @canvasThemeAdaptationEnabled_7421.
  ///
  /// In zh, this message translates to:
  /// **'画布主题适配已启用'**
  String get canvasThemeAdaptationEnabled_7421;

  /// No description provided for @canvasThemeAdaptation_7281.
  ///
  /// In zh, this message translates to:
  /// **'画布主题适配'**
  String get canvasThemeAdaptation_7281;

  /// No description provided for @cardWithActionsTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'带操作按钮'**
  String get cardWithActionsTitle_4821;

  /// No description provided for @cardWithIconAndSubtitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'带图标和副标题'**
  String get cardWithIconAndSubtitle_4821;

  /// No description provided for @catalogTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'目录'**
  String get catalogTitle_4821;

  /// No description provided for @centerLeft_3456.
  ///
  /// In zh, this message translates to:
  /// **'左中'**
  String get centerLeft_3456;

  /// No description provided for @centerOffsetDebug.
  ///
  /// In zh, this message translates to:
  /// **'   - 中心偏移: ({dx}, {dy})'**
  String centerOffsetDebug(Object dx, Object dy);

  /// No description provided for @centerRadius_4821.
  ///
  /// In zh, this message translates to:
  /// **'中心区域半径'**
  String get centerRadius_4821;

  /// No description provided for @centerRight_1235.
  ///
  /// In zh, this message translates to:
  /// **'右中'**
  String get centerRight_1235;

  /// No description provided for @center_7890.
  ///
  /// In zh, this message translates to:
  /// **'中心'**
  String get center_7890;

  /// No description provided for @challengeDecryptedSuccess_7281.
  ///
  /// In zh, this message translates to:
  /// **'挑战解密成功'**
  String get challengeDecryptedSuccess_7281;

  /// No description provided for @challengeDecryptionFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'挑战解密失败: {e}'**
  String challengeDecryptionFailed_7421(Object e);

  /// No description provided for @challengeResponseSentResult.
  ///
  /// In zh, this message translates to:
  /// **'challengeResponseSentResult: {sendResult}'**
  String challengeResponseSentResult(Object sendResult);

  /// No description provided for @changeAvatar_7421.
  ///
  /// In zh, this message translates to:
  /// **'更改头像'**
  String get changeAvatar_7421;

  /// No description provided for @changeBackgroundImage_5421.
  ///
  /// In zh, this message translates to:
  /// **'更换背景图片'**
  String get changeBackgroundImage_5421;

  /// No description provided for @changeDisplayName_4821.
  ///
  /// In zh, this message translates to:
  /// **'修改显示名称'**
  String get changeDisplayName_4821;

  /// No description provided for @changeImage_4821.
  ///
  /// In zh, this message translates to:
  /// **'更换图片'**
  String get changeImage_4821;

  /// No description provided for @characterCount_7421.
  ///
  /// In zh, this message translates to:
  /// **'字符数: {charCount}'**
  String characterCount_7421(Object charCount);

  /// No description provided for @chartSessionInitFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'图例会话初始化失败: {e}'**
  String chartSessionInitFailed_7421(Object e);

  /// No description provided for @checkAndCorrectInputError_4821.
  ///
  /// In zh, this message translates to:
  /// **'请检查并修正参数输入错误'**
  String get checkAndCorrectInputError_4821;

  /// No description provided for @checkAndModifyPath_4821.
  ///
  /// In zh, this message translates to:
  /// **'请检查并修改文件的目标路径。您可以直接编辑路径或点击文件夹图标选择目标位置。'**
  String get checkAndModifyPath_4821;

  /// No description provided for @checkFolderEmptyFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'检查文件夹是否为空失败: {folderName}, 错误: {e}'**
  String checkFolderEmptyFailed_7421(Object e, Object folderName);

  /// No description provided for @checkLanguageAvailability_7421.
  ///
  /// In zh, this message translates to:
  /// **'检查语言 {language} 可用性: {isAvailable}'**
  String checkLanguageAvailability_7421(Object isAvailable, Object language);

  /// No description provided for @checkPlayStatus.
  ///
  /// In zh, this message translates to:
  /// **'🎵 检查播放状态 - 当前源: {currentSource}, 目标源: {targetSource}'**
  String checkPlayStatus(Object currentSource, Object targetSource);

  /// No description provided for @checkPrivateKeyFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'检查私钥存在性失败: {e}'**
  String checkPrivateKeyFailed_4821(Object e);

  /// No description provided for @checkRedoStatusFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'检查重做状态失败: {e}'**
  String checkRedoStatusFailed_4821(Object e);

  /// No description provided for @checkUndoStatusFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'检查撤销状态失败'**
  String get checkUndoStatusFailed_4821;

  /// No description provided for @checkWebDavPasswordExistenceFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'检查WebDAV密码存在性失败: {e}'**
  String checkWebDavPasswordExistenceFailed_4821(Object e);

  /// No description provided for @checkerboardPattern_4821.
  ///
  /// In zh, this message translates to:
  /// **'棋盘格'**
  String get checkerboardPattern_4821;

  /// No description provided for @checkingFileConflicts_4921.
  ///
  /// In zh, this message translates to:
  /// **'正在检查文件冲突...'**
  String get checkingFileConflicts_4921;

  /// No description provided for @chineseCharacter_4821.
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get chineseCharacter_4821;

  /// No description provided for @chineseHK_4894.
  ///
  /// In zh, this message translates to:
  /// **'中文 (香港)'**
  String get chineseHK_4894;

  /// No description provided for @chineseLanguage_5732.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get chineseLanguage_5732;

  /// No description provided for @chineseSG_4895.
  ///
  /// In zh, this message translates to:
  /// **'中文 (新加坡)'**
  String get chineseSG_4895;

  /// No description provided for @chineseSimplified_4822.
  ///
  /// In zh, this message translates to:
  /// **'中文 (简体)'**
  String get chineseSimplified_4822;

  /// No description provided for @chineseTraditional_4823.
  ///
  /// In zh, this message translates to:
  /// **'中文 (繁体)'**
  String get chineseTraditional_4823;

  /// No description provided for @chinese_4821.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get chinese_4821;

  /// No description provided for @circleTool_5689.
  ///
  /// In zh, this message translates to:
  /// **'圆形'**
  String get circleTool_5689;

  /// No description provided for @circularList_7421.
  ///
  /// In zh, this message translates to:
  /// **'循环列表'**
  String get circularList_7421;

  /// No description provided for @cleanDirectoryFailed.
  ///
  /// In zh, this message translates to:
  /// **'清理目录失败: {directoryPath}, 错误: {error}'**
  String cleanDirectoryFailed(Object directoryPath, Object error);

  /// No description provided for @cleanScriptHandler_7421.
  ///
  /// In zh, this message translates to:
  /// **'清理脚本函数处理器: {scriptId}'**
  String cleanScriptHandler_7421(Object scriptId);

  /// No description provided for @cleanTempFilesFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'🗑️ 清理临时文件失败：{e}'**
  String cleanTempFilesFailed_4821(Object e);

  /// No description provided for @cleanVersionSessionData.
  ///
  /// In zh, this message translates to:
  /// **'清理版本会话数据 [{mapTitle}/{versionId}]'**
  String cleanVersionSessionData(Object mapTitle, Object versionId);

  /// No description provided for @cleanWebDavTempFilesFailed_4721.
  ///
  /// In zh, this message translates to:
  /// **'清理WebDAV导入临时文件失败'**
  String get cleanWebDavTempFilesFailed_4721;

  /// No description provided for @cleanedOrphanedCacheItems.
  ///
  /// In zh, this message translates to:
  /// **'已清理 {count} 个孤立的图片缓存项: {items}'**
  String cleanedOrphanedCacheItems(Object count, Object items);

  /// No description provided for @cleanedPaths_7285.
  ///
  /// In zh, this message translates to:
  /// **'被清理的路径: {keysToRemove}'**
  String cleanedPaths_7285(Object keysToRemove);

  /// No description provided for @cleanedPrivateKeysCount.
  ///
  /// In zh, this message translates to:
  /// **'已清理 {count} 个私钥'**
  String cleanedPrivateKeysCount(Object count);

  /// No description provided for @cleaningExpiredLogs_7281.
  ///
  /// In zh, this message translates to:
  /// **'正在清理过期日志文件...'**
  String get cleaningExpiredLogs_7281;

  /// No description provided for @cleaningTempFiles_4923.
  ///
  /// In zh, this message translates to:
  /// **'正在清理临时文件...'**
  String get cleaningTempFiles_4923;

  /// No description provided for @cleaningTempFiles_5009.
  ///
  /// In zh, this message translates to:
  /// **'正在清理临时文件...'**
  String get cleaningTempFiles_5009;

  /// No description provided for @cleaningTempFiles_7421.
  ///
  /// In zh, this message translates to:
  /// **'正在清理临时文件...'**
  String get cleaningTempFiles_7421;

  /// No description provided for @cleanupCacheFailed_4859.
  ///
  /// In zh, this message translates to:
  /// **'清理缓存失败: {error}'**
  String cleanupCacheFailed_4859(Object error);

  /// No description provided for @cleanupCompleted.
  ///
  /// In zh, this message translates to:
  /// **'应用清理操作完成，总耗时: {elapsedMilliseconds}ms'**
  String cleanupCompleted(Object elapsedMilliseconds);

  /// No description provided for @cleanupErrorWithDuration.
  ///
  /// In zh, this message translates to:
  /// **'清理操作过程中发生错误: {e}，已耗时: {elapsedMilliseconds}ms'**
  String cleanupErrorWithDuration(Object e, Object elapsedMilliseconds);

  /// No description provided for @cleanupFailedMessage.
  ///
  /// In zh, this message translates to:
  /// **'清理文件/目录失败: {path}, 错误: {error}'**
  String cleanupFailedMessage(Object error, Object path);

  /// No description provided for @cleanupFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'清理旧数据失败: {e}'**
  String cleanupFailed_7285(Object e);

  /// No description provided for @cleanupTempFilesFailed.
  ///
  /// In zh, this message translates to:
  /// **'清理临时文件失败：{cleanupError}'**
  String cleanupTempFilesFailed(Object cleanupError);

  /// No description provided for @cleanupTempFilesFailed_4917.
  ///
  /// In zh, this message translates to:
  /// **'清理临时文件失败：{error}'**
  String cleanupTempFilesFailed_4917(Object error);

  /// No description provided for @clearAllFilters_4271.
  ///
  /// In zh, this message translates to:
  /// **'清除所有滤镜'**
  String get clearAllFilters_4271;

  /// No description provided for @clearAllNotifications_7281.
  ///
  /// In zh, this message translates to:
  /// **'清除所有通知'**
  String get clearAllNotifications_7281;

  /// No description provided for @clearAllScriptLogs_7281.
  ///
  /// In zh, this message translates to:
  /// **'清空所有脚本执行日志'**
  String get clearAllScriptLogs_7281;

  /// No description provided for @clearButton_7421.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get clearButton_7421;

  /// No description provided for @clearCurrentLocation_4821.
  ///
  /// In zh, this message translates to:
  /// **'清除当前位置'**
  String get clearCurrentLocation_4821;

  /// No description provided for @clearCustomColors_4271.
  ///
  /// In zh, this message translates to:
  /// **'清空自定义颜色'**
  String get clearCustomColors_4271;

  /// No description provided for @clearCustomTags_4271.
  ///
  /// In zh, this message translates to:
  /// **'清空自定义标签'**
  String get clearCustomTags_4271;

  /// No description provided for @clearExtensionSettingsTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'清空扩展设置'**
  String get clearExtensionSettingsTitle_4821;

  /// No description provided for @clearExtensionSettingsWarning_4821.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空所有扩展设置吗？此操作不可撤销。'**
  String get clearExtensionSettingsWarning_4821;

  /// No description provided for @clearLayerSelection_3828.
  ///
  /// In zh, this message translates to:
  /// **'清除图层/图层组选择'**
  String get clearLayerSelection_3828;

  /// No description provided for @clearLegendCacheFailed.
  ///
  /// In zh, this message translates to:
  /// **'清理图例缓存失败: {e}'**
  String clearLegendCacheFailed(Object e);

  /// No description provided for @clearLegendFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'清空图例失败: {e}'**
  String clearLegendFailed_7285(Object e);

  /// No description provided for @clearLink.
  ///
  /// In zh, this message translates to:
  /// **'清空链接'**
  String get clearLink;

  /// No description provided for @clearLogs_4271.
  ///
  /// In zh, this message translates to:
  /// **'清空日志'**
  String get clearLogs_4271;

  /// No description provided for @clearMapInfo_4821.
  ///
  /// In zh, this message translates to:
  /// **'清除地图信息'**
  String get clearMapInfo_4821;

  /// No description provided for @clearPrivateKeysFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'清理所有私钥失败: {e}'**
  String clearPrivateKeysFailed_7421(Object e);

  /// No description provided for @clearRecentColors_4271.
  ///
  /// In zh, this message translates to:
  /// **'清空最近颜色'**
  String get clearRecentColors_4271;

  /// No description provided for @clearScriptEngineDataAccessor_7281.
  ///
  /// In zh, this message translates to:
  /// **'清空脚本引擎数据访问器'**
  String get clearScriptEngineDataAccessor_7281;

  /// No description provided for @clearSelection_4821.
  ///
  /// In zh, this message translates to:
  /// **'清除选择'**
  String get clearSelection_4821;

  /// No description provided for @clearSelection_4825.
  ///
  /// In zh, this message translates to:
  /// **'清除选择'**
  String get clearSelection_4825;

  /// No description provided for @clearSessionState_7421.
  ///
  /// In zh, this message translates to:
  /// **'清理所有版本会话状态 [{arg0}]'**
  String clearSessionState_7421(Object arg0);

  /// No description provided for @clearText_4821.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get clearText_4821;

  /// No description provided for @clearTimerFailed.
  ///
  /// In zh, this message translates to:
  /// **'清空计时器失败: {e}'**
  String clearTimerFailed(Object e);

  /// No description provided for @clearTimerFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'清空计时器失败: {e}'**
  String clearTimerFailed_4821(Object e);

  /// No description provided for @clearWebDavPasswordsFailed.
  ///
  /// In zh, this message translates to:
  /// **'清理所有WebDAV密码失败: {e}'**
  String clearWebDavPasswordsFailed(Object e);

  /// No description provided for @clear_4821.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get clear_4821;

  /// No description provided for @clearedImageCache_7281.
  ///
  /// In zh, this message translates to:
  /// **'已清理所有图片缓存'**
  String get clearedImageCache_7281;

  /// No description provided for @clearedMapLegendGroups_7421.
  ///
  /// In zh, this message translates to:
  /// **'已清除地图 {mapId} 的所有图例组缩放因子设置'**
  String clearedMapLegendGroups_7421(Object mapId);

  /// No description provided for @clearedMapLegendSettings.
  ///
  /// In zh, this message translates to:
  /// **'已清除地图 {mapId} 的所有图例组智能隐藏设置'**
  String clearedMapLegendSettings(Object mapId);

  /// No description provided for @clearedSettingsWithPrefix.
  ///
  /// In zh, this message translates to:
  /// **'扩展设置: 已清除前缀为 {prefix} 的所有设置'**
  String clearedSettingsWithPrefix(Object prefix);

  /// No description provided for @clearingCache_7421.
  ///
  /// In zh, this message translates to:
  /// **'正在清理缓存...'**
  String get clearingCache_7421;

  /// No description provided for @clickAndDragWindowTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'• 点击标题栏并拖拽移动窗口'**
  String get clickAndDragWindowTitle_4821;

  /// No description provided for @clickToAddAccount_7281.
  ///
  /// In zh, this message translates to:
  /// **'点击\"添加账户\"开始使用'**
  String get clickToAddAccount_7281;

  /// No description provided for @clickToAddConfig.
  ///
  /// In zh, this message translates to:
  /// **'点击\"添加配置\"开始使用'**
  String get clickToAddConfig;

  /// No description provided for @clickToAddCustomColor_4821.
  ///
  /// In zh, this message translates to:
  /// **'点击调色盘按钮添加自定义颜色'**
  String get clickToAddCustomColor_4821;

  /// No description provided for @clickToAddText_7281.
  ///
  /// In zh, this message translates to:
  /// **'点击添加文本'**
  String get clickToAddText_7281;

  /// No description provided for @clickToEditTitleAndContent_7281.
  ///
  /// In zh, this message translates to:
  /// **'点击编辑标题和内容'**
  String get clickToEditTitleAndContent_7281;

  /// No description provided for @clickToGeneratePreview_4821.
  ///
  /// In zh, this message translates to:
  /// **'点击\"生成预览\"查看PDF效果'**
  String get clickToGeneratePreview_4821;

  /// No description provided for @clickToInputColorValue.
  ///
  /// In zh, this message translates to:
  /// **'点击输入颜色值'**
  String get clickToInputColorValue;

  /// No description provided for @clickToSelectLegend_5832.
  ///
  /// In zh, this message translates to:
  /// **'点击选择图例项'**
  String get clickToSelectLegend_5832;

  /// No description provided for @clickToStartRecording_4821.
  ///
  /// In zh, this message translates to:
  /// **'点击开始录制按键'**
  String get clickToStartRecording_4821;

  /// No description provided for @clickToUploadImage_4821.
  ///
  /// In zh, this message translates to:
  /// **'点击上传图片'**
  String get clickToUploadImage_4821;

  /// No description provided for @clientConfigCreatedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'客户端配置创建成功: {displayName} ({clientId})'**
  String clientConfigCreatedSuccessfully(Object clientId, Object displayName);

  /// No description provided for @clientConfigDeleted.
  ///
  /// In zh, this message translates to:
  /// **'客户端配置已删除: {clientId}'**
  String clientConfigDeleted(Object clientId);

  /// No description provided for @clientConfigDeletedSuccessfully_7421.
  ///
  /// In zh, this message translates to:
  /// **'客户端配置删除成功: {clientId}'**
  String clientConfigDeletedSuccessfully_7421(Object clientId);

  /// No description provided for @clientConfigFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'创建默认客户端配置失败: {e}'**
  String clientConfigFailed_7285(Object e);

  /// No description provided for @clientConfigNotFound_7281.
  ///
  /// In zh, this message translates to:
  /// **'未找到客户端配置'**
  String get clientConfigNotFound_7281;

  /// No description provided for @clientConfigNotFound_7285.
  ///
  /// In zh, this message translates to:
  /// **'客户端配置不存在: {clientId}'**
  String clientConfigNotFound_7285(Object clientId);

  /// No description provided for @clientConfigUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新客户端配置失败: {e}'**
  String clientConfigUpdateFailed(Object e);

  /// No description provided for @clientConfigUpdatedSuccessfully_7284.
  ///
  /// In zh, this message translates to:
  /// **'客户端配置更新成功: {clientId}'**
  String clientConfigUpdatedSuccessfully_7284(Object clientId);

  /// No description provided for @clientConfigUpdated_7281.
  ///
  /// In zh, this message translates to:
  /// **'客户端配置已更新: {displayName}'**
  String clientConfigUpdated_7281(Object displayName);

  /// No description provided for @clientConfigValidationFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'验证客户端配置失败: {e}'**
  String clientConfigValidationFailed_4821(Object e);

  /// No description provided for @clientCreatedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'默认客户端创建成功: {clientId}'**
  String clientCreatedSuccessfully(Object clientId);

  /// No description provided for @clientCreationFailed_5421.
  ///
  /// In zh, this message translates to:
  /// **'创建客户端失败: {e}'**
  String clientCreationFailed_5421(Object e);

  /// No description provided for @clientCreationFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'创建默认客户端失败: {e}'**
  String clientCreationFailed_7285(Object e);

  /// No description provided for @clientIdLabel.
  ///
  /// In zh, this message translates to:
  /// **'客户端ID: {clientId}'**
  String clientIdLabel(Object clientId);

  /// No description provided for @clientInfoFetchFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取客户端信息失败: {e}'**
  String clientInfoFetchFailed(Object e);

  /// No description provided for @clientInfoLoaded.
  ///
  /// In zh, this message translates to:
  /// **'客户端信息已加载: ID={clientId}, Name={displayName}'**
  String clientInfoLoaded(Object clientId, Object displayName);

  /// No description provided for @clientInitializationFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'客户端初始化失败: {e}'**
  String clientInitializationFailed_7281(Object e);

  /// No description provided for @clientInitializationSuccess_7421.
  ///
  /// In zh, this message translates to:
  /// **'客户端初始化成功: {displayName}'**
  String clientInitializationSuccess_7421(Object displayName);

  /// No description provided for @clientManagement_7281.
  ///
  /// In zh, this message translates to:
  /// **'客户端管理'**
  String get clientManagement_7281;

  /// No description provided for @clientSetSuccessfully_4821.
  ///
  /// In zh, this message translates to:
  /// **'活跃客户端设置成功: {clientId}'**
  String clientSetSuccessfully_4821(Object clientId);

  /// No description provided for @clipboardCopyImageFailed.
  ///
  /// In zh, this message translates to:
  /// **'使用 super_clipboard 复制图像失败: {e}'**
  String clipboardCopyImageFailed(Object e);

  /// No description provided for @clipboardGifReadSuccess.
  ///
  /// In zh, this message translates to:
  /// **'super_clipboard: 从剪贴板成功读取GIF图片，大小: {length} 字节'**
  String clipboardGifReadSuccess(Object length);

  /// No description provided for @clipboardImageReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'从剪贴板读取图片失败: {e}'**
  String clipboardImageReadFailed(Object e);

  /// No description provided for @clipboardImageReadSuccess_7285.
  ///
  /// In zh, this message translates to:
  /// **'从剪贴板成功读取图片'**
  String get clipboardImageReadSuccess_7285;

  /// No description provided for @clipboardImageReadSuccess_7425.
  ///
  /// In zh, this message translates to:
  /// **'从剪贴板成功读取图片，大小: {bytesLength} 字节'**
  String clipboardImageReadSuccess_7425(Object bytesLength);

  /// No description provided for @clipboardLabel_4271.
  ///
  /// In zh, this message translates to:
  /// **'剪贴板'**
  String get clipboardLabel_4271;

  /// No description provided for @clipboardNoSupportedImageFormat_4821.
  ///
  /// In zh, this message translates to:
  /// **'super_clipboard: 剪贴板中没有支持的图片格式'**
  String get clipboardNoSupportedImageFormat_4821;

  /// No description provided for @clipboardPngReadSuccess.
  ///
  /// In zh, this message translates to:
  /// **'super_clipboard: 从剪贴板成功读取PNG图片，大小: {length} 字节{isSynthesized, select, true { (合成)} other {}}'**
  String clipboardPngReadSuccess(String isSynthesized, Object length);

  /// No description provided for @clipboardReadError_4821.
  ///
  /// In zh, this message translates to:
  /// **'平台特定的剪贴板读取不支持或失败'**
  String get clipboardReadError_4821;

  /// No description provided for @clipboardReadFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'平台特定剪贴板读取实现失败: {e}'**
  String clipboardReadFailed_7285(Object e);

  /// No description provided for @clipboardUnavailableWeb_9274.
  ///
  /// In zh, this message translates to:
  /// **'Web: 系统剪贴板不可用，使用事件监听器方式'**
  String get clipboardUnavailableWeb_9274;

  /// No description provided for @clipboardUnavailable_7281.
  ///
  /// In zh, this message translates to:
  /// **'系统剪贴板不可用，尝试平台特定实现'**
  String get clipboardUnavailable_7281;

  /// No description provided for @clipboardUnavailable_7421.
  ///
  /// In zh, this message translates to:
  /// **'系统剪贴板不可用，使用平台特定实现'**
  String get clipboardUnavailable_7421;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @closeButton_4821.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get closeButton_4821;

  /// No description provided for @closeButton_5421.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get closeButton_5421;

  /// No description provided for @closeButton_7281.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get closeButton_7281;

  /// No description provided for @closeButton_7421.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get closeButton_7421;

  /// No description provided for @closeEditorTooltip_7421.
  ///
  /// In zh, this message translates to:
  /// **'关闭编辑器'**
  String get closeEditorTooltip_7421;

  /// No description provided for @closeLastElementLink.
  ///
  /// In zh, this message translates to:
  /// **'关闭组内最后元素的链接: {name}'**
  String closeLastElementLink(Object name);

  /// No description provided for @closeLayerLinkToLastPosition.
  ///
  /// In zh, this message translates to:
  /// **'关闭移动到最后位置的图层链接: {name}'**
  String closeLayerLinkToLastPosition(Object name);

  /// No description provided for @closeLegendDatabaseFailed.
  ///
  /// In zh, this message translates to:
  /// **'关闭图例数据库失败: {e}'**
  String closeLegendDatabaseFailed(Object e);

  /// No description provided for @closeNewGroupLastElementLink.
  ///
  /// In zh, this message translates to:
  /// **'关闭新的组内最后元素的链接: {name}'**
  String closeNewGroupLastElementLink(Object name);

  /// No description provided for @closeUserPrefDbFailed.
  ///
  /// In zh, this message translates to:
  /// **'关闭用户偏好数据库失败: {e}'**
  String closeUserPrefDbFailed(Object e);

  /// No description provided for @close_5031.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close_5031;

  /// No description provided for @closingDbConnection_7281.
  ///
  /// In zh, this message translates to:
  /// **'正在关闭数据库连接...'**
  String get closingDbConnection_7281;

  /// No description provided for @closingVfsSystem_7281.
  ///
  /// In zh, this message translates to:
  /// **'正在关闭VFS系统...'**
  String get closingVfsSystem_7281;

  /// No description provided for @codeExample_7281.
  ///
  /// In zh, this message translates to:
  /// **'代码示例：'**
  String get codeExample_7281;

  /// No description provided for @collabServiceInitStatus.
  ///
  /// In zh, this message translates to:
  /// **'协作服务初始化完成，WebSocket连接状态: {connectionState}'**
  String collabServiceInitStatus(Object connectionState);

  /// No description provided for @collabServiceNotInitialized_4821.
  ///
  /// In zh, this message translates to:
  /// **'协作服务未初始化，跳过enterMapEditor'**
  String get collabServiceNotInitialized_4821;

  /// No description provided for @collabServiceStatus.
  ///
  /// In zh, this message translates to:
  /// **'协作服务已初始化，WebSocket连接状态: {status}'**
  String collabServiceStatus(Object status);

  /// No description provided for @collaborationConflict_4826.
  ///
  /// In zh, this message translates to:
  /// **'协作冲突'**
  String get collaborationConflict_4826;

  /// No description provided for @collaborationConflict_7281.
  ///
  /// In zh, this message translates to:
  /// **'协作冲突'**
  String get collaborationConflict_7281;

  /// No description provided for @collaborationFeatureExample_4821.
  ///
  /// In zh, this message translates to:
  /// **'协作功能集成示例'**
  String get collaborationFeatureExample_4821;

  /// No description provided for @collaborationInitFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'初始化协作状态失败: {error}'**
  String collaborationInitFailed_7281(Object error);

  /// No description provided for @collaborationServiceCleaned_7281.
  ///
  /// In zh, this message translates to:
  /// **'协作服务已清理'**
  String get collaborationServiceCleaned_7281;

  /// No description provided for @collaborationServiceCleanupFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'协作服务清理失败: {e}'**
  String collaborationServiceCleanupFailed_7421(Object e);

  /// No description provided for @collaborationServiceInitFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'协作服务初始化失败: {e}'**
  String collaborationServiceInitFailed_4821(Object e);

  /// No description provided for @collaborationServiceNotInitialized_4821.
  ///
  /// In zh, this message translates to:
  /// **'协作服务未初始化'**
  String get collaborationServiceNotInitialized_4821;

  /// No description provided for @collaborationStateInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'协作状态初始化完成'**
  String get collaborationStateInitialized_7281;

  /// No description provided for @collaborativeMap_4271.
  ///
  /// In zh, this message translates to:
  /// **'协作地图'**
  String get collaborativeMap_4271;

  /// No description provided for @collapseNote_5421.
  ///
  /// In zh, this message translates to:
  /// **'折叠便签'**
  String get collapseNote_5421;

  /// No description provided for @collapse_4821.
  ///
  /// In zh, this message translates to:
  /// **'折叠'**
  String get collapse_4821;

  /// No description provided for @collapsedState_5421.
  ///
  /// In zh, this message translates to:
  /// **'折叠'**
  String get collapsedState_5421;

  /// No description provided for @collectionLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'集合'**
  String get collectionLabel_4821;

  /// No description provided for @collectionStatsError.
  ///
  /// In zh, this message translates to:
  /// **'获取集合统计失败: {dbName}/{collection} - {e}'**
  String collectionStatsError(Object collection, Object dbName, Object e);

  /// No description provided for @color.
  ///
  /// In zh, this message translates to:
  /// **'颜色'**
  String get color;

  /// No description provided for @colorAddedToCustom_7281.
  ///
  /// In zh, this message translates to:
  /// **'颜色已添加到自定义'**
  String get colorAddedToCustom_7281;

  /// No description provided for @colorAlreadyExists_1537.
  ///
  /// In zh, this message translates to:
  /// **'该颜色已存在于自定义颜色中'**
  String get colorAlreadyExists_1537;

  /// No description provided for @colorAlreadyExists_7281.
  ///
  /// In zh, this message translates to:
  /// **'该颜色已存在'**
  String get colorAlreadyExists_7281;

  /// No description provided for @colorFilterCleanupError_4821.
  ///
  /// In zh, this message translates to:
  /// **'在dispose中清理颜色滤镜失败: {e}'**
  String colorFilterCleanupError_4821(Object e);

  /// No description provided for @colorFilterSettingsTitle_4287.
  ///
  /// In zh, this message translates to:
  /// **'色彩滤镜设置'**
  String get colorFilterSettingsTitle_4287;

  /// No description provided for @colorFilterSettings_7421.
  ///
  /// In zh, this message translates to:
  /// **'色彩滤镜设置'**
  String get colorFilterSettings_7421;

  /// No description provided for @colorFilter_4821.
  ///
  /// In zh, this message translates to:
  /// **'色彩滤镜'**
  String get colorFilter_4821;

  /// No description provided for @colorLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'颜色'**
  String get colorLabel_4821;

  /// No description provided for @colorLabel_5421.
  ///
  /// In zh, this message translates to:
  /// **'颜色'**
  String get colorLabel_5421;

  /// No description provided for @colorPickerTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'选择颜色'**
  String get colorPickerTitle_4821;

  /// No description provided for @colorValueHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'例如: FF0000, #FF0000, red'**
  String get colorValueHint_4821;

  /// No description provided for @colorValueLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'颜色值'**
  String get colorValueLabel_4821;

  /// No description provided for @colorWithHashTag_7281.
  ///
  /// In zh, this message translates to:
  /// **'带#号: #FF0000'**
  String get colorWithHashTag_7281;

  /// No description provided for @colorWithHex_7421.
  ///
  /// In zh, this message translates to:
  /// **'颜色:{colorHex}'**
  String colorWithHex_7421(Object colorHex);

  /// No description provided for @commonLineWidth_4521.
  ///
  /// In zh, this message translates to:
  /// **'常用线条宽度'**
  String get commonLineWidth_4521;

  /// No description provided for @commonLineWidth_4821.
  ///
  /// In zh, this message translates to:
  /// **'常用线条宽度'**
  String get commonLineWidth_4821;

  /// No description provided for @commonStrokeWidthAdded.
  ///
  /// In zh, this message translates to:
  /// **'常用线条宽度已添加: {strokeWidth}px'**
  String commonStrokeWidthAdded(Object strokeWidth);

  /// No description provided for @compactMode.
  ///
  /// In zh, this message translates to:
  /// **'紧凑模式'**
  String get compactMode;

  /// No description provided for @compactMode_7281.
  ///
  /// In zh, this message translates to:
  /// **'紧凑模式'**
  String get compactMode_7281;

  /// No description provided for @compareVersionPathDiff.
  ///
  /// In zh, this message translates to:
  /// **'比较版本路径差异: {previousVersionId} vs {versionId}'**
  String compareVersionPathDiff(Object previousVersionId, Object versionId);

  /// No description provided for @compareVersionPathDiff_4827.
  ///
  /// In zh, this message translates to:
  /// **'开始比较版本路径差异: {fromVersionId} -> {toVersionId}'**
  String compareVersionPathDiff_4827(Object fromVersionId, Object toVersionId);

  /// No description provided for @completedTag_3456.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get completedTag_3456;

  /// No description provided for @completedTag_9012.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get completedTag_9012;

  /// No description provided for @completed_9012.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get completed_9012;

  /// No description provided for @compressingFiles_5006.
  ///
  /// In zh, this message translates to:
  /// **'正在压缩文件...'**
  String get compressingFiles_5006;

  /// No description provided for @compressionDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'压缩下载失败: {e}'**
  String compressionDownloadFailed(Object e);

  /// No description provided for @compressionDownloadFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'压缩下载失败: {e}'**
  String compressionDownloadFailed_4821(Object e);

  /// No description provided for @compressionFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'压缩失败'**
  String get compressionFailed_7281;

  /// No description provided for @configAdded_17.
  ///
  /// In zh, this message translates to:
  /// **'配置已添加'**
  String get configAdded_17;

  /// No description provided for @configCheckFailed_7425.
  ///
  /// In zh, this message translates to:
  /// **'检查配置存在性失败: {e}'**
  String configCheckFailed_7425(Object e);

  /// No description provided for @configDeletedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'配置删除成功: {configId}'**
  String configDeletedSuccessfully(Object configId);

  /// No description provided for @configDirCreatedOrExists_7281.
  ///
  /// In zh, this message translates to:
  /// **'配置目录已创建或已存在'**
  String get configDirCreatedOrExists_7281;

  /// No description provided for @configDirCreationError_4821.
  ///
  /// In zh, this message translates to:
  /// **'配置目录创建: {e}'**
  String configDirCreationError_4821(Object e);

  /// No description provided for @configDisabled_4821.
  ///
  /// In zh, this message translates to:
  /// **'配置已禁用'**
  String get configDisabled_4821;

  /// No description provided for @configEditor.
  ///
  /// In zh, this message translates to:
  /// **'配置编辑器'**
  String get configEditor;

  /// No description provided for @configEditorDisplayName_4821.
  ///
  /// In zh, this message translates to:
  /// **'配置编辑器'**
  String get configEditorDisplayName_4821;

  /// No description provided for @configEnabled_4822.
  ///
  /// In zh, this message translates to:
  /// **'配置已启用'**
  String get configEnabled_4822;

  /// No description provided for @configFileCreated.
  ///
  /// In zh, this message translates to:
  /// **'配置文件\"{name}\"已创建'**
  String configFileCreated(Object name);

  /// No description provided for @configImportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'配置导入成功: {name} ({importedConfigId})'**
  String configImportSuccess(Object importedConfigId, Object name);

  /// No description provided for @configInitFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'初始化配置管理系统失败: {e}'**
  String configInitFailed_7285(Object e);

  /// No description provided for @configListLoaded.
  ///
  /// In zh, this message translates to:
  /// **'配置列表已加载，共 {count} 个配置'**
  String configListLoaded(Object count);

  /// No description provided for @configListUpdated.
  ///
  /// In zh, this message translates to:
  /// **'配置列表已更新，共 {count} 个配置'**
  String configListUpdated(Object count);

  /// No description provided for @configLoadedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'配置加载并应用成功: {configId}'**
  String configLoadedSuccessfully(Object configId);

  /// No description provided for @configNotFoundOrLoadFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'配置不存在或加载失败'**
  String get configNotFoundOrLoadFailed_4821;

  /// No description provided for @configNotFound_4821.
  ///
  /// In zh, this message translates to:
  /// **'配置不存在'**
  String get configNotFound_4821;

  /// No description provided for @configSavedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'配置保存成功: {name} ({configId})'**
  String configSavedSuccessfully(Object configId, Object name);

  /// No description provided for @configUpdateSuccess.
  ///
  /// In zh, this message translates to:
  /// **'配置更新成功: {name} ({configId})'**
  String configUpdateSuccess(Object configId, Object name);

  /// No description provided for @configUpdated.
  ///
  /// In zh, this message translates to:
  /// **'配置已更新'**
  String get configUpdated;

  /// No description provided for @configUpdated_42.
  ///
  /// In zh, this message translates to:
  /// **'配置已更新'**
  String get configUpdated_42;

  /// No description provided for @configValidationFailedPrivateKeyMissing.
  ///
  /// In zh, this message translates to:
  /// **'配置验证失败: 私钥不存在 {privateKeyId}'**
  String configValidationFailedPrivateKeyMissing(Object privateKeyId);

  /// No description provided for @configValidationFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'配置验证失败: 公钥格式错误 {error}'**
  String configValidationFailedWithError(Object error);

  /// No description provided for @configValidationFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'配置验证失败: {e}'**
  String configValidationFailed_7281(Object e);

  /// No description provided for @configValidationResult.
  ///
  /// In zh, this message translates to:
  /// **'配置验证结果: {result}'**
  String configValidationResult(Object result);

  /// No description provided for @configurationCopiedToClipboard_4821.
  ///
  /// In zh, this message translates to:
  /// **'配置已复制到剪贴板'**
  String get configurationCopiedToClipboard_4821;

  /// No description provided for @configurationDeletedSuccessfully_7281.
  ///
  /// In zh, this message translates to:
  /// **'配置删除成功'**
  String get configurationDeletedSuccessfully_7281;

  /// No description provided for @configurationDeletedSuccessfully_7421.
  ///
  /// In zh, this message translates to:
  /// **'配置删除成功'**
  String get configurationDeletedSuccessfully_7421;

  /// No description provided for @configurationDeleted_4821.
  ///
  /// In zh, this message translates to:
  /// **'配置已删除'**
  String get configurationDeleted_4821;

  /// No description provided for @configurationDescription_4521.
  ///
  /// In zh, this message translates to:
  /// **'配置描述'**
  String get configurationDescription_4521;

  /// No description provided for @configurationImportSuccess_7281.
  ///
  /// In zh, this message translates to:
  /// **'配置导入成功'**
  String get configurationImportSuccess_7281;

  /// No description provided for @configurationInfo_7284.
  ///
  /// In zh, this message translates to:
  /// **'=== 配置信息 ==='**
  String get configurationInfo_7284;

  /// No description provided for @configurationLoadedSuccessfully_4821.
  ///
  /// In zh, this message translates to:
  /// **'配置加载成功'**
  String get configurationLoadedSuccessfully_4821;

  /// No description provided for @configurationManagement_7421.
  ///
  /// In zh, this message translates to:
  /// **'配置管理'**
  String get configurationManagement_7421;

  /// No description provided for @configurationName_4821.
  ///
  /// In zh, this message translates to:
  /// **'配置名称'**
  String get configurationName_4821;

  /// No description provided for @configurationNotFound_7281.
  ///
  /// In zh, this message translates to:
  /// **'配置未找到'**
  String get configurationNotFound_7281;

  /// No description provided for @configurationSavedSuccessfully_4821.
  ///
  /// In zh, this message translates to:
  /// **'配置保存成功'**
  String get configurationSavedSuccessfully_4821;

  /// No description provided for @configurationsCount_7421.
  ///
  /// In zh, this message translates to:
  /// **'个配置'**
  String get configurationsCount_7421;

  /// No description provided for @configureAppSettings_7285.
  ///
  /// In zh, this message translates to:
  /// **'配置应用程序设置和首选项'**
  String get configureAppSettings_7285;

  /// No description provided for @configurePreferences_5732.
  ///
  /// In zh, this message translates to:
  /// **'配置您的首选项'**
  String get configurePreferences_5732;

  /// No description provided for @confirmAndProcess_7281.
  ///
  /// In zh, this message translates to:
  /// **'确认并处理'**
  String get confirmAndProcess_7281;

  /// No description provided for @confirmButton_4821.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirmButton_4821;

  /// No description provided for @confirmButton_7281.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirmButton_7281;

  /// No description provided for @confirmClearAllTags_7281.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空所有自定义标签吗？'**
  String get confirmClearAllTags_7281;

  /// No description provided for @confirmClearCustomColors_7421.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空所有自定义颜色吗？'**
  String get confirmClearCustomColors_7421;

  /// No description provided for @confirmClearRecentColors_4821.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空所有最近使用的颜色吗？'**
  String get confirmClearRecentColors_4821;

  /// No description provided for @confirmDeleteAccount_7421.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除认证账户\"{accountDisplayName}\"吗？此操作无法撤销。'**
  String confirmDeleteAccount_7421(Object accountDisplayName);

  /// No description provided for @confirmDeleteConfig.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除配置 \"{displayName}\" 吗？'**
  String confirmDeleteConfig(Object displayName);

  /// No description provided for @confirmDeleteElement_4821.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这个{type}元素吗？'**
  String confirmDeleteElement_4821(Object type);

  /// No description provided for @confirmDeleteFolder_4837.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除此文件夹吗？'**
  String get confirmDeleteFolder_4837;

  /// No description provided for @confirmDeleteFolder_7281.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除文件夹 \"{folderName}\" 吗？\n\n注意：只能删除空文件夹。'**
  String confirmDeleteFolder_7281(Object folderName);

  /// No description provided for @confirmDeleteItem_7421.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除\"{item}\"吗？'**
  String confirmDeleteItem_7421(Object item);

  /// No description provided for @confirmDeleteLayer_7421.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除图层 \"{name}\" 吗？此操作不可撤销。'**
  String confirmDeleteLayer_7421(Object name);

  /// No description provided for @confirmDeleteLegend.
  ///
  /// In zh, this message translates to:
  /// **'确认删除图例 \"{title}\" 吗？'**
  String confirmDeleteLegend(Object title);

  /// No description provided for @confirmDeleteLegendGroup_7281.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除图例组 \"{name}\" 吗？此操作不可撤销。'**
  String confirmDeleteLegendGroup_7281(Object name);

  /// No description provided for @confirmDeleteLegend_4821.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除此图例吗？此操作不可撤销。'**
  String get confirmDeleteLegend_4821;

  /// No description provided for @confirmDeleteMap.
  ///
  /// In zh, this message translates to:
  /// **'确认删除地图 \"{title}\"？'**
  String confirmDeleteMap(Object title);

  /// No description provided for @confirmDeleteMessage_4821.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除选中的 {count} 个项目吗？此操作不可撤销。'**
  String confirmDeleteMessage_4821(Object count);

  /// No description provided for @confirmDeleteNote.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除便签 \"{title}\" 吗？此操作不可撤销。'**
  String confirmDeleteNote(Object title);

  /// No description provided for @confirmDeleteScript_7421.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除脚本 \"{name}\" 吗？'**
  String confirmDeleteScript_7421(Object name);

  /// No description provided for @confirmDeleteTimer_7421.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这个计时器吗？'**
  String get confirmDeleteTimer_7421;

  /// No description provided for @confirmDeleteTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDeleteTitle_4821;

  /// No description provided for @confirmDeleteVersion.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除版本 \"{versionId}\" 吗？此操作不可撤销。'**
  String confirmDeleteVersion(Object versionId);

  /// No description provided for @confirmDelete_7281.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDelete_7281;

  /// No description provided for @confirmDeletionMessage_4821.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除选中的 {count} 个项目吗？此操作不可撤销。'**
  String confirmDeletionMessage_4821(Object count);

  /// No description provided for @confirmDeletionTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDeletionTitle_4821;

  /// No description provided for @confirmExit_7284.
  ///
  /// In zh, this message translates to:
  /// **'仍要退出'**
  String get confirmExit_7284;

  /// No description provided for @confirmLoadConfig_7421.
  ///
  /// In zh, this message translates to:
  /// **'确定要加载配置 \"{name}\" 吗？\n\n这将覆盖当前的所有设置（用户信息除外）。'**
  String confirmLoadConfig_7421(Object name);

  /// No description provided for @confirmRemoveAvatar_7421.
  ///
  /// In zh, this message translates to:
  /// **'确定要移除当前头像吗？'**
  String get confirmRemoveAvatar_7421;

  /// No description provided for @confirmResetLayoutSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'确定要将布局设置重置为默认值吗？此操作不可撤销。'**
  String get confirmResetLayoutSettings_4821;

  /// No description provided for @confirmResetSettings.
  ///
  /// In zh, this message translates to:
  /// **'确定要将所有设置重置为默认值吗？此操作不可撤销。'**
  String get confirmResetSettings;

  /// No description provided for @confirmResetTtsSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'确定要重置TTS设置为默认值吗？'**
  String get confirmResetTtsSettings_4821;

  /// No description provided for @confirmResetWindowSize_4821.
  ///
  /// In zh, this message translates to:
  /// **'确定要将窗口大小重置为默认值吗？'**
  String get confirmResetWindowSize_4821;

  /// No description provided for @confirm_4821.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm_4821;

  /// No description provided for @confirm_4843.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm_4843;

  /// No description provided for @conflictCount.
  ///
  /// In zh, this message translates to:
  /// **'{count}个冲突'**
  String conflictCount(Object count);

  /// No description provided for @conflictCreated_7425.
  ///
  /// In zh, this message translates to:
  /// **'冲突已创建'**
  String get conflictCreated_7425;

  /// No description provided for @conflictResolved_7421.
  ///
  /// In zh, this message translates to:
  /// **'冲突已解决'**
  String get conflictResolved_7421;

  /// No description provided for @connect_4821.
  ///
  /// In zh, this message translates to:
  /// **'连接'**
  String get connect_4821;

  /// No description provided for @connected_3632.
  ///
  /// In zh, this message translates to:
  /// **'已连接'**
  String get connected_3632;

  /// No description provided for @connected_4821.
  ///
  /// In zh, this message translates to:
  /// **'已连接'**
  String get connected_4821;

  /// No description provided for @connected_7154.
  ///
  /// In zh, this message translates to:
  /// **'已连接'**
  String get connected_7154;

  /// No description provided for @connectingToTarget.
  ///
  /// In zh, this message translates to:
  /// **'开始连接到: {displayName} ({clientId})'**
  String connectingToTarget(Object clientId, Object displayName);

  /// No description provided for @connectingToWebSocketServer.
  ///
  /// In zh, this message translates to:
  /// **'开始连接到 WebSocket 服务器: {host}:{port}'**
  String connectingToWebSocketServer(Object host, Object port);

  /// No description provided for @connectingWebDAV_5018.
  ///
  /// In zh, this message translates to:
  /// **'正在连接WebDAV...'**
  String get connectingWebDAV_5018;

  /// No description provided for @connecting_5723.
  ///
  /// In zh, this message translates to:
  /// **'连接中'**
  String get connecting_5723;

  /// No description provided for @connecting_5732.
  ///
  /// In zh, this message translates to:
  /// **'连接中'**
  String get connecting_5732;

  /// No description provided for @connectionConfig_7281.
  ///
  /// In zh, this message translates to:
  /// **'连接配置'**
  String get connectionConfig_7281;

  /// No description provided for @connectionDisconnected_4821.
  ///
  /// In zh, this message translates to:
  /// **'连接已断开'**
  String get connectionDisconnected_4821;

  /// No description provided for @connectionError_5421.
  ///
  /// In zh, this message translates to:
  /// **'连接错误: {e}'**
  String connectionError_5421(Object e);

  /// No description provided for @connectionFailedWithError_7281.
  ///
  /// In zh, this message translates to:
  /// **'连接失败：{error}'**
  String connectionFailedWithError_7281(Object error);

  /// No description provided for @connectionFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'连接失败'**
  String get connectionFailed_4821;

  /// No description provided for @connectionFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'连接失败: {error}'**
  String connectionFailed_7281(Object error);

  /// No description provided for @connectionFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService 断开连接失败: {e}'**
  String connectionFailed_7285(Object e);

  /// No description provided for @connectionFailed_9372.
  ///
  /// In zh, this message translates to:
  /// **'连接失败'**
  String get connectionFailed_9372;

  /// No description provided for @connectionInProgress_4821.
  ///
  /// In zh, this message translates to:
  /// **'连接正在进行中，忽略重复连接请求'**
  String get connectionInProgress_4821;

  /// No description provided for @connectionStateChanged_7281.
  ///
  /// In zh, this message translates to:
  /// **'连接状态变更: {state}'**
  String connectionStateChanged_7281(Object state);

  /// No description provided for @connectionStatus_4821.
  ///
  /// In zh, this message translates to:
  /// **'连接状态'**
  String get connectionStatus_4821;

  /// No description provided for @connectionSuccess_4821.
  ///
  /// In zh, this message translates to:
  /// **'连接成功'**
  String get connectionSuccess_4821;

  /// No description provided for @connectionTimeoutError_4821.
  ///
  /// In zh, this message translates to:
  /// **'连接超时'**
  String get connectionTimeoutError_4821;

  /// No description provided for @connectionToPlayerComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎵 连接到现有播放器完成:'**
  String get connectionToPlayerComplete_7281;

  /// No description provided for @consistentDesktopExperience_4821.
  ///
  /// In zh, this message translates to:
  /// **'• 与桌面平台保持一致的交互体验'**
  String get consistentDesktopExperience_4821;

  /// No description provided for @contentLabel_4521.
  ///
  /// In zh, this message translates to:
  /// **'内容'**
  String get contentLabel_4521;

  /// No description provided for @contrastPercentage.
  ///
  /// In zh, this message translates to:
  /// **'对比度: {percentage}%'**
  String contrastPercentage(Object percentage);

  /// No description provided for @contrast_1235.
  ///
  /// In zh, this message translates to:
  /// **'对比度'**
  String get contrast_1235;

  /// No description provided for @contrast_4826.
  ///
  /// In zh, this message translates to:
  /// **'对比度'**
  String get contrast_4826;

  /// No description provided for @controlPanel_4821.
  ///
  /// In zh, this message translates to:
  /// **'操作面板'**
  String get controlPanel_4821;

  /// No description provided for @convertedCanvasPosition_7281.
  ///
  /// In zh, this message translates to:
  /// **'转换后的画布坐标: {canvasPosition}'**
  String convertedCanvasPosition_7281(Object canvasPosition);

  /// No description provided for @coordinateConversion.
  ///
  /// In zh, this message translates to:
  /// **'坐标转换: 本地({localPosition}) -> 画布({clampedPosition})'**
  String coordinateConversion(Object clampedPosition, Object localPosition);

  /// No description provided for @coordinateConversionFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'坐标转换失败: {e}，使用原始坐标'**
  String coordinateConversionFailed_7421(Object e);

  /// No description provided for @copiedFrom_5729.
  ///
  /// In zh, this message translates to:
  /// **' (从 {sourceVersionId} 复制)'**
  String copiedFrom_5729(Object sourceVersionId);

  /// No description provided for @copiedItemsCount.
  ///
  /// In zh, this message translates to:
  /// **'已复制 {count} 个项目'**
  String copiedItemsCount(Object count);

  /// No description provided for @copiedMessage_7421.
  ///
  /// In zh, this message translates to:
  /// **'已复制'**
  String get copiedMessage_7421;

  /// No description provided for @copiedMessage_7532.
  ///
  /// In zh, this message translates to:
  /// **'已复制'**
  String get copiedMessage_7532;

  /// No description provided for @copiedProjectLink.
  ///
  /// In zh, this message translates to:
  /// **'已复制项目 {index} 链接'**
  String copiedProjectLink(Object index);

  /// No description provided for @copiedToClipboard_4821.
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get copiedToClipboard_4821;

  /// No description provided for @copyAllContent_7281.
  ///
  /// In zh, this message translates to:
  /// **'复制所有内容'**
  String get copyAllContent_7281;

  /// No description provided for @copyAudioLink_4821.
  ///
  /// In zh, this message translates to:
  /// **'复制音频链接: {vfsPath}'**
  String copyAudioLink_4821(Object vfsPath);

  /// No description provided for @copyDataFromVersion.
  ///
  /// In zh, this message translates to:
  /// **'从版本 {sourceVersion} 复制数据到版本 {version}'**
  String copyDataFromVersion(Object sourceVersion, Object version);

  /// No description provided for @copyDirectoryFailed.
  ///
  /// In zh, this message translates to:
  /// **'复制目录失败 [{sourcePath} -> {targetPath}]: {error}'**
  String copyDirectoryFailed(
    Object error,
    Object sourcePath,
    Object targetPath,
  );

  /// No description provided for @copyFeatureComingSoon_7281.
  ///
  /// In zh, this message translates to:
  /// **'复制功能将在下个版本中实现'**
  String get copyFeatureComingSoon_7281;

  /// No description provided for @copyInfo_4821.
  ///
  /// In zh, this message translates to:
  /// **'复制信息'**
  String get copyInfo_4821;

  /// No description provided for @copyLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get copyLabel_4821;

  /// No description provided for @copyLayer_4821.
  ///
  /// In zh, this message translates to:
  /// **'复制图层'**
  String get copyLayer_4821;

  /// No description provided for @copyLink_1234.
  ///
  /// In zh, this message translates to:
  /// **'复制链接'**
  String get copyLink_1234;

  /// No description provided for @copyLink_4271.
  ///
  /// In zh, this message translates to:
  /// **'复制链接'**
  String get copyLink_4271;

  /// No description provided for @copyLink_4821.
  ///
  /// In zh, this message translates to:
  /// **'复制链接'**
  String get copyLink_4821;

  /// No description provided for @copyMapSelectionFailed_4829.
  ///
  /// In zh, this message translates to:
  /// **'复制地图选中区域失败: {e}'**
  String copyMapSelectionFailed_4829(Object e);

  /// No description provided for @copyMarkdownContent_7281.
  ///
  /// In zh, this message translates to:
  /// **'复制Markdown内容'**
  String get copyMarkdownContent_7281;

  /// No description provided for @copyNote_7281.
  ///
  /// In zh, this message translates to:
  /// **'复制便签'**
  String get copyNote_7281;

  /// No description provided for @copyPathSelectionStatus.
  ///
  /// In zh, this message translates to:
  /// **'从版本 {sourceVersionId} 复制路径选择状态到 {versionId}'**
  String copyPathSelectionStatus(Object sourceVersionId, Object versionId);

  /// No description provided for @copySelectedItems_4821.
  ///
  /// In zh, this message translates to:
  /// **'复制选中项'**
  String get copySelectedItems_4821;

  /// No description provided for @copySelected_4821.
  ///
  /// In zh, this message translates to:
  /// **'复制选中项'**
  String get copySelected_4821;

  /// No description provided for @copySuffix_3632.
  ///
  /// In zh, this message translates to:
  /// **'(副本)'**
  String get copySuffix_3632;

  /// No description provided for @copySuffix_4821.
  ///
  /// In zh, this message translates to:
  /// **'(副本)'**
  String get copySuffix_4821;

  /// No description provided for @copySuffix_7281.
  ///
  /// In zh, this message translates to:
  /// **'(副本)'**
  String get copySuffix_7281;

  /// No description provided for @copySuffix_7285.
  ///
  /// In zh, this message translates to:
  /// **' (副本)'**
  String get copySuffix_7285;

  /// No description provided for @copySuffix_7421.
  ///
  /// In zh, this message translates to:
  /// **'(副本)'**
  String get copySuffix_7421;

  /// No description provided for @copyText_4821.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get copyText_4821;

  /// No description provided for @copyToClipboardFailed.
  ///
  /// In zh, this message translates to:
  /// **'复制到剪贴板失败: {e}'**
  String copyToClipboardFailed(Object e);

  /// No description provided for @copyToClipboardFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'复制到剪贴板失败'**
  String get copyToClipboardFailed_4821;

  /// No description provided for @copyVersionDataFailed.
  ///
  /// In zh, this message translates to:
  /// **'复制版本数据失败 [{mapTitle}:{sourceVersion}->{targetVersion}]: {e}'**
  String copyVersionDataFailed(
    Object e,
    Object mapTitle,
    Object sourceVersion,
    Object targetVersion,
  );

  /// No description provided for @copyVersionSession.
  ///
  /// In zh, this message translates to:
  /// **'复制版本会话 [{mapTitle}]: {sourceVersionId} -> {newVersionId}'**
  String copyVersionSession(
    Object mapTitle,
    Object newVersionId,
    Object sourceVersionId,
  );

  /// No description provided for @copyVideoLink.
  ///
  /// In zh, this message translates to:
  /// **'复制视频链接: {vfsPath}'**
  String copyVideoLink(Object vfsPath);

  /// No description provided for @copyVideoLink_5421.
  ///
  /// In zh, this message translates to:
  /// **'复制视频链接: {vfsPath}'**
  String copyVideoLink_5421(Object vfsPath);

  /// No description provided for @copyWithNumber_3632.
  ///
  /// In zh, this message translates to:
  /// **'副本'**
  String get copyWithNumber_3632;

  /// No description provided for @copyWithTimestamp_3632.
  ///
  /// In zh, this message translates to:
  /// **'副本'**
  String get copyWithTimestamp_3632;

  /// No description provided for @copyWithTimestamp_8254.
  ///
  /// In zh, this message translates to:
  /// **'副本'**
  String get copyWithTimestamp_8254;

  /// No description provided for @copy_3832.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get copy_3832;

  /// No description provided for @copy_4821.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get copy_4821;

  /// No description provided for @copyingFileProgress_5004.
  ///
  /// In zh, this message translates to:
  /// **'正在复制文件'**
  String get copyingFileProgress_5004;

  /// No description provided for @copyingFiles_4922.
  ///
  /// In zh, this message translates to:
  /// **'正在复制文件到目标位置... ({processed}/{total})'**
  String copyingFiles_4922(Object processed, Object total);

  /// No description provided for @countUnit_7281.
  ///
  /// In zh, this message translates to:
  /// **'个'**
  String get countUnit_7281;

  /// No description provided for @countdownDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'从设定时间倒数到零'**
  String get countdownDescription_4821;

  /// No description provided for @countdownMode_4821.
  ///
  /// In zh, this message translates to:
  /// **'倒计时'**
  String get countdownMode_4821;

  /// No description provided for @coverSizeInfo_4821.
  ///
  /// In zh, this message translates to:
  /// **'封面: {size}'**
  String coverSizeInfo_4821(Object size);

  /// No description provided for @coverSizeLabel_7421.
  ///
  /// In zh, this message translates to:
  /// **'封面大小: {size}KB'**
  String coverSizeLabel_7421(Object size);

  /// No description provided for @coverText_4821.
  ///
  /// In zh, this message translates to:
  /// **'覆盖'**
  String get coverText_4821;

  /// No description provided for @coverText_7281.
  ///
  /// In zh, this message translates to:
  /// **'覆盖'**
  String get coverText_7281;

  /// No description provided for @cover_4827.
  ///
  /// In zh, this message translates to:
  /// **'掩体'**
  String get cover_4827;

  /// No description provided for @createButton_7281.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get createButton_7281;

  /// No description provided for @createButton_7421.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get createButton_7421;

  /// No description provided for @createClientWithWebApiKey.
  ///
  /// In zh, this message translates to:
  /// **'使用 Web API Key 创建客户端: {displayName}'**
  String createClientWithWebApiKey(Object displayName);

  /// No description provided for @createDefaultClient_7281.
  ///
  /// In zh, this message translates to:
  /// **'创建默认客户端: {displayName}'**
  String createDefaultClient_7281(Object displayName);

  /// No description provided for @createEmptyVersionDirectory.
  ///
  /// In zh, this message translates to:
  /// **'创建空版本目录: {version}'**
  String createEmptyVersionDirectory(Object version);

  /// No description provided for @createFirstConnectionHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'点击\"新建\"按钮创建第一个连接配置'**
  String get createFirstConnectionHint_4821;

  /// No description provided for @createFolderFailed.
  ///
  /// In zh, this message translates to:
  /// **'创建文件夹失败: {e}'**
  String createFolderFailed(Object e);

  /// No description provided for @createFolderFailed_4835.
  ///
  /// In zh, this message translates to:
  /// **'创建文件夹失败: {error}'**
  String createFolderFailed_4835(Object error);

  /// No description provided for @createFolderFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'创建文件夹失败: {e}'**
  String createFolderFailed_7285(Object e);

  /// No description provided for @createFolderTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'新建文件夹'**
  String get createFolderTitle_4821;

  /// No description provided for @createFolderTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'创建文件夹'**
  String get createFolderTooltip_7281;

  /// No description provided for @createFolder_4271.
  ///
  /// In zh, this message translates to:
  /// **'创建文件夹'**
  String get createFolder_4271;

  /// No description provided for @createFolder_4821.
  ///
  /// In zh, this message translates to:
  /// **'新建文件夹'**
  String get createFolder_4821;

  /// No description provided for @createFolder_4825.
  ///
  /// In zh, this message translates to:
  /// **'创建文件夹'**
  String get createFolder_4825;

  /// No description provided for @createGroup_4821.
  ///
  /// In zh, this message translates to:
  /// **'创建组'**
  String get createGroup_4821;

  /// No description provided for @createLayerGroup_7532.
  ///
  /// In zh, this message translates to:
  /// **'创建图层组'**
  String get createLayerGroup_7532;

  /// No description provided for @createNewClientConfig_7281.
  ///
  /// In zh, this message translates to:
  /// **'创建新的客户端配置'**
  String get createNewClientConfig_7281;

  /// No description provided for @createNewFile_7281.
  ///
  /// In zh, this message translates to:
  /// **'新建文件'**
  String get createNewFile_7281;

  /// No description provided for @createNewFolder_4821.
  ///
  /// In zh, this message translates to:
  /// **'新建文件夹'**
  String get createNewFolder_4821;

  /// No description provided for @createNewLayer_4821.
  ///
  /// In zh, this message translates to:
  /// **'新建图层'**
  String get createNewLayer_4821;

  /// No description provided for @createNewProfile_4271.
  ///
  /// In zh, this message translates to:
  /// **'创建新配置文件'**
  String get createNewProfile_4271;

  /// No description provided for @createNewProject_7281.
  ///
  /// In zh, this message translates to:
  /// **'新建项目'**
  String get createNewProject_7281;

  /// No description provided for @createNewTimer_4271.
  ///
  /// In zh, this message translates to:
  /// **'创建新计时器'**
  String get createNewTimer_4271;

  /// No description provided for @createNewTimer_4821.
  ///
  /// In zh, this message translates to:
  /// **'创建新计时器'**
  String get createNewTimer_4821;

  /// No description provided for @createNewVersion_3869.
  ///
  /// In zh, this message translates to:
  /// **'新增版本'**
  String get createNewVersion_3869;

  /// No description provided for @createNewVersion_4271.
  ///
  /// In zh, this message translates to:
  /// **'创建新版本'**
  String get createNewVersion_4271;

  /// No description provided for @createNewVersion_4821.
  ///
  /// In zh, this message translates to:
  /// **'创建新版本'**
  String get createNewVersion_4821;

  /// No description provided for @createNewVersion_4824.
  ///
  /// In zh, this message translates to:
  /// **'创建新版本'**
  String get createNewVersion_4824;

  /// No description provided for @createNoteImageSelectionElement_7421.
  ///
  /// In zh, this message translates to:
  /// **'创建便签图片选区元素: imageData={imageBufferData}'**
  String createNoteImageSelectionElement_7421(Object imageBufferData);

  /// No description provided for @createResponsiveScript_4821.
  ///
  /// In zh, this message translates to:
  /// **'新建响应式脚本'**
  String get createResponsiveScript_4821;

  /// No description provided for @createSampleDataFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'创建示例数据失败'**
  String get createSampleDataFailed_7281;

  /// No description provided for @createSampleData_7421.
  ///
  /// In zh, this message translates to:
  /// **'WebDatabaseImporter: 创建示例数据'**
  String get createSampleData_7421;

  /// No description provided for @createScript_4271.
  ///
  /// In zh, this message translates to:
  /// **'创建脚本'**
  String get createScript_4271;

  /// No description provided for @createScript_4821.
  ///
  /// In zh, this message translates to:
  /// **'创建脚本'**
  String get createScript_4821;

  /// No description provided for @createTempDir_7425.
  ///
  /// In zh, this message translates to:
  /// **'创建应用临时目录'**
  String get createTempDir_7425;

  /// No description provided for @createTextElementLog.
  ///
  /// In zh, this message translates to:
  /// **'创建文本元素: \"{text}\" 在位置 ({x}, {y})'**
  String createTextElementLog(Object text, Object x, Object y);

  /// No description provided for @createTimerTooltip_7421.
  ///
  /// In zh, this message translates to:
  /// **'创建计时器'**
  String get createTimerTooltip_7421;

  /// No description provided for @createTimer_4271.
  ///
  /// In zh, this message translates to:
  /// **'创建计时器'**
  String get createTimer_4271;

  /// No description provided for @createVersionSession_4821.
  ///
  /// In zh, this message translates to:
  /// **'创建新版本会话 [{mapTitle}/{versionId}]: {versionName}'**
  String createVersionSession_4821(
    Object mapTitle,
    Object versionId,
    Object versionName,
  );

  /// No description provided for @createWebDavTempDir_4721.
  ///
  /// In zh, this message translates to:
  /// **'创建WebDAV导入临时目录'**
  String get createWebDavTempDir_4721;

  /// No description provided for @create_4833.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get create_4833;

  /// No description provided for @creatingMetadataTable_7281.
  ///
  /// In zh, this message translates to:
  /// **'元数据表不存在，正在创建...'**
  String get creatingMetadataTable_7281;

  /// No description provided for @creationTimeLabel_5421.
  ///
  /// In zh, this message translates to:
  /// **'创建时间: {createdTime}'**
  String creationTimeLabel_5421(Object createdTime);

  /// No description provided for @creationTimeText_7421.
  ///
  /// In zh, this message translates to:
  /// **'创建时间: {date}'**
  String creationTimeText_7421(Object date);

  /// No description provided for @creationTime_4821.
  ///
  /// In zh, this message translates to:
  /// **'创建时间'**
  String get creationTime_4821;

  /// No description provided for @creationTime_7281.
  ///
  /// In zh, this message translates to:
  /// **'创建时间'**
  String get creationTime_7281;

  /// No description provided for @croatianHR_4861.
  ///
  /// In zh, this message translates to:
  /// **'克罗地亚语 (克罗地亚)'**
  String get croatianHR_4861;

  /// No description provided for @croatian_4860.
  ///
  /// In zh, this message translates to:
  /// **'克罗地亚语'**
  String get croatian_4860;

  /// No description provided for @crossLineArea_4827.
  ///
  /// In zh, this message translates to:
  /// **'交叉线区域'**
  String get crossLineArea_4827;

  /// No description provided for @crossLines.
  ///
  /// In zh, this message translates to:
  /// **'十字线'**
  String get crossLines;

  /// No description provided for @crossLinesLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'交叉线'**
  String get crossLinesLabel_4821;

  /// No description provided for @crossLinesTool_3467.
  ///
  /// In zh, this message translates to:
  /// **'交叉线'**
  String get crossLinesTool_3467;

  /// No description provided for @crossLinesTooltip_7532.
  ///
  /// In zh, this message translates to:
  /// **'绘制交叉线'**
  String get crossLinesTooltip_7532;

  /// No description provided for @crossLines_0857.
  ///
  /// In zh, this message translates to:
  /// **'交叉线'**
  String get crossLines_0857;

  /// No description provided for @crossLines_4827.
  ///
  /// In zh, this message translates to:
  /// **'交叉线'**
  String get crossLines_4827;

  /// No description provided for @cssColorNames_4821.
  ///
  /// In zh, this message translates to:
  /// **'• CSS颜色名: red, blue, green等'**
  String get cssColorNames_4821;

  /// No description provided for @cupertinoDesign.
  ///
  /// In zh, this message translates to:
  /// **'Cupertino 设计'**
  String get cupertinoDesign;

  /// No description provided for @currentCacheKeys.
  ///
  /// In zh, this message translates to:
  /// **'当前缓存键: {keys}'**
  String currentCacheKeys(Object keys);

  /// No description provided for @currentConfigDisplay.
  ///
  /// In zh, this message translates to:
  /// **'当前配置: {displayName}'**
  String currentConfigDisplay(Object displayName);

  /// No description provided for @currentConnectionState_7421.
  ///
  /// In zh, this message translates to:
  /// **'当前连接状态: {state}'**
  String currentConnectionState_7421(Object state);

  /// No description provided for @currentCount.
  ///
  /// In zh, this message translates to:
  /// **'当前数量: {count}/5'**
  String currentCount(Object count);

  /// No description provided for @currentIndexLog.
  ///
  /// In zh, this message translates to:
  /// **'  - 当前索引: {currentIndex}'**
  String currentIndexLog(Object currentIndex);

  /// No description provided for @currentLayerOrderDebug.
  ///
  /// In zh, this message translates to:
  /// **'当前_currentMap.layers顺序: {layers}'**
  String currentLayerOrderDebug(Object layers);

  /// No description provided for @currentMapTitle_7421.
  ///
  /// In zh, this message translates to:
  /// **'当前地图: {title}'**
  String currentMapTitle_7421(Object title);

  /// No description provided for @currentMapUpdatedLayersOrder_7421.
  ///
  /// In zh, this message translates to:
  /// **'_currentMap已更新，图层order: {layers}'**
  String currentMapUpdatedLayersOrder_7421(Object layers);

  /// No description provided for @currentNameLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'当前名称:'**
  String get currentNameLabel_4821;

  /// No description provided for @currentOperation_7281.
  ///
  /// In zh, this message translates to:
  /// **'当前正在执行：'**
  String get currentOperation_7281;

  /// No description provided for @currentPermissions_7421.
  ///
  /// In zh, this message translates to:
  /// **'当前权限: {permissions}'**
  String currentPermissions_7421(Object permissions);

  /// No description provided for @currentPitch.
  ///
  /// In zh, this message translates to:
  /// **'当前: {value}'**
  String currentPitch(Object value);

  /// No description provided for @currentPlatform.
  ///
  /// In zh, this message translates to:
  /// **'当前平台：{platform}'**
  String currentPlatform(Object platform);

  /// No description provided for @currentPlatform_5678.
  ///
  /// In zh, this message translates to:
  /// **'此平台'**
  String get currentPlatform_5678;

  /// No description provided for @currentPlaying.
  ///
  /// In zh, this message translates to:
  /// **'  - 当前播放: {currentSource}'**
  String currentPlaying(Object currentSource);

  /// No description provided for @currentPosition_4821.
  ///
  /// In zh, this message translates to:
  /// **'当前位置'**
  String get currentPosition_4821;

  /// No description provided for @currentSelectedLayer_7421.
  ///
  /// In zh, this message translates to:
  /// **'当前: {name}'**
  String currentSelectedLayer_7421(Object name);

  /// No description provided for @currentSelection_4821.
  ///
  /// In zh, this message translates to:
  /// **'当前选择:'**
  String get currentSelection_4821;

  /// No description provided for @currentSettingWithWidth_7421.
  ///
  /// In zh, this message translates to:
  /// **'当前设置: {width}px'**
  String currentSettingWithWidth_7421(Object width);

  /// No description provided for @currentSettings_4521.
  ///
  /// In zh, this message translates to:
  /// **'当前设置'**
  String get currentSettings_4521;

  /// No description provided for @currentSettings_7421.
  ///
  /// In zh, this message translates to:
  /// **'当前设置: {value}px'**
  String currentSettings_7421(Object value);

  /// No description provided for @currentShortcutKey_4821.
  ///
  /// In zh, this message translates to:
  /// **'当前快捷键:'**
  String get currentShortcutKey_4821;

  /// No description provided for @currentSize_7421.
  ///
  /// In zh, this message translates to:
  /// **'当前: {size}px'**
  String currentSize_7421(Object size);

  /// No description provided for @currentSpeechRate.
  ///
  /// In zh, this message translates to:
  /// **'当前: {percentage}%'**
  String currentSpeechRate(Object percentage);

  /// No description provided for @currentUser.
  ///
  /// In zh, this message translates to:
  /// **'当前用户'**
  String get currentUser;

  /// No description provided for @currentUserSuffix_4821.
  ///
  /// In zh, this message translates to:
  /// **'(我)'**
  String get currentUserSuffix_4821;

  /// No description provided for @currentUserSuffix_7281.
  ///
  /// In zh, this message translates to:
  /// **'(我)'**
  String get currentUserSuffix_7281;

  /// No description provided for @currentValuePercentage.
  ///
  /// In zh, this message translates to:
  /// **'当前值: {value}%'**
  String currentValuePercentage(Object value);

  /// No description provided for @currentValueWithUnit.
  ///
  /// In zh, this message translates to:
  /// **'当前值: {value}x'**
  String currentValueWithUnit(Object value);

  /// No description provided for @currentValue_4913.
  ///
  /// In zh, this message translates to:
  /// **'当前值'**
  String get currentValue_4913;

  /// No description provided for @currentVersionLabel.
  ///
  /// In zh, this message translates to:
  /// **'当前版本: {currentVersionId}'**
  String currentVersionLabel(Object currentVersionId);

  /// No description provided for @currentVersion_7281.
  ///
  /// In zh, this message translates to:
  /// **'当前版本'**
  String get currentVersion_7281;

  /// No description provided for @currentVolume.
  ///
  /// In zh, this message translates to:
  /// **'当前: {percentage}%'**
  String currentVolume(Object percentage);

  /// No description provided for @curvatureLabel_7281.
  ///
  /// In zh, this message translates to:
  /// **'弧度'**
  String get curvatureLabel_7281;

  /// No description provided for @curvaturePercentage.
  ///
  /// In zh, this message translates to:
  /// **'弧度: {percentage}%'**
  String curvaturePercentage(Object percentage);

  /// No description provided for @customColorAddedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'自定义颜色添加成功，当前自定义颜色数量: {count}'**
  String customColorAddedSuccessfully(Object count);

  /// No description provided for @customColorAdded_7281.
  ///
  /// In zh, this message translates to:
  /// **'自定义颜色已添加: {color}'**
  String customColorAdded_7281(Object color);

  /// No description provided for @customColor_7421.
  ///
  /// In zh, this message translates to:
  /// **'自定义颜色'**
  String get customColor_7421;

  /// No description provided for @customFields_4943.
  ///
  /// In zh, this message translates to:
  /// **'自定义字段'**
  String get customFields_4943;

  /// No description provided for @customLabel_7281.
  ///
  /// In zh, this message translates to:
  /// **'自定义标签'**
  String get customLabel_7281;

  /// No description provided for @customLayoutDescription_4521.
  ///
  /// In zh, this message translates to:
  /// **'这是一个自定义布局，\nMarkdown 渲染器被嵌入\n到右侧面板中。'**
  String get customLayoutDescription_4521;

  /// No description provided for @customLayoutExample_4821.
  ///
  /// In zh, this message translates to:
  /// **'自定义布局示例'**
  String get customLayoutExample_4821;

  /// No description provided for @customMetadata_7281.
  ///
  /// In zh, this message translates to:
  /// **'自定义元数据'**
  String get customMetadata_7281;

  /// No description provided for @customSizeDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'指定具体宽高比例的浮动窗口'**
  String get customSizeDescription_4821;

  /// No description provided for @customSizeTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'自定义尺寸'**
  String get customSizeTitle_4821;

  /// No description provided for @customTagCount.
  ///
  /// In zh, this message translates to:
  /// **'自定义标签 ({count})'**
  String customTagCount(Object count);

  /// No description provided for @customTagHintText_4521.
  ///
  /// In zh, this message translates to:
  /// **'输入自定义标签'**
  String get customTagHintText_4521;

  /// No description provided for @customTagLoadFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'加载自定义标签失败: {e}'**
  String customTagLoadFailed_7421(Object e);

  /// No description provided for @customVoice_5732.
  ///
  /// In zh, this message translates to:
  /// **'自定义语音'**
  String get customVoice_5732;

  /// No description provided for @customWindowSize_4271.
  ///
  /// In zh, this message translates to:
  /// **'自定义窗口大小'**
  String get customWindowSize_4271;

  /// No description provided for @cutSelectedItems_4821.
  ///
  /// In zh, this message translates to:
  /// **'剪切选中项'**
  String get cutSelectedItems_4821;

  /// No description provided for @cutSelected_4821.
  ///
  /// In zh, this message translates to:
  /// **'剪切选中项'**
  String get cutSelected_4821;

  /// No description provided for @cut_4821.
  ///
  /// In zh, this message translates to:
  /// **'剪切'**
  String get cut_4821;

  /// No description provided for @cuttingTriangleName_7421.
  ///
  /// In zh, this message translates to:
  /// **'切割:{name}'**
  String cuttingTriangleName_7421(Object name);

  /// No description provided for @cuttingType_4821.
  ///
  /// In zh, this message translates to:
  /// **'切割类型'**
  String get cuttingType_4821;

  /// No description provided for @czechCZ_4853.
  ///
  /// In zh, this message translates to:
  /// **'捷克语 (捷克)'**
  String get czechCZ_4853;

  /// No description provided for @czech_4852.
  ///
  /// In zh, this message translates to:
  /// **'捷克语'**
  String get czech_4852;

  /// No description provided for @danishDK_4845.
  ///
  /// In zh, this message translates to:
  /// **'丹麦语 (丹麦)'**
  String get danishDK_4845;

  /// No description provided for @danish_4844.
  ///
  /// In zh, this message translates to:
  /// **'丹麦语'**
  String get danish_4844;

  /// No description provided for @darkMode.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get darkMode;

  /// No description provided for @darkModeAutoInvertApplied_4821.
  ///
  /// In zh, this message translates to:
  /// **'深色模式下已自动应用颜色反转，当前显示您的自定义设置。'**
  String get darkModeAutoInvertApplied_4821;

  /// No description provided for @darkModeColorInversion_4821.
  ///
  /// In zh, this message translates to:
  /// **'深色模式下将自动应用颜色反转。'**
  String get darkModeColorInversion_4821;

  /// No description provided for @darkModeFilterApplied_4821.
  ///
  /// In zh, this message translates to:
  /// **'深色模式下已自动应用颜色反转，当前正在使用主题滤镜。'**
  String get darkModeFilterApplied_4821;

  /// No description provided for @darkModeTitle_4721.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get darkModeTitle_4721;

  /// No description provided for @darkMode_7285.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get darkMode_7285;

  /// No description provided for @darkThemeCanvasAdjustment_4821.
  ///
  /// In zh, this message translates to:
  /// **'在暗色主题下调整画布背景和绘制元素的可见性'**
  String get darkThemeCanvasAdjustment_4821;

  /// No description provided for @darkTheme_5732.
  ///
  /// In zh, this message translates to:
  /// **'深色主题'**
  String get darkTheme_5732;

  /// No description provided for @darkTheme_7632.
  ///
  /// In zh, this message translates to:
  /// **'深色主题'**
  String get darkTheme_7632;

  /// No description provided for @dashedLine.
  ///
  /// In zh, this message translates to:
  /// **'虚线'**
  String get dashedLine;

  /// No description provided for @dashedLineTool_3456.
  ///
  /// In zh, this message translates to:
  /// **'虚线'**
  String get dashedLineTool_3456;

  /// No description provided for @dashedLine_4821.
  ///
  /// In zh, this message translates to:
  /// **'虚线'**
  String get dashedLine_4821;

  /// No description provided for @dashedLine_4822.
  ///
  /// In zh, this message translates to:
  /// **'虚线'**
  String get dashedLine_4822;

  /// No description provided for @dashedLine_5732.
  ///
  /// In zh, this message translates to:
  /// **'虚线'**
  String get dashedLine_5732;

  /// No description provided for @dataChangeListenerFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'数据变更监听器执行失败: {e}'**
  String dataChangeListenerFailed_4821(Object e);

  /// No description provided for @dataLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载数据失败: {e}'**
  String dataLoadFailed(Object e);

  /// No description provided for @dataMigrationComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'数据迁移完成'**
  String get dataMigrationComplete_7281;

  /// No description provided for @dataMigrationFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'数据迁移失败: {e}'**
  String dataMigrationFailed_7281(Object e);

  /// No description provided for @dataMigrationSkipped_7281.
  ///
  /// In zh, this message translates to:
  /// **'数据已经迁移过，跳过迁移'**
  String get dataMigrationSkipped_7281;

  /// No description provided for @dataSerializationComplete.
  ///
  /// In zh, this message translates to:
  /// **'数据序列化完成，字段: {fields}'**
  String dataSerializationComplete(Object fields);

  /// No description provided for @dataSync_7284.
  ///
  /// In zh, this message translates to:
  /// **'数据同步'**
  String get dataSync_7284;

  /// No description provided for @dataWithLayers_5729.
  ///
  /// In zh, this message translates to:
  /// **'有数据(图层数: {layersCount})'**
  String dataWithLayers_5729(Object layersCount);

  /// No description provided for @databaseCloseError_4821.
  ///
  /// In zh, this message translates to:
  /// **'关闭数据库连接时发生错误: {e}'**
  String databaseCloseError_4821(Object e);

  /// No description provided for @databaseConnected_7281.
  ///
  /// In zh, this message translates to:
  /// **'数据库连接成功'**
  String get databaseConnected_7281;

  /// No description provided for @databaseConnectionClosed_7281.
  ///
  /// In zh, this message translates to:
  /// **'数据库连接关闭完成'**
  String get databaseConnectionClosed_7281;

  /// No description provided for @databaseExportFailed_4829.
  ///
  /// In zh, this message translates to:
  /// **'合并数据库导出失败: {e}'**
  String databaseExportFailed_4829(Object e);

  /// No description provided for @databaseExportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'数据库导出成功: {outputFile} (版本: {dbVersion}, 地图数量: {mapCount})'**
  String databaseExportSuccess(
    Object dbVersion,
    Object mapCount,
    Object outputFile,
  );

  /// No description provided for @databaseExportSuccess_7421.
  ///
  /// In zh, this message translates to:
  /// **'合并数据库导出成功'**
  String get databaseExportSuccess_7421;

  /// No description provided for @databaseImportFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'导入数据库失败: {e}'**
  String databaseImportFailed_7421(Object e);

  /// No description provided for @databaseLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'数据库'**
  String get databaseLabel_4821;

  /// No description provided for @databaseLabel_7421.
  ///
  /// In zh, this message translates to:
  /// **'数据库'**
  String get databaseLabel_7421;

  /// No description provided for @databaseStatsError_4821.
  ///
  /// In zh, this message translates to:
  /// **'获取数据库统计信息失败: {e}'**
  String databaseStatsError_4821(Object e);

  /// No description provided for @databaseUpdateComplete.
  ///
  /// In zh, this message translates to:
  /// **'数据库更新完成，影响行数: {updateResult}'**
  String databaseUpdateComplete(Object updateResult);

  /// No description provided for @databaseUpgradeLayoutData_7281.
  ///
  /// In zh, this message translates to:
  /// **'数据库升级：为 layout_data 添加 windowControlsMode 字段'**
  String get databaseUpgradeLayoutData_7281;

  /// No description provided for @databaseUpgradeMessage_7281.
  ///
  /// In zh, this message translates to:
  /// **'数据库升级：添加 home_page_data 字段'**
  String get databaseUpgradeMessage_7281;

  /// No description provided for @daysAgo_7283.
  ///
  /// In zh, this message translates to:
  /// **'天前'**
  String get daysAgo_7283;

  /// No description provided for @dbConnectionCloseTime.
  ///
  /// In zh, this message translates to:
  /// **'数据库连接关闭耗时: {elapsedMilliseconds}ms'**
  String dbConnectionCloseTime(Object elapsedMilliseconds);

  /// No description provided for @debugAddNoteElement.
  ///
  /// In zh, this message translates to:
  /// **'添加便签元素 - renderOrder={renderOrder} (原zIndex={zIndex}), selected={isSelected}'**
  String debugAddNoteElement(
    Object isSelected,
    Object renderOrder,
    Object zIndex,
  );

  /// No description provided for @debugAsyncFunction_7425.
  ///
  /// In zh, this message translates to:
  /// **'处理异步外部函数'**
  String get debugAsyncFunction_7425;

  /// No description provided for @debugClearMapLegendSettings.
  ///
  /// In zh, this message translates to:
  /// **'扩展设置: 已清除地图 {mapId} 的所有图例组智能隐藏设置'**
  String debugClearMapLegendSettings(Object mapId);

  /// No description provided for @debugCompleteGroupCheck.
  ///
  /// In zh, this message translates to:
  /// **'原组是否为完整连接组: {wasCompleteGroup}'**
  String debugCompleteGroupCheck(Object wasCompleteGroup);

  /// No description provided for @debugIndexChange.
  ///
  /// In zh, this message translates to:
  /// **'组oldIndex: {oldIndex}, newIndex: {newIndex}'**
  String debugIndexChange(Object newIndex, Object oldIndex);

  /// No description provided for @debugLayerCount.
  ///
  /// In zh, this message translates to:
  /// **'从当前BLoC状态获取数据: 图层数: {count}'**
  String debugLayerCount(Object count);

  /// No description provided for @debugLegendSessionManagerExists.
  ///
  /// In zh, this message translates to:
  /// **'图例会话管理器是否存在: {isExists}'**
  String debugLegendSessionManagerExists(Object isExists);

  /// No description provided for @debugRemoveElement.
  ///
  /// In zh, this message translates to:
  /// **'使用响应式系统删除绘制元素: {layerId}/{elementId}'**
  String debugRemoveElement(Object elementId, Object layerId);

  /// No description provided for @debugRemoveLegendGroup.
  ///
  /// In zh, this message translates to:
  /// **'使用响应式系统删除图例组: {name}'**
  String debugRemoveLegendGroup(Object name);

  /// No description provided for @decorationLayer_1234.
  ///
  /// In zh, this message translates to:
  /// **'装饰图层'**
  String get decorationLayer_1234;

  /// No description provided for @defaultClientConfigCreated.
  ///
  /// In zh, this message translates to:
  /// **'默认客户端配置创建成功: {displayName}'**
  String defaultClientConfigCreated(Object displayName);

  /// No description provided for @defaultLanguage_7421.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get defaultLanguage_7421;

  /// No description provided for @defaultLayerAdded_7421.
  ///
  /// In zh, this message translates to:
  /// **'默认图层已添加: \"{name}\"'**
  String defaultLayerAdded_7421(Object name);

  /// No description provided for @defaultLayerSuffix_7532.
  ///
  /// In zh, this message translates to:
  /// **'(默认)'**
  String get defaultLayerSuffix_7532;

  /// No description provided for @defaultLegendSize_4821.
  ///
  /// In zh, this message translates to:
  /// **'默认图例大小'**
  String get defaultLegendSize_4821;

  /// No description provided for @defaultOption_7281.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get defaultOption_7281;

  /// No description provided for @defaultText_1234.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get defaultText_1234;

  /// No description provided for @defaultUser_4821.
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get defaultUser_4821;

  /// No description provided for @defaultVersionCreated_7281.
  ///
  /// In zh, this message translates to:
  /// **'默认版本已创建: {versionId}'**
  String defaultVersionCreated_7281(Object versionId);

  /// No description provided for @defaultVersionExists_7281.
  ///
  /// In zh, this message translates to:
  /// **'默认版本已存在'**
  String get defaultVersionExists_7281;

  /// No description provided for @defaultVersionName_4721.
  ///
  /// In zh, this message translates to:
  /// **'默认版本'**
  String get defaultVersionName_4721;

  /// No description provided for @defaultVersionName_4821.
  ///
  /// In zh, this message translates to:
  /// **'默认版本'**
  String get defaultVersionName_4821;

  /// No description provided for @defaultVersionName_7281.
  ///
  /// In zh, this message translates to:
  /// **'默认版本'**
  String get defaultVersionName_7281;

  /// No description provided for @defaultVersionSaved_7281.
  ///
  /// In zh, this message translates to:
  /// **'默认版本已保存 (完整重建)'**
  String get defaultVersionSaved_7281;

  /// No description provided for @defaultVersion_4915.
  ///
  /// In zh, this message translates to:
  /// **'1.2.0'**
  String get defaultVersion_4915;

  /// No description provided for @defaultVoice_4821.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get defaultVoice_4821;

  /// No description provided for @delayReturnToMenu_7281.
  ///
  /// In zh, this message translates to:
  /// **'延迟返回主菜单'**
  String get delayReturnToMenu_7281;

  /// No description provided for @delayUpdateLog.
  ///
  /// In zh, this message translates to:
  /// **'延迟更新: {delay}ms'**
  String delayUpdateLog(Object delay);

  /// No description provided for @delayWithMs.
  ///
  /// In zh, this message translates to:
  /// **'{delay}ms'**
  String delayWithMs(Object delay);

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @deleteButton_7281.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get deleteButton_7281;

  /// No description provided for @deleteClientConfig.
  ///
  /// In zh, this message translates to:
  /// **'删除客户端配置: {clientId}'**
  String deleteClientConfig(Object clientId);

  /// No description provided for @deleteClientConfigFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除客户端配置失败: {e}'**
  String deleteClientConfigFailed(Object e);

  /// No description provided for @deleteConfigFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'删除配置失败: {e}'**
  String deleteConfigFailed_7281(Object e);

  /// No description provided for @deleteConfigFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'删除配置失败: {e}'**
  String deleteConfigFailed_7284(Object e);

  /// No description provided for @deleteConfigLog_7421.
  ///
  /// In zh, this message translates to:
  /// **'删除配置: {displayName} ({clientId})'**
  String deleteConfigLog_7421(Object clientId, Object displayName);

  /// No description provided for @deleteConfiguration_4271.
  ///
  /// In zh, this message translates to:
  /// **'删除配置'**
  String get deleteConfiguration_4271;

  /// No description provided for @deleteConfiguration_7281.
  ///
  /// In zh, this message translates to:
  /// **'删除配置'**
  String get deleteConfiguration_7281;

  /// No description provided for @deleteConflict_4829.
  ///
  /// In zh, this message translates to:
  /// **'删除冲突'**
  String get deleteConflict_4829;

  /// No description provided for @deleteCustomTagFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'删除自定义标签失败: {e}'**
  String deleteCustomTagFailed_7421(Object e);

  /// No description provided for @deleteDrawingElement.
  ///
  /// In zh, this message translates to:
  /// **'删除绘制元素: {layerId}/{elementId}'**
  String deleteDrawingElement(Object elementId, Object layerId);

  /// No description provided for @deleteElementError_4821.
  ///
  /// In zh, this message translates to:
  /// **'删除绘制元素失败 [{mapTitle}/{layerId}/{elementId}:{version}]: {error}'**
  String deleteElementError_4821(
    Object elementId,
    Object error,
    Object layerId,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @deleteElementFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除元素失败: {e}'**
  String deleteElementFailed(Object e);

  /// No description provided for @deleteElementTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'删除元素'**
  String get deleteElementTooltip_7281;

  /// No description provided for @deleteEmptyDirectory_7281.
  ///
  /// In zh, this message translates to:
  /// **'删除空目录: {path}'**
  String deleteEmptyDirectory_7281(Object path);

  /// No description provided for @deleteExpiredLogFile.
  ///
  /// In zh, this message translates to:
  /// **'删除过期日志文件: {path}'**
  String deleteExpiredLogFile(Object path);

  /// No description provided for @deleteFailed_7425.
  ///
  /// In zh, this message translates to:
  /// **'删除失败: {e}'**
  String deleteFailed_7425(Object e);

  /// No description provided for @deleteField_4948.
  ///
  /// In zh, this message translates to:
  /// **'删除字段'**
  String get deleteField_4948;

  /// No description provided for @deleteFilesFailed_4924.
  ///
  /// In zh, this message translates to:
  /// **'删除文件失败: {error}'**
  String deleteFilesFailed_4924(Object error);

  /// No description provided for @deleteFolderFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除文件夹失败: {folderPath}, 错误: {e}'**
  String deleteFolderFailed(Object e, Object folderPath);

  /// No description provided for @deleteFolderFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'删除失败：文件夹不为空或不存在'**
  String get deleteFolderFailed_4821;

  /// No description provided for @deleteFolderFailed_4840.
  ///
  /// In zh, this message translates to:
  /// **'删除文件夹失败'**
  String get deleteFolderFailed_4840;

  /// No description provided for @deleteFolder_4271.
  ///
  /// In zh, this message translates to:
  /// **'删除文件夹'**
  String get deleteFolder_4271;

  /// No description provided for @deleteFolder_4836.
  ///
  /// In zh, this message translates to:
  /// **'删除文件夹'**
  String get deleteFolder_4836;

  /// No description provided for @deleteItem_4822.
  ///
  /// In zh, this message translates to:
  /// **'删除项目 {itemNumber}'**
  String deleteItem_4822(Object itemNumber);

  /// No description provided for @deleteLayer.
  ///
  /// In zh, this message translates to:
  /// **'删除图层'**
  String get deleteLayer;

  /// No description provided for @deleteLayerWithReactiveSystem.
  ///
  /// In zh, this message translates to:
  /// **'使用响应式系统删除图层: {name}'**
  String deleteLayerWithReactiveSystem(Object name);

  /// No description provided for @deleteLayer_4271.
  ///
  /// In zh, this message translates to:
  /// **'删除图层'**
  String get deleteLayer_4271;

  /// No description provided for @deleteLayer_4821.
  ///
  /// In zh, this message translates to:
  /// **'删除图层'**
  String get deleteLayer_4821;

  /// No description provided for @deleteLayer_7425.
  ///
  /// In zh, this message translates to:
  /// **'删除图层: {layerId}'**
  String deleteLayer_7425(Object layerId);

  /// No description provided for @deleteLegend.
  ///
  /// In zh, this message translates to:
  /// **'删除图例'**
  String get deleteLegend;

  /// No description provided for @deleteLegendFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除图例失败: {title}, 错误: {e}'**
  String deleteLegendFailed(Object e, Object title);

  /// No description provided for @deleteLegendGroup.
  ///
  /// In zh, this message translates to:
  /// **'删除图例组'**
  String get deleteLegendGroup;

  /// No description provided for @deleteLegendGroupFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除图例组失败[{mapTitle}/{groupId}:{version}]: {error}'**
  String deleteLegendGroupFailed(
    Object error,
    Object groupId,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @deleteLegendGroupFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'删除图例组失败: {error}'**
  String deleteLegendGroupFailed_7421(Object error);

  /// No description provided for @deleteLegendGroup_4271.
  ///
  /// In zh, this message translates to:
  /// **'删除图例组'**
  String get deleteLegendGroup_4271;

  /// No description provided for @deleteLegend_7421.
  ///
  /// In zh, this message translates to:
  /// **'删除图例'**
  String get deleteLegend_7421;

  /// No description provided for @deleteMap.
  ///
  /// In zh, this message translates to:
  /// **'删除地图'**
  String get deleteMap;

  /// No description provided for @deleteMapFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除地图失败：{error}'**
  String deleteMapFailed(Object error);

  /// No description provided for @deleteNoteDebug.
  ///
  /// In zh, this message translates to:
  /// **'删除便利贴: {noteId}'**
  String deleteNoteDebug(Object noteId);

  /// No description provided for @deleteNoteElementFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除便签元素失败: {e}'**
  String deleteNoteElementFailed(Object e);

  /// No description provided for @deleteNoteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除便签失败: {e}'**
  String deleteNoteFailed(Object e);

  /// No description provided for @deleteNoteFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'删除便签失败: {e}'**
  String deleteNoteFailed_7281(Object e);

  /// No description provided for @deleteNoteLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'删除便签'**
  String get deleteNoteLabel_4821;

  /// No description provided for @deleteNoteTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'删除便签'**
  String get deleteNoteTooltip_7281;

  /// No description provided for @deleteNote_7421.
  ///
  /// In zh, this message translates to:
  /// **'删除便签'**
  String get deleteNote_7421;

  /// No description provided for @deleteOldDataError.
  ///
  /// In zh, this message translates to:
  /// **'删除旧数据目录时出错 [{mapTitle}]: {e}'**
  String deleteOldDataError(Object e, Object mapTitle);

  /// No description provided for @deletePrivateKeyFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除私钥失败: {e}'**
  String deletePrivateKeyFailed(Object e);

  /// No description provided for @deleteScript_4271.
  ///
  /// In zh, this message translates to:
  /// **'删除脚本'**
  String get deleteScript_4271;

  /// No description provided for @deleteSelectedItems_4821.
  ///
  /// In zh, this message translates to:
  /// **'删除选中项'**
  String get deleteSelectedItems_4821;

  /// No description provided for @deleteSelected_4821.
  ///
  /// In zh, this message translates to:
  /// **'删除选中项'**
  String get deleteSelected_4821;

  /// No description provided for @deleteStickyNoteElementDebug.
  ///
  /// In zh, this message translates to:
  /// **'使用响应式系统删除便签绘制元素: {id}/{elementId}'**
  String deleteStickyNoteElementDebug(Object elementId, Object id);

  /// No description provided for @deleteStickyNoteError_7425.
  ///
  /// In zh, this message translates to:
  /// **'删除便签数据失败 [{mapTitle}/{stickyNoteId}:{version}]: {e}'**
  String deleteStickyNoteError_7425(
    Object e,
    Object mapTitle,
    Object stickyNoteId,
    Object version,
  );

  /// No description provided for @deleteSuccessLog_7421.
  ///
  /// In zh, this message translates to:
  /// **'删除成功: {fullRemotePath}'**
  String deleteSuccessLog_7421(Object fullRemotePath);

  /// No description provided for @deleteTempFile.
  ///
  /// In zh, this message translates to:
  /// **'删除临时文件: {path}'**
  String deleteTempFile(Object path);

  /// No description provided for @deleteTempFileFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'删除临时文件失败: {path}, 错误: {error}'**
  String deleteTempFileFailed_7421(Object error, Object path);

  /// No description provided for @deleteText_4821.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get deleteText_4821;

  /// No description provided for @deleteTimerFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除计时器失败: {e}'**
  String deleteTimerFailed(Object e);

  /// No description provided for @deleteUserFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'删除用户失败: {error}'**
  String deleteUserFailed_7421(Object error);

  /// No description provided for @deleteVersionFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除版本失败: {error}'**
  String deleteVersionFailed(Object error);

  /// No description provided for @deleteVersionMetadataFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除版本元数据失败 [{mapTitle}:{versionId}]: {e}'**
  String deleteVersionMetadataFailed(
    Object e,
    Object mapTitle,
    Object versionId,
  );

  /// No description provided for @deleteVersionSession.
  ///
  /// In zh, this message translates to:
  /// **'删除版本会话 [{mapTitle}/{versionId}]'**
  String deleteVersionSession(Object mapTitle, Object versionId);

  /// No description provided for @deleteVersion_4271.
  ///
  /// In zh, this message translates to:
  /// **'删除版本'**
  String get deleteVersion_4271;

  /// No description provided for @deleteVfsVersionDataFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除VFS版本数据失败: {e}'**
  String deleteVfsVersionDataFailed(Object e);

  /// No description provided for @delete_3834.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete_3834;

  /// No description provided for @delete_4821.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete_4821;

  /// No description provided for @delete_4838.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete_4838;

  /// No description provided for @delete_4963.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete_4963;

  /// No description provided for @delete_5421.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete_5421;

  /// No description provided for @delete_7281.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete_7281;

  /// No description provided for @deletedItems_4821.
  ///
  /// In zh, this message translates to:
  /// **'已删除 {count} 个项目'**
  String deletedItems_4821(Object count);

  /// No description provided for @deletedMessage_7421.
  ///
  /// In zh, this message translates to:
  /// **'已删除'**
  String get deletedMessage_7421;

  /// No description provided for @demoMapBlueTheme_4821.
  ///
  /// In zh, this message translates to:
  /// **'演示地图 - 蓝色主题'**
  String get demoMapBlueTheme_4821;

  /// No description provided for @demoMapGreenTheme_7281.
  ///
  /// In zh, this message translates to:
  /// **'演示地图 - 绿色主题'**
  String get demoMapGreenTheme_7281;

  /// No description provided for @demoMapSynced_7281.
  ///
  /// In zh, this message translates to:
  /// **'已同步演示地图1信息'**
  String get demoMapSynced_7281;

  /// No description provided for @demoMapSynced_7421.
  ///
  /// In zh, this message translates to:
  /// **'已同步演示地图2信息'**
  String get demoMapSynced_7421;

  /// No description provided for @demoModeTitle_7281.
  ///
  /// In zh, this message translates to:
  /// **'嵌入模式演示'**
  String get demoModeTitle_7281;

  /// No description provided for @demoText_4271.
  ///
  /// In zh, this message translates to:
  /// **'演示'**
  String get demoText_4271;

  /// No description provided for @demoUpdateNoticeWithoutAnimation_4821.
  ///
  /// In zh, this message translates to:
  /// **'🔄 演示更新通知（无重新动画）'**
  String get demoUpdateNoticeWithoutAnimation_4821;

  /// No description provided for @demoUser_4721.
  ///
  /// In zh, this message translates to:
  /// **'演示用户'**
  String get demoUser_4721;

  /// No description provided for @densityLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'密度'**
  String get densityLabel_4821;

  /// No description provided for @densityValue_7281.
  ///
  /// In zh, this message translates to:
  /// **'密度: {value}x'**
  String densityValue_7281(Object value);

  /// No description provided for @dependencyDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'此外，本项目还依赖众多 Flutter 生态系统中的优秀开源包，点击下方按钮查看完整的依赖项列表和许可证信息。'**
  String get dependencyDescription_4821;

  /// No description provided for @descriptionHint_4942.
  ///
  /// In zh, this message translates to:
  /// **'输入资源包的详细描述'**
  String get descriptionHint_4942;

  /// No description provided for @descriptionLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'描述'**
  String get descriptionLabel_4821;

  /// No description provided for @description_4941.
  ///
  /// In zh, this message translates to:
  /// **'描述'**
  String get description_4941;

  /// No description provided for @desktopExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'桌面平台导出图片失败: {e}'**
  String desktopExportFailed(Object e);

  /// No description provided for @desktopExportImageFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'桌面平台导出单张图片失败: {e}'**
  String desktopExportImageFailed_7285(Object e);

  /// No description provided for @desktopFiles.
  ///
  /// In zh, this message translates to:
  /// **'桌面文件'**
  String get desktopFiles;

  /// No description provided for @desktopMobilePlatforms_4821.
  ///
  /// In zh, this message translates to:
  /// **'在桌面/移动平台上：'**
  String get desktopMobilePlatforms_4821;

  /// No description provided for @desktopMobile_6943.
  ///
  /// In zh, this message translates to:
  /// **'桌面/移动设备'**
  String get desktopMobile_6943;

  /// No description provided for @desktopMode_2634.
  ///
  /// In zh, this message translates to:
  /// **'桌面模式'**
  String get desktopMode_2634;

  /// No description provided for @destructible_4830.
  ///
  /// In zh, this message translates to:
  /// **'可破坏'**
  String get destructible_4830;

  /// No description provided for @destructible_4831.
  ///
  /// In zh, this message translates to:
  /// **'可破坏'**
  String get destructible_4831;

  /// No description provided for @detectOldDataMigration_7281.
  ///
  /// In zh, this message translates to:
  /// **'检测到需要迁移的旧数据'**
  String get detectOldDataMigration_7281;

  /// No description provided for @detectionResultShouldEnableLink_7421.
  ///
  /// In zh, this message translates to:
  /// **'检测结果 - 应该开启链接: {shouldEnableLink}'**
  String detectionResultShouldEnableLink_7421(Object shouldEnableLink);

  /// No description provided for @device_4824.
  ///
  /// In zh, this message translates to:
  /// **'装置'**
  String get device_4824;

  /// No description provided for @device_4828.
  ///
  /// In zh, this message translates to:
  /// **'装置'**
  String get device_4828;

  /// No description provided for @diagonalAreaLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'斜线区域'**
  String get diagonalAreaLabel_4821;

  /// No description provided for @diagonalArea_4826.
  ///
  /// In zh, this message translates to:
  /// **'斜线区域'**
  String get diagonalArea_4826;

  /// No description provided for @diagonalCutting_4521.
  ///
  /// In zh, this message translates to:
  /// **'对角线切割'**
  String get diagonalCutting_4521;

  /// No description provided for @diagonalLines.
  ///
  /// In zh, this message translates to:
  /// **'对角线'**
  String get diagonalLines;

  /// No description provided for @diagonalLinesTool_9023.
  ///
  /// In zh, this message translates to:
  /// **'单斜线'**
  String get diagonalLinesTool_9023;

  /// No description provided for @directUse_4821.
  ///
  /// In zh, this message translates to:
  /// **'直接使用'**
  String get directUse_4821;

  /// No description provided for @directoryCopyComplete.
  ///
  /// In zh, this message translates to:
  /// **'目录复制完成: {sourcePath} -> {targetPath}'**
  String directoryCopyComplete(Object sourcePath, Object targetPath);

  /// No description provided for @directoryCreatedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'目录创建成功: {fullRemotePath}'**
  String directoryCreatedSuccessfully(Object fullRemotePath);

  /// No description provided for @directoryCreationFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'目录创建失败: {e}'**
  String directoryCreationFailed_7285(Object e);

  /// No description provided for @directoryListSuccess.
  ///
  /// In zh, this message translates to:
  /// **'目录列表获取成功: {fullRemotePath} ({length} 个项目)'**
  String directoryListSuccess(Object fullRemotePath, Object length);

  /// No description provided for @directorySelectedByGroup.
  ///
  /// In zh, this message translates to:
  /// **'此目录已被图例组 \"{groupName}\" 选择'**
  String directorySelectedByGroup(Object groupName);

  /// No description provided for @directorySelectedByOthers_4821.
  ///
  /// In zh, this message translates to:
  /// **'此目录已被其他图例组选择'**
  String get directorySelectedByOthers_4821;

  /// No description provided for @directorySelectionNotAllowed_4821.
  ///
  /// In zh, this message translates to:
  /// **'不允许选择文件夹'**
  String get directorySelectionNotAllowed_4821;

  /// No description provided for @directoryUsedByGroups.
  ///
  /// In zh, this message translates to:
  /// **'此目录已被以下图例组选择：{groupNames}'**
  String directoryUsedByGroups(Object groupNames);

  /// No description provided for @directory_4821.
  ///
  /// In zh, this message translates to:
  /// **'目录'**
  String get directory_4821;

  /// No description provided for @directory_5030.
  ///
  /// In zh, this message translates to:
  /// **'目录'**
  String get directory_5030;

  /// No description provided for @disableAudioRendering_4821.
  ///
  /// In zh, this message translates to:
  /// **'禁用音频渲染'**
  String get disableAudioRendering_4821;

  /// No description provided for @disableAutoPlay_5421.
  ///
  /// In zh, this message translates to:
  /// **'关闭自动播放'**
  String get disableAutoPlay_5421;

  /// No description provided for @disableCrosshair_42.
  ///
  /// In zh, this message translates to:
  /// **'关闭十字线'**
  String get disableCrosshair_42;

  /// No description provided for @disableHtmlRendering_4721.
  ///
  /// In zh, this message translates to:
  /// **'禁用HTML渲染'**
  String get disableHtmlRendering_4721;

  /// No description provided for @disableLatexRendering_4821.
  ///
  /// In zh, this message translates to:
  /// **'禁用LaTeX渲染'**
  String get disableLatexRendering_4821;

  /// No description provided for @disableLoopPlayback_7281.
  ///
  /// In zh, this message translates to:
  /// **'关闭循环播放'**
  String get disableLoopPlayback_7281;

  /// No description provided for @disableVideoRendering_4821.
  ///
  /// In zh, this message translates to:
  /// **'禁用视频渲染'**
  String get disableVideoRendering_4821;

  /// No description provided for @disable_4821.
  ///
  /// In zh, this message translates to:
  /// **'禁用'**
  String get disable_4821;

  /// No description provided for @disabledInParentheses_4829.
  ///
  /// In zh, this message translates to:
  /// **'(禁用)'**
  String get disabledInParentheses_4829;

  /// No description provided for @disabledIndicator_7421.
  ///
  /// In zh, this message translates to:
  /// **'(禁用)'**
  String get disabledIndicator_7421;

  /// No description provided for @disabledLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'(禁用)'**
  String get disabledLabel_4821;

  /// No description provided for @disabledStatus_4821.
  ///
  /// In zh, this message translates to:
  /// **'已禁用'**
  String get disabledStatus_4821;

  /// No description provided for @disabledTrayNavigation_4821.
  ///
  /// In zh, this message translates to:
  /// **'此页面已禁用 TrayNavigation'**
  String get disabledTrayNavigation_4821;

  /// No description provided for @disabled_4821.
  ///
  /// In zh, this message translates to:
  /// **'已禁用'**
  String get disabled_4821;

  /// No description provided for @discardChanges_7421.
  ///
  /// In zh, this message translates to:
  /// **'放弃更改'**
  String get discardChanges_7421;

  /// No description provided for @disconnectCurrentConnection_7281.
  ///
  /// In zh, this message translates to:
  /// **'断开当前连接...'**
  String get disconnectCurrentConnection_7281;

  /// No description provided for @disconnectFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'断开连接失败: {e}'**
  String disconnectFailed_7285(Object e);

  /// No description provided for @disconnectWebSocket_4821.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService 断开WebSocket连接'**
  String get disconnectWebSocket_4821;

  /// No description provided for @disconnectWebSocket_7421.
  ///
  /// In zh, this message translates to:
  /// **'断开 WebSocket 连接'**
  String get disconnectWebSocket_7421;

  /// No description provided for @disconnect_7421.
  ///
  /// In zh, this message translates to:
  /// **'断开'**
  String get disconnect_7421;

  /// No description provided for @disconnectedOffline_3632.
  ///
  /// In zh, this message translates to:
  /// **'未连接（离线模式）'**
  String get disconnectedOffline_3632;

  /// No description provided for @disconnected_4821.
  ///
  /// In zh, this message translates to:
  /// **'已断开'**
  String get disconnected_4821;

  /// No description provided for @disconnected_9067.
  ///
  /// In zh, this message translates to:
  /// **'未连接'**
  String get disconnected_9067;

  /// No description provided for @displayAreaMultiplierLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'显示区域倍数'**
  String get displayAreaMultiplierLabel_4821;

  /// No description provided for @displayAreaMultiplierText.
  ///
  /// In zh, this message translates to:
  /// **'显示区域倍数: {value}x'**
  String displayAreaMultiplierText(Object value);

  /// No description provided for @displayDuration_7284.
  ///
  /// In zh, this message translates to:
  /// **'显示时长: '**
  String get displayDuration_7284;

  /// No description provided for @displayLocaleSetting_4821.
  ///
  /// In zh, this message translates to:
  /// **'显示区域设置'**
  String get displayLocaleSetting_4821;

  /// No description provided for @displayLocation_7421.
  ///
  /// In zh, this message translates to:
  /// **'显示位置'**
  String get displayLocation_7421;

  /// No description provided for @displayNameCannotBeEmpty_4821.
  ///
  /// In zh, this message translates to:
  /// **'显示名称不能为空'**
  String get displayNameCannotBeEmpty_4821;

  /// No description provided for @displayNameHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'输入客户端显示名称'**
  String get displayNameHint_4821;

  /// No description provided for @displayNameHint_7532.
  ///
  /// In zh, this message translates to:
  /// **'请输入您的显示名称'**
  String get displayNameHint_7532;

  /// No description provided for @displayNameLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'显示名称'**
  String get displayNameLabel_4821;

  /// No description provided for @displayNameMinLength_4821.
  ///
  /// In zh, this message translates to:
  /// **'显示名称至少需要2个字符'**
  String get displayNameMinLength_4821;

  /// No description provided for @displayNameTooLong_42.
  ///
  /// In zh, this message translates to:
  /// **'显示名称不能超过50个字符'**
  String get displayNameTooLong_42;

  /// No description provided for @displayName_1234.
  ///
  /// In zh, this message translates to:
  /// **'显示名称'**
  String get displayName_1234;

  /// No description provided for @displayName_4521.
  ///
  /// In zh, this message translates to:
  /// **'显示名称'**
  String get displayName_4521;

  /// No description provided for @displayName_4821.
  ///
  /// In zh, this message translates to:
  /// **'显示名称'**
  String get displayName_4821;

  /// No description provided for @displayOrderLayersDebug.
  ///
  /// In zh, this message translates to:
  /// **'当前_displayOrderLayers顺序: {layers}'**
  String displayOrderLayersDebug(Object layers);

  /// No description provided for @dividerText_4821.
  ///
  /// In zh, this message translates to:
  /// **'分割线'**
  String get dividerText_4821;

  /// No description provided for @doNotAutoClose_7281.
  ///
  /// In zh, this message translates to:
  /// **'不自动关闭'**
  String get doNotAutoClose_7281;

  /// No description provided for @documentName_4821.
  ///
  /// In zh, this message translates to:
  /// **'文档'**
  String get documentName_4821;

  /// No description provided for @documentNavigation_7281.
  ///
  /// In zh, this message translates to:
  /// **'文档导航'**
  String get documentNavigation_7281;

  /// No description provided for @documentNoAudioContent_4821.
  ///
  /// In zh, this message translates to:
  /// **'此文档不包含音频内容'**
  String get documentNoAudioContent_4821;

  /// No description provided for @documentWithoutLatex_4721.
  ///
  /// In zh, this message translates to:
  /// **'此文档不包含LaTeX公式'**
  String get documentWithoutLatex_4721;

  /// No description provided for @documentationDescription_4912.
  ///
  /// In zh, this message translates to:
  /// **'查看详细的使用说明和开发文档'**
  String get documentationDescription_4912;

  /// No description provided for @door_4825.
  ///
  /// In zh, this message translates to:
  /// **'门'**
  String get door_4825;

  /// No description provided for @dotGrid.
  ///
  /// In zh, this message translates to:
  /// **'点网格'**
  String get dotGrid;

  /// No description provided for @dotGridArea_4828.
  ///
  /// In zh, this message translates to:
  /// **'点阵区域'**
  String get dotGridArea_4828;

  /// No description provided for @dotGridLabel_5421.
  ///
  /// In zh, this message translates to:
  /// **'点阵'**
  String get dotGridLabel_5421;

  /// No description provided for @dotGridTool_7901.
  ///
  /// In zh, this message translates to:
  /// **'点阵'**
  String get dotGridTool_7901;

  /// No description provided for @dotGrid_1968.
  ///
  /// In zh, this message translates to:
  /// **'点阵'**
  String get dotGrid_1968;

  /// No description provided for @dotGrid_4828.
  ///
  /// In zh, this message translates to:
  /// **'点阵'**
  String get dotGrid_4828;

  /// No description provided for @downText_4821.
  ///
  /// In zh, this message translates to:
  /// **'下'**
  String get downText_4821;

  /// No description provided for @downloadAndImportFailed_5039.
  ///
  /// In zh, this message translates to:
  /// **'下载并导入失败'**
  String get downloadAndImportFailed_5039;

  /// No description provided for @downloadAndImport_5029.
  ///
  /// In zh, this message translates to:
  /// **'下载并导入'**
  String get downloadAndImport_5029;

  /// No description provided for @downloadAsZip_4821.
  ///
  /// In zh, this message translates to:
  /// **'下载为压缩包'**
  String get downloadAsZip_4821;

  /// No description provided for @downloadAsZip_4975.
  ///
  /// In zh, this message translates to:
  /// **'压缩下载'**
  String get downloadAsZip_4975;

  /// No description provided for @downloadCurrentDirectoryCompressed_4821.
  ///
  /// In zh, this message translates to:
  /// **'下载当前目录（压缩）'**
  String get downloadCurrentDirectoryCompressed_4821;

  /// No description provided for @downloadCurrentDirectory_4821.
  ///
  /// In zh, this message translates to:
  /// **'下载当前目录'**
  String get downloadCurrentDirectory_4821;

  /// No description provided for @downloadExportFile_4966.
  ///
  /// In zh, this message translates to:
  /// **'下载导出文件'**
  String get downloadExportFile_4966;

  /// No description provided for @downloadFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'下载失败: {error}'**
  String downloadFailed_7284(Object error);

  /// No description provided for @downloadFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'下载失败: {e}'**
  String downloadFailed_7285(Object e);

  /// No description provided for @downloadFailed_7425.
  ///
  /// In zh, this message translates to:
  /// **'下载失败：{e}'**
  String downloadFailed_7425(Object e);

  /// No description provided for @downloadFilesAndFolders.
  ///
  /// In zh, this message translates to:
  /// **'已下载 {fileCount} 个文件和 {folderCount} 个文件夹到 {downloadPath}'**
  String downloadFilesAndFolders(
    Object downloadPath,
    Object fileCount,
    Object folderCount,
  );

  /// No description provided for @downloadSelectedCompressed_4821.
  ///
  /// In zh, this message translates to:
  /// **'下载选中项（压缩）'**
  String get downloadSelectedCompressed_4821;

  /// No description provided for @downloadSelected_4821.
  ///
  /// In zh, this message translates to:
  /// **'下载选中项'**
  String get downloadSelected_4821;

  /// No description provided for @downloadSelected_4974.
  ///
  /// In zh, this message translates to:
  /// **'下载选中项'**
  String get downloadSelected_4974;

  /// No description provided for @downloadSummary.
  ///
  /// In zh, this message translates to:
  /// **'已下载 {fileCount} 个文件和 {folderCount} 个文件夹到 {downloadPath}'**
  String downloadSummary(
    Object downloadPath,
    Object fileCount,
    Object folderCount,
  );

  /// No description provided for @downloadZipFileFailed_5037.
  ///
  /// In zh, this message translates to:
  /// **'下载ZIP文件失败'**
  String get downloadZipFileFailed_5037;

  /// No description provided for @download_4821.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get download_4821;

  /// No description provided for @download_4973.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get download_4973;

  /// No description provided for @downloadedFilesAndDirectories.
  ///
  /// In zh, this message translates to:
  /// **'已下载 {fileCount} 个文件和 {directoryCount} 个目录'**
  String downloadedFilesAndDirectories(Object directoryCount, Object fileCount);

  /// No description provided for @downloadedFilesCount.
  ///
  /// In zh, this message translates to:
  /// **'已下载 {fileCount} 个文件'**
  String downloadedFilesCount(Object fileCount);

  /// No description provided for @downloadedFilesFromDirectories.
  ///
  /// In zh, this message translates to:
  /// **'已下载 {directoryCount} 个目录中的文件'**
  String downloadedFilesFromDirectories(Object directoryCount);

  /// No description provided for @downloadedFilesInDirectories.
  ///
  /// In zh, this message translates to:
  /// **'已下载 {directoryCount} 个目录中的文件'**
  String downloadedFilesInDirectories(Object directoryCount);

  /// No description provided for @downloadingFileProgress_4821.
  ///
  /// In zh, this message translates to:
  /// **'正在下载文件... {percent}%'**
  String downloadingFileProgress_4821(Object percent);

  /// No description provided for @downloading_5036.
  ///
  /// In zh, this message translates to:
  /// **'正在下载'**
  String get downloading_5036;

  /// No description provided for @dragComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'拖拽完成: {legendPath}'**
  String dragComplete_7281(Object legendPath);

  /// No description provided for @dragDemoTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'拖拽功能演示'**
  String get dragDemoTitle_4821;

  /// No description provided for @dragEndCheckDrawer_4821.
  ///
  /// In zh, this message translates to:
  /// **'拖拽结束：检查是否需要重新打开图例组管理抽屉'**
  String get dragEndCheckDrawer_4821;

  /// No description provided for @dragEndLegend_7281.
  ///
  /// In zh, this message translates to:
  /// **'结束拖拽图例: {legendPath}, 是否被接受: {wasAccepted}'**
  String dragEndLegend_7281(Object legendPath, Object wasAccepted);

  /// No description provided for @dragEndReopenLegendDrawer_7281.
  ///
  /// In zh, this message translates to:
  /// **'拖拽结束：重新打开图例组管理抽屉'**
  String get dragEndReopenLegendDrawer_7281;

  /// No description provided for @dragFeature_4521.
  ///
  /// In zh, this message translates to:
  /// **'拖拽功能'**
  String get dragFeature_4521;

  /// No description provided for @dragHandleSizeHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'拖动控制柄大小'**
  String get dragHandleSizeHint_4821;

  /// No description provided for @dragLegendAccepted_5421.
  ///
  /// In zh, this message translates to:
  /// **'接收到拖拽的图例(onAccept): {legendPath}'**
  String dragLegendAccepted_5421(Object legendPath);

  /// No description provided for @dragLegendFromCache.
  ///
  /// In zh, this message translates to:
  /// **'从缓存拖拽添加图例: {legendPath} 到位置: {canvasPosition}'**
  String dragLegendFromCache(Object canvasPosition, Object legendPath);

  /// No description provided for @dragLegendStart.
  ///
  /// In zh, this message translates to:
  /// **'开始拖拽图例: {legendPath}'**
  String dragLegendStart(Object legendPath);

  /// No description provided for @dragReleasePosition_7421.
  ///
  /// In zh, this message translates to:
  /// **'拖拽释放位置 - 全局: {globalPosition}, 本地: {localPosition}'**
  String dragReleasePosition_7421(Object globalPosition, Object localPosition);

  /// No description provided for @dragStartCloseDrawer_4821.
  ///
  /// In zh, this message translates to:
  /// **'拖拽开始：临时关闭图例组管理抽屉'**
  String get dragStartCloseDrawer_4821;

  /// No description provided for @dragToAddLegendItem_7421.
  ///
  /// In zh, this message translates to:
  /// **'拖拽添加图例项到地图编辑器: ID={id}, legendId={legendId}'**
  String dragToAddLegendItem_7421(Object id, Object legendId);

  /// No description provided for @dragToMoveHint_7281.
  ///
  /// In zh, this message translates to:
  /// **'💡 提示：在标题栏区域按住鼠标并拖拽'**
  String get dragToMoveHint_7281;

  /// No description provided for @dragToReorderFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'通过拖拽重新排序便签失败: {e}'**
  String dragToReorderFailed_7285(Object e);

  /// No description provided for @draggableWindowDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'支持拖拽移动的浮动窗口'**
  String get draggableWindowDescription_4821;

  /// No description provided for @draggableWindowTitle_4521.
  ///
  /// In zh, this message translates to:
  /// **'可拖拽窗口'**
  String get draggableWindowTitle_4521;

  /// No description provided for @draggableWindowTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'可拖拽窗口'**
  String get draggableWindowTitle_4821;

  /// No description provided for @draggableWindow_4271.
  ///
  /// In zh, this message translates to:
  /// **'可拖拽窗口'**
  String get draggableWindow_4271;

  /// No description provided for @draggingText_4821.
  ///
  /// In zh, this message translates to:
  /// **'拖拽中...'**
  String get draggingText_4821;

  /// No description provided for @drawArrowTooltip_8732.
  ///
  /// In zh, this message translates to:
  /// **'绘制箭头'**
  String get drawArrowTooltip_8732;

  /// No description provided for @drawDashedLine_7532.
  ///
  /// In zh, this message translates to:
  /// **'绘制虚线'**
  String get drawDashedLine_7532;

  /// No description provided for @drawDiagonalAreaTooltip_7532.
  ///
  /// In zh, this message translates to:
  /// **'绘制斜线区域'**
  String get drawDiagonalAreaTooltip_7532;

  /// No description provided for @drawDotGridTooltip_8732.
  ///
  /// In zh, this message translates to:
  /// **'绘制点阵'**
  String get drawDotGridTooltip_8732;

  /// No description provided for @drawHollowRectangle_8423.
  ///
  /// In zh, this message translates to:
  /// **'绘制空心矩形'**
  String get drawHollowRectangle_8423;

  /// No description provided for @drawLineTooltip_4522.
  ///
  /// In zh, this message translates to:
  /// **'绘制直线'**
  String get drawLineTooltip_4522;

  /// No description provided for @drawRectangleTooltip_4522.
  ///
  /// In zh, this message translates to:
  /// **'绘制矩形'**
  String get drawRectangleTooltip_4522;

  /// No description provided for @drawToDefaultLayer_4726.
  ///
  /// In zh, this message translates to:
  /// **'绘制到: {name} (默认最上层)'**
  String drawToDefaultLayer_4726(Object name);

  /// No description provided for @drawToLayer_4725.
  ///
  /// In zh, this message translates to:
  /// **'绘制到: {name}'**
  String drawToLayer_4725(Object name);

  /// No description provided for @drawToStickyNote_4724.
  ///
  /// In zh, this message translates to:
  /// **'绘制到便签: {title}'**
  String drawToStickyNote_4724(Object title);

  /// No description provided for @drawerWidthSetting_4521.
  ///
  /// In zh, this message translates to:
  /// **'抽屉宽度设置'**
  String get drawerWidthSetting_4521;

  /// No description provided for @drawerWidth_4271.
  ///
  /// In zh, this message translates to:
  /// **'抽屉宽度'**
  String get drawerWidth_4271;

  /// No description provided for @drawingAreaHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'可在此区域绘制'**
  String get drawingAreaHint_4821;

  /// No description provided for @drawingElementDeleted_7281.
  ///
  /// In zh, this message translates to:
  /// **'已删除绘制元素'**
  String get drawingElementDeleted_7281;

  /// No description provided for @drawingLayer_4821.
  ///
  /// In zh, this message translates to:
  /// **'绘制图层'**
  String get drawingLayer_4821;

  /// No description provided for @drawingPanel_1234.
  ///
  /// In zh, this message translates to:
  /// **'绘图面板'**
  String get drawingPanel_1234;

  /// No description provided for @drawingToolDisabled_4287.
  ///
  /// In zh, this message translates to:
  /// **'绘制工具已禁用'**
  String get drawingToolDisabled_4287;

  /// No description provided for @drawingToolManagerCallbackNotSet_4821.
  ///
  /// In zh, this message translates to:
  /// **'DrawingToolManager: addDrawingElement回调未设置或目标图层ID为空，无法添加元素'**
  String get drawingToolManagerCallbackNotSet_4821;

  /// No description provided for @drawingToolsTitle_4722.
  ///
  /// In zh, this message translates to:
  /// **'绘制工具'**
  String get drawingToolsTitle_4722;

  /// No description provided for @drawingTools_4821.
  ///
  /// In zh, this message translates to:
  /// **'绘图工具'**
  String get drawingTools_4821;

  /// No description provided for @duplicateExportName_4962.
  ///
  /// In zh, this message translates to:
  /// **'导出名称重复'**
  String get duplicateExportName_4962;

  /// No description provided for @duplicateItemExists_7281.
  ///
  /// In zh, this message translates to:
  /// **'目标位置已存在同名{item}:'**
  String duplicateItemExists_7281(Object item);

  /// No description provided for @duplicateLayer_4821.
  ///
  /// In zh, this message translates to:
  /// **'复制图层'**
  String get duplicateLayer_4821;

  /// No description provided for @duplicateMapTitle.
  ///
  /// In zh, this message translates to:
  /// **'地图标题 \"{newTitle}\" 已存在'**
  String duplicateMapTitle(Object newTitle);

  /// No description provided for @duplicateShortcutWarning.
  ///
  /// In zh, this message translates to:
  /// **'快捷键重复: {shortcut} 已在当前列表中'**
  String duplicateShortcutWarning(Object shortcut);

  /// No description provided for @duplicateShortcutsWarning_7421.
  ///
  /// In zh, this message translates to:
  /// **'列表中存在重复快捷键: {duplicates}'**
  String duplicateShortcutsWarning_7421(Object duplicates);

  /// No description provided for @durationLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'时长'**
  String get durationLabel_4821;

  /// No description provided for @dutchNL_4841.
  ///
  /// In zh, this message translates to:
  /// **'荷兰语 (荷兰)'**
  String get dutchNL_4841;

  /// No description provided for @dutch_4840.
  ///
  /// In zh, this message translates to:
  /// **'荷兰语'**
  String get dutch_4840;

  /// No description provided for @dynamicBufferMultiplierInfo.
  ///
  /// In zh, this message translates to:
  /// **'   - 动态缓冲区倍数: {multiplier}x (智能计算)'**
  String dynamicBufferMultiplierInfo(Object multiplier);

  /// No description provided for @dynamicFormulaLegendSizeCalculation.
  ///
  /// In zh, this message translates to:
  /// **'使用动态公式计算图例大小: zoomFactor={zoomFactor}, currentZoom={currentZoomLevel}, legendSize={legendSize}'**
  String dynamicFormulaLegendSizeCalculation(
    Object currentZoomLevel,
    Object legendSize,
    Object zoomFactor,
  );

  /// No description provided for @dynamicFormulaText_7281.
  ///
  /// In zh, this message translates to:
  /// **'使用动态公式：1/(缩放*系数)'**
  String get dynamicFormulaText_7281;

  /// No description provided for @dynamicSize_4821.
  ///
  /// In zh, this message translates to:
  /// **'动态大小'**
  String get dynamicSize_4821;

  /// No description provided for @editAuthAccount_5421.
  ///
  /// In zh, this message translates to:
  /// **'编辑认证账户'**
  String get editAuthAccount_5421;

  /// No description provided for @editButton_7281.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get editButton_7281;

  /// No description provided for @editConflict_4827.
  ///
  /// In zh, this message translates to:
  /// **'编辑冲突'**
  String get editConflict_4827;

  /// No description provided for @editDensity_4271.
  ///
  /// In zh, this message translates to:
  /// **'编辑密度'**
  String get editDensity_4271;

  /// No description provided for @editFontSize_4821.
  ///
  /// In zh, this message translates to:
  /// **'编辑字体大小'**
  String get editFontSize_4821;

  /// No description provided for @editImageTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑图片 {index}'**
  String editImageTitle(Object index);

  /// No description provided for @editItemMessage_4821.
  ///
  /// In zh, this message translates to:
  /// **'编辑项目 {itemNumber}'**
  String editItemMessage_4821(Object itemNumber);

  /// No description provided for @editItemMessage_5421.
  ///
  /// In zh, this message translates to:
  /// **'编辑 {item}'**
  String editItemMessage_5421(Object item);

  /// No description provided for @editJson_7281.
  ///
  /// In zh, this message translates to:
  /// **'编辑JSON'**
  String get editJson_7281;

  /// No description provided for @editLabel_4271.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get editLabel_4271;

  /// No description provided for @editLabel_4521.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get editLabel_4521;

  /// No description provided for @editLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get editLabel_4821;

  /// No description provided for @editLabel_5421.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get editLabel_5421;

  /// No description provided for @editLegendGroupName_4271.
  ///
  /// In zh, this message translates to:
  /// **'编辑图例组名称'**
  String get editLegendGroupName_4271;

  /// No description provided for @editLegendGroup_4271.
  ///
  /// In zh, this message translates to:
  /// **'编辑图例组'**
  String get editLegendGroup_4271;

  /// No description provided for @editLegend_4271.
  ///
  /// In zh, this message translates to:
  /// **'编辑图例'**
  String get editLegend_4271;

  /// No description provided for @editMode_4821.
  ///
  /// In zh, this message translates to:
  /// **'编辑模式'**
  String get editMode_4821;

  /// No description provided for @editMode_5421.
  ///
  /// In zh, this message translates to:
  /// **'编辑模式'**
  String get editMode_5421;

  /// No description provided for @editNameTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'编辑名称'**
  String get editNameTooltip_7281;

  /// No description provided for @editNoteDebug.
  ///
  /// In zh, this message translates to:
  /// **'编辑便签: {id}'**
  String editNoteDebug(Object id);

  /// No description provided for @editNote_4271.
  ///
  /// In zh, this message translates to:
  /// **'编辑便签'**
  String get editNote_4271;

  /// No description provided for @editRadial_7421.
  ///
  /// In zh, this message translates to:
  /// **'编辑弧度'**
  String get editRadial_7421;

  /// No description provided for @editRotationAngle_4271.
  ///
  /// In zh, this message translates to:
  /// **'编辑旋转角度'**
  String get editRotationAngle_4271;

  /// No description provided for @editScriptParams.
  ///
  /// In zh, this message translates to:
  /// **'编辑脚本参数'**
  String get editScriptParams;

  /// No description provided for @editScriptParamsFailed.
  ///
  /// In zh, this message translates to:
  /// **'编辑脚本参数失败: {e}'**
  String editScriptParamsFailed(Object e);

  /// No description provided for @editScriptTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑脚本: {scriptName}'**
  String editScriptTitle(Object scriptName);

  /// No description provided for @editShortcutTooltip_4821.
  ///
  /// In zh, this message translates to:
  /// **'编辑快捷键'**
  String get editShortcutTooltip_4821;

  /// No description provided for @editShortcuts_7421.
  ///
  /// In zh, this message translates to:
  /// **'编辑快捷键'**
  String get editShortcuts_7421;

  /// No description provided for @editStrokeWidth_4271.
  ///
  /// In zh, this message translates to:
  /// **'编辑描边宽度'**
  String get editStrokeWidth_4271;

  /// No description provided for @editTextContent_4821.
  ///
  /// In zh, this message translates to:
  /// **'编辑文本内容'**
  String get editTextContent_4821;

  /// No description provided for @editUserInfo_4821.
  ///
  /// In zh, this message translates to:
  /// **'编辑用户信息'**
  String get editUserInfo_4821;

  /// No description provided for @editWebDavConfig.
  ///
  /// In zh, this message translates to:
  /// **'编辑 WebDAV 配置'**
  String get editWebDavConfig;

  /// No description provided for @editZIndexTitle_7281.
  ///
  /// In zh, this message translates to:
  /// **'编辑Z层级'**
  String get editZIndexTitle_7281;

  /// No description provided for @edit_7281.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit_7281;

  /// No description provided for @editingLabel_7421.
  ///
  /// In zh, this message translates to:
  /// **'正在编辑:'**
  String get editingLabel_7421;

  /// No description provided for @editingMapTitle.
  ///
  /// In zh, this message translates to:
  /// **'正在编辑: {currentMapTitle}'**
  String editingMapTitle(Object currentMapTitle);

  /// No description provided for @editingStatus_4821.
  ///
  /// In zh, this message translates to:
  /// **'编辑中'**
  String get editingStatus_4821;

  /// No description provided for @editingStatus_7154.
  ///
  /// In zh, this message translates to:
  /// **'编辑中'**
  String get editingStatus_7154;

  /// No description provided for @editingVersion_7421.
  ///
  /// In zh, this message translates to:
  /// **'编辑中: {versionId}'**
  String editingVersion_7421(Object versionId);

  /// No description provided for @editorStatus_4521.
  ///
  /// In zh, this message translates to:
  /// **'编辑器状态'**
  String get editorStatus_4521;

  /// No description provided for @elementCount.
  ///
  /// In zh, this message translates to:
  /// **'元素: {count}'**
  String elementCount(Object count);

  /// No description provided for @elementDebugInfo_7428.
  ///
  /// In zh, this message translates to:
  /// **'元素[{i}]: 类型={typeName}, imageData={imageData}'**
  String elementDebugInfo_7428(Object i, Object imageData, Object typeName);

  /// No description provided for @elementListWithCount.
  ///
  /// In zh, this message translates to:
  /// **'元素列表 ({count})'**
  String elementListWithCount(Object count);

  /// No description provided for @elementLockConflict_4821.
  ///
  /// In zh, this message translates to:
  /// **'元素锁定冲突'**
  String get elementLockConflict_4821;

  /// No description provided for @elementLockFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'元素锁定失败'**
  String get elementLockFailed_7281;

  /// No description provided for @elementLockReleased_7425.
  ///
  /// In zh, this message translates to:
  /// **'元素锁定已释放'**
  String get elementLockReleased_7425;

  /// No description provided for @elementLockedSuccessfully_7281.
  ///
  /// In zh, this message translates to:
  /// **'[CollaborationStateManager] 元素锁定成功: {elementId} by {currentUserId}'**
  String elementLockedSuccessfully_7281(Object currentUserId, Object elementId);

  /// No description provided for @elementNotFound_4821.
  ///
  /// In zh, this message translates to:
  /// **'未找到元素 {elementId}'**
  String elementNotFound_4821(Object elementId);

  /// No description provided for @element_3141.
  ///
  /// In zh, this message translates to:
  /// **'元素'**
  String get element_3141;

  /// No description provided for @elements.
  ///
  /// In zh, this message translates to:
  /// **'个元素'**
  String elements(Object elements);

  /// No description provided for @elements_3343.
  ///
  /// In zh, this message translates to:
  /// **'个元素'**
  String elements_3343(Object elementsCount);

  /// No description provided for @elements_7383.
  ///
  /// In zh, this message translates to:
  /// **'个元素'**
  String elements_7383(Object elementsCount);

  /// No description provided for @elevator_4823.
  ///
  /// In zh, this message translates to:
  /// **'电梯'**
  String get elevator_4823;

  /// No description provided for @embeddedModeDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'纯渲染组件，可嵌入任何布局'**
  String get embeddedModeDescription_4821;

  /// No description provided for @embeddedModeTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'3. 嵌入模式'**
  String get embeddedModeTitle_4821;

  /// No description provided for @emptyDirectory_7281.
  ///
  /// In zh, this message translates to:
  /// **'当前目录为空'**
  String get emptyDirectory_7281;

  /// No description provided for @emptyFolderDescription_4827.
  ///
  /// In zh, this message translates to:
  /// **'此文件夹中还没有地图'**
  String get emptyFolderDescription_4827;

  /// No description provided for @emptyFolderMessage_4826.
  ///
  /// In zh, this message translates to:
  /// **'此文件夹为空'**
  String get emptyFolderMessage_4826;

  /// No description provided for @emptyLayerSkipped_7281.
  ///
  /// In zh, this message translates to:
  /// **'图层为空，跳过'**
  String get emptyLayerSkipped_7281;

  /// No description provided for @emptyNote_4251.
  ///
  /// In zh, this message translates to:
  /// **'空便签'**
  String get emptyNote_4251;

  /// No description provided for @emptyNotesMessage_7421.
  ///
  /// In zh, this message translates to:
  /// **'暂无便签\n点击上方按钮添加新便签'**
  String get emptyNotesMessage_7421;

  /// No description provided for @enableAnimation_7281.
  ///
  /// In zh, this message translates to:
  /// **'启用动画'**
  String get enableAnimation_7281;

  /// No description provided for @enableAnimations.
  ///
  /// In zh, this message translates to:
  /// **'启用动画'**
  String get enableAnimations;

  /// No description provided for @enableAudioRendering_4821.
  ///
  /// In zh, this message translates to:
  /// **'启用音频渲染'**
  String get enableAudioRendering_4821;

  /// No description provided for @enableAutoPlay_5421.
  ///
  /// In zh, this message translates to:
  /// **'开启自动播放'**
  String get enableAutoPlay_5421;

  /// No description provided for @enableConfiguration_4271.
  ///
  /// In zh, this message translates to:
  /// **'启用配置'**
  String get enableConfiguration_4271;

  /// No description provided for @enableCrosshair_42.
  ///
  /// In zh, this message translates to:
  /// **'开启十字线'**
  String get enableCrosshair_42;

  /// No description provided for @enableEditing_5421.
  ///
  /// In zh, this message translates to:
  /// **'启用编辑'**
  String get enableEditing_5421;

  /// No description provided for @enableHtmlRendering_5832.
  ///
  /// In zh, this message translates to:
  /// **'启用HTML渲染'**
  String get enableHtmlRendering_5832;

  /// No description provided for @enableLatexRendering_4822.
  ///
  /// In zh, this message translates to:
  /// **'启用LaTeX渲染'**
  String get enableLatexRendering_4822;

  /// No description provided for @enableLayerLinkingToMaintainGroupIntegrity.
  ///
  /// In zh, this message translates to:
  /// **'开启图层链接以保持组完整性: {name}'**
  String enableLayerLinkingToMaintainGroupIntegrity(Object name);

  /// No description provided for @enableLoopPlayback_7282.
  ///
  /// In zh, this message translates to:
  /// **'开启循环播放'**
  String get enableLoopPlayback_7282;

  /// No description provided for @enableMobileLayerLink_7421.
  ///
  /// In zh, this message translates to:
  /// **'开启移动图层的链接: {name}'**
  String enableMobileLayerLink_7421(Object name);

  /// No description provided for @enableSpeechSynthesis_4271.
  ///
  /// In zh, this message translates to:
  /// **'启用语音合成'**
  String get enableSpeechSynthesis_4271;

  /// No description provided for @enableThemeColorFilter_7281.
  ///
  /// In zh, this message translates to:
  /// **'启用主题颜色滤镜'**
  String get enableThemeColorFilter_7281;

  /// No description provided for @enableVideoRendering_4822.
  ///
  /// In zh, this message translates to:
  /// **'启用视频渲染'**
  String get enableVideoRendering_4822;

  /// No description provided for @enableVoiceReadingFeature_4821.
  ///
  /// In zh, this message translates to:
  /// **'开启后将支持语音朗读功能'**
  String get enableVoiceReadingFeature_4821;

  /// No description provided for @enable_4821.
  ///
  /// In zh, this message translates to:
  /// **'启用'**
  String get enable_4821;

  /// No description provided for @enable_7532.
  ///
  /// In zh, this message translates to:
  /// **'启用'**
  String get enable_7532;

  /// No description provided for @enabledStatus_4821.
  ///
  /// In zh, this message translates to:
  /// **'已启用'**
  String get enabledStatus_4821;

  /// No description provided for @enabled_4821.
  ///
  /// In zh, this message translates to:
  /// **'已启用'**
  String get enabled_4821;

  /// No description provided for @englishAU_4896.
  ///
  /// In zh, this message translates to:
  /// **'英语 (澳大利亚)'**
  String get englishAU_4896;

  /// No description provided for @englishCA_4897.
  ///
  /// In zh, this message translates to:
  /// **'英语 (加拿大)'**
  String get englishCA_4897;

  /// No description provided for @englishIN_4898.
  ///
  /// In zh, this message translates to:
  /// **'英语 (印度)'**
  String get englishIN_4898;

  /// No description provided for @englishLanguage_4821.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get englishLanguage_4821;

  /// No description provided for @englishUK_4826.
  ///
  /// In zh, this message translates to:
  /// **'英语 (英国)'**
  String get englishUK_4826;

  /// No description provided for @englishUS_4825.
  ///
  /// In zh, this message translates to:
  /// **'英语 (美国)'**
  String get englishUS_4825;

  /// No description provided for @english_4824.
  ///
  /// In zh, this message translates to:
  /// **'英语'**
  String get english_4824;

  /// No description provided for @ensureValidExportPaths_4821.
  ///
  /// In zh, this message translates to:
  /// **'请确保所有导出项都有有效的源路径和导出名称'**
  String get ensureValidExportPaths_4821;

  /// No description provided for @enterActiveMap.
  ///
  /// In zh, this message translates to:
  /// **'进入活跃地图: {mapTitle}'**
  String enterActiveMap(Object mapTitle);

  /// No description provided for @enterAuthorName_4938.
  ///
  /// In zh, this message translates to:
  /// **'输入作者名称'**
  String get enterAuthorName_4938;

  /// No description provided for @enterConfigurationDescriptionHint_4522.
  ///
  /// In zh, this message translates to:
  /// **'请输入配置描述（可选）'**
  String get enterConfigurationDescriptionHint_4522;

  /// No description provided for @enterConfigurationName_5732.
  ///
  /// In zh, this message translates to:
  /// **'请输入配置名称'**
  String get enterConfigurationName_5732;

  /// No description provided for @enterDisplayName_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入显示名称'**
  String get enterDisplayName_4821;

  /// No description provided for @enterExportName_4960.
  ///
  /// In zh, this message translates to:
  /// **'输入导出名称'**
  String get enterExportName_4960;

  /// No description provided for @enterFieldName_4945.
  ///
  /// In zh, this message translates to:
  /// **'输入字段名'**
  String get enterFieldName_4945;

  /// No description provided for @enterFieldValue_4947.
  ///
  /// In zh, this message translates to:
  /// **'输入字段值'**
  String get enterFieldValue_4947;

  /// No description provided for @enterFileName_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入文件名'**
  String get enterFileName_4821;

  /// No description provided for @enterFolderName_4831.
  ///
  /// In zh, this message translates to:
  /// **'请输入文件夹名称'**
  String get enterFolderName_4831;

  /// No description provided for @enterFullscreen_4821.
  ///
  /// In zh, this message translates to:
  /// **'全屏'**
  String get enterFullscreen_4821;

  /// No description provided for @enterFullscreen_4822.
  ///
  /// In zh, this message translates to:
  /// **'全屏'**
  String get enterFullscreen_4822;

  /// No description provided for @enterFullscreen_5832.
  ///
  /// In zh, this message translates to:
  /// **'全屏'**
  String get enterFullscreen_5832;

  /// No description provided for @enterImmediately_4821.
  ///
  /// In zh, this message translates to:
  /// **'立即进入'**
  String get enterImmediately_4821;

  /// No description provided for @enterLegendTitle.
  ///
  /// In zh, this message translates to:
  /// **'请输入图例标题'**
  String get enterLegendTitle;

  /// No description provided for @enterMapTitle.
  ///
  /// In zh, this message translates to:
  /// **'请输入地图标题'**
  String get enterMapTitle;

  /// No description provided for @enterMapVersion_4822.
  ///
  /// In zh, this message translates to:
  /// **'输入地图版本号'**
  String get enterMapVersion_4822;

  /// No description provided for @enterNumberHint_4521.
  ///
  /// In zh, this message translates to:
  /// **'请输入数字'**
  String get enterNumberHint_4521;

  /// No description provided for @enterPassword_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get enterPassword_4821;

  /// No description provided for @enterResourcePackName_4934.
  ///
  /// In zh, this message translates to:
  /// **'输入资源包名称'**
  String get enterResourcePackName_4934;

  /// No description provided for @enterScriptName_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入脚本名称'**
  String get enterScriptName_4821;

  /// No description provided for @enterSubMenuAfterDelay_4721.
  ///
  /// In zh, this message translates to:
  /// **'鼠标停止移动{delay}ms后进入子菜单'**
  String enterSubMenuAfterDelay_4721(Object delay);

  /// No description provided for @enterSubMenuImmediately_4721.
  ///
  /// In zh, this message translates to:
  /// **'立即进入子菜单'**
  String get enterSubMenuImmediately_4721;

  /// No description provided for @enterSubMenuNow_7421.
  ///
  /// In zh, this message translates to:
  /// **'立即进入子菜单: {label}'**
  String enterSubMenuNow_7421(Object label);

  /// No description provided for @enterTimerName_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入计时器名称'**
  String get enterTimerName_4821;

  /// No description provided for @enterValidUrl_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的URL'**
  String get enterValidUrl_4821;

  /// No description provided for @enterWebApiKey_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入 Web API Key'**
  String get enterWebApiKey_4821;

  /// No description provided for @enteredMapEditorMode.
  ///
  /// In zh, this message translates to:
  /// **'已进入地图编辑器协作模式: {title}'**
  String enteredMapEditorMode(Object title);

  /// No description provided for @entrance_4821.
  ///
  /// In zh, this message translates to:
  /// **'入口'**
  String get entrance_4821;

  /// No description provided for @entrance_4823.
  ///
  /// In zh, this message translates to:
  /// **'入口'**
  String get entrance_4823;

  /// No description provided for @enumType_7890.
  ///
  /// In zh, this message translates to:
  /// **'选择'**
  String get enumType_7890;

  /// No description provided for @eraserItem_4821.
  ///
  /// In zh, this message translates to:
  /// **'橡皮擦'**
  String get eraserItem_4821;

  /// No description provided for @eraserLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'橡皮擦'**
  String get eraserLabel_4821;

  /// No description provided for @eraserTool_3478.
  ///
  /// In zh, this message translates to:
  /// **'橡皮擦'**
  String get eraserTool_3478;

  /// No description provided for @eraserTool_4821.
  ///
  /// In zh, this message translates to:
  /// **'橡皮擦'**
  String get eraserTool_4821;

  /// No description provided for @eraserTooltip_4822.
  ///
  /// In zh, this message translates to:
  /// **'擦除元素'**
  String get eraserTooltip_4822;

  /// No description provided for @eraser_4291.
  ///
  /// In zh, this message translates to:
  /// **'橡皮擦'**
  String get eraser_4291;

  /// No description provided for @eraser_4829.
  ///
  /// In zh, this message translates to:
  /// **'橡皮擦'**
  String get eraser_4829;

  /// No description provided for @eraser_4831.
  ///
  /// In zh, this message translates to:
  /// **'橡皮擦'**
  String get eraser_4831;

  /// No description provided for @error.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get error;

  /// No description provided for @errorLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get errorLabel_4821;

  /// No description provided for @errorLog_7421.
  ///
  /// In zh, this message translates to:
  /// **'错误: {error}'**
  String errorLog_7421(Object error);

  /// No description provided for @errorMessage.
  ///
  /// In zh, this message translates to:
  /// **'错误: {error}'**
  String errorMessage(Object error);

  /// No description provided for @errorMessage_4821.
  ///
  /// In zh, this message translates to:
  /// **'错误: {error}'**
  String errorMessage_4821(Object error);

  /// No description provided for @error_4821.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get error_4821;

  /// No description provided for @error_5016.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get error_5016;

  /// No description provided for @error_5732.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get error_5732;

  /// No description provided for @error_8956.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get error_8956;

  /// No description provided for @error_9376.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get error_9376;

  /// No description provided for @estonianEE_4867.
  ///
  /// In zh, this message translates to:
  /// **'爱沙尼亚语 (爱沙尼亚)'**
  String get estonianEE_4867;

  /// No description provided for @estonian_4866.
  ///
  /// In zh, this message translates to:
  /// **'爱沙尼亚语'**
  String get estonian_4866;

  /// No description provided for @example3ListItemMenu_7421.
  ///
  /// In zh, this message translates to:
  /// **'示例3：列表项菜单'**
  String get example3ListItemMenu_7421;

  /// No description provided for @exampleInputField_4521.
  ///
  /// In zh, this message translates to:
  /// **'示例输入框'**
  String get exampleInputField_4521;

  /// No description provided for @exampleLibrary_7421.
  ///
  /// In zh, this message translates to:
  /// **'图例库'**
  String get exampleLibrary_7421;

  /// No description provided for @exampleMyCloud_4822.
  ///
  /// In zh, this message translates to:
  /// **'例如：我的云盘'**
  String get exampleMyCloud_4822;

  /// No description provided for @exampleRightClickMenu_4821.
  ///
  /// In zh, this message translates to:
  /// **'示例1：简单右键菜单'**
  String get exampleRightClickMenu_4821;

  /// No description provided for @exampleTag_4825.
  ///
  /// In zh, this message translates to:
  /// **'示例'**
  String get exampleTag_4825;

  /// No description provided for @excludedListSkipped_7285.
  ///
  /// In zh, this message translates to:
  /// **'排除列表跳过: 路径=\"{path}\"'**
  String excludedListSkipped_7285(Object path);

  /// No description provided for @executeAction_7421.
  ///
  /// In zh, this message translates to:
  /// **'执行'**
  String get executeAction_7421;

  /// No description provided for @executePermission_4821.
  ///
  /// In zh, this message translates to:
  /// **'执行'**
  String get executePermission_4821;

  /// No description provided for @executeScript_4821.
  ///
  /// In zh, this message translates to:
  /// **'执行脚本'**
  String get executeScript_4821;

  /// No description provided for @executing_7421.
  ///
  /// In zh, this message translates to:
  /// **'执行中...'**
  String get executing_7421;

  /// No description provided for @executionEngine_4521.
  ///
  /// In zh, this message translates to:
  /// **'执行引擎'**
  String get executionEngine_4521;

  /// No description provided for @executionEngine_4821.
  ///
  /// In zh, this message translates to:
  /// **'执行引擎'**
  String get executionEngine_4821;

  /// No description provided for @executionFailed_5421.
  ///
  /// In zh, this message translates to:
  /// **'执行失败'**
  String get executionFailed_5421;

  /// No description provided for @executionFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'执行失败'**
  String get executionFailed_7281;

  /// No description provided for @executionSuccessWithTime.
  ///
  /// In zh, this message translates to:
  /// **'执行成功 ({time}ms)'**
  String executionSuccessWithTime(Object time);

  /// No description provided for @executionSuccess_5421.
  ///
  /// In zh, this message translates to:
  /// **'执行成功'**
  String get executionSuccess_5421;

  /// No description provided for @exitConfirmationCheck.
  ///
  /// In zh, this message translates to:
  /// **'退出确认检查: _hasUnsavedChanges={first}, hasUnsavedVersions={second}'**
  String exitConfirmationCheck(Object first, Object second);

  /// No description provided for @exitFullscreen_4721.
  ///
  /// In zh, this message translates to:
  /// **'退出全屏'**
  String get exitFullscreen_4721;

  /// No description provided for @exitFullscreen_4821.
  ///
  /// In zh, this message translates to:
  /// **'退出全屏'**
  String get exitFullscreen_4821;

  /// No description provided for @exitWithoutSaving_7281.
  ///
  /// In zh, this message translates to:
  /// **'不保存退出'**
  String get exitWithoutSaving_7281;

  /// No description provided for @expandNote_5421.
  ///
  /// In zh, this message translates to:
  /// **'展开便签'**
  String get expandNote_5421;

  /// No description provided for @expandPlayer_7281.
  ///
  /// In zh, this message translates to:
  /// **'展开播放器'**
  String get expandPlayer_7281;

  /// No description provided for @expand_4821.
  ///
  /// In zh, this message translates to:
  /// **'展开'**
  String get expand_4821;

  /// No description provided for @expandedState_5421.
  ///
  /// In zh, this message translates to:
  /// **'展开'**
  String get expandedState_5421;

  /// No description provided for @expiredDataCleaned_7281.
  ///
  /// In zh, this message translates to:
  /// **'过期数据清理完成'**
  String get expiredDataCleaned_7281;

  /// No description provided for @expiredLocksCleaned_4821.
  ///
  /// In zh, this message translates to:
  /// **'已清理 {count} 个过期锁定'**
  String expiredLocksCleaned_4821(Object count);

  /// No description provided for @exportAsPdf_7281.
  ///
  /// In zh, this message translates to:
  /// **'导出为PDF'**
  String get exportAsPdf_7281;

  /// No description provided for @exportBoundaryNotFound_7281.
  ///
  /// In zh, this message translates to:
  /// **'导出边界未找到'**
  String get exportBoundaryNotFound_7281;

  /// No description provided for @exportClientConfigFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出客户端配置失败: {e}'**
  String exportClientConfigFailed(Object e);

  /// No description provided for @exportConfigFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'导出配置失败: {error}'**
  String exportConfigFailed_7421(Object error);

  /// No description provided for @exportConfig_7281.
  ///
  /// In zh, this message translates to:
  /// **'导出配置'**
  String get exportConfig_7281;

  /// No description provided for @exportDatabase.
  ///
  /// In zh, this message translates to:
  /// **'导出数据库'**
  String get exportDatabase;

  /// No description provided for @exportDatabaseDialogTitle_4721.
  ///
  /// In zh, this message translates to:
  /// **'导出R6Box数据库 (Web平台专用)'**
  String get exportDatabaseDialogTitle_4721;

  /// No description provided for @exportDatabaseFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'导出数据库失败: {e}'**
  String exportDatabaseFailed_7421(Object e);

  /// No description provided for @exportDescription_4953.
  ///
  /// In zh, this message translates to:
  /// **'选择要导出的文件或文件夹，并为它们指定导出名称。系统将创建一个包含所选资源和元数据的ZIP文件。'**
  String get exportDescription_4953;

  /// No description provided for @exportExternalResources_4952.
  ///
  /// In zh, this message translates to:
  /// **'导出外部资源'**
  String get exportExternalResources_4952;

  /// No description provided for @exportFailedRetry_4821.
  ///
  /// In zh, this message translates to:
  /// **'导出失败，请重试'**
  String get exportFailedRetry_4821;

  /// No description provided for @exportFailed_5011.
  ///
  /// In zh, this message translates to:
  /// **'导出失败'**
  String get exportFailed_5011;

  /// No description provided for @exportFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'导出失败: {e}'**
  String exportFailed_7284(Object e);

  /// No description provided for @exportFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'导出失败: {e}'**
  String exportFailed_7285(Object e);

  /// No description provided for @exportFileInfoFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取导出文件信息失败: {e}'**
  String exportFileInfoFailed(Object e);

  /// No description provided for @exportFileNotExist_7285.
  ///
  /// In zh, this message translates to:
  /// **'导出文件不存在: {filePath}'**
  String exportFileNotExist_7285(Object filePath);

  /// No description provided for @exportFileValidationPassed.
  ///
  /// In zh, this message translates to:
  /// **'导出文件验证通过: {filePath}'**
  String exportFileValidationPassed(Object filePath);

  /// No description provided for @exportGroupFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'导出组失败: {e}'**
  String exportGroupFailed_7285(Object e);

  /// No description provided for @exportImageFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'导出图片失败: {e}'**
  String exportImageFailed_7421(Object e);

  /// No description provided for @exportImageTitle_7421.
  ///
  /// In zh, this message translates to:
  /// **'导出图片 {index}'**
  String exportImageTitle_7421(Object index);

  /// No description provided for @exportImage_7421.
  ///
  /// In zh, this message translates to:
  /// **'导出图片'**
  String get exportImage_7421;

  /// No description provided for @exportInfoTitle_4728.
  ///
  /// In zh, this message translates to:
  /// **'导出信息'**
  String get exportInfoTitle_4728;

  /// No description provided for @exportLabel_7421.
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get exportLabel_7421;

  /// No description provided for @exportLayerAsPng_7281.
  ///
  /// In zh, this message translates to:
  /// **'导出图层为PNG'**
  String get exportLayerAsPng_7281;

  /// No description provided for @exportLayerFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'导出图层失败: {e}'**
  String exportLayerFailed_7421(Object e);

  /// No description provided for @exportLayerSuccess.
  ///
  /// In zh, this message translates to:
  /// **'导出图层: {name}'**
  String exportLayerSuccess(Object name);

  /// No description provided for @exportLayer_7421.
  ///
  /// In zh, this message translates to:
  /// **'导出图层'**
  String get exportLayer_7421;

  /// No description provided for @exportLegendDatabaseTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'导出图例数据库'**
  String get exportLegendDatabaseTitle_4821;

  /// No description provided for @exportLegendDatabase_4821.
  ///
  /// In zh, this message translates to:
  /// **'导出图例数据库'**
  String get exportLegendDatabase_4821;

  /// No description provided for @exportLegendFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'导出图例数据库失败: {e}'**
  String exportLegendFailed_7285(Object e);

  /// No description provided for @exportList_7281.
  ///
  /// In zh, this message translates to:
  /// **'导出列表'**
  String get exportList_7281;

  /// No description provided for @exportLocalDbFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出本地化数据库失败: {e}'**
  String exportLocalDbFailed(Object e);

  /// No description provided for @exportMapFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'导出地图包失败: {e}'**
  String exportMapFailed_7285(Object e);

  /// No description provided for @exportMapLocalizationFileTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'导出地图本地化文件'**
  String get exportMapLocalizationFileTitle_4821;

  /// No description provided for @exportName_4955.
  ///
  /// In zh, this message translates to:
  /// **'导出名称'**
  String get exportName_4955;

  /// No description provided for @exportPdf_5678.
  ///
  /// In zh, this message translates to:
  /// **'导出PDF'**
  String get exportPdf_5678;

  /// No description provided for @exportPdf_7281.
  ///
  /// In zh, this message translates to:
  /// **'导出PDF'**
  String get exportPdf_7281;

  /// No description provided for @exportPreview_4821.
  ///
  /// In zh, this message translates to:
  /// **'导出预览'**
  String get exportPreview_4821;

  /// No description provided for @exportSettings.
  ///
  /// In zh, this message translates to:
  /// **'导出设置'**
  String get exportSettings;

  /// No description provided for @exportSettingsFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'导出设置失败: {error}'**
  String exportSettingsFailed_7421(Object error);

  /// No description provided for @exportSuccessMessage.
  ///
  /// In zh, this message translates to:
  /// **'成功导出地图数据到: {exportPath}'**
  String exportSuccessMessage(Object exportPath);

  /// No description provided for @exportSuccess_5010.
  ///
  /// In zh, this message translates to:
  /// **'导出成功！'**
  String get exportSuccess_5010;

  /// No description provided for @exportToFolder_4967.
  ///
  /// In zh, this message translates to:
  /// **'导出到文件夹'**
  String get exportToFolder_4967;

  /// No description provided for @exportValidationFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'验证导出文件失败: {e}'**
  String exportValidationFailed_4821(Object e);

  /// No description provided for @exportVersion_9234.
  ///
  /// In zh, this message translates to:
  /// **'导出版本'**
  String get exportVersion_9234;

  /// No description provided for @exportingImage_7421.
  ///
  /// In zh, this message translates to:
  /// **'正在导出图片...'**
  String get exportingImage_7421;

  /// No description provided for @exportingVfsMapDatabase_7281.
  ///
  /// In zh, this message translates to:
  /// **'开始导出VFS地图数据库...'**
  String get exportingVfsMapDatabase_7281;

  /// No description provided for @exporting_4965.
  ///
  /// In zh, this message translates to:
  /// **'导出中...'**
  String get exporting_4965;

  /// No description provided for @exporting_7421.
  ///
  /// In zh, this message translates to:
  /// **'正在导出'**
  String get exporting_7421;

  /// No description provided for @extendedSettingsStorage_4821.
  ///
  /// In zh, this message translates to:
  /// **'扩展设置存储'**
  String get extendedSettingsStorage_4821;

  /// No description provided for @extensionManagerInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'扩展设置管理器已初始化'**
  String get extensionManagerInitialized_7281;

  /// No description provided for @extensionManagerNotInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'扩展设置管理器未初始化'**
  String get extensionManagerNotInitialized_7281;

  /// No description provided for @extensionMethodsDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'使用BuildContext扩展方法快速创建浮动窗口'**
  String get extensionMethodsDescription_4821;

  /// No description provided for @extensionMethodsTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'扩展方法'**
  String get extensionMethodsTitle_4821;

  /// No description provided for @extensionSettingsClearedMapLegendZoom_7421.
  ///
  /// In zh, this message translates to:
  /// **'扩展设置: 已清除地图 {mapId} 的所有图例组缩放因子设置'**
  String extensionSettingsClearedMapLegendZoom_7421(Object mapId);

  /// No description provided for @extensionSettingsCleared_4821.
  ///
  /// In zh, this message translates to:
  /// **'扩展设置已清空'**
  String get extensionSettingsCleared_4821;

  /// No description provided for @extensionSettingsSaved_4821.
  ///
  /// In zh, this message translates to:
  /// **'扩展设置已保存'**
  String get extensionSettingsSaved_4821;

  /// No description provided for @extensionStorageDisabled_4821.
  ///
  /// In zh, this message translates to:
  /// **'扩展设置存储已禁用'**
  String get extensionStorageDisabled_4821;

  /// No description provided for @extensionWindowTitle_7281.
  ///
  /// In zh, this message translates to:
  /// **'扩展方法窗口'**
  String get extensionWindowTitle_7281;

  /// No description provided for @externalFunctionError_4821.
  ///
  /// In zh, this message translates to:
  /// **'外部函数 {functionName} 执行出错: {error}'**
  String externalFunctionError_4821(Object error, Object functionName);

  /// No description provided for @externalFunctionsRegisteredToIsolateExecutor_7281.
  ///
  /// In zh, this message translates to:
  /// **'已注册所有外部函数到Isolate执行器'**
  String get externalFunctionsRegisteredToIsolateExecutor_7281;

  /// No description provided for @externalResourceManagement_7421.
  ///
  /// In zh, this message translates to:
  /// **'外部资源管理'**
  String get externalResourceManagement_7421;

  /// No description provided for @externalResourcesManagement_4821.
  ///
  /// In zh, this message translates to:
  /// **'外部资源管理'**
  String get externalResourcesManagement_4821;

  /// No description provided for @externalResourcesUpdateSuccess_4924.
  ///
  /// In zh, this message translates to:
  /// **'外部资源更新成功'**
  String get externalResourcesUpdateSuccess_4924;

  /// No description provided for @extractTo_4821.
  ///
  /// In zh, this message translates to:
  /// **'解压到...'**
  String get extractTo_4821;

  /// No description provided for @extractingFilesToTempDir_4990.
  ///
  /// In zh, this message translates to:
  /// **'正在提取文件到临时目录...'**
  String get extractingFilesToTempDir_4990;

  /// No description provided for @extractingZipFile_4989.
  ///
  /// In zh, this message translates to:
  /// **'正在解压ZIP文件...'**
  String get extractingZipFile_4989;

  /// No description provided for @extractionFailed_5011.
  ///
  /// In zh, this message translates to:
  /// **'解压失败: {error}'**
  String extractionFailed_5011(Object error);

  /// No description provided for @extractionSuccess_5010.
  ///
  /// In zh, this message translates to:
  /// **'成功解压 {count} 个文件'**
  String extractionSuccess_5010(Object count);

  /// No description provided for @failedToGetAudioFile_4821.
  ///
  /// In zh, this message translates to:
  /// **'无法从VFS获取音频文件'**
  String get failedToGetAudioFile_4821;

  /// No description provided for @failedToGetImageSize.
  ///
  /// In zh, this message translates to:
  /// **'获取图片尺寸失败: {e}'**
  String failedToGetImageSize(Object e);

  /// No description provided for @failedToGetLegendFromPath_7281.
  ///
  /// In zh, this message translates to:
  /// **'从绝对路径获取图例失败: {absolutePath}, 错误: {e}'**
  String failedToGetLegendFromPath_7281(Object absolutePath, Object e);

  /// No description provided for @failedToGetVoiceSpeedRange.
  ///
  /// In zh, this message translates to:
  /// **'获取语音速度范围失败: {e}'**
  String failedToGetVoiceSpeedRange(Object e);

  /// No description provided for @failedToGetWebDavAccountIds.
  ///
  /// In zh, this message translates to:
  /// **'获取所有WebDAV认证账户ID失败: {e}'**
  String failedToGetWebDavAccountIds(Object e);

  /// No description provided for @failedToInitializeReactiveVersionManagement_7285.
  ///
  /// In zh, this message translates to:
  /// **'无法初始化响应式版本管理：当前地图为空'**
  String get failedToInitializeReactiveVersionManagement_7285;

  /// No description provided for @failedToLoadDrawingElement.
  ///
  /// In zh, this message translates to:
  /// **'加载绘制元素失败 [{mapTitle}/{layerId}:{version}]: {e}'**
  String failedToLoadDrawingElement(
    Object e,
    Object layerId,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @failedToLoadElement_4821.
  ///
  /// In zh, this message translates to:
  /// **'加载绘制元素失败 [{mapTitle}/{layerId}/{elementId}:{version}]: {e}'**
  String failedToLoadElement_4821(
    Object e,
    Object elementId,
    Object layerId,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @failedToLoadVfsDirectory_7281.
  ///
  /// In zh, this message translates to:
  /// **'无法加载VFS目录'**
  String get failedToLoadVfsDirectory_7281;

  /// No description provided for @failedToParseLegendUpdateJson.
  ///
  /// In zh, this message translates to:
  /// **'解析图例组更新参数JSON失败: {e}'**
  String failedToParseLegendUpdateJson(Object e);

  /// No description provided for @failedToParseLegendUpdateParamsJson.
  ///
  /// In zh, this message translates to:
  /// **'解析图例项更新参数JSON失败: {error}'**
  String failedToParseLegendUpdateParamsJson(Object error);

  /// No description provided for @failedToReadImageData_7284.
  ///
  /// In zh, this message translates to:
  /// **'无法读取图片数据'**
  String get failedToReadImageData_7284;

  /// No description provided for @failedToReadImageFile_4821.
  ///
  /// In zh, this message translates to:
  /// **'无法读取图片文件'**
  String get failedToReadImageFile_4821;

  /// No description provided for @failedToReadTextFile_4821.
  ///
  /// In zh, this message translates to:
  /// **'无法读取文本文件'**
  String get failedToReadTextFile_4821;

  /// No description provided for @failure_7423.
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get failure_7423;

  /// No description provided for @failure_8364.
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get failure_8364;

  /// No description provided for @failure_9352.
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get failure_9352;

  /// No description provided for @fallbackToAsyncLoading_7281.
  ///
  /// In zh, this message translates to:
  /// **'回退到异步加载方式'**
  String get fallbackToAsyncLoading_7281;

  /// No description provided for @fallbackToTextModeCopy.
  ///
  /// In zh, this message translates to:
  /// **'已回退到文本模式复制: {width}x{height} ({platform})'**
  String fallbackToTextModeCopy(Object height, Object platform, Object width);

  /// No description provided for @fastForward10Seconds_4821.
  ///
  /// In zh, this message translates to:
  /// **'快进10秒'**
  String get fastForward10Seconds_4821;

  /// No description provided for @fastForward10Seconds_7281.
  ///
  /// In zh, this message translates to:
  /// **'快进10秒'**
  String get fastForward10Seconds_7281;

  /// No description provided for @fastForwardFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'快进操作失败: {e}'**
  String fastForwardFailed_4821(Object e);

  /// No description provided for @fastForwardFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'快进操作失败'**
  String get fastForwardFailed_7285;

  /// No description provided for @fastRewind10Seconds_7281.
  ///
  /// In zh, this message translates to:
  /// **'快退10秒'**
  String get fastRewind10Seconds_7281;

  /// No description provided for @fastRewindFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'快退操作失败: {e}'**
  String fastRewindFailed_4821(Object e);

  /// No description provided for @fast_4821.
  ///
  /// In zh, this message translates to:
  /// **'快'**
  String get fast_4821;

  /// No description provided for @favoriteStrokeWidths.
  ///
  /// In zh, this message translates to:
  /// **'常用线条宽度'**
  String get favoriteStrokeWidths;

  /// No description provided for @featureConfiguration.
  ///
  /// In zh, this message translates to:
  /// **'功能配置'**
  String get featureConfiguration;

  /// No description provided for @featureEnhancement_4821.
  ///
  /// In zh, this message translates to:
  /// **'🎉 功能更强大：支持9个位置、堆叠管理、精美动画！'**
  String get featureEnhancement_4821;

  /// No description provided for @features.
  ///
  /// In zh, this message translates to:
  /// **'功能特性'**
  String get features;

  /// No description provided for @feedbackTitle_4271.
  ///
  /// In zh, this message translates to:
  /// **'问题反馈'**
  String get feedbackTitle_4271;

  /// No description provided for @fetchConfigFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'获取配置信息失败'**
  String get fetchConfigFailed_4821;

  /// No description provided for @fetchConfigFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'获取配置信息失败: {e}'**
  String fetchConfigFailed_7284(Object e);

  /// No description provided for @fetchConfigListFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'获取配置列表失败: {error}'**
  String fetchConfigListFailed_7285(Object error);

  /// No description provided for @fetchCustomTagFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'获取自定义标签失败: {e}'**
  String fetchCustomTagFailed_7285(Object e);

  /// No description provided for @fetchDataResult_7281.
  ///
  /// In zh, this message translates to:
  /// **'从源版本 [{sourceVersionId}] 获取数据: {result}'**
  String fetchDataResult_7281(Object result, Object sourceVersionId);

  /// No description provided for @fetchDirectoryFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'获取目录列表失败: {e}'**
  String fetchDirectoryFailed_7285(Object e);

  /// No description provided for @fetchFolderListFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'获取文件夹列表失败: {e}'**
  String fetchFolderListFailed_4821(Object e);

  /// No description provided for @fetchImageFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'获取图片失败: {e}'**
  String fetchImageFailed_7285(Object e);

  /// No description provided for @fetchLegendListFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'获取图例列表失败: {e}'**
  String fetchLegendListFailed_4821(Object e);

  /// No description provided for @fetchLegendListFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'获取图例列表失败: {e}'**
  String fetchLegendListFailed_7285(Object e);

  /// No description provided for @fetchLegendListPath_7421.
  ///
  /// In zh, this message translates to:
  /// **'获取图例列表，路径: {basePath}'**
  String fetchLegendListPath_7421(Object basePath);

  /// No description provided for @fetchLocalizationFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取本地化数据失败: {e}'**
  String fetchLocalizationFailed(Object e);

  /// No description provided for @fetchMapFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'获取所有地图失败: {e}'**
  String fetchMapFailed_7285(Object e);

  /// No description provided for @fetchMapListFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'获取地图列表失败: {e}'**
  String fetchMapListFailed_7285(Object e);

  /// No description provided for @fetchMapSummariesFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'获取所有地图摘要失败: {e}'**
  String fetchMapSummariesFailed_7285(Object e);

  /// No description provided for @fetchOnlineStatusFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取在线状态列表失败: {error}'**
  String fetchOnlineStatusFailed(Object error);

  /// No description provided for @fetchPrivateKeyIdsFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'获取所有私钥ID失败: {e}'**
  String fetchPrivateKeyIdsFailed_7285(Object e);

  /// No description provided for @fetchTtsLanguagesFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'获取TTS语言列表失败: {e}'**
  String fetchTtsLanguagesFailed_4821(Object e);

  /// No description provided for @fetchUserPreferenceFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取用户偏好失败: {e}'**
  String fetchUserPreferenceFailed(Object e);

  /// No description provided for @fetchUserPreferencesFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'获取用户偏好设置失败: {e}'**
  String fetchUserPreferencesFailed_4821(Object e);

  /// No description provided for @fetchVersionNamesFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取所有版本名称失败 [{mapTitle}]: {e}'**
  String fetchVersionNamesFailed(Object e, Object mapTitle);

  /// No description provided for @fieldName_4944.
  ///
  /// In zh, this message translates to:
  /// **'字段名'**
  String get fieldName_4944;

  /// No description provided for @fieldValue_4946.
  ///
  /// In zh, this message translates to:
  /// **'字段值'**
  String get fieldValue_4946;

  /// No description provided for @fileBrowser_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件浏览'**
  String get fileBrowser_4821;

  /// No description provided for @fileConflict_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件冲突'**
  String get fileConflict_4821;

  /// No description provided for @fileConflict_4926.
  ///
  /// In zh, this message translates to:
  /// **'文件冲突'**
  String get fileConflict_4926;

  /// No description provided for @fileCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个文件'**
  String fileCount(Object count);

  /// No description provided for @fileCount_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件数量'**
  String get fileCount_4821;

  /// No description provided for @fileDetails_4722.
  ///
  /// In zh, this message translates to:
  /// **'文件详情'**
  String get fileDetails_4722;

  /// No description provided for @fileDownloadComplete_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件下载完成！'**
  String get fileDownloadComplete_4821;

  /// No description provided for @fileDownloadFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'文件下载失败: {e}'**
  String fileDownloadFailed_7281(Object e);

  /// No description provided for @fileDownloadSuccess.
  ///
  /// In zh, this message translates to:
  /// **'文件下载成功: {fullRemotePath} -> {localFilePath}'**
  String fileDownloadSuccess(Object fullRemotePath, Object localFilePath);

  /// No description provided for @fileExtensionNotice.
  ///
  /// In zh, this message translates to:
  /// **'注意: 文件扩展名 \"{extension}\" 将保持不变'**
  String fileExtensionNotice(Object extension);

  /// No description provided for @fileInfoCopiedToClipboard_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件信息已复制到剪贴板'**
  String get fileInfoCopiedToClipboard_4821;

  /// No description provided for @fileInfoTitle.
  ///
  /// In zh, this message translates to:
  /// **'文件信息 - {name}'**
  String fileInfoTitle(Object name);

  /// No description provided for @fileInfoWithSizeAndDate_5421.
  ///
  /// In zh, this message translates to:
  /// **'{size} • {date}'**
  String fileInfoWithSizeAndDate_5421(Object date, Object size);

  /// No description provided for @fileInfo_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件信息'**
  String get fileInfo_4821;

  /// No description provided for @fileInfo_7281.
  ///
  /// In zh, this message translates to:
  /// **'文件信息'**
  String get fileInfo_7281;

  /// No description provided for @fileLoadFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'加载文件失败: {e}'**
  String fileLoadFailed_7284(Object e);

  /// No description provided for @fileLoadFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'加载文件失败: {e}'**
  String fileLoadFailed_7285(Object e);

  /// No description provided for @fileManagerStyle_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件管理器风格'**
  String get fileManagerStyle_4821;

  /// No description provided for @fileManager_1234.
  ///
  /// In zh, this message translates to:
  /// **'文件管理器'**
  String get fileManager_1234;

  /// No description provided for @fileMappingList_4521.
  ///
  /// In zh, this message translates to:
  /// **'文件映射列表'**
  String get fileMappingList_4521;

  /// No description provided for @fileNameHint_4521.
  ///
  /// In zh, this message translates to:
  /// **'请输入文件名'**
  String get fileNameHint_4521;

  /// No description provided for @fileNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'文件名: {fileName}'**
  String fileNameLabel(Object fileName);

  /// No description provided for @fileNameWithIndex.
  ///
  /// In zh, this message translates to:
  /// **'文件 {index}.txt'**
  String fileNameWithIndex(Object index);

  /// No description provided for @fileName_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件名'**
  String get fileName_4821;

  /// No description provided for @fileName_5421.
  ///
  /// In zh, this message translates to:
  /// **'文件名'**
  String get fileName_5421;

  /// No description provided for @fileName_7891.
  ///
  /// In zh, this message translates to:
  /// **'文件名'**
  String get fileName_7891;

  /// No description provided for @fileNotExist_4721.
  ///
  /// In zh, this message translates to:
  /// **'文件不存在 - {vfsPath}'**
  String fileNotExist_4721(Object vfsPath);

  /// No description provided for @fileNotFound_7421.
  ///
  /// In zh, this message translates to:
  /// **'文件不存在: {fileName}'**
  String fileNotFound_7421(Object fileName);

  /// No description provided for @fileOpenFailed_5421.
  ///
  /// In zh, this message translates to:
  /// **'打开文件失败'**
  String get fileOpenFailed_5421;

  /// No description provided for @fileOpenFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'打开文件失败: {e}'**
  String fileOpenFailed_7285(Object e);

  /// No description provided for @filePathLabel.
  ///
  /// In zh, this message translates to:
  /// **'路径: {path}'**
  String filePathLabel(Object path);

  /// No description provided for @filePath_8423.
  ///
  /// In zh, this message translates to:
  /// **'文件路径'**
  String get filePath_8423;

  /// No description provided for @filePermissionFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'获取文件权限失败: {e}'**
  String filePermissionFailed_7285(Object e);

  /// No description provided for @filePickerFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'文件选择器失败，尝试下载：{e}'**
  String filePickerFailedWithError(Object e);

  /// No description provided for @fileProcessingError_7281.
  ///
  /// In zh, this message translates to:
  /// **'处理文件 {fileName} 时出错: {error}'**
  String fileProcessingError_7281(Object error, Object fileName);

  /// No description provided for @fileSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存文件失败: {e}'**
  String fileSaveFailed(Object e);

  /// No description provided for @fileSavedSuccessfully_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件保存成功'**
  String get fileSavedSuccessfully_4821;

  /// No description provided for @fileSelectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'文件选择失败: {e}'**
  String fileSelectionFailed(Object e);

  /// No description provided for @fileSelectionModeWarning_4821.
  ///
  /// In zh, this message translates to:
  /// **'当前选择模式只能选择文件'**
  String get fileSelectionModeWarning_4821;

  /// No description provided for @fileSizeExceededWebLimit.
  ///
  /// In zh, this message translates to:
  /// **'文件过大（{fileSize}MB，超过4MB限制），无法在Web平台生成URL'**
  String fileSizeExceededWebLimit(Object fileSize);

  /// No description provided for @fileSizeInfo_7425.
  ///
  /// In zh, this message translates to:
  /// **'大小: {fileSize} • 修改时间: {modifiedTime}'**
  String fileSizeInfo_7425(Object fileSize, Object modifiedTime);

  /// No description provided for @fileSizeLabel.
  ///
  /// In zh, this message translates to:
  /// **'文件大小: {size}'**
  String fileSizeLabel(Object size);

  /// No description provided for @fileSizeLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'大小'**
  String get fileSizeLabel_4821;

  /// No description provided for @fileSizeLabel_5421.
  ///
  /// In zh, this message translates to:
  /// **'大小'**
  String get fileSizeLabel_5421;

  /// No description provided for @fileSizeLabel_7421.
  ///
  /// In zh, this message translates to:
  /// **'大小'**
  String get fileSizeLabel_7421;

  /// No description provided for @fileSize_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件大小'**
  String get fileSize_4821;

  /// No description provided for @fileSystemAccess.
  ///
  /// In zh, this message translates to:
  /// **'文件系统访问'**
  String get fileSystemAccess;

  /// No description provided for @fileTypeRestriction_7421.
  ///
  /// In zh, this message translates to:
  /// **'仅指定类型文件 ({extensions}) • 文件夹可导航'**
  String fileTypeRestriction_7421(Object extensions);

  /// No description provided for @fileTypeStatistics_4521.
  ///
  /// In zh, this message translates to:
  /// **'文件类型统计'**
  String get fileTypeStatistics_4521;

  /// No description provided for @fileTypeStatistics_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件类型统计'**
  String get fileTypeStatistics_4821;

  /// No description provided for @fileTypeWithExtension.
  ///
  /// In zh, this message translates to:
  /// **'文件类型: .{extension}'**
  String fileTypeWithExtension(Object extension);

  /// No description provided for @fileType_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get fileType_4821;

  /// No description provided for @fileType_4823.
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get fileType_4823;

  /// No description provided for @fileType_5421.
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get fileType_5421;

  /// No description provided for @fileUnavailable_4287.
  ///
  /// In zh, this message translates to:
  /// **'文件信息不可用'**
  String get fileUnavailable_4287;

  /// No description provided for @fileUploadFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'文件上传失败: {e}'**
  String fileUploadFailed_7284(Object e);

  /// No description provided for @fileUploadFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'上传文件失败: {e}'**
  String fileUploadFailed_7285(Object e);

  /// No description provided for @fileUploadSuccess.
  ///
  /// In zh, this message translates to:
  /// **'成功上传 {successCount} 个文件'**
  String fileUploadSuccess(Object successCount);

  /// No description provided for @file_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get file_4821;

  /// No description provided for @filesAndFolders_7281.
  ///
  /// In zh, this message translates to:
  /// **'文件和文件夹'**
  String get filesAndFolders_7281;

  /// No description provided for @filesCompressedInfo.
  ///
  /// In zh, this message translates to:
  /// **'已压缩下载 {totalFiles} 个文件\n压缩包大小: {fileSize}'**
  String filesCompressedInfo(Object fileSize, Object totalFiles);

  /// No description provided for @filesDownloaded_7421.
  ///
  /// In zh, this message translates to:
  /// **'已下载 {fileCount} 个文件到 {downloadPath}'**
  String filesDownloaded_7421(Object downloadPath, Object fileCount);

  /// No description provided for @filesExistOverwrite_4927.
  ///
  /// In zh, this message translates to:
  /// **'以下文件已存在，是否覆盖？'**
  String get filesExistOverwrite_4927;

  /// No description provided for @filipinoPH_4881.
  ///
  /// In zh, this message translates to:
  /// **'菲律宾语 (菲律宾)'**
  String get filipinoPH_4881;

  /// No description provided for @filipino_4880.
  ///
  /// In zh, this message translates to:
  /// **'菲律宾语'**
  String get filipino_4880;

  /// No description provided for @fillModeLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'填充模式: '**
  String get fillModeLabel_4821;

  /// No description provided for @fillMode_4821.
  ///
  /// In zh, this message translates to:
  /// **'填充模式'**
  String get fillMode_4821;

  /// No description provided for @filterLabel_4281.
  ///
  /// In zh, this message translates to:
  /// **'过滤'**
  String get filterLabel_4281;

  /// No description provided for @filterPreview_4821.
  ///
  /// In zh, this message translates to:
  /// **'滤镜预览'**
  String get filterPreview_4821;

  /// No description provided for @filterRemoved_4821.
  ///
  /// In zh, this message translates to:
  /// **'已移除'**
  String get filterRemoved_4821;

  /// No description provided for @filterScriptExample_3242.
  ///
  /// In zh, this message translates to:
  /// **'过滤脚本示例'**
  String get filterScriptExample_3242;

  /// No description provided for @filterType_4821.
  ///
  /// In zh, this message translates to:
  /// **'滤镜类型'**
  String get filterType_4821;

  /// No description provided for @filter_9012.
  ///
  /// In zh, this message translates to:
  /// **'过滤'**
  String get filter_9012;

  /// No description provided for @finalDisplayOrderLayersDebug.
  ///
  /// In zh, this message translates to:
  /// **'最终_displayOrderLayers顺序: {layers}'**
  String finalDisplayOrderLayersDebug(Object layers);

  /// No description provided for @finalLegendTitleList.
  ///
  /// In zh, this message translates to:
  /// **'最终图例标题列表: {titles}'**
  String finalLegendTitleList(Object titles);

  /// No description provided for @findJsonFileWithPath.
  ///
  /// In zh, this message translates to:
  /// **'查找JSON文件: {jsonPath} (使用原始标题)'**
  String findJsonFileWithPath(Object jsonPath);

  /// No description provided for @finnishFI_4849.
  ///
  /// In zh, this message translates to:
  /// **'芬兰语 (芬兰)'**
  String get finnishFI_4849;

  /// No description provided for @finnish_4848.
  ///
  /// In zh, this message translates to:
  /// **'芬兰语'**
  String get finnish_4848;

  /// No description provided for @fitHeight_4821.
  ///
  /// In zh, this message translates to:
  /// **'适合高度'**
  String get fitHeight_4821;

  /// No description provided for @fitWidthOption_4821.
  ///
  /// In zh, this message translates to:
  /// **'适合宽度'**
  String get fitWidthOption_4821;

  /// No description provided for @fitWindowTooltip_4521.
  ///
  /// In zh, this message translates to:
  /// **'适应窗口'**
  String get fitWindowTooltip_4521;

  /// No description provided for @fixedLegendSizeUsage.
  ///
  /// In zh, this message translates to:
  /// **'使用固定图例大小: {legendSize}'**
  String fixedLegendSizeUsage(Object legendSize);

  /// No description provided for @fixedSizeText_7281.
  ///
  /// In zh, this message translates to:
  /// **'固定大小：{size}'**
  String fixedSizeText_7281(Object size);

  /// No description provided for @floatingWindowBuilderDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'FloatingWindowBuilder提供了一种优雅的方式来配置浮动窗口的各种属性。您可以使用链式调用来设置窗口的标题、图标、尺寸、拖拽支持等功能。'**
  String get floatingWindowBuilderDescription_4821;

  /// No description provided for @floatingWindowDemo_4271.
  ///
  /// In zh, this message translates to:
  /// **'浮动窗口演示'**
  String get floatingWindowDemo_4271;

  /// No description provided for @floatingWindowExample_4271.
  ///
  /// In zh, this message translates to:
  /// **'浮动窗口示例'**
  String get floatingWindowExample_4271;

  /// No description provided for @floatingWindowExample_4521.
  ///
  /// In zh, this message translates to:
  /// **'这是一个简单的浮动窗口示例，模仿了VFS文件选择器的设计风格。'**
  String get floatingWindowExample_4521;

  /// No description provided for @floatingWindowTip_7281.
  ///
  /// In zh, this message translates to:
  /// **'点击按钮体验不同类型的浮动窗口'**
  String get floatingWindowTip_7281;

  /// No description provided for @floatingWindowWithActionsDesc_4821.
  ///
  /// In zh, this message translates to:
  /// **'头部包含自定义操作按钮的浮动窗口'**
  String get floatingWindowWithActionsDesc_4821;

  /// No description provided for @floatingWindowWithIconAndTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'包含图标、主标题和副标题的浮动窗口'**
  String get floatingWindowWithIconAndTitle_4821;

  /// No description provided for @flutterCustomContextMenu_4821.
  ///
  /// In zh, this message translates to:
  /// **'• 使用Flutter自定义的右键菜单'**
  String get flutterCustomContextMenu_4821;

  /// No description provided for @folderAndFileTypesRestriction.
  ///
  /// In zh, this message translates to:
  /// **'文件夹和指定类型文件 ({extensions})'**
  String folderAndFileTypesRestriction(Object extensions);

  /// No description provided for @folderCount_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件夹数量'**
  String get folderCount_4821;

  /// No description provided for @folderCreatedSuccessfully_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件夹创建成功'**
  String get folderCreatedSuccessfully_4821;

  /// No description provided for @folderCreatedSuccessfully_4834.
  ///
  /// In zh, this message translates to:
  /// **'文件夹创建成功'**
  String get folderCreatedSuccessfully_4834;

  /// No description provided for @folderCreatedSuccessfully_7281.
  ///
  /// In zh, this message translates to:
  /// **'文件夹创建成功'**
  String get folderCreatedSuccessfully_7281;

  /// No description provided for @folderCreationFailed.
  ///
  /// In zh, this message translates to:
  /// **'创建文件夹失败: {e}'**
  String folderCreationFailed(Object e);

  /// No description provided for @folderCreationFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件夹创建失败'**
  String get folderCreationFailed_4821;

  /// No description provided for @folderCreationFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'创建文件夹失败: {e}'**
  String folderCreationFailed_7285(Object e);

  /// No description provided for @folderCreationFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'创建文件夹失败 [{folderPath}]: {e}'**
  String folderCreationFailed_7421(Object e, Object folderPath);

  /// No description provided for @folderDeletedSuccessfully_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件夹删除成功'**
  String get folderDeletedSuccessfully_4821;

  /// No description provided for @folderDeletedSuccessfully_4839.
  ///
  /// In zh, this message translates to:
  /// **'文件夹删除成功'**
  String get folderDeletedSuccessfully_4839;

  /// No description provided for @folderDeletionFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除文件夹失败 [{folderPath}]: {e}'**
  String folderDeletionFailed(Object e, Object folderPath);

  /// No description provided for @folderEmpty_4821.
  ///
  /// In zh, this message translates to:
  /// **'此文件夹为空'**
  String get folderEmpty_4821;

  /// No description provided for @folderLabel_5421.
  ///
  /// In zh, this message translates to:
  /// **'文件夹'**
  String get folderLabel_5421;

  /// No description provided for @folderLegendError_7421.
  ///
  /// In zh, this message translates to:
  /// **'获取文件夹中的图例失败: {folderPath}, 错误: {e}'**
  String folderLegendError_7421(Object e, Object folderPath);

  /// No description provided for @folderNameConversion.
  ///
  /// In zh, this message translates to:
  /// **'文件夹名称转换: \"{name}\" -> \"{desanitized}\"'**
  String folderNameConversion(Object desanitized, Object name);

  /// No description provided for @folderNameExists_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件夹名称已存在'**
  String get folderNameExists_4821;

  /// No description provided for @folderNameHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件夹名称'**
  String get folderNameHint_4821;

  /// No description provided for @folderNameHint_5732.
  ///
  /// In zh, this message translates to:
  /// **'文件夹名称'**
  String get folderNameHint_5732;

  /// No description provided for @folderNameLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件夹名称'**
  String get folderNameLabel_4821;

  /// No description provided for @folderNameRules_4821.
  ///
  /// In zh, this message translates to:
  /// **'只能包含字母、数字、斜杠(/)、下划线(_)、连字符(-)，不能包含中文字符，长度不超过100字符'**
  String get folderNameRules_4821;

  /// No description provided for @folderName_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件夹名称'**
  String get folderName_4821;

  /// No description provided for @folderName_4830.
  ///
  /// In zh, this message translates to:
  /// **'文件夹名称'**
  String get folderName_4830;

  /// No description provided for @folderNotEmptyCannotDelete.
  ///
  /// In zh, this message translates to:
  /// **'文件夹不为空，无法删除: {folderPath}'**
  String folderNotEmptyCannotDelete(Object folderPath);

  /// No description provided for @folderNotExist_4821.
  ///
  /// In zh, this message translates to:
  /// **'选择的文件夹不存在'**
  String get folderNotExist_4821;

  /// No description provided for @folderOnly_7281.
  ///
  /// In zh, this message translates to:
  /// **'仅文件夹'**
  String get folderOnly_7281;

  /// No description provided for @folderPathLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件夹路径'**
  String get folderPathLabel_4821;

  /// No description provided for @folderRenameSuccess_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件夹重命名成功'**
  String get folderRenameSuccess_4821;

  /// No description provided for @folderRenameSuccess_4827.
  ///
  /// In zh, this message translates to:
  /// **'文件夹重命名成功: {oldPath} -> {newPath}'**
  String folderRenameSuccess_4827(Object newPath, Object oldPath);

  /// No description provided for @folderRenamedSuccessfully_4844.
  ///
  /// In zh, this message translates to:
  /// **'文件夹重命名成功'**
  String get folderRenamedSuccessfully_4844;

  /// No description provided for @folderSelectionRequired_4821.
  ///
  /// In zh, this message translates to:
  /// **'当前选择模式只能选择文件夹'**
  String get folderSelectionRequired_4821;

  /// No description provided for @folderType_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件夹'**
  String get folderType_4821;

  /// No description provided for @folderType_4822.
  ///
  /// In zh, this message translates to:
  /// **'文件夹'**
  String get folderType_4822;

  /// No description provided for @folderType_5421.
  ///
  /// In zh, this message translates to:
  /// **'文件夹'**
  String get folderType_5421;

  /// No description provided for @folder_7281.
  ///
  /// In zh, this message translates to:
  /// **'文件夹'**
  String get folder_7281;

  /// No description provided for @foldersDownloadedToPath_7281.
  ///
  /// In zh, this message translates to:
  /// **'已下载 {folderCount} 个文件夹到 {downloadPath}'**
  String foldersDownloadedToPath_7281(Object downloadPath, Object folderCount);

  /// No description provided for @foldersDownloaded_7281.
  ///
  /// In zh, this message translates to:
  /// **'已下载 {folderCount} 个文件夹到 {downloadPath}'**
  String foldersDownloaded_7281(Object downloadPath, Object folderCount);

  /// No description provided for @folders_4822.
  ///
  /// In zh, this message translates to:
  /// **'文件夹'**
  String get folders_4822;

  /// No description provided for @fontSizeLabel.
  ///
  /// In zh, this message translates to:
  /// **'字体大小: {value}px'**
  String fontSizeLabel(Object value);

  /// No description provided for @fontSizeLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'字体大小'**
  String get fontSizeLabel_4821;

  /// No description provided for @fontSize_4821.
  ///
  /// In zh, this message translates to:
  /// **'字体大小'**
  String get fontSize_4821;

  /// No description provided for @forceExecutePendingTasks_7281.
  ///
  /// In zh, this message translates to:
  /// **'强制执行所有待处理的节流任务...'**
  String get forceExecutePendingTasks_7281;

  /// No description provided for @forceExecuteThrottleTasks.
  ///
  /// In zh, this message translates to:
  /// **'强制执行{activeCount}个待处理的节流任务'**
  String forceExecuteThrottleTasks(Object activeCount);

  /// No description provided for @forceExitWarning_4821.
  ///
  /// In zh, this message translates to:
  /// **'强制退出可能会导致数据丢失或程序状态异常。建议等待当前任务完成后再退出。'**
  String get forceExitWarning_4821;

  /// No description provided for @forcePreviewSubmission_7421.
  ///
  /// In zh, this message translates to:
  /// **'强制提交预览: {id}'**
  String forcePreviewSubmission_7421(Object id);

  /// No description provided for @forceSaveFailed_4829.
  ///
  /// In zh, this message translates to:
  /// **'强制保存待处理更改失败: {e}'**
  String forceSaveFailed_4829(Object e);

  /// No description provided for @forceTerminateAllWorkStatus_4821.
  ///
  /// In zh, this message translates to:
  /// **'强制结束所有工作状态'**
  String get forceTerminateAllWorkStatus_4821;

  /// No description provided for @forceUpdateMessage_7285.
  ///
  /// In zh, this message translates to:
  /// **'强制更新: {forceUpdate}'**
  String forceUpdateMessage_7285(Object forceUpdate);

  /// No description provided for @foregroundLayer_1234.
  ///
  /// In zh, this message translates to:
  /// **'前景图层'**
  String get foregroundLayer_1234;

  /// No description provided for @formatJsonTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'格式化JSON'**
  String get formatJsonTooltip_7281;

  /// No description provided for @formulaWithCount_7421.
  ///
  /// In zh, this message translates to:
  /// **'公式: {totalCount}'**
  String formulaWithCount_7421(Object totalCount);

  /// No description provided for @forward_4821.
  ///
  /// In zh, this message translates to:
  /// **'前进'**
  String get forward_4821;

  /// No description provided for @foundBlueRectangles_5262.
  ///
  /// In zh, this message translates to:
  /// **'找到'**
  String get foundBlueRectangles_5262;

  /// No description provided for @foundFilesCount_7421.
  ///
  /// In zh, this message translates to:
  /// **'找到 {count} 个文件: {fileList}'**
  String foundFilesCount_7421(Object count, Object fileList);

  /// No description provided for @foundLegendFilesInDirectory.
  ///
  /// In zh, this message translates to:
  /// **'在目录 {directoryPath} 中找到 {count} 个图例文件'**
  String foundLegendFilesInDirectory(Object count, Object directoryPath);

  /// No description provided for @foundLegendFolders.
  ///
  /// In zh, this message translates to:
  /// **'找到的.legend文件夹: {folders}'**
  String foundLegendFolders(Object folders);

  /// No description provided for @foundStoredVersions_7281.
  ///
  /// In zh, this message translates to:
  /// **'找到 {count} 个已存储的版本: {ids}'**
  String foundStoredVersions_7281(Object count, Object ids);

  /// No description provided for @foundSvgFilesCount_5421.
  ///
  /// In zh, this message translates to:
  /// **'找到 {count} 个 SVG 文件'**
  String foundSvgFilesCount_5421(Object count);

  /// No description provided for @fourPerPage_4823.
  ///
  /// In zh, this message translates to:
  /// **'一页四张'**
  String get fourPerPage_4823;

  /// No description provided for @freeDrawingLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'自由绘制'**
  String get freeDrawingLabel_4821;

  /// No description provided for @freeDrawingTooltip_7532.
  ///
  /// In zh, this message translates to:
  /// **'自由绘制'**
  String get freeDrawingTooltip_7532;

  /// No description provided for @freeDrawing_4830.
  ///
  /// In zh, this message translates to:
  /// **'自由绘制'**
  String get freeDrawing_4830;

  /// No description provided for @frenchCA_4883.
  ///
  /// In zh, this message translates to:
  /// **'法语 (加拿大)'**
  String get frenchCA_4883;

  /// No description provided for @frenchFR_4882.
  ///
  /// In zh, this message translates to:
  /// **'法语 (法国)'**
  String get frenchFR_4882;

  /// No description provided for @french_4829.
  ///
  /// In zh, this message translates to:
  /// **'法语'**
  String get french_4829;

  /// No description provided for @fullScreenModeInDevelopment_7281.
  ///
  /// In zh, this message translates to:
  /// **'全屏模式开发中...'**
  String get fullScreenModeInDevelopment_7281;

  /// No description provided for @fullScreenStatusError.
  ///
  /// In zh, this message translates to:
  /// **'获取全屏状态失败: {error}'**
  String fullScreenStatusError(Object error);

  /// No description provided for @fullScreenTestPage_7421.
  ///
  /// In zh, this message translates to:
  /// **'全屏测试页面'**
  String get fullScreenTestPage_7421;

  /// No description provided for @fullscreenMode_7281.
  ///
  /// In zh, this message translates to:
  /// **'全屏模式'**
  String get fullscreenMode_7281;

  /// No description provided for @fullscreenTest_4821.
  ///
  /// In zh, this message translates to:
  /// **'全屏测试'**
  String get fullscreenTest_4821;

  /// No description provided for @fullscreenToggleFailed.
  ///
  /// In zh, this message translates to:
  /// **'切换全屏模式失败: {e}'**
  String fullscreenToggleFailed(Object e);

  /// No description provided for @futureBuilderData.
  ///
  /// In zh, this message translates to:
  /// **'FutureBuilder 数据: {data}'**
  String futureBuilderData(Object data);

  /// No description provided for @futureBuilderError.
  ///
  /// In zh, this message translates to:
  /// **'FutureBuilder 错误: {error}'**
  String futureBuilderError(Object error);

  /// No description provided for @futureBuilderStatus.
  ///
  /// In zh, this message translates to:
  /// **'FutureBuilder 状态: {connectionState}'**
  String futureBuilderStatus(Object connectionState);

  /// No description provided for @generateAuthToken.
  ///
  /// In zh, this message translates to:
  /// **'生成认证令牌: {clientId}'**
  String generateAuthToken(Object clientId);

  /// No description provided for @generateDataUri_7425.
  ///
  /// In zh, this message translates to:
  /// **'生成Data URI'**
  String get generateDataUri_7425;

  /// No description provided for @generateFileUrl.
  ///
  /// In zh, this message translates to:
  /// **'生成文件URL - {vfsPath}'**
  String generateFileUrl(Object vfsPath);

  /// No description provided for @generateFileUrlFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'生成文件URL失败 - {e}'**
  String generateFileUrlFailed_4821(Object e);

  /// No description provided for @generatePreview_7421.
  ///
  /// In zh, this message translates to:
  /// **'生成预览'**
  String get generatePreview_7421;

  /// No description provided for @generateTagMessage.
  ///
  /// In zh, this message translates to:
  /// **'生成标签 {videoTag}'**
  String generateTagMessage(Object videoTag);

  /// No description provided for @generatedPlayUrl.
  ///
  /// In zh, this message translates to:
  /// **'生成的播放URL - {playableUrl}'**
  String generatedPlayUrl(Object playableUrl);

  /// No description provided for @generatingMetadata_5005.
  ///
  /// In zh, this message translates to:
  /// **'正在生成元数据...'**
  String get generatingMetadata_5005;

  /// No description provided for @generatingPdf_7421.
  ///
  /// In zh, this message translates to:
  /// **'正在生成PDF...'**
  String get generatingPdf_7421;

  /// No description provided for @generatingPreviewImage_7281.
  ///
  /// In zh, this message translates to:
  /// **'正在生成预览图片...'**
  String get generatingPreviewImage_7281;

  /// No description provided for @generatingPreview_7421.
  ///
  /// In zh, this message translates to:
  /// **'正在生成预览...'**
  String get generatingPreview_7421;

  /// No description provided for @generatingRsaKeyPair_7284.
  ///
  /// In zh, this message translates to:
  /// **'开始生成2048位RSA密钥对...'**
  String get generatingRsaKeyPair_7284;

  /// No description provided for @germanDE_4884.
  ///
  /// In zh, this message translates to:
  /// **'德语 (德国)'**
  String get germanDE_4884;

  /// No description provided for @german_4830.
  ///
  /// In zh, this message translates to:
  /// **'德语'**
  String get german_4830;

  /// No description provided for @getSubfolderFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'获取子文件夹失败: {parentPath}, 错误: {e}'**
  String getSubfolderFailed_7281(Object e, Object parentPath);

  /// No description provided for @getUserPreferenceFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'获取用户偏好设置显示名称失败: {e}'**
  String getUserPreferenceFailed_4821(Object e);

  /// No description provided for @githubDescription_4910.
  ///
  /// In zh, this message translates to:
  /// **'查看源代码、报告问题和贡献代码'**
  String get githubDescription_4910;

  /// No description provided for @githubRepository_4909.
  ///
  /// In zh, this message translates to:
  /// **'GitHub 仓库'**
  String get githubRepository_4909;

  /// No description provided for @globalCollaborationNotInitialized_4821.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService 未初始化'**
  String get globalCollaborationNotInitialized_4821;

  /// No description provided for @globalCollaborationNotInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService 未初始化'**
  String get globalCollaborationNotInitialized_7281;

  /// No description provided for @globalCollaborationServiceConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService 连接失败: {e}'**
  String globalCollaborationServiceConnectionFailed(Object e);

  /// No description provided for @globalCollaborationServiceInitFailed.
  ///
  /// In zh, this message translates to:
  /// **'全局协作服务初始化失败: {e}'**
  String globalCollaborationServiceInitFailed(Object e);

  /// No description provided for @globalCollaborationServiceInitialized_4821.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService 初始化完成'**
  String get globalCollaborationServiceInitialized_4821;

  /// No description provided for @globalCollaborationServiceInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'全局协作服务初始化成功'**
  String get globalCollaborationServiceInitialized_7281;

  /// No description provided for @globalCollaborationServiceReleaseResources_7421.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService 开始释放资源'**
  String get globalCollaborationServiceReleaseResources_7421;

  /// No description provided for @globalCollaborationUserInfoSet.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService 用户信息已设置: userId={userId}, displayName={displayName}'**
  String globalCollaborationUserInfoSet(Object displayName, Object userId);

  /// No description provided for @globalIndexDebug_7281.
  ///
  /// In zh, this message translates to:
  /// **'全局索引: oldGlobalIndex={oldGlobalIndex}, newGlobalIndex={newGlobalIndex}'**
  String globalIndexDebug_7281(Object newGlobalIndex, Object oldGlobalIndex);

  /// No description provided for @globalServiceNotInitialized_7285.
  ///
  /// In zh, this message translates to:
  /// **'全局协作服务未初始化，使用本地实例: {e}'**
  String globalServiceNotInitialized_7285(Object e);

  /// No description provided for @goHome.
  ///
  /// In zh, this message translates to:
  /// **'回到首页'**
  String get goHome;

  /// No description provided for @googleFontLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法加载Google中文字体，使用默认字体: {e}'**
  String googleFontLoadFailed(Object e);

  /// No description provided for @gplLicense_4906.
  ///
  /// In zh, this message translates to:
  /// **'GPL v3 License'**
  String get gplLicense_4906;

  /// No description provided for @grayscale_4822.
  ///
  /// In zh, this message translates to:
  /// **'灰度'**
  String get grayscale_4822;

  /// No description provided for @grayscale_5678.
  ///
  /// In zh, this message translates to:
  /// **'灰度'**
  String get grayscale_5678;

  /// No description provided for @gridPattern_4821.
  ///
  /// In zh, this message translates to:
  /// **'网格'**
  String get gridPattern_4821;

  /// No description provided for @gridSize.
  ///
  /// In zh, this message translates to:
  /// **'网格大小'**
  String get gridSize;

  /// No description provided for @gridSpacingInfo.
  ///
  /// In zh, this message translates to:
  /// **'   - 基础网格间距: {baseSpacing}px → 实际间距: {actualSpacing}px'**
  String gridSpacingInfo(Object actualSpacing, Object baseSpacing);

  /// No description provided for @gridView_4969.
  ///
  /// In zh, this message translates to:
  /// **'网格视图'**
  String get gridView_4969;

  /// No description provided for @groupGlobalIndexDebug.
  ///
  /// In zh, this message translates to:
  /// **'组全局索引: oldGlobalIndex={oldGlobalIndex}, newGlobalIndex={newGlobalIndex}'**
  String groupGlobalIndexDebug(Object newGlobalIndex, Object oldGlobalIndex);

  /// No description provided for @groupGlobalStartPosition.
  ///
  /// In zh, this message translates to:
  /// **'组在全局的起始位置: {groupStartIndex}'**
  String groupGlobalStartPosition(Object groupStartIndex);

  /// No description provided for @groupIndexDebug.
  ///
  /// In zh, this message translates to:
  /// **'组内oldIndex: {oldIndex}, newIndex: {newIndex}'**
  String groupIndexDebug(Object newIndex, Object oldIndex);

  /// No description provided for @groupIndexOutOfRange_7281.
  ///
  /// In zh, this message translates to:
  /// **'组索引超出范围'**
  String get groupIndexOutOfRange_7281;

  /// No description provided for @groupLayerReorderLog.
  ///
  /// In zh, this message translates to:
  /// **'组内重排序图层: {oldIndex} -> {newIndex}，更新图层数量: {length}'**
  String groupLayerReorderLog(Object length, Object newIndex, Object oldIndex);

  /// No description provided for @groupLayersDebug_4821.
  ///
  /// In zh, this message translates to:
  /// **'组内图层: {layers}'**
  String groupLayersDebug_4821(Object layers);

  /// No description provided for @groupLayersDebug_7421.
  ///
  /// In zh, this message translates to:
  /// **'- 组内图层: {layers}'**
  String groupLayersDebug_7421(Object layers);

  /// No description provided for @groupPermissions_4821.
  ///
  /// In zh, this message translates to:
  /// **'组权限'**
  String get groupPermissions_4821;

  /// No description provided for @groupPermissions_7421.
  ///
  /// In zh, this message translates to:
  /// **'组权限'**
  String get groupPermissions_7421;

  /// No description provided for @groupReorderTriggered.
  ///
  /// In zh, this message translates to:
  /// **'组内重排序触发：oldIndex={oldIndex}, newIndex={newIndex}'**
  String groupReorderTriggered(Object newIndex, Object oldIndex);

  /// No description provided for @groupReorderingComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'=== 组内重排序完成 ==='**
  String get groupReorderingComplete_7281;

  /// No description provided for @groupReorderingLog_7281.
  ///
  /// In zh, this message translates to:
  /// **'=== 执行组内重排序（同时处理链接状态和顺序）==='**
  String get groupReorderingLog_7281;

  /// No description provided for @groupReordering_7281.
  ///
  /// In zh, this message translates to:
  /// **'=== 组重排序 ==='**
  String get groupReordering_7281;

  /// No description provided for @groupSize.
  ///
  /// In zh, this message translates to:
  /// **'组大小: {length}'**
  String groupSize(Object length);

  /// No description provided for @groupSuffix_7281.
  ///
  /// In zh, this message translates to:
  /// **'(组)'**
  String get groupSuffix_7281;

  /// No description provided for @handleOnlineStatusError_4821.
  ///
  /// In zh, this message translates to:
  /// **'处理在线状态列表响应时出错: {error}'**
  String handleOnlineStatusError_4821(Object error);

  /// No description provided for @handleSize_4821.
  ///
  /// In zh, this message translates to:
  /// **'控制柄大小'**
  String get handleSize_4821;

  /// No description provided for @hasAvatar_4821.
  ///
  /// In zh, this message translates to:
  /// **'[有头像]'**
  String get hasAvatar_4821;

  /// No description provided for @hasLayersMessage_5832.
  ///
  /// In zh, this message translates to:
  /// **'有(图层数: {layersCount})'**
  String hasLayersMessage_5832(Object layersCount);

  /// No description provided for @hasSessionData.
  ///
  /// In zh, this message translates to:
  /// **'有会话数据'**
  String get hasSessionData;

  /// No description provided for @hasUnsavedChanges.
  ///
  /// In zh, this message translates to:
  /// **'有未保存更改'**
  String get hasUnsavedChanges;

  /// No description provided for @hebrewIL_4875.
  ///
  /// In zh, this message translates to:
  /// **'希伯来语 (以色列)'**
  String get hebrewIL_4875;

  /// No description provided for @hebrew_4874.
  ///
  /// In zh, this message translates to:
  /// **'希伯来语'**
  String get hebrew_4874;

  /// No description provided for @helpInfo_4821.
  ///
  /// In zh, this message translates to:
  /// **'帮助信息'**
  String get helpInfo_4821;

  /// No description provided for @help_5732.
  ///
  /// In zh, this message translates to:
  /// **'帮助'**
  String get help_5732;

  /// No description provided for @help_7282.
  ///
  /// In zh, this message translates to:
  /// **'帮助'**
  String get help_7282;

  /// No description provided for @hiddenMenu_7281.
  ///
  /// In zh, this message translates to:
  /// **'隐藏菜单'**
  String get hiddenMenu_7281;

  /// No description provided for @hideAllLayersInGroup_7282.
  ///
  /// In zh, this message translates to:
  /// **'已隐藏组内所有图层'**
  String get hideAllLayersInGroup_7282;

  /// No description provided for @hideOtherLayerGroups_3861.
  ///
  /// In zh, this message translates to:
  /// **'隐藏其他图层组'**
  String get hideOtherLayerGroups_3861;

  /// No description provided for @hideOtherLayerGroups_4827.
  ///
  /// In zh, this message translates to:
  /// **'隐藏其他图层组'**
  String get hideOtherLayerGroups_4827;

  /// No description provided for @hideOtherLayersMessage.
  ///
  /// In zh, this message translates to:
  /// **'已隐藏其他图层，只显示 \"{name}\"'**
  String hideOtherLayersMessage(Object name);

  /// No description provided for @hideOtherLayers_3860.
  ///
  /// In zh, this message translates to:
  /// **'隐藏其他图层'**
  String get hideOtherLayers_3860;

  /// No description provided for @hideOtherLayers_4271.
  ///
  /// In zh, this message translates to:
  /// **'隐藏其他图层'**
  String get hideOtherLayers_4271;

  /// No description provided for @hideOtherLayers_4826.
  ///
  /// In zh, this message translates to:
  /// **'隐藏其他图层'**
  String get hideOtherLayers_4826;

  /// No description provided for @hideOtherLegendGroups_3864.
  ///
  /// In zh, this message translates to:
  /// **'隐藏其他图例组'**
  String get hideOtherLegendGroups_3864;

  /// No description provided for @hideOtherLegendGroups_4825.
  ///
  /// In zh, this message translates to:
  /// **'隐藏其他图例组'**
  String get hideOtherLegendGroups_4825;

  /// No description provided for @hidePointer_4271.
  ///
  /// In zh, this message translates to:
  /// **'隐藏指针'**
  String get hidePointer_4271;

  /// No description provided for @hideToc_4821.
  ///
  /// In zh, this message translates to:
  /// **'隐藏目录'**
  String get hideToc_4821;

  /// No description provided for @hide_4821.
  ///
  /// In zh, this message translates to:
  /// **'隐藏'**
  String get hide_4821;

  /// No description provided for @highContrastMode_4271.
  ///
  /// In zh, this message translates to:
  /// **'高对比度'**
  String get highContrastMode_4271;

  /// No description provided for @highPriorityTag_6789.
  ///
  /// In zh, this message translates to:
  /// **'高优先级'**
  String get highPriorityTag_6789;

  /// No description provided for @high_7281.
  ///
  /// In zh, this message translates to:
  /// **'高'**
  String get high_7281;

  /// No description provided for @hindiIN_4893.
  ///
  /// In zh, this message translates to:
  /// **'印地语 (印度)'**
  String get hindiIN_4893;

  /// No description provided for @hindi_4839.
  ///
  /// In zh, this message translates to:
  /// **'印地语'**
  String get hindi_4839;

  /// No description provided for @hintLabelName_7532.
  ///
  /// In zh, this message translates to:
  /// **'输入标签名称'**
  String get hintLabelName_7532;

  /// No description provided for @historyRecord_4271.
  ///
  /// In zh, this message translates to:
  /// **'历史记录'**
  String get historyRecord_4271;

  /// No description provided for @hollowRectangle.
  ///
  /// In zh, this message translates to:
  /// **'空心矩形'**
  String get hollowRectangle;

  /// No description provided for @hollowRectangleTool_5679.
  ///
  /// In zh, this message translates to:
  /// **'空心矩形'**
  String get hollowRectangleTool_5679;

  /// No description provided for @hollowRectangle_4825.
  ///
  /// In zh, this message translates to:
  /// **'空心矩形'**
  String get hollowRectangle_4825;

  /// No description provided for @hollowRectangle_7421.
  ///
  /// In zh, this message translates to:
  /// **'空心矩形'**
  String get hollowRectangle_7421;

  /// No description provided for @hollowRectangle_8635.
  ///
  /// In zh, this message translates to:
  /// **'空心矩形'**
  String get hollowRectangle_8635;

  /// No description provided for @home.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get home;

  /// No description provided for @homePageSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'主页设置'**
  String get homePageSettings_4821;

  /// No description provided for @homePageTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get homePageTitle_4821;

  /// No description provided for @homePage_7281.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get homePage_7281;

  /// No description provided for @hoursAgo_4827.
  ///
  /// In zh, this message translates to:
  /// **'小时前'**
  String get hoursAgo_4827;

  /// No description provided for @hoursAgo_7281.
  ///
  /// In zh, this message translates to:
  /// **'{hours}小时前'**
  String hoursAgo_7281(Object hours);

  /// No description provided for @hoursLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'小时'**
  String get hoursLabel_4821;

  /// No description provided for @hoverHelpText_4821.
  ///
  /// In zh, this message translates to:
  /// **'鼠标悬停时显示帮助信息'**
  String get hoverHelpText_4821;

  /// No description provided for @hoverItem_7421.
  ///
  /// In zh, this message translates to:
  /// **'悬停项目: {label}'**
  String hoverItem_7421(Object label);

  /// No description provided for @htmlContentInfo_7281.
  ///
  /// In zh, this message translates to:
  /// **'HTML内容信息'**
  String get htmlContentInfo_7281;

  /// No description provided for @htmlContentStatistics_7281.
  ///
  /// In zh, this message translates to:
  /// **'HTML内容统计'**
  String get htmlContentStatistics_7281;

  /// No description provided for @htmlImageCount.
  ///
  /// In zh, this message translates to:
  /// **'HTML图片: {count}个'**
  String htmlImageCount(Object count);

  /// No description provided for @htmlInfo_7421.
  ///
  /// In zh, this message translates to:
  /// **'HTML信息'**
  String get htmlInfo_7421;

  /// No description provided for @htmlLinkCount.
  ///
  /// In zh, this message translates to:
  /// **'HTML链接: {count}个'**
  String htmlLinkCount(Object count);

  /// No description provided for @htmlParseComplete.
  ///
  /// In zh, this message translates to:
  /// **'🔧 HtmlProcessor.parseHtml: 解析完成，节点数量: {count}'**
  String htmlParseComplete(Object count);

  /// No description provided for @htmlParseFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'解析失败'**
  String get htmlParseFailed_7281;

  /// No description provided for @htmlParsingFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'HTML解析失败: {e}'**
  String htmlParsingFailed_7285(Object e);

  /// No description provided for @htmlParsingStart.
  ///
  /// In zh, this message translates to:
  /// **'🔧 HtmlProcessor.parseHtml: 开始解析 - textContent: {content}...'**
  String htmlParsingStart(Object content);

  /// No description provided for @htmlProcessingComplete.
  ///
  /// In zh, this message translates to:
  /// **'🔧 HtmlProcessor.parseHtml: 转换完成，SpanNode数量: {count}'**
  String htmlProcessingComplete(Object count);

  /// No description provided for @htmlProcessorNoHtmlTags_4821.
  ///
  /// In zh, this message translates to:
  /// **'🔧 HtmlProcessor.parseHtml: 不包含HTML标签，返回文本节点'**
  String get htmlProcessorNoHtmlTags_4821;

  /// No description provided for @htmlRenderingStatus_4821.
  ///
  /// In zh, this message translates to:
  /// **'HTML渲染状态'**
  String get htmlRenderingStatus_4821;

  /// No description provided for @htmlStatusLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'HTML{status}'**
  String htmlStatusLabel_4821(Object status);

  /// No description provided for @htmlTagDetected_7281.
  ///
  /// In zh, this message translates to:
  /// **'🔧 HtmlProcessor.parseHtml: 检测到HTML标签，开始解析'**
  String get htmlTagDetected_7281;

  /// No description provided for @htmlTagProcessing.
  ///
  /// In zh, this message translates to:
  /// **'🔧 HtmlToSpanVisitor.visitElement: 处理标签 - {localName}, attributes: {attributes}'**
  String htmlTagProcessing(Object attributes, Object localName);

  /// No description provided for @htmlToMarkdownFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'HTML转Markdown失败: {e}'**
  String htmlToMarkdownFailed_4821(Object e);

  /// No description provided for @hueValue.
  ///
  /// In zh, this message translates to:
  /// **'色相: {value}°'**
  String hueValue(Object value);

  /// No description provided for @hue_0123.
  ///
  /// In zh, this message translates to:
  /// **'色相'**
  String get hue_0123;

  /// No description provided for @hue_4828.
  ///
  /// In zh, this message translates to:
  /// **'色相'**
  String get hue_4828;

  /// No description provided for @hungarianHU_4855.
  ///
  /// In zh, this message translates to:
  /// **'匈牙利语 (匈牙利)'**
  String get hungarianHU_4855;

  /// No description provided for @hungarian_4854.
  ///
  /// In zh, this message translates to:
  /// **'匈牙利语'**
  String get hungarian_4854;

  /// No description provided for @iOSFeatures.
  ///
  /// In zh, this message translates to:
  /// **'iOS 功能：'**
  String get iOSFeatures;

  /// No description provided for @iOSPlatform.
  ///
  /// In zh, this message translates to:
  /// **'iOS 平台'**
  String get iOSPlatform;

  /// No description provided for @iOSSpecificFeatures.
  ///
  /// In zh, this message translates to:
  /// **'可以在此处实现 iOS 特定功能。'**
  String get iOSSpecificFeatures;

  /// No description provided for @iconEnlargementFactorLabel.
  ///
  /// In zh, this message translates to:
  /// **'图标放大系数: {factor}x'**
  String iconEnlargementFactorLabel(Object factor);

  /// No description provided for @iconSizeDebug.
  ///
  /// In zh, this message translates to:
  /// **'   - 基础图标大小: {baseSize}px → 实际大小: {actualSize}px'**
  String iconSizeDebug(Object actualSize, Object baseSize);

  /// No description provided for @idChanged_4821.
  ///
  /// In zh, this message translates to:
  /// **'ID变化'**
  String get idChanged_4821;

  /// No description provided for @idMappingInitFailed_7425.
  ///
  /// In zh, this message translates to:
  /// **'初始化ID映射失败: {e}'**
  String idMappingInitFailed_7425(Object e);

  /// No description provided for @ideaTag_8901.
  ///
  /// In zh, this message translates to:
  /// **'想法'**
  String get ideaTag_8901;

  /// No description provided for @idea_2345.
  ///
  /// In zh, this message translates to:
  /// **'想法'**
  String get idea_2345;

  /// No description provided for @idleStatus_6194.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get idleStatus_6194;

  /// No description provided for @idleStatus_6934.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get idleStatus_6934;

  /// No description provided for @idleStatus_6943.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get idleStatus_6943;

  /// No description provided for @idleStatus_7421.
  ///
  /// In zh, this message translates to:
  /// **'空闲状态'**
  String get idleStatus_7421;

  /// No description provided for @ignore_4821.
  ///
  /// In zh, this message translates to:
  /// **'忽略'**
  String get ignore_4821;

  /// No description provided for @ignoredMessageType_7281.
  ///
  /// In zh, this message translates to:
  /// **'ignoredMessageType: {messageType}'**
  String ignoredMessageType_7281(Object messageType);

  /// No description provided for @imageAreaLabel_4281.
  ///
  /// In zh, this message translates to:
  /// **'图片区域'**
  String get imageAreaLabel_4281;

  /// No description provided for @imageAssetExistsOnMap_7421.
  ///
  /// In zh, this message translates to:
  /// **'图像资产已在地图 [{mapTitle}] 中存在，跳过保存: {filename}'**
  String imageAssetExistsOnMap_7421(Object filename, Object mapTitle);

  /// No description provided for @imageBuffer_4821.
  ///
  /// In zh, this message translates to:
  /// **'图片缓冲区'**
  String get imageBuffer_4821;

  /// No description provided for @imageBuffer_7281.
  ///
  /// In zh, this message translates to:
  /// **'图片缓冲区'**
  String get imageBuffer_7281;

  /// No description provided for @imageCompressionFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'图片压缩失败: {e}'**
  String imageCompressionFailed_7284(Object e);

  /// No description provided for @imageCopiedToBuffer_7421.
  ///
  /// In zh, this message translates to:
  /// **'图片已从剪贴板读取到缓冲区\n大小: {sizeInKB}KB{mimeType, select, null{} other{ · 类型: {mimeType}}}'**
  String imageCopiedToBuffer_7421(String mimeType, Object sizeInKB);

  /// No description provided for @imageCopiedToClipboardLinux_4821.
  ///
  /// In zh, this message translates to:
  /// **'Linux: 图像已成功复制到剪贴板'**
  String get imageCopiedToClipboardLinux_4821;

  /// No description provided for @imageCopiedToClipboard_4821.
  ///
  /// In zh, this message translates to:
  /// **'macOS: 图像已成功复制到剪贴板'**
  String get imageCopiedToClipboard_4821;

  /// No description provided for @imageCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张图片'**
  String imageCount(Object count);

  /// No description provided for @imageCountText_7281.
  ///
  /// In zh, this message translates to:
  /// **'图片: {imageCount}'**
  String imageCountText_7281(Object imageCount);

  /// No description provided for @imageDataLoadedFromAssets.
  ///
  /// In zh, this message translates to:
  /// **'已从资产系统加载图像数据，哈希: {imageHash} ({bytes} bytes)'**
  String imageDataLoadedFromAssets(Object bytes, Object imageHash);

  /// No description provided for @imageDecodeFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'解码图片失败: {error}'**
  String imageDecodeFailed_4821(Object error);

  /// No description provided for @imageDescriptionHint_4522.
  ///
  /// In zh, this message translates to:
  /// **'请输入图片描述内容（可选）'**
  String get imageDescriptionHint_4522;

  /// No description provided for @imageDimensions.
  ///
  /// In zh, this message translates to:
  /// **'尺寸: {width} × {height}'**
  String imageDimensions(Object height, Object width);

  /// No description provided for @imageEditAreaRightClickOptions_4821.
  ///
  /// In zh, this message translates to:
  /// **'图片编辑区域 - 右键查看选项'**
  String get imageEditAreaRightClickOptions_4821;

  /// No description provided for @imageEditMenuTitle_7421.
  ///
  /// In zh, this message translates to:
  /// **'示例2：图片编辑菜单'**
  String get imageEditMenuTitle_7421;

  /// No description provided for @imageFetchFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取图片失败: {e}'**
  String imageFetchFailed(Object e);

  /// No description provided for @imageFitMethod_4821.
  ///
  /// In zh, this message translates to:
  /// **'图片适应方式'**
  String get imageFitMethod_4821;

  /// No description provided for @imageFitMethod_7281.
  ///
  /// In zh, this message translates to:
  /// **'图片适应方式'**
  String get imageFitMethod_7281;

  /// No description provided for @imageGenerationFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'图片生成失败'**
  String get imageGenerationFailed_4821;

  /// No description provided for @imageListTitle.
  ///
  /// In zh, this message translates to:
  /// **'图片列表 ({count}张)'**
  String imageListTitle(Object count);

  /// No description provided for @imageLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败: {error}'**
  String imageLoadFailed(Object error);

  /// No description provided for @imageLoadFailed_4721.
  ///
  /// In zh, this message translates to:
  /// **'图片显示失败'**
  String get imageLoadFailed_4721;

  /// No description provided for @imageLoadFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get imageLoadFailed_7281;

  /// No description provided for @imageLoadFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'图片显示失败'**
  String get imageLoadFailed_7421;

  /// No description provided for @imageLoadWarning.
  ///
  /// In zh, this message translates to:
  /// **'警告：无法从资产系统加载图像，哈希: {imageHash}'**
  String imageLoadWarning(Object imageHash);

  /// No description provided for @imageNotAvailable_7281.
  ///
  /// In zh, this message translates to:
  /// **'无法显示图片'**
  String get imageNotAvailable_7281;

  /// No description provided for @imageNoteLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'图片便签'**
  String get imageNoteLabel_4821;

  /// No description provided for @imageProcessingInstructions_4821.
  ///
  /// In zh, this message translates to:
  /// **'1. 点击\"上传图片\"选择文件或\"剪贴板\"粘贴图片\n2. 在画布上拖拽创建选区\n3. 图片将自动适应选区大小\n4. 可通过Z层级检视器调整'**
  String get imageProcessingInstructions_4821;

  /// No description provided for @imageRemoved_4821.
  ///
  /// In zh, this message translates to:
  /// **'图片已移除'**
  String get imageRemoved_4821;

  /// No description provided for @imageRotated_4821.
  ///
  /// In zh, this message translates to:
  /// **'图片已旋转'**
  String get imageRotated_4821;

  /// No description provided for @imageSavedToMapAssets.
  ///
  /// In zh, this message translates to:
  /// **'图像已保存到地图资产系统，哈希: {hash} ({length} bytes)'**
  String imageSavedToMapAssets(Object hash, Object length);

  /// No description provided for @imageSelectionArea_4832.
  ///
  /// In zh, this message translates to:
  /// **'图片选区'**
  String get imageSelectionArea_4832;

  /// No description provided for @imageSelectionCancelled_4521.
  ///
  /// In zh, this message translates to:
  /// **'已取消图片选择'**
  String get imageSelectionCancelled_4521;

  /// No description provided for @imageSelectionComplete_4821.
  ///
  /// In zh, this message translates to:
  /// **'✅ 图片选择完成！'**
  String get imageSelectionComplete_4821;

  /// No description provided for @imageSelectionDemo_4271.
  ///
  /// In zh, this message translates to:
  /// **'图片选择演示'**
  String get imageSelectionDemo_4271;

  /// No description provided for @imageSelectionError_4829.
  ///
  /// In zh, this message translates to:
  /// **'选择图片时发生错误: {e}'**
  String imageSelectionError_4829(Object e);

  /// No description provided for @imageSelectionTool_7912.
  ///
  /// In zh, this message translates to:
  /// **'图片选区'**
  String get imageSelectionTool_7912;

  /// No description provided for @imageSelection_4832.
  ///
  /// In zh, this message translates to:
  /// **'图片选区'**
  String get imageSelection_4832;

  /// No description provided for @imageSelection_5302.
  ///
  /// In zh, this message translates to:
  /// **'图片选区'**
  String get imageSelection_5302;

  /// No description provided for @imageSizeAndOffset_7281.
  ///
  /// In zh, this message translates to:
  /// **'图片大小: {imageSize}, 中心偏移: ({dx}, {dy})'**
  String imageSizeAndOffset_7281(Object dx, Object dy, Object imageSize);

  /// No description provided for @imageSpacing_3632.
  ///
  /// In zh, this message translates to:
  /// **'图片间距'**
  String get imageSpacing_3632;

  /// No description provided for @imageTitleHint_4522.
  ///
  /// In zh, this message translates to:
  /// **'请输入图片标题（可选）'**
  String get imageTitleHint_4522;

  /// No description provided for @imageTitleWithIndex.
  ///
  /// In zh, this message translates to:
  /// **'图片 {index}'**
  String imageTitleWithIndex(Object index);

  /// No description provided for @imageTooLargeError_4821.
  ///
  /// In zh, this message translates to:
  /// **'图片文件过大，请选择小于10MB的图片'**
  String get imageTooLargeError_4821;

  /// No description provided for @imageUploadFailed.
  ///
  /// In zh, this message translates to:
  /// **'上传图片失败: {e}'**
  String imageUploadFailed(Object e);

  /// No description provided for @imageUploadFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'图片上传失败: {e}'**
  String imageUploadFailed_7285(Object e);

  /// No description provided for @imageUploadInstructions_4821.
  ///
  /// In zh, this message translates to:
  /// **'1. 点击\"上传图片\"选择文件或\"剪贴板\"粘贴图片\n2. 在画布上拖拽创建选区\n3. 图片将自动适应选区大小\n4. 可通过Z层级检视器调整'**
  String get imageUploadInstructions_4821;

  /// No description provided for @imageUploadSuccess_4821.
  ///
  /// In zh, this message translates to:
  /// **'图片上传成功'**
  String get imageUploadSuccess_4821;

  /// No description provided for @imageUploadedToBuffer.
  ///
  /// In zh, this message translates to:
  /// **'图片已上传到缓冲区\n大小: {sizeInKB}KB{mimeType, select, null{} other{ · 类型: {mimeType}}}'**
  String imageUploadedToBuffer(String mimeType, Object sizeInKB);

  /// No description provided for @imageUrlLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'图片URL'**
  String get imageUrlLabel_4821;

  /// No description provided for @image_4821.
  ///
  /// In zh, this message translates to:
  /// **'图片'**
  String get image_4821;

  /// No description provided for @importConfigFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'导入配置失败: {error}'**
  String importConfigFailed_7421(Object error);

  /// No description provided for @importConfigFromJson_4821.
  ///
  /// In zh, this message translates to:
  /// **'从JSON数据导入配置'**
  String get importConfigFromJson_4821;

  /// No description provided for @importConfig_4271.
  ///
  /// In zh, this message translates to:
  /// **'导入配置'**
  String get importConfig_4271;

  /// No description provided for @importConfig_7421.
  ///
  /// In zh, this message translates to:
  /// **'导入配置'**
  String get importConfig_7421;

  /// No description provided for @importDatabase.
  ///
  /// In zh, this message translates to:
  /// **'导入数据库'**
  String get importDatabase;

  /// No description provided for @importExportBrowseData_4821.
  ///
  /// In zh, this message translates to:
  /// **'导入、导出和浏览应用数据'**
  String get importExportBrowseData_4821;

  /// No description provided for @importFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败：{error}'**
  String importFailed(Object error);

  /// No description provided for @importFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'导入失败'**
  String get importFailed_7281;

  /// No description provided for @importLegendDatabaseFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入图例数据库失败: {e}'**
  String importLegendDatabaseFailed(Object e);

  /// No description provided for @importLegendDbFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入图例数据库失败: {e}'**
  String importLegendDbFailed(Object e);

  /// No description provided for @importLegendFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'导入图例失败'**
  String get importLegendFailed_7281;

  /// No description provided for @importLocalizationFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'导入本地化文件失败: {e}'**
  String importLocalizationFailed_7285(Object e);

  /// No description provided for @importPreviewWithCount.
  ///
  /// In zh, this message translates to:
  /// **'导入预览 (共 {totalFiles} 个项目)'**
  String importPreviewWithCount(Object totalFiles);

  /// No description provided for @importSettings.
  ///
  /// In zh, this message translates to:
  /// **'导入设置'**
  String get importSettings;

  /// No description provided for @importSettingsFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'导入设置失败: {e}'**
  String importSettingsFailed_7421(Object e);

  /// No description provided for @import_4521.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get import_4521;

  /// No description provided for @importantTag_1234.
  ///
  /// In zh, this message translates to:
  /// **'重要'**
  String get importantTag_1234;

  /// No description provided for @important_1234.
  ///
  /// In zh, this message translates to:
  /// **'重要'**
  String get important_1234;

  /// No description provided for @important_4829.
  ///
  /// In zh, this message translates to:
  /// **'重要'**
  String get important_4829;

  /// No description provided for @important_4832.
  ///
  /// In zh, this message translates to:
  /// **'重要'**
  String get important_4832;

  /// No description provided for @importedFromJson_4822.
  ///
  /// In zh, this message translates to:
  /// **'(从JSON导入)'**
  String get importedFromJson_4822;

  /// No description provided for @importedMapLegendSettings.
  ///
  /// In zh, this message translates to:
  /// **'已导入地图 {mapId} 的图例组智能隐藏设置: {length} 项'**
  String importedMapLegendSettings(Object length, Object mapId);

  /// No description provided for @importedSuffix_4821.
  ///
  /// In zh, this message translates to:
  /// **'(导入)'**
  String get importedSuffix_4821;

  /// No description provided for @inProgress_7421.
  ///
  /// In zh, this message translates to:
  /// **'执行中'**
  String get inProgress_7421;

  /// No description provided for @includeLegends_3567.
  ///
  /// In zh, this message translates to:
  /// **'包含图例'**
  String get includeLegends_3567;

  /// No description provided for @includeLocalizations_4678.
  ///
  /// In zh, this message translates to:
  /// **'包含本地化'**
  String get includeLocalizations_4678;

  /// No description provided for @includeMaps_2456.
  ///
  /// In zh, this message translates to:
  /// **'包含地图'**
  String get includeMaps_2456;

  /// No description provided for @incompleteVersionData_7281.
  ///
  /// In zh, this message translates to:
  /// **'版本数据不完整'**
  String get incompleteVersionData_7281;

  /// No description provided for @increaseTextContrast_4821.
  ///
  /// In zh, this message translates to:
  /// **'提高文本和背景的对比度'**
  String get increaseTextContrast_4821;

  /// No description provided for @indexOutOfRange_7281.
  ///
  /// In zh, this message translates to:
  /// **'oldIndex 超出范围，跳过'**
  String get indexOutOfRange_7281;

  /// No description provided for @indonesianID_4877.
  ///
  /// In zh, this message translates to:
  /// **'印尼语 (印尼)'**
  String get indonesianID_4877;

  /// No description provided for @indonesian_4876.
  ///
  /// In zh, this message translates to:
  /// **'印尼语'**
  String get indonesian_4876;

  /// No description provided for @infoMessage_7284.
  ///
  /// In zh, this message translates to:
  /// **'信息消息'**
  String get infoMessage_7284;

  /// No description provided for @info_7554.
  ///
  /// In zh, this message translates to:
  /// **'信息'**
  String get info_7554;

  /// No description provided for @information_7281.
  ///
  /// In zh, this message translates to:
  /// **'信息'**
  String get information_7281;

  /// No description provided for @initMapEditorSystem_7281.
  ///
  /// In zh, this message translates to:
  /// **'初始化地图编辑器响应式系统'**
  String get initMapEditorSystem_7281;

  /// No description provided for @initReactiveScriptManager.
  ///
  /// In zh, this message translates to:
  /// **'初始化新响应式脚本管理器，地图标题: {mapTitle}'**
  String initReactiveScriptManager(Object mapTitle);

  /// No description provided for @initUserPrefsFailed.
  ///
  /// In zh, this message translates to:
  /// **'初始化用户偏好设置失败: {error}'**
  String initUserPrefsFailed(Object error);

  /// No description provided for @initVersionSession.
  ///
  /// In zh, this message translates to:
  /// **'初始化版本会话 [{arg0}/{arg1}]: {arg2}'**
  String initVersionSession(Object arg0, Object arg1, Object arg2);

  /// No description provided for @initialDataSetupSuccess.
  ///
  /// In zh, this message translates to:
  /// **'为新版本 [{versionId}] 设置初始数据成功'**
  String initialDataSetupSuccess(Object versionId);

  /// No description provided for @initialDataSyncComplete.
  ///
  /// In zh, this message translates to:
  /// **'初始数据同步完成 [{versionId}], 图层数: {layerCount}, 便签数: {noteCount}'**
  String initialDataSyncComplete(
    Object layerCount,
    Object noteCount,
    Object versionId,
  );

  /// No description provided for @initializationComplete_7421.
  ///
  /// In zh, this message translates to:
  /// **'初始化完成'**
  String get initializationComplete_7421;

  /// No description provided for @initializationFailed.
  ///
  /// In zh, this message translates to:
  /// **'初始化失败: {error}'**
  String initializationFailed(Object error);

  /// No description provided for @initializationFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'初始化失败: {e}'**
  String initializationFailed_7285(Object e);

  /// No description provided for @initializeWebSocketClientManager_4821.
  ///
  /// In zh, this message translates to:
  /// **'初始化 WebSocket 客户端管理器'**
  String get initializeWebSocketClientManager_4821;

  /// No description provided for @initializingAppDatabase_7281.
  ///
  /// In zh, this message translates to:
  /// **'开始初始化应用数据库...'**
  String get initializingAppDatabase_7281;

  /// No description provided for @initializingClientWithKey.
  ///
  /// In zh, this message translates to:
  /// **'开始使用 Web API Key 初始化客户端: {webApiKey}'**
  String initializingClientWithKey(Object webApiKey);

  /// No description provided for @initializingGlobalCollaborationService_7281.
  ///
  /// In zh, this message translates to:
  /// **'开始初始化 GlobalCollaborationService'**
  String get initializingGlobalCollaborationService_7281;

  /// No description provided for @initializingReactiveVersionManagement.
  ///
  /// In zh, this message translates to:
  /// **'开始初始化响应式版本管理，地图标题: {title}'**
  String initializingReactiveVersionManagement(Object title);

  /// No description provided for @initializingScriptEngine.
  ///
  /// In zh, this message translates to:
  /// **'初始化新响应式脚本引擎 (支持 {maxConcurrentExecutors} 个并发脚本)'**
  String initializingScriptEngine(Object maxConcurrentExecutors);

  /// No description provided for @initializingVfsSystem_7281.
  ///
  /// In zh, this message translates to:
  /// **'开始初始化应用VFS系统...'**
  String get initializingVfsSystem_7281;

  /// No description provided for @inlineCountUnit_4821.
  ///
  /// In zh, this message translates to:
  /// **'个'**
  String inlineCountUnit_4821(Object count);

  /// No description provided for @inlineFormula_7284.
  ///
  /// In zh, this message translates to:
  /// **'行内公式'**
  String get inlineFormula_7284;

  /// No description provided for @inputAvatarUrl_7281.
  ///
  /// In zh, this message translates to:
  /// **'输入头像URL'**
  String get inputAvatarUrl_7281;

  /// No description provided for @inputColorValue_4821.
  ///
  /// In zh, this message translates to:
  /// **'输入颜色值'**
  String get inputColorValue_4821;

  /// No description provided for @inputConfigName_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入配置名称'**
  String get inputConfigName_4821;

  /// No description provided for @inputDisplayName_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入显示名称'**
  String get inputDisplayName_4821;

  /// No description provided for @inputFolderPath_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入存储文件夹路径'**
  String get inputFolderPath_4821;

  /// No description provided for @inputIntegerHint_4521.
  ///
  /// In zh, this message translates to:
  /// **'请输入整数'**
  String get inputIntegerHint_4521;

  /// No description provided for @inputJsonData_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入JSON数据'**
  String get inputJsonData_4821;

  /// No description provided for @inputLabelHint_4521.
  ///
  /// In zh, this message translates to:
  /// **'输入标签名称'**
  String get inputLabelHint_4521;

  /// No description provided for @inputLinkOrSelectFile_4821.
  ///
  /// In zh, this message translates to:
  /// **'输入网络链接、选择VFS文件或绑定脚本'**
  String get inputLinkOrSelectFile_4821;

  /// No description provided for @inputMessageContent_7281.
  ///
  /// In zh, this message translates to:
  /// **'请输入消息内容'**
  String get inputMessageContent_7281;

  /// No description provided for @inputMessageHint_4521.
  ///
  /// In zh, this message translates to:
  /// **'输入要显示的消息内容'**
  String get inputMessageHint_4521;

  /// No description provided for @inputNewNameHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'输入新名称'**
  String get inputNewNameHint_4821;

  /// No description provided for @inputNumberHint_4522.
  ///
  /// In zh, this message translates to:
  /// **'输入数字'**
  String get inputNumberHint_4522;

  /// No description provided for @inputNumberHint_5732.
  ///
  /// In zh, this message translates to:
  /// **'输入数字'**
  String get inputNumberHint_5732;

  /// No description provided for @inputPrompt.
  ///
  /// In zh, this message translates to:
  /// **'请输入{name}'**
  String inputPrompt(Object name);

  /// No description provided for @inputUrlOrSelectVfsFile_4823.
  ///
  /// In zh, this message translates to:
  /// **'输入网络链接或选择VFS文件'**
  String get inputUrlOrSelectVfsFile_4823;

  /// No description provided for @insertToPlayQueue_7425.
  ///
  /// In zh, this message translates to:
  /// **'插入到播放队列[{index}]'**
  String insertToPlayQueue_7425(Object index);

  /// No description provided for @instructions_4521.
  ///
  /// In zh, this message translates to:
  /// **'使用说明'**
  String get instructions_4521;

  /// No description provided for @insufficientPathSegments.
  ///
  /// In zh, this message translates to:
  /// **'路径段不足: {absolutePath}'**
  String insufficientPathSegments(Object absolutePath);

  /// No description provided for @integerType_5678.
  ///
  /// In zh, this message translates to:
  /// **'整数'**
  String get integerType_5678;

  /// No description provided for @integrationAdapterAddLegendGroup.
  ///
  /// In zh, this message translates to:
  /// **'集成适配器: 添加图例组 {name}'**
  String integrationAdapterAddLegendGroup(Object name);

  /// No description provided for @integrationAdapterDeleteLegendGroup.
  ///
  /// In zh, this message translates to:
  /// **'集成适配器: 删除图例组 {legendGroupId}'**
  String integrationAdapterDeleteLegendGroup(Object legendGroupId);

  /// No description provided for @intensityPercentage.
  ///
  /// In zh, this message translates to:
  /// **'强度: {percentage}%'**
  String intensityPercentage(Object percentage);

  /// No description provided for @interfaceSwitchAnimation_7281.
  ///
  /// In zh, this message translates to:
  /// **'界面切换和过渡动画'**
  String get interfaceSwitchAnimation_7281;

  /// No description provided for @invalidAbsolutePathFormat.
  ///
  /// In zh, this message translates to:
  /// **'无效的绝对路径格式: {absolutePath}'**
  String invalidAbsolutePathFormat(Object absolutePath);

  /// No description provided for @invalidCharactersError_4821.
  ///
  /// In zh, this message translates to:
  /// **'名称包含无效字符: < > : \" / \\ | ? *'**
  String get invalidCharactersError_4821;

  /// No description provided for @invalidCharacters_4821.
  ///
  /// In zh, this message translates to:
  /// **'名称包含无效字符: < > : \" / \\ | ? *'**
  String get invalidCharacters_4821;

  /// No description provided for @invalidClipboardImageData_4271.
  ///
  /// In zh, this message translates to:
  /// **'剪贴板中的数据不是有效的图片文件'**
  String get invalidClipboardImageData_4271;

  /// No description provided for @invalidClipboardImageData_4821.
  ///
  /// In zh, this message translates to:
  /// **'剪贴板中的数据不是有效的图片文件'**
  String get invalidClipboardImageData_4821;

  /// No description provided for @invalidColorFormat_4821.
  ///
  /// In zh, this message translates to:
  /// **'无效的颜色格式，请检查输入'**
  String get invalidColorFormat_4821;

  /// No description provided for @invalidConfigCleanup.
  ///
  /// In zh, this message translates to:
  /// **'发现无效配置，准备清理: {clientId}'**
  String invalidConfigCleanup(Object clientId);

  /// No description provided for @invalidExportFileFormat_4821.
  ///
  /// In zh, this message translates to:
  /// **'导出文件格式不正确，缺少必要字段'**
  String get invalidExportFileFormat_4821;

  /// No description provided for @invalidImage.
  ///
  /// In zh, this message translates to:
  /// **'无效图片'**
  String get invalidImage;

  /// No description provided for @invalidImageData_7281.
  ///
  /// In zh, this message translates to:
  /// **'无效的图像数据'**
  String get invalidImageData_7281;

  /// No description provided for @invalidImageFileError_4821.
  ///
  /// In zh, this message translates to:
  /// **'无效的图片文件，请选择有效的图片'**
  String get invalidImageFileError_4821;

  /// No description provided for @invalidImageUrlError_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入图片URL（支持 jpg, png, gif 等格式）'**
  String get invalidImageUrlError_4821;

  /// No description provided for @invalidImportDataFormat_4271.
  ///
  /// In zh, this message translates to:
  /// **'无效的导入数据格式'**
  String get invalidImportDataFormat_4271;

  /// No description provided for @invalidImportDataFormat_7281.
  ///
  /// In zh, this message translates to:
  /// **'无效的导入数据格式'**
  String get invalidImportDataFormat_7281;

  /// No description provided for @invalidIntegerError_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的整数'**
  String get invalidIntegerError_4821;

  /// No description provided for @invalidLegendCenterPoint.
  ///
  /// In zh, this message translates to:
  /// **'图例 \"{title}\" 中心点坐标无效'**
  String invalidLegendCenterPoint(Object title);

  /// No description provided for @invalidLegendDataFormat_7281.
  ///
  /// In zh, this message translates to:
  /// **'图例数据格式不正确'**
  String get invalidLegendDataFormat_7281;

  /// No description provided for @invalidLegendVersion_7421.
  ///
  /// In zh, this message translates to:
  /// **'图例 \"{title}\" 版本号无效'**
  String invalidLegendVersion_7421(Object title);

  /// No description provided for @invalidMapDataFormat_7281.
  ///
  /// In zh, this message translates to:
  /// **'地图数据格式不正确'**
  String get invalidMapDataFormat_7281;

  /// No description provided for @invalidNameDotError_4821.
  ///
  /// In zh, this message translates to:
  /// **'名称不能以点号开头或结尾'**
  String get invalidNameDotError_4821;

  /// No description provided for @invalidNumberInput_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的数字'**
  String get invalidNumberInput_4821;

  /// No description provided for @invalidPathCharactersError_4821.
  ///
  /// In zh, this message translates to:
  /// **'存储路径只能包含字母、数字、斜杠(/)、下划线(_)、连字符(-)'**
  String get invalidPathCharactersError_4821;

  /// No description provided for @invalidPathFormat_4821.
  ///
  /// In zh, this message translates to:
  /// **'无效的路径格式'**
  String get invalidPathFormat_4821;

  /// No description provided for @invalidPath_4957.
  ///
  /// In zh, this message translates to:
  /// **'路径无效'**
  String get invalidPath_4957;

  /// No description provided for @invalidPathsFound_4918.
  ///
  /// In zh, this message translates to:
  /// **'存在无效路径，请修正后再试。无效路径数量：{count}'**
  String invalidPathsFound_4918(Object count);

  /// No description provided for @invalidRemoteDataFormat_7281.
  ///
  /// In zh, this message translates to:
  /// **'无效的远程数据格式'**
  String get invalidRemoteDataFormat_7281;

  /// No description provided for @invalidServerPath_4821.
  ///
  /// In zh, this message translates to:
  /// **'无效的服务器路径'**
  String get invalidServerPath_4821;

  /// No description provided for @invalidTagCharacters_4821.
  ///
  /// In zh, this message translates to:
  /// **'标签包含非法字符'**
  String get invalidTagCharacters_4821;

  /// No description provided for @invalidTargetPath_4920.
  ///
  /// In zh, this message translates to:
  /// **'目标路径不合法：{path}'**
  String invalidTargetPath_4920(Object path);

  /// No description provided for @invalidUrlPrompt_7281.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的 URL'**
  String get invalidUrlPrompt_7281;

  /// No description provided for @invalidVersionIdWarning.
  ///
  /// In zh, this message translates to:
  /// **'警告：正在编辑的版本ID无效: {activeEditingVersionId}'**
  String invalidVersionIdWarning(Object activeEditingVersionId);

  /// No description provided for @invalid_5739.
  ///
  /// In zh, this message translates to:
  /// **'无效'**
  String get invalid_5739;

  /// No description provided for @invalid_9352.
  ///
  /// In zh, this message translates to:
  /// **'无效'**
  String get invalid_9352;

  /// No description provided for @invert_3456.
  ///
  /// In zh, this message translates to:
  /// **'反色'**
  String get invert_3456;

  /// No description provided for @invert_4824.
  ///
  /// In zh, this message translates to:
  /// **'反色'**
  String get invert_4824;

  /// No description provided for @isInPlaylistCheck_7425.
  ///
  /// In zh, this message translates to:
  /// **'是否在播放列表中'**
  String get isInPlaylistCheck_7425;

  /// No description provided for @isSelectedCheck.
  ///
  /// In zh, this message translates to:
  /// **'是否选中: {isLegendSelected}'**
  String isSelectedCheck(Object isLegendSelected);

  /// No description provided for @isSelectedNote_7425.
  ///
  /// In zh, this message translates to:
  /// **'是否选中'**
  String get isSelectedNote_7425;

  /// No description provided for @italianIT_4887.
  ///
  /// In zh, this message translates to:
  /// **'意大利语 (意大利)'**
  String get italianIT_4887;

  /// No description provided for @italian_4832.
  ///
  /// In zh, this message translates to:
  /// **'意大利语'**
  String get italian_4832;

  /// No description provided for @itemsCutCount.
  ///
  /// In zh, this message translates to:
  /// **'已剪切 {count} 个项目'**
  String itemsCutCount(Object count);

  /// No description provided for @itemsCutMessage.
  ///
  /// In zh, this message translates to:
  /// **'已剪切 {count} 个项目'**
  String itemsCutMessage(Object count);

  /// No description provided for @iterateAllElements_1121.
  ///
  /// In zh, this message translates to:
  /// **'遍历所有元素'**
  String get iterateAllElements_1121;

  /// No description provided for @japaneseJP_4899.
  ///
  /// In zh, this message translates to:
  /// **'日语 (日本)'**
  String get japaneseJP_4899;

  /// No description provided for @japanese_4827.
  ///
  /// In zh, this message translates to:
  /// **'日语'**
  String get japanese_4827;

  /// No description provided for @jpegImageReadSuccess.
  ///
  /// In zh, this message translates to:
  /// **'super_clipboard: 从剪贴板成功读取JPEG图片，大小: {length} 字节'**
  String jpegImageReadSuccess(Object length);

  /// No description provided for @jsonDataHint_4522.
  ///
  /// In zh, this message translates to:
  /// **'粘贴配置JSON数据...'**
  String get jsonDataHint_4522;

  /// No description provided for @jsonDataLabel_4521.
  ///
  /// In zh, this message translates to:
  /// **'JSON数据'**
  String get jsonDataLabel_4521;

  /// No description provided for @jsonData_4821.
  ///
  /// In zh, this message translates to:
  /// **'JSON数据'**
  String get jsonData_4821;

  /// No description provided for @jsonFileNotExist_4821.
  ///
  /// In zh, this message translates to:
  /// **'JSON文件不存在: {jsonPath}'**
  String jsonFileNotExist_4821(Object jsonPath);

  /// No description provided for @jsonFileSearch_7281.
  ///
  /// In zh, this message translates to:
  /// **'查找JSON文件: {jsonPath} (原标题: \"{title}\" -> 清理后: \"{sanitizedTitle}\")'**
  String jsonFileSearch_7281(
    Object jsonPath,
    Object sanitizedTitle,
    Object title,
  );

  /// No description provided for @jsonFormatComplete_4821.
  ///
  /// In zh, this message translates to:
  /// **'JSON格式化完成'**
  String get jsonFormatComplete_4821;

  /// No description provided for @jsonFormatFailed.
  ///
  /// In zh, this message translates to:
  /// **'JSON格式化失败: {e}'**
  String jsonFormatFailed(Object e);

  /// No description provided for @jsonParseError_7282.
  ///
  /// In zh, this message translates to:
  /// **'Error parsing options JSON: {error}'**
  String jsonParseError_7282(Object error);

  /// No description provided for @jumpFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'跳转失败: {e}'**
  String jumpFailed_4821(Object e);

  /// No description provided for @jumpToDestination.
  ///
  /// In zh, this message translates to:
  /// **'已跳转到: {headingText}'**
  String jumpToDestination(Object headingText);

  /// No description provided for @justNow_4821.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get justNow_4821;

  /// No description provided for @keepOpenWhenLoseFocus_7281.
  ///
  /// In zh, this message translates to:
  /// **'保持开启'**
  String get keepOpenWhenLoseFocus_7281;

  /// No description provided for @keepTwoFilesRenameNew_4821.
  ///
  /// In zh, this message translates to:
  /// **'保留两个文件，重命名新文件'**
  String get keepTwoFilesRenameNew_4821;

  /// No description provided for @keyGenerationFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'生成服务器兼容密钥对失败: {e}'**
  String keyGenerationFailed_7285(Object e);

  /// No description provided for @keyboardShortcutsInitialized_7421.
  ///
  /// In zh, this message translates to:
  /// **'键盘快捷键操作实例初始化完成'**
  String get keyboardShortcutsInitialized_7421;

  /// No description provided for @koreanKR_4900.
  ///
  /// In zh, this message translates to:
  /// **'韩语 (韩国)'**
  String get koreanKR_4900;

  /// No description provided for @korean_4828.
  ///
  /// In zh, this message translates to:
  /// **'韩语'**
  String get korean_4828;

  /// No description provided for @labelName_4821.
  ///
  /// In zh, this message translates to:
  /// **'标签名称'**
  String get labelName_4821;

  /// No description provided for @label_4821.
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get label_4821;

  /// No description provided for @label_5421.
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get label_5421;

  /// No description provided for @landscapeOrientation_5678.
  ///
  /// In zh, this message translates to:
  /// **'横向'**
  String get landscapeOrientation_5678;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @languageCheckFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'检查语言可用性失败: {e}'**
  String languageCheckFailed_4821(Object e);

  /// No description provided for @languageCheckFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'检查语言可用性失败: {e}'**
  String languageCheckFailed_7285(Object e);

  /// No description provided for @languageLog_7284.
  ///
  /// In zh, this message translates to:
  /// **', language: {language}'**
  String languageLog_7284(Object language);

  /// No description provided for @languageSetting_4821.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get languageSetting_4821;

  /// No description provided for @languageUpdated.
  ///
  /// In zh, this message translates to:
  /// **'语言已更新为 {name}'**
  String languageUpdated(Object name);

  /// No description provided for @language_4821.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language_4821;

  /// No description provided for @largeBrush_4821.
  ///
  /// In zh, this message translates to:
  /// **'大画笔'**
  String get largeBrush_4821;

  /// No description provided for @largeFileWarning.
  ///
  /// In zh, this message translates to:
  /// **'🔗 VfsServiceProvider: 警告 - 文件较大（{fileSize}MB），可能影响性能'**
  String largeFileWarning(Object fileSize);

  /// No description provided for @lastLoginTime.
  ///
  /// In zh, this message translates to:
  /// **'最后登录: {time}'**
  String lastLoginTime(Object time);

  /// No description provided for @latencyWithValue.
  ///
  /// In zh, this message translates to:
  /// **'延迟: {value}ms'**
  String latencyWithValue(Object value);

  /// No description provided for @latexDisabled_7421.
  ///
  /// In zh, this message translates to:
  /// **'(禁用)'**
  String get latexDisabled_7421;

  /// No description provided for @latexErrorWarning.
  ///
  /// In zh, this message translates to:
  /// **'⚠️ LaTeX错误: {textContent}'**
  String latexErrorWarning(Object textContent);

  /// No description provided for @latexFormulaInfo_7281.
  ///
  /// In zh, this message translates to:
  /// **'LaTeX公式信息'**
  String get latexFormulaInfo_7281;

  /// No description provided for @latexFormulaStatistics_4821.
  ///
  /// In zh, this message translates to:
  /// **'LaTeX公式统计'**
  String get latexFormulaStatistics_4821;

  /// No description provided for @latexInfoTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'LaTeX信息'**
  String get latexInfoTooltip_7281;

  /// No description provided for @latexRenderingStatus_4821.
  ///
  /// In zh, this message translates to:
  /// **'LaTeX渲染状态'**
  String get latexRenderingStatus_4821;

  /// No description provided for @latvianLV_4869.
  ///
  /// In zh, this message translates to:
  /// **'拉脱维亚语 (拉脱维亚)'**
  String get latvianLV_4869;

  /// No description provided for @latvian_4868.
  ///
  /// In zh, this message translates to:
  /// **'拉脱维亚语'**
  String get latvian_4868;

  /// No description provided for @layer1_7281.
  ///
  /// In zh, this message translates to:
  /// **'图层 1'**
  String get layer1_7281;

  /// No description provided for @layerAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加图层 \"{name}\"'**
  String layerAdded(Object name);

  /// No description provided for @layerBackgroundLoaded.
  ///
  /// In zh, this message translates to:
  /// **'图层背景图已从资产系统加载，哈希: {hash} ({length} bytes)'**
  String layerBackgroundLoaded(Object hash, Object length);

  /// No description provided for @layerBackgroundUpdated_7281.
  ///
  /// In zh, this message translates to:
  /// **'图层 \"{name}\" 的背景图片设置已更新'**
  String layerBackgroundUpdated_7281(Object name);

  /// No description provided for @layerBinding_4271.
  ///
  /// In zh, this message translates to:
  /// **'图层绑定'**
  String get layerBinding_4271;

  /// No description provided for @layerCleared_4821.
  ///
  /// In zh, this message translates to:
  /// **'已清空图层标签'**
  String get layerCleared_4821;

  /// No description provided for @layerDataParseFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'解析图层数据失败: {e}'**
  String layerDataParseFailed_7421(Object e);

  /// No description provided for @layerDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已删除图层 \"{name}\"'**
  String layerDeleted(Object name);

  /// No description provided for @layerDeletionFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除图层失败 [{mapTitle}/{layerId}:{version}]: {e}'**
  String layerDeletionFailed(
    Object e,
    Object layerId,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @layerDeletionFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'删除图层失败: {error}'**
  String layerDeletionFailed_7421(Object error);

  /// No description provided for @layerElementLabelUpdated_4821.
  ///
  /// In zh, this message translates to:
  /// **'已更新图层元素标签'**
  String get layerElementLabelUpdated_4821;

  /// No description provided for @layerFilterSetMessage.
  ///
  /// In zh, this message translates to:
  /// **'图层 \"{layerName}\" 的色彩滤镜已设置为：{filterName}'**
  String layerFilterSetMessage(Object filterName, Object layerName);

  /// No description provided for @layerGroupInfo.
  ///
  /// In zh, this message translates to:
  /// **'图层组 {groupIndex} ({layerCount} 个图层)'**
  String layerGroupInfo(Object groupIndex, Object layerCount);

  /// No description provided for @layerGroupOrderUpdated_4821.
  ///
  /// In zh, this message translates to:
  /// **'图层组内顺序已更新'**
  String get layerGroupOrderUpdated_4821;

  /// No description provided for @layerGroupReorderLog.
  ///
  /// In zh, this message translates to:
  /// **'图层组重排序：oldIndex={oldIndex}, newIndex={newIndex}'**
  String layerGroupReorderLog(Object newIndex, Object oldIndex);

  /// No description provided for @layerGroupSelectionCancelled_4821.
  ///
  /// In zh, this message translates to:
  /// **'已取消图层组选择'**
  String get layerGroupSelectionCancelled_4821;

  /// No description provided for @layerGroupTitle.
  ///
  /// In zh, this message translates to:
  /// **'图层组 {groupNumber} ({layerCount}层)'**
  String layerGroupTitle(Object groupNumber, Object layerCount);

  /// No description provided for @layerGroupWithCount.
  ///
  /// In zh, this message translates to:
  /// **'图层组 ({count} 个图层)'**
  String layerGroupWithCount(Object count);

  /// No description provided for @layerGroup_4821.
  ///
  /// In zh, this message translates to:
  /// **'图层组'**
  String get layerGroup_4821;

  /// No description provided for @layerGroup_7281.
  ///
  /// In zh, this message translates to:
  /// **'图层组'**
  String get layerGroup_7281;

  /// No description provided for @layerGroups_4821.
  ///
  /// In zh, this message translates to:
  /// **'图层组'**
  String get layerGroups_4821;

  /// No description provided for @layerId.
  ///
  /// In zh, this message translates to:
  /// **'图层 ID: {id}'**
  String layerId(Object id);

  /// No description provided for @layerImageSavedToAssets.
  ///
  /// In zh, this message translates to:
  /// **'图层背景图已保存到资产系统，哈希: {hash} ({length} bytes)'**
  String layerImageSavedToAssets(Object hash, Object length);

  /// No description provided for @layerIndexOutOfRange_4821.
  ///
  /// In zh, this message translates to:
  /// **'找不到图层的全局索引或索引超出范围'**
  String get layerIndexOutOfRange_4821;

  /// No description provided for @layerLegendSettingsWidth_4821.
  ///
  /// In zh, this message translates to:
  /// **'设置图层图例绑定、图例组管理和Z层级检视器的宽度'**
  String get layerLegendSettingsWidth_4821;

  /// No description provided for @layerListLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载图层列表失败 [{mapTitle}:{version}]: {e}'**
  String layerListLoadFailed(Object e, Object mapTitle, Object version);

  /// No description provided for @layerLoadingFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'加载图层失败 [{mapTitle}/{layerId}:{version}]: {e}'**
  String layerLoadingFailed_4821(
    Object e,
    Object layerId,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @layerLockFailedPreviewQueued.
  ///
  /// In zh, this message translates to:
  /// **'无法锁定图层 {targetLayerId}，预览已加入队列'**
  String layerLockFailedPreviewQueued(Object targetLayerId);

  /// No description provided for @layerLockedPreviewQueued.
  ///
  /// In zh, this message translates to:
  /// **'图层 {targetLayerId} 被锁定，预览已加入队列'**
  String layerLockedPreviewQueued(Object targetLayerId);

  /// No description provided for @layerNameHint_7281.
  ///
  /// In zh, this message translates to:
  /// **'输入图层名称'**
  String get layerNameHint_7281;

  /// No description provided for @layerName_7421.
  ///
  /// In zh, this message translates to:
  /// **'图层: {name}'**
  String layerName_7421(Object name);

  /// No description provided for @layerNoElements_4822.
  ///
  /// In zh, this message translates to:
  /// **'图层没有绘制元素'**
  String get layerNoElements_4822;

  /// No description provided for @layerOperations_4821.
  ///
  /// In zh, this message translates to:
  /// **'图层操作'**
  String get layerOperations_4821;

  /// No description provided for @layerOrderText.
  ///
  /// In zh, this message translates to:
  /// **'顺序: {order}'**
  String layerOrderText(Object order);

  /// No description provided for @layerOrderUpdated_4821.
  ///
  /// In zh, this message translates to:
  /// **'图层顺序已更新'**
  String get layerOrderUpdated_4821;

  /// No description provided for @layerPanel_5678.
  ///
  /// In zh, this message translates to:
  /// **'图层面板'**
  String get layerPanel_5678;

  /// No description provided for @layerPreviewQueueCleared_4821.
  ///
  /// In zh, this message translates to:
  /// **'图层{layerId}的预览队列已清空'**
  String layerPreviewQueueCleared_4821(Object layerId);

  /// No description provided for @layerReorderDebug_7281.
  ///
  /// In zh, this message translates to:
  /// **'组内重排序图层: oldIndex={oldIndex}, newIndex={newIndex}, 更新图层数量: {length}'**
  String layerReorderDebug_7281(
    Object length,
    Object newIndex,
    Object oldIndex,
  );

  /// No description provided for @layerReorderFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'组内重排序图层失败: {error}'**
  String layerReorderFailed_7285(Object error);

  /// No description provided for @layerSaveFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'保存图层失败 [{mapTitle}/{layerId}:{version}]: {error}'**
  String layerSaveFailed_7421(
    Object error,
    Object layerId,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @layerSelectionSettings.
  ///
  /// In zh, this message translates to:
  /// **'图层选择设置'**
  String get layerSelectionSettings;

  /// No description provided for @layerSerializationFailed_4829.
  ///
  /// In zh, this message translates to:
  /// **'图层数据序列化失败: {e}'**
  String layerSerializationFailed_4829(Object e);

  /// No description provided for @layerSerializationFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'图层数据序列化失败: {e}'**
  String layerSerializationFailed_7284(Object e);

  /// No description provided for @layerSerializationSuccess.
  ///
  /// In zh, this message translates to:
  /// **'图层数据序列化成功，长度: {length}'**
  String layerSerializationSuccess(Object length);

  /// No description provided for @layerThemeDisabled_4821.
  ///
  /// In zh, this message translates to:
  /// **'您已禁用此图层的主题适配，当前使用自定义设置。'**
  String get layerThemeDisabled_4821;

  /// No description provided for @layerUpdateFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'更新图层失败: {error}'**
  String layerUpdateFailed_7421(Object error);

  /// No description provided for @layerVisibilityStatus.
  ///
  /// In zh, this message translates to:
  /// **'已启用：绑定的 {totalLayersCount} 个图层中有 {visibleLayersCount} 个可见，图例组已自动显示'**
  String layerVisibilityStatus(
    Object totalLayersCount,
    Object visibleLayersCount,
  );

  /// No description provided for @layer_1323.
  ///
  /// In zh, this message translates to:
  /// **'图层'**
  String get layer_1323;

  /// No description provided for @layer_4821.
  ///
  /// In zh, this message translates to:
  /// **'图层'**
  String get layer_4821;

  /// No description provided for @layers.
  ///
  /// In zh, this message translates to:
  /// **'图层'**
  String get layers;

  /// No description provided for @layersLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'图层'**
  String get layersLabel_4821;

  /// No description provided for @layersLabel_7281.
  ///
  /// In zh, this message translates to:
  /// **'图层'**
  String get layersLabel_7281;

  /// No description provided for @layersReorderedLog.
  ///
  /// In zh, this message translates to:
  /// **'调用 onLayersInGroupReordered({oldIndex}, {newIndex}, {count} 个图层更新)'**
  String layersReorderedLog(Object count, Object newIndex, Object oldIndex);

  /// No description provided for @layersTitle_7281.
  ///
  /// In zh, this message translates to:
  /// **'图层'**
  String get layersTitle_7281;

  /// No description provided for @layers_9101.
  ///
  /// In zh, this message translates to:
  /// **'个图层'**
  String layers_9101(Object count);

  /// No description provided for @layoutDataMigrationError.
  ///
  /// In zh, this message translates to:
  /// **'迁移 layout_data 时发生错误: {e}'**
  String layoutDataMigrationError(Object e);

  /// No description provided for @layoutResetSuccess_4821.
  ///
  /// In zh, this message translates to:
  /// **'布局设置已重置'**
  String get layoutResetSuccess_4821;

  /// No description provided for @layoutSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'界面布局设置'**
  String get layoutSettings_4821;

  /// No description provided for @layoutTypeName.
  ///
  /// In zh, this message translates to:
  /// **'布局: {layoutName}'**
  String layoutTypeName(Object layoutName);

  /// No description provided for @layoutType_7281.
  ///
  /// In zh, this message translates to:
  /// **'布局类型: '**
  String get layoutType_7281;

  /// No description provided for @learnMore_7421.
  ///
  /// In zh, this message translates to:
  /// **'了解'**
  String get learnMore_7421;

  /// No description provided for @leftText_4821.
  ///
  /// In zh, this message translates to:
  /// **'左'**
  String get leftText_4821;

  /// No description provided for @legend.
  ///
  /// In zh, this message translates to:
  /// **'图例'**
  String get legend;

  /// No description provided for @legendAddedSuccessfully_4821.
  ///
  /// In zh, this message translates to:
  /// **'添加图例成功'**
  String get legendAddedSuccessfully_4821;

  /// No description provided for @legendAddedToCache.
  ///
  /// In zh, this message translates to:
  /// **'图例已添加到缓存: {legendPath}'**
  String legendAddedToCache(Object legendPath);

  /// No description provided for @legendAddedToGroup.
  ///
  /// In zh, this message translates to:
  /// **'已将图例添加到 {name} ({count}个图例)'**
  String legendAddedToGroup(Object count, Object name);

  /// No description provided for @legendAlreadyExists_4271.
  ///
  /// In zh, this message translates to:
  /// **'图例已存在'**
  String get legendAlreadyExists_4271;

  /// No description provided for @legendBlockedMessage_4821.
  ///
  /// In zh, this message translates to:
  /// **'图例被遮挡'**
  String get legendBlockedMessage_4821;

  /// No description provided for @legendCacheCleaned.
  ///
  /// In zh, this message translates to:
  /// **'图例缓存 (步进型): 清理了目录 \"{folderPath}\" 下的 {count} 个缓存项（不包括子目录）'**
  String legendCacheCleaned(Object count, Object folderPath);

  /// No description provided for @legendCacheCleanupFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'在dispose中清理图例缓存失败: {e}'**
  String legendCacheCleanupFailed_7285(Object e);

  /// No description provided for @legendCacheCleanupInfo_4857.
  ///
  /// In zh, this message translates to:
  /// **'目录 \"{folderPath}\" 中有 {count} 个图例正在使用，将排除这些图例进行清理'**
  String legendCacheCleanupInfo_4857(Object count, Object folderPath);

  /// No description provided for @legendCacheCleanupSuccess_4858.
  ///
  /// In zh, this message translates to:
  /// **'已清理目录 \"{folderPath}\" 下的图例缓存（排除 {count} 个正在使用的图例）'**
  String legendCacheCleanupSuccess_4858(Object count, Object folderPath);

  /// No description provided for @legendCacheNoItemsToClean.
  ///
  /// In zh, this message translates to:
  /// **'图例缓存 (步进型): 目录 \"{folderPath}\" 下没有需要清理的缓存项'**
  String legendCacheNoItemsToClean(Object folderPath);

  /// No description provided for @legendCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个图例'**
  String legendCount(Object count);

  /// No description provided for @legendCountBeforeUpdate.
  ///
  /// In zh, this message translates to:
  /// **'更新前图例数量: {count}'**
  String legendCountBeforeUpdate(Object count);

  /// No description provided for @legendDataLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载图例数据失败: {legendPath}, 错误: {e}'**
  String legendDataLoadFailed(Object e, Object legendPath);

  /// No description provided for @legendDataParseFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'解析图例组数据失败: {e}'**
  String legendDataParseFailed_7285(Object e);

  /// No description provided for @legendDataStatus_4821.
  ///
  /// In zh, this message translates to:
  /// **'图例数据: {status}'**
  String legendDataStatus_4821(Object status);

  /// No description provided for @legendDeletedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'图例删除成功'**
  String get legendDeletedSuccessfully;

  /// No description provided for @legendDirectoryNotExist_7284.
  ///
  /// In zh, this message translates to:
  /// **'图例目录不存在: {absolutePath}'**
  String legendDirectoryNotExist_7284(Object absolutePath);

  /// No description provided for @legendExistsConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'图例 \"{legendTitle}\" 已存在，是否要覆盖现有图例？'**
  String legendExistsConfirmation(Object legendTitle);

  /// No description provided for @legendFilesFound_7281.
  ///
  /// In zh, this message translates to:
  /// **'在路径 {path} 中找到 {count} 个图例文件'**
  String legendFilesFound_7281(Object count, Object path);

  /// No description provided for @legendFromAbsolutePath.
  ///
  /// In zh, this message translates to:
  /// **'从绝对路径获取图例: \"{title}\", 路径: {absolutePath}'**
  String legendFromAbsolutePath(Object absolutePath, Object title);

  /// No description provided for @legendGroupAdded_7421.
  ///
  /// In zh, this message translates to:
  /// **'已添加图例组 \"{name}\"'**
  String legendGroupAdded_7421(Object name);

  /// No description provided for @legendGroupCleared_4281.
  ///
  /// In zh, this message translates to:
  /// **'已清空图例组标签'**
  String get legendGroupCleared_4281;

  /// No description provided for @legendGroupCount.
  ///
  /// In zh, this message translates to:
  /// **'图例组数量: {count}'**
  String legendGroupCount(Object count);

  /// No description provided for @legendGroupDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已删除图例组 \"{name}\"'**
  String legendGroupDeleted(Object name);

  /// No description provided for @legendGroupDrawerUpdate.
  ///
  /// In zh, this message translates to:
  /// **'图例组管理抽屉更新: {reason}'**
  String legendGroupDrawerUpdate(Object reason);

  /// No description provided for @legendGroupEmpty_7281.
  ///
  /// In zh, this message translates to:
  /// **'图例组没有图例项'**
  String get legendGroupEmpty_7281;

  /// No description provided for @legendGroupHiddenStatusSaved.
  ///
  /// In zh, this message translates to:
  /// **'图例组智能隐藏状态已保存: {mapId}/{legendGroupId} = {enabled}'**
  String legendGroupHiddenStatusSaved(
    Object enabled,
    Object legendGroupId,
    Object mapId,
  );

  /// No description provided for @legendGroupIdChanged.
  ///
  /// In zh, this message translates to:
  /// **'[CachedLegendsDisplay] 图例组ID变化: {oldId} -> {newId}，刷新缓存显示'**
  String legendGroupIdChanged(Object newId, Object oldId);

  /// No description provided for @legendGroupInfo.
  ///
  /// In zh, this message translates to:
  /// **'图例组 {index}: {name}, 可见: {isVisible}, 图例项: {length}'**
  String legendGroupInfo(
    Object index,
    Object isVisible,
    Object length,
    Object name,
  );

  /// No description provided for @legendGroupInvisible_7281.
  ///
  /// In zh, this message translates to:
  /// **'图例组不可见，返回空Widget'**
  String get legendGroupInvisible_7281;

  /// No description provided for @legendGroupItemCount.
  ///
  /// In zh, this message translates to:
  /// **'图例组: {count} 项'**
  String legendGroupItemCount(Object count);

  /// No description provided for @legendGroupItemsLoaded.
  ///
  /// In zh, this message translates to:
  /// **'图例组项加载完成: 共 {count} 个项目'**
  String legendGroupItemsLoaded(Object count);

  /// No description provided for @legendGroupLabel_4912.
  ///
  /// In zh, this message translates to:
  /// **'图例组标签'**
  String get legendGroupLabel_4912;

  /// No description provided for @legendGroupLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载图例组失败[{mapTitle}:{version}]: {e}'**
  String legendGroupLoadFailed(Object e, Object mapTitle, Object version);

  /// No description provided for @legendGroupManagementStatusSynced.
  ///
  /// In zh, this message translates to:
  /// **'图例组管理状态已同步: {name}'**
  String legendGroupManagementStatusSynced(Object name);

  /// No description provided for @legendGroupName.
  ///
  /// In zh, this message translates to:
  /// **'图例组 {count}'**
  String legendGroupName(Object count);

  /// No description provided for @legendGroupName_4821.
  ///
  /// In zh, this message translates to:
  /// **'图例组名称'**
  String get legendGroupName_4821;

  /// No description provided for @legendGroupNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到图例组 {groupId}'**
  String legendGroupNotFound(Object groupId);

  /// No description provided for @legendGroupNotVisibleError_4821.
  ///
  /// In zh, this message translates to:
  /// **'无法选择图例：图例组当前不可见，请先显示图例组'**
  String get legendGroupNotVisibleError_4821;

  /// No description provided for @legendGroupSerializationFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'图例组数据序列化失败: {e}'**
  String legendGroupSerializationFailed_4821(Object e);

  /// No description provided for @legendGroupSerializationFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'图例组数据序列化失败: {e}'**
  String legendGroupSerializationFailed_7285(Object e);

  /// No description provided for @legendGroupSerializationSuccess.
  ///
  /// In zh, this message translates to:
  /// **'图例组数据序列化成功，长度: {length}'**
  String legendGroupSerializationSuccess(Object length);

  /// No description provided for @legendGroupSmartHideInitialized.
  ///
  /// In zh, this message translates to:
  /// **'图例组智能隐藏状态已初始化: {_legendGroupSmartHideStates}'**
  String legendGroupSmartHideInitialized(Object _legendGroupSmartHideStates);

  /// No description provided for @legendGroupSmartHideStatusUpdated.
  ///
  /// In zh, this message translates to:
  /// **'图例组 {legendGroupId} 智能隐藏状态已更新: {enabled}'**
  String legendGroupSmartHideStatusUpdated(
    Object enabled,
    Object legendGroupId,
  );

  /// No description provided for @legendGroupSmartHideStatus_7421.
  ///
  /// In zh, this message translates to:
  /// **'图例组 {legendGroupId} 智能隐藏状态: {isEnabled}'**
  String legendGroupSmartHideStatus_7421(
    Object isEnabled,
    Object legendGroupId,
  );

  /// No description provided for @legendGroupTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'左键：打开图例组管理\n右键：选择图例组'**
  String get legendGroupTooltip_7281;

  /// No description provided for @legendGroupUnavailable_5421.
  ///
  /// In zh, this message translates to:
  /// **'图例组不可用'**
  String get legendGroupUnavailable_5421;

  /// No description provided for @legendGroupUpdated.
  ///
  /// In zh, this message translates to:
  /// **'图例组标签已更新 ({count}个标签)'**
  String legendGroupUpdated(Object count);

  /// No description provided for @legendGroupVisibility.
  ///
  /// In zh, this message translates to:
  /// **'图例组可见性: {isVisible}'**
  String legendGroupVisibility(Object isVisible);

  /// No description provided for @legendGroupZoomFactorInitialized.
  ///
  /// In zh, this message translates to:
  /// **'图例组缩放因子状态已初始化: {_legendGroupZoomFactors}'**
  String legendGroupZoomFactorInitialized(Object _legendGroupZoomFactors);

  /// No description provided for @legendGroupZoomFactorSaved.
  ///
  /// In zh, this message translates to:
  /// **'图例组缩放因子已保存: {mapId}/{legendGroupId} = {zoomFactor}'**
  String legendGroupZoomFactorSaved(
    Object legendGroupId,
    Object mapId,
    Object zoomFactor,
  );

  /// No description provided for @legendGroupZoomUpdated_7281.
  ///
  /// In zh, this message translates to:
  /// **'图例组 {legendGroupId} 缩放因子已更新: {zoomFactor}'**
  String legendGroupZoomUpdated_7281(Object legendGroupId, Object zoomFactor);

  /// No description provided for @legendGroup_7421.
  ///
  /// In zh, this message translates to:
  /// **'图例组 {key}: {value}'**
  String legendGroup_7421(Object key, Object value);

  /// No description provided for @legendHasImageData.
  ///
  /// In zh, this message translates to:
  /// **'图例数据有图片: {hasImageData}'**
  String legendHasImageData(Object hasImageData);

  /// No description provided for @legendId_4821.
  ///
  /// In zh, this message translates to:
  /// **'图例ID: {id}'**
  String legendId_4821(Object id);

  /// No description provided for @legendImportSuccess_7421.
  ///
  /// In zh, this message translates to:
  /// **'成功导入图例'**
  String get legendImportSuccess_7421;

  /// No description provided for @legendInvisibleWidget_4821.
  ///
  /// In zh, this message translates to:
  /// **'图例不可见，返回空Widget'**
  String get legendInvisibleWidget_4821;

  /// No description provided for @legendItemCount.
  ///
  /// In zh, this message translates to:
  /// **'图例项数量: {count}'**
  String legendItemCount(Object count);

  /// No description provided for @legendItemCountChanged.
  ///
  /// In zh, this message translates to:
  /// **'图例项数量变化: {oldCount} -> {newCount}'**
  String legendItemCountChanged(Object newCount, Object oldCount);

  /// No description provided for @legendItemDeletionFailed_4827.
  ///
  /// In zh, this message translates to:
  /// **'删除图例项失败[{mapTitle}/{groupId}/{itemId}:{version}]: {e}'**
  String legendItemDeletionFailed_4827(
    Object e,
    Object groupId,
    Object itemId,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @legendItemFilePath.
  ///
  /// In zh, this message translates to:
  /// **'图例项文件路径: {itemPath}'**
  String legendItemFilePath(Object itemPath);

  /// No description provided for @legendItemInfo.
  ///
  /// In zh, this message translates to:
  /// **'图例项 {index}: {id}, 路径: {path}, 位置: ({dx}, {dy})'**
  String legendItemInfo(
    Object dx,
    Object dy,
    Object id,
    Object index,
    Object path,
  );

  /// No description provided for @legendItemJsonContent.
  ///
  /// In zh, this message translates to:
  /// **'图例项JSON内容: {itemJson}'**
  String legendItemJsonContent(Object itemJson);

  /// No description provided for @legendItemJsonSize.
  ///
  /// In zh, this message translates to:
  /// **'图例项JSON数据大小: {length} bytes'**
  String legendItemJsonSize(Object length);

  /// No description provided for @legendItemLabel_4521.
  ///
  /// In zh, this message translates to:
  /// **'图例项标签'**
  String get legendItemLabel_4521;

  /// No description provided for @legendItemLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载图例项失败[{mapTitle}/{groupId}/{itemId}:{version}]: {e}'**
  String legendItemLoadFailed(
    Object e,
    Object groupId,
    Object itemId,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @legendItemLoaded.
  ///
  /// In zh, this message translates to:
  /// **'成功加载图例项: {itemId}, legendPath={legendPath}, legendId={legendId}'**
  String legendItemLoaded(Object itemId, Object legendId, Object legendPath);

  /// No description provided for @legendItemNotFound.
  ///
  /// In zh, this message translates to:
  /// **'图例项文件不存在: {itemPath}'**
  String legendItemNotFound(Object itemPath);

  /// No description provided for @legendItemNotFound_7285.
  ///
  /// In zh, this message translates to:
  /// **'未找到图例项 {itemId}'**
  String legendItemNotFound_7285(Object itemId);

  /// No description provided for @legendItemParsedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'成功解析图例项: id={id}, legendPath={legendPath}, legendId={legendId}'**
  String legendItemParsedSuccessfully(
    Object id,
    Object legendId,
    Object legendPath,
  );

  /// No description provided for @legendItemSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存图例项失败[{mapTitle}/{groupId}/{itemId}:{version}]: {error}'**
  String legendItemSaveFailed(
    Object error,
    Object groupId,
    Object itemId,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @legendItemsCleared_4281.
  ///
  /// In zh, this message translates to:
  /// **'已清空图例项标签'**
  String get legendItemsCleared_4281;

  /// No description provided for @legendItemsPath_7285.
  ///
  /// In zh, this message translates to:
  /// **'图例项路径: {itemsPath}'**
  String legendItemsPath_7285(Object itemsPath);

  /// No description provided for @legendLabelsUpdated.
  ///
  /// In zh, this message translates to:
  /// **'图例项标签已更新 ({count}个标签)'**
  String legendLabelsUpdated(Object count);

  /// No description provided for @legendLinkOptional_4821.
  ///
  /// In zh, this message translates to:
  /// **'图例链接 (可选)'**
  String get legendLinkOptional_4821;

  /// No description provided for @legendLinkOptional_4822.
  ///
  /// In zh, this message translates to:
  /// **'图例链接 (可选)'**
  String get legendLinkOptional_4822;

  /// No description provided for @legendListTitle.
  ///
  /// In zh, this message translates to:
  /// **'图例列表 ({count})'**
  String legendListTitle(Object count);

  /// No description provided for @legendLoadError_7285.
  ///
  /// In zh, this message translates to:
  /// **'图例 \"{title}\" 加载错误: {error}'**
  String legendLoadError_7285(Object error, Object title);

  /// No description provided for @legendLoadFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'载入图例失败: {legendPath}, 错误: {e}'**
  String legendLoadFailed_7281(Object e, Object legendPath);

  /// No description provided for @legendLoadingFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'加载图例失败: {e}'**
  String legendLoadingFailed_7421(Object e);

  /// No description provided for @legendLoadingInfo.
  ///
  /// In zh, this message translates to:
  /// **'加载图例: title={title}, folderPath={folderPath}, 相对路径={actualPath}'**
  String legendLoadingInfo(Object actualPath, Object folderPath, Object title);

  /// No description provided for @legendLoadingPath_7421.
  ///
  /// In zh, this message translates to:
  /// **'加载图例: 绝对路径={actualPath}'**
  String legendLoadingPath_7421(Object actualPath);

  /// No description provided for @legendLoadingStatus.
  ///
  /// In zh, this message translates to:
  /// **'  - 图例未加载，是否正在加载: {isLoading}'**
  String legendLoadingStatus(Object isLoading);

  /// No description provided for @legendManagement_4821.
  ///
  /// In zh, this message translates to:
  /// **'图例管理'**
  String get legendManagement_4821;

  /// No description provided for @legendManager.
  ///
  /// In zh, this message translates to:
  /// **'图例管理'**
  String get legendManager;

  /// No description provided for @legendManagerEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无图例'**
  String get legendManagerEmpty;

  /// No description provided for @legendMetadataReadFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'读取图例元数据失败: {e}'**
  String legendMetadataReadFailed_7421(Object e);

  /// No description provided for @legendNoImageData_4821.
  ///
  /// In zh, this message translates to:
  /// **'图例没有图片数据且不在加载中，返回空Widget'**
  String get legendNoImageData_4821;

  /// No description provided for @legendOperationDisabled.
  ///
  /// In zh, this message translates to:
  /// **'无法操作图例：图例组\"{name}\"当前不可见'**
  String legendOperationDisabled(Object name);

  /// No description provided for @legendOperations_4821.
  ///
  /// In zh, this message translates to:
  /// **'图例操作'**
  String get legendOperations_4821;

  /// No description provided for @legendPanel_9012.
  ///
  /// In zh, this message translates to:
  /// **'图例面板'**
  String get legendPanel_9012;

  /// No description provided for @legendPathConversion.
  ///
  /// In zh, this message translates to:
  /// **'图例路径转换'**
  String get legendPathConversion;

  /// No description provided for @legendPathConversion_7281.
  ///
  /// In zh, this message translates to:
  /// **'图例会话管理器: 路径转换 {legendPath} -> {actualPath}'**
  String legendPathConversion_7281(Object actualPath, Object legendPath);

  /// No description provided for @legendPathDebug.
  ///
  /// In zh, this message translates to:
  /// **'图例路径: {legendPath}'**
  String legendPathDebug(Object legendPath);

  /// No description provided for @legendPathHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'选择或输入.legend文件路径'**
  String get legendPathHint_4821;

  /// No description provided for @legendPathLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'图例路径 (.legend)'**
  String get legendPathLabel_4821;

  /// No description provided for @legendPosition.
  ///
  /// In zh, this message translates to:
  /// **'图例位置: ({dx}, {dy})'**
  String legendPosition(Object dx, Object dy);

  /// No description provided for @legendReloadFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'图例 \"{title}\" 无法重新加载'**
  String legendReloadFailed_7421(Object title);

  /// No description provided for @legendRenderOrderDebug_7421.
  ///
  /// In zh, this message translates to:
  /// **'计算得到的 legendRenderOrder: {legendRenderOrder}'**
  String legendRenderOrderDebug_7421(Object legendRenderOrder);

  /// No description provided for @legendScaleDescription_4856.
  ///
  /// In zh, this message translates to:
  /// **'新拖拽的图例将根据此缩放因子和当前画布缩放级别自动调整大小'**
  String get legendScaleDescription_4856;

  /// No description provided for @legendSessionInitialized.
  ///
  /// In zh, this message translates to:
  /// **'图例会话初始化完成，图例数量: {count}'**
  String legendSessionInitialized(Object count);

  /// No description provided for @legendSessionInitialized_4821.
  ///
  /// In zh, this message translates to:
  /// **'已为现有地图数据初始化图例会话'**
  String get legendSessionInitialized_4821;

  /// No description provided for @legendSessionManagerBatchPreloadComplete.
  ///
  /// In zh, this message translates to:
  /// **'图例会话管理器: 批量预加载完成，数量: {count}'**
  String legendSessionManagerBatchPreloadComplete(Object count);

  /// No description provided for @legendSessionManagerError.
  ///
  /// In zh, this message translates to:
  /// **'图例会话管理器: 加载异常 {legendPath}, 错误: {e}'**
  String legendSessionManagerError(Object e, Object legendPath);

  /// No description provided for @legendSessionManagerExists_7281.
  ///
  /// In zh, this message translates to:
  /// **'图例会话管理器存在: {value}'**
  String legendSessionManagerExists_7281(Object value);

  /// No description provided for @legendSessionManagerInitialized.
  ///
  /// In zh, this message translates to:
  /// **'图例会话管理器: 初始化完成，预加载图例数量: {count}'**
  String legendSessionManagerInitialized(Object count);

  /// No description provided for @legendSessionManagerLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'图例会话管理器: 加载失败 {legendPath}'**
  String legendSessionManagerLoadFailed(Object legendPath);

  /// No description provided for @legendSessionManagerLoaded.
  ///
  /// In zh, this message translates to:
  /// **'图例会话管理器: 成功加载 {legendPath}'**
  String legendSessionManagerLoaded(Object legendPath);

  /// No description provided for @legendSessionManagerPathConversion.
  ///
  /// In zh, this message translates to:
  /// **'图例会话管理器: 路径转换 {legendPath} -> {actualPath}'**
  String legendSessionManagerPathConversion(
    Object actualPath,
    Object legendPath,
  );

  /// No description provided for @legendSessionManagerRemoveLegend_7281.
  ///
  /// In zh, this message translates to:
  /// **'图例会话管理器: 移除图例 {legendPath}'**
  String legendSessionManagerRemoveLegend_7281(Object legendPath);

  /// No description provided for @legendSessionManagerRetryCount.
  ///
  /// In zh, this message translates to:
  /// **'图例会话管理器: 重试失败的图例，数量: {count}'**
  String legendSessionManagerRetryCount(Object count);

  /// No description provided for @legendSessionManagerStatus_7281.
  ///
  /// In zh, this message translates to:
  /// **'图例会话管理器状态:'**
  String get legendSessionManagerStatus_7281;

  /// No description provided for @legendSizeValue_4821.
  ///
  /// In zh, this message translates to:
  /// **'{value}'**
  String legendSizeValue_4821(Object value);

  /// No description provided for @legendSize_4821.
  ///
  /// In zh, this message translates to:
  /// **'图例大小'**
  String get legendSize_4821;

  /// No description provided for @legendTitle.
  ///
  /// In zh, this message translates to:
  /// **'图例: {count}'**
  String legendTitle(Object count);

  /// No description provided for @legendTitleEmpty_7281.
  ///
  /// In zh, this message translates to:
  /// **'图例标题为空'**
  String get legendTitleEmpty_7281;

  /// No description provided for @legendTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'图例'**
  String get legendTitle_4821;

  /// No description provided for @legendUpdateSuccess_7284.
  ///
  /// In zh, this message translates to:
  /// **'图例更新成功'**
  String get legendUpdateSuccess_7284;

  /// No description provided for @legendVersion.
  ///
  /// In zh, this message translates to:
  /// **'图例版本'**
  String get legendVersion;

  /// No description provided for @legendVersionHintText_4821.
  ///
  /// In zh, this message translates to:
  /// **'输入图例版本号'**
  String get legendVersionHintText_4821;

  /// No description provided for @legendVersionHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'输入图例版本号'**
  String get legendVersionHint_4821;

  /// No description provided for @legendVisibility.
  ///
  /// In zh, this message translates to:
  /// **'图例可见性: {isVisible}'**
  String legendVisibility(Object isVisible);

  /// No description provided for @legendVisibilityStatus.
  ///
  /// In zh, this message translates to:
  /// **'图例是否可见: {isVisible}'**
  String legendVisibilityStatus(Object isVisible);

  /// No description provided for @length_8921.
  ///
  /// In zh, this message translates to:
  /// **'长度'**
  String get length_8921;

  /// No description provided for @licenseCopiedToClipboard_4821.
  ///
  /// In zh, this message translates to:
  /// **'许可证文本已复制到剪贴板'**
  String get licenseCopiedToClipboard_4821;

  /// No description provided for @licenseDescription_4907.
  ///
  /// In zh, this message translates to:
  /// **'开源许可证，保证软件自由'**
  String get licenseDescription_4907;

  /// No description provided for @licenseLegalese_7281.
  ///
  /// In zh, this message translates to:
  /// **'© 2024 R6BOX Team\n使用 GPL v3 许可证发布'**
  String get licenseLegalese_7281;

  /// No description provided for @licenseSection_4905.
  ///
  /// In zh, this message translates to:
  /// **'许可证'**
  String get licenseSection_4905;

  /// No description provided for @lightMode.
  ///
  /// In zh, this message translates to:
  /// **'浅色模式'**
  String get lightMode;

  /// No description provided for @lightTheme_4821.
  ///
  /// In zh, this message translates to:
  /// **'浅色主题'**
  String get lightTheme_4821;

  /// No description provided for @lightTheme_5421.
  ///
  /// In zh, this message translates to:
  /// **'浅色主题'**
  String get lightTheme_5421;

  /// No description provided for @line.
  ///
  /// In zh, this message translates to:
  /// **'直线'**
  String get line;

  /// No description provided for @lineCountText.
  ///
  /// In zh, this message translates to:
  /// **'行数: {lineCount}'**
  String lineCountText(Object lineCount);

  /// No description provided for @lineThickness_4521.
  ///
  /// In zh, this message translates to:
  /// **'线条粗细'**
  String get lineThickness_4521;

  /// No description provided for @lineToolLabel_4521.
  ///
  /// In zh, this message translates to:
  /// **'直线'**
  String get lineToolLabel_4521;

  /// No description provided for @lineTool_9012.
  ///
  /// In zh, this message translates to:
  /// **'直线'**
  String get lineTool_9012;

  /// No description provided for @lineWidthAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加线条宽度 {width}px'**
  String lineWidthAdded(Object width);

  /// No description provided for @lineWidthExists_4821.
  ///
  /// In zh, this message translates to:
  /// **'该线条宽度已存在'**
  String get lineWidthExists_4821;

  /// No description provided for @line_4821.
  ///
  /// In zh, this message translates to:
  /// **'直线'**
  String get line_4821;

  /// No description provided for @linkCount_7281.
  ///
  /// In zh, this message translates to:
  /// **'链接: {linkCount}'**
  String linkCount_7281(Object linkCount);

  /// No description provided for @linkSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'链接设置'**
  String get linkSettings_4821;

  /// No description provided for @linuxFeatures.
  ///
  /// In zh, this message translates to:
  /// **'Linux 功能：'**
  String get linuxFeatures;

  /// No description provided for @linuxPlatform.
  ///
  /// In zh, this message translates to:
  /// **'Linux 平台'**
  String get linuxPlatform;

  /// No description provided for @linuxSpecificFeatures.
  ///
  /// In zh, this message translates to:
  /// **'Linux 特定功能可以在这里实现。'**
  String get linuxSpecificFeatures;

  /// No description provided for @linuxXclipCopyFailed.
  ///
  /// In zh, this message translates to:
  /// **'Linux xclip 复制失败: {resultStderr}'**
  String linuxXclipCopyFailed(Object resultStderr);

  /// No description provided for @linuxXclipReadFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'Linux xclip 读取失败或剪贴板中没有图片'**
  String get linuxXclipReadFailed_7281;

  /// No description provided for @listItemContextMenu_4821.
  ///
  /// In zh, this message translates to:
  /// **'列表项右键菜单'**
  String get listItemContextMenu_4821;

  /// No description provided for @listItemTitle.
  ///
  /// In zh, this message translates to:
  /// **'列表项 {itemNumber}'**
  String listItemTitle(Object itemNumber);

  /// No description provided for @listView_4968.
  ///
  /// In zh, this message translates to:
  /// **'列表视图'**
  String get listView_4968;

  /// No description provided for @lithuanianLT_4871.
  ///
  /// In zh, this message translates to:
  /// **'立陶宛语 (立陶宛)'**
  String get lithuanianLT_4871;

  /// No description provided for @lithuanian_4870.
  ///
  /// In zh, this message translates to:
  /// **'立陶宛语'**
  String get lithuanian_4870;

  /// No description provided for @loadConfigFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载配置失败: {e}'**
  String loadConfigFailed(Object e);

  /// No description provided for @loadConfigFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'加载配置失败: {configError}'**
  String loadConfigFailed_4821(Object configError);

  /// No description provided for @loadFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get loadFailed_4821;

  /// No description provided for @loadFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get loadFailed_7281;

  /// No description provided for @loadFolderFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'加载文件夹失败: {e}'**
  String loadFolderFailed_7285(Object e);

  /// No description provided for @loadLegendFailed.
  ///
  /// In zh, this message translates to:
  /// **'从目录加载图例失败: {directoryPath}, 错误: {e}'**
  String loadLegendFailed(Object directoryPath, Object e);

  /// No description provided for @loadMapsFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载地图失败：{error}'**
  String loadMapsFailed(Object error);

  /// No description provided for @loadNoteDataFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载便签数据失败 [{mapTitle}:{version}]: {e}'**
  String loadNoteDataFailed(Object e, Object mapTitle, Object version);

  /// No description provided for @loadPathToCacheFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载路径到缓存失败: {path}, 错误: {e}'**
  String loadPathToCacheFailed(Object e, Object path);

  /// No description provided for @loadStickyNoteError_4827.
  ///
  /// In zh, this message translates to:
  /// **'加载便签数据失败 [{mapTitle}/{stickyNoteId}:{version}]: {e}'**
  String loadStickyNoteError_4827(
    Object e,
    Object mapTitle,
    Object stickyNoteId,
    Object version,
  );

  /// No description provided for @loadTextFileFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'加载文本文件失败: {e}'**
  String loadTextFileFailed_7421(Object e);

  /// No description provided for @loadUserPreferencesFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载当前用户偏好设置失败: {e}'**
  String loadUserPreferencesFailed(Object e);

  /// No description provided for @loadVersionDataFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'加载版本 {versionId} 数据失败: {error}，使用基础数据'**
  String loadVersionDataFailed_7421(Object error, Object versionId);

  /// No description provided for @loadVersionDataToReactiveSystem.
  ///
  /// In zh, this message translates to:
  /// **'从VFS加载版本数据 [{versionId}] 到响应式系统'**
  String loadVersionDataToReactiveSystem(Object versionId);

  /// No description provided for @loadedButUnselected_7281.
  ///
  /// In zh, this message translates to:
  /// **'未选中但已加载'**
  String get loadedButUnselected_7281;

  /// No description provided for @loadedToCache_7281.
  ///
  /// In zh, this message translates to:
  /// **'已加载到缓存: {legendPath}'**
  String loadedToCache_7281(Object legendPath);

  /// No description provided for @loaded_4821.
  ///
  /// In zh, this message translates to:
  /// **'已加载'**
  String get loaded_4821;

  /// No description provided for @loadingAudio_7281.
  ///
  /// In zh, this message translates to:
  /// **'正在加载音频...'**
  String get loadingAudio_7281;

  /// No description provided for @loadingAudio_7421.
  ///
  /// In zh, this message translates to:
  /// **'正在加载音频...'**
  String get loadingAudio_7421;

  /// No description provided for @loadingConfiguration_7281.
  ///
  /// In zh, this message translates to:
  /// **'加载配置'**
  String get loadingConfiguration_7281;

  /// No description provided for @loadingConfiguration_7421.
  ///
  /// In zh, this message translates to:
  /// **'加载配置'**
  String get loadingConfiguration_7421;

  /// No description provided for @loadingImage_7281.
  ///
  /// In zh, this message translates to:
  /// **'加载图片中...'**
  String get loadingImage_7281;

  /// No description provided for @loadingLegendItem.
  ///
  /// In zh, this message translates to:
  /// **'正在加载图例项: {itemId}'**
  String loadingLegendItem(Object itemId);

  /// No description provided for @loadingMapDetails.
  ///
  /// In zh, this message translates to:
  /// **'加载地图: {mapTitle}, 版本: {version}, 文件夹: {folderPath}'**
  String loadingMapDetails(Object folderPath, Object mapTitle, Object version);

  /// No description provided for @loadingMapToReactiveSystem.
  ///
  /// In zh, this message translates to:
  /// **'加载地图到响应式系统: {title}'**
  String loadingMapToReactiveSystem(Object title);

  /// No description provided for @loadingMarkdownFile_7421.
  ///
  /// In zh, this message translates to:
  /// **'加载Markdown文件中...'**
  String get loadingMarkdownFile_7421;

  /// No description provided for @loadingNoteWithElements.
  ///
  /// In zh, this message translates to:
  /// **'加载便签[{i}] {title}: {count}个绘画元素'**
  String loadingNoteWithElements(Object count, Object i, Object title);

  /// No description provided for @loadingPathToCache.
  ///
  /// In zh, this message translates to:
  /// **'加载路径到缓存: {legendGroupId} -> {path}'**
  String loadingPathToCache(Object legendGroupId, Object path);

  /// No description provided for @loadingPathToCache_7281.
  ///
  /// In zh, this message translates to:
  /// **'正在加载路径到缓存: {path}'**
  String loadingPathToCache_7281(Object path);

  /// No description provided for @loadingStateMessage_5421.
  ///
  /// In zh, this message translates to:
  /// **'  - 加载状态: {loadingState}'**
  String loadingStateMessage_5421(Object loadingState);

  /// No description provided for @loadingStatusCheck.
  ///
  /// In zh, this message translates to:
  /// **'是否正在加载: {isLoading}'**
  String loadingStatusCheck(Object isLoading);

  /// No description provided for @loadingStoredVersionFromVfs_4821.
  ///
  /// In zh, this message translates to:
  /// **'开始从VFS加载已存储的版本...'**
  String get loadingStoredVersionFromVfs_4821;

  /// No description provided for @loadingSvgFiles_5421.
  ///
  /// In zh, this message translates to:
  /// **'正在加载 SVG 文件...'**
  String get loadingSvgFiles_5421;

  /// No description provided for @loadingTextFile_7281.
  ///
  /// In zh, this message translates to:
  /// **'加载文本文件中...'**
  String get loadingTextFile_7281;

  /// No description provided for @loadingText_4821.
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get loadingText_4821;

  /// No description provided for @loadingText_7281.
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get loadingText_7281;

  /// No description provided for @loadingVersionData_7281.
  ///
  /// In zh, this message translates to:
  /// **'从VFS加载版本 {versionId} 数据，图层数: {layerCount}, 便签数: {noteCount}'**
  String loadingVersionData_7281(
    Object layerCount,
    Object noteCount,
    Object versionId,
  );

  /// No description provided for @loadingVfsDirectory_7421.
  ///
  /// In zh, this message translates to:
  /// **'正在加载VFS目录结构...'**
  String get loadingVfsDirectory_7421;

  /// No description provided for @loadingVideo_7281.
  ///
  /// In zh, this message translates to:
  /// **'正在加载视频...'**
  String get loadingVideo_7281;

  /// No description provided for @loadingVideo_7421.
  ///
  /// In zh, this message translates to:
  /// **'正在加载视频...'**
  String get loadingVideo_7421;

  /// No description provided for @loading_5421.
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get loading_5421;

  /// No description provided for @localImageSize_7421.
  ///
  /// In zh, this message translates to:
  /// **'本地图片 ({size} KB)'**
  String localImageSize_7421(Object size);

  /// No description provided for @localImport_4974.
  ///
  /// In zh, this message translates to:
  /// **'本地导入'**
  String get localImport_4974;

  /// No description provided for @localizationFileUploadSuccess_4821.
  ///
  /// In zh, this message translates to:
  /// **'本地化文件上传成功'**
  String get localizationFileUploadSuccess_4821;

  /// No description provided for @localizationVersionNotHigher.
  ///
  /// In zh, this message translates to:
  /// **'本地化文件版本 {version} 不高于当前版本 {currentVersion}，跳过导入'**
  String localizationVersionNotHigher(Object currentVersion, Object version);

  /// No description provided for @localizationVersionTooLowOrUploadCancelled_7281.
  ///
  /// In zh, this message translates to:
  /// **'本地化文件版本过低或取消上传'**
  String get localizationVersionTooLowOrUploadCancelled_7281;

  /// No description provided for @lockConflictDescription.
  ///
  /// In zh, this message translates to:
  /// **'用户 {userName} 尝试锁定已被锁定的元素'**
  String lockConflictDescription(Object userName);

  /// No description provided for @lockConflict_4828.
  ///
  /// In zh, this message translates to:
  /// **'锁定冲突'**
  String get lockConflict_4828;

  /// No description provided for @logCleanupComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'日志文件清理完成'**
  String get logCleanupComplete_7281;

  /// No description provided for @logCleanupError_5421.
  ///
  /// In zh, this message translates to:
  /// **'清理日志文件时发生错误: {e}'**
  String logCleanupError_5421(Object e);

  /// No description provided for @logCleanupTime.
  ///
  /// In zh, this message translates to:
  /// **'日志文件清理耗时: {elapsedMilliseconds}ms'**
  String logCleanupTime(Object elapsedMilliseconds);

  /// No description provided for @logCleared_7281.
  ///
  /// In zh, this message translates to:
  /// **'日志已清空'**
  String get logCleared_7281;

  /// No description provided for @logDeletionFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'删除日志文件失败: {path}, 错误: {error}'**
  String logDeletionFailed_7421(Object error, Object path);

  /// No description provided for @lowPriorityTag_0123.
  ///
  /// In zh, this message translates to:
  /// **'低优先级'**
  String get lowPriorityTag_0123;

  /// No description provided for @low_7284.
  ///
  /// In zh, this message translates to:
  /// **'低'**
  String get low_7284;

  /// No description provided for @macOSFeatures.
  ///
  /// In zh, this message translates to:
  /// **'macOS 功能：'**
  String get macOSFeatures;

  /// No description provided for @macOSNotifications.
  ///
  /// In zh, this message translates to:
  /// **'macOS 通知'**
  String get macOSNotifications;

  /// No description provided for @macOSPlatform.
  ///
  /// In zh, this message translates to:
  /// **'macOS 平台'**
  String get macOSPlatform;

  /// No description provided for @macOSSpecificFeatures.
  ///
  /// In zh, this message translates to:
  /// **'可以在此处实现 macOS 特定功能。'**
  String get macOSSpecificFeatures;

  /// No description provided for @macOsCopyFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'macOS osascript 复制失败: {error}'**
  String macOsCopyFailed_7421(Object error);

  /// No description provided for @macOsScriptReadFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'macOS osascript 读取失败或剪贴板中没有图片'**
  String get macOsScriptReadFailed_7281;

  /// No description provided for @malayMY_4879.
  ///
  /// In zh, this message translates to:
  /// **'马来语 (马来西亚)'**
  String get malayMY_4879;

  /// No description provided for @malay_4878.
  ///
  /// In zh, this message translates to:
  /// **'马来语'**
  String get malay_4878;

  /// No description provided for @manageCustomTags_4271.
  ///
  /// In zh, this message translates to:
  /// **'管理自定义标签'**
  String get manageCustomTags_4271;

  /// No description provided for @manageCustomTags_7421.
  ///
  /// In zh, this message translates to:
  /// **'管理自定义标签'**
  String get manageCustomTags_7421;

  /// No description provided for @manageLayerTagsTitle.
  ///
  /// In zh, this message translates to:
  /// **'管理图层标签 - {name}'**
  String manageLayerTagsTitle(Object name);

  /// No description provided for @manageLegendGroupLegends_4821.
  ///
  /// In zh, this message translates to:
  /// **'管理图例组中的图例'**
  String get manageLegendGroupLegends_4821;

  /// No description provided for @manageLegendGroupTagsTitle.
  ///
  /// In zh, this message translates to:
  /// **'管理图例组标签 - {name}'**
  String manageLegendGroupTagsTitle(Object name);

  /// No description provided for @manageLegendGroup_7421.
  ///
  /// In zh, this message translates to:
  /// **'管理图例组'**
  String get manageLegendGroup_7421;

  /// No description provided for @manageLegendTagsTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'管理图例项标签'**
  String get manageLegendTagsTitle_4821;

  /// No description provided for @manageLineWidths_4821.
  ///
  /// In zh, this message translates to:
  /// **'管理常用线条宽度'**
  String get manageLineWidths_4821;

  /// No description provided for @manageNoteTagsTitle.
  ///
  /// In zh, this message translates to:
  /// **'管理便签标签 - {title}'**
  String manageNoteTagsTitle(Object title);

  /// No description provided for @manageStrokeWidths_4821.
  ///
  /// In zh, this message translates to:
  /// **'管理常用线条宽度'**
  String get manageStrokeWidths_4821;

  /// No description provided for @manageTagsTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'管理标签'**
  String get manageTagsTitle_4821;

  /// No description provided for @manageTagsTitle_7421.
  ///
  /// In zh, this message translates to:
  /// **'管理 {type} 标签'**
  String manageTagsTitle_7421(Object type);

  /// No description provided for @manageTags_4271.
  ///
  /// In zh, this message translates to:
  /// **'管理标签'**
  String get manageTags_4271;

  /// No description provided for @manageTags_4821.
  ///
  /// In zh, this message translates to:
  /// **'管理标签'**
  String get manageTags_4821;

  /// No description provided for @manageTimers_4821.
  ///
  /// In zh, this message translates to:
  /// **'管理计时器'**
  String get manageTimers_4821;

  /// No description provided for @manage_4915.
  ///
  /// In zh, this message translates to:
  /// **'管理'**
  String get manage_4915;

  /// No description provided for @management_4821.
  ///
  /// In zh, this message translates to:
  /// **'管理'**
  String get management_4821;

  /// No description provided for @management_7281.
  ///
  /// In zh, this message translates to:
  /// **'管理'**
  String get management_7281;

  /// No description provided for @manualWindowSizeSetting_4821.
  ///
  /// In zh, this message translates to:
  /// **'手动设置窗口的默认大小'**
  String get manualWindowSizeSetting_4821;

  /// No description provided for @mapAddedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'地图添加成功'**
  String get mapAddedSuccessfully;

  /// No description provided for @mapAlreadyExists_4271.
  ///
  /// In zh, this message translates to:
  /// **'地图已存在'**
  String get mapAlreadyExists_4271;

  /// No description provided for @mapAndResponsiveSystemInitFailed.
  ///
  /// In zh, this message translates to:
  /// **'地图和响应式系统初始化失败: {e}'**
  String mapAndResponsiveSystemInitFailed(Object e);

  /// No description provided for @mapAreaCopiedToClipboard.
  ///
  /// In zh, this message translates to:
  /// **'Web: 地图选中区域已成功复制到剪贴板: {width}x{height}'**
  String mapAreaCopiedToClipboard(Object height, Object width);

  /// No description provided for @mapAtlas.
  ///
  /// In zh, this message translates to:
  /// **'地图册'**
  String get mapAtlas;

  /// No description provided for @mapAtlasEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无地图'**
  String get mapAtlasEmpty;

  /// No description provided for @mapAtlas_4821.
  ///
  /// In zh, this message translates to:
  /// **'地图册'**
  String get mapAtlas_4821;

  /// No description provided for @mapBackupCreated.
  ///
  /// In zh, this message translates to:
  /// **'地图备份创建完成: {mapId} -> {backupPath} ({length} bytes)'**
  String mapBackupCreated(Object backupPath, Object length, Object mapId);

  /// No description provided for @mapBackupFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'创建地图备份失败: {e}'**
  String mapBackupFailed_7285(Object e);

  /// No description provided for @mapClearedMessage_4827.
  ///
  /// In zh, this message translates to:
  /// **'已清除地图信息'**
  String get mapClearedMessage_4827;

  /// No description provided for @mapContentArea_7281.
  ///
  /// In zh, this message translates to:
  /// **'地图内容区域'**
  String get mapContentArea_7281;

  /// No description provided for @mapCoverCompressionFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'地图封面压缩失败，将不同步封面信息'**
  String get mapCoverCompressionFailed_4821;

  /// No description provided for @mapCoverCompressionFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'地图封面压缩失败'**
  String get mapCoverCompressionFailed_7281;

  /// No description provided for @mapCoverLoadFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'加载地图封面失败: {e}'**
  String mapCoverLoadFailed_7285(Object e);

  /// No description provided for @mapCoverRecompressed.
  ///
  /// In zh, this message translates to:
  /// **'地图封面已重新压缩: {oldSize}KB -> {newSize}KB'**
  String mapCoverRecompressed(Object newSize, Object oldSize);

  /// No description provided for @mapCoverUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新地图封面失败 [{arg0}]: {arg1}'**
  String mapCoverUpdateFailed(Object arg0, Object arg1);

  /// No description provided for @mapCoverUpdatedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'地图封面更新成功: {mapTitle}'**
  String mapCoverUpdatedSuccessfully(Object mapTitle);

  /// No description provided for @mapCoverUpdatedSuccessfully_4849.
  ///
  /// In zh, this message translates to:
  /// **'地图封面更新成功'**
  String get mapCoverUpdatedSuccessfully_4849;

  /// No description provided for @mapDataInitializationFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'初始化地图数据失败: {error}'**
  String mapDataInitializationFailed_7421(Object error);

  /// No description provided for @mapDataLoadFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'加载地图数据失败: {e}'**
  String mapDataLoadFailed_7284(Object e);

  /// No description provided for @mapDataLoadFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'加载地图数据失败: {error}'**
  String mapDataLoadFailed_7421(Object error);

  /// No description provided for @mapDataLoadedEvent_4821.
  ///
  /// In zh, this message translates to:
  /// **'=== 响应式监听器收到 MapDataLoaded 事件 ==='**
  String get mapDataLoadedEvent_4821;

  /// No description provided for @mapDataLoadedToReactiveSystem.
  ///
  /// In zh, this message translates to:
  /// **'地图数据已加载到响应式系统: {title}'**
  String mapDataLoadedToReactiveSystem(Object title);

  /// No description provided for @mapDataLoaded_7421.
  ///
  /// In zh, this message translates to:
  /// **'地图数据加载完成: {title}'**
  String mapDataLoaded_7421(Object title);

  /// No description provided for @mapDataSaveFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'保存地图数据失败: {error}'**
  String mapDataSaveFailed_7421(Object error);

  /// No description provided for @mapDatabaseCloseFailed.
  ///
  /// In zh, this message translates to:
  /// **'关闭地图数据库失败: {e}'**
  String mapDatabaseCloseFailed(Object e);

  /// No description provided for @mapDatabaseServiceError_4821.
  ///
  /// In zh, this message translates to:
  /// **'MapDatabaseService.updateMap 错误:'**
  String get mapDatabaseServiceError_4821;

  /// No description provided for @mapDatabaseServiceUpdateMapStart_7281.
  ///
  /// In zh, this message translates to:
  /// **'MapDatabaseService.updateMap 开始执行'**
  String get mapDatabaseServiceUpdateMapStart_7281;

  /// No description provided for @mapDeletedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'地图删除成功'**
  String get mapDeletedSuccessfully;

  /// No description provided for @mapDeletionFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'删除地图失败 [{mapTitle}]: {e}'**
  String mapDeletionFailed_7421(Object e, Object mapTitle);

  /// No description provided for @mapEditor.
  ///
  /// In zh, this message translates to:
  /// **'地图编辑器'**
  String get mapEditor;

  /// No description provided for @mapEditorCallComplete_7421.
  ///
  /// In zh, this message translates to:
  /// **'调用完成'**
  String get mapEditorCallComplete_7421;

  /// No description provided for @mapEditorExitCleanup_4821.
  ///
  /// In zh, this message translates to:
  /// **'地图编辑器退出：已清理所有图例缓存'**
  String get mapEditorExitCleanup_4821;

  /// No description provided for @mapEditorExitMessage_4821.
  ///
  /// In zh, this message translates to:
  /// **'地图编辑器退出：已清理所有颜色滤镜'**
  String get mapEditorExitMessage_4821;

  /// No description provided for @mapEditorSettings_7421.
  ///
  /// In zh, this message translates to:
  /// **'地图编辑器设置'**
  String get mapEditorSettings_7421;

  /// No description provided for @mapEditorUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新地图编辑器设置失败: {error}'**
  String mapEditorUpdateFailed(Object error);

  /// No description provided for @mapEditorUpdateLegendGroup.
  ///
  /// In zh, this message translates to:
  /// **'地图编辑器：更新图例组 {name}'**
  String mapEditorUpdateLegendGroup(Object name);

  /// No description provided for @mapExistsConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'地图 \"{mapTitle}\" 已存在，是否要覆盖现有地图？'**
  String mapExistsConfirmation(Object mapTitle);

  /// No description provided for @mapFetchFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'获取地图数量失败: {e}'**
  String mapFetchFailed_7284(Object e);

  /// Log message when map ID changes
  ///
  /// In zh, this message translates to:
  /// **'地图ID变更: {oldMapId} -> {newMapId}'**
  String mapIdChanged(Object oldMapId, Object newMapId);

  /// No description provided for @mapIdDebug.
  ///
  /// In zh, this message translates to:
  /// **'地图ID: {id}'**
  String mapIdDebug(Object id);

  /// No description provided for @mapIdLookupFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'无法通过ID查找地图，VFS系统使用基于标题的存储: {id}'**
  String mapIdLookupFailed_7421(Object id);

  /// No description provided for @mapImportFailed_4728.
  ///
  /// In zh, this message translates to:
  /// **'导入地图失败'**
  String get mapImportFailed_4728;

  /// No description provided for @mapImportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'成功导入地图: {title}'**
  String mapImportSuccess(Object title);

  /// No description provided for @mapInfoChangedBroadcast.
  ///
  /// In zh, this message translates to:
  /// **'地图信息发生变化，准备广播: mapId={mapId}, mapTitle={mapTitle}'**
  String mapInfoChangedBroadcast(Object mapId, Object mapTitle);

  /// No description provided for @mapInfoSyncComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'地图信息同步完成'**
  String get mapInfoSyncComplete_7281;

  /// No description provided for @mapInfoUnchangedSkipBroadcast_4821.
  ///
  /// In zh, this message translates to:
  /// **'地图信息无变化，跳过广播'**
  String get mapInfoUnchangedSkipBroadcast_4821;

  /// No description provided for @mapInfo_7281.
  ///
  /// In zh, this message translates to:
  /// **'地图信息'**
  String get mapInfo_7281;

  /// No description provided for @mapInfo_7421.
  ///
  /// In zh, this message translates to:
  /// **'地图信息'**
  String get mapInfo_7421;

  /// No description provided for @mapInitialization.
  ///
  /// In zh, this message translates to:
  /// **'初始化地图: {title}'**
  String mapInitialization(Object title);

  /// No description provided for @mapInitializationFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'初始化地图失败: {error}'**
  String mapInitializationFailed_7421(Object error);

  /// No description provided for @mapInsertFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'直接插入示例地图失败: {e}'**
  String mapInsertFailed_7285(Object e);

  /// No description provided for @mapItemAndTitleEmpty_9274.
  ///
  /// In zh, this message translates to:
  /// **'mapItem 和 mapTitle 都为空'**
  String get mapItemAndTitleEmpty_9274;

  /// No description provided for @mapLayerPresetSet.
  ///
  /// In zh, this message translates to:
  /// **'扩展设置: 地图 {mapId} 的图层 {layerId} 透明度预设已设置: {presets}'**
  String mapLayerPresetSet(Object layerId, Object mapId, Object presets);

  /// No description provided for @mapLegendAutoHideStatus.
  ///
  /// In zh, this message translates to:
  /// **'扩展设置: 地图 {mapId} 的图例组 {legendGroupId} 智能隐藏状态已设置为 {isHidden}'**
  String mapLegendAutoHideStatus(
    Object isHidden,
    Object legendGroupId,
    Object mapId,
  );

  /// No description provided for @mapLegendAutoHideStatusSaved.
  ///
  /// In zh, this message translates to:
  /// **'地图 {title} 的图例组智能隐藏状态已保存'**
  String mapLegendAutoHideStatusSaved(Object title);

  /// No description provided for @mapLegendScaleSaved.
  ///
  /// In zh, this message translates to:
  /// **'地图 {title} 的图例组缩放因子状态已保存'**
  String mapLegendScaleSaved(Object title);

  /// No description provided for @mapLegendZoomFactorLog_4821.
  ///
  /// In zh, this message translates to:
  /// **'扩展设置: 地图 {mapId} 的图例组 {legendGroupId} 缩放因子已设置为 {zoomFactor}'**
  String mapLegendZoomFactorLog_4821(
    Object legendGroupId,
    Object mapId,
    Object zoomFactor,
  );

  /// No description provided for @mapLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载地图失败 [{title}]: {e}'**
  String mapLoadFailed(Object e, Object title);

  /// No description provided for @mapLoadFailedById.
  ///
  /// In zh, this message translates to:
  /// **'通过ID加载地图失败 [{id}]: {e}'**
  String mapLoadFailedById(Object e, Object id);

  /// No description provided for @mapLocalizationDbCloseFailed.
  ///
  /// In zh, this message translates to:
  /// **'关闭地图本地化数据库失败: {e}'**
  String mapLocalizationDbCloseFailed(Object e);

  /// No description provided for @mapLocalizationFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'保存地图本地化失败[{mapTitle}]: {e}'**
  String mapLocalizationFailed_7421(Object e, Object mapTitle);

  /// No description provided for @mapMigrationComplete.
  ///
  /// In zh, this message translates to:
  /// **'地图迁移完成: {title} -> {mapId}'**
  String mapMigrationComplete(Object mapId, Object title);

  /// No description provided for @mapMigrationFailed.
  ///
  /// In zh, this message translates to:
  /// **'地图迁移失败: {title} - {error}'**
  String mapMigrationFailed(Object error, Object title);

  /// No description provided for @mapMoveFailed.
  ///
  /// In zh, this message translates to:
  /// **'移动地图失败 [{arg0}]: {arg1}'**
  String mapMoveFailed(Object arg0, Object arg1);

  /// No description provided for @mapName_4821.
  ///
  /// In zh, this message translates to:
  /// **'地图名称'**
  String get mapName_4821;

  /// No description provided for @mapNotFoundError.
  ///
  /// In zh, this message translates to:
  /// **'找不到地图: {mapTitle}'**
  String mapNotFoundError(Object mapTitle);

  /// No description provided for @mapNotFoundError_7285.
  ///
  /// In zh, this message translates to:
  /// **'找不到地图: {oldTitle}'**
  String mapNotFoundError_7285(Object oldTitle);

  /// No description provided for @mapNotFoundWithTitle.
  ///
  /// In zh, this message translates to:
  /// **'未找到标题为 \"{mapTitle}\" 的地图'**
  String mapNotFoundWithTitle(Object mapTitle);

  /// No description provided for @mapNotFound_7281.
  ///
  /// In zh, this message translates to:
  /// **'地图不存在'**
  String get mapNotFound_7281;

  /// No description provided for @mapNotFound_7425.
  ///
  /// In zh, this message translates to:
  /// **'地图不存在: {mapId}'**
  String mapNotFound_7425(Object mapId);

  /// No description provided for @mapPackageExportComplete.
  ///
  /// In zh, this message translates to:
  /// **'地图包导出完成: {mapId} -> {exportPath}'**
  String mapPackageExportComplete(Object exportPath, Object mapId);

  /// No description provided for @mapPreferencesDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'用于存储临时的地图相关偏好设置，如图例组智能隐藏状态等。这些设置不会影响地图数据本身。'**
  String get mapPreferencesDescription_4821;

  /// No description provided for @mapPreview.
  ///
  /// In zh, this message translates to:
  /// **'地图预览'**
  String get mapPreview;

  /// No description provided for @mapRecordNotFoundWithId.
  ///
  /// In zh, this message translates to:
  /// **'没有找到要更新的地图记录，ID: {id}'**
  String mapRecordNotFoundWithId(Object id);

  /// No description provided for @mapRenameSuccess_7285.
  ///
  /// In zh, this message translates to:
  /// **'地图重命名成功: {oldTitle} -> {newTitle}'**
  String mapRenameSuccess_7285(Object newTitle, Object oldTitle);

  /// No description provided for @mapRenamedSuccessfully_4848.
  ///
  /// In zh, this message translates to:
  /// **'地图重命名成功'**
  String get mapRenamedSuccessfully_4848;

  /// No description provided for @mapRestoreFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'从备份恢复地图失败: {e}'**
  String mapRestoreFailed_7285(Object e);

  /// No description provided for @mapSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存地图失败 [{title}]: {error}'**
  String mapSaveFailed(Object error, Object title);

  /// No description provided for @mapSaveFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'保存地图失败: {e}'**
  String mapSaveFailed_7285(Object e);

  /// No description provided for @mapSavedSuccessfully_7281.
  ///
  /// In zh, this message translates to:
  /// **'地图保存成功'**
  String get mapSavedSuccessfully_7281;

  /// No description provided for @mapScriptsLoaded.
  ///
  /// In zh, this message translates to:
  /// **'为地图 {mapTitle} 加载了 {scriptCount} 个脚本'**
  String mapScriptsLoaded(Object mapTitle, Object scriptCount);

  /// No description provided for @mapSelectionSavedWithSize.
  ///
  /// In zh, this message translates to:
  /// **'地图选中区域已保存 ({width}x{height}) - 图像剪贴板功能在{platformHint}不可用'**
  String mapSelectionSavedWithSize(
    Object height,
    Object platformHint,
    Object width,
  );

  /// No description provided for @mapSessionSummary_1589.
  ///
  /// In zh, this message translates to:
  /// **'地图: {mapTitle}, 版本: {totalVersions}, 未保存: {unsavedCount}, 当前: {currentVersionId}'**
  String mapSessionSummary_1589(
    Object currentVersionId,
    Object mapTitle,
    Object totalVersions,
    Object unsavedCount,
  );

  /// No description provided for @mapSummaryError_4821.
  ///
  /// In zh, this message translates to:
  /// **'根据路径获取地图摘要失败 [{mapPath}]: {e}'**
  String mapSummaryError_4821(Object e, Object mapPath);

  /// No description provided for @mapSummaryLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载地图摘要失败 [{desanitizedTitle}]: {e}'**
  String mapSummaryLoadFailed(Object desanitizedTitle, Object e);

  /// No description provided for @mapSyncDemoTitle_7281.
  ///
  /// In zh, this message translates to:
  /// **'地图信息同步演示:'**
  String get mapSyncDemoTitle_7281;

  /// No description provided for @mapSyncFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'同步地图信息失败: {e}'**
  String mapSyncFailed_7285(Object e);

  /// No description provided for @mapTitle.
  ///
  /// In zh, this message translates to:
  /// **'地图标题'**
  String get mapTitle;

  /// No description provided for @mapTitleUpdated_7281.
  ///
  /// In zh, this message translates to:
  /// **'已更新地图标题'**
  String get mapTitleUpdated_7281;

  /// No description provided for @mapTitle_7421.
  ///
  /// In zh, this message translates to:
  /// **'地图标题'**
  String get mapTitle_7421;

  /// No description provided for @mapUpdateMessage.
  ///
  /// In zh, this message translates to:
  /// **'更新地图: {title} (版本 {oldVersion} -> {newVersion})'**
  String mapUpdateMessage(Object newVersion, Object oldVersion, Object title);

  /// No description provided for @mapVersionCreationFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'创建地图版本失败 [{mapTitle}:{version}]: {e}'**
  String mapVersionCreationFailed_7421(
    Object e,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @mapVersionDeletionFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'删除地图版本失败 [{mapTitle}:{version}]: {e}'**
  String mapVersionDeletionFailed_7421(
    Object e,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @mapVersionFetchFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取地图版本失败 [{mapTitle}]: {e}'**
  String mapVersionFetchFailed(Object e, Object mapTitle);

  /// No description provided for @mapVersion_4821.
  ///
  /// In zh, this message translates to:
  /// **'地图版本'**
  String get mapVersion_4821;

  /// No description provided for @mapZoomLevelRecord.
  ///
  /// In zh, this message translates to:
  /// **'扩展设置: 地图 {mapId} 添加缩放级别记录 {zoomLevel}'**
  String mapZoomLevelRecord(Object mapId, Object zoomLevel);

  /// No description provided for @maps_4823.
  ///
  /// In zh, this message translates to:
  /// **'地图'**
  String get maps_4823;

  /// No description provided for @marginLabel_7281.
  ///
  /// In zh, this message translates to:
  /// **'页边距'**
  String get marginLabel_7281;

  /// No description provided for @markRemovedWithPath.
  ///
  /// In zh, this message translates to:
  /// **'标记移除: 路径=\"{path}\"'**
  String markRemovedWithPath(Object path);

  /// No description provided for @markTag_2345.
  ///
  /// In zh, this message translates to:
  /// **'标记'**
  String get markTag_2345;

  /// No description provided for @markdownFileEmpty_7281.
  ///
  /// In zh, this message translates to:
  /// **'Markdown文件为空'**
  String get markdownFileEmpty_7281;

  /// No description provided for @markdownGeneratorCreation.
  ///
  /// In zh, this message translates to:
  /// **'🔧 _buildMarkdownContent: 创建MarkdownGenerator - generators: {generatorsLength}, syntaxes: {syntaxesLength}'**
  String markdownGeneratorCreation(
    Object generatorsLength,
    Object syntaxesLength,
  );

  /// No description provided for @markdownLoadFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'加载Markdown文件失败: {error}'**
  String markdownLoadFailed_7421(Object error);

  /// No description provided for @markdownReadError_4821.
  ///
  /// In zh, this message translates to:
  /// **'无法读取Markdown文件'**
  String get markdownReadError_4821;

  /// No description provided for @markdownRendererDemo_4821.
  ///
  /// In zh, this message translates to:
  /// **'Markdown 渲染器组件演示'**
  String get markdownRendererDemo_4821;

  /// No description provided for @markdownRendererDemo_7421.
  ///
  /// In zh, this message translates to:
  /// **'Markdown 渲染器演示'**
  String get markdownRendererDemo_7421;

  /// No description provided for @markedTag_5678.
  ///
  /// In zh, this message translates to:
  /// **'标记'**
  String get markedTag_5678;

  /// No description provided for @marker_4827.
  ///
  /// In zh, this message translates to:
  /// **'标记'**
  String get marker_4827;

  /// No description provided for @materialDesign.
  ///
  /// In zh, this message translates to:
  /// **'Material Design'**
  String get materialDesign;

  /// No description provided for @maxConcurrentScriptsReached.
  ///
  /// In zh, this message translates to:
  /// **'达到最大并发脚本数限制 ({maxExecutors})'**
  String maxConcurrentScriptsReached(Object maxExecutors);

  /// No description provided for @maxLimitReached_5421.
  ///
  /// In zh, this message translates to:
  /// **'已达到最大数量限制 (5个)'**
  String get maxLimitReached_5421;

  /// No description provided for @maxLineWidthLimit_4821.
  ///
  /// In zh, this message translates to:
  /// **'最多只能添加5个常用线条宽度'**
  String get maxLineWidthLimit_4821;

  /// No description provided for @maxTagsLimit.
  ///
  /// In zh, this message translates to:
  /// **'限制最多10个标签'**
  String get maxTagsLimit;

  /// No description provided for @maxTagsLimitComment.
  ///
  /// In zh, this message translates to:
  /// **'限制最多10个标签'**
  String get maxTagsLimitComment;

  /// No description provided for @maximizeOrRestore_7281.
  ///
  /// In zh, this message translates to:
  /// **'最大化/还原'**
  String get maximizeOrRestore_7281;

  /// No description provided for @maximizeRestore_7281.
  ///
  /// In zh, this message translates to:
  /// **'最大化/还原'**
  String get maximizeRestore_7281;

  /// No description provided for @meIndicator_7281.
  ///
  /// In zh, this message translates to:
  /// **'(我)'**
  String get meIndicator_7281;

  /// No description provided for @mediumBrush_4821.
  ///
  /// In zh, this message translates to:
  /// **'中画笔'**
  String get mediumBrush_4821;

  /// No description provided for @menuBarIntegration.
  ///
  /// In zh, this message translates to:
  /// **'菜单栏集成'**
  String get menuBarIntegration;

  /// No description provided for @menuRadius_4271.
  ///
  /// In zh, this message translates to:
  /// **'菜单半径'**
  String get menuRadius_4271;

  /// No description provided for @menuSelection_7281.
  ///
  /// In zh, this message translates to:
  /// **'菜单选择: {label}'**
  String menuSelection_7281(Object label);

  /// No description provided for @mergeExpand_4281.
  ///
  /// In zh, this message translates to:
  /// **'合并展开'**
  String get mergeExpand_4281;

  /// No description provided for @mergeFolderPrompt_4821.
  ///
  /// In zh, this message translates to:
  /// **'合并文件夹内容，子文件冲突时会再次询问'**
  String get mergeFolderPrompt_4821;

  /// No description provided for @mergeLayers_7281.
  ///
  /// In zh, this message translates to:
  /// **'合并图层'**
  String get mergeLayers_7281;

  /// No description provided for @mergeText_4821.
  ///
  /// In zh, this message translates to:
  /// **'合并'**
  String get mergeText_4821;

  /// No description provided for @mergeText_7421.
  ///
  /// In zh, this message translates to:
  /// **'合并'**
  String get mergeText_7421;

  /// No description provided for @messageContent_7281.
  ///
  /// In zh, this message translates to:
  /// **'消息内容'**
  String get messageContent_7281;

  /// No description provided for @messageSignedSuccessfully_7281.
  ///
  /// In zh, this message translates to:
  /// **'消息签名成功'**
  String get messageSignedSuccessfully_7281;

  /// No description provided for @messageType_7281.
  ///
  /// In zh, this message translates to:
  /// **'消息类型'**
  String get messageType_7281;

  /// No description provided for @messageWithIndexAndType_7421.
  ///
  /// In zh, this message translates to:
  /// **'第{index}条消息 - {type}'**
  String messageWithIndexAndType_7421(Object index, Object type);

  /// No description provided for @metadataFileFormatError_7285.
  ///
  /// In zh, this message translates to:
  /// **'元数据文件格式错误: {e}'**
  String metadataFileFormatError_7285(Object e);

  /// No description provided for @metadataFileMissing_7285.
  ///
  /// In zh, this message translates to:
  /// **'元数据文件不存在: meta.json'**
  String get metadataFileMissing_7285;

  /// No description provided for @metadataFormatError_7281.
  ///
  /// In zh, this message translates to:
  /// **'元数据文件格式错误：{e}'**
  String metadataFormatError_7281(Object e);

  /// No description provided for @metadataFormatExample_4980.
  ///
  /// In zh, this message translates to:
  /// **'metadata.json格式示例：'**
  String get metadataFormatExample_4980;

  /// No description provided for @metadataFormat_4979.
  ///
  /// In zh, this message translates to:
  /// **'元数据格式'**
  String get metadataFormat_4979;

  /// No description provided for @metadataInfo_4932.
  ///
  /// In zh, this message translates to:
  /// **'元数据信息'**
  String get metadataInfo_4932;

  /// No description provided for @metadataJsonNotFoundInZipRoot_7281.
  ///
  /// In zh, this message translates to:
  /// **'ZIP文件根目录中未找到metadata.json文件'**
  String get metadataJsonNotFoundInZipRoot_7281;

  /// No description provided for @metadataLabel_7281.
  ///
  /// In zh, this message translates to:
  /// **'\\n元数据:'**
  String get metadataLabel_7281;

  /// No description provided for @metadataTableCreated_7281.
  ///
  /// In zh, this message translates to:
  /// **'元数据表创建完成'**
  String get metadataTableCreated_7281;

  /// No description provided for @metadataTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'元数据'**
  String get metadataTitle_4821;

  /// No description provided for @metadata_4821.
  ///
  /// In zh, this message translates to:
  /// **'元数据'**
  String get metadata_4821;

  /// No description provided for @middleButton_7281.
  ///
  /// In zh, this message translates to:
  /// **'中键'**
  String get middleButton_7281;

  /// No description provided for @middleKeyPressedShowRadialMenu.
  ///
  /// In zh, this message translates to:
  /// **'中键按下，显示径向菜单于位置: {localPosition}'**
  String middleKeyPressedShowRadialMenu(Object localPosition);

  /// No description provided for @migrateLegacyPreferences.
  ///
  /// In zh, this message translates to:
  /// **'迁移传统用户偏好设置: {displayName}'**
  String migrateLegacyPreferences(Object displayName);

  /// No description provided for @migrateUserConfig.
  ///
  /// In zh, this message translates to:
  /// **'迁移用户配置: {displayName}'**
  String migrateUserConfig(Object displayName);

  /// No description provided for @migratedWindowControlsMode.
  ///
  /// In zh, this message translates to:
  /// **'已为用户 {userId} 迁移 enableMergedWindowControls 到 windowControlsMode'**
  String migratedWindowControlsMode(Object userId);

  /// No description provided for @migrationCheckFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'检查迁移状态失败: {e}'**
  String migrationCheckFailed_4821(Object e);

  /// No description provided for @migrationError_7425.
  ///
  /// In zh, this message translates to:
  /// **'迁移验证出错: {e}'**
  String migrationError_7425(Object e);

  /// No description provided for @migrationFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'迁移传统用户偏好设置失败: {e}'**
  String migrationFailed_7285(Object e);

  /// No description provided for @migrationStatsFailed_5421.
  ///
  /// In zh, this message translates to:
  /// **'获取迁移统计信息失败: {e}'**
  String migrationStatsFailed_5421(Object e);

  /// No description provided for @migrationStatusReset_7281.
  ///
  /// In zh, this message translates to:
  /// **'迁移状态已重置'**
  String get migrationStatusReset_7281;

  /// No description provided for @migrationValidationFailed.
  ///
  /// In zh, this message translates to:
  /// **'迁移验证失败: 地图数量不匹配 (原始: {originalCount}, VFS: {vfsCount})'**
  String migrationValidationFailed(Object originalCount, Object vfsCount);

  /// No description provided for @migrationValidationSuccess_7281.
  ///
  /// In zh, this message translates to:
  /// **'迁移验证成功: 所有地图数据完整'**
  String get migrationValidationSuccess_7281;

  /// No description provided for @mimeTypeLabel.
  ///
  /// In zh, this message translates to:
  /// **'MIME类型: {mimeType}'**
  String mimeTypeLabel(Object mimeType);

  /// No description provided for @mimeTypeLabel_4721.
  ///
  /// In zh, this message translates to:
  /// **'MIME类型'**
  String get mimeTypeLabel_4721;

  /// No description provided for @mimeType_4821.
  ///
  /// In zh, this message translates to:
  /// **'MIME类型'**
  String get mimeType_4821;

  /// No description provided for @minimizeButton_4821.
  ///
  /// In zh, this message translates to:
  /// **'最小化'**
  String get minimizeButton_4821;

  /// No description provided for @minimizeButton_7281.
  ///
  /// In zh, this message translates to:
  /// **'最小化'**
  String get minimizeButton_7281;

  /// No description provided for @minimizePlayer_4821.
  ///
  /// In zh, this message translates to:
  /// **'最小化播放器'**
  String get minimizePlayer_4821;

  /// No description provided for @minimizeTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'最小化'**
  String get minimizeTooltip_7281;

  /// No description provided for @minutesAgo_7421.
  ///
  /// In zh, this message translates to:
  /// **'{minutes}分钟前'**
  String minutesAgo_7421(Object minutes);

  /// No description provided for @minutesLabel_7281.
  ///
  /// In zh, this message translates to:
  /// **'分钟'**
  String get minutesLabel_7281;

  /// No description provided for @missingMetadataFields_4821.
  ///
  /// In zh, this message translates to:
  /// **'元数据中未指定target_path或file_mappings'**
  String get missingMetadataFields_4821;

  /// No description provided for @missingRequiredField_4827.
  ///
  /// In zh, this message translates to:
  /// **'元数据缺少必需字段: {field}'**
  String missingRequiredField_4827(Object field);

  /// No description provided for @mobileGroupLayerDebug.
  ///
  /// In zh, this message translates to:
  /// **'移动组图层: {layers}'**
  String mobileGroupLayerDebug(Object layers);

  /// No description provided for @mobileGroupSize.
  ///
  /// In zh, this message translates to:
  /// **'移动组大小: {length}'**
  String mobileGroupSize(Object length);

  /// No description provided for @mobileGroupTitle_7281.
  ///
  /// In zh, this message translates to:
  /// **'=== 移动组 ==='**
  String get mobileGroupTitle_7281;

  /// No description provided for @mode.
  ///
  /// In zh, this message translates to:
  /// **'模式'**
  String get mode;

  /// No description provided for @modifiedAtText_7281.
  ///
  /// In zh, this message translates to:
  /// **'修改于 {date}'**
  String modifiedAtText_7281(Object date);

  /// No description provided for @modifiedAtTime_7281.
  ///
  /// In zh, this message translates to:
  /// **'修改于 {time}'**
  String modifiedAtTime_7281(Object time);

  /// No description provided for @modifiedTimeLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'修改时间'**
  String get modifiedTimeLabel_4821;

  /// No description provided for @modifiedTimeLabel_5421.
  ///
  /// In zh, this message translates to:
  /// **'修改时间'**
  String get modifiedTimeLabel_5421;

  /// No description provided for @modifiedTimeLabel_7421.
  ///
  /// In zh, this message translates to:
  /// **'修改时间'**
  String get modifiedTimeLabel_7421;

  /// No description provided for @modifiedTimeLabel_8532.
  ///
  /// In zh, this message translates to:
  /// **'修改时间'**
  String get modifiedTimeLabel_8532;

  /// No description provided for @modifiedTime_4821.
  ///
  /// In zh, this message translates to:
  /// **'修改时间'**
  String get modifiedTime_4821;

  /// No description provided for @modified_4963.
  ///
  /// In zh, this message translates to:
  /// **'修改时间'**
  String get modified_4963;

  /// No description provided for @modified_5732.
  ///
  /// In zh, this message translates to:
  /// **'已修改'**
  String get modified_5732;

  /// No description provided for @mouseStopAndEnterSubmenu.
  ///
  /// In zh, this message translates to:
  /// **'鼠标停止移动，延迟进入子菜单: {label}'**
  String mouseStopAndEnterSubmenu(Object label);

  /// No description provided for @moveElementFailedJsonError_4821.
  ///
  /// In zh, this message translates to:
  /// **'移动元素失败：JSON解析错误'**
  String get moveElementFailedJsonError_4821;

  /// No description provided for @moveItem_7421.
  ///
  /// In zh, this message translates to:
  /// **'移动 {item}'**
  String moveItem_7421(Object item);

  /// No description provided for @moveLayerElementOffset.
  ///
  /// In zh, this message translates to:
  /// **'移动图层 {layerId} 中元素 {elementId} 偏移 ({deltaX}, {deltaY})'**
  String moveLayerElementOffset(
    Object deltaX,
    Object deltaY,
    Object elementId,
    Object layerId,
  );

  /// No description provided for @moveNoteElementOffset_4821.
  ///
  /// In zh, this message translates to:
  /// **'移动便签 {noteId} 中元素 {elementId} 偏移 ({deltaX}, {deltaY})'**
  String moveNoteElementOffset_4821(
    Object deltaX,
    Object deltaY,
    Object elementId,
    Object noteId,
  );

  /// No description provided for @moveToTop_7281.
  ///
  /// In zh, this message translates to:
  /// **'移到顶层'**
  String get moveToTop_7281;

  /// No description provided for @movedLayersName_4821.
  ///
  /// In zh, this message translates to:
  /// **'移动后图层名称: {layers}'**
  String movedLayersName_4821(Object layers);

  /// No description provided for @movingLayerDebug_7281.
  ///
  /// In zh, this message translates to:
  /// **'移动的图层: {name}, 是否为组内最后元素: {isMovingLastElement}'**
  String movingLayerDebug_7281(Object isMovingLastElement, Object name);

  /// No description provided for @muteToggleFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'切换静音失败'**
  String get muteToggleFailed_7281;

  /// No description provided for @mute_4821.
  ///
  /// In zh, this message translates to:
  /// **'静音'**
  String get mute_4821;

  /// No description provided for @mute_5422.
  ///
  /// In zh, this message translates to:
  /// **'静音'**
  String get mute_5422;

  /// No description provided for @mute_5832.
  ///
  /// In zh, this message translates to:
  /// **'静音'**
  String get mute_5832;

  /// No description provided for @mutedStatusOff.
  ///
  /// In zh, this message translates to:
  /// **'取消静音'**
  String get mutedStatusOff;

  /// No description provided for @mutedStatusOn.
  ///
  /// In zh, this message translates to:
  /// **'已静音'**
  String get mutedStatusOn;

  /// No description provided for @nameCannotBeEmpty_4821.
  ///
  /// In zh, this message translates to:
  /// **'名称不能为空'**
  String get nameCannotBeEmpty_4821;

  /// No description provided for @nameLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get nameLabel_4821;

  /// No description provided for @nameLengthExceedLimit_4829.
  ///
  /// In zh, this message translates to:
  /// **'名称长度不能超过255个字符'**
  String get nameLengthExceedLimit_4829;

  /// No description provided for @nameLengthExceeded_4821.
  ///
  /// In zh, this message translates to:
  /// **'名称长度不能超过255个字符'**
  String get nameLengthExceeded_4821;

  /// No description provided for @nameUpdatedTo_7421.
  ///
  /// In zh, this message translates to:
  /// **'显示名称已更新为 \"{newName}\"'**
  String nameUpdatedTo_7421(Object newName);

  /// No description provided for @name_4951.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get name_4951;

  /// No description provided for @name_4961.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get name_4961;

  /// No description provided for @nativeContextMenuStyle_4821.
  ///
  /// In zh, this message translates to:
  /// **'• 使用系统原生的右键菜单样式'**
  String get nativeContextMenuStyle_4821;

  /// No description provided for @nativeCopyHint_3456.
  ///
  /// In zh, this message translates to:
  /// **'此平台'**
  String get nativeCopyHint_3456;

  /// No description provided for @nativeGtkIntegration.
  ///
  /// In zh, this message translates to:
  /// **'原生 GTK 集成'**
  String get nativeGtkIntegration;

  /// No description provided for @nativeImageCopyFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'原生平台复制图像失败: {e}'**
  String nativeImageCopyFailed_4821(Object e);

  /// No description provided for @nativeInteractionExperience_4821.
  ///
  /// In zh, this message translates to:
  /// **'• 保持平台原生的交互体验'**
  String get nativeInteractionExperience_4821;

  /// No description provided for @nativeMacOSUI.
  ///
  /// In zh, this message translates to:
  /// **'原生 macOS UI'**
  String get nativeMacOSUI;

  /// No description provided for @nativeWindowsUI.
  ///
  /// In zh, this message translates to:
  /// **'原生 Windows UI'**
  String get nativeWindowsUI;

  /// No description provided for @navigatedToFile_4821.
  ///
  /// In zh, this message translates to:
  /// **'已导航到文件: {name}'**
  String navigatedToFile_4821(Object name);

  /// No description provided for @navigatedToFolder_4821.
  ///
  /// In zh, this message translates to:
  /// **'已导航到文件夹: {name}'**
  String navigatedToFolder_4821(Object name);

  /// No description provided for @navigationFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'导航失败: {error}'**
  String navigationFailed_4821(Object error);

  /// No description provided for @networkError_4825.
  ///
  /// In zh, this message translates to:
  /// **'网络错误'**
  String get networkError_4825;

  /// No description provided for @networkUrlLabel_4823.
  ///
  /// In zh, this message translates to:
  /// **'网络URL'**
  String get networkUrlLabel_4823;

  /// No description provided for @newButton_4821.
  ///
  /// In zh, this message translates to:
  /// **'新建'**
  String get newButton_4821;

  /// No description provided for @newFolderName_4842.
  ///
  /// In zh, this message translates to:
  /// **'新文件夹名称'**
  String get newFolderName_4842;

  /// No description provided for @newFolderTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'新建文件夹'**
  String get newFolderTitle_4821;

  /// No description provided for @newImageElementsDetected_7281.
  ///
  /// In zh, this message translates to:
  /// **'检测到 {count} 个新的图片元素，开始预加载'**
  String newImageElementsDetected_7281(Object count);

  /// No description provided for @newLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'新名称:'**
  String get newLabel_4821;

  /// No description provided for @newLegendGroupItemCount.
  ///
  /// In zh, this message translates to:
  /// **'新图例组有 {count} 个图例项'**
  String newLegendGroupItemCount(Object count);

  /// No description provided for @newMapName_4847.
  ///
  /// In zh, this message translates to:
  /// **'新地图名称'**
  String get newMapName_4847;

  /// No description provided for @newNameLabel_4521.
  ///
  /// In zh, this message translates to:
  /// **'新名称'**
  String get newNameLabel_4521;

  /// No description provided for @newNoteTitle.
  ///
  /// In zh, this message translates to:
  /// **'新便签 {count}'**
  String newNoteTitle(Object count);

  /// No description provided for @newScript_7281.
  ///
  /// In zh, this message translates to:
  /// **'新建脚本'**
  String get newScript_7281;

  /// No description provided for @newVersionCreated_7281.
  ///
  /// In zh, this message translates to:
  /// **'新版本已创建: {versionId}'**
  String newVersionCreated_7281(Object versionId);

  /// No description provided for @nextLayerGroup_4825.
  ///
  /// In zh, this message translates to:
  /// **'下一个图层组'**
  String get nextLayerGroup_4825;

  /// No description provided for @nextLayer_4823.
  ///
  /// In zh, this message translates to:
  /// **'下一个图层'**
  String get nextLayer_4823;

  /// No description provided for @nextLegendGroup_4823.
  ///
  /// In zh, this message translates to:
  /// **'下一个图例组'**
  String get nextLegendGroup_4823;

  /// No description provided for @nextSong_7281.
  ///
  /// In zh, this message translates to:
  /// **'下一首'**
  String get nextSong_7281;

  /// No description provided for @nextVersion_4823.
  ///
  /// In zh, this message translates to:
  /// **'下一个版本'**
  String get nextVersion_4823;

  /// No description provided for @ninePerPage_4825.
  ///
  /// In zh, this message translates to:
  /// **'一页九张'**
  String get ninePerPage_4825;

  /// No description provided for @no.
  ///
  /// In zh, this message translates to:
  /// **'否'**
  String get no;

  /// No description provided for @noActiveClientConfig_7281.
  ///
  /// In zh, this message translates to:
  /// **'未找到活跃的客户端配置'**
  String get noActiveClientConfig_7281;

  /// No description provided for @noActiveMap_7421.
  ///
  /// In zh, this message translates to:
  /// **'暂无活跃地图'**
  String get noActiveMap_7421;

  /// No description provided for @noActiveWebSocketConfigFound_7281.
  ///
  /// In zh, this message translates to:
  /// **'没有找到活跃的WebSocket配置，创建默认配置'**
  String get noActiveWebSocketConfigFound_7281;

  /// No description provided for @noAudioSourceSpecified_7281.
  ///
  /// In zh, this message translates to:
  /// **'没有指定音频源'**
  String get noAudioSourceSpecified_7281;

  /// No description provided for @noAuthenticatedAccount_7421.
  ///
  /// In zh, this message translates to:
  /// **'暂无认证账户'**
  String get noAuthenticatedAccount_7421;

  /// No description provided for @noAvailableLayers.
  ///
  /// In zh, this message translates to:
  /// **'没有可用的图层'**
  String get noAvailableLayers;

  /// No description provided for @noAvailableLayers_4721.
  ///
  /// In zh, this message translates to:
  /// **'无可用图层'**
  String get noAvailableLayers_4721;

  /// No description provided for @noAvailableLayers_4821.
  ///
  /// In zh, this message translates to:
  /// **'没有可用的图层'**
  String get noAvailableLayers_4821;

  /// No description provided for @noAvailableLayers_7281.
  ///
  /// In zh, this message translates to:
  /// **'暂无可用的图层'**
  String get noAvailableLayers_7281;

  /// No description provided for @noAvailableLegend_4821.
  ///
  /// In zh, this message translates to:
  /// **'无可用图例'**
  String get noAvailableLegend_4821;

  /// No description provided for @noAvailableScripts_7281.
  ///
  /// In zh, this message translates to:
  /// **'暂无可用的启用脚本'**
  String get noAvailableScripts_7281;

  /// No description provided for @noAvatar_4821.
  ///
  /// In zh, this message translates to:
  /// **'[无头像]'**
  String get noAvatar_4821;

  /// No description provided for @noBackgroundImage_7421.
  ///
  /// In zh, this message translates to:
  /// **'无背景图片'**
  String get noBackgroundImage_7421;

  /// No description provided for @noBoundLegend_4821.
  ///
  /// In zh, this message translates to:
  /// **'无绑定图例'**
  String get noBoundLegend_4821;

  /// No description provided for @noCachedLegend.
  ///
  /// In zh, this message translates to:
  /// **'暂无缓存图例'**
  String get noCachedLegend;

  /// No description provided for @noCommonLineWidthAdded_4821.
  ///
  /// In zh, this message translates to:
  /// **'还没有添加常用线条宽度'**
  String get noCommonLineWidthAdded_4821;

  /// No description provided for @noConfigurableProperties_7421.
  ///
  /// In zh, this message translates to:
  /// **'此工具无可配置属性'**
  String get noConfigurableProperties_7421;

  /// No description provided for @noConnectionConfig_4521.
  ///
  /// In zh, this message translates to:
  /// **'暂无连接配置'**
  String get noConnectionConfig_4521;

  /// No description provided for @noCustomTagsMessage_7421.
  ///
  /// In zh, this message translates to:
  /// **'暂无自定义标签\n点击上方输入框添加新标签'**
  String get noCustomTagsMessage_7421;

  /// No description provided for @noCustomTags_7281.
  ///
  /// In zh, this message translates to:
  /// **'暂无自定义标签'**
  String get noCustomTags_7281;

  /// No description provided for @noCut_4821.
  ///
  /// In zh, this message translates to:
  /// **'无切割'**
  String get noCut_4821;

  /// No description provided for @noDataSkipSync_4821.
  ///
  /// In zh, this message translates to:
  /// **'当前响应式系统没有数据，跳过同步'**
  String get noDataSkipSync_4821;

  /// No description provided for @noData_6943.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get noData_6943;

  /// No description provided for @noEditingVersionSkipSync_4821.
  ///
  /// In zh, this message translates to:
  /// **'没有正在编辑的版本，跳过数据同步'**
  String get noEditingVersionSkipSync_4821;

  /// No description provided for @noEditingVersionSkipSync_7281.
  ///
  /// In zh, this message translates to:
  /// **'没有正在编辑的版本，跳过数据同步到版本系统'**
  String get noEditingVersionSkipSync_7281;

  /// No description provided for @noEditingVersionToSave_4821.
  ///
  /// In zh, this message translates to:
  /// **'没有正在编辑的版本，无需保存'**
  String get noEditingVersionToSave_4821;

  /// No description provided for @noExecutionLogs_7421.
  ///
  /// In zh, this message translates to:
  /// **'暂无执行日志'**
  String get noExecutionLogs_7421;

  /// No description provided for @noExecutionRecords_4521.
  ///
  /// In zh, this message translates to:
  /// **'暂无执行记录'**
  String get noExecutionRecords_4521;

  /// No description provided for @noExportItems_7281.
  ///
  /// In zh, this message translates to:
  /// **'暂无导出项目'**
  String get noExportItems_7281;

  /// No description provided for @noExtensionSettingsData_7421.
  ///
  /// In zh, this message translates to:
  /// **'当前没有扩展设置数据'**
  String get noExtensionSettingsData_7421;

  /// No description provided for @noExtension_7281.
  ///
  /// In zh, this message translates to:
  /// **'无扩展名'**
  String get noExtension_7281;

  /// No description provided for @noFilterApplied_4821.
  ///
  /// In zh, this message translates to:
  /// **'当前未应用任何滤镜。'**
  String get noFilterApplied_4821;

  /// No description provided for @noFilter_1234.
  ///
  /// In zh, this message translates to:
  /// **'无滤镜'**
  String get noFilter_1234;

  /// No description provided for @noFilter_4821.
  ///
  /// In zh, this message translates to:
  /// **'无滤镜'**
  String get noFilter_4821;

  /// No description provided for @noImageDataInClipboard_4821.
  ///
  /// In zh, this message translates to:
  /// **'剪贴板中没有图片数据'**
  String get noImageDataInClipboard_4821;

  /// No description provided for @noLayerGroups_4521.
  ///
  /// In zh, this message translates to:
  /// **'暂无图层组'**
  String get noLayerGroups_4521;

  /// No description provided for @noLayerSelected_4821.
  ///
  /// In zh, this message translates to:
  /// **'未选择图层'**
  String get noLayerSelected_4821;

  /// No description provided for @noLayersAvailable_4271.
  ///
  /// In zh, this message translates to:
  /// **'暂无图层'**
  String get noLayersAvailable_4271;

  /// No description provided for @noLayersAvailable_7281.
  ///
  /// In zh, this message translates to:
  /// **'暂无图层'**
  String get noLayersAvailable_7281;

  /// No description provided for @noLayersBoundWarning_4821.
  ///
  /// In zh, this message translates to:
  /// **'当前图例组未绑定任何图层'**
  String get noLayersBoundWarning_4821;

  /// No description provided for @noLegendAvailable_4251.
  ///
  /// In zh, this message translates to:
  /// **'暂无图例'**
  String get noLegendAvailable_4251;

  /// No description provided for @noLegendAvailable_4821.
  ///
  /// In zh, this message translates to:
  /// **'暂无图例'**
  String get noLegendAvailable_4821;

  /// No description provided for @noLegendGroupBoundToLayerGroup_4821.
  ///
  /// In zh, this message translates to:
  /// **'当前选中图层组没有绑定图例组'**
  String get noLegendGroupBoundToLayerGroup_4821;

  /// No description provided for @noLegendGroupBound_7281.
  ///
  /// In zh, this message translates to:
  /// **'当前选中图层没有绑定图例组'**
  String get noLegendGroupBound_7281;

  /// No description provided for @noLegendGroupInCurrentMap_4821.
  ///
  /// In zh, this message translates to:
  /// **'当前地图没有图例组'**
  String get noLegendGroupInCurrentMap_4821;

  /// No description provided for @noLegendGroupSelected_4821.
  ///
  /// In zh, this message translates to:
  /// **'当前选中的图层或图层组没有绑定任何图例组'**
  String get noLegendGroupSelected_4821;

  /// No description provided for @noLegendGroup_4521.
  ///
  /// In zh, this message translates to:
  /// **'暂无图例组'**
  String get noLegendGroup_4521;

  /// No description provided for @noLegendGroupsAvailable_4821.
  ///
  /// In zh, this message translates to:
  /// **'没有可切换的图例组'**
  String get noLegendGroupsAvailable_4821;

  /// No description provided for @noLogsAvailable_7421.
  ///
  /// In zh, this message translates to:
  /// **'暂无日志'**
  String get noLogsAvailable_7421;

  /// No description provided for @noMapDataToSave_4821.
  ///
  /// In zh, this message translates to:
  /// **'没有可保存的地图数据'**
  String get noMapDataToSave_4821;

  /// No description provided for @noMatchingFiles_4821.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的文件'**
  String get noMatchingFiles_4821;

  /// No description provided for @noMatchingResults_4828.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的结果'**
  String get noMatchingResults_4828;

  /// No description provided for @noNeedComparePathDiff.
  ///
  /// In zh, this message translates to:
  /// **'无需比较路径差异: previousVersionId={previousVersionId}, versionId={versionId}'**
  String noNeedComparePathDiff(Object previousVersionId, Object versionId);

  /// No description provided for @noOnlineUsers_4271.
  ///
  /// In zh, this message translates to:
  /// **'暂无在线用户'**
  String get noOnlineUsers_4271;

  /// No description provided for @noOnlineUsers_7421.
  ///
  /// In zh, this message translates to:
  /// **'暂无在线用户'**
  String get noOnlineUsers_7421;

  /// No description provided for @noPreferencesToSave_7281.
  ///
  /// In zh, this message translates to:
  /// **'当前没有可保存的偏好设置'**
  String get noPreferencesToSave_7281;

  /// No description provided for @noRecentColors_4821.
  ///
  /// In zh, this message translates to:
  /// **'暂无最近颜色'**
  String get noRecentColors_4821;

  /// No description provided for @noRunningScripts_7421.
  ///
  /// In zh, this message translates to:
  /// **'当前没有运行中的脚本'**
  String get noRunningScripts_7421;

  /// No description provided for @noSavedConfigs_7281.
  ///
  /// In zh, this message translates to:
  /// **'暂无保存的配置'**
  String get noSavedConfigs_7281;

  /// No description provided for @noScriptsAvailable_7421.
  ///
  /// In zh, this message translates to:
  /// **'暂无{type}脚本'**
  String noScriptsAvailable_7421(Object type);

  /// No description provided for @noTagsAvailable_7281.
  ///
  /// In zh, this message translates to:
  /// **'暂无标签'**
  String get noTagsAvailable_7281;

  /// No description provided for @noTagsAvailable_7421.
  ///
  /// In zh, this message translates to:
  /// **'暂无标签'**
  String get noTagsAvailable_7421;

  /// No description provided for @noTimerAvailable_7281.
  ///
  /// In zh, this message translates to:
  /// **'暂无计时器'**
  String get noTimerAvailable_7281;

  /// No description provided for @noToolSelected_4728.
  ///
  /// In zh, this message translates to:
  /// **'未选择工具'**
  String get noToolSelected_4728;

  /// No description provided for @noUpdatablePreferences_4821.
  ///
  /// In zh, this message translates to:
  /// **'没有可更新的偏好设置'**
  String get noUpdatablePreferences_4821;

  /// No description provided for @noValidImageToExport_4821.
  ///
  /// In zh, this message translates to:
  /// **'没有有效的图片可导出'**
  String get noValidImageToExport_4821;

  /// No description provided for @noValidImageToExport_7281.
  ///
  /// In zh, this message translates to:
  /// **'没有有效的图片可导出'**
  String get noValidImageToExport_7281;

  /// No description provided for @noValidMetadataDirectoryFound_5024.
  ///
  /// In zh, this message translates to:
  /// **'没有找到包含有效metadata.json的目录'**
  String get noValidMetadataDirectoryFound_5024;

  /// No description provided for @noVersionAvailable_7281.
  ///
  /// In zh, this message translates to:
  /// **'暂无版本'**
  String get noVersionAvailable_7281;

  /// No description provided for @noVisibleLayersDisabled_4723.
  ///
  /// In zh, this message translates to:
  /// **'无可见图层，绘制工具已禁用'**
  String get noVisibleLayersDisabled_4723;

  /// No description provided for @noWebDAVConfig_5019.
  ///
  /// In zh, this message translates to:
  /// **'没有可用的WebDAV配置，请先在WebDAV管理页面添加配置'**
  String get noWebDAVConfig_5019;

  /// No description provided for @noWebDAVConfig_7281.
  ///
  /// In zh, this message translates to:
  /// **'暂无 WebDAV 配置'**
  String get noWebDAVConfig_7281;

  /// No description provided for @noWebDavConfigAvailable_7281.
  ///
  /// In zh, this message translates to:
  /// **'没有可用的WebDAV配置，请先在WebDAV管理页面添加配置'**
  String get noWebDavConfigAvailable_7281;

  /// No description provided for @noZipFileFoundInDirectory_5035.
  ///
  /// In zh, this message translates to:
  /// **'目录中没有找到ZIP文件'**
  String get noZipFileFoundInDirectory_5035;

  /// No description provided for @no_4287.
  ///
  /// In zh, this message translates to:
  /// **'否'**
  String get no_4287;

  /// No description provided for @no_4821.
  ///
  /// In zh, this message translates to:
  /// **'否'**
  String get no_4821;

  /// No description provided for @nonGroupLayersOrderDebug.
  ///
  /// In zh, this message translates to:
  /// **'分离后的非组图层顺序: {layers}'**
  String nonGroupLayersOrderDebug(Object layers);

  /// No description provided for @none_4821.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get none_4821;

  /// No description provided for @none_5729.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get none_5729;

  /// No description provided for @normalPositionAdjustment.
  ///
  /// In zh, this message translates to:
  /// **'正常位置调整: {adjustedNewIndex}'**
  String normalPositionAdjustment(Object adjustedNewIndex);

  /// No description provided for @norwegianNO_4847.
  ///
  /// In zh, this message translates to:
  /// **'挪威语 (挪威)'**
  String get norwegianNO_4847;

  /// No description provided for @norwegian_4846.
  ///
  /// In zh, this message translates to:
  /// **'挪威语'**
  String get norwegian_4846;

  /// No description provided for @notLoaded_4821.
  ///
  /// In zh, this message translates to:
  /// **'未加载'**
  String get notLoaded_4821;

  /// No description provided for @notModified_6843.
  ///
  /// In zh, this message translates to:
  /// **'未修改'**
  String get notModified_6843;

  /// No description provided for @notSet_4821.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get notSet_4821;

  /// No description provided for @notSet_7281.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get notSet_7281;

  /// No description provided for @notSet_7421.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get notSet_7421;

  /// No description provided for @notSet_8921.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get notSet_8921;

  /// No description provided for @notZipFileError_4821.
  ///
  /// In zh, this message translates to:
  /// **'所选文件不是ZIP文件'**
  String get notZipFileError_4821;

  /// No description provided for @noteBackgroundImageHashRef.
  ///
  /// In zh, this message translates to:
  /// **'便签背景图片只有VFS哈希引用: {backgroundImageHash}'**
  String noteBackgroundImageHashRef(Object backgroundImageHash);

  /// No description provided for @noteBackgroundImageHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'提示: 便签背景图片应该在加载时已恢复为直接数据'**
  String get noteBackgroundImageHint_4821;

  /// No description provided for @noteBackgroundImageUploaded.
  ///
  /// In zh, this message translates to:
  /// **'便签背景图片已上传，将在地图保存时存储到资产系统 ({length} bytes)'**
  String noteBackgroundImageUploaded(Object length);

  /// No description provided for @noteBackgroundLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'便签背景图片加载失败 (直接数据): {error}'**
  String noteBackgroundLoadFailed(Object error);

  /// No description provided for @noteDebugInfo.
  ///
  /// In zh, this message translates to:
  /// **'便签[{arg0}] {arg1}: {arg2}个绘画元素'**
  String noteDebugInfo(Object arg0, Object arg1, Object arg2);

  /// No description provided for @noteDrawingElementLoaded.
  ///
  /// In zh, this message translates to:
  /// **'便签绘画元素图像已从资产系统加载，哈希: {imageHash} ({length} bytes)'**
  String noteDrawingElementLoaded(Object imageHash, Object length);

  /// No description provided for @noteDrawingElementSaved.
  ///
  /// In zh, this message translates to:
  /// **'便签绘画元素图像已保存到资产系统，哈希: {hash} ({length} bytes)'**
  String noteDrawingElementSaved(Object hash, Object length);

  /// No description provided for @noteDrawingStats.
  ///
  /// In zh, this message translates to:
  /// **'便签绘制: 元素={elementCount}, 图片缓存={imageCacheCount}'**
  String noteDrawingStats(Object elementCount, Object imageCacheCount);

  /// No description provided for @noteElementDeleted_7281.
  ///
  /// In zh, this message translates to:
  /// **'已删除便签元素'**
  String get noteElementDeleted_7281;

  /// No description provided for @noteElementInspectorEmpty_1589.
  ///
  /// In zh, this message translates to:
  /// **'便签元素检视器 (无元素)'**
  String get noteElementInspectorEmpty_1589;

  /// No description provided for @noteElementInspectorWithCount_7421.
  ///
  /// In zh, this message translates to:
  /// **'便签元素检视器 ({count}个元素)'**
  String noteElementInspectorWithCount_7421(Object count);

  /// No description provided for @noteImagePreloadComplete.
  ///
  /// In zh, this message translates to:
  /// **'便签图片预加载完成: element.id={id}, 图片尺寸={width}x{height}'**
  String noteImagePreloadComplete(Object height, Object id, Object width);

  /// No description provided for @noteImagePreloadFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'便签图片预加载失败: element.id={elementId}, 错误={error}'**
  String noteImagePreloadFailed_7421(Object elementId, Object error);

  /// No description provided for @noteImageSelectionDebug_7421.
  ///
  /// In zh, this message translates to:
  /// **'便签创建图片选区: 缓冲区数据={value}'**
  String noteImageSelectionDebug_7421(Object value);

  /// No description provided for @noteItem_4821.
  ///
  /// In zh, this message translates to:
  /// **'便签'**
  String get noteItem_4821;

  /// No description provided for @noteLayerHint_8421.
  ///
  /// In zh, this message translates to:
  /// **'便签在图层和图例之上显示，使用非常高的渲染顺序，确保始终在最上层'**
  String get noteLayerHint_8421;

  /// No description provided for @noteMovedToTop1234.
  ///
  /// In zh, this message translates to:
  /// **'便签已移到顶层'**
  String get noteMovedToTop1234;

  /// No description provided for @notePreviewRemoved_7421.
  ///
  /// In zh, this message translates to:
  /// **'便签预览已移除'**
  String get notePreviewRemoved_7421;

  /// No description provided for @noteProcessing.
  ///
  /// In zh, this message translates to:
  /// **'处理便签: {title}(zIndex={zIndex}), 索引={noteIndex}, 可见={isVisible}'**
  String noteProcessing(
    Object isVisible,
    Object noteIndex,
    Object title,
    Object zIndex,
  );

  /// No description provided for @noteQueueDebugPrint.
  ///
  /// In zh, this message translates to:
  /// **'便签队列渲染: 便签ID={noteId}, 队列项目={queueLength}'**
  String noteQueueDebugPrint(Object noteId, Object queueLength);

  /// No description provided for @noteRendererElementCount.
  ///
  /// In zh, this message translates to:
  /// **'便签绘制器: 元素数量={count}'**
  String noteRendererElementCount(Object count);

  /// No description provided for @noteTagUpdated_4821.
  ///
  /// In zh, this message translates to:
  /// **'已更新便签元素标签'**
  String get noteTagUpdated_4821;

  /// No description provided for @noteTag_7890.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get noteTag_7890;

  /// No description provided for @noteTagsUpdated.
  ///
  /// In zh, this message translates to:
  /// **'便签标签已更新 ({count}个标签)'**
  String noteTagsUpdated(Object count);

  /// No description provided for @noteTitleHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'便签标题'**
  String get noteTitleHint_4821;

  /// No description provided for @note_8901.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get note_8901;

  /// No description provided for @notesTagsCleared_7281.
  ///
  /// In zh, this message translates to:
  /// **'已清空便签标签'**
  String get notesTagsCleared_7281;

  /// No description provided for @notificationClicked_4821.
  ///
  /// In zh, this message translates to:
  /// **'常驻通知被点击'**
  String get notificationClicked_4821;

  /// No description provided for @notificationClosed.
  ///
  /// In zh, this message translates to:
  /// **'通知被关闭: {message}'**
  String notificationClosed(Object message);

  /// No description provided for @notificationSystemTest_4271.
  ///
  /// In zh, this message translates to:
  /// **'通知系统测试'**
  String get notificationSystemTest_4271;

  /// No description provided for @notificationTestPageTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'通知测试'**
  String get notificationTestPageTitle_4821;

  /// No description provided for @notificationUpdated_7281.
  ///
  /// In zh, this message translates to:
  /// **'✨ 消息已更新！注意没有重新播放动画'**
  String get notificationUpdated_7281;

  /// No description provided for @notificationWillBeUpdated_7281.
  ///
  /// In zh, this message translates to:
  /// **'🔄 这个通知将会被更新（不重新播放动画）'**
  String get notificationWillBeUpdated_7281;

  /// No description provided for @notifications_4821.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get notifications_4821;

  /// No description provided for @nullContextThemeInfo_4821.
  ///
  /// In zh, this message translates to:
  /// **'context为null，无法获取主题信息'**
  String get nullContextThemeInfo_4821;

  /// No description provided for @numberType_9012.
  ///
  /// In zh, this message translates to:
  /// **'数字'**
  String get numberType_9012;

  /// No description provided for @objectOpacity_4271.
  ///
  /// In zh, this message translates to:
  /// **'对象不透明度'**
  String get objectOpacity_4271;

  /// No description provided for @occurrenceTime_4821.
  ///
  /// In zh, this message translates to:
  /// **'发生时间: {timestamp}'**
  String occurrenceTime_4821(Object timestamp);

  /// No description provided for @offlineStatus_3087.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get offlineStatus_3087;

  /// No description provided for @offlineStatus_5732.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get offlineStatus_5732;

  /// No description provided for @offlineStatus_7154.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get offlineStatus_7154;

  /// No description provided for @offlineStatus_7845.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get offlineStatus_7845;

  /// No description provided for @offlineStickyNotePreviewHandled_7421.
  ///
  /// In zh, this message translates to:
  /// **'用户离线，便签预览已直接处理并添加到便签 {stickyNoteId}'**
  String offlineStickyNotePreviewHandled_7421(Object stickyNoteId);

  /// No description provided for @offline_4821.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get offline_4821;

  /// No description provided for @oldDataCleanedUp_7281.
  ///
  /// In zh, this message translates to:
  /// **'旧数据清理完成'**
  String get oldDataCleanedUp_7281;

  /// No description provided for @onePerPage_4821.
  ///
  /// In zh, this message translates to:
  /// **'一页一张'**
  String get onePerPage_4821;

  /// No description provided for @oneSecond_7281.
  ///
  /// In zh, this message translates to:
  /// **'1秒'**
  String get oneSecond_7281;

  /// No description provided for @onlineStatusInitComplete_4821.
  ///
  /// In zh, this message translates to:
  /// **'在线状态管理初始化完成'**
  String get onlineStatusInitComplete_4821;

  /// No description provided for @onlineStatusProcessed.
  ///
  /// In zh, this message translates to:
  /// **'成功处理在线状态列表，共 {count} 个用户'**
  String onlineStatusProcessed(Object count);

  /// No description provided for @onlineStatus_4821.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get onlineStatus_4821;

  /// No description provided for @onlineUsersCount.
  ///
  /// In zh, this message translates to:
  /// **'用户 ({count})'**
  String onlineUsersCount(Object count);

  /// No description provided for @onlineUsers_4271.
  ///
  /// In zh, this message translates to:
  /// **'在线用户'**
  String get onlineUsers_4271;

  /// No description provided for @onlineUsers_4821.
  ///
  /// In zh, this message translates to:
  /// **'在线用户'**
  String get onlineUsers_4821;

  /// No description provided for @onlineUsers_7421.
  ///
  /// In zh, this message translates to:
  /// **'在线用户'**
  String get onlineUsers_7421;

  /// No description provided for @onlyFilesAndFoldersNavigable_7281.
  ///
  /// In zh, this message translates to:
  /// **'仅文件 • 文件夹可导航'**
  String get onlyFilesAndFoldersNavigable_7281;

  /// No description provided for @opacity.
  ///
  /// In zh, this message translates to:
  /// **'不透明度'**
  String get opacity;

  /// No description provided for @opacityLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'透明度'**
  String get opacityLabel_4821;

  /// No description provided for @opacityLabel_7281.
  ///
  /// In zh, this message translates to:
  /// **'不透明度:'**
  String get opacityLabel_7281;

  /// No description provided for @opacityPercentage.
  ///
  /// In zh, this message translates to:
  /// **'透明度: {percentage}%'**
  String opacityPercentage(Object percentage);

  /// No description provided for @openEditorMessage_4521.
  ///
  /// In zh, this message translates to:
  /// **'打开编辑器'**
  String get openEditorMessage_4521;

  /// No description provided for @openFile_7282.
  ///
  /// In zh, this message translates to:
  /// **'打开文件'**
  String get openFile_7282;

  /// No description provided for @openInWindowHint_7281.
  ///
  /// In zh, this message translates to:
  /// **'在窗口中打开功能需要导入窗口组件'**
  String get openInWindowHint_7281;

  /// No description provided for @openInWindowTooltip_4271.
  ///
  /// In zh, this message translates to:
  /// **'在窗口中打开'**
  String get openInWindowTooltip_4271;

  /// No description provided for @openInWindow_4281.
  ///
  /// In zh, this message translates to:
  /// **'在窗口中打开'**
  String get openInWindow_4281;

  /// No description provided for @openInWindow_7281.
  ///
  /// In zh, this message translates to:
  /// **'在窗口中打开'**
  String get openInWindow_7281;

  /// No description provided for @openLegendDrawer_4824.
  ///
  /// In zh, this message translates to:
  /// **'打开图例组绑定抽屉'**
  String get openLegendDrawer_4824;

  /// No description provided for @openLegendGroupDrawer_3827.
  ///
  /// In zh, this message translates to:
  /// **'打开图例组绑定抽屉'**
  String get openLegendGroupDrawer_3827;

  /// No description provided for @openLink.
  ///
  /// In zh, this message translates to:
  /// **'打开链接'**
  String get openLink;

  /// No description provided for @openLinkFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'打开链接失败: {e}'**
  String openLinkFailed_4821(Object e);

  /// No description provided for @openLinkFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'打开链接失败: {e}'**
  String openLinkFailed_7285(Object e);

  /// No description provided for @openNextLegendGroup_3826.
  ///
  /// In zh, this message translates to:
  /// **'打开下一个图例组'**
  String get openNextLegendGroup_3826;

  /// No description provided for @openPreviousLegendGroup_3825.
  ///
  /// In zh, this message translates to:
  /// **'打开上一个图例组'**
  String get openPreviousLegendGroup_3825;

  /// No description provided for @openRelativePathFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'打开相对路径链接失败: {e}'**
  String openRelativePathFailed_7285(Object e);

  /// No description provided for @openSourceAcknowledgement_7281.
  ///
  /// In zh, this message translates to:
  /// **'开源项目致谢'**
  String get openSourceAcknowledgement_7281;

  /// No description provided for @openSourceProjectsIntro_4821.
  ///
  /// In zh, this message translates to:
  /// **'本项目使用了以下优秀的开源项目和资源：'**
  String get openSourceProjectsIntro_4821;

  /// No description provided for @openTextEditorFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'打开文本编辑器失败: {e}'**
  String openTextEditorFailed_7281(Object e);

  /// No description provided for @openVideoInWindow.
  ///
  /// In zh, this message translates to:
  /// **'在窗口中打开视频: {vfsPath}'**
  String openVideoInWindow(Object vfsPath);

  /// No description provided for @openWithTextEditor_7421.
  ///
  /// In zh, this message translates to:
  /// **'使用文本编辑器打开'**
  String get openWithTextEditor_7421;

  /// No description provided for @openZElementInspector_3858.
  ///
  /// In zh, this message translates to:
  /// **'打开Z元素检视器'**
  String get openZElementInspector_3858;

  /// No description provided for @openZInspector_4823.
  ///
  /// In zh, this message translates to:
  /// **'打开Z层级检视器'**
  String get openZInspector_4823;

  /// No description provided for @open_4821.
  ///
  /// In zh, this message translates to:
  /// **'打开'**
  String get open_4821;

  /// No description provided for @open_7281.
  ///
  /// In zh, this message translates to:
  /// **'打开'**
  String get open_7281;

  /// No description provided for @operationCanBeUndone_8245.
  ///
  /// In zh, this message translates to:
  /// **'此操作可以通过撤销功能恢复。'**
  String get operationCanBeUndone_8245;

  /// No description provided for @operationCompletedSuccessfully_7281.
  ///
  /// In zh, this message translates to:
  /// **'您的操作已成功完成'**
  String get operationCompletedSuccessfully_7281;

  /// No description provided for @operationFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'操作失败: {error}'**
  String operationFailedWithError(Object error);

  /// No description provided for @operationSuccess_4821.
  ///
  /// In zh, this message translates to:
  /// **'操作成功'**
  String get operationSuccess_4821;

  /// No description provided for @operation_4821.
  ///
  /// In zh, this message translates to:
  /// **'操作'**
  String get operation_4821;

  /// No description provided for @originalJsonMissing_4821.
  ///
  /// In zh, this message translates to:
  /// **'原始标题JSON文件不存在，尝试sanitized标题'**
  String get originalJsonMissing_4821;

  /// No description provided for @otherGroupSelectedPaths_7425.
  ///
  /// In zh, this message translates to:
  /// **'其他组选中路径'**
  String get otherGroupSelectedPaths_7425;

  /// No description provided for @otherLayersDebug_7421.
  ///
  /// In zh, this message translates to:
  /// **'- 其他图层: {layers}'**
  String otherLayersDebug_7421(Object layers);

  /// No description provided for @otherPermissions_7281.
  ///
  /// In zh, this message translates to:
  /// **'其他权限'**
  String get otherPermissions_7281;

  /// No description provided for @otherSelectedGroup_4821.
  ///
  /// In zh, this message translates to:
  /// **'其他组选中'**
  String get otherSelectedGroup_4821;

  /// No description provided for @otherSettings_7421.
  ///
  /// In zh, this message translates to:
  /// **'其他设置'**
  String get otherSettings_7421;

  /// No description provided for @overlayText_4821.
  ///
  /// In zh, this message translates to:
  /// **'覆盖'**
  String get overlayText_4821;

  /// No description provided for @overwrite_4929.
  ///
  /// In zh, this message translates to:
  /// **'覆盖'**
  String get overwrite_4929;

  /// No description provided for @ownSelectedHeader_5421.
  ///
  /// In zh, this message translates to:
  /// **'自己组选中'**
  String get ownSelectedHeader_5421;

  /// No description provided for @ownSelectedPaths_7425.
  ///
  /// In zh, this message translates to:
  /// **'自己组选中路径'**
  String get ownSelectedPaths_7425;

  /// No description provided for @packageManagement.
  ///
  /// In zh, this message translates to:
  /// **'包管理'**
  String get packageManagement;

  /// No description provided for @pageConfiguration.
  ///
  /// In zh, this message translates to:
  /// **'页面配置'**
  String get pageConfiguration;

  /// No description provided for @pageLayout_7281.
  ///
  /// In zh, this message translates to:
  /// **'页面布局'**
  String get pageLayout_7281;

  /// No description provided for @pageModeDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'全屏页面显示 Markdown，适合深度阅读'**
  String get pageModeDescription_4821;

  /// No description provided for @pageModeTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'2. 页面模式'**
  String get pageModeTitle_4821;

  /// No description provided for @pageNotFound.
  ///
  /// In zh, this message translates to:
  /// **'页面未找到：{uri}'**
  String pageNotFound(Object uri);

  /// No description provided for @pageOrientation_3632.
  ///
  /// In zh, this message translates to:
  /// **'方向'**
  String get pageOrientation_3632;

  /// No description provided for @panelAutoClose_4821.
  ///
  /// In zh, this message translates to:
  /// **'面板自动关闭'**
  String get panelAutoClose_4821;

  /// No description provided for @panelCollapseStatus_4821.
  ///
  /// In zh, this message translates to:
  /// **'面板折叠状态'**
  String get panelCollapseStatus_4821;

  /// No description provided for @panelDefaultState_7428.
  ///
  /// In zh, this message translates to:
  /// **'面板默认{state}状态'**
  String panelDefaultState_7428(Object state);

  /// No description provided for @panelStateSavedOnExit_4821.
  ///
  /// In zh, this message translates to:
  /// **'面板状态已在退出时保存'**
  String get panelStateSavedOnExit_4821;

  /// No description provided for @panelStatusChanged_7281.
  ///
  /// In zh, this message translates to:
  /// **'面板状态已更改'**
  String get panelStatusChanged_7281;

  /// No description provided for @panelUpdateFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'更新面板状态失败: {error}'**
  String panelUpdateFailed_7285(Object error);

  /// No description provided for @paperSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'纸张设置'**
  String get paperSettings_4821;

  /// No description provided for @paperSizeAndOrientation.
  ///
  /// In zh, this message translates to:
  /// **'纸张: {paperSize} ({orientation})'**
  String paperSizeAndOrientation(Object orientation, Object paperSize);

  /// No description provided for @paperSize_7281.
  ///
  /// In zh, this message translates to:
  /// **'纸张大小'**
  String get paperSize_7281;

  /// No description provided for @parameters_4821.
  ///
  /// In zh, this message translates to:
  /// **'参数'**
  String get parameters_4821;

  /// No description provided for @parseAttributesLog_7281.
  ///
  /// In zh, this message translates to:
  /// **'解析属性 - {attributes}'**
  String parseAttributesLog_7281(Object attributes);

  /// No description provided for @parseExtensionSettingsFailed.
  ///
  /// In zh, this message translates to:
  /// **'解析扩展设置JSON失败: {error}'**
  String parseExtensionSettingsFailed(Object error);

  /// No description provided for @parseMessageFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'解析消息失败: {e}'**
  String parseMessageFailed_7285(Object e);

  /// No description provided for @parseNoteDataFailed.
  ///
  /// In zh, this message translates to:
  /// **'解析便签数据失败 [{filePath}]: {error}'**
  String parseNoteDataFailed(Object error, Object filePath);

  /// No description provided for @parseNoteDataFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'解析便签数据失败: {e}'**
  String parseNoteDataFailed_7284(Object e);

  /// No description provided for @parseParamFailed.
  ///
  /// In zh, this message translates to:
  /// **'解析参数定义失败: {line}, 错误: {e}'**
  String parseParamFailed(Object e, Object line);

  /// No description provided for @parseUserLayoutFailed.
  ///
  /// In zh, this message translates to:
  /// **'解析用户 {userId} 的 layout_data 失败: {e}'**
  String parseUserLayoutFailed(Object e, Object userId);

  /// No description provided for @passwordKeepEmpty_1234.
  ///
  /// In zh, this message translates to:
  /// **'密码（留空保持不变）'**
  String get passwordKeepEmpty_1234;

  /// No description provided for @password_5678.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get password_5678;

  /// No description provided for @pasteCompleteSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'粘贴完成，成功处理 {successCount} 个项目'**
  String pasteCompleteSuccessfully(Object successCount);

  /// No description provided for @pasteFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'粘贴失败: {e}'**
  String pasteFailed_7285(Object e);

  /// No description provided for @pasteImageFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'从剪贴板粘贴图片失败: {e}'**
  String pasteImageFailed_4821(Object e);

  /// No description provided for @pasteJsonConfig_7281.
  ///
  /// In zh, this message translates to:
  /// **'请粘贴配置JSON数据：'**
  String get pasteJsonConfig_7281;

  /// No description provided for @paste_3833.
  ///
  /// In zh, this message translates to:
  /// **'粘贴'**
  String get paste_3833;

  /// No description provided for @paste_4821.
  ///
  /// In zh, this message translates to:
  /// **'粘贴'**
  String get paste_4821;

  /// No description provided for @pastedMessage_4821.
  ///
  /// In zh, this message translates to:
  /// **'已粘贴'**
  String get pastedMessage_4821;

  /// No description provided for @pasted_4822.
  ///
  /// In zh, this message translates to:
  /// **'已粘贴'**
  String get pasted_4822;

  /// No description provided for @pathCheckFailed.
  ///
  /// In zh, this message translates to:
  /// **'路径检查失败: {remotePath} - {e}'**
  String pathCheckFailed(Object e, Object remotePath);

  /// No description provided for @pathDiffAnalysisComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'路径差异分析完成:'**
  String get pathDiffAnalysisComplete_7281;

  /// No description provided for @pathExists_4821.
  ///
  /// In zh, this message translates to:
  /// **'路径存在: {fullRemotePath}'**
  String pathExists_4821(Object fullRemotePath);

  /// No description provided for @pathIssuesDetected_7281.
  ///
  /// In zh, this message translates to:
  /// **'检测到 {count} 个路径问题，请展开列表进行修正'**
  String pathIssuesDetected_7281(Object count);

  /// No description provided for @pathLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'路径'**
  String get pathLabel_4821;

  /// No description provided for @pathLabel_5421.
  ///
  /// In zh, this message translates to:
  /// **'路径'**
  String get pathLabel_5421;

  /// No description provided for @pathLabel_7421.
  ///
  /// In zh, this message translates to:
  /// **'路径'**
  String get pathLabel_7421;

  /// No description provided for @pathLoadedComplete_728.
  ///
  /// In zh, this message translates to:
  /// **'路径加载完成: {path}'**
  String pathLoadedComplete_728(Object path);

  /// No description provided for @pathMismatch_7284.
  ///
  /// In zh, this message translates to:
  /// **'路径不匹配: 路径=\"{path}\", 不以\"{folderPath}/\"开头'**
  String pathMismatch_7284(Object folderPath, Object path);

  /// No description provided for @pathNoChineseChars_4821.
  ///
  /// In zh, this message translates to:
  /// **'存储路径不能包含中文字符'**
  String get pathNoChineseChars_4821;

  /// No description provided for @pathSelectionFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'选择路径失败：{e}'**
  String pathSelectionFailed_7421(Object e);

  /// No description provided for @pathStillInUse.
  ///
  /// In zh, this message translates to:
  /// **'路径仍被其他图例组使用，跳过清理: {path}'**
  String pathStillInUse(Object path);

  /// No description provided for @path_4826.
  ///
  /// In zh, this message translates to:
  /// **'路径'**
  String get path_4826;

  /// No description provided for @patternDensity_7281.
  ///
  /// In zh, this message translates to:
  /// **'图案密度'**
  String get patternDensity_7281;

  /// No description provided for @pauseButton_4821.
  ///
  /// In zh, this message translates to:
  /// **'暂停'**
  String get pauseButton_4821;

  /// No description provided for @pauseFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'暂停失败'**
  String get pauseFailed_7281;

  /// No description provided for @pauseFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'暂停失败: {e}'**
  String pauseFailed_7285(Object e);

  /// No description provided for @pauseOperationTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'暂停操作'**
  String get pauseOperationTooltip_7281;

  /// No description provided for @pauseTimerFailed.
  ///
  /// In zh, this message translates to:
  /// **'暂停计时器失败: {e}'**
  String pauseTimerFailed(Object e);

  /// No description provided for @pauseTimerName.
  ///
  /// In zh, this message translates to:
  /// **'暂停 {name}'**
  String pauseTimerName(Object name);

  /// No description provided for @pdfExportFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'PDF导出失败: {e}'**
  String pdfExportFailed_7281(Object e);

  /// No description provided for @pdfExportSuccess_4821.
  ///
  /// In zh, this message translates to:
  /// **'PDF导出成功'**
  String get pdfExportSuccess_4821;

  /// No description provided for @pdfGenerationFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'PDF文档生成失败: {e}'**
  String pdfGenerationFailed_7281(Object e);

  /// No description provided for @pdfPreviewFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'PDF预览生成失败: {e}'**
  String pdfPreviewFailed_7285(Object e);

  /// No description provided for @pdfPreview_4521.
  ///
  /// In zh, this message translates to:
  /// **'PDF预览'**
  String get pdfPreview_4521;

  /// No description provided for @pdfPrintDialogOpened_4821.
  ///
  /// In zh, this message translates to:
  /// **'PDF打印对话框已打开'**
  String get pdfPrintDialogOpened_4821;

  /// No description provided for @pdfPrintDialogOpened_7281.
  ///
  /// In zh, this message translates to:
  /// **'PDF打印对话框已打开'**
  String get pdfPrintDialogOpened_7281;

  /// No description provided for @pdfPrintFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'PDF打印失败，请重试'**
  String get pdfPrintFailed_4821;

  /// No description provided for @pdfPrintFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'PDF打印失败: {e}'**
  String pdfPrintFailed_7285(Object e);

  /// No description provided for @pdfSavedToPath_7281.
  ///
  /// In zh, this message translates to:
  /// **'PDF已保存到: {path}'**
  String pdfSavedToPath_7281(Object path);

  /// No description provided for @penTool_1234.
  ///
  /// In zh, this message translates to:
  /// **'钢笔'**
  String get penTool_1234;

  /// No description provided for @performanceOptimizationInfo_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎯 性能优化信息:'**
  String get performanceOptimizationInfo_7281;

  /// No description provided for @performanceSettings_7281.
  ///
  /// In zh, this message translates to:
  /// **'性能设置'**
  String get performanceSettings_7281;

  /// No description provided for @permissionConflict_4830.
  ///
  /// In zh, this message translates to:
  /// **'权限冲突'**
  String get permissionConflict_4830;

  /// No description provided for @permissionDenied_4824.
  ///
  /// In zh, this message translates to:
  /// **'权限被拒绝'**
  String get permissionDenied_4824;

  /// No description provided for @permissionDetails_7281.
  ///
  /// In zh, this message translates to:
  /// **'权限详情'**
  String get permissionDetails_7281;

  /// No description provided for @permissionFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'权限管理失败: {e}'**
  String permissionFailed_7284(Object e);

  /// No description provided for @permissionManagement_4821.
  ///
  /// In zh, this message translates to:
  /// **'权限管理'**
  String get permissionManagement_4821;

  /// No description provided for @permissionManagement_7421.
  ///
  /// In zh, this message translates to:
  /// **'权限管理'**
  String get permissionManagement_7421;

  /// No description provided for @permissionSaved_7421.
  ///
  /// In zh, this message translates to:
  /// **'权限已保存'**
  String get permissionSaved_7421;

  /// No description provided for @permissionSettings_7281.
  ///
  /// In zh, this message translates to:
  /// **'权限设置'**
  String get permissionSettings_7281;

  /// No description provided for @permissionUpdated_4821.
  ///
  /// In zh, this message translates to:
  /// **'权限已更新'**
  String get permissionUpdated_4821;

  /// No description provided for @permissionUpdated_7281.
  ///
  /// In zh, this message translates to:
  /// **'权限已更新'**
  String get permissionUpdated_7281;

  /// No description provided for @permissionViewError_4821.
  ///
  /// In zh, this message translates to:
  /// **'无法查看权限: {error}'**
  String permissionViewError_4821(Object error);

  /// No description provided for @persistentNotificationDemo_7281.
  ///
  /// In zh, this message translates to:
  /// **'🔥 常驻通知演示 (SnackBar 替换)'**
  String get persistentNotificationDemo_7281;

  /// No description provided for @personalSettingsManagement_4821.
  ///
  /// In zh, this message translates to:
  /// **'管理主题、地图编辑器、界面布局等个人设置'**
  String get personalSettingsManagement_4821;

  /// No description provided for @perspectiveBufferFactorDebug.
  ///
  /// In zh, this message translates to:
  /// **'   - 透视缓冲调节系数: {factor}x'**
  String perspectiveBufferFactorDebug(Object factor);

  /// No description provided for @perspectiveBufferFactorLabel.
  ///
  /// In zh, this message translates to:
  /// **'透视缓冲调节系数: {factor}x'**
  String perspectiveBufferFactorLabel(Object factor);

  /// No description provided for @perspectiveStrengthDebug.
  ///
  /// In zh, this message translates to:
  /// **'   - 当前透视强度: {value} (0~1)'**
  String perspectiveStrengthDebug(Object value);

  /// No description provided for @pinyinConversionFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'拼音转换失败: {e}'**
  String pinyinConversionFailed_4821(Object e);

  /// No description provided for @pitchLog_7287.
  ///
  /// In zh, this message translates to:
  /// **', pitch: {pitch}'**
  String pitchLog_7287(Object pitch);

  /// No description provided for @pixelPenTool_1245.
  ///
  /// In zh, this message translates to:
  /// **'像素笔'**
  String get pixelPenTool_1245;

  /// No description provided for @pixelPen_2079.
  ///
  /// In zh, this message translates to:
  /// **'像素笔'**
  String get pixelPen_2079;

  /// No description provided for @pixelPen_4829.
  ///
  /// In zh, this message translates to:
  /// **'像素笔'**
  String get pixelPen_4829;

  /// No description provided for @planTag_4567.
  ///
  /// In zh, this message translates to:
  /// **'计划'**
  String get planTag_4567;

  /// No description provided for @plan_6789.
  ///
  /// In zh, this message translates to:
  /// **'计划'**
  String get plan_6789;

  /// No description provided for @platformCopyFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'平台特定复制实现失败: {e}'**
  String platformCopyFailed_7285(Object e);

  /// No description provided for @playButton_4821.
  ///
  /// In zh, this message translates to:
  /// **'播放'**
  String get playButton_4821;

  /// No description provided for @playOurAudioPrompt_4821.
  ///
  /// In zh, this message translates to:
  /// **'是否播放我们的音频'**
  String get playOurAudioPrompt_4821;

  /// No description provided for @playPauseFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'播放/暂停操作失败: {e}'**
  String playPauseFailed_4821(Object e);

  /// No description provided for @playPauseFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'播放/暂停操作失败: {e}'**
  String playPauseFailed_7285(Object e);

  /// No description provided for @playQueueEmpty_4821.
  ///
  /// In zh, this message translates to:
  /// **'播放队列为空'**
  String get playQueueEmpty_4821;

  /// No description provided for @playQueueEmpty_7281.
  ///
  /// In zh, this message translates to:
  /// **'播放队列为空'**
  String get playQueueEmpty_7281;

  /// No description provided for @playbackFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'播放失败 - {e}'**
  String playbackFailed_4821(Object e);

  /// No description provided for @playbackFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'播放失败: {e}'**
  String playbackFailed_7285(Object e);

  /// No description provided for @playbackModeSetTo.
  ///
  /// In zh, this message translates to:
  /// **'播放模式设置为 {playbackMode}'**
  String playbackModeSetTo(Object playbackMode);

  /// No description provided for @playbackMode_1234.
  ///
  /// In zh, this message translates to:
  /// **'播放模式'**
  String get playbackMode_1234;

  /// No description provided for @playbackProgress.
  ///
  /// In zh, this message translates to:
  /// **'  - 播放进度: {currentPosition}/{totalDuration}'**
  String playbackProgress(Object currentPosition, Object totalDuration);

  /// No description provided for @playbackRateSetTo.
  ///
  /// In zh, this message translates to:
  /// **'播放速度设置为 {_playbackRate}x'**
  String playbackRateSetTo(Object _playbackRate);

  /// No description provided for @playbackSpeed_4821.
  ///
  /// In zh, this message translates to:
  /// **'播放速度'**
  String get playbackSpeed_4821;

  /// No description provided for @playbackSpeed_7421.
  ///
  /// In zh, this message translates to:
  /// **'播放速度'**
  String get playbackSpeed_7421;

  /// No description provided for @playbackStatus_7421.
  ///
  /// In zh, this message translates to:
  /// **'播放状态'**
  String get playbackStatus_7421;

  /// No description provided for @playerConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接到播放器失败: {e}'**
  String playerConnectionFailed(Object e);

  /// No description provided for @playerConnectionFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'🎵 连接到播放器失败: {e}'**
  String playerConnectionFailed_7285(Object e);

  /// No description provided for @playerInitFailed.
  ///
  /// In zh, this message translates to:
  /// **'播放器初始化失败: {e}'**
  String playerInitFailed(Object e);

  /// No description provided for @playerInitFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'初始化播放器失败: {e}'**
  String playerInitFailed_4821(Object e);

  /// No description provided for @playlistEmpty_7281.
  ///
  /// In zh, this message translates to:
  /// **'播放列表为空'**
  String get playlistEmpty_7281;

  /// No description provided for @playlistIndexOutOfRange_7281.
  ///
  /// In zh, this message translates to:
  /// **'播放队列索引超出范围'**
  String get playlistIndexOutOfRange_7281;

  /// No description provided for @playlistLength.
  ///
  /// In zh, this message translates to:
  /// **'播放列表长度: {length}'**
  String playlistLength(Object length);

  /// No description provided for @playlistTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'播放列表'**
  String get playlistTitle_4821;

  /// No description provided for @playlistTooltip_4271.
  ///
  /// In zh, this message translates to:
  /// **'播放列表'**
  String get playlistTooltip_4271;

  /// No description provided for @pleaseEnterExportName_4961.
  ///
  /// In zh, this message translates to:
  /// **'请输入导出名称'**
  String get pleaseEnterExportName_4961;

  /// No description provided for @pleaseSelectDatabaseAndCollection_4821.
  ///
  /// In zh, this message translates to:
  /// **'请选择数据库和集合'**
  String get pleaseSelectDatabaseAndCollection_4821;

  /// No description provided for @pleaseSelectSourcePath_4958.
  ///
  /// In zh, this message translates to:
  /// **'请选择源路径'**
  String get pleaseSelectSourcePath_4958;

  /// No description provided for @pointsCount.
  ///
  /// In zh, this message translates to:
  /// **'点数: {count}'**
  String pointsCount(Object count);

  /// No description provided for @polishPL_4851.
  ///
  /// In zh, this message translates to:
  /// **'波兰语 (波兰)'**
  String get polishPL_4851;

  /// No description provided for @polish_4850.
  ///
  /// In zh, this message translates to:
  /// **'波兰语'**
  String get polish_4850;

  /// No description provided for @portraitOrientation_1234.
  ///
  /// In zh, this message translates to:
  /// **'竖向'**
  String get portraitOrientation_1234;

  /// No description provided for @portugueseBrazil_4834.
  ///
  /// In zh, this message translates to:
  /// **'葡萄牙语 (巴西)'**
  String get portugueseBrazil_4834;

  /// No description provided for @portuguesePT_4888.
  ///
  /// In zh, this message translates to:
  /// **'葡萄牙语 (葡萄牙)'**
  String get portuguesePT_4888;

  /// No description provided for @portuguese_4833.
  ///
  /// In zh, this message translates to:
  /// **'葡萄牙语'**
  String get portuguese_4833;

  /// No description provided for @positionCoordinates_7421.
  ///
  /// In zh, this message translates to:
  /// **'位置: ({dx}, {dy})'**
  String positionCoordinates_7421(Object dx, Object dy);

  /// No description provided for @powershellReadError_4821.
  ///
  /// In zh, this message translates to:
  /// **'Windows PowerShell 读取失败或剪贴板中没有图片'**
  String get powershellReadError_4821;

  /// No description provided for @preferencesInitialized.
  ///
  /// In zh, this message translates to:
  /// **'用户偏好设置初始化完成: {displayName}'**
  String preferencesInitialized(Object displayName);

  /// No description provided for @preparingDownload_5033.
  ///
  /// In zh, this message translates to:
  /// **'正在准备下载...'**
  String get preparingDownload_5033;

  /// No description provided for @preparingExport_7281.
  ///
  /// In zh, this message translates to:
  /// **'正在准备导出...'**
  String get preparingExport_7281;

  /// No description provided for @preparingFileMappingPreview_4821.
  ///
  /// In zh, this message translates to:
  /// **'正在准备文件映射预览...'**
  String get preparingFileMappingPreview_4821;

  /// No description provided for @preparingPreview_5040.
  ///
  /// In zh, this message translates to:
  /// **'正在准备预览...'**
  String get preparingPreview_5040;

  /// No description provided for @preparingToPrint_7281.
  ///
  /// In zh, this message translates to:
  /// **'正在准备打印...'**
  String get preparingToPrint_7281;

  /// No description provided for @preprocessAudioContent_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎵 _loadMarkdownFile: 预处理音频内容'**
  String get preprocessAudioContent_7281;

  /// No description provided for @preprocessHtmlContent_7281.
  ///
  /// In zh, this message translates to:
  /// **'🔧 _loadMarkdownFile: 预处理HTML内容'**
  String get preprocessHtmlContent_7281;

  /// No description provided for @preprocessLatexContent_7281.
  ///
  /// In zh, this message translates to:
  /// **'🔧 _loadMarkdownFile: 预处理LaTeX内容'**
  String get preprocessLatexContent_7281;

  /// No description provided for @preprocessVideoContent_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎥 _loadMarkdownFile: 预处理视频内容'**
  String get preprocessVideoContent_7281;

  /// No description provided for @pressKeyCombination_4821.
  ///
  /// In zh, this message translates to:
  /// **'请按下按键组合...'**
  String get pressKeyCombination_4821;

  /// No description provided for @pressShortcutFirst_4821.
  ///
  /// In zh, this message translates to:
  /// **'请先按下快捷键组合'**
  String get pressShortcutFirst_4821;

  /// No description provided for @previewGenerationFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'预览生成失败: {e}'**
  String previewGenerationFailed_7421(Object e);

  /// No description provided for @previewImmediatelyProcessedAndAddedToLayer.
  ///
  /// In zh, this message translates to:
  /// **'预览已立即处理并添加到图层 {targetLayerId}'**
  String previewImmediatelyProcessedAndAddedToLayer(Object targetLayerId);

  /// No description provided for @previewMode_4822.
  ///
  /// In zh, this message translates to:
  /// **'预览模式'**
  String get previewMode_4822;

  /// No description provided for @previewQueueCleared.
  ///
  /// In zh, this message translates to:
  /// **'[PreviewQueueManager] 便签 {stickyNoteId} 队列已清空，所有 {totalItems} 个项目处理完成'**
  String previewQueueCleared(Object stickyNoteId, Object totalItems);

  /// No description provided for @previewQueueCleared_7281.
  ///
  /// In zh, this message translates to:
  /// **'预览队列已清空'**
  String get previewQueueCleared_7281;

  /// No description provided for @previewQueueCleared_7421.
  ///
  /// In zh, this message translates to:
  /// **'便签预览队列已清空'**
  String get previewQueueCleared_7421;

  /// No description provided for @previewQueueItemProcessed_7281.
  ///
  /// In zh, this message translates to:
  /// **'[PreviewQueueManager] 便签 {stickyNoteId} 队列项目 {currentItem}/{totalItems} 已处理: {itemId}'**
  String previewQueueItemProcessed_7281(
    Object currentItem,
    Object itemId,
    Object stickyNoteId,
    Object totalItems,
  );

  /// No description provided for @previewQueueLockFailed.
  ///
  /// In zh, this message translates to:
  /// **'[PreviewQueueManager] 无法锁定便签 {stickyNoteId}，预览已加入队列，当前队列长度: {queueLength}'**
  String previewQueueLockFailed(Object queueLength, Object stickyNoteId);

  /// No description provided for @previewQueueProcessed.
  ///
  /// In zh, this message translates to:
  /// **'[PreviewQueueManager] 图层 {layerId} 队列中的预览已处理: {itemId}, z值: {zIndex}'**
  String previewQueueProcessed(Object itemId, Object layerId, Object zIndex);

  /// No description provided for @previewRemoved_7425.
  ///
  /// In zh, this message translates to:
  /// **'预览已移除'**
  String get previewRemoved_7425;

  /// No description provided for @previewSubmitted_7285.
  ///
  /// In zh, this message translates to:
  /// **'预览已提交: {itemId}'**
  String previewSubmitted_7285(Object itemId);

  /// No description provided for @previousLayerGroup_4824.
  ///
  /// In zh, this message translates to:
  /// **'上一个图层组'**
  String get previousLayerGroup_4824;

  /// No description provided for @previousLayer_4822.
  ///
  /// In zh, this message translates to:
  /// **'上一个图层'**
  String get previousLayer_4822;

  /// No description provided for @previousLegendGroup_4822.
  ///
  /// In zh, this message translates to:
  /// **'上一个图例组'**
  String get previousLegendGroup_4822;

  /// No description provided for @previousTrack_7281.
  ///
  /// In zh, this message translates to:
  /// **'上一首'**
  String get previousTrack_7281;

  /// No description provided for @previousVersion_4822.
  ///
  /// In zh, this message translates to:
  /// **'上一个版本'**
  String get previousVersion_4822;

  /// No description provided for @primaryColor.
  ///
  /// In zh, this message translates to:
  /// **'主色调'**
  String get primaryColor;

  /// No description provided for @primaryColor_7285.
  ///
  /// In zh, this message translates to:
  /// **'主色调'**
  String get primaryColor_7285;

  /// No description provided for @printConfigInfo.
  ///
  /// In zh, this message translates to:
  /// **'打印配置信息'**
  String get printConfigInfo;

  /// No description provided for @printLabel_4271.
  ///
  /// In zh, this message translates to:
  /// **'打印'**
  String get printLabel_4271;

  /// No description provided for @printPdf_1234.
  ///
  /// In zh, this message translates to:
  /// **'打印PDF'**
  String get printPdf_1234;

  /// No description provided for @prioritizeLayerGroupEnd_7281.
  ///
  /// In zh, this message translates to:
  /// **'=== _prioritizeLayerGroup 结束 ==='**
  String get prioritizeLayerGroupEnd_7281;

  /// No description provided for @prioritizeLayerGroupStart_7281.
  ///
  /// In zh, this message translates to:
  /// **'=== _prioritizeLayerGroup 开始 ==='**
  String get prioritizeLayerGroupStart_7281;

  /// No description provided for @priorityLayerGroupCombination_7281.
  ///
  /// In zh, this message translates to:
  /// **'优先显示图层和图层组的组合'**
  String get priorityLayerGroupCombination_7281;

  /// No description provided for @priorityLayerGroupDisplay.
  ///
  /// In zh, this message translates to:
  /// **'优先显示图层组: {groupNames}'**
  String priorityLayerGroupDisplay(Object groupNames);

  /// No description provided for @priorityLayersDebug_7421.
  ///
  /// In zh, this message translates to:
  /// **'- 优先图层: {layers}'**
  String priorityLayersDebug_7421(Object layers);

  /// No description provided for @privateKeyDecryptionFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'使用私钥解密失败: {e}'**
  String privateKeyDecryptionFailed_4821(Object e);

  /// No description provided for @privateKeyDeleted_7281.
  ///
  /// In zh, this message translates to:
  /// **'私钥已删除: {privateKeyId}'**
  String privateKeyDeleted_7281(Object privateKeyId);

  /// No description provided for @privateKeyFetchFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取私钥失败: {e}'**
  String privateKeyFetchFailed(Object e);

  /// No description provided for @privateKeyNotFound_7281.
  ///
  /// In zh, this message translates to:
  /// **'私钥未找到: {privateKeyId}'**
  String privateKeyNotFound_7281(Object privateKeyId);

  /// No description provided for @privateKeyNotFound_7285.
  ///
  /// In zh, this message translates to:
  /// **'私钥未找到: {privateKeyId}'**
  String privateKeyNotFound_7285(Object privateKeyId);

  /// No description provided for @privateKeyObtainedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'私钥获取成功: {privateKeyId}'**
  String privateKeyObtainedSuccessfully(Object privateKeyId);

  /// No description provided for @privateKeyRemovedLog.
  ///
  /// In zh, this message translates to:
  /// **'私钥已从 SharedPreferences 删除 {platform}: {privateKeyId}'**
  String privateKeyRemovedLog(Object platform, Object privateKeyId);

  /// No description provided for @privateKeyRetrievedSuccessfully_7281.
  ///
  /// In zh, this message translates to:
  /// **'私钥从 SharedPreferences 获取成功 {platform}: {privateKeyId}'**
  String privateKeyRetrievedSuccessfully_7281(
    Object platform,
    Object privateKeyId,
  );

  /// No description provided for @privateKeySignFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'使用私钥签名失败: {e}'**
  String privateKeySignFailed_7285(Object e);

  /// No description provided for @privateKeyStoredMessage.
  ///
  /// In zh, this message translates to:
  /// **'私钥已存储到 SharedPreferences {platform}: {privateKeyId}'**
  String privateKeyStoredMessage(Object platform, Object privateKeyId);

  /// No description provided for @privateKeyStoredSafely_4821.
  ///
  /// In zh, this message translates to:
  /// **'私钥已安全存储: {privateKeyId}'**
  String privateKeyStoredSafely_4821(Object privateKeyId);

  /// No description provided for @problem_0123.
  ///
  /// In zh, this message translates to:
  /// **'问题'**
  String get problem_0123;

  /// No description provided for @processFolderMappingFailed_5015.
  ///
  /// In zh, this message translates to:
  /// **'处理文件夹映射失败'**
  String get processFolderMappingFailed_5015;

  /// No description provided for @processZipFileFailed_5042.
  ///
  /// In zh, this message translates to:
  /// **'处理ZIP文件失败'**
  String get processZipFileFailed_5042;

  /// No description provided for @processingExternalResourceFile_4987.
  ///
  /// In zh, this message translates to:
  /// **'正在处理外部资源文件...'**
  String get processingExternalResourceFile_4987;

  /// No description provided for @processingFlowDescription_4982.
  ///
  /// In zh, this message translates to:
  /// **'系统会在VFS的fs集合中创建临时文件夹进行处理'**
  String get processingFlowDescription_4982;

  /// No description provided for @processingFlow_4981.
  ///
  /// In zh, this message translates to:
  /// **'处理流程'**
  String get processingFlow_4981;

  /// No description provided for @processingQueueElement_7421.
  ///
  /// In zh, this message translates to:
  /// **'处理队列元素: {elementId} 添加到图层: {layerId}'**
  String processingQueueElement_7421(Object elementId, Object layerId);

  /// No description provided for @processingRequired_4821.
  ///
  /// In zh, this message translates to:
  /// **'需要处理'**
  String get processingRequired_4821;

  /// No description provided for @processingZipFile_5038.
  ///
  /// In zh, this message translates to:
  /// **'正在处理ZIP文件...'**
  String get processingZipFile_5038;

  /// No description provided for @processing_4972.
  ///
  /// In zh, this message translates to:
  /// **'正在处理...'**
  String get processing_4972;

  /// No description provided for @processing_5421.
  ///
  /// In zh, this message translates to:
  /// **'处理中...'**
  String get processing_5421;

  /// No description provided for @profileNameLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'配置文件名称'**
  String get profileNameLabel_4821;

  /// No description provided for @programWorking_1234.
  ///
  /// In zh, this message translates to:
  /// **'程序正在工作中'**
  String get programWorking_1234;

  /// No description provided for @progressBarDragFail_4821.
  ///
  /// In zh, this message translates to:
  /// **'进度条拖拽跳转失败: {e}'**
  String progressBarDragFail_4821(Object e);

  /// No description provided for @progressBarDraggedTo.
  ///
  /// In zh, this message translates to:
  /// **'🎵 进度条拖拽到: {currentPosition} / {totalDuration}'**
  String progressBarDraggedTo(Object currentPosition, Object totalDuration);

  /// No description provided for @progressNotification_4271.
  ///
  /// In zh, this message translates to:
  /// **'进度通知'**
  String get progressNotification_4271;

  /// No description provided for @progressiveWebApp.
  ///
  /// In zh, this message translates to:
  /// **'渐进式Web应用'**
  String get progressiveWebApp;

  /// No description provided for @projectCopied_4821.
  ///
  /// In zh, this message translates to:
  /// **'已复制项目'**
  String get projectCopied_4821;

  /// No description provided for @projectDeleted_7281.
  ///
  /// In zh, this message translates to:
  /// **'已删除项目'**
  String get projectDeleted_7281;

  /// No description provided for @projectDocumentation_4911.
  ///
  /// In zh, this message translates to:
  /// **'项目文档'**
  String get projectDocumentation_4911;

  /// No description provided for @projectItem.
  ///
  /// In zh, this message translates to:
  /// **'项目 {index}'**
  String projectItem(Object index);

  /// No description provided for @projectLinksSection_4908.
  ///
  /// In zh, this message translates to:
  /// **'项目地址'**
  String get projectLinksSection_4908;

  /// No description provided for @propertiesPanel_6789.
  ///
  /// In zh, this message translates to:
  /// **'属性面板'**
  String get propertiesPanel_6789;

  /// No description provided for @properties_4281.
  ///
  /// In zh, this message translates to:
  /// **'属性'**
  String get properties_4281;

  /// No description provided for @properties_4821.
  ///
  /// In zh, this message translates to:
  /// **'属性'**
  String get properties_4821;

  /// No description provided for @publicKeyConversionComplete_4821.
  ///
  /// In zh, this message translates to:
  /// **'公钥格式转换完成'**
  String get publicKeyConversionComplete_4821;

  /// No description provided for @publicKeyConversionFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'公钥格式转换失败: {e}'**
  String publicKeyConversionFailed_7285(Object e);

  /// No description provided for @publicKeyFormatConversionSuccess_7281.
  ///
  /// In zh, this message translates to:
  /// **'公钥格式转换成功: RSA PUBLIC KEY → PUBLIC KEY'**
  String get publicKeyFormatConversionSuccess_7281;

  /// No description provided for @pushNotifications.
  ///
  /// In zh, this message translates to:
  /// **'推送通知'**
  String get pushNotifications;

  /// No description provided for @pushNotifications_4821.
  ///
  /// In zh, this message translates to:
  /// **'推送通知'**
  String get pushNotifications_4821;

  /// No description provided for @quickCreate_7421.
  ///
  /// In zh, this message translates to:
  /// **'快速创建'**
  String get quickCreate_7421;

  /// No description provided for @quickSelectLayerCategory_4821.
  ///
  /// In zh, this message translates to:
  /// **'快速选择 (图层)'**
  String get quickSelectLayerCategory_4821;

  /// No description provided for @quickSelectLayerGroup.
  ///
  /// In zh, this message translates to:
  /// **'快速选择 (图层组)'**
  String get quickSelectLayerGroup;

  /// No description provided for @quickTest_7421.
  ///
  /// In zh, this message translates to:
  /// **'快速测试'**
  String get quickTest_7421;

  /// No description provided for @r6OperatorSvgTest_4271.
  ///
  /// In zh, this message translates to:
  /// **'R6 干员 SVG 测试'**
  String get r6OperatorSvgTest_4271;

  /// No description provided for @r6OperatorsAssetsDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'彩虹六号干员头像和图标资源'**
  String get r6OperatorsAssetsDescription_4821;

  /// No description provided for @r6OperatorsAssetsSubtitle_7539.
  ///
  /// In zh, this message translates to:
  /// **'marcopixel/r6operators 仓库提供的干员素材'**
  String get r6OperatorsAssetsSubtitle_7539;

  /// No description provided for @radialGestureDemoTitle_4721.
  ///
  /// In zh, this message translates to:
  /// **'径向手势菜单演示'**
  String get radialGestureDemoTitle_4721;

  /// No description provided for @radialMenuInstructions_7281.
  ///
  /// In zh, this message translates to:
  /// **'1. 按住中键或触摸板双指按下调起菜单\n2. 拖动到菜单项上会自动进入子菜单\n3. 拖回中心区域返回主菜单\n4. 松开鼠标/手指执行选择的动作\n5. 开启调试模式可以看到连线和角度信息'**
  String get radialMenuInstructions_7281;

  /// No description provided for @radianUnit_7421.
  ///
  /// In zh, this message translates to:
  /// **'弧度'**
  String get radianUnit_7421;

  /// No description provided for @radianValue.
  ///
  /// In zh, this message translates to:
  /// **'弧度:{value}'**
  String radianValue(Object value);

  /// No description provided for @randomPlay_4271.
  ///
  /// In zh, this message translates to:
  /// **'随机播放'**
  String get randomPlay_4271;

  /// No description provided for @rawResponseContent.
  ///
  /// In zh, this message translates to:
  /// **'原始响应内容: {responseBody}'**
  String rawResponseContent(Object responseBody);

  /// No description provided for @readDirectoryContentFailed_5023.
  ///
  /// In zh, this message translates to:
  /// **'读取目录内容失败'**
  String get readDirectoryContentFailed_5023;

  /// No description provided for @readFileFailed_4985.
  ///
  /// In zh, this message translates to:
  /// **'读取文件失败'**
  String get readFileFailed_4985;

  /// No description provided for @readOnlyMode_4821.
  ///
  /// In zh, this message translates to:
  /// **'只读模式'**
  String get readOnlyMode_4821;

  /// No description provided for @readOnlyMode_5421.
  ///
  /// In zh, this message translates to:
  /// **'只读模式'**
  String get readOnlyMode_5421;

  /// No description provided for @readOnlyMode_6732.
  ///
  /// In zh, this message translates to:
  /// **'只读模式'**
  String get readOnlyMode_6732;

  /// No description provided for @readOnlyMode_7421.
  ///
  /// In zh, this message translates to:
  /// **'只读模式'**
  String get readOnlyMode_7421;

  /// No description provided for @readPermission_4821.
  ///
  /// In zh, this message translates to:
  /// **'读取'**
  String get readPermission_4821;

  /// No description provided for @readPermission_5421.
  ///
  /// In zh, this message translates to:
  /// **'读取'**
  String get readPermission_5421;

  /// No description provided for @readWebDAVDirectoryFailed_5026.
  ///
  /// In zh, this message translates to:
  /// **'读取WebDAV目录失败'**
  String get readWebDAVDirectoryFailed_5026;

  /// No description provided for @readingImageFromClipboard_4721.
  ///
  /// In zh, this message translates to:
  /// **'正在从剪贴板读取图片...'**
  String get readingImageFromClipboard_4721;

  /// No description provided for @readingJsonFile_7421.
  ///
  /// In zh, this message translates to:
  /// **'读取JSON文件: {path}'**
  String readingJsonFile_7421(Object path);

  /// No description provided for @readingWebDAVDirectory_5020.
  ///
  /// In zh, this message translates to:
  /// **'正在读取WebDAV目录...'**
  String get readingWebDAVDirectory_5020;

  /// No description provided for @reapplyThemeFilter_7281.
  ///
  /// In zh, this message translates to:
  /// **'重新应用主题滤镜'**
  String get reapplyThemeFilter_7281;

  /// No description provided for @rearrangedOrder_4281.
  ///
  /// In zh, this message translates to:
  /// **'重新排列后的显示顺序:'**
  String get rearrangedOrder_4281;

  /// No description provided for @receivedMessage.
  ///
  /// In zh, this message translates to:
  /// **'收到: {type} - {data}'**
  String receivedMessage(Object data, Object type);

  /// No description provided for @recentColors.
  ///
  /// In zh, this message translates to:
  /// **'最近使用的颜色'**
  String get recentColors;

  /// No description provided for @recentColors_7281.
  ///
  /// In zh, this message translates to:
  /// **'最近颜色'**
  String get recentColors_7281;

  /// No description provided for @recentExecutionRecords_4821.
  ///
  /// In zh, this message translates to:
  /// **'最近执行记录'**
  String get recentExecutionRecords_4821;

  /// No description provided for @recentlyUsedColors_4821.
  ///
  /// In zh, this message translates to:
  /// **'最近使用的颜色'**
  String get recentlyUsedColors_4821;

  /// No description provided for @recentlyUsed_7421.
  ///
  /// In zh, this message translates to:
  /// **'最近使用'**
  String get recentlyUsed_7421;

  /// No description provided for @reconnecting_7845.
  ///
  /// In zh, this message translates to:
  /// **'重连中'**
  String get reconnecting_7845;

  /// No description provided for @reconnecting_8265.
  ///
  /// In zh, this message translates to:
  /// **'重连中'**
  String get reconnecting_8265;

  /// No description provided for @rectangle.
  ///
  /// In zh, this message translates to:
  /// **'矩形'**
  String get rectangle;

  /// No description provided for @rectangleLabel_4521.
  ///
  /// In zh, this message translates to:
  /// **'矩形'**
  String get rectangleLabel_4521;

  /// No description provided for @recursivelyDeletedOldAssets.
  ///
  /// In zh, this message translates to:
  /// **'已递归删除旧的assets目录及其所有内容: {assetsPath}'**
  String recursivelyDeletedOldAssets(Object assetsPath);

  /// No description provided for @recursivelyDeletedOldDataDir.
  ///
  /// In zh, this message translates to:
  /// **'已递归删除旧的data目录及其所有内容: {dataPath}'**
  String recursivelyDeletedOldDataDir(Object dataPath);

  /// No description provided for @redoOperation_7421.
  ///
  /// In zh, this message translates to:
  /// **'执行重做操作'**
  String get redoOperation_7421;

  /// No description provided for @redoWithReactiveSystem_4821.
  ///
  /// In zh, this message translates to:
  /// **'使用响应式系统重做'**
  String get redoWithReactiveSystem_4821;

  /// No description provided for @redo_3830.
  ///
  /// In zh, this message translates to:
  /// **'重做'**
  String get redo_3830;

  /// No description provided for @redo_4823.
  ///
  /// In zh, this message translates to:
  /// **'重做'**
  String get redo_4823;

  /// No description provided for @redo_7281.
  ///
  /// In zh, this message translates to:
  /// **'重做'**
  String get redo_7281;

  /// No description provided for @reduceSpacingForSmallScreen_7281.
  ///
  /// In zh, this message translates to:
  /// **'减少界面元素间距，适合小屏幕'**
  String get reduceSpacingForSmallScreen_7281;

  /// No description provided for @referenceLayer_1234.
  ///
  /// In zh, this message translates to:
  /// **'参考图层'**
  String get referenceLayer_1234;

  /// No description provided for @referenceTag_1235.
  ///
  /// In zh, this message translates to:
  /// **'参考'**
  String get referenceTag_1235;

  /// No description provided for @refreshButton_7421.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refreshButton_7421;

  /// No description provided for @refreshConfigFailed_5421.
  ///
  /// In zh, this message translates to:
  /// **'刷新活跃配置失败: {e}'**
  String refreshConfigFailed_5421(Object e);

  /// No description provided for @refreshConfigFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'刷新配置列表失败: {e}'**
  String refreshConfigFailed_7284(Object e);

  /// No description provided for @refreshDirectoryTree_7281.
  ///
  /// In zh, this message translates to:
  /// **'刷新目录树'**
  String get refreshDirectoryTree_7281;

  /// No description provided for @refreshFileList_4821.
  ///
  /// In zh, this message translates to:
  /// **'刷新文件列表'**
  String get refreshFileList_4821;

  /// No description provided for @refreshLabel_7421.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refreshLabel_7421;

  /// No description provided for @refreshOperation_7284.
  ///
  /// In zh, this message translates to:
  /// **'刷新操作'**
  String get refreshOperation_7284;

  /// No description provided for @refreshStatus_4821.
  ///
  /// In zh, this message translates to:
  /// **'刷新状态'**
  String get refreshStatus_4821;

  /// No description provided for @refreshTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refreshTooltip_7281;

  /// No description provided for @refresh_4821.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refresh_4821;

  /// No description provided for @refresh_4822.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refresh_4822;

  /// No description provided for @refresh_4976.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refresh_4976;

  /// No description provided for @releaseMapEditorAdapter_4821.
  ///
  /// In zh, this message translates to:
  /// **'释放地图编辑器集成适配器资源'**
  String get releaseMapEditorAdapter_4821;

  /// No description provided for @releaseMapEditorResources_7281.
  ///
  /// In zh, this message translates to:
  /// **'释放地图编辑器响应式系统资源'**
  String get releaseMapEditorResources_7281;

  /// No description provided for @releaseMouseToCompleteMove_7281.
  ///
  /// In zh, this message translates to:
  /// **'• 释放鼠标完成移动操作'**
  String get releaseMouseToCompleteMove_7281;

  /// No description provided for @releaseResourceManager_4821.
  ///
  /// In zh, this message translates to:
  /// **'释放新响应式脚本管理器资源'**
  String get releaseResourceManager_4821;

  /// No description provided for @releaseScriptEngineResources_4821.
  ///
  /// In zh, this message translates to:
  /// **'释放新响应式脚本引擎资源'**
  String get releaseScriptEngineResources_4821;

  /// No description provided for @releaseToAddLegend_4821.
  ///
  /// In zh, this message translates to:
  /// **'释放以添加图例到此位置'**
  String get releaseToAddLegend_4821;

  /// No description provided for @reloadTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'重新加载'**
  String get reloadTooltip_7281;

  /// No description provided for @remainingAudiosCount.
  ///
  /// In zh, this message translates to:
  /// **'... 还有{count}个音频'**
  String remainingAudiosCount(Object count);

  /// No description provided for @remainingConflictsToResolve.
  ///
  /// In zh, this message translates to:
  /// **'还有 {remainingConflicts} 个冲突需要处理'**
  String remainingConflictsToResolve(Object remainingConflicts);

  /// No description provided for @remainingLegendBlocked_4821.
  ///
  /// In zh, this message translates to:
  /// **'剩余图例被遮挡'**
  String get remainingLegendBlocked_4821;

  /// No description provided for @remarkTag_7890.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get remarkTag_7890;

  /// No description provided for @rememberMaximizeState_4821.
  ///
  /// In zh, this message translates to:
  /// **'记住最大化状态'**
  String get rememberMaximizeState_4821;

  /// No description provided for @reminder_7890.
  ///
  /// In zh, this message translates to:
  /// **'提醒'**
  String get reminder_7890;

  /// No description provided for @remoteConflictError_7285.
  ///
  /// In zh, this message translates to:
  /// **'处理远程冲突失败'**
  String get remoteConflictError_7285;

  /// No description provided for @remoteDataProcessingFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'处理远程数据失败: {error}'**
  String remoteDataProcessingFailed_7421(Object error);

  /// No description provided for @remoteElementLockFailure_4821.
  ///
  /// In zh, this message translates to:
  /// **'处理远程元素锁定失败'**
  String get remoteElementLockFailure_4821;

  /// No description provided for @remotePointerError_4821.
  ///
  /// In zh, this message translates to:
  /// **'处理远程用户指针失败'**
  String get remotePointerError_4821;

  /// No description provided for @remoteUserJoinFailure_4821.
  ///
  /// In zh, this message translates to:
  /// **'处理远程用户加入失败'**
  String get remoteUserJoinFailure_4821;

  /// No description provided for @remoteUserLeaveError_4728.
  ///
  /// In zh, this message translates to:
  /// **'处理远程用户离开失败'**
  String get remoteUserLeaveError_4728;

  /// No description provided for @remoteUserSelectionFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'处理远程用户选择失败'**
  String get remoteUserSelectionFailed_7421;

  /// No description provided for @remoteUser_4521.
  ///
  /// In zh, this message translates to:
  /// **'远程用户'**
  String get remoteUser_4521;

  /// No description provided for @removeAvatar_4271.
  ///
  /// In zh, this message translates to:
  /// **'移除头像'**
  String get removeAvatar_4271;

  /// No description provided for @removeBackgroundImage_4271.
  ///
  /// In zh, this message translates to:
  /// **'移除背景图片'**
  String get removeBackgroundImage_4271;

  /// No description provided for @removeCustomColorFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'移除自定义颜色失败: {error}'**
  String removeCustomColorFailed_7421(Object error);

  /// No description provided for @removeCustomTagFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'移除自定义标签失败: {error}'**
  String removeCustomTagFailed_7421(Object error);

  /// No description provided for @removeFailedMessage_7421.
  ///
  /// In zh, this message translates to:
  /// **'移除失败: {error}'**
  String removeFailedMessage_7421(Object error);

  /// No description provided for @removeImage_7421.
  ///
  /// In zh, this message translates to:
  /// **'移除图片'**
  String get removeImage_7421;

  /// No description provided for @remove_4821.
  ///
  /// In zh, this message translates to:
  /// **'移除'**
  String get remove_4821;

  /// No description provided for @removedFromQueue_7421.
  ///
  /// In zh, this message translates to:
  /// **'从播放队列移除'**
  String get removedFromQueue_7421;

  /// No description provided for @removedPathsCount_7421.
  ///
  /// In zh, this message translates to:
  /// **'  移除路径: {count} 个'**
  String removedPathsCount_7421(Object count);

  /// No description provided for @renameFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'重命名失败'**
  String get renameFailed_4821;

  /// No description provided for @renameFailed_4845.
  ///
  /// In zh, this message translates to:
  /// **'重命名失败'**
  String get renameFailed_4845;

  /// No description provided for @renameFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'重命名失败: {e}'**
  String renameFailed_7284(Object e);

  /// No description provided for @renameFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'重命名失败: {e}'**
  String renameFailed_7285(Object e);

  /// No description provided for @renameFileOrFolder_7421.
  ///
  /// In zh, this message translates to:
  /// **'{isDirectory, select, true{重命名 文件夹} false{重命名 文件} other{重命名}}'**
  String renameFileOrFolder_7421(String isDirectory);

  /// No description provided for @renameFolderFailed.
  ///
  /// In zh, this message translates to:
  /// **'重命名文件夹失败 [{oldPath} -> {newPath}]: {error}'**
  String renameFolderFailed(Object error, Object newPath, Object oldPath);

  /// No description provided for @renameFolder_4271.
  ///
  /// In zh, this message translates to:
  /// **'重命名文件夹'**
  String get renameFolder_4271;

  /// No description provided for @renameFolder_4841.
  ///
  /// In zh, this message translates to:
  /// **'重命名文件夹'**
  String get renameFolder_4841;

  /// No description provided for @renameGroup_4821.
  ///
  /// In zh, this message translates to:
  /// **'重命名组'**
  String get renameGroup_4821;

  /// No description provided for @renameLayerGroup_7539.
  ///
  /// In zh, this message translates to:
  /// **'重命名图层组'**
  String get renameLayerGroup_7539;

  /// No description provided for @renameMapFailed.
  ///
  /// In zh, this message translates to:
  /// **'重命名地图失败 [{oldTitle} -> {newTitle}]: {error}'**
  String renameMapFailed(Object error, Object newTitle, Object oldTitle);

  /// No description provided for @renameMap_4846.
  ///
  /// In zh, this message translates to:
  /// **'重命名地图'**
  String get renameMap_4846;

  /// No description provided for @renameSuccess_4821.
  ///
  /// In zh, this message translates to:
  /// **'重命名成功'**
  String get renameSuccess_4821;

  /// No description provided for @rename_4821.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get rename_4821;

  /// No description provided for @rename_4852.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get rename_4852;

  /// No description provided for @rename_7421.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get rename_7421;

  /// No description provided for @renamedDemoMap.
  ///
  /// In zh, this message translates to:
  /// **'演示地图 - 已重命名 {timestamp}'**
  String renamedDemoMap(Object timestamp);

  /// No description provided for @renamedSuccessfully_7281.
  ///
  /// In zh, this message translates to:
  /// **'已重命名'**
  String get renamedSuccessfully_7281;

  /// No description provided for @renderBoxWarning_4721.
  ///
  /// In zh, this message translates to:
  /// **'警告：无法获取RenderBox，使用默认位置处理拖拽'**
  String get renderBoxWarning_4721;

  /// No description provided for @rendererAudioUuidMap_4821.
  ///
  /// In zh, this message translates to:
  /// **'渲染器: _audioUuidMap'**
  String get rendererAudioUuidMap_4821;

  /// No description provided for @reorderLayerFailed.
  ///
  /// In zh, this message translates to:
  /// **'重排序图层失败: {error}'**
  String reorderLayerFailed(Object error);

  /// No description provided for @reorderLayerLog.
  ///
  /// In zh, this message translates to:
  /// **'重排序图层: oldIndex={oldIndex}, newIndex={newIndex}'**
  String reorderLayerLog(Object newIndex, Object oldIndex);

  /// No description provided for @reorderLayersCall_7284.
  ///
  /// In zh, this message translates to:
  /// **'=== reorderLayersReactive 调用 ==='**
  String get reorderLayersCall_7284;

  /// No description provided for @reorderLayersComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'=== reorderLayersInGroupReactive 完成 ==='**
  String get reorderLayersComplete_7281;

  /// No description provided for @reorderLayersInGroupReactiveCall_7281.
  ///
  /// In zh, this message translates to:
  /// **'=== reorderLayersInGroupReactive 调用 ==='**
  String get reorderLayersInGroupReactiveCall_7281;

  /// No description provided for @reorderNoteLog.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 重新排序便签 {oldIndex} -> {newIndex}'**
  String reorderNoteLog(Object newIndex, Object oldIndex);

  /// No description provided for @reorderNotesFailed.
  ///
  /// In zh, this message translates to:
  /// **'重新排序便签失败: {e}'**
  String reorderNotesFailed(Object e);

  /// No description provided for @reorderNotesFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'重新排序便签失败: {e}'**
  String reorderNotesFailed_4821(Object e);

  /// No description provided for @reorderStickyNote.
  ///
  /// In zh, this message translates to:
  /// **'重新排序便利贴: {oldIndex} -> {newIndex}'**
  String reorderStickyNote(Object newIndex, Object oldIndex);

  /// No description provided for @reorderStickyNotesCount.
  ///
  /// In zh, this message translates to:
  /// **'通过拖拽重新排序便利贴，数量: {count}'**
  String reorderStickyNotesCount(Object count);

  /// No description provided for @replaceExistingFileWithNew_7281.
  ///
  /// In zh, this message translates to:
  /// **'用新文件替换现有文件'**
  String get replaceExistingFileWithNew_7281;

  /// No description provided for @reportBugOrFeatureSuggestion_7281.
  ///
  /// In zh, this message translates to:
  /// **'报告 Bug 或提出功能建议'**
  String get reportBugOrFeatureSuggestion_7281;

  /// No description provided for @requestOnlineStatusFailed.
  ///
  /// In zh, this message translates to:
  /// **'请求在线状态列表失败: {error}'**
  String requestOnlineStatusFailed(Object error);

  /// No description provided for @requestUrl_4821.
  ///
  /// In zh, this message translates to:
  /// **'请求 URL: {url}'**
  String requestUrl_4821(Object url);

  /// No description provided for @requiredParamError_7421.
  ///
  /// In zh, this message translates to:
  /// **'{name}是必填参数'**
  String requiredParamError_7421(Object name);

  /// No description provided for @requiredParameter.
  ///
  /// In zh, this message translates to:
  /// **'{name}是必填参数'**
  String requiredParameter(Object name);

  /// No description provided for @reservedNameError_4821.
  ///
  /// In zh, this message translates to:
  /// **'不能使用系统保留名称'**
  String get reservedNameError_4821;

  /// No description provided for @resetAllSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'重置所有设置'**
  String get resetAllSettings_4821;

  /// No description provided for @resetButton_4521.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get resetButton_4521;

  /// No description provided for @resetButton_5421.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get resetButton_5421;

  /// No description provided for @resetButton_7421.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get resetButton_7421;

  /// No description provided for @resetFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'重置失败：{error}'**
  String resetFailedWithError(Object error);

  /// No description provided for @resetLayoutSettings_4271.
  ///
  /// In zh, this message translates to:
  /// **'重置布局设置'**
  String get resetLayoutSettings_4271;

  /// No description provided for @resetMapData_7421.
  ///
  /// In zh, this message translates to:
  /// **'重置地图数据'**
  String get resetMapData_7421;

  /// No description provided for @resetMigrationFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'重置迁移状态失败: {e}'**
  String resetMigrationFailed_4821(Object e);

  /// No description provided for @resetReactiveScriptEngine_4821.
  ///
  /// In zh, this message translates to:
  /// **'重置新响应式脚本引擎'**
  String get resetReactiveScriptEngine_4821;

  /// No description provided for @resetScriptEngine_7281.
  ///
  /// In zh, this message translates to:
  /// **'重置脚本引擎'**
  String get resetScriptEngine_7281;

  /// No description provided for @resetSettings.
  ///
  /// In zh, this message translates to:
  /// **'重置为默认值'**
  String get resetSettings;

  /// No description provided for @resetSettingsFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'重置设置失败: {error}'**
  String resetSettingsFailed_7421(Object error);

  /// No description provided for @resetShortcutsConfirmation_4821.
  ///
  /// In zh, this message translates to:
  /// **'确定要将所有快捷键恢复到默认设置吗？此操作将覆盖您的自定义快捷键设置。'**
  String get resetShortcutsConfirmation_4821;

  /// No description provided for @resetTimerFailed.
  ///
  /// In zh, this message translates to:
  /// **'重置计时器失败: {error}'**
  String resetTimerFailed(Object error);

  /// No description provided for @resetTimerName.
  ///
  /// In zh, this message translates to:
  /// **'重置 {name}'**
  String resetTimerName(Object name);

  /// No description provided for @resetToAutoSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'重置为自动设置'**
  String get resetToAutoSettings_4821;

  /// No description provided for @resetToDefault_4271.
  ///
  /// In zh, this message translates to:
  /// **'重置为默认'**
  String get resetToDefault_4271;

  /// No description provided for @resetToDefault_4855.
  ///
  /// In zh, this message translates to:
  /// **'重置为默认值 (1.0)'**
  String get resetToDefault_4855;

  /// No description provided for @resetToolSettingsConfirmation_4821.
  ///
  /// In zh, this message translates to:
  /// **'确定要将工具设置重置为默认值吗？此操作不可撤销。'**
  String get resetToolSettingsConfirmation_4821;

  /// No description provided for @resetToolSettings_4271.
  ///
  /// In zh, this message translates to:
  /// **'重置工具设置'**
  String get resetToolSettings_4271;

  /// No description provided for @resetTtsSettings_4271.
  ///
  /// In zh, this message translates to:
  /// **'重置TTS设置'**
  String get resetTtsSettings_4271;

  /// No description provided for @resetVersionLegendSelection.
  ///
  /// In zh, this message translates to:
  /// **'重置版本 {versionId} 图例组 {legendGroupId} 的选择'**
  String resetVersionLegendSelection(Object legendGroupId, Object versionId);

  /// No description provided for @resetWindowSizeFailed_4829.
  ///
  /// In zh, this message translates to:
  /// **'重置窗口大小失败: {e}'**
  String resetWindowSizeFailed_4829(Object e);

  /// No description provided for @resetWindowSize_4271.
  ///
  /// In zh, this message translates to:
  /// **'重置窗口大小'**
  String get resetWindowSize_4271;

  /// No description provided for @resetZoomTooltip_4821.
  ///
  /// In zh, this message translates to:
  /// **'重置缩放'**
  String get resetZoomTooltip_4821;

  /// No description provided for @residentNotificationClosed_7281.
  ///
  /// In zh, this message translates to:
  /// **'常驻通知被关闭'**
  String get residentNotificationClosed_7281;

  /// No description provided for @resourceManagement.
  ///
  /// In zh, this message translates to:
  /// **'资源管理'**
  String get resourceManagement;

  /// No description provided for @resourcePackInfo_4950.
  ///
  /// In zh, this message translates to:
  /// **'资源包信息'**
  String get resourcePackInfo_4950;

  /// No description provided for @resourcePackName_4933.
  ///
  /// In zh, this message translates to:
  /// **'资源包名称 *'**
  String get resourcePackName_4933;

  /// No description provided for @resourcePackageTag_4826.
  ///
  /// In zh, this message translates to:
  /// **'资源包'**
  String get resourcePackageTag_4826;

  /// No description provided for @resourceReleaseComplete_4821.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService 资源释放完成'**
  String get resourceReleaseComplete_4821;

  /// No description provided for @resourceReleaseFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService 释放资源失败: {e}'**
  String resourceReleaseFailed_4821(Object e);

  /// No description provided for @resourceReleased_4821.
  ///
  /// In zh, this message translates to:
  /// **'在线状态管理资源已释放'**
  String get resourceReleased_4821;

  /// No description provided for @responsiveDataLayerOrder.
  ///
  /// In zh, this message translates to:
  /// **'响应式数据图层order: {layers}'**
  String responsiveDataLayerOrder(Object layers);

  /// No description provided for @responsiveLayerManagerReorder.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 重新排序图层 {oldIndex} -> {newIndex}'**
  String responsiveLayerManagerReorder(Object newIndex, Object oldIndex);

  /// No description provided for @responsiveNoteManagerDeleteNote_7421.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 删除便签 {noteId}'**
  String responsiveNoteManagerDeleteNote_7421(Object noteId);

  /// No description provided for @responsiveNoteManager_7281.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 拖拽重新排序便签，数量: {count}'**
  String responsiveNoteManager_7281(Object count);

  /// No description provided for @responsiveScriptDescription_4521.
  ///
  /// In zh, this message translates to:
  /// **'响应式脚本会自动响应地图数据变化，确保实时数据一致性'**
  String get responsiveScriptDescription_4521;

  /// No description provided for @responsiveScriptManagerAccessMapData_4821.
  ///
  /// In zh, this message translates to:
  /// **'新的响应式脚本管理器自动通过MapDataBloc访问地图数据'**
  String get responsiveScriptManagerAccessMapData_4821;

  /// No description provided for @responsiveSystemAddLayerFailed.
  ///
  /// In zh, this message translates to:
  /// **'响应式系统添加图层失败: {e}'**
  String responsiveSystemAddLayerFailed(Object e);

  /// No description provided for @responsiveSystemDeleteFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'响应式系统删除元素失败: {e}'**
  String responsiveSystemDeleteFailed_4821(Object e);

  /// No description provided for @responsiveSystemDeleteLayerFailed.
  ///
  /// In zh, this message translates to:
  /// **'响应式系统删除图层失败: {e}'**
  String responsiveSystemDeleteLayerFailed(Object e);

  /// No description provided for @responsiveSystemDeleteLegendGroupFailed.
  ///
  /// In zh, this message translates to:
  /// **'响应式系统删除图例组失败: {e}'**
  String responsiveSystemDeleteLegendGroupFailed(Object e);

  /// No description provided for @responsiveSystemDeleteNoteFailed.
  ///
  /// In zh, this message translates to:
  /// **'响应式系统删除便签元素失败: {e}'**
  String responsiveSystemDeleteNoteFailed(Object e);

  /// No description provided for @responsiveSystemGroupReorderFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'响应式系统组内重排序图层失败: {e}'**
  String responsiveSystemGroupReorderFailed_4821(Object e);

  /// No description provided for @responsiveSystemInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'响应式系统初始化完成'**
  String get responsiveSystemInitialized_7281;

  /// No description provided for @responsiveSystemInitialized_7421.
  ///
  /// In zh, this message translates to:
  /// **'响应式系统初始化完成'**
  String get responsiveSystemInitialized_7421;

  /// No description provided for @responsiveSystemRedoFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'响应式系统重做失败: {e}'**
  String responsiveSystemRedoFailed_7421(Object e);

  /// No description provided for @responsiveSystemReorderFailed.
  ///
  /// In zh, this message translates to:
  /// **'响应式系统重排序图层失败: {e}'**
  String responsiveSystemReorderFailed(Object e);

  /// No description provided for @responsiveSystemUndoFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'响应式系统撤销失败: {e}'**
  String responsiveSystemUndoFailed_7421(Object e);

  /// No description provided for @responsiveSystemUpdateFailed_5421.
  ///
  /// In zh, this message translates to:
  /// **'响应式系统更新元素失败: {e}'**
  String responsiveSystemUpdateFailed_5421(Object e);

  /// No description provided for @responsiveSystemUpdateFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'响应式系统更新图例组失败: {e}'**
  String responsiveSystemUpdateFailed_7285(Object e);

  /// No description provided for @responsiveVersionInitFailed.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理初始化失败: {e}'**
  String responsiveVersionInitFailed(Object e);

  /// No description provided for @responsiveVersionManagerAdapterReleased_7421.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理适配器已释放资源'**
  String get responsiveVersionManagerAdapterReleased_7421;

  /// No description provided for @responsiveVersionManagerAddLayer.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 添加图层 {name}'**
  String responsiveVersionManagerAddLayer(Object name);

  /// No description provided for @responsiveVersionManagerAddLegendGroup_7421.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 添加图例组 {name}'**
  String responsiveVersionManagerAddLegendGroup_7421(Object name);

  /// No description provided for @responsiveVersionManagerAddNote.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 添加便签 {title}'**
  String responsiveVersionManagerAddNote(Object title);

  /// No description provided for @responsiveVersionManagerBatchUpdate.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 批量更新图层，数量: {count}'**
  String responsiveVersionManagerBatchUpdate(Object count);

  /// No description provided for @responsiveVersionManagerCreated_4821.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器已创建'**
  String get responsiveVersionManagerCreated_4821;

  /// No description provided for @responsiveVersionManagerDeleteLayer.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 删除图层 {layerId}'**
  String responsiveVersionManagerDeleteLayer(Object layerId);

  /// No description provided for @responsiveVersionManagerDeleteLegendGroup.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 删除图例组 {legendGroupId}'**
  String responsiveVersionManagerDeleteLegendGroup(Object legendGroupId);

  /// No description provided for @responsiveVersionManagerReorder.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 组内重排序图层 {oldIndex} -> {newIndex}，更新图层数量: {length}'**
  String responsiveVersionManagerReorder(
    Object length,
    Object newIndex,
    Object oldIndex,
  );

  /// No description provided for @responsiveVersionManagerSetOpacity.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 设置图层透明度 {layerId} = {opacity}'**
  String responsiveVersionManagerSetOpacity(Object layerId, Object opacity);

  /// No description provided for @responsiveVersionManagerSetVisibility.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 设置图例组可见性 {groupId} = {isVisible}'**
  String responsiveVersionManagerSetVisibility(
    Object groupId,
    Object isVisible,
  );

  /// No description provided for @responsiveVersionManagerUpdateLayer.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 更新图层 {name}'**
  String responsiveVersionManagerUpdateLayer(Object name);

  /// No description provided for @responsiveVersionManagerUpdateLegendGroup.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 更新图例组 {name}'**
  String responsiveVersionManagerUpdateLegendGroup(Object name);

  /// No description provided for @responsiveVersionManagerUpdateNote.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理器: 更新便签 {title}'**
  String responsiveVersionManagerUpdateNote(Object title);

  /// No description provided for @responsiveVersionTabDebug.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本标签栏构建: 版本数量={versionCount}, 当前版本={currentVersion}, 未保存版本={hasUnsavedVersions}'**
  String responsiveVersionTabDebug(
    Object currentVersion,
    Object hasUnsavedVersions,
    Object versionCount,
  );

  /// No description provided for @restoreDefaultShortcuts_4821.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认快捷键'**
  String get restoreDefaultShortcuts_4821;

  /// No description provided for @restoreDefaults_7421.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认'**
  String get restoreDefaults_7421;

  /// No description provided for @restoreMaximizedStateOnStartup_4281.
  ///
  /// In zh, this message translates to:
  /// **'启动时恢复窗口的最大化状态'**
  String get restoreMaximizedStateOnStartup_4281;

  /// No description provided for @restrictedChoice_7281.
  ///
  /// In zh, this message translates to:
  /// **'选择受限'**
  String get restrictedChoice_7281;

  /// No description provided for @retryButton_7281.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retryButton_7281;

  /// No description provided for @retryButton_7284.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retryButton_7284;

  /// No description provided for @retryTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'重试操作'**
  String get retryTooltip_7281;

  /// No description provided for @retry_4281.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry_4281;

  /// No description provided for @retry_4821.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry_4821;

  /// No description provided for @retry_7281.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry_7281;

  /// No description provided for @retry_7284.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry_7284;

  /// No description provided for @returnValue_4821.
  ///
  /// In zh, this message translates to:
  /// **'返回值: {result}'**
  String returnValue_4821(Object result);

  /// No description provided for @reuploadText_4821.
  ///
  /// In zh, this message translates to:
  /// **'重新上传'**
  String get reuploadText_4821;

  /// No description provided for @reuploadText_7281.
  ///
  /// In zh, this message translates to:
  /// **'重新上传'**
  String get reuploadText_7281;

  /// No description provided for @rewind10Seconds_7539.
  ///
  /// In zh, this message translates to:
  /// **'快退10秒'**
  String get rewind10Seconds_7539;

  /// No description provided for @rewindFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'快退操作失败: {error}'**
  String rewindFailed_4821(Object error);

  /// No description provided for @rgbColorDescription_7281.
  ///
  /// In zh, this message translates to:
  /// **'• RGB: FF0000 (红色)'**
  String get rgbColorDescription_7281;

  /// No description provided for @rightClickHereHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'右键点击这里试试'**
  String get rightClickHereHint_4821;

  /// No description provided for @rightClickHere_7281.
  ///
  /// In zh, this message translates to:
  /// **'右键点击这里'**
  String get rightClickHere_7281;

  /// No description provided for @rightClickOptionsWithMode_7421.
  ///
  /// In zh, this message translates to:
  /// **'右键查看选项 - {mode}'**
  String rightClickOptionsWithMode_7421(Object mode);

  /// No description provided for @rightClickOptions_4821.
  ///
  /// In zh, this message translates to:
  /// **'右键点击查看选项'**
  String get rightClickOptions_4821;

  /// No description provided for @rightClickToViewProperties_7421.
  ///
  /// In zh, this message translates to:
  /// **'右键查看属性'**
  String get rightClickToViewProperties_7421;

  /// No description provided for @rightClick_4271.
  ///
  /// In zh, this message translates to:
  /// **'右键'**
  String get rightClick_4271;

  /// No description provided for @rightDirection_4821.
  ///
  /// In zh, this message translates to:
  /// **'右'**
  String get rightDirection_4821;

  /// No description provided for @rightVerticalNavigation_4271.
  ///
  /// In zh, this message translates to:
  /// **'右侧垂直导航'**
  String get rightVerticalNavigation_4271;

  /// No description provided for @romanianRO_4857.
  ///
  /// In zh, this message translates to:
  /// **'罗马尼亚语 (罗马尼亚)'**
  String get romanianRO_4857;

  /// No description provided for @romanian_4856.
  ///
  /// In zh, this message translates to:
  /// **'罗马尼亚语'**
  String get romanian_4856;

  /// No description provided for @room_4822.
  ///
  /// In zh, this message translates to:
  /// **'房间'**
  String get room_4822;

  /// No description provided for @rootDirectoryCheck.
  ///
  /// In zh, this message translates to:
  /// **'根目录检查: 路径=\"{path}\", 包含/={containsSlash}, 应移除={shouldRemove}'**
  String rootDirectoryCheck(
    Object containsSlash,
    Object path,
    Object shouldRemove,
  );

  /// No description provided for @rootDirectoryName_4721.
  ///
  /// In zh, this message translates to:
  /// **'根目录'**
  String get rootDirectoryName_4721;

  /// No description provided for @rootDirectory_4721.
  ///
  /// In zh, this message translates to:
  /// **'根目录'**
  String get rootDirectory_4721;

  /// No description provided for @rootDirectory_4821.
  ///
  /// In zh, this message translates to:
  /// **'根目录'**
  String get rootDirectory_4821;

  /// No description provided for @rootDirectory_4905.
  ///
  /// In zh, this message translates to:
  /// **'根目录'**
  String get rootDirectory_4905;

  /// No description provided for @rootDirectory_5421.
  ///
  /// In zh, this message translates to:
  /// **'根目录'**
  String get rootDirectory_5421;

  /// No description provided for @rootDirectory_5732.
  ///
  /// In zh, this message translates to:
  /// **'根目录'**
  String get rootDirectory_5732;

  /// No description provided for @rootDirectory_5832.
  ///
  /// In zh, this message translates to:
  /// **'根目录'**
  String get rootDirectory_5832;

  /// No description provided for @rootDirectory_7281.
  ///
  /// In zh, this message translates to:
  /// **'根目录'**
  String get rootDirectory_7281;

  /// No description provided for @rootDirectory_7421.
  ///
  /// In zh, this message translates to:
  /// **'根目录'**
  String get rootDirectory_7421;

  /// No description provided for @rotate_4822.
  ///
  /// In zh, this message translates to:
  /// **'旋转'**
  String get rotate_4822;

  /// No description provided for @rotationAngle_4521.
  ///
  /// In zh, this message translates to:
  /// **'旋转角度'**
  String get rotationAngle_4521;

  /// No description provided for @rotationAngle_4721.
  ///
  /// In zh, this message translates to:
  /// **'旋转角度'**
  String get rotationAngle_4721;

  /// No description provided for @rotationLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'旋转'**
  String get rotationLabel_4821;

  /// No description provided for @rouletteGestureMenuExample_4271.
  ///
  /// In zh, this message translates to:
  /// **'轮盘手势菜单示例'**
  String get rouletteGestureMenuExample_4271;

  /// No description provided for @rouletteMenuSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'轮盘菜单设置'**
  String get rouletteMenuSettings_4821;

  /// No description provided for @rsaKeyGenerationStep1_4821.
  ///
  /// In zh, this message translates to:
  /// **'步骤1: 开始生成RSA密钥对...'**
  String get rsaKeyGenerationStep1_4821;

  /// No description provided for @rsaKeyPairGenerated_4821.
  ///
  /// In zh, this message translates to:
  /// **'步骤1: RSA密钥对生成完成'**
  String get rsaKeyPairGenerated_4821;

  /// No description provided for @rsaKeyPairGenerated_7281.
  ///
  /// In zh, this message translates to:
  /// **'RSA密钥对生成完成，开始转换公钥格式...'**
  String get rsaKeyPairGenerated_7281;

  /// No description provided for @rsaKeyPairGenerationFailed.
  ///
  /// In zh, this message translates to:
  /// **'生成 RSA 密钥对失败: {e}'**
  String rsaKeyPairGenerationFailed(Object e);

  /// No description provided for @runButton_7421.
  ///
  /// In zh, this message translates to:
  /// **'运行'**
  String get runButton_7421;

  /// No description provided for @runText_4821.
  ///
  /// In zh, this message translates to:
  /// **'运行'**
  String get runText_4821;

  /// No description provided for @runningScriptsCount.
  ///
  /// In zh, this message translates to:
  /// **'运行中的脚本 ({count})'**
  String runningScriptsCount(Object count);

  /// No description provided for @runningStatus_4821.
  ///
  /// In zh, this message translates to:
  /// **'运行中'**
  String get runningStatus_4821;

  /// No description provided for @runningStatus_5421.
  ///
  /// In zh, this message translates to:
  /// **'运行中'**
  String get runningStatus_5421;

  /// No description provided for @russianRU_4889.
  ///
  /// In zh, this message translates to:
  /// **'俄语 (俄罗斯)'**
  String get russianRU_4889;

  /// No description provided for @russian_4835.
  ///
  /// In zh, this message translates to:
  /// **'俄语'**
  String get russian_4835;

  /// No description provided for @sampleDataCleaned_7421.
  ///
  /// In zh, this message translates to:
  /// **'示例数据清理完成'**
  String get sampleDataCleaned_7421;

  /// No description provided for @sampleDataCleanupFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'示例数据清理失败: {e}'**
  String sampleDataCleanupFailed_7421(Object e);

  /// No description provided for @sampleDataCreated_7421.
  ///
  /// In zh, this message translates to:
  /// **'WebDatabaseImporter: 示例数据创建完成'**
  String get sampleDataCreated_7421;

  /// No description provided for @sampleDataInitFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'示例数据初始化失败: {e}'**
  String sampleDataInitFailed_7421(Object e);

  /// No description provided for @sampleDataInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'示例数据初始化完成'**
  String get sampleDataInitialized_7281;

  /// No description provided for @sampleLayerName_4821.
  ///
  /// In zh, this message translates to:
  /// **'示例图层'**
  String get sampleLayerName_4821;

  /// No description provided for @sampleMapTitle_7281.
  ///
  /// In zh, this message translates to:
  /// **'示例地图'**
  String get sampleMapTitle_7281;

  /// No description provided for @saturationLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'饱和度'**
  String get saturationLabel_4821;

  /// No description provided for @saturationPercentage.
  ///
  /// In zh, this message translates to:
  /// **'饱和度: {percentage}%'**
  String saturationPercentage(Object percentage);

  /// No description provided for @saturation_4827.
  ///
  /// In zh, this message translates to:
  /// **'饱和度'**
  String get saturation_4827;

  /// No description provided for @saturation_6789.
  ///
  /// In zh, this message translates to:
  /// **'饱和度'**
  String get saturation_6789;

  /// No description provided for @saveAndClose_7281.
  ///
  /// In zh, this message translates to:
  /// **'保存并关闭'**
  String get saveAndClose_7281;

  /// No description provided for @saveAndExit_4271.
  ///
  /// In zh, this message translates to:
  /// **'保存并退出'**
  String get saveAndExit_4271;

  /// No description provided for @saveAsNewConfig_7281.
  ///
  /// In zh, this message translates to:
  /// **'将当前设置保存为新配置'**
  String get saveAsNewConfig_7281;

  /// No description provided for @saveAs_7421.
  ///
  /// In zh, this message translates to:
  /// **'另存为'**
  String get saveAs_7421;

  /// No description provided for @saveAssetFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'保存资产失败: {e}'**
  String saveAssetFailed_7281(Object e);

  /// No description provided for @saveButton_5421.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get saveButton_5421;

  /// No description provided for @saveButton_7281.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get saveButton_7281;

  /// No description provided for @saveButton_7284.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get saveButton_7284;

  /// No description provided for @saveButton_7421.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get saveButton_7421;

  /// No description provided for @saveConfig.
  ///
  /// In zh, this message translates to:
  /// **'保存配置'**
  String get saveConfig;

  /// No description provided for @saveConfigFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存配置失败: {error}'**
  String saveConfigFailed(Object error);

  /// No description provided for @saveCurrentConfig_4271.
  ///
  /// In zh, this message translates to:
  /// **'保存当前配置'**
  String get saveCurrentConfig_4271;

  /// No description provided for @saveCurrentMapId_7425.
  ///
  /// In zh, this message translates to:
  /// **'保存当前地图ID'**
  String get saveCurrentMapId_7425;

  /// No description provided for @saveDrawingElementError_7281.
  ///
  /// In zh, this message translates to:
  /// **'保存绘制元素失败 [{location}]: {error}'**
  String saveDrawingElementError_7281(Object error, Object location);

  /// No description provided for @saveExportFileTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'保存导出文件'**
  String get saveExportFileTitle_4821;

  /// No description provided for @saveFailedError_7281.
  ///
  /// In zh, this message translates to:
  /// **'保存失败: {error}'**
  String saveFailedError_7281(Object error);

  /// No description provided for @saveFailedMessage.
  ///
  /// In zh, this message translates to:
  /// **'保存失败: {e}'**
  String saveFailedMessage(Object e);

  /// No description provided for @saveFileTooltip_4521.
  ///
  /// In zh, this message translates to:
  /// **'保存文件'**
  String get saveFileTooltip_4521;

  /// No description provided for @saveImageAssetToMap.
  ///
  /// In zh, this message translates to:
  /// **'保存新图像资产到地图 [{mapTitle}]: {filename} ({length} bytes)'**
  String saveImageAssetToMap(Object filename, Object length, Object mapTitle);

  /// No description provided for @saveImageTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'保存图片'**
  String get saveImageTitle_4821;

  /// No description provided for @saveLegendGroupFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存图例组失败[{mapTitle}/{groupId}:{version}]: {error}'**
  String saveLegendGroupFailed(
    Object error,
    Object groupId,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @saveLegendGroupStateFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存图例组智能隐藏状态失败: {e}'**
  String saveLegendGroupStateFailed(Object e);

  /// No description provided for @saveLegendScaleFactorFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存图例组缩放因子状态失败: {e}'**
  String saveLegendScaleFactorFailed(Object e);

  /// No description provided for @saveMap.
  ///
  /// In zh, this message translates to:
  /// **'保存地图'**
  String get saveMap;

  /// No description provided for @saveMapDataComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'=== saveMapDataReactive 完成 ==='**
  String get saveMapDataComplete_7281;

  /// No description provided for @saveMapDataStart_7281.
  ///
  /// In zh, this message translates to:
  /// **'=== saveMapDataReactive 开始 ==='**
  String get saveMapDataStart_7281;

  /// No description provided for @saveMapDataWithForceUpdate.
  ///
  /// In zh, this message translates to:
  /// **'保存地图数据，强制更新: {forceUpdate}'**
  String saveMapDataWithForceUpdate(Object forceUpdate);

  /// No description provided for @saveMapDatabaseTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'保存地图数据库'**
  String get saveMapDatabaseTitle_4821;

  /// No description provided for @saveMaximizeStatusEnabled_4821.
  ///
  /// In zh, this message translates to:
  /// **'保存最大化状态：已开启记住最大化状态设置'**
  String get saveMaximizeStatusEnabled_4821;

  /// No description provided for @savePanelStateChange_4821.
  ///
  /// In zh, this message translates to:
  /// **'保存面板状态变更'**
  String get savePanelStateChange_4821;

  /// No description provided for @savePanelStateFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'保存面板状态失败: {e}'**
  String savePanelStateFailed_7285(Object e);

  /// No description provided for @savePanelStateFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'在dispose中保存面板状态失败: {e}'**
  String savePanelStateFailed_7421(Object e);

  /// No description provided for @savePdfDialogTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'保存PDF文件'**
  String get savePdfDialogTitle_4821;

  /// No description provided for @savePermissionFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存权限失败: {e}'**
  String savePermissionFailed(Object e);

  /// No description provided for @saveScaleFactorFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'在dispose中保存缩放因子状态失败: {e}'**
  String saveScaleFactorFailed_7285(Object e);

  /// No description provided for @saveScriptTooltip_4821.
  ///
  /// In zh, this message translates to:
  /// **'保存脚本'**
  String get saveScriptTooltip_4821;

  /// No description provided for @saveSmartHideStateFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'在dispose中保存智能隐藏状态失败: {e}'**
  String saveSmartHideStateFailed_7285(Object e);

  /// No description provided for @saveStickyNoteError.
  ///
  /// In zh, this message translates to:
  /// **'保存便签数据失败 [{mapTitle}/{id}:{version}]: {error}'**
  String saveStickyNoteError(
    Object error,
    Object id,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @saveTagPreferenceFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存标签到偏好设置失败: {e}'**
  String saveTagPreferenceFailed(Object e);

  /// No description provided for @saveUserPreferenceFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存用户偏好设置失败: {e}'**
  String saveUserPreferenceFailed(Object e);

  /// No description provided for @saveVersionToVfs.
  ///
  /// In zh, this message translates to:
  /// **'保存版本数据到VFS: {title}/{versionId}'**
  String saveVersionToVfs(Object title, Object versionId);

  /// No description provided for @saveVersion_7281.
  ///
  /// In zh, this message translates to:
  /// **'保存版本: {versionId} ({versionName})'**
  String saveVersion_7281(Object versionId, Object versionName);

  /// No description provided for @saveWindowSizeFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'保存窗口大小失败: {e}'**
  String saveWindowSizeFailed_7284(Object e);

  /// No description provided for @saveWindowSizeFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'手动保存窗口大小失败: {e}'**
  String saveWindowSizeFailed_7285(Object e);

  /// No description provided for @saveWindowSizeNotMaximized_4821.
  ///
  /// In zh, this message translates to:
  /// **'保存窗口大小：当前非最大化状态'**
  String get saveWindowSizeNotMaximized_4821;

  /// No description provided for @saveZipFileTitle_4721.
  ///
  /// In zh, this message translates to:
  /// **'保存压缩文件'**
  String get saveZipFileTitle_4721;

  /// No description provided for @saveZipFileTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'保存压缩文件'**
  String get saveZipFileTitle_4821;

  /// No description provided for @save_3831.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save_3831;

  /// No description provided for @save_4824.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save_4824;

  /// No description provided for @save_73.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save_73;

  /// No description provided for @savedConfigsCount.
  ///
  /// In zh, this message translates to:
  /// **'已保存的配置 ({count})'**
  String savedConfigsCount(Object count);

  /// No description provided for @savingFile_5007.
  ///
  /// In zh, this message translates to:
  /// **'正在保存文件...'**
  String get savingFile_5007;

  /// No description provided for @savingInProgress_42.
  ///
  /// In zh, this message translates to:
  /// **'保存中...'**
  String get savingInProgress_42;

  /// No description provided for @savingMap_7281.
  ///
  /// In zh, this message translates to:
  /// **'正在保存地图...'**
  String get savingMap_7281;

  /// No description provided for @scaleLevelErrorWithDefault.
  ///
  /// In zh, this message translates to:
  /// **'获取缩放等级失败: {e}，返回默认值{defaultValue}'**
  String scaleLevelErrorWithDefault(Object defaultValue, Object e);

  /// No description provided for @scanningDirectories_5022.
  ///
  /// In zh, this message translates to:
  /// **'正在扫描目录...'**
  String get scanningDirectories_5022;

  /// No description provided for @scriptBound.
  ///
  /// In zh, this message translates to:
  /// **'已绑定脚本'**
  String get scriptBound;

  /// No description provided for @scriptCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个脚本'**
  String scriptCount(Object count);

  /// No description provided for @scriptCreatedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'响应式脚本 \"{name}\" 创建成功'**
  String scriptCreatedSuccessfully(Object name);

  /// Debug message for script engine data updater with layer count, sticky notes count and legend groups count
  ///
  /// In zh, this message translates to:
  /// **'更新脚本引擎数据访问器，图层数量: {layersCount}，便签数量: {notesCount}，图例组数量: {groupsCount}'**
  String scriptEngineDataUpdater(
    Object layersCount,
    Object notesCount,
    Object groupsCount,
  );

  /// No description provided for @scriptEngineReinitialized_4821.
  ///
  /// In zh, this message translates to:
  /// **'新脚本引擎重新初始化完成'**
  String get scriptEngineReinitialized_4821;

  /// No description provided for @scriptEngineResetDone_7281.
  ///
  /// In zh, this message translates to:
  /// **'脚本引擎重置完成'**
  String get scriptEngineResetDone_7281;

  /// No description provided for @scriptEngineResetFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'脚本引擎重置失败: {e}'**
  String scriptEngineResetFailed_7285(Object e);

  /// No description provided for @scriptEngineStatusMonitoring_7281.
  ///
  /// In zh, this message translates to:
  /// **'脚本引擎状态监控'**
  String get scriptEngineStatusMonitoring_7281;

  /// No description provided for @scriptEngine_4521.
  ///
  /// In zh, this message translates to:
  /// **'脚本引擎'**
  String get scriptEngine_4521;

  /// No description provided for @scriptError_7284.
  ///
  /// In zh, this message translates to:
  /// **'脚本错误: {error}'**
  String scriptError_7284(Object error);

  /// No description provided for @scriptExecutionError_7284.
  ///
  /// In zh, this message translates to:
  /// **'脚本执行异常: {e}'**
  String scriptExecutionError_7284(Object e);

  /// No description provided for @scriptExecutionFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'脚本执行失败: {error}'**
  String scriptExecutionFailed_7281(Object error);

  /// No description provided for @scriptExecutionLog_4821.
  ///
  /// In zh, this message translates to:
  /// **'脚本执行日志'**
  String get scriptExecutionLog_4821;

  /// No description provided for @scriptExecutionLogs_4521.
  ///
  /// In zh, this message translates to:
  /// **'执行脚本时的日志会显示在这里'**
  String get scriptExecutionLogs_4521;

  /// No description provided for @scriptExecutionResult_7421.
  ///
  /// In zh, this message translates to:
  /// **'脚本执行结果'**
  String get scriptExecutionResult_7421;

  /// No description provided for @scriptExecutionTime.
  ///
  /// In zh, this message translates to:
  /// **'脚本执行器停止耗时: {elapsedMilliseconds}ms'**
  String scriptExecutionTime(Object elapsedMilliseconds);

  /// No description provided for @scriptExecutorCleanup_7421.
  ///
  /// In zh, this message translates to:
  /// **'清理脚本执行器: {scriptId}'**
  String scriptExecutorCleanup_7421(Object scriptId);

  /// No description provided for @scriptExecutorCreation_7281.
  ///
  /// In zh, this message translates to:
  /// **'为脚本 {scriptId} 创建新的执行器和函数处理器 (当前池大小: {poolSize})'**
  String scriptExecutorCreation_7281(Object poolSize, Object scriptId);

  /// No description provided for @scriptExecutorError_7425.
  ///
  /// In zh, this message translates to:
  /// **'停止脚本执行器时发生错误: {e}'**
  String scriptExecutorError_7425(Object e);

  /// No description provided for @scriptExecutorFailure_4829.
  ///
  /// In zh, this message translates to:
  /// **'停止脚本执行器失败: {e}'**
  String scriptExecutorFailure_4829(Object e);

  /// No description provided for @scriptExecutorStopped_7281.
  ///
  /// In zh, this message translates to:
  /// **'脚本执行器停止完成'**
  String get scriptExecutorStopped_7281;

  /// No description provided for @scriptManagement_4821.
  ///
  /// In zh, this message translates to:
  /// **'脚本管理'**
  String get scriptManagement_4821;

  /// No description provided for @scriptManagerNotInitializedError_42.
  ///
  /// In zh, this message translates to:
  /// **'脚本管理器未初始化，无法执行脚本'**
  String get scriptManagerNotInitializedError_42;

  /// No description provided for @scriptName_4521.
  ///
  /// In zh, this message translates to:
  /// **'脚本名称'**
  String get scriptName_4521;

  /// No description provided for @scriptName_7421.
  ///
  /// In zh, this message translates to:
  /// **'脚本: {scriptName}'**
  String scriptName_7421(Object scriptName);

  /// No description provided for @scriptNoParamsRequired.
  ///
  /// In zh, this message translates to:
  /// **'脚本 {name} 无需参数'**
  String scriptNoParamsRequired(Object name);

  /// No description provided for @scriptNotFoundError.
  ///
  /// In zh, this message translates to:
  /// **'未找到绑定的脚本: {scriptId}'**
  String scriptNotFoundError(Object scriptId);

  /// No description provided for @scriptPanel_7890.
  ///
  /// In zh, this message translates to:
  /// **'脚本面板'**
  String get scriptPanel_7890;

  /// No description provided for @scriptParameterSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'脚本参数设置'**
  String get scriptParameterSettings_4821;

  /// No description provided for @scriptParamsUpdated_7421.
  ///
  /// In zh, this message translates to:
  /// **'已更新脚本参数: {name}'**
  String scriptParamsUpdated_7421(Object name);

  /// No description provided for @scriptSaved_4821.
  ///
  /// In zh, this message translates to:
  /// **'脚本已保存'**
  String get scriptSaved_4821;

  /// No description provided for @scriptTtsFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'停止脚本TTS失败: {e}'**
  String scriptTtsFailed_4821(Object e);

  /// No description provided for @scriptTtsFailure_4829.
  ///
  /// In zh, this message translates to:
  /// **'停止脚本TTS失败: {e}'**
  String scriptTtsFailure_4829(Object e);

  /// No description provided for @scriptType_4521.
  ///
  /// In zh, this message translates to:
  /// **'脚本类型'**
  String get scriptType_4521;

  /// No description provided for @scrollToBottom_4821.
  ///
  /// In zh, this message translates to:
  /// **'跳转到底部'**
  String get scrollToBottom_4821;

  /// No description provided for @scrollToTop_4821.
  ///
  /// In zh, this message translates to:
  /// **'跳转到顶部'**
  String get scrollToTop_4821;

  /// No description provided for @searchMapsAndFolders_4824.
  ///
  /// In zh, this message translates to:
  /// **'搜索地图和文件夹...'**
  String get searchMapsAndFolders_4824;

  /// No description provided for @searchResults_4821.
  ///
  /// In zh, this message translates to:
  /// **'搜索结果: \"{query}\"'**
  String searchResults_4821(Object query);

  /// No description provided for @search_4821.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search_4821;

  /// No description provided for @secondsCount_4821.
  ///
  /// In zh, this message translates to:
  /// **'6秒'**
  String get secondsCount_4821;

  /// No description provided for @secondsLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'秒'**
  String get secondsLabel_4821;

  /// No description provided for @seekFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'跳转失败'**
  String get seekFailed_4821;

  /// No description provided for @seekToPosition.
  ///
  /// In zh, this message translates to:
  /// **'跳转到 {seconds}秒'**
  String seekToPosition(Object seconds);

  /// No description provided for @selectAllWithCount.
  ///
  /// In zh, this message translates to:
  /// **'全选 ({count} 项)'**
  String selectAllWithCount(Object count);

  /// No description provided for @selectAndUploadZip_4973.
  ///
  /// In zh, this message translates to:
  /// **'选择并上传ZIP文件'**
  String get selectAndUploadZip_4973;

  /// No description provided for @selectAuthAccount_4821.
  ///
  /// In zh, this message translates to:
  /// **'请选择认证账户'**
  String get selectAuthAccount_4821;

  /// No description provided for @selectCenterPoint.
  ///
  /// In zh, this message translates to:
  /// **'选择中心点:'**
  String get selectCenterPoint;

  /// No description provided for @selectCollection_5033.
  ///
  /// In zh, this message translates to:
  /// **'选择集合'**
  String get selectCollection_5033;

  /// No description provided for @selectColor_4821.
  ///
  /// In zh, this message translates to:
  /// **'选择颜色'**
  String get selectColor_4821;

  /// No description provided for @selectColor_7281.
  ///
  /// In zh, this message translates to:
  /// **'选择颜色'**
  String get selectColor_7281;

  /// No description provided for @selectDatabaseAndCollectionFirst_7281.
  ///
  /// In zh, this message translates to:
  /// **'请先选择数据库和集合'**
  String get selectDatabaseAndCollectionFirst_7281;

  /// No description provided for @selectDatabaseAndCollection_7281.
  ///
  /// In zh, this message translates to:
  /// **'请选择数据库和集合'**
  String get selectDatabaseAndCollection_7281;

  /// No description provided for @selectDatabaseAndCollection_7421.
  ///
  /// In zh, this message translates to:
  /// **'请选择数据库和集合'**
  String get selectDatabaseAndCollection_7421;

  /// No description provided for @selectDatabaseFirst_4281.
  ///
  /// In zh, this message translates to:
  /// **'请先选择数据库'**
  String get selectDatabaseFirst_4281;

  /// No description provided for @selectDatabaseFirst_4821.
  ///
  /// In zh, this message translates to:
  /// **'请先选择数据库'**
  String get selectDatabaseFirst_4821;

  /// No description provided for @selectDatabaseFirst_7281.
  ///
  /// In zh, this message translates to:
  /// **'请先选择数据库和集合'**
  String get selectDatabaseFirst_7281;

  /// No description provided for @selectDatabase_5032.
  ///
  /// In zh, this message translates to:
  /// **'选择数据库'**
  String get selectDatabase_5032;

  /// No description provided for @selectExportDirectory_4821.
  ///
  /// In zh, this message translates to:
  /// **'选择导出目录'**
  String get selectExportDirectory_4821;

  /// No description provided for @selectFileOrFolderFirst_7281.
  ///
  /// In zh, this message translates to:
  /// **'请先选择要下载的文件或文件夹'**
  String get selectFileOrFolderFirst_7281;

  /// No description provided for @selectFileToViewMetadata_4821.
  ///
  /// In zh, this message translates to:
  /// **'选择文件以查看元数据'**
  String get selectFileToViewMetadata_4821;

  /// No description provided for @selectFileToViewMetadata_7281.
  ///
  /// In zh, this message translates to:
  /// **'选择文件以查看元数据'**
  String get selectFileToViewMetadata_7281;

  /// No description provided for @selectFiles_4821.
  ///
  /// In zh, this message translates to:
  /// **'选择文件'**
  String get selectFiles_4821;

  /// No description provided for @selectLanguage_4821.
  ///
  /// In zh, this message translates to:
  /// **'选择语言'**
  String get selectLanguage_4821;

  /// No description provided for @selectLayer10_3854.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 10'**
  String get selectLayer10_3854;

  /// No description provided for @selectLayer10_4831.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 10'**
  String get selectLayer10_4831;

  /// No description provided for @selectLayer11_3855.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 11'**
  String get selectLayer11_3855;

  /// No description provided for @selectLayer11_4832.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 11'**
  String get selectLayer11_4832;

  /// No description provided for @selectLayer12_3856.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 12'**
  String get selectLayer12_3856;

  /// No description provided for @selectLayer12_4833.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 12'**
  String get selectLayer12_4833;

  /// No description provided for @selectLayer1_3845.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 1'**
  String get selectLayer1_3845;

  /// No description provided for @selectLayer1_4822.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 1'**
  String get selectLayer1_4822;

  /// No description provided for @selectLayer2_3846.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 2'**
  String get selectLayer2_3846;

  /// No description provided for @selectLayer2_4823.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 2'**
  String get selectLayer2_4823;

  /// No description provided for @selectLayer3_3847.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 3'**
  String get selectLayer3_3847;

  /// No description provided for @selectLayer3_4824.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 3'**
  String get selectLayer3_4824;

  /// No description provided for @selectLayer4_3848.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 4'**
  String get selectLayer4_3848;

  /// No description provided for @selectLayer4_4825.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 4'**
  String get selectLayer4_4825;

  /// No description provided for @selectLayer5_3849.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 5'**
  String get selectLayer5_3849;

  /// No description provided for @selectLayer5_4826.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 5'**
  String get selectLayer5_4826;

  /// No description provided for @selectLayer6_3850.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 6'**
  String get selectLayer6_3850;

  /// No description provided for @selectLayer6_4827.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 6'**
  String get selectLayer6_4827;

  /// No description provided for @selectLayer7_3851.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 7'**
  String get selectLayer7_3851;

  /// No description provided for @selectLayer7_4828.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 7'**
  String get selectLayer7_4828;

  /// No description provided for @selectLayer8_3852.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 8'**
  String get selectLayer8_3852;

  /// No description provided for @selectLayer8_4829.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 8'**
  String get selectLayer8_4829;

  /// No description provided for @selectLayer9_3853.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 9'**
  String get selectLayer9_3853;

  /// No description provided for @selectLayer9_4830.
  ///
  /// In zh, this message translates to:
  /// **'选择图层 9'**
  String get selectLayer9_4830;

  /// No description provided for @selectLayerFirst_4281.
  ///
  /// In zh, this message translates to:
  /// **'请先选择一个图层'**
  String get selectLayerFirst_4281;

  /// No description provided for @selectLayerGroup1.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 1'**
  String get selectLayerGroup1;

  /// No description provided for @selectLayerGroup10.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 10'**
  String get selectLayerGroup10;

  /// No description provided for @selectLayerGroup10_3844.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 10'**
  String get selectLayerGroup10_3844;

  /// No description provided for @selectLayerGroup1_3835.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 1'**
  String get selectLayerGroup1_3835;

  /// No description provided for @selectLayerGroup2.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 2'**
  String get selectLayerGroup2;

  /// No description provided for @selectLayerGroup2_3836.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 2'**
  String get selectLayerGroup2_3836;

  /// No description provided for @selectLayerGroup3.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 3'**
  String get selectLayerGroup3;

  /// No description provided for @selectLayerGroup3_3837.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 3'**
  String get selectLayerGroup3_3837;

  /// No description provided for @selectLayerGroup4.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 4'**
  String get selectLayerGroup4;

  /// No description provided for @selectLayerGroup4_3838.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 4'**
  String get selectLayerGroup4_3838;

  /// No description provided for @selectLayerGroup5.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 5'**
  String get selectLayerGroup5;

  /// No description provided for @selectLayerGroup5_3839.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 5'**
  String get selectLayerGroup5_3839;

  /// No description provided for @selectLayerGroup6.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 6'**
  String get selectLayerGroup6;

  /// No description provided for @selectLayerGroup6_3840.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 6'**
  String get selectLayerGroup6_3840;

  /// No description provided for @selectLayerGroup7.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 7'**
  String get selectLayerGroup7;

  /// No description provided for @selectLayerGroup7_3841.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 7'**
  String get selectLayerGroup7_3841;

  /// No description provided for @selectLayerGroup8.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 8'**
  String get selectLayerGroup8;

  /// No description provided for @selectLayerGroup8_3842.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 8'**
  String get selectLayerGroup8_3842;

  /// No description provided for @selectLayerGroup9.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 9'**
  String get selectLayerGroup9;

  /// No description provided for @selectLayerGroup9_3843.
  ///
  /// In zh, this message translates to:
  /// **'选择图层组 9'**
  String get selectLayerGroup9_3843;

  /// No description provided for @selectLayersForLegendGroup_4821.
  ///
  /// In zh, this message translates to:
  /// **'选择要绑定到此图例组的图层'**
  String get selectLayersForLegendGroup_4821;

  /// No description provided for @selectLegendFileError_4821.
  ///
  /// In zh, this message translates to:
  /// **'请选择.legend文件'**
  String get selectLegendFileError_4821;

  /// No description provided for @selectLegendFileTooltip_4821.
  ///
  /// In zh, this message translates to:
  /// **'选择图例文件'**
  String get selectLegendFileTooltip_4821;

  /// No description provided for @selectLegendGroupToBind_7281.
  ///
  /// In zh, this message translates to:
  /// **'选择要绑定到此图层的图例组'**
  String get selectLegendGroupToBind_7281;

  /// No description provided for @selectNextLayerGroup_3824.
  ///
  /// In zh, this message translates to:
  /// **'选择下一个图层组'**
  String get selectNextLayerGroup_3824;

  /// No description provided for @selectNextLayer_3822.
  ///
  /// In zh, this message translates to:
  /// **'选择下一个图层'**
  String get selectNextLayer_3822;

  /// No description provided for @selectNoteColor_7281.
  ///
  /// In zh, this message translates to:
  /// **'选择便签颜色'**
  String get selectNoteColor_7281;

  /// No description provided for @selectOption_4271.
  ///
  /// In zh, this message translates to:
  /// **'选择'**
  String get selectOption_4271;

  /// No description provided for @selectParamPrompt.
  ///
  /// In zh, this message translates to:
  /// **'请选择{name}'**
  String selectParamPrompt(Object name);

  /// No description provided for @selectPathFailed_4931.
  ///
  /// In zh, this message translates to:
  /// **'选择路径失败：{error}'**
  String selectPathFailed_4931(Object error);

  /// No description provided for @selectPath_4959.
  ///
  /// In zh, this message translates to:
  /// **'选择路径'**
  String get selectPath_4959;

  /// No description provided for @selectPreviousLayerGroup_3823.
  ///
  /// In zh, this message translates to:
  /// **'选择上一个图层组'**
  String get selectPreviousLayerGroup_3823;

  /// No description provided for @selectPreviousLayer_3821.
  ///
  /// In zh, this message translates to:
  /// **'选择上一个图层'**
  String get selectPreviousLayer_3821;

  /// No description provided for @selectProcessingMethod_4821.
  ///
  /// In zh, this message translates to:
  /// **'请选择处理方式:'**
  String get selectProcessingMethod_4821;

  /// No description provided for @selectRegionBeforeCopy_7281.
  ///
  /// In zh, this message translates to:
  /// **'请先选择一个区域再复制'**
  String get selectRegionBeforeCopy_7281;

  /// No description provided for @selectScriptToBind_4271.
  ///
  /// In zh, this message translates to:
  /// **'选择要绑定的脚本'**
  String get selectScriptToBind_4271;

  /// No description provided for @selectSourceFileOrFolder_4956.
  ///
  /// In zh, this message translates to:
  /// **'选择源文件或文件夹'**
  String get selectSourceFileOrFolder_4956;

  /// No description provided for @selectTargetFolderTitle_4930.
  ///
  /// In zh, this message translates to:
  /// **'选择目标文件夹'**
  String get selectTargetFolderTitle_4930;

  /// No description provided for @selectTargetFolder_4916.
  ///
  /// In zh, this message translates to:
  /// **'选择目标文件夹'**
  String get selectTargetFolder_4916;

  /// No description provided for @selectTriangulation_4271.
  ///
  /// In zh, this message translates to:
  /// **'选择三角分割'**
  String get selectTriangulation_4271;

  /// No description provided for @selectVfsDirectoryHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'选择VFS目录来加载图例到缓存'**
  String get selectVfsDirectoryHint_4821;

  /// No description provided for @selectVfsFile.
  ///
  /// In zh, this message translates to:
  /// **'选择VFS文件'**
  String get selectVfsFile;

  /// No description provided for @selectVfsFileTooltip_4821.
  ///
  /// In zh, this message translates to:
  /// **'选择VFS文件'**
  String get selectVfsFileTooltip_4821;

  /// No description provided for @selectWebDavConfig_7281.
  ///
  /// In zh, this message translates to:
  /// **'选择WebDAV配置'**
  String get selectWebDavConfig_7281;

  /// No description provided for @selectableLayers_7281.
  ///
  /// In zh, this message translates to:
  /// **'可选择的图层'**
  String get selectableLayers_7281;

  /// No description provided for @selectedAction_7421.
  ///
  /// In zh, this message translates to:
  /// **'选择了: {action}'**
  String selectedAction_7421(Object action);

  /// No description provided for @selectedCount_7284.
  ///
  /// In zh, this message translates to:
  /// **'选中数量'**
  String get selectedCount_7284;

  /// No description provided for @selectedDirectoriesCount.
  ///
  /// In zh, this message translates to:
  /// **'已选中: {count} 个目录'**
  String selectedDirectoriesCount(Object count);

  /// No description provided for @selectedElementsUpdated.
  ///
  /// In zh, this message translates to:
  /// **'[CollaborationStateManager] 用户选择已更新: {count} 个元素'**
  String selectedElementsUpdated(Object count);

  /// No description provided for @selectedFile.
  ///
  /// In zh, this message translates to:
  /// **'选择了: {name}'**
  String selectedFile(Object name);

  /// No description provided for @selectedFile_7281.
  ///
  /// In zh, this message translates to:
  /// **'选中的文件'**
  String get selectedFile_7281;

  /// No description provided for @selectedGroup_4821.
  ///
  /// In zh, this message translates to:
  /// **'选中组'**
  String get selectedGroup_4821;

  /// No description provided for @selectedItemLabel.
  ///
  /// In zh, this message translates to:
  /// **'选择项目: {label}'**
  String selectedItemLabel(Object label);

  /// No description provided for @selectedItemsCount.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {selectedCount} / {totalCount} 项'**
  String selectedItemsCount(Object selectedCount, Object totalCount);

  /// No description provided for @selectedItems_4821.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 项'**
  String selectedItems_4821(Object count);

  /// No description provided for @selectedLayerAndGroup_7281.
  ///
  /// In zh, this message translates to:
  /// **'图层: {layerName} | 组: {groupNames}'**
  String selectedLayerAndGroup_7281(Object groupNames, Object layerName);

  /// No description provided for @selectedLayerGroup.
  ///
  /// In zh, this message translates to:
  /// **'已选中图层组 ({count} 个图层)'**
  String selectedLayerGroup(Object count);

  /// No description provided for @selectedLayerGroupMessage.
  ///
  /// In zh, this message translates to:
  /// **'图层组: {layers}'**
  String selectedLayerGroupMessage(Object layers);

  /// No description provided for @selectedLayerGroupUpdated_4821.
  ///
  /// In zh, this message translates to:
  /// **'选中图层组引用已更新'**
  String get selectedLayerGroupUpdated_4821;

  /// No description provided for @selectedLayerGroupWithCount_4821.
  ///
  /// In zh, this message translates to:
  /// **'已选中图层组 ({count} 个图层)，可同时操作图层和图层组'**
  String selectedLayerGroupWithCount_4821(Object count);

  /// No description provided for @selectedLayerGroup_4727.
  ///
  /// In zh, this message translates to:
  /// **'选中图层组 ({count} 个图层)'**
  String selectedLayerGroup_4727(Object count);

  /// No description provided for @selectedLayerLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'选中图层'**
  String get selectedLayerLabel_4821;

  /// No description provided for @selectedLayerUpdated_7421.
  ///
  /// In zh, this message translates to:
  /// **'选中图层引用已更新: {name}'**
  String selectedLayerUpdated_7421(Object name);

  /// No description provided for @selectedLayersInfo_4821.
  ///
  /// In zh, this message translates to:
  /// **'{count}层: {names}'**
  String selectedLayersInfo_4821(Object count, Object names);

  /// No description provided for @selectedLegendItem_7421.
  ///
  /// In zh, this message translates to:
  /// **'当前选中: {currentIndex}/{count}'**
  String selectedLegendItem_7421(Object count, Object currentIndex);

  /// No description provided for @selectedPathsCount_7421.
  ///
  /// In zh, this message translates to:
  /// **'当前组选中路径: {selectedCount} 个，其他组选中: {otherCount} 个'**
  String selectedPathsCount_7421(Object otherCount, Object selectedCount);

  /// No description provided for @selectedText_7421.
  ///
  /// In zh, this message translates to:
  /// **'已选中'**
  String get selectedText_7421;

  /// No description provided for @selectedWithMultiple_4827.
  ///
  /// In zh, this message translates to:
  /// **'已选中多个'**
  String get selectedWithMultiple_4827;

  /// No description provided for @selected_3632.
  ///
  /// In zh, this message translates to:
  /// **'选中'**
  String get selected_3632;

  /// No description provided for @selectingImage_4821.
  ///
  /// In zh, this message translates to:
  /// **'正在选择图片...'**
  String get selectingImage_4821;

  /// No description provided for @selectingImage_7421.
  ///
  /// In zh, this message translates to:
  /// **'📸 正在选择图片...'**
  String get selectingImage_7421;

  /// No description provided for @selectionCopiedToClipboard_4821.
  ///
  /// In zh, this message translates to:
  /// **'选区已复制到剪贴板'**
  String get selectionCopiedToClipboard_4821;

  /// No description provided for @sendDataToRemote_7428.
  ///
  /// In zh, this message translates to:
  /// **'发送数据到远程'**
  String get sendDataToRemote_7428;

  /// No description provided for @separate_7281.
  ///
  /// In zh, this message translates to:
  /// **'分离'**
  String get separate_7281;

  /// No description provided for @separatedGroupLayersOrder_7284.
  ///
  /// In zh, this message translates to:
  /// **'分离后的组内图层顺序: {layers}'**
  String separatedGroupLayersOrder_7284(Object layers);

  /// No description provided for @sepia_4823.
  ///
  /// In zh, this message translates to:
  /// **'棕褐色'**
  String get sepia_4823;

  /// No description provided for @sepia_9012.
  ///
  /// In zh, this message translates to:
  /// **'棕褐色'**
  String get sepia_9012;

  /// No description provided for @sequentialPlayback_4271.
  ///
  /// In zh, this message translates to:
  /// **'顺序播放'**
  String get sequentialPlayback_4271;

  /// No description provided for @serializedResultDebug_7281.
  ///
  /// In zh, this message translates to:
  /// **'序列化后的结果: {serializedResult}'**
  String serializedResultDebug_7281(Object serializedResult);

  /// No description provided for @serializedResultDebug_7425.
  ///
  /// In zh, this message translates to:
  /// **'序列化后的结果'**
  String get serializedResultDebug_7425;

  /// No description provided for @serverChallengeReceived_4289.
  ///
  /// In zh, this message translates to:
  /// **'serverChallengeReceived'**
  String get serverChallengeReceived_4289;

  /// No description provided for @serverErrorResponse.
  ///
  /// In zh, this message translates to:
  /// **'serverErrorResponse: {error}'**
  String serverErrorResponse(Object error);

  /// No description provided for @serverErrorWithDetails_7421.
  ///
  /// In zh, this message translates to:
  /// **'服务器返回错误状态码: {statusCode} 响应内容: {body}'**
  String serverErrorWithDetails_7421(Object body, Object statusCode);

  /// No description provided for @serverInfo.
  ///
  /// In zh, this message translates to:
  /// **'服务器:{host}:{port}'**
  String serverInfo(Object host, Object port);

  /// No description provided for @serverInfoLabel_7281.
  ///
  /// In zh, this message translates to:
  /// **'服务器: {serverInfo}'**
  String serverInfoLabel_7281(Object serverInfo);

  /// No description provided for @serverInfo_4827.
  ///
  /// In zh, this message translates to:
  /// **'服务器: {host}:{port}'**
  String serverInfo_4827(Object host, Object port);

  /// No description provided for @serverLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'服务器'**
  String get serverLabel_4821;

  /// No description provided for @serverUrlHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'https://example.com/webdav'**
  String get serverUrlHint_4821;

  /// No description provided for @serverUrlLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'服务器 URL'**
  String get serverUrlLabel_4821;

  /// No description provided for @serverUrlRequired_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入服务器 URL'**
  String get serverUrlRequired_4821;

  /// No description provided for @serviceInitialized_7421.
  ///
  /// In zh, this message translates to:
  /// **'服务已初始化'**
  String get serviceInitialized_7421;

  /// No description provided for @serviceNotInitializedError_4821.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService 未初始化，请先调用 initialize()'**
  String get serviceNotInitializedError_4821;

  /// No description provided for @serviceNotInitializedError_7281.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService 未初始化，请先调用 initialize()'**
  String get serviceNotInitializedError_7281;

  /// No description provided for @serviceNotInitializedIgnoreData_7283.
  ///
  /// In zh, this message translates to:
  /// **'服务未初始化，忽略远程数据'**
  String get serviceNotInitializedIgnoreData_7283;

  /// No description provided for @sessionManagerClearData_7281.
  ///
  /// In zh, this message translates to:
  /// **'图例会话管理器: 清除会话数据'**
  String get sessionManagerClearData_7281;

  /// No description provided for @setActiveClientFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'设置活跃客户端失败: {e}'**
  String setActiveClientFailed_7285(Object e);

  /// No description provided for @setActiveClient_7421.
  ///
  /// In zh, this message translates to:
  /// **'设置活跃客户端: {clientId}'**
  String setActiveClient_7421(Object clientId);

  /// No description provided for @setActiveConfig.
  ///
  /// In zh, this message translates to:
  /// **'设置活跃配置: {displayName} ({clientId})'**
  String setActiveConfig(Object clientId, Object displayName);

  /// No description provided for @setActiveConfigFailed.
  ///
  /// In zh, this message translates to:
  /// **'设置活跃配置失败: {e}'**
  String setActiveConfigFailed(Object e);

  /// No description provided for @setAsActive_7281.
  ///
  /// In zh, this message translates to:
  /// **'设为活跃'**
  String get setAsActive_7281;

  /// No description provided for @setAudioBalanceFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'设置音频平衡失败 - {e}'**
  String setAudioBalanceFailed_4821(Object e);

  /// No description provided for @setCurrentUser_7421.
  ///
  /// In zh, this message translates to:
  /// **'设置当前用户: {currentUserId}'**
  String setCurrentUser_7421(Object currentUserId);

  /// No description provided for @setLayerOpacity.
  ///
  /// In zh, this message translates to:
  /// **'设置图层透明度: {layerId} = {opacity}'**
  String setLayerOpacity(Object layerId, Object opacity);

  /// No description provided for @setLayerVisibility.
  ///
  /// In zh, this message translates to:
  /// **'设置图层可见性: {layerId} = {isVisible}'**
  String setLayerVisibility(Object isVisible, Object layerId);

  /// No description provided for @setLegendGroupOpacityLog_7421.
  ///
  /// In zh, this message translates to:
  /// **'设置图例组 {groupId} 透明度为: {opacity}'**
  String setLegendGroupOpacityLog_7421(Object groupId, Object opacity);

  /// No description provided for @setLegendGroupVisibility.
  ///
  /// In zh, this message translates to:
  /// **'设置图例组 {groupId} 可见性为: {isVisible}'**
  String setLegendGroupVisibility(Object groupId, Object isVisible);

  /// No description provided for @setParametersPrompt_4821.
  ///
  /// In zh, this message translates to:
  /// **'请设置以下参数：'**
  String get setParametersPrompt_4821;

  /// No description provided for @setPlaybackSpeedFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'设置播放速度失败'**
  String get setPlaybackSpeedFailed_7281;

  /// No description provided for @setPlaybackSpeedFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'设置播放速度失败: {e}'**
  String setPlaybackSpeedFailed_7285(Object e);

  /// No description provided for @setShortcutForAction.
  ///
  /// In zh, this message translates to:
  /// **'为 {action} 设置快捷键'**
  String setShortcutForAction(Object action);

  /// No description provided for @setThemeFilterForLayer.
  ///
  /// In zh, this message translates to:
  /// **'为图层 {id} 设置主题适配滤镜'**
  String setThemeFilterForLayer(Object id);

  /// No description provided for @setValidTimeError_4821.
  ///
  /// In zh, this message translates to:
  /// **'请设置有效的时间'**
  String get setValidTimeError_4821;

  /// No description provided for @setVfsAccessorWithMapTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置VFS访问器，地图标题: {mapTitle}'**
  String setVfsAccessorWithMapTitle(Object mapTitle);

  /// No description provided for @setVolumeFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'设置音量失败'**
  String get setVolumeFailed_7281;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @settingsDisplayName_4821.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsDisplayName_4821;

  /// No description provided for @settingsExported.
  ///
  /// In zh, this message translates to:
  /// **'设置导出成功'**
  String get settingsExported;

  /// No description provided for @settingsImported.
  ///
  /// In zh, this message translates to:
  /// **'设置导入成功'**
  String get settingsImported;

  /// No description provided for @settingsManagement_4821.
  ///
  /// In zh, this message translates to:
  /// **'设置管理'**
  String get settingsManagement_4821;

  /// No description provided for @settingsOperation_4251.
  ///
  /// In zh, this message translates to:
  /// **'设置操作'**
  String get settingsOperation_4251;

  /// No description provided for @settingsOption_7421.
  ///
  /// In zh, this message translates to:
  /// **'设置选项'**
  String get settingsOption_7421;

  /// No description provided for @settingsReset.
  ///
  /// In zh, this message translates to:
  /// **'设置已重置为默认值'**
  String get settingsReset;

  /// No description provided for @settingsWindow_4271.
  ///
  /// In zh, this message translates to:
  /// **'设置窗口'**
  String get settingsWindow_4271;

  /// No description provided for @settings_4821.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings_4821;

  /// No description provided for @settings_7281.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings_7281;

  /// No description provided for @shareFeatureInDevelopment_7281.
  ///
  /// In zh, this message translates to:
  /// **'分享功能开发中...'**
  String get shareFeatureInDevelopment_7281;

  /// No description provided for @shareProject.
  ///
  /// In zh, this message translates to:
  /// **'分享项目 {index}'**
  String shareProject(Object index);

  /// No description provided for @share_4821.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get share_4821;

  /// No description provided for @share_7281.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get share_7281;

  /// No description provided for @shelter_4825.
  ///
  /// In zh, this message translates to:
  /// **'掩体'**
  String get shelter_4825;

  /// No description provided for @shortcutCheckResult.
  ///
  /// In zh, this message translates to:
  /// **'快捷键检查: {shortcut}, 主键匹配: {keyMatch}, 修饰键匹配: {modifierMatch}, 最终结果: {result}'**
  String shortcutCheckResult(
    Object keyMatch,
    Object modifierMatch,
    Object result,
    Object shortcut,
  );

  /// No description provided for @shortcutConflictMessage.
  ///
  /// In zh, this message translates to:
  /// **'快捷键冲突: {shortcut} 已被 \"{conflictName}\" 使用'**
  String shortcutConflictMessage(Object conflictName, Object shortcut);

  /// No description provided for @shortcutConflict_4827.
  ///
  /// In zh, this message translates to:
  /// **'快捷键冲突: {shortcut} 已被 \"{conflictName}\" 使用'**
  String shortcutConflict_4827(Object conflictName, Object shortcut);

  /// No description provided for @shortcutEditHint_7281.
  ///
  /// In zh, this message translates to:
  /// **'点击编辑按钮可以修改对应功能的快捷键'**
  String get shortcutEditHint_7281;

  /// No description provided for @shortcutInstruction_4821.
  ///
  /// In zh, this message translates to:
  /// **'点击下方区域，然后按下您想要添加的快捷键组合'**
  String get shortcutInstruction_4821;

  /// No description provided for @shortcutList_4821.
  ///
  /// In zh, this message translates to:
  /// **'快捷键列表'**
  String get shortcutList_4821;

  /// No description provided for @shortcutManagement_4821.
  ///
  /// In zh, this message translates to:
  /// **'快捷键管理'**
  String get shortcutManagement_4821;

  /// No description provided for @shortcutSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'快捷键设置'**
  String get shortcutSettings_4821;

  /// No description provided for @shortcutVersion_4821.
  ///
  /// In zh, this message translates to:
  /// **'快捷键版本'**
  String get shortcutVersion_4821;

  /// No description provided for @shortcutsResetToDefault_4821.
  ///
  /// In zh, this message translates to:
  /// **'已恢复所有快捷键到默认设置'**
  String get shortcutsResetToDefault_4821;

  /// No description provided for @showAdvancedTools.
  ///
  /// In zh, this message translates to:
  /// **'显示高级工具'**
  String get showAdvancedTools;

  /// No description provided for @showAdvancedTools_4271.
  ///
  /// In zh, this message translates to:
  /// **'显示高级工具'**
  String get showAdvancedTools_4271;

  /// No description provided for @showAllLayersInGroup_7281.
  ///
  /// In zh, this message translates to:
  /// **'已显示组内所有图层'**
  String get showAllLayersInGroup_7281;

  /// No description provided for @showAllLayers_7281.
  ///
  /// In zh, this message translates to:
  /// **'显示所有图层'**
  String get showAllLayers_7281;

  /// No description provided for @showCloseButton_4271.
  ///
  /// In zh, this message translates to:
  /// **'显示关闭按钮: '**
  String get showCloseButton_4271;

  /// No description provided for @showCurrentLayerGroup_3863.
  ///
  /// In zh, this message translates to:
  /// **'显示当前图层组'**
  String get showCurrentLayerGroup_3863;

  /// No description provided for @showCurrentLayerGroup_4829.
  ///
  /// In zh, this message translates to:
  /// **'显示当前图层组'**
  String get showCurrentLayerGroup_4829;

  /// No description provided for @showCurrentLayer_3862.
  ///
  /// In zh, this message translates to:
  /// **'显示当前图层'**
  String get showCurrentLayer_3862;

  /// No description provided for @showCurrentLayer_4828.
  ///
  /// In zh, this message translates to:
  /// **'显示当前图层'**
  String get showCurrentLayer_4828;

  /// No description provided for @showCurrentLegendGroup_3865.
  ///
  /// In zh, this message translates to:
  /// **'显示当前图例组'**
  String get showCurrentLegendGroup_3865;

  /// No description provided for @showCurrentLegendGroup_4826.
  ///
  /// In zh, this message translates to:
  /// **'显示当前图例组'**
  String get showCurrentLegendGroup_4826;

  /// No description provided for @showMenuAtPosition.
  ///
  /// In zh, this message translates to:
  /// **'显示菜单于位置: {position}'**
  String showMenuAtPosition(Object position);

  /// No description provided for @showMultipleNotifications_4271.
  ///
  /// In zh, this message translates to:
  /// **'显示多条通知'**
  String get showMultipleNotifications_4271;

  /// No description provided for @showNotification_1234.
  ///
  /// In zh, this message translates to:
  /// **'显示通知'**
  String get showNotification_1234;

  /// No description provided for @showPersistentNotification_7281.
  ///
  /// In zh, this message translates to:
  /// **'显示常驻通知'**
  String get showPersistentNotification_7281;

  /// No description provided for @showProToolsInToolbar_4271.
  ///
  /// In zh, this message translates to:
  /// **'在工具栏中显示专业级工具'**
  String get showProToolsInToolbar_4271;

  /// No description provided for @showProperties_4281.
  ///
  /// In zh, this message translates to:
  /// **'显示属性'**
  String get showProperties_4281;

  /// No description provided for @showProperties_4821.
  ///
  /// In zh, this message translates to:
  /// **'显示属性'**
  String get showProperties_4821;

  /// No description provided for @showShortcutList_3866.
  ///
  /// In zh, this message translates to:
  /// **'显示快捷键列表'**
  String get showShortcutList_3866;

  /// No description provided for @showShortcutsList_7281.
  ///
  /// In zh, this message translates to:
  /// **'显示快捷键列表'**
  String get showShortcutsList_7281;

  /// No description provided for @showToc_7532.
  ///
  /// In zh, this message translates to:
  /// **'显示目录'**
  String get showToc_7532;

  /// No description provided for @showTooltip_4271.
  ///
  /// In zh, this message translates to:
  /// **'显示工具提示'**
  String get showTooltip_4271;

  /// No description provided for @showTooltips.
  ///
  /// In zh, this message translates to:
  /// **'显示工具提示'**
  String get showTooltips;

  /// No description provided for @show_4822.
  ///
  /// In zh, this message translates to:
  /// **'显示'**
  String get show_4822;

  /// No description provided for @sidebarWidth_4271.
  ///
  /// In zh, this message translates to:
  /// **'侧边栏宽度'**
  String get sidebarWidth_4271;

  /// No description provided for @sidebar_1235.
  ///
  /// In zh, this message translates to:
  /// **'侧边栏'**
  String get sidebar_1235;

  /// No description provided for @signatureFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'消息签名失败: {e}'**
  String signatureFailed_7285(Object e);

  /// No description provided for @signatureVerificationFailed.
  ///
  /// In zh, this message translates to:
  /// **'验证消息签名失败: {e}'**
  String signatureVerificationFailed(Object e);

  /// No description provided for @signatureVerificationFailed_4829.
  ///
  /// In zh, this message translates to:
  /// **'验证签名失败: {e}'**
  String signatureVerificationFailed_4829(Object e);

  /// No description provided for @signatureVerificationResult_7425.
  ///
  /// In zh, this message translates to:
  /// **'签名验证结果: {result}'**
  String signatureVerificationResult_7425(Object result);

  /// No description provided for @simpleRightClickMenu_7281.
  ///
  /// In zh, this message translates to:
  /// **'简单右键菜单'**
  String get simpleRightClickMenu_7281;

  /// No description provided for @simpleWindow_7421.
  ///
  /// In zh, this message translates to:
  /// **'简单窗口'**
  String get simpleWindow_7421;

  /// No description provided for @simplifiedChinese_4821.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get simplifiedChinese_4821;

  /// No description provided for @simplifiedChinese_7281.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get simplifiedChinese_7281;

  /// No description provided for @simulateCheckUserOfflineStatus_4821.
  ///
  /// In zh, this message translates to:
  /// **'模拟检查用户离线状态'**
  String get simulateCheckUserOfflineStatus_4821;

  /// No description provided for @simultaneousEditConflict_4822.
  ///
  /// In zh, this message translates to:
  /// **'同时编辑冲突'**
  String get simultaneousEditConflict_4822;

  /// No description provided for @singleCycleMode_4271.
  ///
  /// In zh, this message translates to:
  /// **'单曲循环'**
  String get singleCycleMode_4271;

  /// No description provided for @singleDiagonalLine_4826.
  ///
  /// In zh, this message translates to:
  /// **'单斜线'**
  String get singleDiagonalLine_4826;

  /// No description provided for @singleDiagonalLine_9746.
  ///
  /// In zh, this message translates to:
  /// **'单斜线'**
  String get singleDiagonalLine_9746;

  /// No description provided for @singleFileSelectionModeWarning_4827.
  ///
  /// In zh, this message translates to:
  /// **'单选模式下只能选择一个文件'**
  String get singleFileSelectionModeWarning_4827;

  /// No description provided for @singleSelectionModeWithCount.
  ///
  /// In zh, this message translates to:
  /// **'单选模式 ({count} 项)'**
  String singleSelectionModeWithCount(Object count);

  /// No description provided for @singleSelectionOnly_4821.
  ///
  /// In zh, this message translates to:
  /// **'仅单选'**
  String get singleSelectionOnly_4821;

  /// No description provided for @siriShortcuts.
  ///
  /// In zh, this message translates to:
  /// **'Siri 快捷指令'**
  String get siriShortcuts;

  /// No description provided for @sixPerPage_4824.
  ///
  /// In zh, this message translates to:
  /// **'一页六张'**
  String get sixPerPage_4824;

  /// No description provided for @sizeInBytes_7285.
  ///
  /// In zh, this message translates to:
  /// **'大小: {bytes} 字节'**
  String sizeInBytes_7285(Object bytes);

  /// No description provided for @sizeLabel_4521.
  ///
  /// In zh, this message translates to:
  /// **'大小'**
  String get sizeLabel_4521;

  /// No description provided for @sizeLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'大小'**
  String get sizeLabel_4821;

  /// No description provided for @size_4962.
  ///
  /// In zh, this message translates to:
  /// **'大小'**
  String get size_4962;

  /// No description provided for @skipDuplicateExecution_4821.
  ///
  /// In zh, this message translates to:
  /// **'清理操作已在进行中，跳过重复执行'**
  String get skipDuplicateExecution_4821;

  /// No description provided for @skipExampleDataInitialization_7281.
  ///
  /// In zh, this message translates to:
  /// **'已有地图数据，跳过示例数据初始化'**
  String get skipExampleDataInitialization_7281;

  /// No description provided for @skipFailedMigrationMap.
  ///
  /// In zh, this message translates to:
  /// **'跳过迁移失败的地图: {title}'**
  String skipFailedMigrationMap(Object title);

  /// No description provided for @skipFileKeepExisting_7281.
  ///
  /// In zh, this message translates to:
  /// **'跳过此文件，保留现有文件'**
  String get skipFileKeepExisting_7281;

  /// No description provided for @skipInvisibleLayer.
  ///
  /// In zh, this message translates to:
  /// **'跳过不可见图层: {name}'**
  String skipInvisibleLayer(Object name);

  /// No description provided for @skipMapCoverUpdate_7421.
  ///
  /// In zh, this message translates to:
  /// **'跳过更新地图封面：不在编辑器中或mapId为空'**
  String get skipMapCoverUpdate_7421;

  /// No description provided for @skipMapMessage.
  ///
  /// In zh, this message translates to:
  /// **'跳过地图: {title} (当前版本 {existingVersion} >= 导入版本 {importedVersion})'**
  String skipMapMessage(
    Object existingVersion,
    Object importedVersion,
    Object title,
  );

  /// No description provided for @skipSameIndexAdjustment_7281.
  ///
  /// In zh, this message translates to:
  /// **'调整后索引相同，跳过'**
  String get skipSameIndexAdjustment_7281;

  /// No description provided for @skipSameIndex_7281.
  ///
  /// In zh, this message translates to:
  /// **'索引相同，跳过'**
  String get skipSameIndex_7281;

  /// No description provided for @skipSameIndex_7421.
  ///
  /// In zh, this message translates to:
  /// **'索引相同，跳过'**
  String get skipSameIndex_7421;

  /// No description provided for @skipSameSourceAd_7285.
  ///
  /// In zh, this message translates to:
  /// **'🎵 插播请求与当前播放源一致，跳过插播。'**
  String get skipSameSourceAd_7285;

  /// No description provided for @skipSaveMaximizedState.
  ///
  /// In zh, this message translates to:
  /// **'跳过保存：当前处于最大化状态'**
  String get skipSaveMaximizedState;

  /// No description provided for @skipSaveMaximizedStateNotEnabled_4821.
  ///
  /// In zh, this message translates to:
  /// **'跳过保存：最大化状态但未开启记住最大化状态设置'**
  String get skipSaveMaximizedStateNotEnabled_4821;

  /// No description provided for @skipSaveMaximizedState_4821.
  ///
  /// In zh, this message translates to:
  /// **'跳过保存：当前处于最大化状态'**
  String get skipSaveMaximizedState_4821;

  /// No description provided for @skipUpdateMapTitle_7421.
  ///
  /// In zh, this message translates to:
  /// **'跳过更新地图标题：不在编辑器中或mapId为空'**
  String get skipUpdateMapTitle_7421;

  /// No description provided for @skip_4821.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get skip_4821;

  /// No description provided for @skippingInvisibleLegendGroup.
  ///
  /// In zh, this message translates to:
  /// **'跳过不可见图例组: {name}'**
  String skippingInvisibleLegendGroup(Object name);

  /// No description provided for @skippingInvisibleNote.
  ///
  /// In zh, this message translates to:
  /// **'跳过不可见便签: {title}'**
  String skippingInvisibleNote(Object title);

  /// No description provided for @skippingNonJsonFile.
  ///
  /// In zh, this message translates to:
  /// **'跳过非JSON文件: {fileName}'**
  String skippingNonJsonFile(Object fileName);

  /// No description provided for @sleepTimer_4271.
  ///
  /// In zh, this message translates to:
  /// **'睡眠定时器'**
  String get sleepTimer_4271;

  /// No description provided for @slovakSK_4863.
  ///
  /// In zh, this message translates to:
  /// **'斯洛伐克语 (斯洛伐克)'**
  String get slovakSK_4863;

  /// No description provided for @slovak_4862.
  ///
  /// In zh, this message translates to:
  /// **'斯洛伐克语'**
  String get slovak_4862;

  /// No description provided for @slovenianSI_4865.
  ///
  /// In zh, this message translates to:
  /// **'斯洛文尼亚语 (斯洛文尼亚)'**
  String get slovenianSI_4865;

  /// No description provided for @slovenian_4864.
  ///
  /// In zh, this message translates to:
  /// **'斯洛文尼亚语'**
  String get slovenian_4864;

  /// No description provided for @slow_7284.
  ///
  /// In zh, this message translates to:
  /// **'慢'**
  String get slow_7284;

  /// No description provided for @smallBrush_4821.
  ///
  /// In zh, this message translates to:
  /// **'小画笔'**
  String get smallBrush_4821;

  /// No description provided for @smallDialogTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'小型对话框'**
  String get smallDialogTitle_4821;

  /// No description provided for @smartDynamicDisplayInfo_7284.
  ///
  /// In zh, this message translates to:
  /// **'📏 智能动态显示区域信息:'**
  String get smartDynamicDisplayInfo_7284;

  /// No description provided for @smartHideStatusSaved.
  ///
  /// In zh, this message translates to:
  /// **'智能隐藏状态已保存: {enabled}'**
  String smartHideStatusSaved(Object enabled);

  /// No description provided for @smartHiding_4854.
  ///
  /// In zh, this message translates to:
  /// **'智能隐藏'**
  String get smartHiding_4854;

  /// No description provided for @snackBarDemoDescription_7281.
  ///
  /// In zh, this message translates to:
  /// **'演示如何替换原版 SnackBar 的常驻显示功能'**
  String get snackBarDemoDescription_7281;

  /// No description provided for @snackBarDemo_4271.
  ///
  /// In zh, this message translates to:
  /// **'SnackBar兼容演示'**
  String get snackBarDemo_4271;

  /// No description provided for @softwareInfoLicenseAcknowledgements_4821.
  ///
  /// In zh, this message translates to:
  /// **'软件信息、许可证和开源项目致谢'**
  String get softwareInfoLicenseAcknowledgements_4821;

  /// No description provided for @solidLine_4821.
  ///
  /// In zh, this message translates to:
  /// **'实线'**
  String get solidLine_4821;

  /// No description provided for @solidRectangleTool_1235.
  ///
  /// In zh, this message translates to:
  /// **'实心矩形'**
  String get solidRectangleTool_1235;

  /// No description provided for @solidRectangle_4824.
  ///
  /// In zh, this message translates to:
  /// **'实心矩形'**
  String get solidRectangle_4824;

  /// No description provided for @solidRectangle_7524.
  ///
  /// In zh, this message translates to:
  /// **'实心矩形'**
  String get solidRectangle_7524;

  /// No description provided for @solution_4567.
  ///
  /// In zh, this message translates to:
  /// **'解决方案'**
  String get solution_4567;

  /// No description provided for @solve_7421.
  ///
  /// In zh, this message translates to:
  /// **'解决'**
  String get solve_7421;

  /// No description provided for @songsSuffix_8153.
  ///
  /// In zh, this message translates to:
  /// **'首'**
  String get songsSuffix_8153;

  /// No description provided for @sort_4821.
  ///
  /// In zh, this message translates to:
  /// **'排序'**
  String get sort_4821;

  /// No description provided for @sourceDirectoryNotExist_7285.
  ///
  /// In zh, this message translates to:
  /// **'源目录不存在: {sourcePath}'**
  String sourceDirectoryNotExist_7285(Object sourcePath);

  /// No description provided for @sourceFile_7281.
  ///
  /// In zh, this message translates to:
  /// **'源文件'**
  String get sourceFile_7281;

  /// No description provided for @sourceFolderNotExist_7285.
  ///
  /// In zh, this message translates to:
  /// **'源文件夹不存在: {oldPath}'**
  String sourceFolderNotExist_7285(Object oldPath);

  /// No description provided for @sourceGroupEmpty_7281.
  ///
  /// In zh, this message translates to:
  /// **'源组为空'**
  String get sourceGroupEmpty_7281;

  /// No description provided for @sourceLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'源'**
  String get sourceLabel_4821;

  /// No description provided for @sourcePathNotExists_5014.
  ///
  /// In zh, this message translates to:
  /// **'源路径不存在'**
  String get sourcePathNotExists_5014;

  /// No description provided for @sourcePath_4954.
  ///
  /// In zh, this message translates to:
  /// **'源路径'**
  String get sourcePath_4954;

  /// No description provided for @sourceVersionNotFound_4821.
  ///
  /// In zh, this message translates to:
  /// **'源版本不存在: {sourceVersionId}'**
  String sourceVersionNotFound_4821(Object sourceVersionId);

  /// No description provided for @sourceVersionPathSelection_7281.
  ///
  /// In zh, this message translates to:
  /// **'源版本 {versionId} 路径选择:'**
  String sourceVersionPathSelection_7281(Object versionId);

  /// No description provided for @spacingSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'间距设置'**
  String get spacingSettings_4821;

  /// No description provided for @spanishES_4885.
  ///
  /// In zh, this message translates to:
  /// **'西班牙语 (西班牙)'**
  String get spanishES_4885;

  /// No description provided for @spanishMX_4886.
  ///
  /// In zh, this message translates to:
  /// **'西班牙语 (墨西哥)'**
  String get spanishMX_4886;

  /// No description provided for @spanish_4831.
  ///
  /// In zh, this message translates to:
  /// **'西班牙语'**
  String get spanish_4831;

  /// No description provided for @speechRateLog_7285.
  ///
  /// In zh, this message translates to:
  /// **', rate: {rate}'**
  String speechRateLog_7285(Object rate);

  /// No description provided for @speechSynthesisFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'语音合成失败: {e}'**
  String speechSynthesisFailed_7285(Object e);

  /// No description provided for @stackTraceMessage_7421.
  ///
  /// In zh, this message translates to:
  /// **'堆栈: {stackTrace}'**
  String stackTraceMessage_7421(Object stackTrace);

  /// No description provided for @stairs_4822.
  ///
  /// In zh, this message translates to:
  /// **'楼梯'**
  String get stairs_4822;

  /// No description provided for @startBatchLoadingDirectoryToCache.
  ///
  /// In zh, this message translates to:
  /// **'开始批量加载目录到缓存: {directoryPath}'**
  String startBatchLoadingDirectoryToCache(Object directoryPath);

  /// No description provided for @startCachingSvgFiles_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎨 开始缓存SVG文件...'**
  String get startCachingSvgFiles_7281;

  /// No description provided for @startCleaningExpiredData_1234.
  ///
  /// In zh, this message translates to:
  /// **'开始清理过期数据'**
  String get startCleaningExpiredData_1234;

  /// No description provided for @startCleaningTempFolder_4821.
  ///
  /// In zh, this message translates to:
  /// **'🗑️ 开始清理临时文件夹: {fullTempPath}'**
  String startCleaningTempFolder_4821(Object fullTempPath);

  /// No description provided for @startCleanupOperation_7281.
  ///
  /// In zh, this message translates to:
  /// **'开始执行应用清理操作...'**
  String get startCleanupOperation_7281;

  /// No description provided for @startCreatingClientConfigWithWebApiKey_4821.
  ///
  /// In zh, this message translates to:
  /// **'开始使用 Web API Key 创建客户端配置...'**
  String get startCreatingClientConfigWithWebApiKey_4821;

  /// No description provided for @startDeletingVersionData_7281.
  ///
  /// In zh, this message translates to:
  /// **'开始删除版本存储数据...'**
  String get startDeletingVersionData_7281;

  /// No description provided for @startEditingDefaultVersion_7281.
  ///
  /// In zh, this message translates to:
  /// **'开始编辑默认版本以确保数据同步正常工作'**
  String get startEditingDefaultVersion_7281;

  /// No description provided for @startEditingFirstVersion_7281.
  ///
  /// In zh, this message translates to:
  /// **'开始编辑第一个可用版本: {firstVersionId}'**
  String startEditingFirstVersion_7281(Object firstVersionId);

  /// No description provided for @startEditingVersion.
  ///
  /// In zh, this message translates to:
  /// **'开始编辑版本 [{mapTitle}/{versionId}]'**
  String startEditingVersion(Object mapTitle, Object versionId);

  /// No description provided for @startLoadingLegendGroup.
  ///
  /// In zh, this message translates to:
  /// **'开始加载图例组项: mapTitle={mapTitle}, groupId={groupId}, version={version}, folderPath={folderPath}'**
  String startLoadingLegendGroup(
    Object folderPath,
    Object groupId,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @startLoadingLegendItems_7421.
  ///
  /// In zh, this message translates to:
  /// **'开始加载图例项: mapTitle={mapTitle}, groupId={groupId}, itemId={itemId}, version={version}, folderPath={folderPath}'**
  String startLoadingLegendItems_7421(
    Object folderPath,
    Object groupId,
    Object itemId,
    Object mapTitle,
    Object version,
  );

  /// No description provided for @startLoadingLegendsToCache.
  ///
  /// In zh, this message translates to:
  /// **'开始从目录加载图例到缓存: {directoryPath}'**
  String startLoadingLegendsToCache(Object directoryPath);

  /// No description provided for @startLoadingVersionDataToSession.
  ///
  /// In zh, this message translates to:
  /// **'开始加载版本数据到会话: {versionId}'**
  String startLoadingVersionDataToSession(Object versionId);

  /// No description provided for @startLooping_5422.
  ///
  /// In zh, this message translates to:
  /// **'循环播放'**
  String get startLooping_5422;

  /// No description provided for @startMigrationMap_7421.
  ///
  /// In zh, this message translates to:
  /// **'开始迁移地图: {title}'**
  String startMigrationMap_7421(Object title);

  /// No description provided for @startProcessingQueue.
  ///
  /// In zh, this message translates to:
  /// **'开始处理便签 {stickyNoteId} 队列，共 {totalItems} 个项目'**
  String startProcessingQueue(Object stickyNoteId, Object totalItems);

  /// No description provided for @startSavingResponsiveVersionData.
  ///
  /// In zh, this message translates to:
  /// **'开始保存响应式版本数据 [地图: {mapTitle}]'**
  String startSavingResponsiveVersionData(Object mapTitle);

  /// No description provided for @startSwitchingVersion_7281.
  ///
  /// In zh, this message translates to:
  /// **'开始切换版本: {versionId}'**
  String startSwitchingVersion_7281(Object versionId);

  /// No description provided for @startTimerName_7281.
  ///
  /// In zh, this message translates to:
  /// **'开始 {name}'**
  String startTimerName_7281(Object name);

  /// No description provided for @startWebSocketAuthFlow.
  ///
  /// In zh, this message translates to:
  /// **'开始 WebSocket 认证流程 (使用外部流): {clientId}'**
  String startWebSocketAuthFlow(Object clientId);

  /// No description provided for @startWebSocketAuthProcess.
  ///
  /// In zh, this message translates to:
  /// **'开始 WebSocket 认证流程: {clientId}'**
  String startWebSocketAuthProcess(Object clientId);

  /// No description provided for @startWebSocketConnection_7281.
  ///
  /// In zh, this message translates to:
  /// **'开始连接 WebSocket 服务器: {clientId}'**
  String startWebSocketConnection_7281(Object clientId);

  /// No description provided for @statisticsScriptExample_9303.
  ///
  /// In zh, this message translates to:
  /// **'统计脚本示例'**
  String get statisticsScriptExample_9303;

  /// No description provided for @statistics_3456.
  ///
  /// In zh, this message translates to:
  /// **'统计'**
  String get statistics_3456;

  /// No description provided for @statistics_4821.
  ///
  /// In zh, this message translates to:
  /// **'统计'**
  String get statistics_4821;

  /// No description provided for @step2PrivateKeyStored.
  ///
  /// In zh, this message translates to:
  /// **'步骤2: 私钥存储完成，ID: {privateKeyId}'**
  String step2PrivateKeyStored(Object privateKeyId);

  /// No description provided for @step2StorePrivateKey_7281.
  ///
  /// In zh, this message translates to:
  /// **'步骤2: 开始存储私钥到安全存储...'**
  String get step2StorePrivateKey_7281;

  /// No description provided for @stepSelectionModeHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'步进型选择模式：只选择当前目录，不会递归选择子目录'**
  String get stepSelectionModeHint_4821;

  /// No description provided for @steppedCacheCleanStart.
  ///
  /// In zh, this message translates to:
  /// **'步进型缓存清理开始: 目标目录=\"{folderPath}\"'**
  String steppedCacheCleanStart(Object folderPath);

  /// No description provided for @steppedCleanupLog.
  ///
  /// In zh, this message translates to:
  /// **'步进型清理: 清理路径 {folderPath} 的缓存'**
  String steppedCleanupLog(Object folderPath);

  /// No description provided for @steppedCleanupSkip_4827.
  ///
  /// In zh, this message translates to:
  /// **'步进型清理: 路径 {folderPath} 仍被使用，跳过清理'**
  String steppedCleanupSkip_4827(Object folderPath);

  /// No description provided for @stepperCancelLog.
  ///
  /// In zh, this message translates to:
  /// **'步进型取消: 取消选中目录 {path}'**
  String stepperCancelLog(Object path);

  /// No description provided for @stepperSelection_4821.
  ///
  /// In zh, this message translates to:
  /// **'步进型选择: 选中目录 {path}'**
  String stepperSelection_4821(Object path);

  /// No description provided for @stickyNoteBackgroundLoaded.
  ///
  /// In zh, this message translates to:
  /// **'便签背景图片已从资产系统加载，哈希: {backgroundImageHash} ({length} bytes)'**
  String stickyNoteBackgroundLoaded(Object backgroundImageHash, Object length);

  /// No description provided for @stickyNoteBackgroundSaved.
  ///
  /// In zh, this message translates to:
  /// **'便签背景图片已保存到资产系统，哈希: {hash} ({length} bytes)'**
  String stickyNoteBackgroundSaved(Object hash, Object length);

  /// No description provided for @stickyNoteDeleted.
  ///
  /// In zh, this message translates to:
  /// **'便签数据已删除 [{mapTitle}/{stickyNoteId}:{version}]'**
  String stickyNoteDeleted(
    Object mapTitle,
    Object stickyNoteId,
    Object version,
  );

  /// No description provided for @stickyNoteInspectorTitle_7421.
  ///
  /// In zh, this message translates to:
  /// **'便签元素检视器 - {title}'**
  String stickyNoteInspectorTitle_7421(Object title);

  /// No description provided for @stickyNoteInspectorWithCount.
  ///
  /// In zh, this message translates to:
  /// **'便签元素检视器 ({count})'**
  String stickyNoteInspectorWithCount(Object count);

  /// No description provided for @stickyNoteLabel_4281.
  ///
  /// In zh, this message translates to:
  /// **'便签'**
  String get stickyNoteLabel_4281;

  /// No description provided for @stickyNoteLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'便签'**
  String get stickyNoteLabel_4821;

  /// No description provided for @stickyNoteLockedPreviewQueued_7281.
  ///
  /// In zh, this message translates to:
  /// **'[PreviewQueueManager] 便签 {stickyNoteId} 被锁定，预览已加入队列，当前队列长度: {queueLength}'**
  String stickyNoteLockedPreviewQueued_7281(
    Object queueLength,
    Object stickyNoteId,
  );

  /// No description provided for @stickyNoteNoElements_4821.
  ///
  /// In zh, this message translates to:
  /// **'便签没有绘制元素'**
  String get stickyNoteNoElements_4821;

  /// No description provided for @stickyNotePanel_3456.
  ///
  /// In zh, this message translates to:
  /// **'便签面板'**
  String get stickyNotePanel_3456;

  /// No description provided for @stickyNotePreviewProcessed_7421.
  ///
  /// In zh, this message translates to:
  /// **'便签预览已立即处理并添加到便签'**
  String get stickyNotePreviewProcessed_7421;

  /// No description provided for @stickyNotePreviewQueueCleared.
  ///
  /// In zh, this message translates to:
  /// **'便签{stickyNoteId}的预览队列已清空'**
  String stickyNotePreviewQueueCleared(Object stickyNoteId);

  /// No description provided for @stickyNoteSaved.
  ///
  /// In zh, this message translates to:
  /// **'便签数据已保存 [{mapTitle}/{id}:{version}]'**
  String stickyNoteSaved(Object id, Object mapTitle, Object version);

  /// No description provided for @stickyNoteTitle_7421.
  ///
  /// In zh, this message translates to:
  /// **'便签'**
  String get stickyNoteTitle_7421;

  /// No description provided for @stopEditingVersion.
  ///
  /// In zh, this message translates to:
  /// **'停止编辑版本 [{arg0}/{arg1}]'**
  String stopEditingVersion(Object arg0, Object arg1);

  /// No description provided for @stopExecution_7421.
  ///
  /// In zh, this message translates to:
  /// **'停止执行'**
  String get stopExecution_7421;

  /// No description provided for @stopFailedError.
  ///
  /// In zh, this message translates to:
  /// **'停止失败: {e}'**
  String stopFailedError(Object e);

  /// No description provided for @stopLooping_5421.
  ///
  /// In zh, this message translates to:
  /// **'关闭循环'**
  String get stopLooping_5421;

  /// No description provided for @stopScript_7285.
  ///
  /// In zh, this message translates to:
  /// **'停止脚本: {scriptId}'**
  String stopScript_7285(Object scriptId);

  /// No description provided for @stopScript_7421.
  ///
  /// In zh, this message translates to:
  /// **'停止脚本'**
  String get stopScript_7421;

  /// No description provided for @stopTimerFailed.
  ///
  /// In zh, this message translates to:
  /// **'停止计时器失败: {e}'**
  String stopTimerFailed(Object e);

  /// No description provided for @stopTimerName.
  ///
  /// In zh, this message translates to:
  /// **'停止 {name}'**
  String stopTimerName(Object name);

  /// No description provided for @stoppedScriptTtsPlayback_7421.
  ///
  /// In zh, this message translates to:
  /// **'已停止脚本 {_scriptId} 的所有TTS播放'**
  String stoppedScriptTtsPlayback_7421(Object _scriptId);

  /// No description provided for @stoppedTtsRequests.
  ///
  /// In zh, this message translates to:
  /// **'已停止来源为 {sourceId} 的 {count} 个TTS请求'**
  String stoppedTtsRequests(Object count, Object sourceId);

  /// No description provided for @stoppingAudioService_7421.
  ///
  /// In zh, this message translates to:
  /// **'正在停止音频服务...'**
  String get stoppingAudioService_7421;

  /// No description provided for @stoppingScriptExecutor_7421.
  ///
  /// In zh, this message translates to:
  /// **'正在停止脚本执行器...'**
  String get stoppingScriptExecutor_7421;

  /// No description provided for @stopwatchDescription_7532.
  ///
  /// In zh, this message translates to:
  /// **'从零开始正向计时'**
  String get stopwatchDescription_7532;

  /// No description provided for @stopwatchMode_7532.
  ///
  /// In zh, this message translates to:
  /// **'正计时'**
  String get stopwatchMode_7532;

  /// No description provided for @storageFolderLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'存储文件夹'**
  String get storageFolderLabel_4821;

  /// No description provided for @storageInfo_7281.
  ///
  /// In zh, this message translates to:
  /// **'存储信息'**
  String get storageInfo_7281;

  /// No description provided for @storagePathLengthExceeded_4821.
  ///
  /// In zh, this message translates to:
  /// **'存储路径长度不能超过100个字符'**
  String get storagePathLengthExceeded_4821;

  /// No description provided for @storagePath_7281.
  ///
  /// In zh, this message translates to:
  /// **'存储路径'**
  String get storagePath_7281;

  /// No description provided for @storageStatsError_4821.
  ///
  /// In zh, this message translates to:
  /// **'获取存储统计信息失败: {e}'**
  String storageStatsError_4821(Object e);

  /// No description provided for @storageStats_7281.
  ///
  /// In zh, this message translates to:
  /// **'存储大小: {size} KB | 键值对数量: {count}'**
  String storageStats_7281(Object count, Object size);

  /// No description provided for @storePrivateKeyFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'存储私钥失败: {e}'**
  String storePrivateKeyFailed_7285(Object e);

  /// No description provided for @streamClosed_8251.
  ///
  /// In zh, this message translates to:
  /// **'Stream 已关闭'**
  String get streamClosed_8251;

  /// No description provided for @streamError_7284.
  ///
  /// In zh, this message translates to:
  /// **'Stream 错误: {error}'**
  String streamError_7284(Object error);

  /// No description provided for @strokeWidth.
  ///
  /// In zh, this message translates to:
  /// **'笔触宽度'**
  String get strokeWidth;

  /// No description provided for @strokeWidthLabel.
  ///
  /// In zh, this message translates to:
  /// **'线宽:{width}px'**
  String strokeWidthLabel(Object width);

  /// No description provided for @strokeWidth_4821.
  ///
  /// In zh, this message translates to:
  /// **'描边宽度'**
  String get strokeWidth_4821;

  /// No description provided for @subMenuInitialHoverItem.
  ///
  /// In zh, this message translates to:
  /// **'子菜单初始悬停项目: {label}'**
  String subMenuInitialHoverItem(Object label);

  /// No description provided for @subdirectoryCheck.
  ///
  /// In zh, this message translates to:
  /// **'子目录检查: 路径=\"{path}\", 相对路径=\"{relativePath}\", 包含/={containsSlash}, 应移除={shouldRemove}'**
  String subdirectoryCheck(
    Object containsSlash,
    Object path,
    Object relativePath,
    Object shouldRemove,
  );

  /// No description provided for @submenuDelayTimer.
  ///
  /// In zh, this message translates to:
  /// **'设置子菜单延迟计时器: {label}'**
  String submenuDelayTimer(Object label);

  /// No description provided for @submenuDelay_4821.
  ///
  /// In zh, this message translates to:
  /// **'子菜单延迟'**
  String get submenuDelay_4821;

  /// No description provided for @successMessage_4821.
  ///
  /// In zh, this message translates to:
  /// **'成功消息'**
  String get successMessage_4821;

  /// No description provided for @successUploadMetadataToWebDAV_5013.
  ///
  /// In zh, this message translates to:
  /// **'成功上传metadata.json到WebDAV'**
  String get successUploadMetadataToWebDAV_5013;

  /// No description provided for @successWithLayerCount_4592.
  ///
  /// In zh, this message translates to:
  /// **'成功(图层数: {count})'**
  String successWithLayerCount_4592(Object count);

  /// No description provided for @success_4821.
  ///
  /// In zh, this message translates to:
  /// **'成功'**
  String get success_4821;

  /// No description provided for @success_7422.
  ///
  /// In zh, this message translates to:
  /// **'成功'**
  String get success_7422;

  /// No description provided for @success_8421.
  ///
  /// In zh, this message translates to:
  /// **'成功'**
  String get success_8421;

  /// No description provided for @suggestedTagsLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'建议标签：'**
  String get suggestedTagsLabel_4821;

  /// No description provided for @summary_7892.
  ///
  /// In zh, this message translates to:
  /// **'总结'**
  String get summary_7892;

  /// No description provided for @superClipboardReadError_7425.
  ///
  /// In zh, this message translates to:
  /// **'super_clipboard 读取失败: {e}，回退到平台特定实现'**
  String superClipboardReadError_7425(Object e);

  /// No description provided for @supportMultipleSelection_7281.
  ///
  /// In zh, this message translates to:
  /// **'支持多选'**
  String get supportMultipleSelection_7281;

  /// No description provided for @supportedFileTypes_4821.
  ///
  /// In zh, this message translates to:
  /// **'当前支持的文件类型:'**
  String get supportedFileTypes_4821;

  /// No description provided for @supportedFormats_7281.
  ///
  /// In zh, this message translates to:
  /// **'支持以下格式：'**
  String get supportedFormats_7281;

  /// No description provided for @supportedHtmlTags_7281.
  ///
  /// In zh, this message translates to:
  /// **'支持的HTML标签'**
  String get supportedHtmlTags_7281;

  /// No description provided for @supportedImageFormats_4821.
  ///
  /// In zh, this message translates to:
  /// **'支持 JPG、PNG、GIF 格式'**
  String get supportedImageFormats_4821;

  /// No description provided for @supportedImageFormats_5732.
  ///
  /// In zh, this message translates to:
  /// **'支持 jpg, png, gif 等格式的图片'**
  String get supportedImageFormats_5732;

  /// No description provided for @supportedImageFormats_7281.
  ///
  /// In zh, this message translates to:
  /// **'• 图片: png, jpg, jpeg, gif, bmp, webp, svg'**
  String get supportedImageFormats_7281;

  /// No description provided for @supportedModesDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'现在支持三种不同的使用模式：'**
  String get supportedModesDescription_4821;

  /// No description provided for @supportedTextFormats_7281.
  ///
  /// In zh, this message translates to:
  /// **'• 文本: txt, log, csv, json'**
  String get supportedTextFormats_7281;

  /// No description provided for @surveillance_4832.
  ///
  /// In zh, this message translates to:
  /// **'监控'**
  String get surveillance_4832;

  /// No description provided for @svgDistributionRecordCount.
  ///
  /// In zh, this message translates to:
  /// **'SVG分布记录数量: {recentSvgHistorySize}'**
  String svgDistributionRecordCount(Object recentSvgHistorySize);

  /// No description provided for @svgFileNotFound_4821.
  ///
  /// In zh, this message translates to:
  /// **'未找到 SVG 文件'**
  String get svgFileNotFound_4821;

  /// No description provided for @svgLoadError.
  ///
  /// In zh, this message translates to:
  /// **'加载 SVG 文件时出错: {e}'**
  String svgLoadError(Object e);

  /// No description provided for @svgLoadFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'加载SVG失败: {svgPath} - {e}'**
  String svgLoadFailed_4821(Object e, Object svgPath);

  /// No description provided for @svgLoadFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'无法加载 SVG 文件'**
  String get svgLoadFailed_7421;

  /// No description provided for @svgTestPageTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'SVG 测试'**
  String get svgTestPageTitle_4821;

  /// No description provided for @svgThumbnailLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'SVG图例缩略图加载失败'**
  String get svgThumbnailLoadFailed;

  /// No description provided for @svgThumbnailLoadFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'SVG图例缩略图加载失败: {e}'**
  String svgThumbnailLoadFailed_4821(Object e);

  /// No description provided for @svgThumbnailLoadFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'SVG图例缩略图加载失败: {e}'**
  String svgThumbnailLoadFailed_7285(Object e);

  /// No description provided for @swedishSE_4843.
  ///
  /// In zh, this message translates to:
  /// **'瑞典语 (瑞典)'**
  String get swedishSE_4843;

  /// No description provided for @swedish_4842.
  ///
  /// In zh, this message translates to:
  /// **'瑞典语'**
  String get swedish_4842;

  /// No description provided for @switchAndLoadVersionData.
  ///
  /// In zh, this message translates to:
  /// **'切换并加载版本数据 [{versionId}] 到响应式系统，图层数: {layersCount}, 便签数: {notesCount}'**
  String switchAndLoadVersionData(
    Object layersCount,
    Object notesCount,
    Object versionId,
  );

  /// No description provided for @switchToDarkThemeTooltip_8532.
  ///
  /// In zh, this message translates to:
  /// **'切换到深色主题'**
  String get switchToDarkThemeTooltip_8532;

  /// No description provided for @switchToLightThemeTooltip_7421.
  ///
  /// In zh, this message translates to:
  /// **'切换到浅色主题'**
  String get switchToLightThemeTooltip_7421;

  /// No description provided for @switchToNextVersion_3868.
  ///
  /// In zh, this message translates to:
  /// **'切换到下一个版本'**
  String get switchToNextVersion_3868;

  /// No description provided for @switchToPreviousVersion_3867.
  ///
  /// In zh, this message translates to:
  /// **'切换到上一个版本'**
  String get switchToPreviousVersion_3867;

  /// No description provided for @switchUserFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'切换用户失败: {error}'**
  String switchUserFailed_7421(Object error);

  /// No description provided for @switchView_4821.
  ///
  /// In zh, this message translates to:
  /// **'切换视图'**
  String get switchView_4821;

  /// No description provided for @switchedToVersion_7281.
  ///
  /// In zh, this message translates to:
  /// **'已切换到版本: {versionId}'**
  String switchedToVersion_7281(Object versionId);

  /// No description provided for @syncDataFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'同步当前数据到版本系统失败: {e}'**
  String syncDataFailed_7285(Object e);

  /// No description provided for @syncDisabled_7421.
  ///
  /// In zh, this message translates to:
  /// **'同步已禁用'**
  String get syncDisabled_7421;

  /// No description provided for @syncEnabled_7421.
  ///
  /// In zh, this message translates to:
  /// **'同步已启用'**
  String get syncEnabled_7421;

  /// No description provided for @syncExternalFunctionDebug_7421.
  ///
  /// In zh, this message translates to:
  /// **'处理同步外部函数: {functionName}，结果类型: {runtimeType}'**
  String syncExternalFunctionDebug_7421(
    Object functionName,
    Object runtimeType,
  );

  /// No description provided for @syncLegendGroupDrawerStatus_4821.
  ///
  /// In zh, this message translates to:
  /// **'同步更新图例组管理抽屉的状态'**
  String get syncLegendGroupDrawerStatus_4821;

  /// No description provided for @syncMap1_1234.
  ///
  /// In zh, this message translates to:
  /// **'同步地图1'**
  String get syncMap1_1234;

  /// No description provided for @syncMap2_7421.
  ///
  /// In zh, this message translates to:
  /// **'同步地图2'**
  String get syncMap2_7421;

  /// No description provided for @syncMapDataToVersion.
  ///
  /// In zh, this message translates to:
  /// **'同步地图数据到版本 [{versionId}], 图层数: {layersCount}, 便签数: {stickiesCount}, 图例组数: {legendsCount}'**
  String syncMapDataToVersion(
    Object layersCount,
    Object legendsCount,
    Object stickiesCount,
    Object versionId,
  );

  /// No description provided for @syncMapInfoToPresenceBloc_7421.
  ///
  /// In zh, this message translates to:
  /// **'同步地图信息到PresenceBloc'**
  String get syncMapInfoToPresenceBloc_7421;

  /// No description provided for @syncNoteDebug_7421.
  ///
  /// In zh, this message translates to:
  /// **'同步便签[{index}] {title}: {count}个绘画元素'**
  String syncNoteDebug_7421(Object count, Object index, Object title);

  /// No description provided for @syncServiceCleanedUp_7421.
  ///
  /// In zh, this message translates to:
  /// **'同步服务已清理'**
  String get syncServiceCleanedUp_7421;

  /// No description provided for @syncServiceInitFailed.
  ///
  /// In zh, this message translates to:
  /// **'初始化同步服务失败: {error}'**
  String syncServiceInitFailed(Object error);

  /// No description provided for @syncServiceInitialized.
  ///
  /// In zh, this message translates to:
  /// **'同步服务初始化完成'**
  String get syncServiceInitialized;

  /// No description provided for @syncServiceNotInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'同步服务未初始化'**
  String get syncServiceNotInitialized_7281;

  /// No description provided for @syncTreeStatusLegendGroup.
  ///
  /// In zh, this message translates to:
  /// **'同步树状态（步进型）- 当前图例组: {legendGroupId}'**
  String syncTreeStatusLegendGroup(Object legendGroupId);

  /// No description provided for @syncUnsavedStateToUI.
  ///
  /// In zh, this message translates to:
  /// **'已同步响应式系统的未保存状态到UI: {hasUnsavedChanges}'**
  String syncUnsavedStateToUI(Object hasUnsavedChanges);

  /// No description provided for @systemMetrics_4521.
  ///
  /// In zh, this message translates to:
  /// **'系统指标'**
  String get systemMetrics_4521;

  /// No description provided for @systemMode.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get systemMode;

  /// No description provided for @systemProtectedFileWarning_4821.
  ///
  /// In zh, this message translates to:
  /// **'系统保护文件 - 此文件受系统保护，不可删除或修改权限'**
  String get systemProtectedFileWarning_4821;

  /// No description provided for @systemProtectedFile_4821.
  ///
  /// In zh, this message translates to:
  /// **'系统保护文件'**
  String get systemProtectedFile_4821;

  /// No description provided for @systemTrayIntegration.
  ///
  /// In zh, this message translates to:
  /// **'系统托盘集成'**
  String get systemTrayIntegration;

  /// No description provided for @systemTraySupport.
  ///
  /// In zh, this message translates to:
  /// **'系统托盘支持'**
  String get systemTraySupport;

  /// No description provided for @tactic_4828.
  ///
  /// In zh, this message translates to:
  /// **'战术'**
  String get tactic_4828;

  /// No description provided for @tagAlreadyExists_7281.
  ///
  /// In zh, this message translates to:
  /// **'标签已存在'**
  String get tagAlreadyExists_7281;

  /// No description provided for @tagCannotBeEmpty_4821.
  ///
  /// In zh, this message translates to:
  /// **'标签不能为空'**
  String get tagCannotBeEmpty_4821;

  /// No description provided for @tagCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个标签'**
  String tagCount(Object count);

  /// No description provided for @tagCountWithMax_7281.
  ///
  /// In zh, this message translates to:
  /// **'{count} / {max} 个标签'**
  String tagCountWithMax_7281(Object count, Object max);

  /// No description provided for @tagFilterFailedJsonError_4821.
  ///
  /// In zh, this message translates to:
  /// **'标签筛选失败：JSON解析错误'**
  String get tagFilterFailedJsonError_4821;

  /// No description provided for @tagLengthExceeded_4821.
  ///
  /// In zh, this message translates to:
  /// **'标签长度不能超过20个字符'**
  String get tagLengthExceeded_4821;

  /// No description provided for @tagManagement_7281.
  ///
  /// In zh, this message translates to:
  /// **'标签管理'**
  String get tagManagement_7281;

  /// No description provided for @tagNoSpacesAllowed_7281.
  ///
  /// In zh, this message translates to:
  /// **'标签不能包含空格'**
  String get tagNoSpacesAllowed_7281;

  /// No description provided for @targetFolderExists.
  ///
  /// In zh, this message translates to:
  /// **'目标文件夹已存在: {newPath}'**
  String targetFolderExists(Object newPath);

  /// No description provided for @targetPath_4821.
  ///
  /// In zh, this message translates to:
  /// **'目标路径'**
  String get targetPath_4821;

  /// No description provided for @targetPositionAdjustedToGroupEnd.
  ///
  /// In zh, this message translates to:
  /// **'目标位置调整为组内最后位置: {adjustedNewIndex}'**
  String targetPositionAdjustedToGroupEnd(Object adjustedNewIndex);

  /// No description provided for @targetPositionInGroup_7281.
  ///
  /// In zh, this message translates to:
  /// **'目标位置在组内: {adjustedNewIndex}'**
  String targetPositionInGroup_7281(Object adjustedNewIndex);

  /// No description provided for @targetVersionExists_4821.
  ///
  /// In zh, this message translates to:
  /// **'目标版本已存在: {newVersionId}'**
  String targetVersionExists_4821(Object newVersionId);

  /// No description provided for @tempFileCleaned_7281.
  ///
  /// In zh, this message translates to:
  /// **'临时文件清理完成'**
  String get tempFileCleaned_7281;

  /// No description provided for @tempFileCleanupError_4821.
  ///
  /// In zh, this message translates to:
  /// **'清理临时文件时发生错误: {e}'**
  String tempFileCleanupError_4821(Object e);

  /// No description provided for @tempFileCleanupFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'清理临时文件失败'**
  String get tempFileCleanupFailed_4821;

  /// No description provided for @tempFileCleanupFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'清理临时文件失败'**
  String get tempFileCleanupFailed_7421;

  /// No description provided for @tempFileCleanupTime.
  ///
  /// In zh, this message translates to:
  /// **'临时文件清理耗时: {elapsedMilliseconds}ms'**
  String tempFileCleanupTime(Object elapsedMilliseconds);

  /// No description provided for @tempFileCreated_7285.
  ///
  /// In zh, this message translates to:
  /// **'成功创建临时文件'**
  String get tempFileCreated_7285;

  /// No description provided for @tempFileDeletionWarning.
  ///
  /// In zh, this message translates to:
  /// **'警告：无法删除临时文件: {e}'**
  String tempFileDeletionWarning(Object e);

  /// No description provided for @tempFileDeletionWarning_4821.
  ///
  /// In zh, this message translates to:
  /// **'警告：无法删除临时文件: {e}'**
  String tempFileDeletionWarning_4821(Object e);

  /// No description provided for @tempFileDeletionWarning_7284.
  ///
  /// In zh, this message translates to:
  /// **'警告：无法删除临时文件: {e}'**
  String tempFileDeletionWarning_7284(Object e);

  /// No description provided for @tempFileExists_4821.
  ///
  /// In zh, this message translates to:
  /// **'🔗 VfsPlatformIO: 临时文件已存在，直接返回路径'**
  String get tempFileExists_4821;

  /// No description provided for @tempFileGenerationFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'生成临时文件失败'**
  String get tempFileGenerationFailed_4821;

  /// No description provided for @tempFileGenerationFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'生成临时文件失败'**
  String get tempFileGenerationFailed_7281;

  /// No description provided for @tempFolderCleanedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'🗑️ 临时文件夹清理成功: {fullTempPath}'**
  String tempFolderCleanedSuccessfully(Object fullTempPath);

  /// No description provided for @tempFolderCleanupFailed.
  ///
  /// In zh, this message translates to:
  /// **'🗑️ 临时文件夹清理失败: {fullTempPath}'**
  String tempFolderCleanupFailed(Object fullTempPath);

  /// No description provided for @tempFolderNotExist.
  ///
  /// In zh, this message translates to:
  /// **'🗑️ 临时文件夹不存在，无需清理: {fullTempPath}'**
  String tempFolderNotExist(Object fullTempPath);

  /// No description provided for @tempQueuePlayFailed_4829.
  ///
  /// In zh, this message translates to:
  /// **'临时队列播放失败 - {e}'**
  String tempQueuePlayFailed_4829(Object e);

  /// No description provided for @temporaryQueuePlaybackFailed_4829.
  ///
  /// In zh, this message translates to:
  /// **'临时队列播放失败: {e}'**
  String temporaryQueuePlaybackFailed_4829(Object e);

  /// No description provided for @temporaryTag_3456.
  ///
  /// In zh, this message translates to:
  /// **'临时'**
  String get temporaryTag_3456;

  /// No description provided for @temporaryTag_9012.
  ///
  /// In zh, this message translates to:
  /// **'临时'**
  String get temporaryTag_9012;

  /// No description provided for @temporary_3456.
  ///
  /// In zh, this message translates to:
  /// **'临时'**
  String get temporary_3456;

  /// No description provided for @tenSeconds_4821.
  ///
  /// In zh, this message translates to:
  /// **'10秒'**
  String get tenSeconds_4821;

  /// No description provided for @testConnection_4821.
  ///
  /// In zh, this message translates to:
  /// **'测试连接'**
  String get testConnection_4821;

  /// No description provided for @testFailedMessage.
  ///
  /// In zh, this message translates to:
  /// **'测试失败: {e}'**
  String testFailedMessage(Object e);

  /// No description provided for @testMessage_4721.
  ///
  /// In zh, this message translates to:
  /// **'这是一条测试消息'**
  String get testMessage_4721;

  /// No description provided for @testResourcePackageDescription_4822.
  ///
  /// In zh, this message translates to:
  /// **'用于测试外部资源上传功能的示例资源包'**
  String get testResourcePackageDescription_4822;

  /// No description provided for @testResourcePackageName_4821.
  ///
  /// In zh, this message translates to:
  /// **'测试资源包'**
  String get testResourcePackageName_4821;

  /// No description provided for @testTag_4824.
  ///
  /// In zh, this message translates to:
  /// **'测试'**
  String get testTag_4824;

  /// No description provided for @testUser_4823.
  ///
  /// In zh, this message translates to:
  /// **'测试用户'**
  String get testUser_4823;

  /// No description provided for @testVoice_7281.
  ///
  /// In zh, this message translates to:
  /// **'测试语音'**
  String get testVoice_7281;

  /// No description provided for @testingInProgress_4821.
  ///
  /// In zh, this message translates to:
  /// **'测试中...'**
  String get testingInProgress_4821;

  /// No description provided for @textBox_3180.
  ///
  /// In zh, this message translates to:
  /// **'文本框'**
  String get textBox_3180;

  /// No description provided for @textContentLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'文本内容'**
  String get textContentLabel_4821;

  /// No description provided for @textContent_4521.
  ///
  /// In zh, this message translates to:
  /// **'文本内容'**
  String get textContent_4521;

  /// No description provided for @textContent_4821.
  ///
  /// In zh, this message translates to:
  /// **'文本内容'**
  String get textContent_4821;

  /// No description provided for @textLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'文本'**
  String get textLabel_4821;

  /// No description provided for @textModeCopyFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'文本模式复制也失败了: {e}'**
  String textModeCopyFailed_4821(Object e);

  /// No description provided for @textNoteLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'文本便签'**
  String get textNoteLabel_4821;

  /// No description provided for @textTool_9034.
  ///
  /// In zh, this message translates to:
  /// **'文本'**
  String get textTool_9034;

  /// No description provided for @textType_1234.
  ///
  /// In zh, this message translates to:
  /// **'文本'**
  String get textType_1234;

  /// No description provided for @text_4830.
  ///
  /// In zh, this message translates to:
  /// **'文本'**
  String get text_4830;

  /// No description provided for @text_4831.
  ///
  /// In zh, this message translates to:
  /// **'文本'**
  String get text_4831;

  /// No description provided for @thaiTH_4891.
  ///
  /// In zh, this message translates to:
  /// **'泰语 (泰国)'**
  String get thaiTH_4891;

  /// No description provided for @thai_4837.
  ///
  /// In zh, this message translates to:
  /// **'泰语'**
  String get thai_4837;

  /// No description provided for @theme.
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get theme;

  /// No description provided for @themeUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新主题设置失败: {error}'**
  String themeUpdateFailed(Object error);

  /// No description provided for @throttleErrorImmediate.
  ///
  /// In zh, this message translates to:
  /// **'节流立即执行出错 [{key}]: {e}'**
  String throttleErrorImmediate(Object e, Object key);

  /// No description provided for @throttleError_7425.
  ///
  /// In zh, this message translates to:
  /// **'节流执行出错 [{arg0}]: {arg1}'**
  String throttleError_7425(Object arg0, Object arg1);

  /// No description provided for @throttleLayerUpdate_7281.
  ///
  /// In zh, this message translates to:
  /// **'=== 节流执行图层更新 ==='**
  String get throttleLayerUpdate_7281;

  /// No description provided for @throttleManagerReleased.
  ///
  /// In zh, this message translates to:
  /// **'ThrottleManager已释放，清理了{count}个定时器'**
  String throttleManagerReleased(Object count);

  /// No description provided for @timeSettings_7284.
  ///
  /// In zh, this message translates to:
  /// **'时间设置'**
  String get timeSettings_7284;

  /// No description provided for @timerCannotPauseCurrentState_7281.
  ///
  /// In zh, this message translates to:
  /// **'计时器当前状态无法暂停'**
  String get timerCannotPauseCurrentState_7281;

  /// No description provided for @timerCannotStartInCurrentState_4287.
  ///
  /// In zh, this message translates to:
  /// **'计时器当前状态无法启动'**
  String get timerCannotStartInCurrentState_4287;

  /// No description provided for @timerCannotStopCurrentState_4821.
  ///
  /// In zh, this message translates to:
  /// **'计时器当前状态无法停止'**
  String get timerCannotStopCurrentState_4821;

  /// No description provided for @timerCompleted_4824.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get timerCompleted_4824;

  /// No description provided for @timerCompleted_7281.
  ///
  /// In zh, this message translates to:
  /// **'计时器已完成: {timerId}'**
  String timerCompleted_7281(Object timerId);

  /// No description provided for @timerCreated.
  ///
  /// In zh, this message translates to:
  /// **'计时器已创建: {id}'**
  String timerCreated(Object id);

  /// No description provided for @timerCreationFailed.
  ///
  /// In zh, this message translates to:
  /// **'创建计时器失败: {e}'**
  String timerCreationFailed(Object e);

  /// No description provided for @timerDeleted.
  ///
  /// In zh, this message translates to:
  /// **'计时器已删除: {timerId}'**
  String timerDeleted(Object timerId);

  /// No description provided for @timerIdExistsError_4821.
  ///
  /// In zh, this message translates to:
  /// **'计时器ID已存在'**
  String get timerIdExistsError_4821;

  /// No description provided for @timerInDevelopment_7421.
  ///
  /// In zh, this message translates to:
  /// **'定时器功能正在开发中...'**
  String get timerInDevelopment_7421;

  /// No description provided for @timerManagement_4271.
  ///
  /// In zh, this message translates to:
  /// **'计时器管理'**
  String get timerManagement_4271;

  /// No description provided for @timerManagerCleaned_7281.
  ///
  /// In zh, this message translates to:
  /// **'计时器管理器已清理'**
  String get timerManagerCleaned_7281;

  /// No description provided for @timerNameHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入计时器名称'**
  String get timerNameHint_4821;

  /// No description provided for @timerNameLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'计时器名称'**
  String get timerNameLabel_4821;

  /// No description provided for @timerNotExist_7281.
  ///
  /// In zh, this message translates to:
  /// **'计时器不存在'**
  String get timerNotExist_7281;

  /// No description provided for @timerNotExist_7283.
  ///
  /// In zh, this message translates to:
  /// **'计时器不存在'**
  String get timerNotExist_7283;

  /// No description provided for @timerNotExist_7284.
  ///
  /// In zh, this message translates to:
  /// **'计时器不存在'**
  String get timerNotExist_7284;

  /// No description provided for @timerPauseFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'暂停计时器失败: {e}'**
  String timerPauseFailed_7285(Object e);

  /// No description provided for @timerPaused_4823.
  ///
  /// In zh, this message translates to:
  /// **'已暂停'**
  String get timerPaused_4823;

  /// No description provided for @timerPaused_7285.
  ///
  /// In zh, this message translates to:
  /// **'计时器已暂停: {timerId}'**
  String timerPaused_7285(Object timerId);

  /// No description provided for @timerRunning_4822.
  ///
  /// In zh, this message translates to:
  /// **'运行中'**
  String get timerRunning_4822;

  /// No description provided for @timerStartFailed.
  ///
  /// In zh, this message translates to:
  /// **'启动计时器失败: {e}'**
  String timerStartFailed(Object e);

  /// No description provided for @timerStartFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'启动计时器失败: {e}'**
  String timerStartFailed_7285(Object e);

  /// No description provided for @timerStarted_7281.
  ///
  /// In zh, this message translates to:
  /// **'计时器已启动: {timerId}'**
  String timerStarted_7281(Object timerId);

  /// No description provided for @timerStopFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'停止计时器失败: {e}'**
  String timerStopFailed_4821(Object e);

  /// No description provided for @timerStopped_4821.
  ///
  /// In zh, this message translates to:
  /// **'已停止'**
  String get timerStopped_4821;

  /// No description provided for @timerStopped_7285.
  ///
  /// In zh, this message translates to:
  /// **'计时器已停止'**
  String get timerStopped_7285;

  /// No description provided for @timerTypeLabel_7281.
  ///
  /// In zh, this message translates to:
  /// **'计时器类型'**
  String get timerTypeLabel_7281;

  /// No description provided for @timerUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新计时器失败: {e}'**
  String timerUpdateFailed(Object e);

  /// No description provided for @timerUpdateFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'计时器时间更新失败: {e}'**
  String timerUpdateFailed_7284(Object e);

  /// No description provided for @titleFontSizeMultiplierText.
  ///
  /// In zh, this message translates to:
  /// **'标题字体大小倍数: {value}%'**
  String titleFontSizeMultiplierText(Object value);

  /// No description provided for @titleHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'输入主页标题文字'**
  String get titleHint_4821;

  /// No description provided for @titleLabel_4521.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get titleLabel_4521;

  /// No description provided for @titleLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'标题文字'**
  String get titleLabel_4821;

  /// No description provided for @titleSetting_1234.
  ///
  /// In zh, this message translates to:
  /// **'标题设置'**
  String get titleSetting_1234;

  /// No description provided for @title_5421.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get title_5421;

  /// No description provided for @todo_5678.
  ///
  /// In zh, this message translates to:
  /// **'待办'**
  String get todo_5678;

  /// No description provided for @toggleDebugMode_4721.
  ///
  /// In zh, this message translates to:
  /// **'切换调试模式'**
  String get toggleDebugMode_4721;

  /// No description provided for @toggleLeftSidebar_3857.
  ///
  /// In zh, this message translates to:
  /// **'切换左侧边栏'**
  String get toggleLeftSidebar_3857;

  /// No description provided for @toggleLegendGroupDrawer_4824.
  ///
  /// In zh, this message translates to:
  /// **'切换图例组抽屉'**
  String get toggleLegendGroupDrawer_4824;

  /// No description provided for @toggleLegendManagementDrawer_3859.
  ///
  /// In zh, this message translates to:
  /// **'切换图例管理抽屉'**
  String get toggleLegendManagementDrawer_3859;

  /// No description provided for @toggleMuteFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'切换静音失败: {error}'**
  String toggleMuteFailed_7284(Object error);

  /// No description provided for @toggleSidebar_4822.
  ///
  /// In zh, this message translates to:
  /// **'切换侧边栏'**
  String get toggleSidebar_4822;

  /// No description provided for @tokenValidationFailedTimestampMissing_4821.
  ///
  /// In zh, this message translates to:
  /// **'令牌验证失败: 时间戳缺失'**
  String get tokenValidationFailedTimestampMissing_4821;

  /// No description provided for @tokenValidationFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'令牌验证失败: 令牌已过期'**
  String get tokenValidationFailed_7281;

  /// No description provided for @tokenValidationSuccess.
  ///
  /// In zh, this message translates to:
  /// **'令牌验证成功: {clientId}'**
  String tokenValidationSuccess(Object clientId);

  /// No description provided for @tokenVerificationFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'令牌验证失败: {e}'**
  String tokenVerificationFailed_7421(Object e);

  /// No description provided for @toneTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'音调'**
  String get toneTitle_4821;

  /// No description provided for @toolLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'工具'**
  String get toolLabel_4821;

  /// No description provided for @toolPropertiesTitle_7421.
  ///
  /// In zh, this message translates to:
  /// **'{toolName} 属性'**
  String toolPropertiesTitle_7421(Object toolName);

  /// No description provided for @toolSettingsReset_4821.
  ///
  /// In zh, this message translates to:
  /// **'工具设置已重置'**
  String get toolSettingsReset_4821;

  /// No description provided for @toolSettingsUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新工具设置失败: {error}'**
  String toolSettingsUpdateFailed(Object error);

  /// No description provided for @toolSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'工具设置'**
  String get toolSettings_4821;

  /// No description provided for @tool_6413.
  ///
  /// In zh, this message translates to:
  /// **'工具'**
  String get tool_6413;

  /// No description provided for @toolbarLayout_4521.
  ///
  /// In zh, this message translates to:
  /// **'工具栏布局'**
  String get toolbarLayout_4521;

  /// No description provided for @toolbarPositionSaved.
  ///
  /// In zh, this message translates to:
  /// **'工具栏 {toolbarId} 位置已保存: ({x}, {y})'**
  String toolbarPositionSaved(Object toolbarId, Object x, Object y);

  /// No description provided for @toolbarPositionSet.
  ///
  /// In zh, this message translates to:
  /// **'扩展设置: 工具栏 {toolbarId} 位置已设置为 ({x}, {y})'**
  String toolbarPositionSet(Object toolbarId, Object x, Object y);

  /// No description provided for @toolbar_0123.
  ///
  /// In zh, this message translates to:
  /// **'工具栏'**
  String get toolbar_0123;

  /// No description provided for @toolsTitle_7281.
  ///
  /// In zh, this message translates to:
  /// **'工具'**
  String get toolsTitle_7281;

  /// No description provided for @topCenter_5678.
  ///
  /// In zh, this message translates to:
  /// **'上中'**
  String get topCenter_5678;

  /// No description provided for @topLeftCut_4822.
  ///
  /// In zh, this message translates to:
  /// **'左上切割'**
  String get topLeftCut_4822;

  /// No description provided for @topLeftTriangle_4821.
  ///
  /// In zh, this message translates to:
  /// **'左上三角'**
  String get topLeftTriangle_4821;

  /// No description provided for @topLeft_1234.
  ///
  /// In zh, this message translates to:
  /// **'左上'**
  String get topLeft_1234;

  /// No description provided for @topLeft_5723.
  ///
  /// In zh, this message translates to:
  /// **'左上'**
  String get topLeft_5723;

  /// No description provided for @topRightCut_4823.
  ///
  /// In zh, this message translates to:
  /// **'右上切割'**
  String get topRightCut_4823;

  /// No description provided for @topRightTriangle_4821.
  ///
  /// In zh, this message translates to:
  /// **'右上三角'**
  String get topRightTriangle_4821;

  /// No description provided for @topRight_6934.
  ///
  /// In zh, this message translates to:
  /// **'右上'**
  String get topRight_6934;

  /// No description provided for @topRight_9012.
  ///
  /// In zh, this message translates to:
  /// **'右上'**
  String get topRight_9012;

  /// No description provided for @totalAccountsCount.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 个账户'**
  String totalAccountsCount(Object count);

  /// No description provided for @totalConfigsCount.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 个配置'**
  String totalConfigsCount(Object count);

  /// No description provided for @totalCountLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'总数'**
  String get totalCountLabel_4821;

  /// No description provided for @totalCount_7281.
  ///
  /// In zh, this message translates to:
  /// **'总数量'**
  String get totalCount_7281;

  /// No description provided for @totalCount_7421.
  ///
  /// In zh, this message translates to:
  /// **'总数量'**
  String get totalCount_7421;

  /// No description provided for @totalFilesCount_7284.
  ///
  /// In zh, this message translates to:
  /// **'文件总数'**
  String get totalFilesCount_7284;

  /// No description provided for @totalFiles_4821.
  ///
  /// In zh, this message translates to:
  /// **'文件总数'**
  String get totalFiles_4821;

  /// No description provided for @totalImageCount.
  ///
  /// In zh, this message translates to:
  /// **'总图片数量: {count}'**
  String totalImageCount(Object count);

  /// No description provided for @totalItemsCount_1345.
  ///
  /// In zh, this message translates to:
  /// **'总项目数量'**
  String get totalItemsCount_1345;

  /// No description provided for @totalLayers_5678.
  ///
  /// In zh, this message translates to:
  /// **'共有'**
  String get totalLayers_5678;

  /// No description provided for @totalLogsCount_7421.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 条'**
  String totalLogsCount_7421(Object count);

  /// No description provided for @totalScriptsLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'总脚本'**
  String get totalScriptsLabel_4821;

  /// No description provided for @totalSize_4821.
  ///
  /// In zh, this message translates to:
  /// **'总大小'**
  String get totalSize_4821;

  /// No description provided for @total_5363.
  ///
  /// In zh, this message translates to:
  /// **'总计'**
  String get total_5363;

  /// No description provided for @total_7284.
  ///
  /// In zh, this message translates to:
  /// **'总计'**
  String get total_7284;

  /// No description provided for @touchBarSupport.
  ///
  /// In zh, this message translates to:
  /// **'Touch Bar 支持'**
  String get touchBarSupport;

  /// No description provided for @transformInfo.
  ///
  /// In zh, this message translates to:
  /// **'变换信息: 缩放({scaleX}, {scaleY}), 平移({translateX}, {translateY})'**
  String transformInfo(
    Object scaleX,
    Object scaleY,
    Object translateX,
    Object translateY,
  );

  /// No description provided for @transparencyLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'透明度'**
  String get transparencyLabel_4821;

  /// No description provided for @transparentLayer_7285.
  ///
  /// In zh, this message translates to:
  /// **'透明图层'**
  String get transparentLayer_7285;

  /// No description provided for @trap_4830.
  ///
  /// In zh, this message translates to:
  /// **'陷阱'**
  String get trap_4830;

  /// No description provided for @trap_4831.
  ///
  /// In zh, this message translates to:
  /// **'陷阱'**
  String get trap_4831;

  /// No description provided for @triangleDivision_4821.
  ///
  /// In zh, this message translates to:
  /// **'三角分割'**
  String get triangleDivision_4821;

  /// No description provided for @triangleHeightInfo.
  ///
  /// In zh, this message translates to:
  /// **'   - 三角形高度: {value}px (行间距)'**
  String triangleHeightInfo(Object value);

  /// No description provided for @triggerButton_7421.
  ///
  /// In zh, this message translates to:
  /// **'触发按键'**
  String get triggerButton_7421;

  /// No description provided for @tryDifferentKeywords_4829.
  ///
  /// In zh, this message translates to:
  /// **'尝试使用不同的关键词搜索'**
  String get tryDifferentKeywords_4829;

  /// No description provided for @tryRightClickMenu_4821.
  ///
  /// In zh, this message translates to:
  /// **'试试看右键菜单功能'**
  String get tryRightClickMenu_4821;

  /// No description provided for @ttsDisabledSkipPlayRequest_4821.
  ///
  /// In zh, this message translates to:
  /// **'TTS已禁用，跳过播放请求'**
  String get ttsDisabledSkipPlayRequest_4821;

  /// No description provided for @ttsEmptySkipPlay_4821.
  ///
  /// In zh, this message translates to:
  /// **'TTS文本为空，跳过播放'**
  String get ttsEmptySkipPlay_4821;

  /// No description provided for @ttsError_7285.
  ///
  /// In zh, this message translates to:
  /// **'TTS错误: {msg}'**
  String ttsError_7285(Object msg);

  /// No description provided for @ttsInitializationComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'TTS服务初始化完成'**
  String get ttsInitializationComplete_7281;

  /// No description provided for @ttsInitializationFailed.
  ///
  /// In zh, this message translates to:
  /// **'TTS服务初始化失败: {e}'**
  String ttsInitializationFailed(Object e);

  /// No description provided for @ttsInitializationSuccess_7281.
  ///
  /// In zh, this message translates to:
  /// **'TTS 服务初始化成功'**
  String get ttsInitializationSuccess_7281;

  /// No description provided for @ttsLanguageListError_4821.
  ///
  /// In zh, this message translates to:
  /// **'获取TTS语言列表失败: {e}'**
  String ttsLanguageListError_4821(Object e);

  /// No description provided for @ttsLanguageListObtained.
  ///
  /// In zh, this message translates to:
  /// **'获取TTS语言列表: {count} 种语言'**
  String ttsLanguageListObtained(Object count);

  /// No description provided for @ttsListFetchFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取TTS语音列表失败: {e}'**
  String ttsListFetchFailed(Object e);

  /// No description provided for @ttsListFetchFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'获取TTS语音列表失败: {e}'**
  String ttsListFetchFailed_7285(Object e);

  /// No description provided for @ttsLoadFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'加载TTS选项失败: {e}'**
  String ttsLoadFailed_7285(Object e);

  /// No description provided for @ttsNotInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'TTS未初始化，无法播放'**
  String get ttsNotInitialized_7281;

  /// No description provided for @ttsPlaybackCancelled_7421.
  ///
  /// In zh, this message translates to:
  /// **'TTS播放取消'**
  String get ttsPlaybackCancelled_7421;

  /// No description provided for @ttsPlaybackComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'TTS播放完成'**
  String get ttsPlaybackComplete_7281;

  /// No description provided for @ttsPlaybackStart.
  ///
  /// In zh, this message translates to:
  /// **'TTS开始播放文本: {text} (来源: {sourceId})'**
  String ttsPlaybackStart(Object sourceId, Object text);

  /// No description provided for @ttsRequestFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'处理TTS请求失败: {e}'**
  String ttsRequestFailed_7421(Object e);

  /// No description provided for @ttsRequestQueued.
  ///
  /// In zh, this message translates to:
  /// **'TTS请求已加入队列: \"{text}\" (来源: {source}, 队列长度: {length})'**
  String ttsRequestQueued(Object length, Object source, Object text);

  /// No description provided for @ttsServiceFailed.
  ///
  /// In zh, this message translates to:
  /// **'停止TTS服务失败: {e}'**
  String ttsServiceFailed(Object e);

  /// No description provided for @ttsSettingsReset_4821.
  ///
  /// In zh, this message translates to:
  /// **'TTS设置已重置'**
  String get ttsSettingsReset_4821;

  /// No description provided for @ttsSettingsTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'TTS 语音合成设置'**
  String get ttsSettingsTitle_4821;

  /// No description provided for @ttsSpeedRangeLog.
  ///
  /// In zh, this message translates to:
  /// **'获取TTS语音速度范围: {range}'**
  String ttsSpeedRangeLog(Object range);

  /// No description provided for @ttsStartPlaying_7281.
  ///
  /// In zh, this message translates to:
  /// **'TTS开始播放'**
  String get ttsStartPlaying_7281;

  /// No description provided for @ttsStoppedQueueCleared_4821.
  ///
  /// In zh, this message translates to:
  /// **'TTS已停止，队列已清空'**
  String get ttsStoppedQueueCleared_4821;

  /// No description provided for @ttsTestFailed.
  ///
  /// In zh, this message translates to:
  /// **'TTS 测试失败: {error}'**
  String ttsTestFailed(Object error);

  /// No description provided for @ttsTestStartedPlaying.
  ///
  /// In zh, this message translates to:
  /// **'TTS 测试已开始播放 ({languageName})'**
  String ttsTestStartedPlaying(Object languageName);

  /// No description provided for @ttsTestText_4821.
  ///
  /// In zh, this message translates to:
  /// **'这是一个语音合成测试，当前设置已应用。'**
  String get ttsTestText_4821;

  /// No description provided for @ttsVoiceListCount.
  ///
  /// In zh, this message translates to:
  /// **'获取TTS语音列表: {count} 种语音'**
  String ttsVoiceListCount(Object count);

  /// No description provided for @turkishTR_4873.
  ///
  /// In zh, this message translates to:
  /// **'土耳其语 (土耳其)'**
  String get turkishTR_4873;

  /// No description provided for @turkish_4872.
  ///
  /// In zh, this message translates to:
  /// **'土耳其语'**
  String get turkish_4872;

  /// No description provided for @twoPerPage_4822.
  ///
  /// In zh, this message translates to:
  /// **'一页两张'**
  String get twoPerPage_4822;

  /// No description provided for @twoSeconds_4271.
  ///
  /// In zh, this message translates to:
  /// **'2秒'**
  String get twoSeconds_4271;

  /// No description provided for @typeLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get typeLabel_4821;

  /// No description provided for @typeLabel_5421.
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get typeLabel_5421;

  /// No description provided for @type_4964.
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get type_4964;

  /// No description provided for @type_5161.
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get type_5161;

  /// No description provided for @uiControl_4821.
  ///
  /// In zh, this message translates to:
  /// **'界面控制'**
  String get uiControl_4821;

  /// No description provided for @uiStateSyncedWithUnsavedChanges.
  ///
  /// In zh, this message translates to:
  /// **'UI状态已同步响应式数据，未保存更改: {_hasUnsavedChanges}'**
  String uiStateSyncedWithUnsavedChanges(Object _hasUnsavedChanges);

  /// No description provided for @unableToOpenLink_7285.
  ///
  /// In zh, this message translates to:
  /// **'无法打开链接: {url}'**
  String unableToOpenLink_7285(Object url);

  /// No description provided for @unableToOpenUrl.
  ///
  /// In zh, this message translates to:
  /// **'无法打开链接: {url}'**
  String unableToOpenUrl(Object url);

  /// No description provided for @undoAction_7421.
  ///
  /// In zh, this message translates to:
  /// **'撤销'**
  String get undoAction_7421;

  /// No description provided for @undoHistoryCount_4821.
  ///
  /// In zh, this message translates to:
  /// **'撤销历史记录数量'**
  String get undoHistoryCount_4821;

  /// No description provided for @undoOperation_7281.
  ///
  /// In zh, this message translates to:
  /// **'执行撤销操作'**
  String get undoOperation_7281;

  /// No description provided for @undoStepsLabel.
  ///
  /// In zh, this message translates to:
  /// **'{count} 步'**
  String undoStepsLabel(Object count);

  /// No description provided for @undo_3829.
  ///
  /// In zh, this message translates to:
  /// **'撤销'**
  String get undo_3829;

  /// No description provided for @undo_4822.
  ///
  /// In zh, this message translates to:
  /// **'撤销'**
  String get undo_4822;

  /// No description provided for @unexpectedContentTypeWithResponse.
  ///
  /// In zh, this message translates to:
  /// **'意外的内容类型: {contentType} 响应内容: {responseBody}'**
  String unexpectedContentTypeWithResponse(
    Object contentType,
    Object responseBody,
  );

  /// No description provided for @ungroupAction_4821.
  ///
  /// In zh, this message translates to:
  /// **'取消分组'**
  String get ungroupAction_4821;

  /// No description provided for @unknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknown;

  /// No description provided for @unknownAccount_4821.
  ///
  /// In zh, this message translates to:
  /// **'未知账户'**
  String get unknownAccount_4821;

  /// No description provided for @unknownClient_7281.
  ///
  /// In zh, this message translates to:
  /// **'未知客户端'**
  String get unknownClient_7281;

  /// No description provided for @unknownClient_7284.
  ///
  /// In zh, this message translates to:
  /// **'未知客户端'**
  String get unknownClient_7284;

  /// No description provided for @unknownError.
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get unknownError;

  /// No description provided for @unknownError_7421.
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get unknownError_7421;

  /// No description provided for @unknownLabel_4721.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknownLabel_4721;

  /// No description provided for @unknownLegend_4821.
  ///
  /// In zh, this message translates to:
  /// **'未知图例'**
  String get unknownLegend_4821;

  /// No description provided for @unknownLegend_7632.
  ///
  /// In zh, this message translates to:
  /// **'未知图例'**
  String get unknownLegend_7632;

  /// No description provided for @unknownMap_4821.
  ///
  /// In zh, this message translates to:
  /// **'未知地图'**
  String get unknownMap_4821;

  /// No description provided for @unknownReason_7421.
  ///
  /// In zh, this message translates to:
  /// **'未知原因'**
  String get unknownReason_7421;

  /// No description provided for @unknownRemoteDataType_4721.
  ///
  /// In zh, this message translates to:
  /// **'未知的远程数据类型: {type}'**
  String unknownRemoteDataType_4721(Object type);

  /// No description provided for @unknownSource_3632.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknownSource_3632;

  /// No description provided for @unknownTask_7421.
  ///
  /// In zh, this message translates to:
  /// **'未知任务'**
  String get unknownTask_7421;

  /// No description provided for @unknownTime_4821.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknownTime_4821;

  /// No description provided for @unknownToolLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'未知工具'**
  String get unknownToolLabel_4821;

  /// No description provided for @unknownTool_4833.
  ///
  /// In zh, this message translates to:
  /// **'未知工具'**
  String get unknownTool_4833;

  /// No description provided for @unknownTooltip_4821.
  ///
  /// In zh, this message translates to:
  /// **'未知工具'**
  String get unknownTooltip_4821;

  /// No description provided for @unknownVoice_4821.
  ///
  /// In zh, this message translates to:
  /// **'未知语音'**
  String get unknownVoice_4821;

  /// No description provided for @unknown_4822.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknown_4822;

  /// No description provided for @unknown_9367.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknown_9367;

  /// No description provided for @unlockElement_4271.
  ///
  /// In zh, this message translates to:
  /// **'解锁元素'**
  String get unlockElement_4271;

  /// No description provided for @unmute_4721.
  ///
  /// In zh, this message translates to:
  /// **'取消静音'**
  String get unmute_4721;

  /// No description provided for @unmute_4821.
  ///
  /// In zh, this message translates to:
  /// **'取消静音'**
  String get unmute_4821;

  /// No description provided for @unmute_5421.
  ///
  /// In zh, this message translates to:
  /// **'取消静音'**
  String get unmute_5421;

  /// No description provided for @unnamedLayer_4821.
  ///
  /// In zh, this message translates to:
  /// **'未命名图层'**
  String get unnamedLayer_4821;

  /// No description provided for @unnamedLegendGroup_4821.
  ///
  /// In zh, this message translates to:
  /// **'未命名图例组'**
  String get unnamedLegendGroup_4821;

  /// No description provided for @unsavedChangesPrompt_7421.
  ///
  /// In zh, this message translates to:
  /// **'是否有未保存更改'**
  String get unsavedChangesPrompt_7421;

  /// No description provided for @unsavedChangesWarning_4821.
  ///
  /// In zh, this message translates to:
  /// **'您有未保存的更改，确定要关闭吗？'**
  String get unsavedChangesWarning_4821;

  /// No description provided for @unsavedChangesWarning_7284.
  ///
  /// In zh, this message translates to:
  /// **'您有未保存的更改，确定要退出吗？'**
  String get unsavedChangesWarning_7284;

  /// No description provided for @unsavedChanges_4271.
  ///
  /// In zh, this message translates to:
  /// **'未保存的更改'**
  String get unsavedChanges_4271;

  /// No description provided for @unsavedChanges_4821.
  ///
  /// In zh, this message translates to:
  /// **'未保存的更改'**
  String get unsavedChanges_4821;

  /// No description provided for @unsavedText_7421.
  ///
  /// In zh, this message translates to:
  /// **'未保存'**
  String get unsavedText_7421;

  /// No description provided for @unselected_3633.
  ///
  /// In zh, this message translates to:
  /// **'取消选中'**
  String get unselected_3633;

  /// No description provided for @unsupportedFileType.
  ///
  /// In zh, this message translates to:
  /// **'不支持的文件类型: .{extension}'**
  String unsupportedFileType(Object extension);

  /// No description provided for @unsupportedFileType_4271.
  ///
  /// In zh, this message translates to:
  /// **'不支持的文件类型'**
  String get unsupportedFileType_4271;

  /// No description provided for @unsupportedImageFormatError_4821.
  ///
  /// In zh, this message translates to:
  /// **'不支持的图片格式，请选择 JPG、PNG、GIF 或 WebP 格式的图片'**
  String get unsupportedImageFormatError_4821;

  /// No description provided for @unsupportedKey_7425.
  ///
  /// In zh, this message translates to:
  /// **'不支持的按键: {key}'**
  String unsupportedKey_7425(Object key);

  /// No description provided for @unsupportedOrCorruptedImage_7281.
  ///
  /// In zh, this message translates to:
  /// **'图片格式不支持或已损坏'**
  String get unsupportedOrCorruptedImage_7281;

  /// No description provided for @unsupportedProperty_7285.
  ///
  /// In zh, this message translates to:
  /// **'不支持的属性: {property}'**
  String unsupportedProperty_7285(Object property);

  /// No description provided for @unsupportedUrlFormat.
  ///
  /// In zh, this message translates to:
  /// **'不支持的链接格式: {url}'**
  String unsupportedUrlFormat(Object url);

  /// No description provided for @untitledNote_4721.
  ///
  /// In zh, this message translates to:
  /// **'无标题便签'**
  String get untitledNote_4721;

  /// No description provided for @untitledNote_4821.
  ///
  /// In zh, this message translates to:
  /// **'无标题便签'**
  String get untitledNote_4821;

  /// No description provided for @untitledNote_7281.
  ///
  /// In zh, this message translates to:
  /// **'无标题便签'**
  String get untitledNote_7281;

  /// No description provided for @upText_4821.
  ///
  /// In zh, this message translates to:
  /// **'上'**
  String get upText_4821;

  /// No description provided for @updateClientConfigFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'更新客户端配置失败: {e}'**
  String updateClientConfigFailed_7421(Object e);

  /// No description provided for @updateCompleteMessage_4821.
  ///
  /// In zh, this message translates to:
  /// **'🎉 更新完成！这就是updateNotification的威力'**
  String get updateCompleteMessage_4821;

  /// No description provided for @updateConfigFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'更新配置失败: {error}'**
  String updateConfigFailed_7421(Object error);

  /// No description provided for @updateCoverFailed_4850.
  ///
  /// In zh, this message translates to:
  /// **'更新封面失败'**
  String get updateCoverFailed_4850;

  /// No description provided for @updateCover_4853.
  ///
  /// In zh, this message translates to:
  /// **'更换封面'**
  String get updateCover_4853;

  /// No description provided for @updateCustomTagFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新自定义标签失败: {error}'**
  String updateCustomTagFailed(Object error);

  /// No description provided for @updateDisplayOrderLog.
  ///
  /// In zh, this message translates to:
  /// **'_updateDisplayOrderAfterLayerChange() 完成，_displayOrderLayers: {layers}'**
  String updateDisplayOrderLog(Object layers);

  /// No description provided for @updateDisplayOrderLog_7281.
  ///
  /// In zh, this message translates to:
  /// **'调用 _updateDisplayOrderAfterLayerChange()'**
  String get updateDisplayOrderLog_7281;

  /// No description provided for @updateDrawingElement_7281.
  ///
  /// In zh, this message translates to:
  /// **'更新绘制元素: {layerId}/{elementId}'**
  String updateDrawingElement_7281(Object elementId, Object layerId);

  /// No description provided for @updateElementFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新元素失败: {e}'**
  String updateElementFailed(Object e);

  /// No description provided for @updateElementSizeLog.
  ///
  /// In zh, this message translates to:
  /// **'更新元素 {elementId} 的文本大小为: {newSize}'**
  String updateElementSizeLog(Object elementId, Object newSize);

  /// No description provided for @updateElementTextLog.
  ///
  /// In zh, this message translates to:
  /// **'更新元素 {elementId} 的文本内容为: \"{newText}\"'**
  String updateElementTextLog(Object elementId, Object newText);

  /// No description provided for @updateExtensionSettingsFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新扩展设置失败: {error}'**
  String updateExtensionSettingsFailed(Object error);

  /// No description provided for @updateExternalResources_4970.
  ///
  /// In zh, this message translates to:
  /// **'更新外部资源'**
  String get updateExternalResources_4970;

  /// No description provided for @updateFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'更新失败: {error}'**
  String updateFailedWithError(Object error);

  /// No description provided for @updateFailed_4925.
  ///
  /// In zh, this message translates to:
  /// **'更新失败：{error}'**
  String updateFailed_4925(Object error);

  /// No description provided for @updateFailed_4988.
  ///
  /// In zh, this message translates to:
  /// **'更新失败'**
  String get updateFailed_4988;

  /// No description provided for @updateHomeSettingsFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新主页设置失败: {error}'**
  String updateHomeSettingsFailed(Object error);

  /// No description provided for @updateLayerDebug.
  ///
  /// In zh, this message translates to:
  /// **'更新图层: {name}, ID: {id}'**
  String updateLayerDebug(Object id, Object name);

  /// No description provided for @updateLayerElementProperty_7421.
  ///
  /// In zh, this message translates to:
  /// **'更新图层 {layerId} 中元素 {elementId} 的属性 {property}'**
  String updateLayerElementProperty_7421(
    Object elementId,
    Object layerId,
    Object property,
  );

  /// No description provided for @updateLayerElementWithReactiveSystem.
  ///
  /// In zh, this message translates to:
  /// **'使用响应式系统更新图层绘制元素: {layerId}/{elementId}'**
  String updateLayerElementWithReactiveSystem(Object layerId, Object elementId);

  /// No description provided for @updateLayerLog.
  ///
  /// In zh, this message translates to:
  /// **'执行更新图层: {name}, isLinkedToNext: {isLinkedToNext}'**
  String updateLayerLog(Object isLinkedToNext, Object name);

  /// No description provided for @updateLayerReactiveCall_7281.
  ///
  /// In zh, this message translates to:
  /// **'=== updateLayerReactive 调用 ==='**
  String get updateLayerReactiveCall_7281;

  /// No description provided for @updateLayerReactiveComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'=== updateLayerReactive 完成 ==='**
  String get updateLayerReactiveComplete_7281;

  /// No description provided for @updateLayoutFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新界面布局设置失败: {error}'**
  String updateLayoutFailed(Object error);

  /// No description provided for @updateLegendDataFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'更新图例数据失败: {e}'**
  String updateLegendDataFailed_7284(Object e);

  /// No description provided for @updateLegendFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新图例失败: {error}'**
  String updateLegendFailed(Object error);

  /// No description provided for @updateLegendGroupFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新图例组失败: {error}'**
  String updateLegendGroupFailed(Object error);

  /// No description provided for @updateLegendGroupLog.
  ///
  /// In zh, this message translates to:
  /// **'更新图例组 {groupId}'**
  String updateLegendGroupLog(Object groupId);

  /// No description provided for @updateLegendGroupWithReactiveSystem.
  ///
  /// In zh, this message translates to:
  /// **'使用响应式系统更新图例组: {name}'**
  String updateLegendGroupWithReactiveSystem(Object name);

  /// No description provided for @updateLegendGroup_7421.
  ///
  /// In zh, this message translates to:
  /// **'集成适配器: 更新图例组 {name}'**
  String updateLegendGroup_7421(Object name);

  /// No description provided for @updateLegendItem_7425.
  ///
  /// In zh, this message translates to:
  /// **'更新图例项 {itemId}'**
  String updateLegendItem_7425(Object itemId);

  /// No description provided for @updateMapTitleFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新地图标题失败: {e}'**
  String updateMapTitleFailed(Object e);

  /// No description provided for @updateMetadata_4829.
  ///
  /// In zh, this message translates to:
  /// **'更新元数据: {metadata}'**
  String updateMetadata_4829(Object metadata);

  /// No description provided for @updateNoteDebug.
  ///
  /// In zh, this message translates to:
  /// **'更新便利贴: {id}'**
  String updateNoteDebug(Object id);

  /// No description provided for @updateNoteElementProperty.
  ///
  /// In zh, this message translates to:
  /// **'更新便签 {noteId} 中元素 {elementId} 的属性 {property}'**
  String updateNoteElementProperty(
    Object elementId,
    Object noteId,
    Object property,
  );

  /// No description provided for @updateNoteFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新便签失败: {e}'**
  String updateNoteFailed(Object e);

  /// No description provided for @updateNoteFailed_7284.
  ///
  /// In zh, this message translates to:
  /// **'更新便签失败: {e}'**
  String updateNoteFailed_7284(Object e);

  /// No description provided for @updateRecentColorsFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新最近使用颜色失败: {e}'**
  String updateRecentColorsFailed(Object e);

  /// No description provided for @updateShortcutFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'更新地图编辑器快捷键失败: {error}'**
  String updateShortcutFailed_7421(Object error);

  /// No description provided for @updateStickyNoteElement.
  ///
  /// In zh, this message translates to:
  /// **'使用响应式系统更新便签绘制元素: {noteId}/{elementId}'**
  String updateStickyNoteElement(Object elementId, Object noteId);

  /// No description provided for @updateTimeChanged_4821.
  ///
  /// In zh, this message translates to:
  /// **'更新时间变化'**
  String get updateTimeChanged_4821;

  /// No description provided for @updateTitle_4271.
  ///
  /// In zh, this message translates to:
  /// **'更新标题'**
  String get updateTitle_4271;

  /// No description provided for @updateUserInfoFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'更新用户信息失败: {error}'**
  String updateUserInfoFailed_7421(Object error);

  /// No description provided for @updateVersionMetadata_7421.
  ///
  /// In zh, this message translates to:
  /// **'更新版本元数据 [{mapTitle}/{versionId}]'**
  String updateVersionMetadata_7421(Object mapTitle, Object versionId);

  /// No description provided for @updateVersionName.
  ///
  /// In zh, this message translates to:
  /// **'更新版本名称 [{arg0}/{arg1}]: {arg2}'**
  String updateVersionName(Object arg0, Object arg1, Object arg2);

  /// No description provided for @updateVersionSessionData_4821.
  ///
  /// In zh, this message translates to:
  /// **'更新版本会话数据 [{mapTitle}/{versionId}], 标记为{isModified}, 图层数: {layerCount}'**
  String updateVersionSessionData_4821(
    Object isModified,
    Object layerCount,
    Object mapTitle,
    Object versionId,
  );

  /// No description provided for @updatedLayerLabels_7281.
  ///
  /// In zh, this message translates to:
  /// **'已更新图层标签：{labels}'**
  String updatedLayerLabels_7281(Object labels);

  /// No description provided for @updatedLegendCount.
  ///
  /// In zh, this message translates to:
  /// **'更新后图例数量: {length}'**
  String updatedLegendCount(Object length);

  /// No description provided for @updatedLegendItemsCount.
  ///
  /// In zh, this message translates to:
  /// **'更新的图例项数量: {count}'**
  String updatedLegendItemsCount(Object count);

  /// No description provided for @updatingCachedLegendsList.
  ///
  /// In zh, this message translates to:
  /// **'[CachedLegendsDisplay] 开始更新缓存图例列表，当前图例组ID: {currentLegendGroupId}'**
  String updatingCachedLegendsList(Object currentLegendGroupId);

  /// No description provided for @uploadBackgroundImage_5421.
  ///
  /// In zh, this message translates to:
  /// **'上传背景图片'**
  String get uploadBackgroundImage_5421;

  /// No description provided for @uploadButton_7284.
  ///
  /// In zh, this message translates to:
  /// **'上传'**
  String get uploadButton_7284;

  /// No description provided for @uploadDescription_4971.
  ///
  /// In zh, this message translates to:
  /// **'上传包含外部资源的ZIP文件，系统将自动解压并根据元数据文件将资源复制到指定位置。'**
  String get uploadDescription_4971;

  /// No description provided for @uploadFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'上传失败: {error}'**
  String uploadFailedWithError(Object error);

  /// No description provided for @uploadFiles_4821.
  ///
  /// In zh, this message translates to:
  /// **'上传文件'**
  String get uploadFiles_4821;

  /// No description provided for @uploadFiles_4971.
  ///
  /// In zh, this message translates to:
  /// **'上传文件'**
  String get uploadFiles_4971;

  /// No description provided for @uploadFolderFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'上传文件夹失败: {error}'**
  String uploadFolderFailed_4821(Object error);

  /// No description provided for @uploadFolderSuccess_4821.
  ///
  /// In zh, this message translates to:
  /// **'成功上传文件夹 \"{folderName}\" 包含 {count} 个文件'**
  String uploadFolderSuccess_4821(Object count, Object folderName);

  /// No description provided for @uploadFolder_4821.
  ///
  /// In zh, this message translates to:
  /// **'上传文件夹'**
  String get uploadFolder_4821;

  /// No description provided for @uploadFolder_4972.
  ///
  /// In zh, this message translates to:
  /// **'上传文件夹'**
  String get uploadFolder_4972;

  /// No description provided for @uploadImageToBuffer_4521.
  ///
  /// In zh, this message translates to:
  /// **'点击上传图片到缓冲区'**
  String get uploadImageToBuffer_4521;

  /// No description provided for @uploadImageToBuffer_5421.
  ///
  /// In zh, this message translates to:
  /// **'点击上传图片到缓冲区'**
  String get uploadImageToBuffer_5421;

  /// No description provided for @uploadImage_5739.
  ///
  /// In zh, this message translates to:
  /// **'上传图片'**
  String get uploadImage_5739;

  /// No description provided for @uploadImage_7421.
  ///
  /// In zh, this message translates to:
  /// **'上传图片'**
  String get uploadImage_7421;

  /// No description provided for @uploadLocalImage_4271.
  ///
  /// In zh, this message translates to:
  /// **'上传本地图片'**
  String get uploadLocalImage_4271;

  /// No description provided for @uploadLocalizationFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'上传本地化文件失败: {error}'**
  String uploadLocalizationFailed_7421(Object error);

  /// No description provided for @uploadToWebDAV_4969.
  ///
  /// In zh, this message translates to:
  /// **'上传到WebDAV'**
  String get uploadToWebDAV_4969;

  /// No description provided for @upload_4821.
  ///
  /// In zh, this message translates to:
  /// **'上传'**
  String get upload_4821;

  /// No description provided for @uploadingToWebDAV_5008.
  ///
  /// In zh, this message translates to:
  /// **'正在上传到WebDAV...'**
  String get uploadingToWebDAV_5008;

  /// No description provided for @uploading_4968.
  ///
  /// In zh, this message translates to:
  /// **'上传中...'**
  String get uploading_4968;

  /// No description provided for @urgentTag_5678.
  ///
  /// In zh, this message translates to:
  /// **'紧急'**
  String get urgentTag_5678;

  /// No description provided for @urlOpenFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'打开链接失败: {e}'**
  String urlOpenFailed_7285(Object e);

  /// No description provided for @urlRouting.
  ///
  /// In zh, this message translates to:
  /// **'URL路由'**
  String get urlRouting;

  /// No description provided for @usageHint_4521.
  ///
  /// In zh, this message translates to:
  /// **'使用提示：'**
  String get usageHint_4521;

  /// No description provided for @usageInstructions_4521.
  ///
  /// In zh, this message translates to:
  /// **'使用说明'**
  String get usageInstructions_4521;

  /// No description provided for @usageInstructions_4821.
  ///
  /// In zh, this message translates to:
  /// **'使用说明'**
  String get usageInstructions_4821;

  /// No description provided for @usageInstructions_4976.
  ///
  /// In zh, this message translates to:
  /// **'使用说明'**
  String get usageInstructions_4976;

  /// No description provided for @usageRequirementsHint_4940.
  ///
  /// In zh, this message translates to:
  /// **'如：不允许私自转发、仅供学习使用、需注明出处等'**
  String get usageRequirementsHint_4940;

  /// No description provided for @usageRequirements_4939.
  ///
  /// In zh, this message translates to:
  /// **'使用要求'**
  String get usageRequirements_4939;

  /// No description provided for @useGetAllUsersAsyncMethod.
  ///
  /// In zh, this message translates to:
  /// **'请使用 getAllUsersAsync() 方法'**
  String get useGetAllUsersAsyncMethod;

  /// No description provided for @useLegacyReorderMethod_4821.
  ///
  /// In zh, this message translates to:
  /// **'使用传统重排序方式'**
  String get useLegacyReorderMethod_4821;

  /// No description provided for @useLoadedLegendData_7281.
  ///
  /// In zh, this message translates to:
  /// **'  - 使用已加载的图例数据'**
  String get useLoadedLegendData_7281;

  /// No description provided for @useNetworkImageUrl_4821.
  ///
  /// In zh, this message translates to:
  /// **'使用网络图片URL'**
  String get useNetworkImageUrl_4821;

  /// No description provided for @useReactiveSystemUndo_7281.
  ///
  /// In zh, this message translates to:
  /// **'使用响应式系统撤销'**
  String get useReactiveSystemUndo_7281;

  /// No description provided for @useSystemColorTheme_4821.
  ///
  /// In zh, this message translates to:
  /// **'使用系统颜色主题'**
  String get useSystemColorTheme_4821;

  /// No description provided for @useToolbarToCreateFolder_4821.
  ///
  /// In zh, this message translates to:
  /// **'使用工具栏按钮创建文件夹'**
  String get useToolbarToCreateFolder_4821;

  /// No description provided for @userCanceledSaveOperation_9274.
  ///
  /// In zh, this message translates to:
  /// **'用户取消了保存操作'**
  String get userCanceledSaveOperation_9274;

  /// No description provided for @userConfigDeleted.
  ///
  /// In zh, this message translates to:
  /// **'用户配置已删除: {userId}'**
  String userConfigDeleted(Object userId);

  /// No description provided for @userCreationFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'创建用户失败: {error}'**
  String userCreationFailed_7421(Object error);

  /// No description provided for @userFieldAdded.
  ///
  /// In zh, this message translates to:
  /// **'已为用户 {userId} 添加 windowControlsMode 字段'**
  String userFieldAdded(Object userId);

  /// No description provided for @userFile_4521.
  ///
  /// In zh, this message translates to:
  /// **'用户文件'**
  String get userFile_4521;

  /// No description provided for @userFile_4821.
  ///
  /// In zh, this message translates to:
  /// **'用户文件'**
  String get userFile_4821;

  /// No description provided for @userInfoSetSkipped_7281.
  ///
  /// In zh, this message translates to:
  /// **'用户信息已设置，跳过重复设置'**
  String get userInfoSetSkipped_7281;

  /// No description provided for @userInfoUpdated_7421.
  ///
  /// In zh, this message translates to:
  /// **'用户信息已更新'**
  String get userInfoUpdated_7421;

  /// No description provided for @userJoined_7425.
  ///
  /// In zh, this message translates to:
  /// **'用户{displayName} ({userId})'**
  String userJoined_7425(Object displayName, Object userId);

  /// No description provided for @userLeft_7421.
  ///
  /// In zh, this message translates to:
  /// **'用户{userId}离开'**
  String userLeft_7421(Object userId);

  /// No description provided for @userManagement_4521.
  ///
  /// In zh, this message translates to:
  /// **'用户管理'**
  String get userManagement_4521;

  /// No description provided for @userName_7284.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get userName_7284;

  /// No description provided for @userOfflinePreviewAddedToLayer.
  ///
  /// In zh, this message translates to:
  /// **'用户离线，预览已直接处理并添加到图层 {targetLayerId}'**
  String userOfflinePreviewAddedToLayer(Object targetLayerId);

  /// No description provided for @userPermissionsTitle_7281.
  ///
  /// In zh, this message translates to:
  /// **'用户权限'**
  String get userPermissionsTitle_7281;

  /// No description provided for @userPermissions_7281.
  ///
  /// In zh, this message translates to:
  /// **'用户权限'**
  String get userPermissions_7281;

  /// No description provided for @userPreferenceCloseFailed.
  ///
  /// In zh, this message translates to:
  /// **'关闭用户偏好服务失败: {e}'**
  String userPreferenceCloseFailed(Object e);

  /// No description provided for @userPreferenceDbUpgrade_7421.
  ///
  /// In zh, this message translates to:
  /// **'用户偏好设置数据库从版本 {oldVersion} 升级到 {newVersion}'**
  String userPreferenceDbUpgrade_7421(Object newVersion, Object oldVersion);

  /// No description provided for @userPreferenceInitFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'用户偏好设置服务初始化失败: {e}'**
  String userPreferenceInitFailed_7421(Object e);

  /// No description provided for @userPreferences.
  ///
  /// In zh, this message translates to:
  /// **'用户偏好设置'**
  String get userPreferences;

  /// No description provided for @userPreferencesInitComplete_4821.
  ///
  /// In zh, this message translates to:
  /// **'用户偏好设置配置管理系统初始化完成'**
  String get userPreferencesInitComplete_4821;

  /// No description provided for @userPreferencesInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'用户偏好设置服务初始化完成'**
  String get userPreferencesInitialized_7281;

  /// No description provided for @userPreferencesMigrationComplete.
  ///
  /// In zh, this message translates to:
  /// **'用户偏好设置迁移完成，迁移了 {migratedUsersCount} 个用户'**
  String userPreferencesMigrationComplete(Object migratedUsersCount);

  /// No description provided for @userPreferencesMigration_7281.
  ///
  /// In zh, this message translates to:
  /// **'执行用户偏好设置数据迁移...'**
  String get userPreferencesMigration_7281;

  /// No description provided for @userPreferencesSavedToDatabase.
  ///
  /// In zh, this message translates to:
  /// **'用户偏好设置已保存到数据库: {displayName}'**
  String userPreferencesSavedToDatabase(Object displayName);

  /// No description provided for @userPreferencesSaved_7281.
  ///
  /// In zh, this message translates to:
  /// **'用户偏好设置已保存: {displayName}'**
  String userPreferencesSaved_7281(Object displayName);

  /// No description provided for @userPreferencesTableCreated_7281.
  ///
  /// In zh, this message translates to:
  /// **'用户偏好设置数据库表创建完成'**
  String get userPreferencesTableCreated_7281;

  /// No description provided for @userPreferences_4821.
  ///
  /// In zh, this message translates to:
  /// **'用户偏好设置'**
  String get userPreferences_4821;

  /// No description provided for @userPrefsInitFailed_4829.
  ///
  /// In zh, this message translates to:
  /// **'初始化用户偏好设置失败: {e}'**
  String userPrefsInitFailed_4829(Object e);

  /// No description provided for @userStateInitFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'初始化用户状态失败'**
  String get userStateInitFailed_4821;

  /// No description provided for @userStateRemoved_4821.
  ///
  /// In zh, this message translates to:
  /// **'已移除用户状态'**
  String get userStateRemoved_4821;

  /// No description provided for @userStatusBroadcastError_4821.
  ///
  /// In zh, this message translates to:
  /// **'处理用户状态广播时出错: {error}'**
  String userStatusBroadcastError_4821(Object error);

  /// No description provided for @userStatusBroadcast_7421.
  ///
  /// In zh, this message translates to:
  /// **'用户状态广播: 用户={userId}, 在线状态={onlineStatus}, 活动状态={activityStatus}, 空间={spaceId}'**
  String userStatusBroadcast_7421(
    Object activityStatus,
    Object onlineStatus,
    Object spaceId,
    Object userId,
  );

  /// No description provided for @userStatusChangeBroadcast.
  ///
  /// In zh, this message translates to:
  /// **'用户状态发生变化，准备广播: {currentStatus} -> {newStatus}'**
  String userStatusChangeBroadcast(Object currentStatus, Object newStatus);

  /// No description provided for @userStatusUnchangedSkipBroadcast_4821.
  ///
  /// In zh, this message translates to:
  /// **'用户状态无变化，跳过广播'**
  String get userStatusUnchangedSkipBroadcast_4821;

  /// No description provided for @userStatusWithName.
  ///
  /// In zh, this message translates to:
  /// **'我: {statusText}'**
  String userStatusWithName(Object statusText);

  /// No description provided for @user_4821.
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get user_4821;

  /// No description provided for @usernameLabel_4521.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get usernameLabel_4521;

  /// No description provided for @usernameLabel_5421.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get usernameLabel_5421;

  /// No description provided for @usernameRequired_4821.
  ///
  /// In zh, this message translates to:
  /// **'请输入用户名'**
  String get usernameRequired_4821;

  /// No description provided for @usersEditingCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人正在编辑'**
  String usersEditingCount(Object count);

  /// No description provided for @valid_4821.
  ///
  /// In zh, this message translates to:
  /// **'有效'**
  String get valid_4821;

  /// No description provided for @valid_8421.
  ///
  /// In zh, this message translates to:
  /// **'有效'**
  String get valid_8421;

  /// No description provided for @validatingFilePaths_4919.
  ///
  /// In zh, this message translates to:
  /// **'正在验证文件路径...'**
  String get validatingFilePaths_4919;

  /// No description provided for @validatingMetadataFile_4821.
  ///
  /// In zh, this message translates to:
  /// **'正在验证元数据文件...'**
  String get validatingMetadataFile_4821;

  /// No description provided for @validationError_7285.
  ///
  /// In zh, this message translates to:
  /// **'验证过程出错: {error}'**
  String validationError_7285(Object error);

  /// No description provided for @verifiedAccountTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'认证账户'**
  String get verifiedAccountTitle_4821;

  /// No description provided for @verifiedAccount_7281.
  ///
  /// In zh, this message translates to:
  /// **'认证账户'**
  String get verifiedAccount_7281;

  /// No description provided for @versionAdapterExists_7281.
  ///
  /// In zh, this message translates to:
  /// **'版本适配器存在: {condition}'**
  String versionAdapterExists_7281(Object condition);

  /// No description provided for @versionCount_7281.
  ///
  /// In zh, this message translates to:
  /// **'版本数量: {count}'**
  String versionCount_7281(Object count);

  /// No description provided for @versionCreatedAndSwitched_7281.
  ///
  /// In zh, this message translates to:
  /// **'新版本创建并切换完成: {versionId}'**
  String versionCreatedAndSwitched_7281(Object versionId);

  /// No description provided for @versionCreatedMessage_7421.
  ///
  /// In zh, this message translates to:
  /// **'新版本已创建: {versionId}, 会话数据={sessionDataStatus}'**
  String versionCreatedMessage_7421(Object sessionDataStatus, Object versionId);

  /// No description provided for @versionCreated_7421.
  ///
  /// In zh, this message translates to:
  /// **'版本 \"{name}\" 已创建'**
  String versionCreated_7421(Object name);

  /// No description provided for @versionCreationFailed.
  ///
  /// In zh, this message translates to:
  /// **'创建版本失败: {error}'**
  String versionCreationFailed(Object error);

  /// No description provided for @versionCreationFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'创建版本失败: {e}'**
  String versionCreationFailed_7285(Object e);

  /// No description provided for @versionCreationStart.
  ///
  /// In zh, this message translates to:
  /// **'开始创建新版本: {versionId}, 源版本: {sourceVersionId}'**
  String versionCreationStart(Object sourceVersionId, Object versionId);

  /// No description provided for @versionCreationStatus.
  ///
  /// In zh, this message translates to:
  /// **'创建版本前状态: 当前版本={currentVersionId}, 当前地图图层数={layerCount}'**
  String versionCreationStatus(Object currentVersionId, Object layerCount);

  /// No description provided for @versionDataLoaded.
  ///
  /// In zh, this message translates to:
  /// **'版本 {versionId} 数据已加载到会话，图层数: {layerCount}, 图例组数: {legendGroupCount}, 便签数: {stickyNoteCount}'**
  String versionDataLoaded(
    Object layerCount,
    Object legendGroupCount,
    Object stickyNoteCount,
    Object versionId,
  );

  /// No description provided for @versionDataSaved_7281.
  ///
  /// In zh, this message translates to:
  /// **'保存版本数据 [{activeVersionId}] 完成'**
  String versionDataSaved_7281(Object activeVersionId);

  /// No description provided for @versionDataTitleEmpty_7281.
  ///
  /// In zh, this message translates to:
  /// **'版本数据标题为空: {versionId}'**
  String versionDataTitleEmpty_7281(Object versionId);

  /// No description provided for @versionDeletedComplete.
  ///
  /// In zh, this message translates to:
  /// **'版本删除完成: {versionId}'**
  String versionDeletedComplete(Object versionId);

  /// No description provided for @versionDeletedLog.
  ///
  /// In zh, this message translates to:
  /// **'删除版本完成 [{versionId}]'**
  String versionDeletedLog(Object versionId);

  /// No description provided for @versionDeletedSuccessfully_7281.
  ///
  /// In zh, this message translates to:
  /// **'版本已完全删除'**
  String get versionDeletedSuccessfully_7281;

  /// No description provided for @versionExistsInReactiveSystem_7421.
  ///
  /// In zh, this message translates to:
  /// **'版本 {versionId} 已存在于响应式系统中，但需要确保数据已加载'**
  String versionExistsInReactiveSystem_7421(Object versionId);

  /// No description provided for @versionExists_7284.
  ///
  /// In zh, this message translates to:
  /// **'版本已存在: {version}'**
  String versionExists_7284(Object version);

  /// No description provided for @versionExists_7285.
  ///
  /// In zh, this message translates to:
  /// **'版本已存在: {versionId}'**
  String versionExists_7285(Object versionId);

  /// No description provided for @versionFetchFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取版本名称失败 [{mapTitle}:{versionId}]: {e}'**
  String versionFetchFailed(Object e, Object mapTitle, Object versionId);

  /// No description provided for @versionHint_4936.
  ///
  /// In zh, this message translates to:
  /// **'如: 1.0.0'**
  String get versionHint_4936;

  /// No description provided for @versionLegendGroupStatusPath.
  ///
  /// In zh, this message translates to:
  /// **'版本 {versionId} 图例组 {legendGroupId} {status} 路径: {path}'**
  String versionLegendGroupStatusPath(
    Object legendGroupId,
    Object path,
    Object status,
    Object versionId,
  );

  /// No description provided for @versionLoadFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'加载版本 {versionId} 失败: {e}'**
  String versionLoadFailed_7281(Object e, Object versionId);

  /// No description provided for @versionLoadFailure_7285.
  ///
  /// In zh, this message translates to:
  /// **'从VFS加载版本失败: {e}'**
  String versionLoadFailure_7285(Object e);

  /// No description provided for @versionLoadedFromVfs_7281.
  ///
  /// In zh, this message translates to:
  /// **'完成从VFS加载版本，响应式系统中共有 {length} 个版本'**
  String versionLoadedFromVfs_7281(Object length);

  /// No description provided for @versionLoadedToReactiveSystem.
  ///
  /// In zh, this message translates to:
  /// **'已加载版本到响应式系统: {versionId} ({versionName})'**
  String versionLoadedToReactiveSystem(Object versionId, Object versionName);

  /// No description provided for @versionManagement_4821.
  ///
  /// In zh, this message translates to:
  /// **'版本管理'**
  String get versionManagement_4821;

  /// No description provided for @versionManagerStatusChanged_7281.
  ///
  /// In zh, this message translates to:
  /// **'版本管理器状态变化: {summary}'**
  String versionManagerStatusChanged_7281(Object summary);

  /// No description provided for @versionMetadataDeletedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'删除版本元数据成功 [{arg0}]'**
  String versionMetadataDeletedSuccessfully(Object arg0);

  /// No description provided for @versionMetadataReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'读取版本元数据失败，将创建新文件: {e}'**
  String versionMetadataReadFailed(Object e);

  /// No description provided for @versionMetadataSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存版本元数据失败 [{mapTitle}:{versionId}]: {e}'**
  String versionMetadataSaveFailed(Object e, Object mapTitle, Object versionId);

  /// No description provided for @versionMetadataSaveFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'保存版本元数据失败: {e}'**
  String versionMetadataSaveFailed_7421(Object e);

  /// No description provided for @versionMetadataSaved_7281.
  ///
  /// In zh, this message translates to:
  /// **'保存版本元数据成功 [{mapTitle}:{versionId} -> {versionName}]'**
  String versionMetadataSaved_7281(
    Object mapTitle,
    Object versionId,
    Object versionName,
  );

  /// No description provided for @versionMismatch_4823.
  ///
  /// In zh, this message translates to:
  /// **'版本不匹配'**
  String get versionMismatch_4823;

  /// No description provided for @versionNameHint_4822.
  ///
  /// In zh, this message translates to:
  /// **'输入版本名称'**
  String get versionNameHint_4822;

  /// No description provided for @versionNameLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'版本名称'**
  String get versionNameLabel_4821;

  /// No description provided for @versionNameMapping_7281.
  ///
  /// In zh, this message translates to:
  /// **'版本名称映射: {versionNames}'**
  String versionNameMapping_7281(Object versionNames);

  /// No description provided for @versionNoSessionDataToSave.
  ///
  /// In zh, this message translates to:
  /// **'版本 [{activeVersionId}] 没有会话数据，无法保存'**
  String versionNoSessionDataToSave(Object activeVersionId);

  /// No description provided for @versionNoSessionData_7281.
  ///
  /// In zh, this message translates to:
  /// **'版本 {versionId} 没有会话数据，尝试从VFS加载'**
  String versionNoSessionData_7281(Object versionId);

  /// No description provided for @versionNotExistNeedDelete.
  ///
  /// In zh, this message translates to:
  /// **'版本不存在，无需删除: {versionId}'**
  String versionNotExistNeedDelete(Object versionId);

  /// No description provided for @versionNotFoundCannotUpdate.
  ///
  /// In zh, this message translates to:
  /// **'版本不存在，无法更新数据: {versionId}'**
  String versionNotFoundCannotUpdate(Object versionId);

  /// No description provided for @versionNotFoundError.
  ///
  /// In zh, this message translates to:
  /// **'版本不存在: {versionId}'**
  String versionNotFoundError(Object versionId);

  /// No description provided for @versionNotFoundError_4821.
  ///
  /// In zh, this message translates to:
  /// **'版本不存在: {versionId}'**
  String versionNotFoundError_4821(Object versionId);

  /// No description provided for @versionNotFoundError_7284.
  ///
  /// In zh, this message translates to:
  /// **'版本不存在: {versionId}'**
  String versionNotFoundError_7284(Object versionId);

  /// No description provided for @versionNotFoundUsingDefault_7281.
  ///
  /// In zh, this message translates to:
  /// **'版本 {versionId} 不存在，使用基础数据作为初始数据'**
  String versionNotFoundUsingDefault_7281(Object versionId);

  /// No description provided for @versionOrSessionNotFound.
  ///
  /// In zh, this message translates to:
  /// **'版本或会话数据不存在，无法更新图例组: {versionId}'**
  String versionOrSessionNotFound(Object versionId);

  /// No description provided for @versionPathSelection_7281.
  ///
  /// In zh, this message translates to:
  /// **'目标版本 {versionId} 路径选择:'**
  String versionPathSelection_7281(Object versionId);

  /// No description provided for @versionSaveFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'保存版本数据失败 [{versionId}]: {error}'**
  String versionSaveFailed_7281(Object error, Object versionId);

  /// No description provided for @versionSavedLog.
  ///
  /// In zh, this message translates to:
  /// **'标记版本已保存 [{arg0}/{arg1}]'**
  String versionSavedLog(Object arg0, Object arg1);

  /// No description provided for @versionSavedToMetadata.
  ///
  /// In zh, this message translates to:
  /// **'版本名称已保存到元数据: {name} (ID: {versionId})'**
  String versionSavedToMetadata(Object name, Object versionId);

  /// No description provided for @versionSessionCacheMissing_7421.
  ///
  /// In zh, this message translates to:
  /// **'警告：版本 {key} 的会话数据缓存丢失'**
  String versionSessionCacheMissing_7421(Object key);

  /// No description provided for @versionSessionDataMissing_7281.
  ///
  /// In zh, this message translates to:
  /// **'版本会话数据不存在: {versionId}'**
  String versionSessionDataMissing_7281(Object versionId);

  /// No description provided for @versionSessionUsage_7281.
  ///
  /// In zh, this message translates to:
  /// **'版本 {versionId} 使用会话数据，图层数: {layersCount}'**
  String versionSessionUsage_7281(Object layersCount, Object versionId);

  /// No description provided for @versionStatusDebug.
  ///
  /// In zh, this message translates to:
  /// **'版本状态: 有会话数据={hasSessionData}, 有未保存更改={hasUnsavedChanges}'**
  String versionStatusDebug(Object hasSessionData, Object hasUnsavedChanges);

  /// No description provided for @versionStatusNotFound.
  ///
  /// In zh, this message translates to:
  /// **'版本状态不存在: {versionId}'**
  String versionStatusNotFound(Object versionId);

  /// No description provided for @versionStatusUpdated_7281.
  ///
  /// In zh, this message translates to:
  /// **'版本状态已更新，版本数量: {count}'**
  String versionStatusUpdated_7281(Object count);

  /// No description provided for @versionSwitchCleanPath.
  ///
  /// In zh, this message translates to:
  /// **'版本切换-清理路径: [{legendGroupId}] {path}'**
  String versionSwitchCleanPath(Object legendGroupId, Object path);

  /// No description provided for @versionSwitchComplete.
  ///
  /// In zh, this message translates to:
  /// **'智能版本切换完成: {previousVersionId} -> {versionId}'**
  String versionSwitchComplete(Object previousVersionId, Object versionId);

  /// No description provided for @versionSwitchCompleteResetFlag.
  ///
  /// In zh, this message translates to:
  /// **'版本切换完成，重置更新标志 [{versionId}]'**
  String versionSwitchCompleteResetFlag(Object versionId);

  /// No description provided for @versionSwitchFailed.
  ///
  /// In zh, this message translates to:
  /// **'切换版本失败: {e}'**
  String versionSwitchFailed(Object e);

  /// No description provided for @versionSwitchLog_7421.
  ///
  /// In zh, this message translates to:
  /// **'切换版本 [{mapTitle}]: {previousVersionId} -> {versionId}'**
  String versionSwitchLog_7421(
    Object mapTitle,
    Object previousVersionId,
    Object versionId,
  );

  /// No description provided for @versionSwitchPath_4821.
  ///
  /// In zh, this message translates to:
  /// **'版本切换-加载路径: [{legendGroupId}] {path}'**
  String versionSwitchPath_4821(Object legendGroupId, Object path);

  /// No description provided for @versionSwitchStart.
  ///
  /// In zh, this message translates to:
  /// **'开始智能版本切换: {previousVersionId} -> {versionId}'**
  String versionSwitchStart(Object previousVersionId, Object versionId);

  /// No description provided for @versionSystemInitialized.
  ///
  /// In zh, this message translates to:
  /// **'响应式版本管理系统初始化完成，当前版本: {currentVersionId}'**
  String versionSystemInitialized(Object currentVersionId);

  /// No description provided for @versionWarning_4821.
  ///
  /// In zh, this message translates to:
  /// **'警告: 两个版本都没有路径选择数据'**
  String get versionWarning_4821;

  /// No description provided for @versionWarning_7284.
  ///
  /// In zh, this message translates to:
  /// **'警告: 新版本 [{versionId}] 没有初始数据'**
  String versionWarning_7284(Object versionId);

  /// No description provided for @version_4935.
  ///
  /// In zh, this message translates to:
  /// **'版本 *'**
  String get version_4935;

  /// No description provided for @version_5027.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get version_5027;

  /// No description provided for @verticalLayoutNavBar_4821.
  ///
  /// In zh, this message translates to:
  /// **'将导航栏显示在屏幕右侧（垂直布局）'**
  String get verticalLayoutNavBar_4821;

  /// No description provided for @vfsCleanupComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'VFS数据清理完成'**
  String get vfsCleanupComplete_7281;

  /// No description provided for @vfsCleanupFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'VFS数据清理失败: {e}'**
  String vfsCleanupFailed_7281(Object e);

  /// No description provided for @vfsDatabaseCloseFailure.
  ///
  /// In zh, this message translates to:
  /// **'关闭VFS存储数据库失败: {e}'**
  String vfsDatabaseCloseFailure(Object e);

  /// No description provided for @vfsDatabaseExportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'VFS地图数据库导出成功 (版本: {dbVersion}, 地图数量: {mapCount})'**
  String vfsDatabaseExportSuccess(Object dbVersion, Object mapCount);

  /// No description provided for @vfsDirectoryLoadFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'VFS目录树: 加载失败 {e}'**
  String vfsDirectoryLoadFailed_7421(Object e);

  /// No description provided for @vfsDirectoryTreeBuilt_7281.
  ///
  /// In zh, this message translates to:
  /// **'VFS目录树: 构建完成，根节点包含 {count} 个子节点'**
  String vfsDirectoryTreeBuilt_7281(Object count);

  /// No description provided for @vfsDirectoryTreeCreateNode.
  ///
  /// In zh, this message translates to:
  /// **'VFS目录树: 创建节点 \"{segment}\" (路径: {currentPath})，添加到父节点 \"{parentName}\" (路径: {parentPath})'**
  String vfsDirectoryTreeCreateNode(
    Object currentPath,
    Object parentName,
    Object parentPath,
    Object segment,
  );

  /// No description provided for @vfsDirectoryTreeLoaded.
  ///
  /// In zh, this message translates to:
  /// **'VFS目录树: 加载完成，根节点包含 {count} 个子目录'**
  String vfsDirectoryTreeLoaded(Object count);

  /// No description provided for @vfsDirectoryTreeProcessingPath.
  ///
  /// In zh, this message translates to:
  /// **'VFS目录树: 处理路径 \"{folderPath}\"，分段: {pathSegments}'**
  String vfsDirectoryTreeProcessingPath(Object folderPath, Object pathSegments);

  /// No description provided for @vfsDirectoryTreeStartBuilding.
  ///
  /// In zh, this message translates to:
  /// **'VFS目录树: 开始构建，输入文件夹数量: {count}'**
  String vfsDirectoryTreeStartBuilding(Object count);

  /// No description provided for @vfsEntryCount.
  ///
  /// In zh, this message translates to:
  /// **'VFS返回的条目数量: {count}'**
  String vfsEntryCount(Object count);

  /// No description provided for @vfsErrorClosing_5421.
  ///
  /// In zh, this message translates to:
  /// **'关闭VFS系统时发生错误: {e}'**
  String vfsErrorClosing_5421(Object e);

  /// No description provided for @vfsFileInfoError.
  ///
  /// In zh, this message translates to:
  /// **'获取VFS文件信息失败: {e}'**
  String vfsFileInfoError(Object e);

  /// No description provided for @vfsFileInfoError_4821.
  ///
  /// In zh, this message translates to:
  /// **'获取VFS文件信息失败: {e}'**
  String vfsFileInfoError_4821(Object e);

  /// No description provided for @vfsFileLabel_4822.
  ///
  /// In zh, this message translates to:
  /// **'VFS文件'**
  String get vfsFileLabel_4822;

  /// No description provided for @vfsFileManager_4821.
  ///
  /// In zh, this message translates to:
  /// **'VFS 文件管理器'**
  String get vfsFileManager_4821;

  /// No description provided for @vfsFilePickerStyle_4821.
  ///
  /// In zh, this message translates to:
  /// **'VFS文件选择器风格'**
  String get vfsFilePickerStyle_4821;

  /// No description provided for @vfsImageLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载VFS图片失败: {e}'**
  String vfsImageLoadFailed(Object e);

  /// No description provided for @vfsInitFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'VFS系统初始化失败: {e}'**
  String vfsInitFailed_7281(Object e);

  /// No description provided for @vfsInitializationComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'应用VFS系统初始化完成'**
  String get vfsInitializationComplete_7281;

  /// No description provided for @vfsInitializationFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'应用VFS系统初始化失败: {e}'**
  String vfsInitializationFailed_7421(Object e);

  /// No description provided for @vfsInitializationSkipped_7281.
  ///
  /// In zh, this message translates to:
  /// **'VFS权限系统已初始化，跳过重复初始化'**
  String get vfsInitializationSkipped_7281;

  /// No description provided for @vfsInitializationStart_7281.
  ///
  /// In zh, this message translates to:
  /// **'开始初始化VFS根文件系统...'**
  String get vfsInitializationStart_7281;

  /// No description provided for @vfsInitializationSuccess_7281.
  ///
  /// In zh, this message translates to:
  /// **'VFS系统初始化成功'**
  String get vfsInitializationSuccess_7281;

  /// No description provided for @vfsInitializedSkipDb_4821.
  ///
  /// In zh, this message translates to:
  /// **'VFS系统已通过全局初始化完成，跳过默认数据库初始化'**
  String get vfsInitializedSkipDb_4821;

  /// No description provided for @vfsInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'VFS系统已初始化，跳过重复初始化'**
  String get vfsInitialized_7281;

  /// No description provided for @vfsLegendDirectory_4821.
  ///
  /// In zh, this message translates to:
  /// **'VFS图例目录'**
  String get vfsLegendDirectory_4821;

  /// No description provided for @vfsLegendDirectory_7421.
  ///
  /// In zh, this message translates to:
  /// **'VFS图例目录'**
  String get vfsLegendDirectory_7421;

  /// No description provided for @vfsLinkOpenFailed.
  ///
  /// In zh, this message translates to:
  /// **'打开VFS链接失败: {e}'**
  String vfsLinkOpenFailed(Object e);

  /// No description provided for @vfsMapDbImportFailed.
  ///
  /// In zh, this message translates to:
  /// **'VFS地图数据库导入失败: {e}'**
  String vfsMapDbImportFailed(Object e);

  /// No description provided for @vfsMapDbImportNotImplemented_7281.
  ///
  /// In zh, this message translates to:
  /// **'VFS地图数据库导入功能暂未实现'**
  String get vfsMapDbImportNotImplemented_7281;

  /// No description provided for @vfsMapExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'VFS地图数据库导出失败: {e}'**
  String vfsMapExportFailed(Object e);

  /// No description provided for @vfsMarkdownRendererCleanedTempFiles_7281.
  ///
  /// In zh, this message translates to:
  /// **'🔗 VfsMarkdownRenderer: 已清理临时文件'**
  String get vfsMarkdownRendererCleanedTempFiles_7281;

  /// No description provided for @vfsNodeExists_7281.
  ///
  /// In zh, this message translates to:
  /// **'VFS目录树: 节点已存在: {currentPath}'**
  String vfsNodeExists_7281(Object currentPath);

  /// No description provided for @vfsPlatformIOCleanedTempFiles_7281.
  ///
  /// In zh, this message translates to:
  /// **'🔗 VfsPlatformIO: 已清理临时文件'**
  String get vfsPlatformIOCleanedTempFiles_7281;

  /// No description provided for @vfsPlatformIOCreatingTempFile_4821.
  ///
  /// In zh, this message translates to:
  /// **'🔗 VfsPlatformIO: 开始创建临时文件'**
  String get vfsPlatformIOCreatingTempFile_4821;

  /// No description provided for @vfsProviderCloseFailed.
  ///
  /// In zh, this message translates to:
  /// **'关闭VFS服务提供者失败: {e}'**
  String vfsProviderCloseFailed(Object e);

  /// No description provided for @vfsRootExists_7281.
  ///
  /// In zh, this message translates to:
  /// **'VFS根文件系统已存在，跳过初始化'**
  String get vfsRootExists_7281;

  /// No description provided for @vfsRootInitFailed.
  ///
  /// In zh, this message translates to:
  /// **'VFS根文件系统初始化失败: {e}'**
  String vfsRootInitFailed(Object e);

  /// No description provided for @vfsRootInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'VFS根文件系统初始化完成'**
  String get vfsRootInitialized_7281;

  /// No description provided for @vfsServiceNoNeedToClose_7281.
  ///
  /// In zh, this message translates to:
  /// **'VFS服务不需要显式关闭'**
  String get vfsServiceNoNeedToClose_7281;

  /// No description provided for @vfsShutdownComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'VFS系统关闭完成'**
  String get vfsShutdownComplete_7281;

  /// No description provided for @vfsShutdownTime.
  ///
  /// In zh, this message translates to:
  /// **'VFS系统关闭耗时: {elapsedMilliseconds}ms'**
  String vfsShutdownTime(Object elapsedMilliseconds);

  /// No description provided for @vfsTreeWarningParentNotFound.
  ///
  /// In zh, this message translates to:
  /// **'VFS目录树: 警告 - 找不到父节点: {parentPath}'**
  String vfsTreeWarningParentNotFound(Object parentPath);

  /// No description provided for @vfsVersionDeletedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'VFS版本数据删除成功: {versionId}'**
  String vfsVersionDeletedSuccessfully(Object versionId);

  /// No description provided for @vfsVersionNotImplemented_7281.
  ///
  /// In zh, this message translates to:
  /// **'VFS版本管理暂未实现'**
  String get vfsVersionNotImplemented_7281;

  /// No description provided for @videoConversionComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎥 VideoProcessor.convertMarkdownVideos: 转换完成'**
  String get videoConversionComplete_7281;

  /// No description provided for @videoCountLabel_7281.
  ///
  /// In zh, this message translates to:
  /// **'视频: {videoCount}'**
  String videoCountLabel_7281(Object videoCount);

  /// No description provided for @videoElementCreationLog.
  ///
  /// In zh, this message translates to:
  /// **'🎥 VideoSyntax.onMatch: 创建视频元素 - tag: {tag}, attributes: {attributes}'**
  String videoElementCreationLog(Object attributes, Object tag);

  /// No description provided for @videoFile_4821.
  ///
  /// In zh, this message translates to:
  /// **'视频文件'**
  String get videoFile_4821;

  /// No description provided for @videoFile_5732.
  ///
  /// In zh, this message translates to:
  /// **'视频文件'**
  String get videoFile_5732;

  /// No description provided for @videoFile_7421.
  ///
  /// In zh, this message translates to:
  /// **'视频文件'**
  String get videoFile_7421;

  /// No description provided for @videoFormats_7281.
  ///
  /// In zh, this message translates to:
  /// **'• 视频: mp4, avi, mov, wmv'**
  String get videoFormats_7281;

  /// No description provided for @videoInfoLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载视频信息失败: {e}'**
  String videoInfoLoadFailed(Object e);

  /// No description provided for @videoInfo_4271.
  ///
  /// In zh, this message translates to:
  /// **'视频信息'**
  String get videoInfo_4271;

  /// No description provided for @videoInfo_4821.
  ///
  /// In zh, this message translates to:
  /// **'视频信息'**
  String get videoInfo_4821;

  /// No description provided for @videoInfo_7421.
  ///
  /// In zh, this message translates to:
  /// **'视频信息'**
  String get videoInfo_7421;

  /// No description provided for @videoLinkCopiedToClipboard_4821.
  ///
  /// In zh, this message translates to:
  /// **'视频链接已复制到剪贴板'**
  String get videoLinkCopiedToClipboard_4821;

  /// No description provided for @videoLoadFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'视频加载失败'**
  String get videoLoadFailed_4821;

  /// No description provided for @videoLoadFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'视频加载失败'**
  String get videoLoadFailed_7281;

  /// No description provided for @videoNodeAddedToParent_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎥 HtmlToSpanVisitor: VideoNode已添加到父节点'**
  String get videoNodeAddedToParent_7281;

  /// No description provided for @videoNodeBuildLog.
  ///
  /// In zh, this message translates to:
  /// **'🎥 VideoNode.build: 返回WidgetSpan - MediaKitVideoPlayer(url: {src})'**
  String videoNodeBuildLog(Object src);

  /// No description provided for @videoNodeBuildStart.
  ///
  /// In zh, this message translates to:
  /// **'开始构建 - src: {src}'**
  String videoNodeBuildStart(Object src);

  /// No description provided for @videoNodeCreationLog.
  ///
  /// In zh, this message translates to:
  /// **'🎥 VideoNode: 创建节点 - attributes: {attributes}, textContent: {textContent}'**
  String videoNodeCreationLog(Object attributes, Object textContent);

  /// No description provided for @videoNodeGenerationLog.
  ///
  /// In zh, this message translates to:
  /// **'🎥 VideoProcessor: 生成VideoNode - tag: {tag}, attributes: {attributes}, textContent: {textContent}'**
  String videoNodeGenerationLog(
    Object attributes,
    Object tag,
    Object textContent,
  );

  /// No description provided for @videoProcessorConvertMarkdownVideos_7425.
  ///
  /// In zh, this message translates to:
  /// **'VideoProcessor.convertMarkdownVideos: 转换 {src}'**
  String videoProcessorConvertMarkdownVideos_7425(Object src);

  /// No description provided for @videoProcessorCreated_4821.
  ///
  /// In zh, this message translates to:
  /// **'🎥 VideoProcessor: 创建视频生成器'**
  String get videoProcessorCreated_4821;

  /// No description provided for @videoProcessorDebug.
  ///
  /// In zh, this message translates to:
  /// **'🎥 VideoProcessor.containsVideo: text长度={textLength}, 包含视频={result}'**
  String videoProcessorDebug(Object result, Object textLength);

  /// No description provided for @videoProcessorStartConversion_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎥 VideoProcessor.convertMarkdownVideos: 开始转换'**
  String get videoProcessorStartConversion_7281;

  /// No description provided for @videoStatusLabel_4829.
  ///
  /// In zh, this message translates to:
  /// **'视频{status}'**
  String videoStatusLabel_4829(Object status);

  /// No description provided for @videoSyntaxParserAdded_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎥 _buildMarkdownContent: 添加视频语法解析器和生成器'**
  String get videoSyntaxParserAdded_7281;

  /// No description provided for @videoTagDetected_7281.
  ///
  /// In zh, this message translates to:
  /// **'🎥 HtmlToSpanVisitor: 发现video标签，创建VideoNode'**
  String get videoTagDetected_7281;

  /// No description provided for @videoTagMatched.
  ///
  /// In zh, this message translates to:
  /// **'匹配到视频标签 - {matchValue}'**
  String videoTagMatched(Object matchValue);

  /// No description provided for @vietnameseVN_4892.
  ///
  /// In zh, this message translates to:
  /// **'越南语 (越南)'**
  String get vietnameseVN_4892;

  /// No description provided for @vietnamese_4838.
  ///
  /// In zh, this message translates to:
  /// **'越南语'**
  String get vietnamese_4838;

  /// No description provided for @viewDetails_4821.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get viewDetails_4821;

  /// No description provided for @viewEditShortcutSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'点击查看和编辑所有快捷键设置'**
  String get viewEditShortcutSettings_4821;

  /// No description provided for @viewExecutionLogs_4821.
  ///
  /// In zh, this message translates to:
  /// **'查看执行日志'**
  String get viewExecutionLogs_4821;

  /// No description provided for @viewFolderPermissions_4821.
  ///
  /// In zh, this message translates to:
  /// **'查看文件夹权限'**
  String get viewFolderPermissions_4821;

  /// No description provided for @viewFullLicenseList_7281.
  ///
  /// In zh, this message translates to:
  /// **'查看完整许可证列表'**
  String get viewFullLicenseList_7281;

  /// No description provided for @viewItemDetails_7421.
  ///
  /// In zh, this message translates to:
  /// **'查看 {item} 详情'**
  String viewItemDetails_7421(Object item);

  /// No description provided for @viewProjectDetails.
  ///
  /// In zh, this message translates to:
  /// **'查看项目 {index} 详情'**
  String viewProjectDetails(Object index);

  /// No description provided for @viewShortcutList_7281.
  ///
  /// In zh, this message translates to:
  /// **'查看快捷键列表'**
  String get viewShortcutList_7281;

  /// No description provided for @view_4821.
  ///
  /// In zh, this message translates to:
  /// **'视图'**
  String get view_4821;

  /// No description provided for @view_4822.
  ///
  /// In zh, this message translates to:
  /// **'视图'**
  String get view_4822;

  /// No description provided for @viewingStatus_5723.
  ///
  /// In zh, this message translates to:
  /// **'正在查看'**
  String get viewingStatus_5723;

  /// No description provided for @viewingStatus_5732.
  ///
  /// In zh, this message translates to:
  /// **'查看中'**
  String get viewingStatus_5732;

  /// No description provided for @viewingStatus_6943.
  ///
  /// In zh, this message translates to:
  /// **'查看中'**
  String get viewingStatus_6943;

  /// No description provided for @viewingStatus_7532.
  ///
  /// In zh, this message translates to:
  /// **'查看中'**
  String get viewingStatus_7532;

  /// No description provided for @visualEffectsSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'视觉效果设置'**
  String get visualEffectsSettings_4821;

  /// No description provided for @voiceLog_7288.
  ///
  /// In zh, this message translates to:
  /// **', voice: {voice}'**
  String voiceLog_7288(Object voice);

  /// No description provided for @voiceNoteLabel_7281.
  ///
  /// In zh, this message translates to:
  /// **'语音便签'**
  String get voiceNoteLabel_7281;

  /// No description provided for @voiceNote_7281.
  ///
  /// In zh, this message translates to:
  /// **'语音便签'**
  String get voiceNote_7281;

  /// No description provided for @voiceSpeed_4251.
  ///
  /// In zh, this message translates to:
  /// **'语音速度'**
  String get voiceSpeed_4251;

  /// No description provided for @voiceSynthesisEmptyText_7281.
  ///
  /// In zh, this message translates to:
  /// **'语音合成: 文本为空，跳过'**
  String get voiceSynthesisEmptyText_7281;

  /// No description provided for @voiceSynthesisFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'语音合成失败: {e}'**
  String voiceSynthesisFailed_7281(Object e);

  /// No description provided for @voiceSynthesisLog_7283.
  ///
  /// In zh, this message translates to:
  /// **'语音合成: \"{text}\"'**
  String voiceSynthesisLog_7283(Object text);

  /// No description provided for @voiceSynthesisLog_7285.
  ///
  /// In zh, this message translates to:
  /// **'处理语音合成: text=\"{text}\"'**
  String voiceSynthesisLog_7285(Object text);

  /// No description provided for @voiceTitle_4271.
  ///
  /// In zh, this message translates to:
  /// **'语音'**
  String get voiceTitle_4271;

  /// No description provided for @volumeControl_4821.
  ///
  /// In zh, this message translates to:
  /// **'音量控制'**
  String get volumeControl_4821;

  /// No description provided for @volumeControl_7281.
  ///
  /// In zh, this message translates to:
  /// **'音量控制'**
  String get volumeControl_7281;

  /// No description provided for @volumeLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'音量'**
  String get volumeLabel_4821;

  /// No description provided for @volumeLabel_8472.
  ///
  /// In zh, this message translates to:
  /// **'音量'**
  String get volumeLabel_8472;

  /// No description provided for @volumeLog_7286.
  ///
  /// In zh, this message translates to:
  /// **', volume: {volume}'**
  String volumeLog_7286(Object volume);

  /// No description provided for @volumePercentage.
  ///
  /// In zh, this message translates to:
  /// **'音量: {percentage}%'**
  String volumePercentage(Object percentage);

  /// No description provided for @volumeSetTo.
  ///
  /// In zh, this message translates to:
  /// **'音量设置为 {percentage}%'**
  String volumeSetTo(Object percentage);

  /// No description provided for @volumeSettingFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'设置音量失败: {e}'**
  String volumeSettingFailed_7285(Object e);

  /// No description provided for @volumeTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'音量'**
  String get volumeTitle_4821;

  /// No description provided for @waitingUserConfirmImport_5041.
  ///
  /// In zh, this message translates to:
  /// **'等待用户确认导入...'**
  String get waitingUserConfirmImport_5041;

  /// No description provided for @waitingUserSelectImport_5025.
  ///
  /// In zh, this message translates to:
  /// **'等待用户选择导入项...'**
  String get waitingUserSelectImport_5025;

  /// No description provided for @wall_4826.
  ///
  /// In zh, this message translates to:
  /// **'墙'**
  String get wall_4826;

  /// No description provided for @warningCannotLoadStickerImage.
  ///
  /// In zh, this message translates to:
  /// **'警告：无法从资产系统加载便签绘画元素图像，哈希: {imageHash}'**
  String warningCannotLoadStickerImage(Object imageHash);

  /// No description provided for @warningCannotLoadStickyNoteBackground.
  ///
  /// In zh, this message translates to:
  /// **'警告：无法从资产系统加载便签背景图片，哈希: {backgroundImageHash}'**
  String warningCannotLoadStickyNoteBackground(Object backgroundImageHash);

  /// No description provided for @warningFailedToLoadNoteDrawingElement.
  ///
  /// In zh, this message translates to:
  /// **'警告：无法从资产系统加载便签绘画元素图像，哈希: {imageHash}'**
  String warningFailedToLoadNoteDrawingElement(Object imageHash);

  /// No description provided for @warningFailedToLoadStickyNoteBackground_7285.
  ///
  /// In zh, this message translates to:
  /// **'警告：无法从资产系统加载便签背景图片，哈希: {backgroundImageHash}'**
  String warningFailedToLoadStickyNoteBackground_7285(
    Object backgroundImageHash,
  );

  /// No description provided for @warningLayerBackgroundLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'警告：无法从资产系统加载图层背景图，哈希: {hash}'**
  String warningLayerBackgroundLoadFailed(Object hash);

  /// No description provided for @warningMessage_7284.
  ///
  /// In zh, this message translates to:
  /// **'警告消息'**
  String get warningMessage_7284;

  /// No description provided for @warningSourcePathNotExists_5003.
  ///
  /// In zh, this message translates to:
  /// **'警告：源路径不存在，跳过'**
  String get warningSourcePathNotExists_5003;

  /// No description provided for @warning_6643.
  ///
  /// In zh, this message translates to:
  /// **'警告'**
  String get warning_6643;

  /// No description provided for @warning_7281.
  ///
  /// In zh, this message translates to:
  /// **'警告'**
  String get warning_7281;

  /// No description provided for @webApiKeyClientConfigFailed.
  ///
  /// In zh, this message translates to:
  /// **'使用 Web API Key 创建客户端配置失败: {e}'**
  String webApiKeyClientConfigFailed(Object e);

  /// No description provided for @webApiKeyHint_7532.
  ///
  /// In zh, this message translates to:
  /// **'输入 Web API Key'**
  String get webApiKeyHint_7532;

  /// No description provided for @webApiKeyLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'Web API Key'**
  String get webApiKeyLabel_4821;

  /// No description provided for @webApis.
  ///
  /// In zh, this message translates to:
  /// **'Web API'**
  String get webApis;

  /// No description provided for @webBrowser_5732.
  ///
  /// In zh, this message translates to:
  /// **'Web浏览器'**
  String get webBrowser_5732;

  /// No description provided for @webClipboardNotSupported_7281.
  ///
  /// In zh, this message translates to:
  /// **'Web 平台不支持平台特定的剪贴板读取实现'**
  String get webClipboardNotSupported_7281;

  /// No description provided for @webContextMenuDemoTitle_4721.
  ///
  /// In zh, this message translates to:
  /// **'Web右键菜单演示'**
  String get webContextMenuDemoTitle_4721;

  /// No description provided for @webContextMenuExample_7281.
  ///
  /// In zh, this message translates to:
  /// **'Web兼容右键菜单示例'**
  String get webContextMenuExample_7281;

  /// No description provided for @webCopyHint_9012.
  ///
  /// In zh, this message translates to:
  /// **'Web平台'**
  String get webCopyHint_9012;

  /// No description provided for @webDatabaseImportComplete_4821.
  ///
  /// In zh, this message translates to:
  /// **'WebDatabaseImporter: 数据导入完成'**
  String get webDatabaseImportComplete_4821;

  /// No description provided for @webDatabaseImporterWebOnly_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebDatabaseImporter: 只能在Web平台使用'**
  String get webDatabaseImporterWebOnly_7281;

  /// No description provided for @webDavAccountCreated.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV认证账户已创建: {authAccountId}'**
  String webDavAccountCreated(Object authAccountId);

  /// No description provided for @webDavAccountUpdated.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV认证账户已更新: {authAccountId}'**
  String webDavAccountUpdated(Object authAccountId);

  /// No description provided for @webDavAuthAccountDeleted.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV认证账户已删除: {authAccountId}'**
  String webDavAuthAccountDeleted(Object authAccountId);

  /// No description provided for @webDavAuthAccountNotFound.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV认证账户未找到: {authAccountId}'**
  String webDavAuthAccountNotFound(Object authAccountId);

  /// No description provided for @webDavAuthFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV认证凭据验证失败：密码未找到'**
  String get webDavAuthFailed_7281;

  /// No description provided for @webDavAuthFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV认证凭据验证失败: {e}'**
  String webDavAuthFailed_7285(Object e);

  /// No description provided for @webDavClientCreationError_4821.
  ///
  /// In zh, this message translates to:
  /// **'无法创建WebDAV客户端，请检查配置'**
  String get webDavClientCreationError_4821;

  /// No description provided for @webDavClientCreationFailed.
  ///
  /// In zh, this message translates to:
  /// **'创建WebDAV客户端失败: {e}'**
  String webDavClientCreationFailed(Object e);

  /// No description provided for @webDavClientInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV客户端服务初始化完成'**
  String get webDavClientInitialized_7281;

  /// No description provided for @webDavConfigCreated.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV配置已创建: {configId}'**
  String webDavConfigCreated(Object configId);

  /// No description provided for @webDavConfigDeleted.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV配置已删除: {configId}'**
  String webDavConfigDeleted(Object configId);

  /// No description provided for @webDavConfigNotFound.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV配置未找到: {configId}'**
  String webDavConfigNotFound(Object configId);

  /// No description provided for @webDavConfigTitle_7281.
  ///
  /// In zh, this message translates to:
  /// **'配置和管理 WebDAV 云存储连接'**
  String get webDavConfigTitle_7281;

  /// No description provided for @webDavConfigUpdated.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV配置已更新: {configId}'**
  String webDavConfigUpdated(Object configId);

  /// No description provided for @webDavConfig_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 配置'**
  String get webDavConfig_7281;

  /// No description provided for @webDavInitializationComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV安全存储服务初始化完成'**
  String get webDavInitializationComplete_7281;

  /// No description provided for @webDavInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV数据库服务初始化完成'**
  String get webDavInitialized_7281;

  /// No description provided for @webDavManagement_4271.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 管理'**
  String get webDavManagement_4271;

  /// No description provided for @webDavManagement_4821.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 管理'**
  String get webDavManagement_4821;

  /// No description provided for @webDavManagement_7421.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 管理'**
  String get webDavManagement_7421;

  /// No description provided for @webDavPasswordDeleted.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV密码已删除: {authAccountId}'**
  String webDavPasswordDeleted(Object authAccountId);

  /// No description provided for @webDavPasswordDeletionFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除WebDAV密码失败: {e}'**
  String webDavPasswordDeletionFailed(Object e);

  /// No description provided for @webDavPasswordError.
  ///
  /// In zh, this message translates to:
  /// **'获取WebDAV密码失败: {e}'**
  String webDavPasswordError(Object e);

  /// No description provided for @webDavPasswordNotFound.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV密码未找到: {authAccountId}'**
  String webDavPasswordNotFound(Object authAccountId);

  /// No description provided for @webDavPasswordRemoved.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV密码已从 SharedPreferences 删除 (macOS): {authAccountId}'**
  String webDavPasswordRemoved(Object authAccountId);

  /// No description provided for @webDavPasswordRetrievedMacos.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV密码从 SharedPreferences 获取成功 (macOS): {authAccountId}'**
  String webDavPasswordRetrievedMacos(Object authAccountId);

  /// No description provided for @webDavPasswordSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'存储WebDAV密码失败: {e}'**
  String webDavPasswordSaveFailed(Object e);

  /// No description provided for @webDavPasswordStored.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV密码已安全存储: {authAccountId}'**
  String webDavPasswordStored(Object authAccountId);

  /// No description provided for @webDavPasswordSuccess_7285.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV密码获取成功: {authAccountId}'**
  String webDavPasswordSuccess_7285(Object authAccountId);

  /// No description provided for @webDavPasswordsClearedMacOs.
  ///
  /// In zh, this message translates to:
  /// **'所有WebDAV密码已从 SharedPreferences 清理 (macOS)'**
  String get webDavPasswordsClearedMacOs;

  /// No description provided for @webDavStatsError_4821.
  ///
  /// In zh, this message translates to:
  /// **'获取WebDAV存储统计信息失败: {e}'**
  String webDavStatsError_4821(Object e);

  /// No description provided for @webDavStorageCreated.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV存储目录已创建: {storagePath}'**
  String webDavStorageCreated(Object storagePath);

  /// No description provided for @webDavTempFilesCleaned.
  ///
  /// In zh, this message translates to:
  /// **'🔗 VfsPlatformIO: 已清理WebDAV导入临时文件'**
  String get webDavTempFilesCleaned;

  /// No description provided for @webDavUploadFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV上传失败'**
  String get webDavUploadFailed_7281;

  /// No description provided for @webDavUploadFailed_7421.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV上传失败：{e}'**
  String webDavUploadFailed_7421(Object e);

  /// No description provided for @webDavUploadSuccess.
  ///
  /// In zh, this message translates to:
  /// **'成功上传到WebDAV：{remotePath}'**
  String webDavUploadSuccess(Object remotePath);

  /// No description provided for @webDownloadFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'Web平台下载失败: {error}'**
  String webDownloadFailed_4821(Object error);

  /// No description provided for @webDownloadFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'Web压缩包下载失败: {e}'**
  String webDownloadFailed_7285(Object e);

  /// No description provided for @webDownloadHelperWebOnly_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebDownloadHelper只能在Web平台使用'**
  String get webDownloadHelperWebOnly_7281;

  /// No description provided for @webDownloadUtilsWebOnly_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebDownloadUtils只能在Web平台使用'**
  String get webDownloadUtilsWebOnly_7281;

  /// No description provided for @webExportImageFailed.
  ///
  /// In zh, this message translates to:
  /// **'Web平台导出图片失败: {e}'**
  String webExportImageFailed(Object e);

  /// No description provided for @webExportSingleImageFailed.
  ///
  /// In zh, this message translates to:
  /// **'Web平台导出单张图片失败: {e}'**
  String webExportSingleImageFailed(Object e);

  /// No description provided for @webFeatures.
  ///
  /// In zh, this message translates to:
  /// **'Web 功能：'**
  String get webFeatures;

  /// No description provided for @webFileDownloadFailed_7285.
  ///
  /// In zh, this message translates to:
  /// **'Web文件下载失败: {e}'**
  String webFileDownloadFailed_7285(Object e);

  /// No description provided for @webImageCopyFailed.
  ///
  /// In zh, this message translates to:
  /// **'Web 平台复制图像失败: {e}'**
  String webImageCopyFailed(Object e);

  /// No description provided for @webMode_1589.
  ///
  /// In zh, this message translates to:
  /// **'Web模式'**
  String get webMode_1589;

  /// No description provided for @webPdfDialogOpened_7281.
  ///
  /// In zh, this message translates to:
  /// **'Web平台PDF打印对话框已打开'**
  String get webPdfDialogOpened_7281;

  /// No description provided for @webPlatform.
  ///
  /// In zh, this message translates to:
  /// **'Web 平台'**
  String get webPlatform;

  /// No description provided for @webPlatformExportPdf_4728.
  ///
  /// In zh, this message translates to:
  /// **'Web平台将使用打印功能导出PDF'**
  String get webPlatformExportPdf_4728;

  /// No description provided for @webPlatformFeatures_4821.
  ///
  /// In zh, this message translates to:
  /// **'在Web平台上：'**
  String get webPlatformFeatures_4821;

  /// No description provided for @webPlatformMenuDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'在Web平台上，浏览器默认会显示自己的右键菜单。通过我们的处理方案，可以禁用浏览器默认菜单，使用Flutter自定义菜单。'**
  String get webPlatformMenuDescription_4821;

  /// No description provided for @webPlatformNoNeedCleanTempFiles_4821.
  ///
  /// In zh, this message translates to:
  /// **'🔗 VfsPlatformWeb: Web平台不需要清理临时文件'**
  String get webPlatformNoNeedCleanTempFiles_4821;

  /// No description provided for @webPlatformNotSupportTempFile_4821.
  ///
  /// In zh, this message translates to:
  /// **'Web平台不支持生成临时文件，请使用Data URI或Blob URL'**
  String get webPlatformNotSupportTempFile_4821;

  /// No description provided for @webPlatformNotSupported_7281.
  ///
  /// In zh, this message translates to:
  /// **'Web平台不支持创建文件'**
  String get webPlatformNotSupported_7281;

  /// No description provided for @webPlatformRightClickMenuDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'Web平台右键菜单说明'**
  String get webPlatformRightClickMenuDescription_4821;

  /// No description provided for @webPlatformUnsupportedDirectoryCreation_4821.
  ///
  /// In zh, this message translates to:
  /// **'Web平台不支持创建目录'**
  String get webPlatformUnsupportedDirectoryCreation_4821;

  /// No description provided for @webPlatform_1234.
  ///
  /// In zh, this message translates to:
  /// **'Web平台'**
  String get webPlatform_1234;

  /// No description provided for @webReadOnlyModeWithOperation_7421.
  ///
  /// In zh, this message translates to:
  /// **'Web版本为只读模式，无法执行\"{operation}\"操作。\n\n如需编辑功能，请使用桌面版本。'**
  String webReadOnlyModeWithOperation_7421(Object operation);

  /// No description provided for @webRightClickDemo_4821.
  ///
  /// In zh, this message translates to:
  /// **'Web右键菜单演示'**
  String get webRightClickDemo_4821;

  /// No description provided for @webSocketConnectionManager_4821.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket 连接管理'**
  String get webSocketConnectionManager_4821;

  /// No description provided for @webSocketConnectionStart_7281.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService 开始连接WebSocket'**
  String get webSocketConnectionStart_7281;

  /// No description provided for @webSocketInitComplete_4821.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket 安全存储服务初始化完成'**
  String get webSocketInitComplete_4821;

  /// No description provided for @webSocketInitFailed.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket 客户端管理器初始化失败: {e}'**
  String webSocketInitFailed(Object e);

  /// No description provided for @webSocketManagerInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket 连接管理器初始化成功'**
  String get webSocketManagerInitialized_7281;

  /// No description provided for @webSpecificFeatures.
  ///
  /// In zh, this message translates to:
  /// **'Web 特定功能可以在这里实现。'**
  String get webSpecificFeatures;

  /// No description provided for @webTempDirUnsupported_7281.
  ///
  /// In zh, this message translates to:
  /// **'Web平台不支持获取临时目录'**
  String get webTempDirUnsupported_7281;

  /// No description provided for @webdavDownloadCancelled_5045.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV下载已取消'**
  String get webdavDownloadCancelled_5045;

  /// No description provided for @webdavImportCancelled_5043.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV导入已取消'**
  String get webdavImportCancelled_5043;

  /// No description provided for @webdavImportFailed_5046.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV导入失败'**
  String get webdavImportFailed_5046;

  /// No description provided for @webdavImportList_5044.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV导入列表'**
  String get webdavImportList_5044;

  /// No description provided for @webdavImport_4975.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV导入'**
  String get webdavImport_4975;

  /// No description provided for @websocketClientConfigDeleted.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket 客户端配置已删除: {clientId}'**
  String websocketClientConfigDeleted(Object clientId);

  /// No description provided for @websocketClientConfig_4821.
  ///
  /// In zh, this message translates to:
  /// **'管理 WebSocket 客户端连接配置'**
  String get websocketClientConfig_4821;

  /// No description provided for @websocketClientDbInitComplete_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket 客户端数据库服务初始化完成'**
  String get websocketClientDbInitComplete_7281;

  /// No description provided for @websocketConfigSaved.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket 客户端配置已保存: {displayName}'**
  String websocketConfigSaved(Object displayName);

  /// No description provided for @websocketConnectedStatusRequest_4821.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket已连接，请求在线状态列表'**
  String get websocketConnectedStatusRequest_4821;

  /// No description provided for @websocketConnectedSuccess_4821.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket连接成功，请求在线状态列表'**
  String get websocketConnectedSuccess_4821;

  /// No description provided for @websocketConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接 WebSocket 服务器失败: {e}'**
  String websocketConnectionFailed(Object e);

  /// No description provided for @websocketConnectionFailed_4821.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService WebSocket连接失败'**
  String get websocketConnectionFailed_4821;

  /// No description provided for @websocketConnectionManagement_4821.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket 连接管理'**
  String get websocketConnectionManagement_4821;

  /// No description provided for @websocketDbUpgradeMessage.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket 客户端配置数据库从版本 {oldVersion} 升级到 {newVersion}'**
  String websocketDbUpgradeMessage(Object newVersion, Object oldVersion);

  /// No description provided for @websocketDisconnectFailed.
  ///
  /// In zh, this message translates to:
  /// **'断开 WebSocket 连接失败: {e}'**
  String websocketDisconnectFailed(Object e);

  /// No description provided for @websocketDisconnected_7281.
  ///
  /// In zh, this message translates to:
  /// **'GlobalCollaborationService WebSocket连接已断开'**
  String get websocketDisconnected_7281;

  /// No description provided for @websocketError_4829.
  ///
  /// In zh, this message translates to:
  /// **'处理WebSocket消息时出错: {error}'**
  String websocketError_4829(Object error);

  /// No description provided for @websocketManagerInitializedSuccess_4821.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket 客户端管理器初始化成功'**
  String get websocketManagerInitializedSuccess_4821;

  /// No description provided for @websocketManagerInitialized_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket 客户端管理器初始化完成'**
  String get websocketManagerInitialized_7281;

  /// No description provided for @websocketNotConnectedSkipBroadcast_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket未连接，跳过广播用户状态更新（离线模式）'**
  String get websocketNotConnectedSkipBroadcast_7281;

  /// No description provided for @websocketNotInitializedError_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket 客户端管理器未初始化，请先调用 initialize()'**
  String get websocketNotInitializedError_7281;

  /// No description provided for @websocketTableCreated_7281.
  ///
  /// In zh, this message translates to:
  /// **'WebSocket 客户端配置数据库表创建完成'**
  String get websocketTableCreated_7281;

  /// No description provided for @welcomeFloatingWidget_7421.
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用浮动窗口组件！'**
  String get welcomeFloatingWidget_7421;

  /// No description provided for @wheelMenuInstruction_4521.
  ///
  /// In zh, this message translates to:
  /// **'使用中键或触摸板双指按下\n来调起轮盘菜单'**
  String get wheelMenuInstruction_4521;

  /// No description provided for @widthWithPx_7421.
  ///
  /// In zh, this message translates to:
  /// **'宽度: {value}px'**
  String widthWithPx_7421(Object value);

  /// No description provided for @windowAutoSnapHint_4721.
  ///
  /// In zh, this message translates to:
  /// **'窗口会自动保持在屏幕可见区域内。'**
  String get windowAutoSnapHint_4721;

  /// No description provided for @windowBoundaryHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'窗口会自动限制在屏幕边界内，但允许部分内容移出屏幕边缘。'**
  String get windowBoundaryHint_4821;

  /// No description provided for @windowConfigChainCall_7284.
  ///
  /// In zh, this message translates to:
  /// **'使用链式调用配置窗口属性'**
  String get windowConfigChainCall_7284;

  /// No description provided for @windowContentDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'窗口内容描述'**
  String get windowContentDescription_4821;

  /// No description provided for @windowControlDisplayMode_4821.
  ///
  /// In zh, this message translates to:
  /// **'选择窗口控制按钮的显示方式'**
  String get windowControlDisplayMode_4821;

  /// No description provided for @windowControlMode_4821.
  ///
  /// In zh, this message translates to:
  /// **'窗口控件模式'**
  String get windowControlMode_4821;

  /// No description provided for @windowDragHint_4721.
  ///
  /// In zh, this message translates to:
  /// **'您可以通过拖拽标题栏来移动这个窗口。'**
  String get windowDragHint_4721;

  /// No description provided for @windowDragHint_4821.
  ///
  /// In zh, this message translates to:
  /// **'拖拽标题栏可移动窗口'**
  String get windowDragHint_4821;

  /// No description provided for @windowHeight_4271.
  ///
  /// In zh, this message translates to:
  /// **'窗口高度'**
  String get windowHeight_4271;

  /// No description provided for @windowModeDescription_4821.
  ///
  /// In zh, this message translates to:
  /// **'在浮动窗口中显示 Markdown，适合快速预览'**
  String get windowModeDescription_4821;

  /// No description provided for @windowModeTitle_4821.
  ///
  /// In zh, this message translates to:
  /// **'1. 窗口模式'**
  String get windowModeTitle_4821;

  /// No description provided for @windowScalingFactorDebug.
  ///
  /// In zh, this message translates to:
  /// **'   - 窗口随动系数: {factor} (影响内容缩放)'**
  String windowScalingFactorDebug(Object factor);

  /// No description provided for @windowScalingFactorLabel.
  ///
  /// In zh, this message translates to:
  /// **'窗口大小随动系数: {value}'**
  String windowScalingFactorLabel(Object value);

  /// No description provided for @windowSettings_4821.
  ///
  /// In zh, this message translates to:
  /// **'窗口设置'**
  String get windowSettings_4821;

  /// No description provided for @windowSizeApplied.
  ///
  /// In zh, this message translates to:
  /// **'窗口大小已应用: {windowWidth}x{windowHeight}, 位置由系统决定, 最大化: {isMaximized}'**
  String windowSizeApplied(
    Object isMaximized,
    Object windowHeight,
    Object windowWidth,
  );

  /// No description provided for @windowSizeDescription_5739.
  ///
  /// In zh, this message translates to:
  /// **'窗口尺寸描述'**
  String get windowSizeDescription_5739;

  /// No description provided for @windowSizeError_7425.
  ///
  /// In zh, this message translates to:
  /// **'应用窗口大小失败: {e}'**
  String windowSizeError_7425(Object e);

  /// No description provided for @windowSizeResetToDefault_4821.
  ///
  /// In zh, this message translates to:
  /// **'窗口大小设置已重置为默认值'**
  String get windowSizeResetToDefault_4821;

  /// No description provided for @windowSizeSaveFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'窗口大小保存失败'**
  String get windowSizeSaveFailed_7281;

  /// No description provided for @windowSizeSaveRequestSent_7281.
  ///
  /// In zh, this message translates to:
  /// **'窗口大小保存请求已发送（非最大化状态）'**
  String get windowSizeSaveRequestSent_7281;

  /// No description provided for @windowSizeSaved.
  ///
  /// In zh, this message translates to:
  /// **'窗口大小已保存: {width}x{height}, 最大化: {maximized} (位置由系统决定)'**
  String windowSizeSaved(Object height, Object maximized, Object width);

  /// No description provided for @windowSizeUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新窗口大小失败: {e}'**
  String windowSizeUpdateFailed(Object e);

  /// No description provided for @windowStateOnExit.
  ///
  /// In zh, this message translates to:
  /// **'退出时读取窗口状态: {width}x{height}, 最大化: {maximized}'**
  String windowStateOnExit(Object height, Object maximized, Object width);

  /// No description provided for @windowStateSaveError.
  ///
  /// In zh, this message translates to:
  /// **'退出时保存窗口状态异常: {e}'**
  String windowStateSaveError(Object e);

  /// No description provided for @windowStateSaveFailed_7281.
  ///
  /// In zh, this message translates to:
  /// **'退出时窗口状态保存失败'**
  String get windowStateSaveFailed_7281;

  /// No description provided for @windowStateSavedSuccessfully_7281.
  ///
  /// In zh, this message translates to:
  /// **'退出时窗口状态保存成功'**
  String get windowStateSavedSuccessfully_7281;

  /// No description provided for @windowStayVisibleArea_4821.
  ///
  /// In zh, this message translates to:
  /// **'窗口会保持在屏幕可见区域内'**
  String get windowStayVisibleArea_4821;

  /// No description provided for @windowTitle_7281.
  ///
  /// In zh, this message translates to:
  /// **'窗口标题'**
  String get windowTitle_7281;

  /// No description provided for @windowTitle_7421.
  ///
  /// In zh, this message translates to:
  /// **'窗口标题'**
  String get windowTitle_7421;

  /// No description provided for @windowWidth_4821.
  ///
  /// In zh, this message translates to:
  /// **'窗口宽度'**
  String get windowWidth_4821;

  /// No description provided for @window_4824.
  ///
  /// In zh, this message translates to:
  /// **'窗户'**
  String get window_4824;

  /// No description provided for @windowsClipboardImageReadSuccess.
  ///
  /// In zh, this message translates to:
  /// **'Windows: 从剪贴板成功读取图片，大小: {bytesLength} 字节'**
  String windowsClipboardImageReadSuccess(Object bytesLength);

  /// No description provided for @windowsFeatures.
  ///
  /// In zh, this message translates to:
  /// **'Windows 功能：'**
  String get windowsFeatures;

  /// No description provided for @windowsNotifications.
  ///
  /// In zh, this message translates to:
  /// **'Windows 通知'**
  String get windowsNotifications;

  /// No description provided for @windowsPlatform.
  ///
  /// In zh, this message translates to:
  /// **'Windows 平台'**
  String get windowsPlatform;

  /// No description provided for @windowsPowerShellCopyFailed.
  ///
  /// In zh, this message translates to:
  /// **'Windows PowerShell 复制失败: {resultStderr}'**
  String windowsPowerShellCopyFailed(Object resultStderr);

  /// No description provided for @windowsSpecificFeatures.
  ///
  /// In zh, this message translates to:
  /// **'可以在此处实现 Windows 特定功能。'**
  String get windowsSpecificFeatures;

  /// No description provided for @wordCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'字数: {wordCount}'**
  String wordCountLabel(Object wordCount);

  /// No description provided for @workStatusEnded_7281.
  ///
  /// In zh, this message translates to:
  /// **'工作状态结束'**
  String get workStatusEnded_7281;

  /// No description provided for @workStatusStart_7285.
  ///
  /// In zh, this message translates to:
  /// **'工作状态开始: {description}'**
  String workStatusStart_7285(Object description);

  /// No description provided for @writePermission_4821.
  ///
  /// In zh, this message translates to:
  /// **'写入'**
  String get writePermission_4821;

  /// No description provided for @writePermission_7421.
  ///
  /// In zh, this message translates to:
  /// **'写入'**
  String get writePermission_7421;

  /// No description provided for @writeTextFileLog_7421.
  ///
  /// In zh, this message translates to:
  /// **'写入文本文件: {path}, 内容长度: {length}'**
  String writeTextFileLog_7421(Object length, Object path);

  /// No description provided for @xAxisLabel_7281.
  ///
  /// In zh, this message translates to:
  /// **'X轴: '**
  String get xAxisLabel_7281;

  /// No description provided for @xAxisOffset.
  ///
  /// In zh, this message translates to:
  /// **'X轴偏移: {percentage}%'**
  String xAxisOffset(Object percentage);

  /// No description provided for @xCoordinateLabel_4521.
  ///
  /// In zh, this message translates to:
  /// **'X坐标'**
  String get xCoordinateLabel_4521;

  /// No description provided for @xOffsetLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'X偏移'**
  String get xOffsetLabel_4821;

  /// No description provided for @xPerspectiveFactor.
  ///
  /// In zh, this message translates to:
  /// **'   - X方向透视因子: {factor}'**
  String xPerspectiveFactor(Object factor);

  /// No description provided for @yAxisLabel_7284.
  ///
  /// In zh, this message translates to:
  /// **'Y轴: '**
  String get yAxisLabel_7284;

  /// No description provided for @yAxisOffset.
  ///
  /// In zh, this message translates to:
  /// **'Y轴偏移: {percentage}%'**
  String yAxisOffset(Object percentage);

  /// No description provided for @yCoordinateLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'Y坐标'**
  String get yCoordinateLabel_4821;

  /// No description provided for @yOffsetLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'Y偏移'**
  String get yOffsetLabel_4821;

  /// No description provided for @yPerspectiveFactor.
  ///
  /// In zh, this message translates to:
  /// **'   - Y方向透视因子: {factor}'**
  String yPerspectiveFactor(Object factor);

  /// No description provided for @yes.
  ///
  /// In zh, this message translates to:
  /// **'是'**
  String get yes;

  /// No description provided for @yes_4287.
  ///
  /// In zh, this message translates to:
  /// **'是'**
  String get yes_4287;

  /// No description provided for @yes_4821.
  ///
  /// In zh, this message translates to:
  /// **'是'**
  String get yes_4821;

  /// No description provided for @zIndexLabel.
  ///
  /// In zh, this message translates to:
  /// **'Z层级: {zIndex}'**
  String zIndexLabel(Object zIndex);

  /// No description provided for @zLayerInspectorWithCount.
  ///
  /// In zh, this message translates to:
  /// **'Z层级检视器 ({count})'**
  String zLayerInspectorWithCount(Object count);

  /// No description provided for @zLevelInspector_1589.
  ///
  /// In zh, this message translates to:
  /// **'Z层级检视器'**
  String get zLevelInspector_1589;

  /// No description provided for @zLevelLabel_4521.
  ///
  /// In zh, this message translates to:
  /// **'Z层级'**
  String get zLevelLabel_4521;

  /// No description provided for @zLevel_4821.
  ///
  /// In zh, this message translates to:
  /// **'Z层级'**
  String get zLevel_4821;

  /// No description provided for @zipFileDescription_4978.
  ///
  /// In zh, this message translates to:
  /// **'ZIP文件应包含一个metadata.json文件，用于指定资源的目标位置'**
  String get zipFileDescription_4978;

  /// No description provided for @zipFileStructure_4977.
  ///
  /// In zh, this message translates to:
  /// **'ZIP文件结构'**
  String get zipFileStructure_4977;

  /// No description provided for @zipReadError_7281.
  ///
  /// In zh, this message translates to:
  /// **'无法读取ZIP文件内容'**
  String get zipReadError_7281;

  /// No description provided for @zoomFactor_4911.
  ///
  /// In zh, this message translates to:
  /// **'缩放因子'**
  String get zoomFactor_4911;

  /// No description provided for @zoomImage_4821.
  ///
  /// In zh, this message translates to:
  /// **'缩放图片'**
  String get zoomImage_4821;

  /// No description provided for @zoomInTooltip_4821.
  ///
  /// In zh, this message translates to:
  /// **'放大'**
  String get zoomInTooltip_4821;

  /// No description provided for @zoomLabel_4821.
  ///
  /// In zh, this message translates to:
  /// **'缩放'**
  String get zoomLabel_4821;

  /// No description provided for @zoomLevelRecorded.
  ///
  /// In zh, this message translates to:
  /// **'缩放级别已记录: {zoomLevel}'**
  String zoomLevelRecorded(Object zoomLevel);

  /// No description provided for @zoomOutTooltip_7281.
  ///
  /// In zh, this message translates to:
  /// **'缩小'**
  String get zoomOutTooltip_7281;

  /// No description provided for @zoomPercentage.
  ///
  /// In zh, this message translates to:
  /// **'缩放: {percentage}%'**
  String zoomPercentage(Object percentage);

  /// No description provided for @zoomSensitivity_4271.
  ///
  /// In zh, this message translates to:
  /// **'缩放敏感度'**
  String get zoomSensitivity_4271;

  /// No description provided for @zoom_4821.
  ///
  /// In zh, this message translates to:
  /// **'缩放'**
  String get zoom_4821;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
