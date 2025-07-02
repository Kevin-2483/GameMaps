import 'package:flutter/widgets.dart';
import '../models/legend_item.dart' as legend_db;
import 'legend_vfs/legend_vfs_service.dart';
import 'dart:async';

/// 图例缓存状态
enum LegendLoadingState {
  notLoaded, // 未加载
  loading, // 加载中
  loaded, // 已加载
  error, // 加载失败
}

/// 缓存的图例项
class CachedLegendItem {
  final LegendLoadingState state;
  final legend_db.LegendItem? legendData;
  final String? errorMessage;
  final DateTime? loadedAt;

  const CachedLegendItem({
    required this.state,
    this.legendData,
    this.errorMessage,
    this.loadedAt,
  });

  CachedLegendItem copyWith({
    LegendLoadingState? state,
    legend_db.LegendItem? legendData,
    String? errorMessage,
    DateTime? loadedAt,
  }) {
    return CachedLegendItem(
      state: state ?? this.state,
      legendData: legendData ?? this.legendData,
      errorMessage: errorMessage ?? this.errorMessage,
      loadedAt: loadedAt ?? this.loadedAt,
    );
  }

  /// 是否需要重新加载（超过5分钟或状态为错误）
  bool get needsReload {
    if (state == LegendLoadingState.error) return true;
    if (state != LegendLoadingState.loaded) return false;
    if (loadedAt == null) return true;

    final now = DateTime.now();
    final elapsed = now.difference(loadedAt!);
    return elapsed.inMinutes > 5; // 5分钟后重新加载
  }
}

/// 图例缓存管理器
/// 提供图例的缓存加载、状态管理和自动更新功能
class LegendCacheManager extends ChangeNotifier {
  static final LegendCacheManager _instance = LegendCacheManager._internal();
  factory LegendCacheManager() => _instance;
  LegendCacheManager._internal();

  final Map<String, CachedLegendItem> _cache = {};
  final Map<String, Completer<legend_db.LegendItem?>> _loadingCompleters = {};
  final LegendVfsService _legendService = LegendVfsService();

  /// 获取缓存的图例项（可能为null或加载中）
  CachedLegendItem? getCachedLegendItem(String legendPath) {
    return _cache[legendPath];
  }

  /// 获取图例数据（异步加载）
  Future<legend_db.LegendItem?> getLegendData(String legendPath) async {
    if (legendPath.isEmpty || !legendPath.endsWith('.legend')) {
      return null;
    }

    // 检查缓存
    final cached = _cache[legendPath];
    if (cached != null && !cached.needsReload) {
      switch (cached.state) {
        case LegendLoadingState.loaded:
          return cached.legendData;
        case LegendLoadingState.loading:
          // 等待正在进行的加载
          return await _waitForLoading(legendPath);
        case LegendLoadingState.error:
          // 重试加载
          return await _loadLegend(legendPath);
        case LegendLoadingState.notLoaded:
          return await _loadLegend(legendPath);
      }
    }

    // 需要加载或重新加载
    return await _loadLegend(legendPath);
  }

  /// 预加载图例（不阻塞UI）
  void preloadLegend(String legendPath) {
    if (legendPath.isEmpty || !legendPath.endsWith('.legend')) {
      return;
    }

    final cached = _cache[legendPath];
    if (cached != null && !cached.needsReload) {
      return; // 已经加载或正在加载
    }

    // 异步预加载
    _loadLegend(legendPath);
  }

  /// 批量预加载图例
  void preloadLegends(List<String> legendPaths) {
    for (final path in legendPaths) {
      preloadLegend(path);
    }
  }

  /// 获取加载状态
  LegendLoadingState getLoadingState(String legendPath) {
    final cached = _cache[legendPath];
    return cached?.state ?? LegendLoadingState.notLoaded;
  }

  /// 是否已加载
  bool isLoaded(String legendPath) {
    final cached = _cache[legendPath];
    return cached?.state == LegendLoadingState.loaded;
  }

  /// 是否正在加载
  bool isLoading(String legendPath) {
    final cached = _cache[legendPath];
    return cached?.state == LegendLoadingState.loading;
  }

  /// 获取错误信息
  String? getErrorMessage(String legendPath) {
    final cached = _cache[legendPath];
    return cached?.state == LegendLoadingState.error
        ? cached?.errorMessage
        : null;
  }

  /// 清除特定图例的缓存
  void clearCache(String legendPath) {
    _cache.remove(legendPath);
    _loadingCompleters.remove(legendPath);
    notifyListeners();
  }

  /// 清除所有缓存
  void clearAllCache() {
    _cache.clear();
    _loadingCompleters.clear();
    notifyListeners();
  }

  /// 获取缓存统计信息
  Map<String, int> getCacheStats() {
    final stats = <String, int>{
      'total': _cache.length,
      'loaded': 0,
      'loading': 0,
      'error': 0,
      'notLoaded': 0,
    };

    for (final cached in _cache.values) {
      switch (cached.state) {
        case LegendLoadingState.loaded:
          stats['loaded'] = stats['loaded']! + 1;
          break;
        case LegendLoadingState.loading:
          stats['loading'] = stats['loading']! + 1;
          break;
        case LegendLoadingState.error:
          stats['error'] = stats['error']! + 1;
          break;
        case LegendLoadingState.notLoaded:
          stats['notLoaded'] = stats['notLoaded']! + 1;
          break;
      }
    }

    return stats;
  }

  /// 加载图例的内部实现
  Future<legend_db.LegendItem?> _loadLegend(String legendPath) async {
    // 如果已经在加载中，等待现有的加载完成
    if (_loadingCompleters.containsKey(legendPath)) {
      return await _waitForLoading(legendPath);
    }

    // 设置加载状态
    _cache[legendPath] = const CachedLegendItem(
      state: LegendLoadingState.loading,
    );
    notifyListeners();

    // 创建加载Completer
    final completer = Completer<legend_db.LegendItem?>();
    _loadingCompleters[legendPath] = completer;

    try {
      // 从VFS路径解析图例标题和文件夹路径
      String actualPath = legendPath;

      // 如果是完整的VFS路径，需要提取相对路径部分
      if (legendPath.startsWith('indexeddb://')) {
        // 格式: indexeddb://r6box/legends/[folderPath/]title.legend
        final uri = Uri.parse(legendPath);
        final pathSegments = uri.pathSegments;

        // pathSegments 应该是 ['legends', ...folderPath, 'title.legend']
        if (pathSegments.length >= 2 && pathSegments[0] == 'legends') {
          // 移除 'legends' 前缀，剩下的就是相对路径
          actualPath = pathSegments.skip(1).join('/');
        }
      }

      final pathParts = actualPath.split('/');
      if (pathParts.isEmpty) {
        throw Exception('无效的图例路径');
      }

      final fileName = pathParts.last;
      final title = fileName.replaceAll('.legend', '');
      final folderPath = pathParts.length > 1
          ? pathParts.sublist(0, pathParts.length - 1).join('/')
          : null;

      // 加载图例数据
      debugPrint(
        '图例缓存: 解析路径 $legendPath -> title=$title, folderPath=$folderPath, actualPath=$actualPath',
      );
      final legendData = await _legendService.getLegend(title, folderPath);

      if (legendData != null) {
        // 加载成功
        _cache[legendPath] = CachedLegendItem(
          state: LegendLoadingState.loaded,
          legendData: legendData,
          loadedAt: DateTime.now(),
        );
        completer.complete(legendData);
        debugPrint('图例缓存: 成功加载 $legendPath');
      } else {
        // 数据为空
        _cache[legendPath] = const CachedLegendItem(
          state: LegendLoadingState.error,
          errorMessage: '图例数据为空',
        );
        completer.complete(null);
        debugPrint('图例缓存: 图例数据为空 $legendPath');
      }
    } catch (e) {
      // 加载失败
      final errorMessage = '加载失败: $e';
      _cache[legendPath] = CachedLegendItem(
        state: LegendLoadingState.error,
        errorMessage: errorMessage,
      );
      completer.complete(null);
      debugPrint('图例缓存: 加载失败 $legendPath, 错误: $e');
    } finally {
      // 清理加载状态
      _loadingCompleters.remove(legendPath);
      notifyListeners();
    }

    return completer.future;
  }

  /// 等待正在进行的加载
  Future<legend_db.LegendItem?> _waitForLoading(String legendPath) async {
    final completer = _loadingCompleters[legendPath];
    if (completer != null) {
      return await completer.future;
    }

    // 如果没有找到加载器，返回缓存的数据
    final cached = _cache[legendPath];
    return cached?.legendData;
  }

  @override
  void dispose() {
    _cache.clear();
    _loadingCompleters.clear();
    super.dispose();
  }
}
