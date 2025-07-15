import 'package:equatable/equatable.dart';
import '../models/map_layer.dart';
import '../models/map_item.dart';
import '../models/timer_data.dart';

/// 地图数据状态
abstract class MapDataState extends Equatable {
  const MapDataState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class MapDataInitial extends MapDataState {
  const MapDataInitial();
}

/// 加载中状态
class MapDataLoading extends MapDataState {
  const MapDataLoading();
}

/// 已加载状态
class MapDataLoaded extends MapDataState {
  final MapItem mapItem;
  final List<MapLayer> layers;
  final List<LegendGroup> legendGroups;
  final List<TimerData> timers;
  final DateTime lastModified;
  final Map<String, dynamic> metadata;
  final Map<String, bool> manuallyClosedLegendGroups; // 手动关闭的图例组标记

  const MapDataLoaded({
    required this.mapItem,
    required this.layers,
    required this.legendGroups,
    this.timers = const [],
    required this.lastModified,
    this.metadata = const {},
    this.manuallyClosedLegendGroups = const {},
  });

  @override
  List<Object?> get props => [
    mapItem,
    layers,
    legendGroups,
    timers,
    lastModified,
    metadata,
    manuallyClosedLegendGroups,
  ];

  /// 创建副本，用于状态更新
  MapDataLoaded copyWith({
    MapItem? mapItem,
    List<MapLayer>? layers,
    List<LegendGroup>? legendGroups,
    List<TimerData>? timers,
    DateTime? lastModified,
    Map<String, dynamic>? metadata,
    Map<String, bool>? manuallyClosedLegendGroups,
  }) {
    return MapDataLoaded(
      mapItem: mapItem ?? this.mapItem,
      layers: layers ?? this.layers,
      legendGroups: legendGroups ?? this.legendGroups,
      timers: timers ?? this.timers,
      lastModified: lastModified ?? this.lastModified,
      metadata: metadata ?? this.metadata,
      manuallyClosedLegendGroups: manuallyClosedLegendGroups ?? this.manuallyClosedLegendGroups,
    );
  }

  /// 获取指定ID的图层
  MapLayer? getLayerById(String layerId) {
    try {
      return layers.firstWhere((layer) => layer.id == layerId);
    } catch (e) {
      return null;
    }
  }

  /// 获取指定ID的图例组
  LegendGroup? getLegendGroupById(String groupId) {
    try {
      return legendGroups.firstWhere((group) => group.id == groupId);
    } catch (e) {
      return null;
    }
  }

  /// 获取按order排序的图层
  List<MapLayer> get sortedLayers {
    final sorted = List<MapLayer>.from(layers);
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }

  /// 获取可见图层
  List<MapLayer> get visibleLayers {
    return layers.where((layer) => layer.isVisible).toList();
  }

  /// 获取可见图例组
  List<LegendGroup> get visibleLegendGroups {
    return legendGroups.where((group) => group.isVisible).toList();
  }

  /// 获取指定ID的计时器
  TimerData? getTimerById(String timerId) {
    try {
      return timers.firstWhere((timer) => timer.id == timerId);
    } catch (e) {
      return null;
    }
  }

  /// 获取运行中的计时器
  List<TimerData> get runningTimers {
    return timers.where((timer) => timer.isRunning).toList();
  }

  /// 获取已暂停的计时器
  List<TimerData> get pausedTimers {
    return timers.where((timer) => timer.isPaused).toList();
  }

  /// 获取已完成的计时器
  List<TimerData> get completedTimers {
    return timers.where((timer) => timer.isCompleted).toList();
  }

  /// 检查是否有运行中的计时器
  bool get hasRunningTimers => runningTimers.isNotEmpty;

  /// 获取按创建时间排序的计时器
  List<TimerData> get sortedTimers {
    final sorted = List<TimerData>.from(timers);
    sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted;
  }
}

/// 错误状态
class MapDataError extends MapDataState {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  const MapDataError({required this.message, this.error, this.stackTrace});

  @override
  List<Object?> get props => [message, error, stackTrace];
}

/// 保存中状态
class MapDataSaving extends MapDataState {
  final MapDataLoaded currentData;

  const MapDataSaving({required this.currentData});

  @override
  List<Object?> get props => [currentData];
}

/// 已保存状态
class MapDataSaved extends MapDataState {
  final MapDataLoaded data;
  final DateTime savedAt;

  const MapDataSaved({required this.data, required this.savedAt});

  @override
  List<Object?> get props => [data, savedAt];
}
