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

  /// 主页设置
  final HomePagePreferences homePage;

  /// 地图编辑器设置
  final MapEditorPreferences mapEditor;

  /// 界面布局设置
  final LayoutPreferences layout;

  /// 工具设置
  final ToolPreferences tools;

  /// 扩展设置存储区域 (JSON格式存储临时偏好设置)
  final Map<String, dynamic> extensionSettings;

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
    required this.homePage,
    required this.mapEditor,
    required this.layout,
    required this.tools,
    this.extensionSettings = const {},
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
      homePage: HomePagePreferences.createDefault(),
      mapEditor: MapEditorPreferences.createDefault(),
      layout: LayoutPreferences.createDefault(),
      tools: ToolPreferences.createDefault(),
      extensionSettings: const {},
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
    HomePagePreferences? homePage,
    MapEditorPreferences? mapEditor,
    LayoutPreferences? layout,
    ToolPreferences? tools,
    Map<String, dynamic>? extensionSettings,
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
      homePage: homePage ?? this.homePage,
      mapEditor: mapEditor ?? this.mapEditor,
      layout: layout ?? this.layout,
      tools: tools ?? this.tools,
      extensionSettings: extensionSettings ?? this.extensionSettings,
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

  /// 是否启用画布主题适配
  final bool canvasThemeAdaptation;

  const ThemePreferences({
    required this.themeMode,
    required this.primaryColor,
    this.useMaterialYou = true,
    this.fontScale = 1.0,
    this.highContrast = false,
    this.canvasThemeAdaptation = false,
  });

  factory ThemePreferences.createDefault() {
    return const ThemePreferences(
      themeMode: 'system',
      primaryColor: 0xFF2196F3, // 蓝色
      useMaterialYou: true,
      fontScale: 1.0,
      highContrast: false,
      canvasThemeAdaptation: false,
    );
  }

  ThemePreferences copyWith({
    String? themeMode,
    int? primaryColor,
    bool? useMaterialYou,
    double? fontScale,
    bool? highContrast,
    bool? canvasThemeAdaptation,
  }) {
    return ThemePreferences(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      useMaterialYou: useMaterialYou ?? this.useMaterialYou,
      fontScale: fontScale ?? this.fontScale,
      highContrast: highContrast ?? this.highContrast,
      canvasThemeAdaptation: canvasThemeAdaptation ?? this.canvasThemeAdaptation,
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

  /// 是否启用扩展储存功能
  final bool enableExtensionStorage;

  /// 抽屉宽度设置
  final double drawerWidth;

  /// 是否自动保存窗口大小
  final bool autoSaveWindowSize;

  /// 窗口宽度（桌面平台）
  final double windowWidth;

  /// 窗口高度（桌面平台）
  final double windowHeight;

  /// 窗口最小宽度
  final double minWindowWidth;

  /// 窗口最小高度
  final double minWindowHeight;

  /// 窗口是否记住最大化状态
  final bool rememberMaximizedState;

  /// 窗口是否处于最大化状态
  final bool isMaximized;



  const LayoutPreferences({
    required this.panelCollapsedStates,
    required this.panelAutoCloseStates,
    this.sidebarWidth = 300.0,
    this.compactMode = false,
    this.showTooltips = true,
    this.animationDuration = 300,
    this.enableAnimations = true,
    this.autoRestorePanelStates = true,
    this.enableExtensionStorage = false,
    this.drawerWidth = 400.0,
    this.autoSaveWindowSize = true,
    this.windowWidth = 1280.0,
    this.windowHeight = 720.0,
    this.minWindowWidth = 800.0,
    this.minWindowHeight = 600.0,
    this.rememberMaximizedState = true,
    this.isMaximized = false
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
      enableExtensionStorage: false, // 明确设置默认值
      drawerWidth: 400.0,
      autoSaveWindowSize: true,
      windowWidth: 1280.0,
      windowHeight: 720.0,
      minWindowWidth: 800.0,
      minWindowHeight: 600.0,
      rememberMaximizedState: true,
      isMaximized: false
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
    bool? enableExtensionStorage,
    double? drawerWidth,
    bool? autoSaveWindowSize,
    double? windowWidth,
    double? windowHeight,
    double? minWindowWidth,
    double? minWindowHeight,
    bool? rememberMaximizedState,
    bool? isMaximized,

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
      enableExtensionStorage:
          enableExtensionStorage ?? this.enableExtensionStorage,
      drawerWidth: drawerWidth ?? this.drawerWidth,
      autoSaveWindowSize: autoSaveWindowSize ?? this.autoSaveWindowSize,
      windowWidth: windowWidth ?? this.windowWidth,
      windowHeight: windowHeight ?? this.windowHeight,
      minWindowWidth: minWindowWidth ?? this.minWindowWidth,
      minWindowHeight: minWindowHeight ?? this.minWindowHeight,
      rememberMaximizedState: rememberMaximizedState ?? this.rememberMaximizedState,
      isMaximized: isMaximized ?? this.isMaximized,
    );
  }

  factory LayoutPreferences.fromJson(Map<String, dynamic> json) =>
      _$LayoutPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$LayoutPreferencesToJson(this);
}

/// 主页偏好设置
@JsonSerializable()
class HomePagePreferences {
  /// 显示区域倍数
  final double displayAreaMultiplier;
  
  /// 基础缓冲区倍数
  final double baseBufferMultiplier;
  
  /// 透视缓冲调节系数
  final double perspectiveBufferFactor;
  
  /// 窗口大小随动系数
  final double windowScalingFactor;
  
  /// 基础网格间距
  final double baseNodeSpacing;
  
  /// 基础SVG渲染大小
  final double baseSvgRenderSize;
  
  /// 是否启用主题颜色滤镜
  final bool enableThemeColorFilter;
  
  /// 主页标题文字
  final String titleText;
  
  /// 标题字体大小倍数
  final double titleFontSizeMultiplier;
  
  /// 最近使用SVG记录数量
  final int recentSvgHistorySize;
  
  /// 摄像机移动速度
  final double cameraSpeed;
  
  /// 图标放大系数
  final double iconEnlargementFactor;

  const HomePagePreferences({
    this.displayAreaMultiplier = 1.5,
    this.baseBufferMultiplier = 1.5,
    this.perspectiveBufferFactor = 1.0,
    this.windowScalingFactor = 0.5,
    this.baseNodeSpacing = 200.0,
    this.baseSvgRenderSize = 150.0,
    this.enableThemeColorFilter = true,
    this.titleText = 'R6BOX',
    this.titleFontSizeMultiplier = 0.12,
    this.recentSvgHistorySize = 20,
    this.cameraSpeed = 50.0,
    this.iconEnlargementFactor = 1.0,
  });

  factory HomePagePreferences.createDefault() {
    return const HomePagePreferences();
  }

  HomePagePreferences copyWith({
    double? displayAreaMultiplier,
    double? baseBufferMultiplier,
    double? perspectiveBufferFactor,
    double? windowScalingFactor,
    double? baseNodeSpacing,
    double? baseSvgRenderSize,
    bool? enableThemeColorFilter,
    String? titleText,
    double? titleFontSizeMultiplier,
    int? recentSvgHistorySize,
    double? cameraSpeed,
    double? iconEnlargementFactor,
  }) {
    return HomePagePreferences(
      displayAreaMultiplier: displayAreaMultiplier ?? this.displayAreaMultiplier,
      baseBufferMultiplier: baseBufferMultiplier ?? this.baseBufferMultiplier,
      perspectiveBufferFactor: perspectiveBufferFactor ?? this.perspectiveBufferFactor,
      windowScalingFactor: windowScalingFactor ?? this.windowScalingFactor,
      baseNodeSpacing: baseNodeSpacing ?? this.baseNodeSpacing,
      baseSvgRenderSize: baseSvgRenderSize ?? this.baseSvgRenderSize,
      enableThemeColorFilter: enableThemeColorFilter ?? this.enableThemeColorFilter,
      titleText: titleText ?? this.titleText,
      titleFontSizeMultiplier: titleFontSizeMultiplier ?? this.titleFontSizeMultiplier,
      recentSvgHistorySize: recentSvgHistorySize ?? this.recentSvgHistorySize,
      cameraSpeed: cameraSpeed ?? this.cameraSpeed,
      iconEnlargementFactor: iconEnlargementFactor ?? this.iconEnlargementFactor,
    );
  }

  factory HomePagePreferences.fromJson(Map<String, dynamic> json) =>
      _$HomePagePreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$HomePagePreferencesToJson(this);
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

  /// 语音合成设置 (TTS)
  final TtsPreferences tts;

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
    required this.tts,
  });
  factory ToolPreferences.createDefault() {
    return ToolPreferences(
      recentColors: const [
        0xFF000000, // 黑色
        0xFFFF0000, // 红色
        0xFF00FF00, // 绿色
        0xFF0000FF, // 蓝色
        0xFFFFFF00, // 黄色
      ],
      customColors: const [
        0xFF9C27B0, // 紫色
        0xFFFF9800, // 橙色
        0xFF795548, // 棕色
      ],
      favoriteStrokeWidths: const [1.0, 2.0, 3.0, 5.0, 8.0],
      shortcuts: const {
        'undo': 'Ctrl+Z',
        'redo': 'Ctrl+Y',
        'save': 'Ctrl+S',
        'copy': 'Ctrl+C',
        'paste': 'Ctrl+V',
        'delete': 'Delete',
      },
      toolbarLayout: const [
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
      customTags: const [
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
      recentTags: const [],
      tts: TtsPreferences.createDefault(),
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
    TtsPreferences? tts,
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
      tts: tts ?? this.tts,
    );
  }

  factory ToolPreferences.fromJson(Map<String, dynamic> json) =>
      _$ToolPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$ToolPreferencesToJson(this);
}

/// 语音合成偏好设置 (TTS)
@JsonSerializable()
class TtsPreferences {
  /// 语言代码 (如 'zh-CN', 'en-US')
  final String? language;

  /// 语音速度 (0.0 - 1.0)
  final double speechRate;

  /// 音量 (0.0 - 1.0)
  final double volume;

  /// 音调 (0.5 - 2.0)
  final double pitch;

  /// 选择的语音 (语音ID)
  final Map<String, String>? voice;

  /// 是否启用TTS
  final bool enabled;

  const TtsPreferences({
    this.language,
    this.speechRate = 0.5,
    this.volume = 0.8,
    this.pitch = 1.0,
    this.voice,
    this.enabled = true,
  });

  /// 创建默认TTS设置
  factory TtsPreferences.createDefault() {
    return const TtsPreferences(
      language: 'zh-CN', // 默认中文
      speechRate: 0.5, // 中等语速
      volume: 0.8, // 80%音量
      pitch: 1.0, // 标准音调
      voice: null, // 使用默认语音
      enabled: true, // 默认启用
    );
  }

  TtsPreferences copyWith({
    String? language,
    double? speechRate,
    double? volume,
    double? pitch,
    Map<String, String>? voice,
    bool? enabled,
  }) {
    return TtsPreferences(
      language: language ?? this.language,
      speechRate: speechRate ?? this.speechRate,
      volume: volume ?? this.volume,
      pitch: pitch ?? this.pitch,
      voice: voice ?? this.voice,
      enabled: enabled ?? this.enabled,
    );
  }

  factory TtsPreferences.fromJson(Map<String, dynamic> json) =>
      _$TtsPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$TtsPreferencesToJson(this);
}
