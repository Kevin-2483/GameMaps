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
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'avatarPath': instance.avatarPath,
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
  defaultDrawingTool: json['defaultDrawingTool'] as String?,
  defaultColor: (json['defaultColor'] as num).toInt(),
  defaultStrokeWidth: (json['defaultStrokeWidth'] as num).toDouble(),
  defaultDensity: (json['defaultDensity'] as num).toDouble(),
  defaultCurvature: (json['defaultCurvature'] as num).toDouble(),
  autoSave: json['autoSave'] as bool? ?? true,
  autoSaveInterval: (json['autoSaveInterval'] as num?)?.toInt() ?? 5,
  undoHistoryLimit: (json['undoHistoryLimit'] as num?)?.toInt() ?? 20,
  showGrid: json['showGrid'] as bool? ?? false,
  gridSize: (json['gridSize'] as num?)?.toDouble() ?? 20.0,
  snapToGrid: json['snapToGrid'] as bool? ?? false,
  zoomSensitivity: (json['zoomSensitivity'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$MapEditorPreferencesToJson(
  MapEditorPreferences instance,
) => <String, dynamic>{
  'defaultDrawingTool': instance.defaultDrawingTool,
  'defaultColor': instance.defaultColor,
  'defaultStrokeWidth': instance.defaultStrokeWidth,
  'defaultDensity': instance.defaultDensity,
  'defaultCurvature': instance.defaultCurvature,
  'autoSave': instance.autoSave,
  'autoSaveInterval': instance.autoSaveInterval,
  'undoHistoryLimit': instance.undoHistoryLimit,
  'showGrid': instance.showGrid,
  'gridSize': instance.gridSize,
  'snapToGrid': instance.snapToGrid,
  'zoomSensitivity': instance.zoomSensitivity,
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
    };

ToolPreferences _$ToolPreferencesFromJson(Map<String, dynamic> json) =>
    ToolPreferences(
      recentColors: (json['recentColors'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      favoriteStrokeWidths: (json['favoriteStrokeWidths'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      shortcuts: Map<String, String>.from(json['shortcuts'] as Map),
      toolbarLayout: (json['toolbarLayout'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      showAdvancedTools: json['showAdvancedTools'] as bool? ?? false,
    );

Map<String, dynamic> _$ToolPreferencesToJson(ToolPreferences instance) =>
    <String, dynamic>{
      'recentColors': instance.recentColors,
      'favoriteStrokeWidths': instance.favoriteStrokeWidths,
      'shortcuts': instance.shortcuts,
      'toolbarLayout': instance.toolbarLayout,
      'showAdvancedTools': instance.showAdvancedTools,
    };
