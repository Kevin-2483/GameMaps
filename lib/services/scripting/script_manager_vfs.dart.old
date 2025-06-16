import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/script_data.dart';
import 'script_engine.dart';
import '../virtual_file_system/virtual_file_system.dart';
import '../../utils/filename_sanitizer.dart';

/// 脚本管理器 - 使用VFS存储结构
class ScriptManager extends ChangeNotifier {
  final VirtualFileSystem _vfs = VirtualFileSystem();
  final ScriptEngine _engine = ScriptEngine();

  final List<ScriptData> _scripts = [];
  final Map<String, ScriptStatus> _scriptStatuses = {};
  final Map<String, ScriptExecutionResult> _lastResults = {};

  String? _currentMapTitle; // 当前地图标题，用于构建脚本存储路径

  List<ScriptData> get scripts => List.unmodifiable(_scripts);
  Map<String, ScriptStatus> get scriptStatuses =>
      Map.unmodifiable(_scriptStatuses);
  Map<String, ScriptExecutionResult> get lastResults =>
      Map.unmodifiable(_lastResults);

  /// 初始化管理器
  Future<void> initialize({String? mapTitle}) async {
    _currentMapTitle = mapTitle;

    await _engine.initialize();
    if (_currentMapTitle != null) {
      await loadScripts();
    }
  }

  /// 设置当前地图标题
  void setMapTitle(String mapTitle) {
    if (_currentMapTitle != mapTitle) {
      _currentMapTitle = mapTitle;
      // 重新加载脚本
      loadScripts();
    }
  }

  /// 获取脚本存储路径
  String _getScriptsPath() {
    if (_currentMapTitle == null) {
      throw Exception('Map title not set');
    }
    return 'indexeddb://r6box/maps/${_getMapPath(_currentMapTitle!)}/scripts';
  }

  /// 获取地图路径（处理特殊字符）- 使用与VFS地图服务相同的路径格式
  String _getMapPath(String mapTitle) {
    // 使用与VfsMapServiceImpl相同的文件名清理逻辑
    final sanitizedTitle = FilenameSanitizer.sanitize(mapTitle);
    return '$sanitizedTitle.mapdata';
  }

  /// 获取脚本文件路径
  String _getScriptFilePath(String scriptId) {
    return '${_getScriptsPath()}/$scriptId.json';
  }

  /// 获取脚本索引文件路径
  String _getScriptIndexPath() {
    return '${_getScriptsPath()}/index.json';
  }

  /// 从VFS存储加载脚本
  Future<void> loadScripts() async {
    if (_currentMapTitle == null) return;

    try {
      _scripts.clear();
      _scriptStatuses.clear();

      // 先尝试读取脚本索引文件
      final indexPath = _getScriptIndexPath();
      final indexExists = await _vfs.exists(indexPath);

      if (indexExists) {
        final indexData = await _vfs.readTextFile(indexPath);
        if (indexData != null) {
          final scriptIds = List<String>.from(json.decode(indexData));

          // 逐个加载脚本文件
          for (final scriptId in scriptIds) {
            try {
              final scriptPath = _getScriptFilePath(scriptId);
              final scriptData = await _vfs.readTextFile(scriptPath);
              if (scriptData != null) {
                final script = ScriptData.fromJson(json.decode(scriptData));

                _scripts.add(script);
                _scriptStatuses[script.id] = ScriptStatus.idle;
              }
            } catch (e) {
              debugPrint('Failed to load script $scriptId: $e');
            }
          }
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load scripts: $e');
    }
  }

  /// 保存脚本索引到VFS
  Future<void> _saveScriptIndex() async {
    try {
      final scriptIds = _scripts.map((s) => s.id).toList();
      final indexPath = _getScriptIndexPath();
      await _vfs.writeTextFile(indexPath, json.encode(scriptIds));
    } catch (e) {
      debugPrint('Failed to save script index: $e');
    }
  }

  /// 保存单个脚本到VFS
  Future<void> _saveScript(ScriptData script) async {
    try {
      final scriptPath = _getScriptFilePath(script.id);
      await _vfs.writeTextFile(scriptPath, json.encode(script.toJson()));
    } catch (e) {
      debugPrint('Failed to save script ${script.id}: $e');
    }
  }

  /// 删除脚本文件
  Future<void> _deleteScriptFile(String scriptId) async {
    try {
      final scriptPath = _getScriptFilePath(scriptId);
      await _vfs.delete(scriptPath);
    } catch (e) {
      debugPrint('Failed to delete script file $scriptId: $e');
    }
  }

  /// 添加脚本
  Future<void> addScript(ScriptData script) async {
    if (_currentMapTitle == null) {
      throw Exception('Map title not set');
    }

    _scripts.add(script);
    _scriptStatuses[script.id] = ScriptStatus.idle;

    await _saveScript(script);
    await _saveScriptIndex();

    notifyListeners();
  }

  /// 更新脚本
  Future<void> updateScript(ScriptData script) async {
    final index = _scripts.indexWhere((s) => s.id == script.id);
    if (index != -1) {
      final updatedScript = script.copyWith(updatedAt: DateTime.now());
      _scripts[index] = updatedScript;

      await _saveScript(updatedScript);
      notifyListeners();
    }
  }

  /// 删除脚本
  Future<void> deleteScript(String scriptId) async {
    _scripts.removeWhere((s) => s.id == scriptId);
    _scriptStatuses.remove(scriptId);
    _lastResults.remove(scriptId);
    _engine.stopScript(scriptId);

    await _deleteScriptFile(scriptId);
    await _saveScriptIndex();

    notifyListeners();
  }

  /// 执行脚本
  Future<void> executeScript(String scriptId) async {
    final script = _scripts.firstWhere(
      (s) => s.id == scriptId,
      orElse: () => throw Exception('Script not found: $scriptId'),
    );

    if (!script.isEnabled) {
      throw Exception('Script is disabled: ${script.name}');
    }

    _scriptStatuses[scriptId] = ScriptStatus.running;
    notifyListeners();

    try {
      final result = await _engine.executeScript(script);
      _lastResults[scriptId] = result;

      if (result.success) {
        _scriptStatuses[scriptId] = ScriptStatus.idle;
        // 更新最后运行时间
        final updatedScript = script.copyWith(
          lastRunAt: DateTime.now(),
          clearLastError: true,
        );
        await updateScript(updatedScript);
      } else {
        _scriptStatuses[scriptId] = ScriptStatus.error;
        // 更新错误信息
        final updatedScript = script.copyWith(
          lastError: result.error,
          lastRunAt: DateTime.now(),
        );
        await updateScript(updatedScript);
      }
    } catch (e) {
      _scriptStatuses[scriptId] = ScriptStatus.error;
      _lastResults[scriptId] = ScriptExecutionResult(
        success: false,
        error: e.toString(),
        executionTime: Duration.zero,
      );

      // 更新错误信息
      final updatedScript = script.copyWith(
        lastError: e.toString(),
        lastRunAt: DateTime.now(),
      );
      await updateScript(updatedScript);
    }

    notifyListeners();
  }

  /// 停止脚本执行
  void stopScript(String scriptId) {
    _engine.stopScript(scriptId);
    _scriptStatuses[scriptId] = ScriptStatus.idle;
    notifyListeners();
  }

  /// 获取脚本状态
  ScriptStatus getScriptStatus(String scriptId) {
    return _scriptStatuses[scriptId] ?? ScriptStatus.idle;
  }

  /// 获取脚本最后执行结果
  ScriptExecutionResult? getLastResult(String scriptId) {
    return _lastResults[scriptId];
  }

  /// 启用/禁用脚本
  Future<void> toggleScriptEnabled(String scriptId) async {
    final index = _scripts.indexWhere((s) => s.id == scriptId);
    if (index != -1) {
      final script = _scripts[index];
      final updatedScript = script.copyWith(isEnabled: !script.isEnabled);
      _scripts[index] = updatedScript;
      await updateScript(updatedScript);
    }
  }

  /// 复制脚本
  Future<void> duplicateScript(String scriptId) async {
    final script = _scripts.firstWhere(
      (s) => s.id == scriptId,
      orElse: () => throw Exception('Script not found: $scriptId'),
    );

    final duplicatedScript = ScriptData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${script.name} (Copy)',
      description: script.description,
      type: script.type,
      content: script.content,
      parameters: Map.from(script.parameters),
      isEnabled: false, // 默认禁用复制的脚本
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await addScript(duplicatedScript);
  }

  /// 导出脚本
  String exportScript(String scriptId) {
    final script = _scripts.firstWhere(
      (s) => s.id == scriptId,
      orElse: () => throw Exception('Script not found: $scriptId'),
    );

    return json.encode(script.toJson());
  }

  /// 导入脚本
  Future<void> importScript(String scriptJson) async {
    try {
      final scriptMap = json.decode(scriptJson) as Map<String, dynamic>;
      final script = ScriptData.fromJson(scriptMap);

      // 生成新的ID和时间戳
      final importedScript = script.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEnabled: false, // 默认禁用导入的脚本
      );

      await addScript(importedScript);
    } catch (e) {
      throw Exception('Failed to import script: $e');
    }
  }

  /// 设置地图数据访问器
  void setMapDataAccessor(
    layers,
    onLayersChanged,
    stickyNotes,
    onStickyNotesChanged,
    legendGroups,
    onLegendGroupsChanged,
  ) {
    _engine.setMapDataAccessor(
      layers,
      onLayersChanged,
      stickyNotes,
      onStickyNotesChanged,
      legendGroups,
      onLegendGroupsChanged,
    );
  }

  /// 设置 VFS 访问器
  void setVfsAccessor(String mapTitle) {
    _engine.setVfsAccessor(_vfs, mapTitle);
  }

  /// 获取按类型分组的脚本
  Map<ScriptType, List<ScriptData>> getScriptsByType() {
    final grouped = <ScriptType, List<ScriptData>>{};

    for (final type in ScriptType.values) {
      grouped[type] = _scripts.where((s) => s.type == type).toList();
    }

    return grouped;
  }

  /// 获取脚本内容（用于编辑器）
  Future<String> getScriptContent(String scriptId) async {
    final script = _scripts.firstWhere(
      (s) => s.id == scriptId,
      orElse: () => throw Exception('Script not found: $scriptId'),
    );
    return script.content;
  }

  /// 更新脚本内容（用于编辑器）
  Future<void> updateScriptContent(String scriptId, String content) async {
    final index = _scripts.indexWhere((s) => s.id == scriptId);
    if (index != -1) {
      final script = _scripts[index];
      final updatedScript = script.copyWith(
        content: content,
        updatedAt: DateTime.now(),
      );
      _scripts[index] = updatedScript;
      await updateScript(updatedScript);
    }
  }

  /// 清理资源
  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }
}
