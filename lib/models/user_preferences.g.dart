// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      userId: json['userId'] as String?,
      displayName: json['displayName'] as String,
      avatarPath: json['avatarPath'] as String?,
      avatarData:
          const Uint8ListConverter().fromJson(json['avatarData'] as String?),
      theme: ThemePreferences.fromJson(json['theme'] as Map<String, dynamic>),
      homePage: HomePagePreferences.fromJson(
          json['homePage'] as Map<String, dynamic>),
      mapEditor: MapEditorPreferences.fromJson(
          json['mapEditor'] as Map<String, dynamic>),
      layout:
          LayoutPreferences.fromJson(json['layout'] as Map<String, dynamic>),
      tools: ToolPreferences.fromJson(json['tools'] as Map<String, dynamic>),
      extensionSettings:
          json['extensionSettings'] as Map<String, dynamic>? ?? const {},
      locale: json['locale'] as String? ?? 'zh_CN',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'avatarPath': instance.avatarPath,
      'avatarData': const Uint8ListConverter().toJson(instance.avatarData),
      'theme': instance.theme,
      'homePage': instance.homePage,
      'mapEditor': instance.mapEditor,
      'layout': instance.layout,
      'tools': instance.tools,
      'extensionSettings': instance.extensionSettings,
      'locale': instance.locale,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
    };

ThemePreferences _$ThemePreferencesFromJson(Map<String, dynamic> json) =>
    ThemePreferences(
      themeMode: json['themeMode'] as String,
      primaryColor: (json['primaryColor'] as num).toInt(),
      useMaterialYou: json['useMaterialYou'] as bool? ?? true,
      fontScale: (json['fontScale'] as num?)?.toDouble() ?? 1.0,
      highContrast: json['highContrast'] as bool? ?? false,
      canvasThemeAdaptation: json['canvasThemeAdaptation'] as bool? ?? false,
    );

Map<String, dynamic> _$ThemePreferencesToJson(ThemePreferences instance) =>
    <String, dynamic>{
      'themeMode': instance.themeMode,
      'primaryColor': instance.primaryColor,
      'useMaterialYou': instance.useMaterialYou,
      'fontScale': instance.fontScale,
      'highContrast': instance.highContrast,
      'canvasThemeAdaptation': instance.canvasThemeAdaptation,
    };

MapEditorPreferences _$MapEditorPreferencesFromJson(
        Map<String, dynamic> json) =>
    MapEditorPreferences(
      undoHistoryLimit: (json['undoHistoryLimit'] as num?)?.toInt() ?? 20,
      zoomSensitivity: (json['zoomSensitivity'] as num?)?.toDouble() ?? 1.0,
      backgroundPattern: $enumDecodeNullable(
              _$BackgroundPatternEnumMap, json['backgroundPattern']) ??
          BackgroundPattern.checkerboard,
      canvasBoundaryMargin:
          (json['canvasBoundaryMargin'] as num?)?.toDouble() ?? 200.0,
      radialMenuButton: (json['radialMenuButton'] as num?)?.toInt() ?? 2,
      radialMenuRadius: (json['radialMenuRadius'] as num?)?.toDouble() ?? 120.0,
      radialMenuCenterRadius:
          (json['radialMenuCenterRadius'] as num?)?.toDouble() ?? 30.0,
      radialMenuBackgroundOpacity:
          (json['radialMenuBackgroundOpacity'] as num?)?.toDouble() ?? 0.8,
      radialMenuObjectOpacity:
          (json['radialMenuObjectOpacity'] as num?)?.toDouble() ?? 0.9,
      radialMenuReturnDelay:
          (json['radialMenuReturnDelay'] as num?)?.toInt() ?? 100,
      radialMenuAnimationDuration:
          (json['radialMenuAnimationDuration'] as num?)?.toInt() ?? 300,
      radialMenuSubMenuDelay:
          (json['radialMenuSubMenuDelay'] as num?)?.toInt() ?? 50,
      shortcuts: (json['shortcuts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k, (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          const <String, List<String>>{},
      autoSelectLastLayerInGroup:
          json['autoSelectLastLayerInGroup'] as bool? ?? false,
      defaultLegendSize: (json['defaultLegendSize'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$MapEditorPreferencesToJson(
        MapEditorPreferences instance) =>
    <String, dynamic>{
      'undoHistoryLimit': instance.undoHistoryLimit,
      'zoomSensitivity': instance.zoomSensitivity,
      'backgroundPattern':
          _$BackgroundPatternEnumMap[instance.backgroundPattern]!,
      'canvasBoundaryMargin': instance.canvasBoundaryMargin,
      'radialMenuButton': instance.radialMenuButton,
      'radialMenuRadius': instance.radialMenuRadius,
      'radialMenuCenterRadius': instance.radialMenuCenterRadius,
      'radialMenuBackgroundOpacity': instance.radialMenuBackgroundOpacity,
      'radialMenuObjectOpacity': instance.radialMenuObjectOpacity,
      'radialMenuReturnDelay': instance.radialMenuReturnDelay,
      'radialMenuAnimationDuration': instance.radialMenuAnimationDuration,
      'radialMenuSubMenuDelay': instance.radialMenuSubMenuDelay,
      'shortcuts': instance.shortcuts,
      'autoSelectLastLayerInGroup': instance.autoSelectLastLayerInGroup,
      'defaultLegendSize': instance.defaultLegendSize,
    };

const _$BackgroundPatternEnumMap = {
  BackgroundPattern.blank: 'blank',
  BackgroundPattern.grid: 'grid',
  BackgroundPattern.checkerboard: 'checkerboard',
};

LayoutPreferences _$LayoutPreferencesFromJson(Map<String, dynamic> json) =>
    LayoutPreferences(
      panelCollapsedStates:
          Map<String, bool>.from(json['panelCollapsedStates'] as Map),
      panelAutoCloseStates:
          Map<String, bool>.from(json['panelAutoCloseStates'] as Map),
      sidebarWidth: (json['sidebarWidth'] as num?)?.toDouble() ?? 300.0,
      compactMode: json['compactMode'] as bool? ?? false,
      showTooltips: json['showTooltips'] as bool? ?? true,
      animationDuration: (json['animationDuration'] as num?)?.toInt() ?? 300,
      enableAnimations: json['enableAnimations'] as bool? ?? true,
      autoRestorePanelStates: json['autoRestorePanelStates'] as bool? ?? true,
      enableExtensionStorage: json['enableExtensionStorage'] as bool? ?? false,
      drawerWidth: (json['drawerWidth'] as num?)?.toDouble() ?? 400.0,
      autoSaveWindowSize: json['autoSaveWindowSize'] as bool? ?? true,
      windowWidth: (json['windowWidth'] as num?)?.toDouble() ?? 1280.0,
      windowHeight: (json['windowHeight'] as num?)?.toDouble() ?? 720.0,
      minWindowWidth: (json['minWindowWidth'] as num?)?.toDouble() ?? 800.0,
      minWindowHeight: (json['minWindowHeight'] as num?)?.toDouble() ?? 600.0,
      rememberMaximizedState: json['rememberMaximizedState'] as bool? ?? true,
      isMaximized: json['isMaximized'] as bool? ?? false,
    );

Map<String, dynamic> _$LayoutPreferencesToJson(LayoutPreferences instance) =>
    <String, dynamic>{
      'panelCollapsedStates': instance.panelCollapsedStates,
      'panelAutoCloseStates': instance.panelAutoCloseStates,
      'sidebarWidth': instance.sidebarWidth,
      'compactMode': instance.compactMode,
      'showTooltips': instance.showTooltips,
      'animationDuration': instance.animationDuration,
      'enableAnimations': instance.enableAnimations,
      'autoRestorePanelStates': instance.autoRestorePanelStates,
      'enableExtensionStorage': instance.enableExtensionStorage,
      'drawerWidth': instance.drawerWidth,
      'autoSaveWindowSize': instance.autoSaveWindowSize,
      'windowWidth': instance.windowWidth,
      'windowHeight': instance.windowHeight,
      'minWindowWidth': instance.minWindowWidth,
      'minWindowHeight': instance.minWindowHeight,
      'rememberMaximizedState': instance.rememberMaximizedState,
      'isMaximized': instance.isMaximized,
    };

HomePagePreferences _$HomePagePreferencesFromJson(Map<String, dynamic> json) =>
    HomePagePreferences(
      displayAreaMultiplier:
          (json['displayAreaMultiplier'] as num?)?.toDouble() ?? 1.5,
      baseBufferMultiplier:
          (json['baseBufferMultiplier'] as num?)?.toDouble() ?? 1.5,
      perspectiveBufferFactor:
          (json['perspectiveBufferFactor'] as num?)?.toDouble() ?? 1.0,
      windowScalingFactor:
          (json['windowScalingFactor'] as num?)?.toDouble() ?? 0.5,
      baseNodeSpacing: (json['baseNodeSpacing'] as num?)?.toDouble() ?? 300.0,
      baseSvgRenderSize:
          (json['baseSvgRenderSize'] as num?)?.toDouble() ?? 200.0,
      enableThemeColorFilter: json['enableThemeColorFilter'] as bool? ?? true,
      titleText: json['titleText'] as String? ?? 'R6BOX',
      titleFontSizeMultiplier:
          (json['titleFontSizeMultiplier'] as num?)?.toDouble() ?? 0.12,
      recentSvgHistorySize:
          (json['recentSvgHistorySize'] as num?)?.toInt() ?? 20,
      cameraSpeed: (json['cameraSpeed'] as num?)?.toDouble() ?? 50.0,
      iconEnlargementFactor:
          (json['iconEnlargementFactor'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$HomePagePreferencesToJson(
        HomePagePreferences instance) =>
    <String, dynamic>{
      'displayAreaMultiplier': instance.displayAreaMultiplier,
      'baseBufferMultiplier': instance.baseBufferMultiplier,
      'perspectiveBufferFactor': instance.perspectiveBufferFactor,
      'windowScalingFactor': instance.windowScalingFactor,
      'baseNodeSpacing': instance.baseNodeSpacing,
      'baseSvgRenderSize': instance.baseSvgRenderSize,
      'enableThemeColorFilter': instance.enableThemeColorFilter,
      'titleText': instance.titleText,
      'titleFontSizeMultiplier': instance.titleFontSizeMultiplier,
      'recentSvgHistorySize': instance.recentSvgHistorySize,
      'cameraSpeed': instance.cameraSpeed,
      'iconEnlargementFactor': instance.iconEnlargementFactor,
    };

ToolPreferences _$ToolPreferencesFromJson(Map<String, dynamic> json) =>
    ToolPreferences(
      recentColors: (json['recentColors'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      customColors: (json['customColors'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      favoriteStrokeWidths: (json['favoriteStrokeWidths'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      toolbarLayout: (json['toolbarLayout'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      showAdvancedTools: json['showAdvancedTools'] as bool? ?? false,
      handleSize: (json['handleSize'] as num?)?.toDouble() ?? 8.0,
      customTags: (json['customTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      recentTags: (json['recentTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tts: TtsPreferences.fromJson(json['tts'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ToolPreferencesToJson(ToolPreferences instance) =>
    <String, dynamic>{
      'recentColors': instance.recentColors,
      'customColors': instance.customColors,
      'favoriteStrokeWidths': instance.favoriteStrokeWidths,
      'toolbarLayout': instance.toolbarLayout,
      'showAdvancedTools': instance.showAdvancedTools,
      'handleSize': instance.handleSize,
      'customTags': instance.customTags,
      'recentTags': instance.recentTags,
      'tts': instance.tts,
    };

TtsPreferences _$TtsPreferencesFromJson(Map<String, dynamic> json) =>
    TtsPreferences(
      language: json['language'] as String?,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? 0.5,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.8,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
      voice: (json['voice'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      enabled: json['enabled'] as bool? ?? true,
    );

Map<String, dynamic> _$TtsPreferencesToJson(TtsPreferences instance) =>
    <String, dynamic>{
      'language': instance.language,
      'speechRate': instance.speechRate,
      'volume': instance.volume,
      'pitch': instance.pitch,
      'voice': instance.voice,
      'enabled': instance.enabled,
    };
