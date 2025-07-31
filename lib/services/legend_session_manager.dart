// This file has been processed by AI for internationalization
import 'package:flutter/widgets.dart';
import '../models/map_item.dart';
import '../models/legend_item.dart' as legend_db;
import '../utils/legend_path_resolver.dart';
import 'legend_cache_manager.dart';
import 'dart:async';

import 'localization_service.dart';

/// 图例会话数据
class LegendSessionData {
  final Map<String, legend_db.LegendItem> loadedLegends;
  final Map<String, LegendLoadingState> loadingStates;
  final Set<String> failedPaths;

  const LegendSessionData({
    required this.loadedLegends,
    required this.loadingStates,
    required this.failedPaths,
  });

  LegendSessionData copyWith({
    Map<String, legend_db.LegendItem>? loadedLegends,
    Map<String, LegendLoadingState>? loadingStates,
    Set<String>? failedPaths,
  }) {
    return LegendSessionData(
      loadedLegends: loadedLegends ?? Map.from(this.loadedLegends),
      loadingStates: loadingStates ?? Map.from(this.loadingStates),
      failedPaths: failedPaths ?? Set.from(this.failedPaths),
    );
  }

  /// 获取图例数据
  legend_db.LegendItem? getLegend(String legendPath) {
    return loadedLegends[legendPath];
  }

  /// 获取加载状态
  LegendLoadingState getLoadingState(String legendPath) {
    return loadingStates[legendPath] ?? LegendLoadingState.notLoaded;
  }

  /// 是否已加载
  bool isLoaded(String legendPath) {
    return loadedLegends.containsKey(legendPath);
  }

  /// 是否正在加载
  bool isLoading(String legendPath) {
    return loadingStates[legendPath] == LegendLoadingState.loading;
  }

  /// 是否加载失败
  bool isFailed(String legendPath) {
    return failedPaths.contains(legendPath);
  }

  /// 获取统计信息
  Map<String, int> getStats() {
    return {
      'loaded': loadedLegends.length,
      'loading': loadingStates.values
          .where((s) => s == LegendLoadingState.loading)
          .length,
      'failed': failedPaths.length,
      'total': loadingStates.length,
    };
  }
}

/// 图例会话管理器
/// 为当前地图编辑会话管理图例数据，与响应式版本管理系统集成
class LegendSessionManager extends ChangeNotifier {
  final LegendCacheManager _cacheManager = LegendCacheManager();
  LegendSessionData _sessionData = const LegendSessionData(
    loadedLegends: {},
    loadingStates: {},
    failedPaths: {},
  );

  /// 当前地图的绝对路径（用于占位符路径转换）
  String? _currentMapAbsolutePath;

  /// 获取当前会话数据
  LegendSessionData get sessionData => _sessionData;

  /// 获取当前地图的绝对路径
  String? get currentMapAbsolutePath => _currentMapAbsolutePath;

  /// 初始化会话（预加载地图中的所有图例）
  Future<void> initializeSession(
    MapItem mapItem, {
    String? mapAbsolutePath,
  }) async {
    // 设置当前地图路径
    _currentMapAbsolutePath = mapAbsolutePath;

    final allLegendPaths = <String>{};

    // 收集所有图例组中的图例路径
    for (final legendGroup in mapItem.legendGroups) {
      for (final legendItem in legendGroup.legendItems) {
        if (legendItem.legendPath.isNotEmpty) {
          allLegendPaths.add(legendItem.legendPath);
        }
      }
    }

    // 预加载所有图例
    await preloadLegends(allLegendPaths.toList());

    debugPrint(
      LocalizationService.instance.current.legendSessionManagerInitialized(
        allLegendPaths.length,
      ),
    );
  }

  /// 获取图例数据（同步，从会话缓存中获取）
  legend_db.LegendItem? getLegendData(String legendPath) {
    return _sessionData.getLegend(legendPath);
  }

  /// 获取加载状态
  LegendLoadingState getLoadingState(String legendPath) {
    return _sessionData.getLoadingState(legendPath);
  }

  /// 异步加载单个图例并更新会话
  Future<legend_db.LegendItem?> loadLegend(String legendPath) async {
    if (legendPath.isEmpty) return null;

    // 如果已经在会话中，直接返回
    final existing = _sessionData.getLegend(legendPath);
    if (existing != null) return existing;

    // 如果正在加载，等待加载完成
    if (_sessionData.isLoading(legendPath)) {
      while (_sessionData.isLoading(legendPath)) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _sessionData.getLegend(legendPath);
    }

    // 设置加载状态
    _updateLoadingState(legendPath, LegendLoadingState.loading);

    try {
      // 转换占位符路径为实际路径
      final actualPath = _convertToActualPath(legendPath);
      debugPrint(
        LocalizationService.instance.current.legendPathConversion_7281(
          legendPath,
          actualPath,
        ),
      );

      // 从缓存管理器获取数据
      final legendData = await _cacheManager.getLegendData(actualPath);

      if (legendData != null) {
        // 加载成功，添加到会话
        _addLegendToSession(legendPath, legendData);
        debugPrint(
          LocalizationService.instance.current.legendSessionManagerLoaded(
            legendPath,
          ),
        );
        return legendData;
      } else {
        // 加载失败
        _markLegendFailed(legendPath);
        debugPrint(
          LocalizationService.instance.current.legendSessionManagerLoadFailed(
            legendPath,
          ),
        );
        return null;
      }
    } catch (e) {
      _markLegendFailed(legendPath);
      debugPrint(
        LocalizationService.instance.current.legendSessionManagerError(
          legendPath,
          e,
        ),
      );
      return null;
    }
  }

  /// 批量预加载图例
  Future<void> preloadLegends(List<String> legendPaths) async {
    if (legendPaths.isEmpty) return;

    // 过滤已加载的图例
    final pathsToLoad = legendPaths
        .where(
          (path) =>
              path.isNotEmpty &&
              !_sessionData.isLoaded(path) &&
              !_sessionData.isLoading(path),
        )
        .toList();

    if (pathsToLoad.isEmpty) return;

    // 设置所有路径为加载中状态
    for (final path in pathsToLoad) {
      _updateLoadingState(path, LegendLoadingState.loading);
    }

    // 并发加载所有图例
    final futures = pathsToLoad.map((path) => _loadSingleLegend(path));
    await Future.wait(futures);

    debugPrint(
      LocalizationService.instance.current
          .legendSessionManagerBatchPreloadComplete(pathsToLoad.length),
    );
  }

  /// 添加新图例到会话（当用户添加新图例项时调用）
  Future<void> addLegendToSession(String legendPath) async {
    if (legendPath.isEmpty || _sessionData.isLoaded(legendPath)) {
      return;
    }

    await loadLegend(legendPath);
  }

  /// 从会话中移除图例（当图例项被删除时调用）
  void removeLegendFromSession(String legendPath) {
    if (legendPath.isEmpty) return;

    final newLoadedLegends = Map<String, legend_db.LegendItem>.from(
      _sessionData.loadedLegends,
    );
    final newLoadingStates = Map<String, LegendLoadingState>.from(
      _sessionData.loadingStates,
    );
    final newFailedPaths = Set<String>.from(_sessionData.failedPaths);

    newLoadedLegends.remove(legendPath);
    newLoadingStates.remove(legendPath);
    newFailedPaths.remove(legendPath);

    _sessionData = _sessionData.copyWith(
      loadedLegends: newLoadedLegends,
      loadingStates: newLoadingStates,
      failedPaths: newFailedPaths,
    );

    notifyListeners();
    debugPrint(
      LocalizationService.instance.current
          .legendSessionManagerRemoveLegend_7281(legendPath),
    );
  }

  /// 清除会话数据
  void clearSession() {
    _sessionData = const LegendSessionData(
      loadedLegends: {},
      loadingStates: {},
      failedPaths: {},
    );
    notifyListeners();
    debugPrint(
      LocalizationService.instance.current.sessionManagerClearData_7281,
    );
  }

  /// 重新加载失败的图例
  Future<void> retryFailedLegends() async {
    final failedPaths = _sessionData.failedPaths.toList();

    // 清除失败状态
    final newFailedPaths = Set<String>.from(_sessionData.failedPaths);
    newFailedPaths.clear();

    _sessionData = _sessionData.copyWith(failedPaths: newFailedPaths);
    notifyListeners();

    // 重新加载
    await preloadLegends(failedPaths);

    debugPrint(
      LocalizationService.instance.current.legendSessionManagerRetryCount(
        failedPaths.length,
      ),
    );
  }

  /// 获取会话统计信息
  Map<String, int> getSessionStats() {
    return _sessionData.getStats();
  }

  /// 检查是否所有图例都已加载完成
  bool get isAllLoaded {
    return _sessionData.loadingStates.values.every(
      (state) =>
          state == LegendLoadingState.loaded ||
          state == LegendLoadingState.error,
    );
  }

  /// 获取加载进度（0.0 - 1.0）
  double get loadingProgress {
    final total = _sessionData.loadingStates.length;
    if (total == 0) return 1.0;

    final completed = _sessionData.loadingStates.values
        .where(
          (state) =>
              state == LegendLoadingState.loaded ||
              state == LegendLoadingState.error,
        )
        .length;

    return completed / total;
  }

  /// 内部方法：加载单个图例
  Future<void> _loadSingleLegend(String legendPath) async {
    try {
      // 转换占位符路径为实际路径
      final actualPath = _convertToActualPath(legendPath);
      debugPrint(
        LocalizationService.instance.current.legendSessionManagerPathConversion(
          legendPath,
          actualPath,
        ),
      );

      final legendData = await _cacheManager.getLegendData(actualPath);

      if (legendData != null) {
        _addLegendToSession(legendPath, legendData);
      } else {
        _markLegendFailed(legendPath);
      }
    } catch (e) {
      _markLegendFailed(legendPath);
      debugPrint(
        LocalizationService.instance.current.legendSessionManagerLoadFailed(e),
      );
    }
  }

  /// 内部方法：添加图例到会话
  void _addLegendToSession(String legendPath, legend_db.LegendItem legendData) {
    final newLoadedLegends = Map<String, legend_db.LegendItem>.from(
      _sessionData.loadedLegends,
    );
    final newLoadingStates = Map<String, LegendLoadingState>.from(
      _sessionData.loadingStates,
    );

    newLoadedLegends[legendPath] = legendData;
    newLoadingStates[legendPath] = LegendLoadingState.loaded;

    _sessionData = _sessionData.copyWith(
      loadedLegends: newLoadedLegends,
      loadingStates: newLoadingStates,
    );

    notifyListeners();
  }

  /// 内部方法：标记图例加载失败
  void _markLegendFailed(String legendPath) {
    final newLoadingStates = Map<String, LegendLoadingState>.from(
      _sessionData.loadingStates,
    );
    final newFailedPaths = Set<String>.from(_sessionData.failedPaths);

    newLoadingStates[legendPath] = LegendLoadingState.error;
    newFailedPaths.add(legendPath);

    _sessionData = _sessionData.copyWith(
      loadingStates: newLoadingStates,
      failedPaths: newFailedPaths,
    );

    notifyListeners();
  }

  /// 内部方法：更新加载状态
  void _updateLoadingState(String legendPath, LegendLoadingState state) {
    final newLoadingStates = Map<String, LegendLoadingState>.from(
      _sessionData.loadingStates,
    );
    newLoadingStates[legendPath] = state;

    _sessionData = _sessionData.copyWith(loadingStates: newLoadingStates);
    notifyListeners();
  }

  /// 内部方法：转换占位符路径为实际路径
  String _convertToActualPath(String legendPath) {
    // 使用LegendPathResolver转换占位符路径
    return LegendPathResolver.convertToActualPath(
      legendPath,
      _currentMapAbsolutePath,
    );
  }

  @override
  void dispose() {
    clearSession();
    super.dispose();
  }
}
