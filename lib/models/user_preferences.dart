import 'dart:convert';
import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';

part 'user_preferences.g.dart';

/// Uint8List 转换器，用于 JSON 序列化
class Uint8ListConverter implements JsonConverter<Uint8List?, String?> {
  const Uint8ListConverter();

  @override
  Uint8List? fromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    return base64Decode(json);
  }

  @override
  String? toJson(Uint8List? object) {
    if (object == null || object.isEmpty) return null;
    return base64Encode(object);
  }
}

/// 用户偏好设置数据模型
@JsonSerializable()
class UserPreferences {
  /// 用户ID（可选，用于多用户支持）
  final String? userId;

  /// 用户显示名称
  final String displayName;

  /// 用户头像URL或路径
  final String? avatarPath;

  /// 用户头像二进制数据
  @Uint8ListConverter()
  final Uint8List? avatarData;

  /// 主题设置
  final ThemePreferences theme;

  /// 地图编辑器设置
  final MapEditorPreferences mapEditor;

  /// 界面布局设置
  final LayoutPreferences layout;

  /// 工具设置
  final ToolPreferences tools;

  /// 语言设置
  final String locale;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 最后登录时间
  final DateTime? lastLoginAt;
  const UserPreferences({
    this.userId,
    required this.displayName,
    this.avatarPath,
    this.avatarData,
    required this.theme,
    required this.mapEditor,
    required this.layout,
    required this.tools,
    this.locale = 'zh_CN',
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  /// 创建默认用户偏好设置
  factory UserPreferences.createDefault({String? userId, String? displayName}) {
    final now = DateTime.now();
    return UserPreferences(
      userId: userId,
      displayName: displayName ?? '用户',
      theme: ThemePreferences.createDefault(),
      mapEditor: MapEditorPreferences.createDefault(),
      layout: LayoutPreferences.createDefault(),
      tools: ToolPreferences.createDefault(),
      createdAt: now,
      updatedAt: now,
      lastLoginAt: now,
    );
  }

  /// 更新用户偏好设置
  UserPreferences copyWith({
    String? userId,
    String? displayName,
    String? avatarPath,
    Uint8List? avatarData,
    ThemePreferences? theme,
    MapEditorPreferences? mapEditor,
    LayoutPreferences? layout,
    ToolPreferences? tools,
    String? locale,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarData: avatarData ?? this.avatarData,
      theme: theme ?? this.theme,
      mapEditor: mapEditor ?? this.mapEditor,
      layout: layout ?? this.layout,
      tools: tools ?? this.tools,
      locale: locale ?? this.locale,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// 从JSON创建实例
  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
}

/// 主题偏好设置
@JsonSerializable()
class ThemePreferences {
  /// 主题模式：system, light, dark
  final String themeMode;

  /// 主色调
  final int primaryColor;

  /// 是否使用系统颜色
  final bool useMaterialYou;

  /// 字体大小缩放
  final double fontScale;

  /// 是否启用高对比度
  final bool highContrast;

  const ThemePreferences({
    required this.themeMode,
    required this.primaryColor,
    this.useMaterialYou = true,
    this.fontScale = 1.0,
    this.highContrast = false,
  });

  factory ThemePreferences.createDefault() {
    return const ThemePreferences(
      themeMode: 'system',
      primaryColor: 0xFF2196F3, // 蓝色
      useMaterialYou: true,
      fontScale: 1.0,
      highContrast: false,
    );
  }

  ThemePreferences copyWith({
    String? themeMode,
    int? primaryColor,
    bool? useMaterialYou,
    double? fontScale,
    bool? highContrast,
  }) {
    return ThemePreferences(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      useMaterialYou: useMaterialYou ?? this.useMaterialYou,
      fontScale: fontScale ?? this.fontScale,
      highContrast: highContrast ?? this.highContrast,
    );
  }

  factory ThemePreferences.fromJson(Map<String, dynamic> json) =>
      _$ThemePreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$ThemePreferencesToJson(this);
}

/// 背景图案类型
enum BackgroundPattern {
  blank, // 空白
  grid, // 网格
  checkerboard, // 棋盘格
}

/// 地图编辑器偏好设置
@JsonSerializable()
class MapEditorPreferences {
  /// 撤销历史记录数量
  final int undoHistoryLimit;

  /// 缩放敏感度
  final double zoomSensitivity;

  /// 背景图案类型
  final BackgroundPattern backgroundPattern;

  /// 画布边距大小
  final double canvasBoundaryMargin;

  const MapEditorPreferences({
    this.undoHistoryLimit = 20,
    this.zoomSensitivity = 1.0,
    this.backgroundPattern = BackgroundPattern.checkerboard,
    this.canvasBoundaryMargin = 200.0,
  });
  factory MapEditorPreferences.createDefault() {
    return const MapEditorPreferences(
      undoHistoryLimit: 20,
      zoomSensitivity: 1.0,
      backgroundPattern: BackgroundPattern.checkerboard,
      canvasBoundaryMargin: 200.0,
    );
  }
  MapEditorPreferences copyWith({
    int? undoHistoryLimit,
    double? zoomSensitivity,
    BackgroundPattern? backgroundPattern,
    double? canvasBoundaryMargin,
  }) {
    return MapEditorPreferences(
      undoHistoryLimit: undoHistoryLimit ?? this.undoHistoryLimit,
      zoomSensitivity: zoomSensitivity ?? this.zoomSensitivity,
      backgroundPattern: backgroundPattern ?? this.backgroundPattern,
      canvasBoundaryMargin: canvasBoundaryMargin ?? this.canvasBoundaryMargin,
    );
  }

  factory MapEditorPreferences.fromJson(Map<String, dynamic> json) =>
      _$MapEditorPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$MapEditorPreferencesToJson(this);
}

/// 界面布局偏好设置
@JsonSerializable()
class LayoutPreferences {
  /// 工具栏折叠状态
  final Map<String, bool> panelCollapsedStates;

  /// 工具栏自动关闭设置
  final Map<String, bool> panelAutoCloseStates;

  /// 侧边栏宽度
  final double sidebarWidth;

  /// 是否使用紧凑模式
  final bool compactMode;

  /// 是否显示工具提示
  final bool showTooltips;

  /// 动画持续时间
  final int animationDuration;

  /// 是否启用动画
  final bool enableAnimations;

  /// 是否自动恢复面板状态
  final bool autoRestorePanelStates;

  const LayoutPreferences({
    required this.panelCollapsedStates,
    required this.panelAutoCloseStates,
    this.sidebarWidth = 300.0,
    this.compactMode = false,
    this.showTooltips = true,
    this.animationDuration = 300,
    this.enableAnimations = true,
    this.autoRestorePanelStates = true,
  });
  factory LayoutPreferences.createDefault() {
    return const LayoutPreferences(
      panelCollapsedStates: {
        'drawing': false,
        'layer': false,
        'legend': false,
        'stickyNote': false,
        'script': false,
        'sidebar': false,
      },
      panelAutoCloseStates: {
        'drawing': true,
        'layer': true,
        'legend': true,
        'stickyNote': true,
        'script': true,
      },
      sidebarWidth: 300.0,
      compactMode: false,
      showTooltips: true,
      animationDuration: 300,
      enableAnimations: true,
      autoRestorePanelStates: true,
    );
  }
  LayoutPreferences copyWith({
    Map<String, bool>? panelCollapsedStates,
    Map<String, bool>? panelAutoCloseStates,
    double? sidebarWidth,
    bool? compactMode,
    bool? showTooltips,
    int? animationDuration,
    bool? enableAnimations,
    bool? autoRestorePanelStates,
  }) {
    return LayoutPreferences(
      panelCollapsedStates: panelCollapsedStates ?? this.panelCollapsedStates,
      panelAutoCloseStates: panelAutoCloseStates ?? this.panelAutoCloseStates,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      compactMode: compactMode ?? this.compactMode,
      showTooltips: showTooltips ?? this.showTooltips,
      animationDuration: animationDuration ?? this.animationDuration,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      autoRestorePanelStates:
          autoRestorePanelStates ?? this.autoRestorePanelStates,
    );
  }

  factory LayoutPreferences.fromJson(Map<String, dynamic> json) =>
      _$LayoutPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$LayoutPreferencesToJson(this);
}

/// 工具偏好设置
@JsonSerializable()
class ToolPreferences {
  /// 最近使用的颜色
  final List<int> recentColors;

  /// 自定义颜色
  final List<int> customColors;

  /// 常用线条宽度
  final List<double> favoriteStrokeWidths;

  /// 快捷键设置
  final Map<String, String> shortcuts;

  /// 工具栏自定义布局
  final List<String> toolbarLayout;

  /// 是否显示高级工具
  final bool showAdvancedTools;

  /// 拖动控制柄大小
  final double handleSize;

  /// 自定义标签列表
  final List<String> customTags;

  /// 最近使用的标签
  final List<String> recentTags;

  const ToolPreferences({
    required this.recentColors,
    required this.customColors,
    required this.favoriteStrokeWidths,
    required this.shortcuts,
    required this.toolbarLayout,
    this.showAdvancedTools = false,
    this.handleSize = 8.0,
    this.customTags = const [],
    this.recentTags = const [],
  });
  factory ToolPreferences.createDefault() {
    return const ToolPreferences(
      recentColors: [
        0xFF000000, // 黑色
        0xFFFF0000, // 红色
        0xFF00FF00, // 绿色
        0xFF0000FF, // 蓝色
        0xFFFFFF00, // 黄色
      ],
      customColors: [
        0xFF9C27B0, // 紫色
        0xFFFF9800, // 橙色
        0xFF795548, // 棕色
      ],
      favoriteStrokeWidths: [1.0, 2.0, 3.0, 5.0, 8.0],
      shortcuts: {
        'undo': 'Ctrl+Z',
        'redo': 'Ctrl+Y',
        'save': 'Ctrl+S',
        'copy': 'Ctrl+C',
        'paste': 'Ctrl+V',
        'delete': 'Delete',
      },
      toolbarLayout: [
        'line',
        'dashedLine',
        'arrow',
        'rectangle',
        'hollowRectangle',
        'diagonalLines',
        'crossLines',
        'dotGrid',
        'freeDrawing',
        'text',
        'eraser',
        'imageArea',
      ],
      showAdvancedTools: false,
      handleSize: 8.0,
      customTags: [
        '重要',
        '紧急',
        '完成',
        '临时',
        '备注',
        '标记',
        '高优先级',
        '低优先级',
        '计划',
        '想法',
        '参考',
      ],
      recentTags: [],
    );
  }
  ToolPreferences copyWith({
    List<int>? recentColors,
    List<int>? customColors,
    List<double>? favoriteStrokeWidths,
    Map<String, String>? shortcuts,
    List<String>? toolbarLayout,
    bool? showAdvancedTools,
    double? handleSize,
    List<String>? customTags,
    List<String>? recentTags,
  }) {
    return ToolPreferences(
      recentColors: recentColors ?? this.recentColors,
      customColors: customColors ?? this.customColors,
      favoriteStrokeWidths: favoriteStrokeWidths ?? this.favoriteStrokeWidths,
      shortcuts: shortcuts ?? this.shortcuts,
      toolbarLayout: toolbarLayout ?? this.toolbarLayout,
      showAdvancedTools: showAdvancedTools ?? this.showAdvancedTools,
      handleSize: handleSize ?? this.handleSize,
      customTags: customTags ?? this.customTags,
      recentTags: recentTags ?? this.recentTags,
    );
  }

  factory ToolPreferences.fromJson(Map<String, dynamic> json) =>
      _$ToolPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$ToolPreferencesToJson(this);
}
