// This file has been processed by AI for internationalization
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'map_layer.dart';
import 'sticky_note.dart'; // 导入StickyNote

import '../services/localization_service.dart';

part 'map_item.g.dart';

/// Uint8List 转换器，用于 JSON 序列化
class Uint8ListConverter implements JsonConverter<Uint8List?, String?> {
  const Uint8ListConverter();

  @override
  Uint8List? fromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    return base64Decode(json);
  }

  @override
  String? toJson(Uint8List? object) {
    if (object == null || object.isEmpty) return null;
    return base64Encode(object);
  }
}

/// 地图项数据模型
@JsonSerializable()
class MapItem {
  final int? id;
  final String title;
  @Uint8ListConverter()
  final Uint8List? imageData; // 图片二进制数据
  final int version; // 地图版本
  final List<MapLayer> layers; // 图层列表
  final List<LegendGroup> legendGroups; // 图例组列表
  final List<StickyNote> stickyNotes; // 便签列表
  final List<String>? tags; // 标签列表，用于分类和筛选
  final DateTime createdAt;
  final DateTime updatedAt;
  const MapItem({
    this.id,
    required this.title,
    this.imageData,
    required this.version,
    this.layers = const [],
    this.legendGroups = const [],
    this.stickyNotes = const [], // 默认无便签
    this.tags, // 标签列表，默认为null
    required this.createdAt,
    required this.updatedAt,
  });

  /// 检查是否有图像数据
  bool get hasImageData => imageData != null && imageData!.isNotEmpty;

  factory MapItem.fromJson(Map<String, dynamic> json) =>
      _$MapItemFromJson(json);
  Map<String, dynamic> toJson() => _$MapItemToJson(this);

  /// 从数据库记录创建 MapItem
  factory MapItem.fromDatabase(Map<String, dynamic> map) {
    // 解析图层、图例组和便签数据
    List<MapLayer> layers = [];
    List<LegendGroup> legendGroups = [];
    List<StickyNote> stickyNotes = [];

    if (map['layers'] != null) {
      try {
        final layersJson = json.decode(map['layers'] as String);
        if (layersJson is List) {
          layers = layersJson
              .map((e) => MapLayer.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        debugPrint(
          LocalizationService.instance.current.layerDataParseFailed_7421(e),
        );
        // 如果解析失败，继续使用空列表
      }
    }

    if (map['legend_groups'] != null) {
      try {
        final legendGroupsJson = json.decode(map['legend_groups'] as String);
        if (legendGroupsJson is List) {
          legendGroups = legendGroupsJson
              .map((e) => LegendGroup.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        debugPrint(
          LocalizationService.instance.current.legendDataParseFailed_7285(e),
        );
        // 如果解析失败，继续使用空列表
      }
    }

    if (map['sticky_notes'] != null) {
      try {
        final stickyNotesJson = json.decode(map['sticky_notes'] as String);
        if (stickyNotesJson is List) {
          stickyNotes = stickyNotesJson
              .map((e) => StickyNote.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        debugPrint(
          LocalizationService.instance.current.parseNoteDataFailed_7284(e),
        );
        // 如果解析失败，继续使用空列表
      }
    }
    return MapItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      imageData: map['image_data'] as Uint8List?,
      version: map['version'] as int,
      layers: layers,
      legendGroups: legendGroups,
      stickyNotes: stickyNotes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// 转换为数据库记录
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'image_data': imageData,
      'version': version,
      'layers': json.encode(layers.map((e) => e.toJson()).toList()),
      'legend_groups': json.encode(
        legendGroups.map((e) => e.toJson()).toList(),
      ),
      'sticky_notes': json.encode(stickyNotes.map((e) => e.toJson()).toList()),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// 创建副本
  MapItem copyWith({
    int? id,
    String? title,
    Uint8List? imageData,
    int? version,
    List<MapLayer>? layers,
    List<LegendGroup>? legendGroups,
    List<StickyNote>? stickyNotes,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearId = false,
    bool clearImageData = false,
    bool clearTags = false,
  }) {
    return MapItem(
      id: clearId ? null : (id ?? this.id),
      title: title ?? this.title,
      imageData: clearImageData ? null : (imageData ?? this.imageData),
      version: version ?? this.version,
      layers: layers ?? this.layers,
      legendGroups: legendGroups ?? this.legendGroups,
      stickyNotes: stickyNotes ?? this.stickyNotes,
      tags: clearTags ? null : (tags ?? this.tags),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 数据库版本信息
@JsonSerializable()
class MapDatabase {
  final int version; // 整个数据库版本
  final List<MapItem> maps;
  final DateTime exportedAt;

  const MapDatabase({
    required this.version,
    required this.maps,
    required this.exportedAt,
  });

  factory MapDatabase.fromJson(Map<String, dynamic> json) =>
      _$MapDatabaseFromJson(json);
  Map<String, dynamic> toJson() => _$MapDatabaseToJson(this);
}
