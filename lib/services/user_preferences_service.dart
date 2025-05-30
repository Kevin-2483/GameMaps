import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import '../models/user_preferences.dart';

/// 用户偏好设置服务
/// 支持Web和桌面端的跨平台存储
class UserPreferencesService {
  static final UserPreferencesService _instance = UserPreferencesService._internal();
  factory UserPreferencesService() => _instance;
  UserPreferencesService._internal();

  static const String _preferencesKey = 'user_preferences';
  static const String _userProfilesKey = 'user_profiles';
  static const String _currentUserKey = 'current_user_id';

  SharedPreferences? _prefs;
  UserPreferences? _currentPreferences;
  final Map<String, UserPreferences> _userProfiles = {};

  /// 初始化服务
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUserProfiles();
    await _loadCurrentUser();
  }

  /// 获取SharedPreferences实例
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// 获取当前用户偏好设置
  Future<UserPreferences> getCurrentPreferences() async {
    if (_currentPreferences != null) {
      return _currentPreferences!;
    }

    // 尝试从存储中加载
    await _loadCurrentUser();
    
    // 如果仍然为空，创建默认设置
    if (_currentPreferences == null) {
      _currentPreferences = UserPreferences.createDefault();
      await savePreferences(_currentPreferences!);
    }

    return _currentPreferences!;
  }

  /// 保存用户偏好设置
  Future<void> savePreferences(UserPreferences preferences) async {
    final prefs = await _preferences;
    
    // 更新时间戳
    final updatedPreferences = preferences.copyWith(
      updatedAt: DateTime.now(),
    );

    // 保存到内存
    _currentPreferences = updatedPreferences;

    // 保存到存储
    final json = updatedPreferences.toJson();
    await prefs.setString(_preferencesKey, jsonEncode(json));

    // 如果有用户ID，也保存到用户配置文件中
    if (updatedPreferences.userId != null) {
      _userProfiles[updatedPreferences.userId!] = updatedPreferences;
      await _saveUserProfiles();
      await prefs.setString(_currentUserKey, updatedPreferences.userId!);
    }

    if (kDebugMode) {
      print('用户偏好设置已保存: ${updatedPreferences.displayName}');
    }
  }

  /// 切换用户
  Future<void> switchUser(String userId) async {
    if (_userProfiles.containsKey(userId)) {
      _currentPreferences = _userProfiles[userId];
      final prefs = await _preferences;
      await prefs.setString(_currentUserKey, userId);
      
      // 更新最后登录时间
      _currentPreferences = _currentPreferences!.copyWith(
        lastLoginAt: DateTime.now(),
      );
      await savePreferences(_currentPreferences!);
    }
  }

  /// 创建新用户
  Future<UserPreferences> createUser({
    required String displayName,
    String? avatarPath,
  }) async {
    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    final preferences = UserPreferences.createDefault(
      userId: userId,
      displayName: displayName,
    ).copyWith(avatarPath: avatarPath);

    _userProfiles[userId] = preferences;
    await _saveUserProfiles();
    
    // 切换到新用户
    await switchUser(userId);
    
    return preferences;
  }

  /// 删除用户
  Future<void> deleteUser(String userId) async {
    if (_userProfiles.containsKey(userId)) {
      _userProfiles.remove(userId);
      await _saveUserProfiles();

      // 如果删除的是当前用户，切换到默认用户或创建新用户
      if (_currentPreferences?.userId == userId) {
        if (_userProfiles.isNotEmpty) {
          final firstUserId = _userProfiles.keys.first;
          await switchUser(firstUserId);
        } else {
          _currentPreferences = UserPreferences.createDefault();
          await savePreferences(_currentPreferences!);
        }
      }
    }
  }

  /// 获取所有用户配置文件
  List<UserPreferences> getAllUsers() {
    return _userProfiles.values.toList()
      ..sort((a, b) => (b.lastLoginAt ?? b.createdAt)
          .compareTo(a.lastLoginAt ?? a.createdAt));
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

  /// 更新用户信息
  Future<void> updateUserInfo({
    String? displayName,
    String? avatarPath,
    String? locale,
  }) async {
    final current = await getCurrentPreferences();
    await savePreferences(current.copyWith(
      displayName: displayName,
      avatarPath: avatarPath,
      locale: locale,
    ));
  }

  /// 添加最近使用的颜色
  Future<void> addRecentColor(int color) async {
    final current = await getCurrentPreferences();
    final recentColors = List<int>.from(current.tools.recentColors);
    
    // 移除已存在的颜色
    recentColors.remove(color);
    // 添加到开头
    recentColors.insert(0, color);
    // 限制数量
    if (recentColors.length > 10) {
      recentColors.removeRange(10, recentColors.length);
    }

    final updatedTools = current.tools.copyWith(recentColors: recentColors);
    await updateTools(updatedTools);
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
      'version': '1.0.0',
      'exportTime': DateTime.now().toIso8601String(),
      'preferences': current.toJson(),
    };
    return jsonEncode(exportData);
  }

  /// 导入用户设置
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
      
      await savePreferences(importedPreferences);
    } catch (e) {
      if (kDebugMode) {
        print('导入设置失败: $e');
      }
      rethrow;
    }
  }

  /// 重置为默认设置
  Future<void> resetToDefaults() async {
    final current = await getCurrentPreferences();
    final defaultPreferences = UserPreferences.createDefault(
      userId: current.userId,
      displayName: current.displayName,
    ).copyWith(
      avatarPath: current.avatarPath,
      createdAt: current.createdAt,
    );
    
    await savePreferences(defaultPreferences);
  }

  /// 加载用户配置文件
  Future<void> _loadUserProfiles() async {
    final prefs = await _preferences;
    final profilesJson = prefs.getString(_userProfilesKey);
    
    if (profilesJson != null) {
      try {
        final profilesData = jsonDecode(profilesJson) as Map<String, dynamic>;
        _userProfiles.clear();
        
        for (final entry in profilesData.entries) {
          final preferences = UserPreferences.fromJson(
            entry.value as Map<String, dynamic>,
          );
          _userProfiles[entry.key] = preferences;
        }
      } catch (e) {
        if (kDebugMode) {
          print('加载用户配置文件失败: $e');
        }
      }
    }
  }

  /// 保存用户配置文件
  Future<void> _saveUserProfiles() async {
    final prefs = await _preferences;
    final profilesData = <String, dynamic>{};
    
    for (final entry in _userProfiles.entries) {
      profilesData[entry.key] = entry.value.toJson();
    }
    
    await prefs.setString(_userProfilesKey, jsonEncode(profilesData));
  }

  /// 加载当前用户
  Future<void> _loadCurrentUser() async {
    final prefs = await _preferences;
    
    // 尝试从用户ID加载
    final currentUserId = prefs.getString(_currentUserKey);
    if (currentUserId != null && _userProfiles.containsKey(currentUserId)) {
      _currentPreferences = _userProfiles[currentUserId];
      return;
    }

    // 尝试从旧的偏好设置加载
    final preferencesJson = prefs.getString(_preferencesKey);
    if (preferencesJson != null) {
      try {
        final json = jsonDecode(preferencesJson) as Map<String, dynamic>;
        _currentPreferences = UserPreferences.fromJson(json);
      } catch (e) {
        if (kDebugMode) {
          print('加载用户偏好设置失败: $e');
        }
      }
    }
  }

  /// 清除所有数据（用于测试或重置）
  Future<void> clearAllData() async {
    final prefs = await _preferences;
    await prefs.remove(_preferencesKey);
    await prefs.remove(_userProfilesKey);
    await prefs.remove(_currentUserKey);
    
    _currentPreferences = null;
    _userProfiles.clear();
  }

  /// 获取存储使用情况统计
  Future<Map<String, dynamic>> getStorageStats() async {
    final prefs = await _preferences;
    final keys = prefs.getKeys();
    int totalSize = 0;
    
    for (final key in keys) {
      final value = prefs.get(key);
      if (value is String) {
        totalSize += value.length;
      }
    }

    return {
      'totalKeys': keys.length,
      'totalSize': totalSize,
      'userProfiles': _userProfiles.length,
      'platform': kIsWeb ? 'web' : Platform.operatingSystem,
    };
  }
}
