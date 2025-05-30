import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user_preferences.dart';
import '../services/user_preferences_service.dart';

/// 用户偏好设置状态管理Provider
class UserPreferencesProvider extends ChangeNotifier {
  final UserPreferencesService _service = UserPreferencesService();
  
  UserPreferences? _currentPreferences;
  bool _isLoading = false;
  String? _error;

  /// 当前用户偏好设置
  UserPreferences? get currentPreferences => _currentPreferences;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 错误信息
  String? get error => _error;

  /// 是否已初始化
  bool get isInitialized => _currentPreferences != null;

  /// 主题偏好设置
  ThemePreferences get theme => 
      _currentPreferences?.theme ?? ThemePreferences.createDefault();

  /// 地图编辑器偏好设置
  MapEditorPreferences get mapEditor => 
      _currentPreferences?.mapEditor ?? MapEditorPreferences.createDefault();

  /// 界面布局偏好设置
  LayoutPreferences get layout => 
      _currentPreferences?.layout ?? LayoutPreferences.createDefault();

  /// 工具偏好设置
  ToolPreferences get tools => 
      _currentPreferences?.tools ?? ToolPreferences.createDefault();

  /// 语言设置
  String get locale => _currentPreferences?.locale ?? 'zh_CN';

  /// 用户显示名称
  String get displayName => _currentPreferences?.displayName ?? '用户';

  /// 用户头像路径
  String? get avatarPath => _currentPreferences?.avatarPath;

  /// 初始化用户偏好设置
  Future<void> initialize() async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      await _service.initialize();
      _currentPreferences = await _service.getCurrentPreferences();
      
      if (kDebugMode) {
        print('用户偏好设置初始化完成: ${_currentPreferences?.displayName}');
      }
    } catch (e) {
      _setError('初始化用户偏好设置失败: ${e.toString()}');
      if (kDebugMode) {
        print('初始化用户偏好设置失败: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 更新主题设置
  Future<void> updateTheme({
    String? themeMode,
    int? primaryColor,
    bool? useMaterialYou,
    double? fontScale,
    bool? highContrast,
  }) async {
    if (_currentPreferences == null) return;

    try {
      final updatedTheme = theme.copyWith(
        themeMode: themeMode,
        primaryColor: primaryColor,
        useMaterialYou: useMaterialYou,
        fontScale: fontScale,
        highContrast: highContrast,
      );

      await _service.updateTheme(updatedTheme);
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('更新主题设置失败: ${e.toString()}');
    }
  }

  /// 更新地图编辑器设置
  Future<void> updateMapEditor({
    String? defaultDrawingTool,
    int? defaultColor,
    double? defaultStrokeWidth,
    double? defaultDensity,
    double? defaultCurvature,
    bool? autoSave,
    int? autoSaveInterval,
    int? undoHistoryLimit,
    bool? showGrid,
    double? gridSize,
    bool? snapToGrid,
    double? zoomSensitivity,
  }) async {
    if (_currentPreferences == null) return;

    try {
      final updatedMapEditor = mapEditor.copyWith(
        defaultDrawingTool: defaultDrawingTool,
        defaultColor: defaultColor,
        defaultStrokeWidth: defaultStrokeWidth,
        defaultDensity: defaultDensity,
        defaultCurvature: defaultCurvature,
        autoSave: autoSave,
        autoSaveInterval: autoSaveInterval,
        undoHistoryLimit: undoHistoryLimit,
        showGrid: showGrid,
        gridSize: gridSize,
        snapToGrid: snapToGrid,
        zoomSensitivity: zoomSensitivity,
      );

      await _service.updateMapEditor(updatedMapEditor);
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('更新地图编辑器设置失败: ${e.toString()}');
    }
  }

  /// 更新界面布局设置
  Future<void> updateLayout({
    Map<String, bool>? panelCollapsedStates,
    Map<String, bool>? panelAutoCloseStates,
    double? sidebarWidth,
    bool? compactMode,
    bool? showTooltips,
    int? animationDuration,
    bool? enableAnimations,
  }) async {
    if (_currentPreferences == null) return;

    try {
      final updatedLayout = layout.copyWith(
        panelCollapsedStates: panelCollapsedStates,
        panelAutoCloseStates: panelAutoCloseStates,
        sidebarWidth: sidebarWidth,
        compactMode: compactMode,
        showTooltips: showTooltips,
        animationDuration: animationDuration,
        enableAnimations: enableAnimations,
      );

      await _service.updateLayout(updatedLayout);
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('更新界面布局设置失败: ${e.toString()}');
    }
  }

  /// 更新工具设置
  Future<void> updateTools({
    List<int>? recentColors,
    List<double>? favoriteStrokeWidths,
    Map<String, String>? shortcuts,
    List<String>? toolbarLayout,
    bool? showAdvancedTools,
  }) async {
    if (_currentPreferences == null) return;

    try {
      final updatedTools = tools.copyWith(
        recentColors: recentColors,
        favoriteStrokeWidths: favoriteStrokeWidths,
        shortcuts: shortcuts,
        toolbarLayout: toolbarLayout,
        showAdvancedTools: showAdvancedTools,
      );

      await _service.updateTools(updatedTools);
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('更新工具设置失败: ${e.toString()}');
    }
  }

  /// 更新用户信息
  Future<void> updateUserInfo({
    String? displayName,
    String? avatarPath,
    String? locale,
  }) async {
    if (_currentPreferences == null) return;

    try {
      await _service.updateUserInfo(
        displayName: displayName,
        avatarPath: avatarPath,
        locale: locale,
      );
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('更新用户信息失败: ${e.toString()}');
    }
  }

  /// 添加最近使用的颜色
  Future<void> addRecentColor(int color) async {
    try {
      await _service.addRecentColor(color);
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('添加最近使用颜色失败: ${e.toString()}');
    }
  }

  /// 更新面板状态
  Future<void> updatePanelState({
    required String panelType,
    bool? isCollapsed,
    bool? autoClose,
  }) async {
    try {
      await _service.updatePanelState(
        panelType: panelType,
        isCollapsed: isCollapsed,
        autoClose: autoClose,
      );
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('更新面板状态失败: ${e.toString()}');
    }
  }

  /// 创建新用户
  Future<void> createUser({
    required String displayName,
    String? avatarPath,
  }) async {
    _setLoading(true);
    try {
      _currentPreferences = await _service.createUser(
        displayName: displayName,
        avatarPath: avatarPath,
      );
      notifyListeners();
    } catch (e) {
      _setError('创建用户失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 切换用户
  Future<void> switchUser(String userId) async {
    _setLoading(true);
    try {
      await _service.switchUser(userId);
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('切换用户失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 删除用户
  Future<void> deleteUser(String userId) async {
    try {
      await _service.deleteUser(userId);
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('删除用户失败: ${e.toString()}');
    }
  }

  /// 获取所有用户
  List<UserPreferences> getAllUsers() {
    return _service.getAllUsers();
  }

  /// 导出设置
  Future<String> exportSettings() async {
    try {
      return await _service.exportSettings();
    } catch (e) {
      _setError('导出设置失败: ${e.toString()}');
      rethrow;
    }
  }

  /// 导入设置
  Future<void> importSettings(String jsonData) async {
    _setLoading(true);
    try {
      await _service.importSettings(jsonData);
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('导入设置失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 重置为默认设置
  Future<void> resetToDefaults() async {
    _setLoading(true);
    try {
      await _service.resetToDefaults();
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('重置设置失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    return await _service.getStorageStats();
  }

  /// 清除错误
  void clearError() {
    _setError(null);
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// 设置错误信息
  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  /// 获取面板折叠状态
  bool getPanelCollapsedState(String panelType) {
    return layout.panelCollapsedStates[panelType] ?? false;
  }

  /// 获取面板自动关闭状态
  bool getPanelAutoCloseState(String panelType) {
    return layout.panelAutoCloseStates[panelType] ?? true;
  }

  /// 获取主题模式
  ThemeMode getThemeMode() {
    switch (theme.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// 获取主色调
  Color getPrimaryColor() {
    return Color(theme.primaryColor);
  }

  /// 获取默认绘制颜色
  Color getDefaultDrawingColor() {
    return Color(mapEditor.defaultColor);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
