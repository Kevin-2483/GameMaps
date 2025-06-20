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
      avatarData: const Uint8ListConverter().fromJson(
        json['avatarData'] as String?,
      ),
      theme: ThemePreferences.fromJson(json['theme'] as Map<String, dynamic>),
      mapEditor: MapEditorPreferences.fromJson(
        json['mapEditor'] as Map<String, dynamic>,
      ),
      layout: LayoutPreferences.fromJson(
        json['layout'] as Map<String, dynamic>,
      ),
      tools: ToolPreferences.fromJson(json['tools'] as Map<String, dynamic>),
      locale: json['locale'] as String? ?? 'zh_CN',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLoginAt:
          json['lastLoginAt'] == null
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
      'mapEditor': instance.mapEditor,
      'layout': instance.layout,
      'tools': instance.tools,
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
    );

Map<String, dynamic> _$ThemePreferencesToJson(ThemePreferences instance) =>
    <String, dynamic>{
      'themeMode': instance.themeMode,
      'primaryColor': instance.primaryColor,
      'useMaterialYou': instance.useMaterialYou,
      'fontScale': instance.fontScale,
      'highContrast': instance.highContrast,
    };

MapEditorPreferences _$MapEditorPreferencesFromJson(
  Map<String, dynamic> json,
) => MapEditorPreferences(
  undoHistoryLimit: (json['undoHistoryLimit'] as num?)?.toInt() ?? 20,
  zoomSensitivity: (json['zoomSensitivity'] as num?)?.toDouble() ?? 1.0,
  backgroundPattern:
      $enumDecodeNullable(
        _$BackgroundPatternEnumMap,
        json['backgroundPattern'],
      ) ??
      BackgroundPattern.checkerboard,
  canvasBoundaryMargin:
      (json['canvasBoundaryMargin'] as num?)?.toDouble() ?? 200.0,
);

Map<String, dynamic> _$MapEditorPreferencesToJson(
  MapEditorPreferences instance,
) => <String, dynamic>{
  'undoHistoryLimit': instance.undoHistoryLimit,
  'zoomSensitivity': instance.zoomSensitivity,
  'backgroundPattern': _$BackgroundPatternEnumMap[instance.backgroundPattern]!,
  'canvasBoundaryMargin': instance.canvasBoundaryMargin,
};

const _$BackgroundPatternEnumMap = {
  BackgroundPattern.blank: 'blank',
  BackgroundPattern.grid: 'grid',
  BackgroundPattern.checkerboard: 'checkerboard',
};

LayoutPreferences _$LayoutPreferencesFromJson(Map<String, dynamic> json) =>
    LayoutPreferences(
      panelCollapsedStates: Map<String, bool>.from(
        json['panelCollapsedStates'] as Map,
      ),
      panelAutoCloseStates: Map<String, bool>.from(
        json['panelAutoCloseStates'] as Map,
      ),
      sidebarWidth: (json['sidebarWidth'] as num?)?.toDouble() ?? 300.0,
      compactMode: json['compactMode'] as bool? ?? false,
      showTooltips: json['showTooltips'] as bool? ?? true,
      animationDuration: (json['animationDuration'] as num?)?.toInt() ?? 300,
      enableAnimations: json['enableAnimations'] as bool? ?? true,
      autoRestorePanelStates: json['autoRestorePanelStates'] as bool? ?? true,
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
    };

ToolPreferences _$ToolPreferencesFromJson(Map<String, dynamic> json) =>
    ToolPreferences(
      recentColors:
          (json['recentColors'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
      customColors:
          (json['customColors'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
      favoriteStrokeWidths:
          (json['favoriteStrokeWidths'] as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList(),
      shortcuts: Map<String, String>.from(json['shortcuts'] as Map),
      toolbarLayout:
          (json['toolbarLayout'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      showAdvancedTools: json['showAdvancedTools'] as bool? ?? false,
      handleSize: (json['handleSize'] as num?)?.toDouble() ?? 8.0,
      customTags:
          (json['customTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      recentTags:
          (json['recentTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ToolPreferencesToJson(ToolPreferences instance) =>
    <String, dynamic>{
      'recentColors': instance.recentColors,
      'customColors': instance.customColors,
      'favoriteStrokeWidths': instance.favoriteStrokeWidths,
      'shortcuts': instance.shortcuts,
      'toolbarLayout': instance.toolbarLayout,
      'showAdvancedTools': instance.showAdvancedTools,
      'handleSize': instance.handleSize,
      'customTags': instance.customTags,
      'recentTags': instance.recentTags,
    };
