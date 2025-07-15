import 'dart:async';
import 'dart:convert';
// import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../models/user_preferences.dart';
import 'user_preferences_database_service.dart';
import 'user_preferences_migration_service.dart';
// import 'user_preferences_migration_service.dart';

/// 用户偏好设置服务
/// 使用SQLite数据库存储，替代SharedPreferences以提升性能
/// 包含防抖机制避免频繁保存
class UserPreferencesService {
  static final UserPreferencesService _instance =
      UserPreferencesService._internal();
  factory UserPreferencesService() => _instance;
  UserPreferencesService._internal();
  final UserPreferencesDatabaseService _dbService =
      UserPreferencesDatabaseService();
  final UserPreferencesMigrationService _migrationService =
      UserPreferencesMigrationService();

  UserPreferences? _currentPreferences;
  bool _initialized = false;

  // 防抖相关变量
  Timer? _debounceTimer;
  UserPreferences? _pendingPreferences;
  static const Duration _debounceDuration = Duration(
    milliseconds: 500,
  ); // 防抖延迟时间
  final Set<String> _immediateKeys = {
    'currentUser',
    'displayName',
    'avatarPath',
    'locale',
  }; // 需要立即保存的关键配置

  /// 初始化服务
  Future<void> initialize() async {
    if (_initialized) {
      return; // 避免重复初始化
    }

    try {
      // 只在真正需要时执行迁移
      if (await _migrationService.needsMigration()) {
        if (kDebugMode) {
          debugPrint('执行用户偏好设置数据迁移...');
        }

        final migrationSuccess = await _migrationService.performMigration();
        if (migrationSuccess) {
          if (kDebugMode) {
            debugPrint('数据迁移完成');
          }
          // 迁移成功后可选择清理旧数据
          // await _migrationService.cleanupLegacyData();
        }
      }

      // 加载当前用户
      await _loadCurrentUser();
      _initialized = true;

      if (kDebugMode) {
        debugPrint('用户偏好设置服务初始化完成');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('用户偏好设置服务初始化失败: $e');
      }
      // 即使迁移失败，也要继续初始化服务
      await _loadCurrentUser();
      _initialized = true;
    }
  }

  /// 获取当前用户偏好设置
  Future<UserPreferences> getCurrentPreferences() async {
    if (_currentPreferences != null) {
      return _currentPreferences!;
    }

    // 尝试从数据库中加载
    await _loadCurrentUser();

    // 如果仍然为空，创建默认设置
    if (_currentPreferences == null) {
      _currentPreferences = UserPreferences.createDefault();
      await savePreferences(_currentPreferences!);
    }

    return _currentPreferences!;
  }

  /// 保存用户偏好设置（带防抖机制）
  Future<void> savePreferences(
    UserPreferences preferences, {
    bool immediate = false,
  }) async {
    // 更新时间戳
    final updatedPreferences = preferences.copyWith(updatedAt: DateTime.now());

    // 更新内存缓存
    _currentPreferences = updatedPreferences;

    if (immediate) {
      // 立即保存，取消任何待处理的防抖保存
      _debounceTimer?.cancel();
      _pendingPreferences = null;
      await _saveToDatabase(updatedPreferences);
    } else {
      // 使用防抖保存
      await _debouncedSave(updatedPreferences);
    }
  }

  /// 防抖保存实现
  Future<void> _debouncedSave(UserPreferences preferences) async {
    _pendingPreferences = preferences;

    // 取消之前的定时器
    _debounceTimer?.cancel();

    // 创建新的防抖定时器
    _debounceTimer = Timer(_debounceDuration, () async {
      if (_pendingPreferences != null) {
        await _saveToDatabase(_pendingPreferences!);
        _pendingPreferences = null;
      }
    });
  }

  /// 实际保存到数据库的方法
  Future<void> _saveToDatabase(UserPreferences preferences) async {
    try {
      await _dbService.savePreferences(preferences);

      if (kDebugMode) {
        debugPrint('用户偏好设置已保存: ${preferences.displayName}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('保存用户偏好设置失败: $e');
      }
      rethrow;
    }
  }

  /// 强制保存所有待处理的更改
  Future<void> flushPendingChanges() async {
    _debounceTimer?.cancel();
    if (_pendingPreferences != null) {
      await _saveToDatabase(_pendingPreferences!);
      _pendingPreferences = null;
    }
  }

  /// 切换用户（立即保存）
  Future<void> switchUser(String userId) async {
    final preferences = await _dbService.getPreferences(userId);
    if (preferences != null) {
      await _dbService.setCurrentUser(userId);
      _currentPreferences = preferences.copyWith(lastLoginAt: DateTime.now());
      await savePreferences(_currentPreferences!, immediate: true);
    }
  }

  /// 创建新用户（立即保存）
  Future<UserPreferences> createUser({
    required String displayName,
    String? avatarPath,
  }) async {
    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    final preferences = UserPreferences.createDefault(
      userId: userId,
      displayName: displayName,
    ).copyWith(avatarPath: avatarPath);

    await _dbService.savePreferences(preferences);
    await _dbService.setCurrentUser(userId);
    _currentPreferences = preferences;

    return preferences;
  }

  /// 删除用户（立即保存）
  Future<void> deleteUser(String userId) async {
    await _dbService.deleteUser(userId); // 如果删除的是当前用户，创建新的默认用户
    if (_currentPreferences?.userId == userId) {
      final allUsers = await getAllUsersAsync();
      if (allUsers.isNotEmpty) {
        await switchUser(allUsers.first.userId!);
      } else {
        _currentPreferences = UserPreferences.createDefault();
        await savePreferences(_currentPreferences!, immediate: true);
      }
    }
  }

  /// 获取所有用户配置文件
  List<UserPreferences> getAllUsers() {
    // 使用异步包装器来处理数据库调用
    throw UnimplementedError('请使用 getAllUsersAsync() 方法');
  }

  /// 获取所有用户配置文件（异步版本）
  Future<List<UserPreferences>> getAllUsersAsync() async {
    return await _dbService.getAllUsers();
  }

  /// 更新主题设置
  Future<void> updateTheme(ThemePreferences theme) async {
    final current = await getCurrentPreferences();
    await savePreferences(current.copyWith(theme: theme));
  }

  /// 更新地图编辑器设置
  Future<void> updateMapEditor(MapEditorPreferences mapEditor) async {
    final current = await getCurrentPreferences();
    await savePreferences(current.copyWith(mapEditor: mapEditor));
  }

  /// 更新界面布局设置
  Future<void> updateLayout(LayoutPreferences layout) async {
    final current = await getCurrentPreferences();
    await savePreferences(current.copyWith(layout: layout));
  }

  /// 更新工具设置
  Future<void> updateTools(ToolPreferences tools) async {
    final current = await getCurrentPreferences();
    await savePreferences(current.copyWith(tools: tools));
  }

  /// 更新扩展设置
  Future<void> updateExtensionSettings(
    Map<String, dynamic> extensionSettings,
  ) async {
    final current = await getCurrentPreferences();
    await savePreferences(
      current.copyWith(extensionSettings: extensionSettings),
    );
  }

  /// 更新用户信息
  Future<void> updateUserInfo({
    String? displayName,
    String? avatarPath,
    Uint8List? avatarData,
    String? locale,
  }) async {
    final current = await getCurrentPreferences();
    final updated = current.copyWith(
      displayName: displayName,
      avatarPath: avatarPath,
      avatarData: avatarData,
      locale: locale,
    );

    // 用户基本信息变更立即保存
    final immediate =
        displayName != null || avatarPath != null || locale != null;
    await savePreferences(updated, immediate: immediate);
  }

  /// 添加最近使用的颜色
  Future<void> addRecentColor(int color) async {
    final current = await getCurrentPreferences();
    final recentColors = List<int>.from(current.tools.recentColors);

    // 移除已存在的颜色
    recentColors.remove(color);
    // 添加到开头
    recentColors.insert(0, color);
    // 限制数量为5个
    if (recentColors.length > 5) {
      recentColors.removeRange(5, recentColors.length);
    }

    final updatedTools = current.tools.copyWith(recentColors: recentColors);
    await updateTools(updatedTools);
  }

  /// 添加自定义颜色
  Future<void> addCustomColor(int color) async {
    final current = await getCurrentPreferences();
    final customColors = List<int>.from(current.tools.customColors);

    // 检查颜色是否已存在
    if (customColors.contains(color)) {
      throw Exception('该颜色已存在');
    }

    // 添加新颜色到开头
    customColors.insert(0, color);
    // 限制数量为10个
    if (customColors.length > 10) {
      customColors.removeRange(10, customColors.length);
    }

    final updatedTools = current.tools.copyWith(customColors: customColors);
    await updateTools(updatedTools);

    if (kDebugMode) {
      debugPrint('自定义颜色已添加: ${color.toRadixString(16).padLeft(8, '0')}');
    }
  }

  /// 添加常用线条宽度
  Future<void> addFavoriteStrokeWidth(double strokeWidth) async {
    final current = await getCurrentPreferences();
    final favoriteStrokeWidths = List<double>.from(
      current.tools.favoriteStrokeWidths,
    );

    // 移除已存在的宽度
    favoriteStrokeWidths.remove(strokeWidth);
    // 添加到开头
    favoriteStrokeWidths.insert(0, strokeWidth);
    // 限制数量为5个
    if (favoriteStrokeWidths.length > 5) {
      favoriteStrokeWidths.removeRange(5, favoriteStrokeWidths.length);
    }

    final updatedTools = current.tools.copyWith(
      favoriteStrokeWidths: favoriteStrokeWidths,
    );
    await updateTools(updatedTools);

    if (kDebugMode) {
      debugPrint('常用线条宽度已添加: ${strokeWidth}px');
    }
  }

  /// 更新面板状态
  Future<void> updatePanelState({
    required String panelType,
    bool? isCollapsed,
    bool? autoClose,
  }) async {
    final current = await getCurrentPreferences();
    final layout = current.layout;

    Map<String, bool>? collapsedStates;
    Map<String, bool>? autoCloseStates;

    if (isCollapsed != null) {
      collapsedStates = Map<String, bool>.from(layout.panelCollapsedStates);
      collapsedStates[panelType] = isCollapsed;
    }

    if (autoClose != null) {
      autoCloseStates = Map<String, bool>.from(layout.panelAutoCloseStates);
      autoCloseStates[panelType] = autoClose;
    }

    final updatedLayout = layout.copyWith(
      panelCollapsedStates: collapsedStates,
      panelAutoCloseStates: autoCloseStates,
    );

    await updateLayout(updatedLayout);
  }

  /// 导出用户设置
  Future<String> exportSettings() async {
    final current = await getCurrentPreferences();
    final exportData = {
      'version': '1.1.0',
      'exportTime': DateTime.now().toIso8601String(),
      'preferences': current.toJson(),
    };
    return jsonEncode(exportData);
  }

  /// 导入用户设置（立即保存）
  Future<void> importSettings(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final preferencesData = data['preferences'] as Map<String, dynamic>;
      final preferences = UserPreferences.fromJson(preferencesData);

      // 保持当前用户ID但应用导入的设置
      final current = await getCurrentPreferences();
      final importedPreferences = preferences.copyWith(
        userId: current.userId,
        createdAt: current.createdAt,
        updatedAt: DateTime.now(),
      );

      await savePreferences(importedPreferences, immediate: true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('导入设置失败: $e');
      }
      rethrow;
    }
  }

  /// 重置为默认设置（立即保存）
  Future<void> resetToDefaults() async {
    final current = await getCurrentPreferences();
    final defaultPreferences = UserPreferences.createDefault(
      userId: current.userId,
      displayName: current.displayName,
    ).copyWith(avatarPath: current.avatarPath, createdAt: current.createdAt);

    await savePreferences(defaultPreferences, immediate: true);
  }

  /// 加载当前用户
  Future<void> _loadCurrentUser() async {
    try {
      _currentPreferences = await _dbService.getCurrentPreferences();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('加载当前用户偏好设置失败: $e');
      }
    }
  }

  /// 清除所有数据（用于测试或重置）
  Future<void> clearAllData() async {
    await _dbService.clearAllData();
    _currentPreferences = null;
  }

  /// 获取存储使用情况统计
  Future<Map<String, dynamic>> getStorageStats() async {
    return await _dbService.getStorageStats();
  }

  /// 关闭服务
  Future<void> close() async {
    // 保存所有待处理的更改
    await flushPendingChanges();

    // 取消防抖定时器
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _pendingPreferences = null;

    await _dbService.close();
    _currentPreferences = null;
  }

  /// 添加自定义标签
  Future<void> addCustomTag(String tag) async {
    final current = await getCurrentPreferences();
    final customTags = List<String>.from(current.tools.customTags);

    // 避免重复添加
    if (!customTags.contains(tag)) {
      customTags.add(tag);

      final updatedTools = current.tools.copyWith(customTags: customTags);
      await updateTools(updatedTools);
    }
  }

  /// 移除自定义标签
  Future<void> removeCustomTag(String tag) async {
    final current = await getCurrentPreferences();
    final customTags = List<String>.from(current.tools.customTags);

    if (customTags.remove(tag)) {
      final updatedTools = current.tools.copyWith(customTags: customTags);
      await updateTools(updatedTools);
    }
  }

  /// 更新自定义标签列表
  Future<void> updateCustomTags(List<String> tags) async {
    final current = await getCurrentPreferences();
    final updatedTools = current.tools.copyWith(customTags: tags);
    await updateTools(updatedTools);
  }

  /// 添加最近使用的标签
  Future<void> addRecentTag(String tag) async {
    final current = await getCurrentPreferences();
    final recentTags = List<String>.from(current.tools.recentTags);

    // 移除已存在的标签
    recentTags.remove(tag);
    // 添加到开头
    recentTags.insert(0, tag);
    // 限制数量为10个
    if (recentTags.length > 10) {
      recentTags.removeRange(10, recentTags.length);
    }

    final updatedTools = current.tools.copyWith(recentTags: recentTags);
    await updateTools(updatedTools);
  }
}
