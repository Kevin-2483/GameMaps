import 'package:equatable/equatable.dart';
import '../models/map_layer.dart';
import '../models/map_item.dart';

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
  final DateTime lastModified;
  final Map<String, dynamic> metadata;

  const MapDataLoaded({
    required this.mapItem,
    required this.layers,
    required this.legendGroups,
    required this.lastModified,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
    mapItem,
    layers,
    legendGroups,
    lastModified,
    metadata,
  ];

  /// 创建副本，用于状态更新
  MapDataLoaded copyWith({
    MapItem? mapItem,
    List<MapLayer>? layers,
    List<LegendGroup>? legendGroups,
    DateTime? lastModified,
    Map<String, dynamic>? metadata,
  }) {
    return MapDataLoaded(
      mapItem: mapItem ?? this.mapItem,
      layers: layers ?? this.layers,
      legendGroups: legendGroups ?? this.legendGroups,
      lastModified: lastModified ?? this.lastModified,
      metadata: metadata ?? this.metadata,
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
}

/// 错误状态
class MapDataError extends MapDataState {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  const MapDataError({
    required this.message,
    this.error,
    this.stackTrace,
  });

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

  const MapDataSaved({
    required this.data,
    required this.savedAt,
  });

  @override
  List<Object?> get props => [data, savedAt];
}
