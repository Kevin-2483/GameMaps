import 'package:flutter/foundation.dart';
import 'map_item.dart';

/// 地图版本信息
@immutable
class MapVersion {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MapItem? mapData; // 版本的地图数据，null表示未加载

  const MapVersion({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.mapData,
  });

  MapVersion copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    MapItem? mapData,
  }) {
    return MapVersion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mapData: mapData ?? this.mapData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapVersion &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, createdAt, updatedAt);
  }

  @override
  String toString() {
    return 'MapVersion(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 从JSON创建
  factory MapVersion.fromJson(Map<String, dynamic> json) {
    return MapVersion(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// 版本管理器
class MapVersionManager {
  final String mapTitle;
  final Map<String, MapVersion> _versions = {};
  String _currentVersionId = 'default';

  MapVersionManager({required this.mapTitle});

  /// 获取所有版本
  List<MapVersion> get versions => _versions.values.toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  /// 获取当前版本ID
  String get currentVersionId => _currentVersionId;

  /// 获取当前版本
  MapVersion? get currentVersion => _versions[_currentVersionId];

  /// 添加版本（用于从存储加载）
  void addVersion(MapVersion version) {
    _versions[version.id] = version;
  }
  /// 从数据创建版本（用于加载已存在的版本）
  MapVersion createVersionFromData(String versionId, String name, MapItem mapData) {
    final now = DateTime.now();
    
    // 创建地图数据的深拷贝，避免引用问题
    final deepCopiedMapData = mapData.copyWith(
      layers: mapData.layers.map((layer) => layer.copyWith()).toList(),
      legendGroups: mapData.legendGroups.map((group) => group.copyWith()).toList(),
      updatedAt: now,
    );
    
    final version = MapVersion(
      id: versionId,
      name: name,
      createdAt: now,
      updatedAt: now,
      mapData: deepCopiedMapData,
    );
    
    _versions[versionId] = version;
    return version;
  }/// 创建新版本
  MapVersion createVersion(String name, MapItem currentMapData) {
    final now = DateTime.now();
    
    // 使用清理后的版本名称作为版本ID
    String versionId = _sanitizeVersionName(name);
    
    // 确保版本ID唯一
    versionId = _ensureUniqueVersionId(versionId);
    
    // 创建地图数据的深拷贝，避免引用问题
    final deepCopiedMapData = currentMapData.copyWith(
      layers: currentMapData.layers.map((layer) => layer.copyWith()).toList(),
      legendGroups: currentMapData.legendGroups.map((group) => group.copyWith()).toList(),
      updatedAt: now,
    );
    
    final version = MapVersion(
      id: versionId,
      name: name,
      createdAt: now,
      updatedAt: now,
      mapData: deepCopiedMapData,
    );
    
    _versions[versionId] = version;
    return version;
  }

  /// 清理版本名称，使其可以作为文件夹名
  String _sanitizeVersionName(String name) {
    if (name.isEmpty) {
      return 'untitled_version';
    }
    
    String sanitized = name
        // 替换不安全的字符为下划线
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        // 替换空格为下划线
        .replaceAll(RegExp(r'\s+'), '_')
        // 移除连续的下划线
        .replaceAll(RegExp(r'_+'), '_')
        // 移除首尾的点和下划线
        .replaceAll(RegExp(r'^[._]+|[._]+$'), '')
        // 限制长度
        .substring(0, name.length > 50 ? 50 : name.length);
    
    // 如果处理后为空，使用默认名称
    if (sanitized.isEmpty) {
      return 'untitled_version';
    }
    
    return sanitized;
  }

  /// 确保版本ID唯一
  String _ensureUniqueVersionId(String baseId) {
    if (!_versions.containsKey(baseId)) {
      return baseId;
    }
    
    int counter = 1;
    String uniqueId;
    do {
      uniqueId = '${baseId}_$counter';
      counter++;
    } while (_versions.containsKey(uniqueId));
    
    return uniqueId;
  }

  /// 切换到指定版本
  void switchToVersion(String versionId) {
    if (_versions.containsKey(versionId)) {
      _currentVersionId = versionId;
    }
  }
  /// 获取版本信息
  MapVersion? getVersion(String versionId) {
    return _versions[versionId];
  }

  /// 删除版本
  bool deleteVersion(String versionId) {
    // 不能删除默认版本
    if (versionId == 'default') return false;
    
    // 不能删除当前版本
    if (versionId == _currentVersionId) return false;
    
    return _versions.remove(versionId) != null;
  }

  /// 检查版本是否存在
  bool hasVersion(String versionId) {
    return _versions.containsKey(versionId);
  }
  /// 更新版本数据
  void updateVersionData(String versionId, MapItem mapData) {
    final version = _versions[versionId];
    if (version != null) {
      // 创建地图数据的深拷贝，避免引用问题
      final deepCopiedMapData = mapData.copyWith(
        layers: mapData.layers.map((layer) => layer.copyWith()).toList(),
        legendGroups: mapData.legendGroups.map((group) => group.copyWith()).toList(),
        updatedAt: DateTime.now(),
      );
      
      _versions[versionId] = version.copyWith(
        mapData: deepCopiedMapData,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// 获取版本数据
  MapItem? getVersionData(String versionId) {
    return _versions[versionId]?.mapData;
  }

  /// 清空所有版本（保留默认版本）
  void clear() {
    _versions.clear();
    _currentVersionId = 'default';
    
    // 重新添加默认版本
    final now = DateTime.now();
    _versions['default'] = MapVersion(
      id: 'default',
      name: '默认版本',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 初始化默认版本
  void initializeDefault() {
    if (!_versions.containsKey('default')) {
      final now = DateTime.now();
      _versions['default'] = MapVersion(
        id: 'default',
        name: '默认版本',
        createdAt: now,
        updatedAt: now,
      );
    }
  }
}
