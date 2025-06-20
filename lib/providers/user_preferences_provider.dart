import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user_preferences.dart';
import '../services/user_preferences/user_preferences_service.dart';
import 'theme_provider.dart';

/// 用户偏好设置状态管理Provider
class UserPreferencesProvider extends ChangeNotifier {
  final UserPreferencesService _service = UserPreferencesService();

  UserPreferences? _currentPreferences;
  bool _isLoading = false;
  String? _error;
  ThemeProvider? _themeProvider;

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

      // 先更新数据，但不立即通知监听器
      await _service.updateTheme(updatedTheme);
      _currentPreferences = await _service.getCurrentPreferences();

      // 使用微任务机制，避免在构建过程中触发更新
      Future.microtask(() {
        if (_currentPreferences != null) {
          notifyListeners();

          // 更新 ThemeProvider，但也使用微任务
          Future.microtask(() {
            _themeProvider?.updateFromUserPreferences(
              themeMode: updatedTheme.themeMode,
              primaryColor: updatedTheme.primaryColor,
              useMaterialYou: updatedTheme.useMaterialYou,
              fontScale: updatedTheme.fontScale,
              highContrast: updatedTheme.highContrast,
            );
          });
        }
      });
    } catch (e) {
      _setError('更新主题设置失败: ${e.toString()}');
    }
  }

  /// 更新地图编辑器设置
  Future<void> updateMapEditor({
    int? undoHistoryLimit,
    double? zoomSensitivity,
    BackgroundPattern? backgroundPattern,
    double? canvasBoundaryMargin,
  }) async {
    if (_currentPreferences == null) return;

    try {
      final updatedMapEditor = mapEditor.copyWith(
        undoHistoryLimit: undoHistoryLimit,
        zoomSensitivity: zoomSensitivity,
        backgroundPattern: backgroundPattern,
        canvasBoundaryMargin: canvasBoundaryMargin,
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
    bool? autoRestorePanelStates,
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
        autoRestorePanelStates: autoRestorePanelStates,
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
    List<int>? customColors,
    List<double>? favoriteStrokeWidths,
    Map<String, String>? shortcuts,
    List<String>? toolbarLayout,
    bool? showAdvancedTools,
    double? handleSize,
  }) async {
    if (_currentPreferences == null) return;

    try {
      final updatedTools = tools.copyWith(
        recentColors: recentColors,
        customColors: customColors,
        favoriteStrokeWidths: favoriteStrokeWidths,
        shortcuts: shortcuts,
        toolbarLayout: toolbarLayout,
        showAdvancedTools: showAdvancedTools,
        handleSize: handleSize,
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
    Uint8List? avatarData,
    String? locale,
  }) async {
    if (_currentPreferences == null) return;

    try {
      await _service.updateUserInfo(
        displayName: displayName,
        avatarPath: avatarPath,
        avatarData: avatarData,
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

  /// 添加常用线条宽度
  Future<void> addFavoriteStrokeWidth(double strokeWidth) async {
    try {
      await _service.addFavoriteStrokeWidth(strokeWidth);
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('添加常用线条宽度失败: ${e.toString()}');
    }
  }

  /// 添加自定义颜色
  Future<void> addCustomColor(int color) async {
    try {
      if (kDebugMode) {
        print('开始添加自定义颜色: ${color.toRadixString(16).padLeft(8, '0')}');
      }
      await _service.addCustomColor(color);
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
      if (kDebugMode) {
        print(
          '自定义颜色添加成功，当前自定义颜色数量: ${_currentPreferences!.tools.customColors.length}',
        );
      }
    } catch (e) {
      _setError('添加自定义颜色失败: ${e.toString()}');
      if (kDebugMode) {
        print('添加自定义颜色失败: $e');
      }
      rethrow; // 重新抛出错误，让调用方能够处理
    }
  }

  /// 移除自定义颜色
  Future<void> removeCustomColor(int color) async {
    if (_currentPreferences == null) return;

    try {
      final customColors = List<int>.from(
        _currentPreferences!.tools.customColors,
      );
      customColors.remove(color);

      await updateTools(customColors: customColors);
    } catch (e) {
      _setError('移除自定义颜色失败: ${e.toString()}');
    }
  }

  /// 添加自定义标签
  Future<void> addCustomTag(String tag) async {
    try {
      await _service.addCustomTag(tag);
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('添加自定义标签失败: ${e.toString()}');
    }
  }

  /// 移除自定义标签
  Future<void> removeCustomTag(String tag) async {
    try {
      await _service.removeCustomTag(tag);
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('移除自定义标签失败: ${e.toString()}');
    }
  }

  /// 更新自定义标签列表
  Future<void> updateCustomTags(List<String> tags) async {
    try {
      await _service.updateCustomTags(tags);
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('更新自定义标签失败: ${e.toString()}');
    }
  }

  /// 添加最近使用的标签
  Future<void> addRecentTag(String tag) async {
    try {
      await _service.addRecentTag(tag);
      _currentPreferences = await _service.getCurrentPreferences();
      notifyListeners();
    } catch (e) {
      _setError('添加最近使用标签失败: ${e.toString()}');
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
  Future<List<UserPreferences>> getAllUsers() async {
    return await _service.getAllUsersAsync();
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

  /// 设置 ThemeProvider 引用以同步主题更新
  void setThemeProvider(ThemeProvider themeProvider) {
    _themeProvider = themeProvider;
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

  @override
  void dispose() {
    super.dispose();
  }
}
